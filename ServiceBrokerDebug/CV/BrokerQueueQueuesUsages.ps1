﻿
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
      Provides information about the Service Broker Queue and Service association in the current database.
      Please note a service can be associated with only one queue, whereas a queue can be associated with more than one services if required.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerQueueQueuesUsages.ps1 -SourceInstance .\MySourceInstance -SourceDB mySourceDB -TargetInstance .\myTargetInstance -TargetDB myTargetDB


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
                     service_id, service_queue_id
                   FROM sys.service_queue_usages
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
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Broker Queue Data - BrokerQueueQueuesUsages.ps1" -EntryType Warning
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
        $bc.DestinationTableName = "SolidQ.service_queue_usages" 
        $bc.ColumnMappings.Add("service_id", "service_id")
        $bc.ColumnMappings.Add("service_queue_id", "service_queue_id")
        $bc.WriteToServer($dataTable)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Queue Data - BrokerQueueQueuesUsages.ps1" -EntryType Warning
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

  
  Start-Sleep -s $Global:SamplingTime

} 

#endregion run service get worst queries