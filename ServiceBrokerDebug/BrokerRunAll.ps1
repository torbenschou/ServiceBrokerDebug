Param(
	$SamplingTime,
	$SourceHost,
	$SourceInstance,
	$SourceDatabase,
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

Set-ExecutionPolicy Unrestricted -Force

function GetCounters([string] $SourceHost, [string]$RepositoryInstance, [string]$RepositoryDatabase, $SamplingTime)
{
	$Files = Get-ChildItem -Path .\ServiceBrokerDebug\Counters |Where-Object { $_.Extension -match "ps1" } | Select-Object -Property FullName

	$param = $SourceHost, $RepositoryInstance, $RepositoryDatabase, $SamplingTime

	Start-Job -Name "GetCounters" -ScriptBlock {
		param([string]$files, $param)
		foreach ($file in $files) {
			Invoke-Command -FilePath $file -ArgumentList ($param)
			}
		} -ArgumentList ($Files, $param)
	
}

function GetCatalogViews([string] $SourceInstance, [string]$SourceDatabase, [string]$RepositoryInstance, [string]$RepositoryDatabase, $SamplingTime)
{
	$Files = Get-ChildItem -Path .\ServiceBrokerDebug\CV |Where-Object { $_.Extension -match "ps1" } | Select-Object -Property FullName

	$param = $SourceInstance, $SourceDatabase, $RepositoryInstance, $RepositoryDatabase, $SamplingTime

	Start-Job -Name "GetCatalogViews" -ScriptBlock {
		param([string]$files, $param)
		foreach ($file in $files) {
			Invoke-Command -FilePath $file -ArgumentList ($param)
			}
		} -ArgumentList ($Files, $param)
}

function GetDMV ([string] $SourceInstance, [string]$SourceDatabase, [string]$RepositoryInstance, [string]$RepositoryDatabase, $SamplingTime)
{
	$Files = Get-ChildItem -Path .\ServiceBrokerDebug\DMV |Where-Object { $_.Extension -match "ps1" } | Select-Object -Property FullName

	$param = $SourceInstance, $SourceDatabase, $RepositoryInstance, $RepositoryDatabase, $SamplingTime

	Start-Job -Name "GetDMV" -ScriptBlock {
		param([string]$files, $param)
		foreach ($file in $files) {
			Invoke-Command -FilePath $file -ArgumentList ($param)
			}
		} -ArgumentList ($Files, $param)
}


