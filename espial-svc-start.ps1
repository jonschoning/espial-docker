<#
.SYNOPSIS
  Windows equivalent of `espial-svc-start`: brings up Espial and tails logs to espial.log.
#>
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$ScriptDir\espial.ps1" up-d
& "$ScriptDir\espial.ps1" logs 2>&1 | Tee-Object -Append -FilePath (Join-Path $ScriptDir 'espial.log')
