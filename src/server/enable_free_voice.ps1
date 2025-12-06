# Enable Free Voice Features (FASTER_WHISPER + ORPHEUS)
# This script configures Sentient to use completely free, local voice providers

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Enabling FREE Voice Features" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "ERROR: .env file not found!" -ForegroundColor Red
    Write-Host "Please create a .env file from .env.template first" -ForegroundColor Yellow
    exit 1
}

Write-Host "Configuring FREE voice providers..." -ForegroundColor Yellow
Write-Host "- STT: FASTER_WHISPER (Local, Free)" -ForegroundColor White
Write-Host "- TTS: ORPHEUS (Local, Free)" -ForegroundColor White
Write-Host ""

# Function to update .env file
function Update-EnvVariable {
    param(
        [string]$Key,
        [string]$Value
    )
    
    $envPath = ".env"
    $content = Get-Content $envPath -Raw
    
    if ($content -match "(?m)^$Key=") {
        $content = $content -replace "(?m)^$Key=.*", "$Key=$Value"
        Write-Host "✓ Updated $Key=$Value" -ForegroundColor Green
    } else {
        $content += "`n$Key=$Value"
        Write-Host "✓ Added $Key=$Value" -ForegroundColor Green
    }
    
    $content | Set-Content $envPath -NoNewline
}

# Configure STT Provider
Update-EnvVariable "STT_PROVIDER" "FASTER_WHISPER"

# Configure TTS Provider
Write-Host ""
Write-Host "TTS Configuration (The Mouth):" -ForegroundColor Yellow
Write-Host "1. Edge TTS (Recommended)" -ForegroundColor Green
Write-Host "   - Uses Microsoft Edge Online TTS. High quality, instant, requires internet."
Write-Host "2. Orpheus (Local AI)" -ForegroundColor White
Write-Host "   - Completely offline. Requires GPU for speed. Slow on CPU."

$ttsChoice = Read-Host "Choose Provider (1-2, default: 1)"
if ($ttsChoice -eq "2") {
    Update-EnvVariable "TTS_PROVIDER" "ORPHEUS"
} else {
    Update-EnvVariable "TTS_PROVIDER" "EDGE_TTS"
}

# Ask about GPU availability
Write-Host ""
Write-Host "GPU Configuration:" -ForegroundColor Yellow
Write-Host "Do you have an NVIDIA GPU with CUDA installed?" -ForegroundColor White
Write-Host "- If YES: Voice processing will be faster" -ForegroundColor Gray
Write-Host "- If NO: Will use CPU (slower but works)" -ForegroundColor Gray
$hasGPU = Read-Host "Do you have NVIDIA GPU with CUDA? (y/n)"

if ($hasGPU -eq "y" -or $hasGPU -eq "Y") {
    Write-Host ""
    Write-Host "Configuring for GPU (CUDA)..." -ForegroundColor Cyan
    Update-EnvVariable "FASTER_WHISPER_DEVICE" "cuda"
    Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float16"
    $gpuMode = $true
} else {
    Write-Host ""
    Write-Host "Configuring for CPU..." -ForegroundColor Cyan
    Update-EnvVariable "FASTER_WHISPER_DEVICE" "cpu"
    Update-EnvVariable "FASTER_WHISPER_COMPUTE_TYPE" "float32"
    $gpuMode = $false
}

# Configure model size
Write-Host ""
Write-Host "Choose Whisper Model Size:" -ForegroundColor Yellow
Write-Host "1. tiny   - Fastest, lowest quality (39M params)" -ForegroundColor White
Write-Host "2. base   - Fast, good quality (74M params) [RECOMMENDED]" -ForegroundColor Green
Write-Host "3. small  - Balanced (244M params)" -ForegroundColor White
Write-Host "4. medium - Slower, better quality (769M params)" -ForegroundColor White
Write-Host "5. large  - Slowest, best quality (1550M params)" -ForegroundColor White

$modelChoice = Read-Host "Enter choice (1-5, default: 2)"

$modelSize = switch ($modelChoice) {
    "1" { "tiny" }
    "3" { "small" }
    "4" { "medium" }
    "5" { "large" }
    default { "base" }
}

Update-EnvVariable "FASTER_WHISPER_MODEL_SIZE" $modelSize

# Configure Orpheus model path
Update-EnvVariable "ORPHEUS_MODEL_PATH" "src/server/main/voice/models/orpheus-3b-0.1-ft-q4_k_m.gguf"

# Configure LLM (The Brain)
Write-Host ""
Write-Host "LLM Configuration (The Brain):" -ForegroundColor Yellow
Write-Host "Sentient needs an LLM to understand and reply."
Write-Host "1. Gemini (Fast, Free Tier, Recommended)" -ForegroundColor Green
Write-Host "2. Ollama (Local, Completely Free, Requires RAM)" -ForegroundColor White
Write-Host "3. OpenAI (Paid API)" -ForegroundColor White

$llmChoice = Read-Host "Choose Provider (1-3, default: 1)"

