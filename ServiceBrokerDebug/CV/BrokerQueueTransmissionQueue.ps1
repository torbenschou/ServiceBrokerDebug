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
      A transmission queue is a special internal table of Service Broker in which messages get stored 
      if they could not be written to target queue because of any issue. 
      Messages are first put in transmission queue if the target is outside SQL Server instance and are sent from there. 
      Once the Service Broker on Initiator receives the acknowledgement from the target service
      , message is removed from the transmission queue only then.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerQueueTransmissionQueue.ps1 -SourceInstance .\MySourceInstance -SourceDB mySourceDB -TargetInstance .\myTargetInstance -TargetDB myTargetDB -SamplingTime (secounds)


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
                     conversation_handle, to_service_name, to_broker_instance, from_service_name, service_contract_name
                     , enqueue_time, message_sequence_number, message_type_name, is_conversation_error, is_end_of_dialog
                     , message_body, transmission_status, priority
                   FROM sys.transmission_queue
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
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Broker Queue Data - BrokerQueueTransmissionQueue.ps1" -EntryType Warning
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
        $bc.DestinationTableName = "SolidQ.transmission_queue" 

        $bc.ColumnMappings.Add("conversation_handle", "conversation_handle")
        $bc.ColumnMappings.Add("to_service_name", "to_service_name")
        $bc.ColumnMappings.Add("to_broker_instance", "to_broker_instance")
        $bc.ColumnMappings.Add("from_service_name", "from_service_name")
        $bc.ColumnMappings.Add("service_contract_name", "service_contract_name")
        $bc.ColumnMappings.Add("enqueue_time", "enqueue_time")
        $bc.ColumnMappings.Add("message_sequence_number", "message_sequence_number")
        $bc.ColumnMappings.Add("message_type_name", "message_type_name")
        $bc.ColumnMappings.Add("is_conversation_error", "is_conversation_error")
        $bc.ColumnMappings.Add("is_end_of_dialog", "is_end_of_dialog")
        $bc.ColumnMappings.Add("message_body", "message_body")
        $bc.ColumnMappings.Add("transmission_status", "transmission_status")
        $bc.ColumnMappings.Add("priority", "priority")

        $bc.WriteToServer($dataTable)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Queue Data - BrokerQueueTransmissionQueue.ps1" -EntryType Warning
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message $_.Exception.Message -EntryType Error
    }
    Finally
    {
    $conTarget.Close()
    }

}
#endregion WriteBrokerQueueData

#region sample

EventLogExists

$Global:SamplingTime = $SamplingTime

while ($true)
{ 


  $data = GetBrokerQueueData $SourceInstance $SourceDB

  WriteBrokerQueueData $RepositoryInstance $RepositoryDatabase $data

  
  if ($Global:SamplingTime -gt 1) { sleep-until -s $Global:SamplingTime }

} 

#endregion sample