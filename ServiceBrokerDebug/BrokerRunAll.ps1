﻿Param(
	$WorkDir,
	$SamplingTime,
	$SourceHost,
	$SourceInstance,
	$SourceDatabase,
	$RepositoryInstance,
	$RepositoryDatabase,
    [string] $TraceFilename,  # Full path C:\data\trace.trc
    [string] $TraceInputFile = "sql\Magna_BrokerTrace.sql"
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

$Global:debug = $false

Clear-Host

Set-ExecutionPolicy Unrestricted -Force



#region Counters
Set-ExecutionPolicy Unrestricted -Force

function GetCounters([string] $SourceHost, [string]$RepositoryInstance, [string]$RepositoryDatabase, $SamplingTime)
{
    $Files = Get-ChildItem -Path .\Counters | Where-Object { $_.Extension -match "ps1" } | Select-Object -Property FullName
    Foreach ($file in $Files) 
    {
 
      $file = $file.FullName  
      $Arg =  @("
        $file -Sourcehost $SourceHost -RepositoryInstance $RepositoryInstance -RepositoryDatabase $RepositoryDatabase -SamplingTime 60
      ")

      if ($Global:debug) { $Arg }
  
      Start-Process Powershell -ArgumentList $Arg -PassThru -Verbose
    }
}
#endregion 

#region Catalog Views
function GetCatalogViews([string] $SourceInstance, [string]$SourceDatabase, [string]$RepositoryInstance, [string]$RepositoryDatabase, $SamplingTime)
{
    $Files = Get-ChildItem -Path .\CV | Where-Object { $_.Extension -match "ps1" } | Select-Object -Property FullName
    Foreach ($file in $Files) 
    {
 
      $file = $file.FullName  
      $Arg =  @("
        $file -SourceInstance $SourceInstance -SourceDatabase $SourceDatabase -RepositoryInstance $RepositoryInstance -RepositoryDatabase $RepositoryDatabase -SamplingTime 60
      ")

      if ($Global:debug) { $Arg }
  
      Start-Process Powershell -ArgumentList $Arg -PassThru -Verbose
    }
}
#endregion


#region DMV
function GetDMV ([string] $SourceInstance, [string]$SourceDatabase, [string]$RepositoryInstance, [string]$RepositoryDatabase, $SamplingTime)
{
    $Files = Get-ChildItem -Path .\DMV | Where-Object { $_.Extension -match "ps1" } | Select-Object -Property FullName
    Foreach ($file in $Files) 
    {
 
      $file = $file.FullName  
      $Arg =  @("
        $file -SourceInstance $SourceInstance -SourceDatabase $SourceDatabase -RepositoryInstance $RepositoryInstance -RepositoryDatabase $RepositoryDatabase -SamplingTime 60
      ")


      if ($Global:debug) 
      { 
        $Arg
        Start-Process Powershell -ArgumentList $Arg -PassThru -Verbose
      } else {
  
        Start-Process Powershell -ArgumentList $Arg -PassThru -NoNewWindow
      }
    }
}
#endregion


#region RunServerSideTrace
function RunServerSideTrace([string] $SourceInstance, [int] $SamplingTime, [string] $TraceFilename, [string] $TraceInputFile)
{
    
    $local = (Get-Location).Path
    $ps = "$local\Trace\BrokerTrace.ps1"
    $trace = "$local\$TraceInputFile"

    $Arg = @("
      $ps -SourceInstance $SourceInstance -SamplingTime $SamplingTime -TraceFilename $TraceFilename -TraceInputFile $trace
    ")

    if ($Global:debug) 
    { 
      $Arg
      Start-Process Powershell -ArgumentList $Arg -PassThru -Verbose

    } else {
  
      Start-Process Powershell -ArgumentList $Arg -PassThru -NoNewWindow
    }

    
	#Invoke-Expression -FilePath .\Trace\BrokerTrace.ps1 -ArgumentList ($SourceInstance, $SamplingTime, $TraceFilename, $TraceInputFile)
}
#endregion

#region StopAll
Function StopAll($SamplingTime)
{
    Start-Sleep -Seconds 5
    Write-Host "Number of process running local are" @(Get-Process | Where-Object { $_.ProcessName -eq 'Powershell' }).Count -ForegroundColor DarkRed -BackgroundColor Yellow
    
    if ($Global:debug) { Get-Process | Where-Object { $_.ProcessName -eq 'Powershell' } }


    $SamplingTime = $SamplingTime * 60
    Start-Sleep -Seconds $SamplingTime

    ((Get-Process | Where-Object { $_.ProcessName -eq 'Powershell' }) | SELECT ID) | Stop-Process
}
#endregion

Set-Location $WorkDir

GetCounters $SourceHost $RepositoryInstance $RepositoryDatabase $SamplingTime

GetCatalogViews $SourceInstance $SourceDatabase $RepositoryInstance $RepositoryDatabase $SamplingTime

GetDMV $SourceInstance $SourceDatabase $RepositoryInstance $RepositoryDatabase $SamplingTime

RunServerSideTrace "$SourceInstance" "$SamplingTime" "$TraceFilename" "$TraceInputFile"

StopAll $SamplingTime