# Snowpaw Native Windows Launcher Script
# Usage:
#   .\run.ps1 -Component server [-Init] [-Config <path>]
#   .\run.ps1 -Component client
#   .\run.ps1 -Component agent -Config <path>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("server", "client", "agent", "init")]
    [string]$Component,

    [string]$DataDir = "$env:APPDATA\snowpaw\data",
    [string]$Config = "",
    [switch]$Release = $true
)

$ErrorActionPreference = "Stop"

$llvmMingwCandidate = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\MartinStorsjo.LLVM-MinGW.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\llvm-mingw-20260908-ucrt-x86_64\bin"
if (Test-Path $llvmMingwCandidate) {
    $env:PATH = "$llvmMingwCandidate;$env:USERPROFILE\.cargo\bin;$env:PATH"
}

$binDir = if ($Release) { "target\release" } else { "target\debug" }

switch ($Component) {
    "init" {
        $serverBin = Join-Path $binDir "snowpaw-server.exe"
        if (-not (Test-Path $serverBin)) {
            Write-Error "Server binary not found at $serverBin. Run .\build.ps1 first."
            exit 1
        }
        Write-Host "[*] Initializing Snowpaw server data directory at $DataDir..." -ForegroundColor Cyan
        & $serverBin init $DataDir
        $configPath = Join-Path $DataDir "server.toml"
        Write-Host "`n[*] Now set the server password by running:" -ForegroundColor Yellow
        Write-Host "  & `"$serverBin`" set-password --config `"$configPath`"" -ForegroundColor White
    }
    "server" {
        $serverBin = Join-Path $binDir "snowpaw-server.exe"
        if (-not (Test-Path $serverBin)) {
            Write-Error "Server binary not found at $serverBin. Run .\build.ps1 first."
            exit 1
        }
        if ([string]::IsNullOrEmpty($Config)) {
            $Config = Join-Path $DataDir "server.toml"
        }
        if (-not (Test-Path $Config)) {
            Write-Host "[!] Config not found at $Config. Running init first..." -ForegroundColor Yellow
            & $serverBin init $DataDir
            Write-Host "`n[*] Please set a password first:" -ForegroundColor Yellow
            & $serverBin set-password --config $Config
        }
        Write-Host "[*] Starting Snowpaw Server ($Config)..." -ForegroundColor Green
        & $serverBin run --config $Config
    }
    "client" {
        $clientBin = Join-Path $binDir "snowpaw.exe"
        if (-not (Test-Path $clientBin)) {
            Write-Error "Client binary not found at $clientBin. Run .\build.ps1 first."
            exit 1
        }
        Write-Host "[*] Launching Snowpaw Desktop Client..." -ForegroundColor Green
        & $clientBin
    }
    "agent" {
        $agentBin = Join-Path $binDir "snowpaw-agent.exe"
        if (-not (Test-Path $agentBin)) {
            Write-Error "Agent binary not found at $agentBin. Run .\build.ps1 first."
            exit 1
        }
        if ([string]::IsNullOrEmpty($Config)) {
            Write-Error "Agent requires -Config <path-to-agent.toml>"
            exit 1
        }
        Write-Host "[*] Starting Snowpaw Agent ($Config)..." -ForegroundColor Green
        & $agentBin run --config $Config
    }
}
