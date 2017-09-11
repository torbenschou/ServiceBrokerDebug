Param(
	$SamplingTime,
	$SourceInstance,
	$RepositoryInstance,
	$RepositoryDatabase,
    [string] $TraceFilename,  # Full path C:\data\trace.trc
    [string] $TraceInputFile



)

<#
  .SYNOPSIS
      A powershell script to sample Service Broker related trace data 
      

  .DESCRIPTION



  .NOTES
      Auther: SolidQ Nordic
              
              Torben Schou (tschou@solidq.com)
              

  .SAMPLE
  .\BrokerTrace.ps1 -SourceHost "." -TraceInputFile "C:\temp\myTrace.sql" -TraceFilename "C:\Temp\resultTrace.trc" -SamplingTime (minuttes)


#>

Clear-Host

function GetCounters([string] $SourceInstance, $RepositoryInstance, $RepositoryDatabase, $SamplingTime)
{
	$Files = Get-ChildItem -Path .\ServiceBrokerDebug\Counters | Select-Object -Property FullName

	$param = $SourceInstance, $RepositoryInstance, $RepositoryDatabase, $SamplingTime

	Start-Job -Name "GetCounters" -ScriptBlock {
		param([string]$files, $param)
		foreach ($file in $files) {
			Invoke-Command -FilePath $file -ArgumentList ($param)
			}
		} -ArgumentList ($Files, $param)
	
}
