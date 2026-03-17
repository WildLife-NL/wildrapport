param(
    [switch]$Apk,
    [switch]$SkipVersion
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $root
Write-Host "Projectmap: $root"

if (-not $SkipVersion) {
    Write-Host ""
    Write-Host "Stap 1/2: Version bijwerken naar builddatum..."
    dart run tool/update_version_to_date.dart
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FOUT: Version update mislukt (exit code $LASTEXITCODE). Controleer of 'dart' in je PATH staat." -ForegroundColor Red
        exit $LASTEXITCODE
    }
    Write-Host "Version bijgewerkt." -ForegroundColor Green
}

Write-Host ""
Write-Host "Stap 2/2: Release app bundle bouwen..."
flutter build appbundle
if ($LASTEXITCODE -ne 0) {
    Write-Host "FOUT: Flutter build mislukt (exit code $LASTEXITCODE). Controleer of 'flutter' in je PATH staat en of je signing hebt geconfigureerd (android/key.properties, upload-keystore)." -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "Release build voltooid. Output: build/app/outputs/bundle/release/" -ForegroundColor Green
if ($Apk) {
    Write-Host "APK bouwen..."
    flutter build apk --release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
