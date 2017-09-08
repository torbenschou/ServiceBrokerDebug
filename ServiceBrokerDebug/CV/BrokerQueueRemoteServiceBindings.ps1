param
(
  [string] $SourceDB 
  , [string] $SourceInstance 
  , [string] $TargetDB
  , [string] $targetInstance
  , [int] $SamplingTime
)


<#
  .SYNOPSIS
      A powershell script to sample Dynamic Management Views for Service Broker
      

  .DESCRIPTION
      A remote service binding defines the credential to use while initiating a conversation with a remote service outside SQL Server instance. 
      This catalog view gives information about the Service Broker Remote Service Binding object created in the current database.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerQueueRemoteServiceBindings.ps1 -SourceInstance .\MySourceInstance -SourceDB mySourceDB -TargetInstance .\myTargetInstance -TargetDB myTargetDB -SamplingTime (secounds)


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
                     name, remote_service_binding_id, principal_id, remote_service_name, service_contract_id, remote_principal_id, is_anonymous_on
                   FROM sys.remote_service_bindings
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
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Broker Queue Data - BrokerQueueRemoteServiceBindings.ps1" -EntryType Warning
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
function WriteBrokerQueueData([string]$TargetInstance, [string]$TargetDB, $dataTable)
{
    $conTarget = New-Object System.Data.SqlClient.SqlConnection
    $conTarget.ConnectionString = "Data Source=$TargetInstance;Initial Catalog=$TargetDB;Integrated Security=True;";

    try
    {
        $conTarget.Open()  

        $bc = New-Object System.Data.SqlClient.SqlBulkCopy $conTarget
        $bc.DestinationTableName = "SolidQ.remote_service_bindings" 
        $bc.ColumnMappings.Add("name", "name")
        $bc.ColumnMappings.Add("remote_service_binding_id", "remote_service_binding_id")
        $bc.ColumnMappings.Add("principal_id", "principal_id")
        $bc.ColumnMappings.Add("remote_service_name", "remote_service_name")
        $bc.ColumnMappings.Add("service_contract_id", "service_contract_id")
        $bc.ColumnMappings.Add("remote_principal_id", "remote_principal_id")
        $bc.ColumnMappings.Add("is_anonymous_on", "is_anonymous_on")
        $bc.WriteToServer($dataTable)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Queue Data - BrokerQueueRemoteServiceBindings.ps1" -EntryType Warning
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

  WriteBrokerQueueData $TargetInstance $TargetDB $data

  
  if ($Global:SamplingTime -gt 1) { sleep-until -s $Global:SamplingTime }

} 

#endregion run service get worst queries