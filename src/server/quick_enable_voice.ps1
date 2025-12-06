# Quick Enable Free Voice - Auto-configure for free voice features
# STT: FASTER_WHISPER, TTS: ORPHEUS (both free and local)

Write-Host "Enabling FREE Voice Features (FASTER_WHISPER + ORPHEUS)..." -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
    exit 1
}

# Read current .env
$content = Get-Content ".env" -Raw

# Update STT Provider
$content = $content -replace '(?m)^STT_PROVIDER=.*', 'STT_PROVIDER=FASTER_WHISPER'
Write-Host "Set STT_PROVIDER=FASTER_WHISPER" -ForegroundColor Green

# Update TTS Provider  
$content = $content -replace '(?m)^TTS_PROVIDER=.*', 'TTS_PROVIDER=ORPHEUS'
Write-Host "Set TTS_PROVIDER=ORPHEUS" -ForegroundColor Green

# Update FASTER_WHISPER settings
$content = $content -replace '(?m)^FASTER_WHISPER_MODEL_SIZE=.*', 'FASTER_WHISPER_MODEL_SIZE=base'
Write-Host "Set FASTER_WHISPER_MODEL_SIZE=base" -ForegroundColor Green

$content = $content -replace '(?m)^FASTER_WHISPER_DEVICE=.*', 'FASTER_WHISPER_DEVICE=cpu'
Write-Host "Set FASTER_WHISPER_DEVICE=cpu" -ForegroundColor Green

$content = $content -replace '(?m)^FASTER_WHISPER_COMPUTE_TYPE=.*', 'FASTER_WHISPER_COMPUTE_TYPE=float32'
Write-Host "Set FASTER_WHISPER_COMPUTE_TYPE=float32" -ForegroundColor Green

# Update ORPHEUS settings - using single quotes to avoid escaping issues
$orpheusPath = 'ORPHEUS_MODEL_PATH="src/server/main/voice/models/orpheus-3b-0.1-ft-q4_k_m.gguf"'
$content = $content -replace '(?m)^ORPHEUS_MODEL_PATH=.*', $orpheusPath
Write-Host "Set ORPHEUS_MODEL_PATH" -ForegroundColor Green

# Save .env
$content | Set-Content ".env" -NoNewline

Write-Host ""
Write-Host "Configuration complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  STT: FASTER_WHISPER (base model, CPU)" -ForegroundColor White
Write-Host "  TTS: ORPHEUS (local)" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANT: Download Orpheus model" -ForegroundColor Yellow
Write-Host "  1. Create folder: src\server\main\voice\models" -ForegroundColor White
Write-Host "  2. Download from HuggingFace: ggerganov/orpheus" -ForegroundColor White
Write-Host "     File: orpheus-3b-0.1-ft-q4_k_m.gguf" -ForegroundColor White
Write-Host "  3. Place file in the models folder" -ForegroundColor White
Write-Host ""
