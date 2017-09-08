param
(
  [string] $SourceHost 
  , [string] $TargetDB
  , [string] $targetInstance
  , [int] $SamplingTime
)
<#
  .SYNOPSIS
      A powershell script to sample Service Broker related Performance counters 
      

  .DESCRIPTION
     Retrieve the Service Broker related Performance counters from Source and stored these in repository database
     - SQLServer:Memory Broker Clerks(*)
     - SQLServer:Broker Statistics
     - SQLServer:Broker/DBM Transport
     - SQLServer:Broker Activation(*)
     - SQLServer:Broker TO Statistics


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerCounters.ps1 -SourceHost . -TargetInstance .\myTargetInstance -TargetDB myTargetDB -SamplingTime (secounds)


#>

Clear-Host

Set-ExecutionPolicy unrestricted -Force


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

#region Get-BrokerCountersFromSource
function Get-BrokerCounters([string]$SourceHost)
{
    $DataTable = New-Object System.Data.DataTable

    $Col1 = New-Object System.Data.DataColumn Counter,([string])
    $Col2 = New-Object System.Data.DataColumn Value, ([float])

    $DataTable.Columns.Add($Col1)
    $DataTable.Columns.Add($Col2)


    $CounterSet = Get-Counter -ListSet *Broker* | ForEach-Object {    
        $CounterCategory = $_
        $CounterCategory |
        Select-Object -ExpandProperty Counter
    } 

    foreach ($myCounter in $CounterSet)
    {

      $myCounter = '\\' + "$SourceHost" + $myCounter
      $row = $DataTable.NewRow();
      $row.Counter = $myCounter
      $row.Value = (Get-Counter $myCounter -MaxSamples 1).CounterSamples[0].CookedValue

      $DataTable.Rows.Add($row)

      $myCounter
      (Get-Counter $myCounter -MaxSamples 1).CounterSamples[0].CookedValue

      #write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "$DataTable.row[0}[0]" -EntryType Warning
    }

    return $DataTable
}
#endregion Get-BrokerCountersFromSource

function WriteBrokerCounts ($TargetInstance, $TargetDB, $data)
{
    $conTarget = New-Object System.Data.SqlClient.SqlConnection
    $conTarget.ConnectionString = "Data Source=$TargetInstance;Initial Catalog=$TargetDB;Integrated Security=True;";

    try
    {
        $conTarget.Open()  

        $bc = New-Object System.Data.SqlClient.SqlBulkCopy $conTarget
        $bc.DestinationTableName = "SolidQ.BrokerPerfCounters" 

        $bc.ColumnMappings.Add("Counter", "CounterName")
        $bc.ColumnMappings.Add("Value", "Value")

        $bc.WriteToServer($data)
    }
    Catch
    {
        $ex = $_.exception
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message "Bulk insert - Broker Counter Data - BrokerCounters.ps1" -EntryType Warning
        write-eventlog -logname Application -Source "Queue Problem" -EventId 50001 -Message $_.Exception.Message -EntryType Error
    }
    Finally
    {
    $conTarget.Close()
    }

}

#region sample

EventLogExists

$Global:SamplingTime = $SamplingTime

while ($true)
{ 


  $data = Get-BrokerCounters $SourceHost

  WriteBrokerCounts $TargetInstance $TargetDB $data
  
  if ($Global:SamplingTime -gt 1) { Start-Sleep -s $Global:SamplingTime }

} 

#endregion sample