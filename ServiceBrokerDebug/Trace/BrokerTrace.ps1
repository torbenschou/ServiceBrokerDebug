param
(  
  [string] $targetInstance
  , [int] $SamplingTime      # In minutes 
  , [string] $TraceFilename  # Full path C:\data\trace.trc
  , [string] $TraceInputFile
)

Function StartTrace ([string] $Instance, [int] $time, [string] $Filename, [string] $InputFile)
{
  #Parameter
  $dbParam = @(
               "FileName='$FileName'",
               "TraceTime='$TraceTime'"
            )

  $splat = @{
    ServerInstance=$Instance
    InputFile=$InputFile
    Variable=$dbParam
  }  

  Invoke-Sqlcmd $splat
}

StartTrace $targetInstance $SamplingTime $TraceFilename $TraceInputFile