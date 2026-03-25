# Run Flutter tests with code coverage.
# Usage: .\scripts\run_coverage.ps1
# Optional: pass -Html to generate HTML report (requires genhtml/lcov on PATH).

param(
    [switch]$Html
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path (Join-Path $projectRoot "pubspec.yaml"))) {
    $projectRoot = (Get-Location).Path
}

Set-Location $projectRoot

Write-Host "Running tests with coverage..." -ForegroundColor Cyan
& flutter test --coverage
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Fix failures before viewing coverage." -ForegroundColor Red
    exit $LASTEXITCODE
}

$lcovPath = Join-Path $projectRoot "coverage\lcov.info"
if (-not (Test-Path $lcovPath)) {
    Write-Host "Coverage file not found at $lcovPath" -ForegroundColor Red
    exit 1
}

# Normalize paths: Flutter on Windows writes SF:lib\... but Coverage Gutters expects lib/...
(Get-Content $lcovPath -Raw) -replace '\\', '/' | Set-Content $lcovPath -NoNewline
Write-Host "Coverage written to coverage\lcov.info (paths normalized for Coverage Gutters)" -ForegroundColor Green

if ($Html) {
    $genhtml = Get-Command genhtml -ErrorAction SilentlyContinue
    if ($genhtml) {
        $htmlDir = Join-Path $projectRoot "coverage\html"
        New-Item -ItemType Directory -Force -Path $htmlDir | Out-Null
        & genhtml $lcovPath -o $htmlDir
        Write-Host "HTML report: coverage\html\index.html" -ForegroundColor Green
        Write-Host "Open in browser: $htmlDir\index.html"
    } else {
        Write-Host "genhtml (lcov) not found. Install lcov for HTML reports, e.g.:" -ForegroundColor Yellow
        Write-Host "  choco install lcov" -ForegroundColor Yellow
        Write-Host "  or use a VS Code extension (e.g. Coverage Gutters) with coverage\lcov.info"
    }
}
