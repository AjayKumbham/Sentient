$key = Read-Host "Enter your Gemini API Key"
$path = ".env.selfhost"

if (-not (Test-Path $path)) {
    Write-Host "Error: .env.selfhost not found!" -ForegroundColor Red
    exit
}

$content = Get-Content $path -Raw

# Update GEMINI_API_KEY
if ($content -match "GEMINI_API_KEY=") {
    $content = $content -replace "(?m)^GEMINI_API_KEY=.*", "GEMINI_API_KEY=$key"
} else {
    $content += "`nGEMINI_API_KEY=$key"
}

# Update LLM_PROVIDER
if ($content -match "LLM_PROVIDER=") {
    $content = $content -replace "(?m)^LLM_PROVIDER=.*", "LLM_PROVIDER=GEMINI"
} else {
    $content += "`nLLM_PROVIDER=GEMINI"
}

$content | Set-Content $path -NoNewline
Write-Host "Successfully updated .env.selfhost with Gemini settings!" -ForegroundColor Green
Write-Host "Please restart your server for changes to take effect." -ForegroundColor Yellow
