
param
(
  [string] $SourceDB 
  , [string] $SourceInstance 
  , [string] $RepositoryDatabase
  , [string] $RepositoryInstance
  , [int] $SamplingTime
)


<#
  .SYNOPSIS
      A powershell script to sample Dynamic Management Views for Service Broker
      

  .DESCRIPTION
      This DMV gives information about the network connection established by Service Broker, including the state of the network connection.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerQueueConnections.ps1 -SourceInstance .\MySourceInstance -SourceDB mySourceDB -TargetInstance .\myTargetInstance -TargetDB myTargetDB -SamplingTime (seconds)


#>


Clear-Host

Set-ExecutionPolicy Unrestricted -Force

#region base function
Function EventLogExists
{
  if ([System.Diagnostics.EventLog]::SourceExists("Queue Problem") -eq $False) 
  {
    New-EventLog -LogName "Application" -Source "Queue Problem"
  }
}
#endregion base function

#region GetBrokerQueueData
Function GetBrokerQueueData([string]$SourceInstance, [string]$SourceDB)
{
  	# Create SqlConnection object, define connection string, and open connection 
 	$con = New-Object System.Data.SqlClient.SqlConnection 
 	$con.ConnectionString = "Data Source=$SourceInstance;Initial Catalog=$SourceDB;Integrated Security=True;Application Name=QueueProblemSampler;"
    
    try
    {
        $con.Open();

        $sqlstr = @("
                   SELECT 
                     connection_id, transport_stream_id, state, state_desc, connect_time, login_time, authentication_method, principal_name, remote_user_name, last_activity_time, is_accept
                     , login_state, login_state_desc, peer_certificate_id, encryption_algorithm, encryption_algorithm_desc, receives_posted, is_receive_flow_controlled, sends_posted
                     , is_send_flow_controlled, total_bytes_sent, total_bytes_received, total_fragments_sent, total_fragments_received, total_sends, total_receives, peer_arbitration_id
                   FROM sys.dm_broker_connections
        ")


        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand    
        $SqlCmd.Connection = $con
        $SqlCmd.CommandText = $sqlstr

        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd

        $DataSet = New-Object System.Data.DataSet
        $SqlAdapter.Fill($DataSet) | Out-Null

        $data = New-Object System.Data.DataTable  
        $data = $DataSet.Tables[0]
    }
    catch
    {
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Broker Queue Data - BrokerQueueConnections.ps1" -EntryType Warning
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message $_.Exception.Message -EntryType Error
    }

    Finally
    {
        $con.Close()
    } 
  
    return $data

}	
#endregion GetBrokerQueueData

#region WriteBrokerQueueData
function WriteBrokerQueueData([string]$RepositoryInstance, [string]$RepositoryDatabase, $dataTable)
{
    $conTarget = New-Object System.Data.SqlClient.SqlConnection
    $conTarget.ConnectionString = "Data Source=$RepositoryInstance;Initial Catalog=$RepositoryDatabase;Integrated Security=True;";

    try
    {
        $conTarget.Open()  

        $bc = New-Object System.Data.SqlClient.SqlBulkCopy $conTarget
        $bc.DestinationTableName = "SolidQ.dm_broker_connections" 
        $bc.ColumnMappings.Add("connection_id", "connection_id")
        $bc.ColumnMappings.Add("transport_stream_id", "transport_stream_id")
        $bc.ColumnMappings.Add("state", "state")
        $bc.ColumnMappings.Add("state_desc", "state_desc")
        $bc.ColumnMappings.Add("connect_time", "connect_time")
        $bc.ColumnMappings.Add("login_time", "login_time")
        $bc.ColumnMappings.Add("authentication_method", "authentication_method")
        $bc.ColumnMappings.Add("principal_name", "principal_name")
        $bc.ColumnMappings.Add("remote_user_name", "remote_user_name")
        $bc.ColumnMappings.Add("last_activity_time", "last_activity_time")
        $bc.ColumnMappings.Add("is_accept", "is_accept")
        $bc.ColumnMappings.Add("login_state", "login_state")
        $bc.ColumnMappings.Add("login_state_desc", "login_state_desc")
        $bc.ColumnMappings.Add("peer_certificate_id", "peer_certificate_id")
        $bc.ColumnMappings.Add("encryption_algorithm", "encryption_algorithm")
        $bc.ColumnMappings.Add("encryption_algorithm_desc", "encryption_algorithm_desc")
        $bc.ColumnMappings.Add("receives_posted", "receives_posted")
        $bc.ColumnMappings.Add("is_receive_flow_controlled", "is_receive_flow_controlled")
        $bc.ColumnMappings.Add("sends_posted", "sends_posted")
        $bc.ColumnMappings.Add("is_send_flow_controlled", "is_send_flow_controlled")
        $bc.ColumnMappings.Add("total_bytes_sent", "total_bytes_sent")
        $bc.ColumnMappings.Add("total_bytes_received", "total_bytes_received")
        $bc.ColumnMappings.Add("total_fragments_sent", "total_fragments_sent")
        $bc.ColumnMappings.Add("total_fragments_received", "total_fragments_received")
        $bc.ColumnMappings.Add("total_sends", "total_sends")
        $bc.ColumnMappings.Add("total_receives", "total_receives")
        $bc.ColumnMappings.Add("peer_arbitration_id", "peer_arbitration_id")
        $bc.WriteToServer($dataTable)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Queue Data - BrokerQueueConnections.ps1" -EntryType Warning
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message $_.Exception.Message -EntryType Error
    }
    Finally
    {
    $conTarget.Close()
    }

}
#endregion WriteBrokerQueueData

#region run service 
EventLogExists

$Global:SamplingTime = $SamplingTime

while ($true)
{ 


  $data = GetBrokerQueueData $SourceInstance $SourceDB

  WriteBrokerQueueData $RepositoryInstance $RepositoryDatabase $data

  
  Start-Sleep -s $Global:SamplingTime

} 

#endregion run service 