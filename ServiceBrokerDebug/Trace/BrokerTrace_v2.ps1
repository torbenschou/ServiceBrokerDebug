clear-host


[string] $targetInstance = "SQLSERVER-0"
[int] $SamplingTime = 1      # In minutes 
[string] $TraceFilename = "F:\DATA\trace.trc" # Full path C:\data\trace.trc
[string] $TraceInputFile = "F:\DATA\trace.sql"


Function StartTrace ([string] $Instance, [int] $Time, [string] $Filename, [string] $InputFile)
{
  #Parameter
  $dbParam1 = "FileName=" + $FileName
  $dbParam2 = "TraceTime=" + $Time
  $dbParam = $dbParam1, $dbParam2
  
  Invoke-Sqlcmd -ServerInstance $Instance -InputFile $InputFile -Variable $dbParam
}

StartTrace $targetInstance $SamplingTime $TraceFilename $TraceInputFile