if ($llmChoice -eq "2") {
    # Ollama
    Write-Host "Configuring for Ollama..." -ForegroundColor Cyan
    Update-EnvVariable "LLM_PROVIDER" "OPENAI" # Uses OpenAI-compatible endpoint
    Update-EnvVariable "OPENAI_API_BASE_URL" "http://localhost:11434/v1"
    Update-EnvVariable "OPENAI_API_KEY" "ollama"
    $ollamaModel = Read-Host "Enter Ollama model name (default: llama3.1)"
    if (-not $ollamaModel) { $ollamaModel = "llama3.1" }
    Update-EnvVariable "OPENAI_MODEL_NAME" $ollamaModel
    
} elseif ($llmChoice -eq "3") {
    # OpenAI
    Write-Host "Configuring for OpenAI..." -ForegroundColor Cyan
    Update-EnvVariable "LLM_PROVIDER" "OPENAI"
    Update-EnvVariable "OPENAI_API_BASE_URL" "https://api.openai.com/v1"
    $apiKey = Read-Host "Enter your OpenAI API Key"
    Update-EnvVariable "OPENAI_API_KEY" $apiKey
    Update-EnvVariable "OPENAI_MODEL_NAME" "gpt-4-turbo"

} else {
    # Gemini (Default)
    Write-Host "Configuring for Gemini..." -ForegroundColor Cyan
    Update-EnvVariable "LLM_PROVIDER" "GEMINI"
    $geminiKey = Read-Host "Enter your Gemini API Key"
    Update-EnvVariable "GEMINI_API_KEY" $geminiKey
}
Write-Host "==================================" -ForegroundColor Green
Write-Host "✓ Configuration Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "--------" -ForegroundColor Cyan
Write-Host "STT Provider: FASTER_WHISPER" -ForegroundColor White
Write-Host "TTS Provider: ORPHEUS" -ForegroundColor White
Write-Host "Model Size: $modelSize" -ForegroundColor White
Write-Host "Device: $(if ($gpuMode) { 'CUDA (GPU)' } else { 'CPU' })" -ForegroundColor White
Write-Host ""

# Check if Orpheus model exists
$orpheusPath = "main\voice\models\orpheus-3b-0.1-ft-q4_k_m.gguf"
if (-not (Test-Path $orpheusPath)) {
    Write-Host "⚠ IMPORTANT: Orpheus TTS model not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You need to download the Orpheus model:" -ForegroundColor Yellow
    Write-Host "1. Create directory: src/server/main/voice/models/" -ForegroundColor White
    Write-Host "2. Download model from: https://huggingface.co/ggerganov/orpheus" -ForegroundColor White
    Write-Host "   File: orpheus-3b-0.1-ft-q4_k_m.gguf" -ForegroundColor White
    Write-Host "3. Place the file in: src/server/main/voice/models/" -ForegroundColor White
    Write-Host ""
    
    $downloadNow = Read-Host "Would you like instructions to download it now? (y/n)"
    if ($downloadNow -eq "y" -or $downloadNow -eq "Y") {
        Write-Host ""
        Write-Host "Download Instructions:" -ForegroundColor Cyan
        Write-Host "---------------------" -ForegroundColor Cyan
        Write-Host "1. Create the models directory:" -ForegroundColor White
        Write-Host "   mkdir -p main\voice\models" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Download using one of these methods:" -ForegroundColor White
        Write-Host ""
        Write-Host "   Method A - Using wget (if installed):" -ForegroundColor Yellow
        Write-Host "   cd main\voice\models" -ForegroundColor Gray
        Write-Host "   wget https://huggingface.co/ggerganov/orpheus/resolve/main/orpheus-3b-0.1-ft-q4_k_m.gguf" -ForegroundColor Gray
        Write-Host ""
        Write-Host "   Method B - Manual download:" -ForegroundColor Yellow
        Write-Host "   1. Visit: https://huggingface.co/ggerganov/orpheus/tree/main" -ForegroundColor Gray
        Write-Host "   2. Download: orpheus-3b-0.1-ft-q4_k_m.gguf (~2GB)" -ForegroundColor Gray
        Write-Host "   3. Move to: src/server/main/voice/models/" -ForegroundColor Gray
        Write-Host ""
    }
} else {
    Write-Host "✓ Orpheus model found!" -ForegroundColor Green
}

# Check Python dependencies
Write-Host ""
Write-Host "Checking Python dependencies..." -ForegroundColor Cyan

$venvPath = "venv\Scripts\python.exe"
if (Test-Path $venvPath) {
    Write-Host "✓ Virtual environment found" -ForegroundColor Green
    
    # Check if faster-whisper is installed
    $checkFasterWhisper = & $venvPath -c "import faster_whisper" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ faster-whisper is installed" -ForegroundColor Green
    } else {
        Write-Host "⚠ faster-whisper not found" -ForegroundColor Yellow
        Write-Host "Installing faster-whisper..." -ForegroundColor Cyan
        & "venv\Scripts\pip.exe" install faster-whisper
    }
} else {
    Write-Host "⚠ Virtual environment not found at 'venv'" -ForegroundColor Yellow
    Write-Host "Make sure to install dependencies:" -ForegroundColor Yellow
    Write-Host "  pip install faster-whisper" -ForegroundColor Gray
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "1. Download Orpheus model (if not done)" -ForegroundColor White
Write-Host "2. Restart the Sentient server" -ForegroundColor White
Write-Host "3. Check server health: http://localhost:8080/health" -ForegroundColor White
Write-Host "4. Test voice features in the client" -ForegroundColor White
Write-Host ""
Write-Host "For troubleshooting, see: VOICE_SETUP_GUIDE.md" -ForegroundColor Yellow
Write-Host ""
