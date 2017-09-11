param
(  
  [string] $SourceInstance
  , [int] $SamplingTime      # In minutes 
  , [string] $TraceFilename  # Full path C:\data\trace.trc
  , [string] $TraceInputFile
)

<#
  .SYNOPSIS
      A powershell script to sample Service Broker related trace data 
      

  .DESCRIPTION
     Start a service side trace based on the input file ($TraceInputFile)
	 The result will be written to local storage on the server ($TraceFilename)
	 The output are limit to 200 files with a max of 250MB.


  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerTrace.ps1 -SourceHost "." -TraceInputFile "C:\temp\myTrace.sql" -TraceFilename "C:\Temp\resultTrace.trc" -SamplingTime (minuttes)


#>

Function StartTrace ([string] $Instance, [int] $time, [string] $Filename, [string] $InputFile)
{
  #Parameter
  $dbParam1 = "FileName=" + $FileName
  $dbParam2 = "TraceTime=" + $Time
  $dbParam = $dbParam1, $dbParam2
  
  Invoke-Sqlcmd -ServerInstance $Instance -InputFile $InputFile -Variable $dbParam
}

StartTrace $SourceInstance $SamplingTime $TraceFilename $TraceInputFile