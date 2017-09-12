
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
      This catalog view gives information about the Service Broker Message Type created in the current database
      , including the validation type to be used and XML Schema Collection Id.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerQueueMessageTypes.ps1 -SourceInstance .\MySourceInstance -SourceDB mySourceDB -TargetInstance .\myTargetInstance -TargetDB myTargetDB -SampleTime (seconds)


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
                     name, message_type_id, principal_id, validation, validation_desc, xml_collection_id
                   FROM sys.service_message_types
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
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Broker Queue Data - BrokerQueueMessageTypes.ps1" -EntryType Warning
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
        $bc.DestinationTableName = "SolidQ.service_message_types" 
        $bc.ColumnMappings.Add("name", "name")
        $bc.ColumnMappings.Add("message_type_id", "message_type_id")
        $bc.ColumnMappings.Add("principal_id", "principal_id")
        $bc.ColumnMappings.Add("validation", "validation")
        $bc.ColumnMappings.Add("validation_desc", "validation_desc")
        $bc.ColumnMappings.Add("xml_collection_id", "xml_collection_id")
        $bc.WriteToServer($dataTable)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Queue Data - BrokerQueueMessageTypes.ps1" -EntryType Warning
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

  
  sleep-until -s $Global:SamplingTime

} 

#endregion run service get worst queries