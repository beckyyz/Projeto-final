# Script to run the Flutter app
# This PowerShell script helps start an emulator and run the app

Write-Host "=== Diário de Viagens App Launcher ===" -ForegroundColor Cyan
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow

# Check Flutter
flutter doctor -v
if ($LASTEXITCODE -ne 0) {
    Write-Host "Flutter installation issues detected. Please fix them before continuing." -ForegroundColor Red
    exit 1
}

Write-Host "`nGetting available emulators..." -ForegroundColor Yellow
$emulators = flutter emulators
Write-Host $emulators

Write-Host "`nChoose how to run the app:" -ForegroundColor Cyan
Write-Host "1. Start a specific emulator"
Write-Host "2. Run on any available device"
Write-Host "3. Clean and rebuild the app"
$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        $emulatorId = Read-Host "Enter the emulator ID from the list above"
        Write-Host "`nStarting emulator: $emulatorId..." -ForegroundColor Yellow
        flutter emulators --launch $emulatorId
        
        Write-Host "Waiting for emulator to start (30 seconds)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        
        Write-Host "`nRunning the app..." -ForegroundColor Green
        flutter run
    }
    "2" {
        Write-Host "`nRunning the app on available device..." -ForegroundColor Green
        flutter run
    }
    "3" {
        Write-Host "`nCleaning the project..." -ForegroundColor Yellow
        flutter clean
        
        Write-Host "`nGetting dependencies..." -ForegroundColor Yellow
        flutter pub get
        
        Write-Host "`nRunning the app..." -ForegroundColor Green
        flutter run
    }
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}
