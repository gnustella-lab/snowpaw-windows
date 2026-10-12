# Snowpaw Native Windows Build Script
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\build.ps1 [-Release] [-Test]

param(
    [switch]$Release = $true,
    [switch]$Test = $false
)

$ErrorActionPreference = "Stop"

Write-Host "=== Snowpaw Windows Native Build ===" -ForegroundColor Cyan

# 1. Locate LLVM-MinGW UCRT toolchain
$llvmMingwCandidate = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\MartinStorsjo.LLVM-MinGW.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\llvm-mingw-20260908-ucrt-x86_64\bin"

if (Test-Path $llvmMingwCandidate) {
    Write-Host "[+] Found LLVM-MinGW toolchain: $llvmMingwCandidate" -ForegroundColor Green
    $env:PATH = "$llvmMingwCandidate;$env:USERPROFILE\.cargo\bin;$env:PATH"
} else {
    Write-Host "[*] LLVM-MinGW not found in default WinGet package directory. Using current PATH." -ForegroundColor Yellow
}

# 2. Verify rustc target
$rustTarget = (rustc -vV | Select-String "host:").ToString().Split(':')[1].Trim()
Write-Host "[+] Rust host/target: $rustTarget" -ForegroundColor Green

# 3. Optional tests execution
if ($Test) {
    Write-Host "`n[*] Running entire workspace test suite..." -ForegroundColor Yellow
    cargo test --workspace --locked
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Tests failed!"
        exit $LASTEXITCODE
    }
    Write-Host "[+] All tests passed successfully!" -ForegroundColor Green
}

# 4. Build binaries
$profileFlag = if ($Release) { "--release" } else { "" }
Write-Host "`n[*] Building Snowpaw binaries ($($profileFlag.TrimStart('-')))..." -ForegroundColor Yellow

cargo build --workspace $profileFlag --locked
if ($LASTEXITCODE -ne 0) {
    Write-Error "Cargo build failed!"
    exit $LASTEXITCODE
}

$targetDir = if ($Release) { "target\release" } else { "target\debug" }
Write-Host "`n=== Build Completed Successfully! ===" -ForegroundColor Green
Write-Host "Generated native executables:" -ForegroundColor Cyan
Get-ChildItem -Path $targetDir -Filter "snowpaw*.exe" | ForEach-Object {
    Write-Host "  - $($_.Name) ($([math]::Round($_.Length / 1MB, 2)) MB)" -ForegroundColor White
}
