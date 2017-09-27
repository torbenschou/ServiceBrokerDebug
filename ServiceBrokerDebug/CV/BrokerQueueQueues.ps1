
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
      Provides information about the Service Broker Queue in the current database
      , including name of the activation stored procedure
      , maximum number of instances of activation stored procedures that can be created
      , whether the queue is enabled or disabled, etc.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerQueueQueues.ps1 -SourceInstance .\MySourceInstance -SourceDB mySourceDB -TargetInstance .\myTargetInstance -TargetDB myTargetDB


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
                     name, object_id, principal_id, schema_id, parent_object_id, type, type_desc, create_date, modify_date
                     , is_ms_shipped, is_published, is_schema_published, max_readers, activation_procedure, execute_as_principal_id
                     , is_activation_enabled, is_receive_enabled, is_enqueue_enabled, is_retention_enabled, is_poison_message_handling_enabled
                   FROM sys.service_queues
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
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Broker Queue Data - BrokerQueueQueues.ps1" -EntryType Warning
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
        $bc.DestinationTableName = "SolidQ.service_queues" 
        $bc.ColumnMappings.Add("name", "name")
        $bc.ColumnMappings.Add("object_id", "object_id")
        $bc.ColumnMappings.Add("principal_id", "principal_id")
        $bc.ColumnMappings.Add("schema_id", "schema_id")
        $bc.ColumnMappings.Add("parent_object_id", "parent_object_id")
        $bc.ColumnMappings.Add("type", "type")
        $bc.ColumnMappings.Add("type_desc", "type_desc")
        $bc.ColumnMappings.Add("create_date", "create_date")
        $bc.ColumnMappings.Add("modify_date", "modify_date")
        $bc.ColumnMappings.Add("is_ms_shipped", "is_ms_shipped")
        $bc.ColumnMappings.Add("is_published", "is_published")
        $bc.ColumnMappings.Add("is_schema_published", "is_schema_published")
        $bc.ColumnMappings.Add("max_readers", "max_readers")
        $bc.ColumnMappings.Add("activation_procedure", "activation_procedure")
        $bc.ColumnMappings.Add("execute_as_principal_id", "execute_as_principal_id")
        $bc.ColumnMappings.Add("is_activation_enabled", "is_activation_enabled")
        $bc.ColumnMappings.Add("is_receive_enabled", "is_receive_enabled")
        $bc.ColumnMappings.Add("is_enqueue_enabled", "is_enqueue_enabled")
        $bc.ColumnMappings.Add("is_retention_enabled", "is_retention_enabled")
        $bc.ColumnMappings.Add("is_poison_message_handling_enabled", "is_poison_message_handling_enabled")
        $bc.WriteToServer($dataTable)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Queue Data - BrokerQueueQueues.ps1" -EntryType Warning
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