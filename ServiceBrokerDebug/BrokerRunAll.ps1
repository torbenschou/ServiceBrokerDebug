Param(
	$SamplingTime,
	$SourceHost,
	$SourceInstance,
	$SourceDatabase,
	$RepositoryInstance,
	$RepositoryDatabase,
    [string] $TraceFilename,  # Full path C:\data\trace.trc
    [string] $TraceInputFile = ".\ServiceBrokerDebug\Sql\Magna_BrokerTrace.sql"
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
  .\BrokerRunAll.ps1 -SamplingTime 15 -SourceHost "Magna01" -SourceInstance "Magno01\SQL01" -SourceDatabase "BrokerEnabled" -RepositoryInstance "Magna03\Repository" -RepositoryDatabase "SolidQ_ServiceBroker" -TraceFilename "E:\data\myTrace.trc" -$TraceInputFile ".\ServiceBrokerDebug\Sql\Magna_BrokerTrace.sql"


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
    
	$SamplingTime = (($SamplingTime * 60) / 5)
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

	$SamplingTime = ($SamplingTime * 60) / 15
	$param = $SourceInstance, $SourceDatabase, $RepositoryInstance, $RepositoryDatabase, $SamplingTime

	Start-Job -Name "GetDMV" -ScriptBlock {
		param([string]$files, $param)
		foreach ($file in $files) {
			Invoke-Command -FilePath $file -ArgumentList ($param)
			}
		} -ArgumentList ($Files, $param)
}

function StartTrace([string] $SourceInstance, [int] $SamplingTime, [string] $TraceFilename, [string] $TraceInputFile)
{
	Invoke-Command -FilePath .\ServiceBrokerDebug\Trace\BrokerTrace.ps1 -ArgumentList ($SourceInstance, $SamplingTime, $TraceFilename, $TraceInputFile)
}

function StopAllJobs($SamplingTime)
{
	Start-Sleep -Seconds ($SamplingTime * 60)

	$timeout = [timespan]::FromMinutes(1)
	$now = Get-Date

	Get-Job | Where {$_.State -eq 'Running' -and $_.Name -in ('GetCounters', 'GetCatalogViews', 'GetDMV') -and (($now - $_.PSBeginTime) -gt $timeout)} | Stop-Job

	Start-Sleep -Seconds 10

	Remove-Job -Name 'GetCounters'
	Remove-Job -Name 'GetCatalogViews'
	Remove-Job -Name 'GetDMV'

}


#region working
GetCounters $SourceHost $RepositoryInstance $RepositoryDatabase $SamplingTime

GetCatalogViews $SourceInstance $SourceDatabase $RepositoryInstance $RepositoryDatabase $SamplingTime

GetDMV $SourceInstance $SourceDatabase $RepositoryInstance $RepositoryDatabase $SamplingTime

StartTrace $SourceInstance $SamplingTime $TraceFilename $TraceInputFile

StopAllJobs $SamplingTime
#endregion
