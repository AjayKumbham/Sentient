# Voice Features Configuration and Testing Script
# This script helps you configure and test voice features in Sentient

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Sentient Voice Features Setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
    Write-Host "Please create a .env file from .env.template first" -ForegroundColor Yellow
    exit 1
}

# Function to update .env file
function Update-EnvVariable {
    param(
        [string]$Key,
        [string]$Value
    )
    
    $envPath = ".env"
    $content = Get-Content $envPath -Raw
    
    if ($content -match "^$Key=.*" -replace "`r`n", "`n") {
        $content = $content -replace "(?m)^$Key=.*", "$Key=$Value"
        Write-Host "✓ Updated $Key" -ForegroundColor Green
    } else {
        $content += "`n$Key=$Value"
        Write-Host "✓ Added $Key" -ForegroundColor Green
    }
    
    $content | Set-Content $envPath -NoNewline
}

# Display current configuration
Write-Host "Current Voice Configuration:" -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow
$currentSTT = (Select-String -Path ".env" -Pattern "^STT_PROVIDER=" | Select-Object -First 1).Line
$currentTTS = (Select-String -Path ".env" -Pattern "^TTS_PROVIDER=" | Select-Object -First 1).Line
Write-Host $currentSTT
Write-Host $currentTTS
Write-Host ""

# Menu for setup options
Write-Host "Choose your voice setup option:" -ForegroundColor Cyan
Write-Host "1. Free Local Setup (FASTER_WHISPER + ORPHEUS)" -ForegroundColor White
Write-Host "   - Completely free, runs locally" -ForegroundColor Gray
Write-Host "   - Requires GPU for best performance" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Cloud Setup (DEEPGRAM + ELEVENLABS)" -ForegroundColor White
Write-Host "   - Best quality, requires API keys" -ForegroundColor Gray
Write-Host "   - Paid service" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Hybrid Setup (FASTER_WHISPER + ELEVENLABS)" -ForegroundColor White
Write-Host "   - Free STT, paid TTS" -ForegroundColor Gray
Write-Host "   - Balanced option" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Custom Configuration" -ForegroundColor White
Write-Host ""
Write-Host "5. Test Current Configuration" -ForegroundColor White
Write-Host ""
Write-Host "6. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

