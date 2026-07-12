<#
.SYNOPSIS
  Windows equivalent of `espial-svc-stop`: stops the Espial stack.
#>
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$ScriptDir\espial.ps1" down
