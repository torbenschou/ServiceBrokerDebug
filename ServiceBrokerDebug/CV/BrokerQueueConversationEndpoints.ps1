
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
      A conversation has two endpoints represented by Initiator and Target. 
      This catalog view gives the information about the conversation endpoints created in the current database. 
      Also, it indicates the state of those endpoints; e.g., conversing, error, closed, etc.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerQueueConversationEndpoints.ps1 -SourceInstance .\MySourceInstance -SourceDB mySourceDB -TargetInstance .\myTargetInstance -TargetDB myTargetDB -SamplingTime (secounds)


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


Function sleep-until($future_time) 
{ 
    if ([String]$future_time -as [DateTime]) { 
        if ($(get-date $future_time) -gt $(get-date)) { 
            $sec = [system.math]::ceiling($($(get-date $future_time) - $(get-date)).totalseconds) 
            start-sleep -seconds $sec 
        } 
        else { 
            write-host "You must specify a date/time in the future" 
            return 
        } 
    } 
    else { 
        write-host "Incorrect date/time format" 
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
                     conversation_handle, conversation_id, is_initiator, service_contract_id, conversation_group_id, service_id
                     , lifetime, state, state_desc, far_service, far_broker_instance, principal_id, far_principal_id
                     , outbound_session_key_identifier, inbound_session_key_identifier, security_timestamp, dialog_timer
                     , send_sequence, last_send_tran_id, end_dialog_sequence, receive_sequence, receive_sequence_frag
                     , system_sequence, first_out_of_order_sequence, last_out_of_order_sequence, last_out_of_order_frag
                     , is_system, priority
                   FROM sys.conversation_endpoints
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
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Broker Queue Data - BrokerQueueConversationEndpoints.ps1" -EntryType Warning
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
        $bc.DestinationTableName = "SolidQ.conversation_endpoints" 

        $bc.ColumnMappings.Add("conversation_handle", "conversation_handle")
        $bc.ColumnMappings.Add("conversation_id", "conversation_id")
        $bc.ColumnMappings.Add("is_initiator", "is_initiator")
        $bc.ColumnMappings.Add("service_contract_id", "service_contract_id")
        $bc.ColumnMappings.Add("conversation_group_id", "conversation_group_id")
        $bc.ColumnMappings.Add("service_id", "service_id")
        $bc.ColumnMappings.Add("lifetime", "lifetime")
        $bc.ColumnMappings.Add("state", "state")
        $bc.ColumnMappings.Add("state_desc", "state_desc")
        $bc.ColumnMappings.Add("far_service", "far_service")
        $bc.ColumnMappings.Add("far_broker_instance", "far_broker_instance")
        $bc.ColumnMappings.Add("principal_id", "principal_id")
        $bc.ColumnMappings.Add("far_principal_id", "far_principal_id")
        $bc.ColumnMappings.Add("outbound_session_key_identifier", "outbound_session_key_identifier")
        $bc.ColumnMappings.Add("inbound_session_key_identifier", "inbound_session_key_identifier")
        $bc.ColumnMappings.Add("security_timestamp", "security_timestamp")
        $bc.ColumnMappings.Add("dialog_timer", "dialog_timer")
        $bc.ColumnMappings.Add("send_sequence", "send_sequence")
        $bc.ColumnMappings.Add("last_send_tran_id", "last_send_tran_id")
        $bc.ColumnMappings.Add("end_dialog_sequence", "end_dialog_sequence")
        $bc.ColumnMappings.Add("receive_sequence", "receive_sequence")
        $bc.ColumnMappings.Add("receive_sequence_frag", "receive_sequence_frag")
        $bc.ColumnMappings.Add("system_sequence", "system_sequence")
        $bc.ColumnMappings.Add("first_out_of_order_sequence", "first_out_of_order_sequence")
        $bc.ColumnMappings.Add("last_out_of_order_sequence", "last_out_of_order_sequence")
        $bc.ColumnMappings.Add("last_out_of_order_frag", "last_out_of_order_frag")
        $bc.ColumnMappings.Add("is_system", "is_system")
        $bc.ColumnMappings.Add("priority", "priority")

        $bc.WriteToServer($dataTable)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Queue Data - BrokerQueueConversationEndpoints.ps1" -EntryType Warning
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message $_.Exception.Message -EntryType Error
    }
    Finally
    {
    $conTarget.Close()
    }

}
#endregion WriteBrokerQueueData

#region run service get worst queries

EventLogExists

$Global:SamplingTime = $SamplingTime

while ($true)
{ 


  $data = GetBrokerQueueData $SourceInstance $SourceDB

  WriteBrokerQueueData $RepositoryInstance $RepositoryDatabase $data

  
  if ($Global:SamplingTime -gt 1) { sleep-until -s $Global:SamplingTime }

} 

#endregion run service get worst queries