# Change STT provider to FASTER_WHISPER (no API key needed)
$content = Get-Content .env
$content = $content -replace '^STT_PROVIDER=.*', 'STT_PROVIDER=FASTER_WHISPER'
$content | Set-Content .env
Write-Host "Updated STT_PROVIDER to FASTER_WHISPER"
