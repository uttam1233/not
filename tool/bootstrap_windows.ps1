# Run from project root in PowerShell:
#   powershell -ExecutionPolicy Bypass -File .	oolootstrap_windows.ps1

Write-Host "Bootstrapping Flutter project files..." -ForegroundColor Cyan

# Generate platform folders (including ios) on Windows.
flutter create . --platforms=android,ios,web,windows

Write-Host "Getting packages..." -ForegroundColor Cyan
flutter pub get

Write-Host "Generating code (Isar)..." -ForegroundColor Cyan
dart run build_runner build --delete-conflicting-outputs

Write-Host "Done. You can now push to GitHub and use Actions to build an IPA." -ForegroundColor Green
