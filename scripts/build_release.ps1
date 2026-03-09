# Release build: zet version op builddatum en bouw app bundle (en optioneel APK).
# Gebruik: .\scripts\build_release.ps1
#         .\scripts\build_release.ps1 -Apk   # bouw ook APK
#         .\scripts\build_release.ps1 -SkipVersion  # bouw zonder version te updaten

param(
    [switch]$Apk,
    [switch]$SkipVersion
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $root

if (-not $SkipVersion) {
    Write-Host "Version bijwerken naar builddatum..."
    dart run tool/update_version_to_date.dart
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "Release build starten (app bundle)..."
flutter build appbundle
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($Apk) {
    Write-Host "Release APK bouwen..."
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "Release build voltooid. Output o.a. in build/app/outputs/bundle/release/"
