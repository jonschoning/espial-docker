<#
.SYNOPSIS
  Windows PowerShell equivalent of the Makefile, for driving the Espial docker compose stack.

.DESCRIPTION
  Mirrors the targets in `Makefile` so Windows users without `make`/POSIX shell
  can run the same workflow described in README.md.

.PARAMETER Command
  pull | createdb | up | up-d | down | logs | logs-espial | shell

.PARAMETER ComposeFile
  Optional alternate compose file (e.g. docker-compose-caddy.yml). Defaults to docker-compose.yml.

.EXAMPLE
  ./espial.ps1 pull
  ./espial.ps1 up-d
  ./espial.ps1 logs
  ./espial.ps1 -ComposeFile docker-compose-caddy.yml up-d
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('pull', 'createdb', 'up', 'up-d', 'down', 'logs', 'logs-espial', 'shell')]
    [string]$Command,

    [Parameter()]
    [string]$ComposeFile
)

$ErrorActionPreference = 'Stop'

$composeArgs = @('compose')
if ($ComposeFile) {
    $composeArgs += @('-f', $ComposeFile)
}

function Invoke-Compose {
    param([string[]]$SubArgs)
    & docker @composeArgs @SubArgs
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

switch ($Command) {
    'pull' {
        Invoke-Compose @('pull', 'espial')
    }
    'createdb' {
        Invoke-Compose @('exec', 'espial', './migration', 'createdb')
    }
    'up' {
        Invoke-Compose @('up', 'espial')
    }
    'up-d' {
        Invoke-Compose @('up', '-d', 'espial')
    }
    'down' {
        Invoke-Compose @('down')
    }
    'logs-espial' {
        $since = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $containerId = & docker @composeArgs ps -q espial
        & docker logs -f --since $since $containerId
    }
    'logs' {
        $since = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        Invoke-Compose @('logs', '-f', '--since', $since)
    }
    'shell' {
        Invoke-Compose @('exec', 'espial', 'sh')
    }
}
