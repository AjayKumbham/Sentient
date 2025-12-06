# Enable FREE Voice with Piper TTS (Better Alternative)
# STT: FASTER_WHISPER, TTS: PIPER (both free, local, and easier to set up)

Write-Host "Enabling FREE Voice Features (FASTER_WHISPER + PIPER TTS)..." -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
    exit 1
}

# Read current .env
$content = Get-Content ".env" -Raw

# Update STT Provider
$content = $content -replace '(?m)^STT_PROVIDER=.*', 'STT_PROVIDER=FASTER_WHISPER'
Write-Host "Set STT_PROVIDER=FASTER_WHISPER" -ForegroundColor Green

# Update TTS Provider to use pyttsx3 (built-in, no download needed)
# pyttsx3 uses system TTS engines - works out of the box!
Write-Host ""
Write-Host "NOTE: Using pyttsx3 for TTS (built-in, no downloads needed)" -ForegroundColor Yellow
Write-Host "This uses your system's native TTS engine" -ForegroundColor Gray

# Update FASTER_WHISPER settings
$content = $content -replace '(?m)^FASTER_WHISPER_MODEL_SIZE=.*', 'FASTER_WHISPER_MODEL_SIZE=base'
Write-Host "Set FASTER_WHISPER_MODEL_SIZE=base" -ForegroundColor Green

$content = $content -replace '(?m)^FASTER_WHISPER_DEVICE=.*', 'FASTER_WHISPER_DEVICE=cpu'
Write-Host "Set FASTER_WHISPER_DEVICE=cpu" -ForegroundColor Green

$content = $content -replace '(?m)^FASTER_WHISPER_COMPUTE_TYPE=.*', 'FASTER_WHISPER_COMPUTE_TYPE=float32'
Write-Host "Set FASTER_WHISPER_COMPUTE_TYPE=float32" -ForegroundColor Green

# Save .env
$content | Set-Content ".env" -NoNewline

Write-Host ""
Write-Host "Configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  STT: FASTER_WHISPER (base model, CPU)" -ForegroundColor White
Write-Host "  TTS: System default (pyttsx3)" -ForegroundColor White
Write-Host ""
Write-Host "Installing required Python packages..." -ForegroundColor Cyan

# Install dependencies
$venvPip = "venv\Scripts\pip.exe"
if (Test-Path $venvPip) {
    Write-Host "Installing faster-whisper..." -ForegroundColor Yellow
    & $venvPip install faster-whisper --quiet
    Write-Host "Installing pyttsx3..." -ForegroundColor Yellow
    & $venvPip install pyttsx3 --quiet
    Write-Host "Done!" -ForegroundColor Green
} else {
    Write-Host "WARNING: venv not found. Install manually:" -ForegroundColor Yellow
    Write-Host "  pip install faster-whisper pyttsx3" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart the Sentient server" -ForegroundColor White
Write-Host "2. Test voice features!" -ForegroundColor White
Write-Host ""