switch ($choice) {
    "1" {
        Write-Host "`nConfiguring Free Local Setup..." -ForegroundColor Cyan
        Update-EnvVariable "STT_PROVIDER" "FASTER_WHISPER"
        Update-EnvVariable "TTS_PROVIDER" "ORPHEUS"
        Update-EnvVariable "FASTER_WHISPER_MODEL_SIZE" "base"
        
        # Ask about GPU
        $hasGPU = Read-Host "Do you have an NVIDIA GPU with CUDA? (y/n)"
        if ($hasGPU -eq "y") {
            Update-EnvVariable "FASTER_WHISPER_DEVICE" "cuda"
            Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float16"
        } else {
            Update-EnvVariable "FASTER_WHISPER_DEVICE" "cpu"
            Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float32"
        }
        
        Update-EnvVariable "ORPHEUS_MODEL_PATH" "src/server/main/voice/models/orpheus-3b-0.1-ft-q4_k_m.gguf"
        
        Write-Host "`n✓ Configuration complete!" -ForegroundColor Green
        Write-Host "`nNOTE: You need to download the Orpheus model:" -ForegroundColor Yellow
        Write-Host "1. Download from: https://huggingface.co/ggerganov/orpheus-3b-0.1-ft-q4_k_m" -ForegroundColor Yellow
        Write-Host "2. Place in: src/server/main/voice/models/" -ForegroundColor Yellow
    }
    
    "2" {
        Write-Host "`nConfiguring Cloud Setup..." -ForegroundColor Cyan
        Update-EnvVariable "STT_PROVIDER" "DEEPGRAM"
        Update-EnvVariable "TTS_PROVIDER" "ELEVENLABS"
        
        Write-Host "`nPlease enter your API keys:" -ForegroundColor Yellow
        $deepgramKey = Read-Host "Deepgram API Key"
        $elevenlabsKey = Read-Host "ElevenLabs API Key"
        
        if ($deepgramKey) {
            Update-EnvVariable "DEEPGRAM_API_KEY" $deepgramKey
        }
        if ($elevenlabsKey) {
            Update-EnvVariable "ELEVENLABS_API_KEY" $elevenlabsKey
        }
        
        Write-Host "`n✓ Configuration complete!" -ForegroundColor Green
    }
    
    "3" {
        Write-Host "`nConfiguring Hybrid Setup..." -ForegroundColor Cyan
        Update-EnvVariable "STT_PROVIDER" "FASTER_WHISPER"
        Update-EnvVariable "TTS_PROVIDER" "ELEVENLABS"
        Update-EnvVariable "FASTER_WHISPER_MODEL_SIZE" "base"
        
        # Ask about GPU
        $hasGPU = Read-Host "Do you have an NVIDIA GPU with CUDA? (y/n)"
        if ($hasGPU -eq "y") {
            Update-EnvVariable "FASTER_WHISPER_DEVICE" "cuda"
            Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float16"
        } else {
            Update-EnvVariable "FASTER_WHISPER_DEVICE" "cpu"
            Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float32"
        }
        
        Write-Host "`nPlease enter your ElevenLabs API key:" -ForegroundColor Yellow
        $elevenlabsKey = Read-Host "ElevenLabs API Key"
        
        if ($elevenlabsKey) {
            Update-EnvVariable "ELEVENLABS_API_KEY" $elevenlabsKey
        }
        
        Write-Host "`n✓ Configuration complete!" -ForegroundColor Green
    }
    
    "4" {
        Write-Host "`nCustom Configuration" -ForegroundColor Cyan
        Write-Host "-------------------" -ForegroundColor Cyan
        
        Write-Host "`nChoose STT Provider:" -ForegroundColor Yellow
        Write-Host "1. FASTER_WHISPER (Local, Free)"
        Write-Host "2. DEEPGRAM (Cloud, Paid)"
        Write-Host "3. ELEVENLABS (Cloud, Paid)"
        $sttChoice = Read-Host "Enter choice (1-3)"
        
        switch ($sttChoice) {
            "1" { 
                Update-EnvVariable "STT_PROVIDER" "FASTER_WHISPER"
                Update-EnvVariable "FASTER_WHISPER_MODEL_SIZE" "base"
                
                $hasGPU = Read-Host "Do you have an NVIDIA GPU with CUDA? (y/n)"
                if ($hasGPU -eq "y") {
                    Update-EnvVariable "FASTER_WHISPER_DEVICE" "cuda"
                    Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float16"
                } else {
                    Update-EnvVariable "FASTER_WHISPER_DEVICE" "cpu"
                    Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float32"
                }
            }
            "2" { 
                Update-EnvVariable "STT_PROVIDER" "DEEPGRAM"
                $key = Read-Host "Enter Deepgram API Key"
                if ($key) { Update-EnvVariable "DEEPGRAM_API_KEY" $key }
            }
            "3" { 
                Update-EnvVariable "STT_PROVIDER" "ELEVENLABS"
                $key = Read-Host "Enter ElevenLabs API Key"
                if ($key) { Update-EnvVariable "ELEVENLABS_API_KEY" $key }
            }
        }
        
        Write-Host "`nChoose TTS Provider:" -ForegroundColor Yellow
        Write-Host "1. ORPHEUS (Local, Free)"
        Write-Host "2. ELEVENLABS (Cloud, Paid)"
        Write-Host "3. SMALLEST_AI (Cloud, Paid)"
        $ttsChoice = Read-Host "Enter choice (1-3)"
        
        switch ($ttsChoice) {
            "1" { 
                Update-EnvVariable "TTS_PROVIDER" "ORPHEUS"
                Update-EnvVariable "ORPHEUS_MODEL_PATH" "src/server/main/voice/models/orpheus-3b-0.1-ft-q4_k_m.gguf"
            }
            "2" { 
                Update-EnvVariable "TTS_PROVIDER" "ELEVENLABS"
                $key = Read-Host "Enter ElevenLabs API Key"
                if ($key) { Update-EnvVariable "ELEVENLABS_API_KEY" $key }
            }
            "3" { 
                Update-EnvVariable "TTS_PROVIDER" "SMALLEST_AI"
                $key = Read-Host "Enter Smallest AI API Key"
                if ($key) { Update-EnvVariable "SMALLEST_AI_API_KEY" $key }
            }
        }
        
        Write-Host "`n✓ Configuration complete!" -ForegroundColor Green
    }
    
    "5" {
        Write-Host "`nTesting Current Configuration..." -ForegroundColor Cyan
        Write-Host "--------------------------------" -ForegroundColor Cyan
        
        # Check if server is running
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -ErrorAction Stop
            $health = $response.Content | ConvertFrom-Json
            
            Write-Host "`n✓ Server is running!" -ForegroundColor Green
            Write-Host "`nVoice Services Status:" -ForegroundColor Yellow
            Write-Host "STT: $($health.services.stt)" -ForegroundColor $(if ($health.services.stt -eq "loaded") { "Green" } else { "Red" })
            Write-Host "TTS: $($health.services.tts)" -ForegroundColor $(if ($health.services.tts -eq "loaded") { "Green" } else { "Red" })
            
            if ($health.services.stt -eq "loaded" -and $health.services.tts -eq "loaded") {
                Write-Host "`n✓ Voice features are fully enabled!" -ForegroundColor Green
            } else {
                Write-Host "`n⚠ Voice features are not fully loaded. Check server logs." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "`n✗ Server is not running or not accessible" -ForegroundColor Red
            Write-Host "Please start the server first" -ForegroundColor Yellow
        }
    }
    
    "6" {
        Write-Host "`nExiting..." -ForegroundColor Cyan
        exit 0
    }
    
    default {
        Write-Host "`nInvalid choice!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "1. Review the configuration in .env file" -ForegroundColor White
Write-Host "2. Restart the Sentient server" -ForegroundColor White
Write-Host "3. Check server logs for any errors" -ForegroundColor White
Write-Host "4. Test voice features in the client" -ForegroundColor White
Write-Host ""
Write-Host "For detailed documentation, see: VOICE_SETUP_GUIDE.md" -ForegroundColor Yellow
Write-Host ""
