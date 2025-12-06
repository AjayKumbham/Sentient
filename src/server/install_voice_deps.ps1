# Install All Dependencies for Free Voice Features
# This installs FASTER_WHISPER + ORPHEUS dependencies

Write-Host "Installing dependencies for FREE voice features..." -ForegroundColor Cyan
Write-Host ""

$dependencies = @(
    "faster-whisper",
    "snac",
    "llama-cpp-python",
    "google-generativeai"
)

foreach ($dep in $dependencies) {
    Write-Host "Installing $dep..." -ForegroundColor Yellow
    & ".\venv\Scripts\pip.exe" install $dep
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $dep installed successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to install $dep" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "All dependencies installed!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now start the server with:" -ForegroundColor Cyan
Write-Host '$env:ENVIRONMENT = "selfhost"' -ForegroundColor White
Write-Host "uvicorn main.app:app --reload" -ForegroundColor White
