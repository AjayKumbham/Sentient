$content = Get-Content .env
$content = $content -replace '^ENVIRONMENT=.*', 'ENVIRONMENT=selfhost'
$hasSecret = $content | Where-Object { $_ -match '^SELF_HOST_AUTH_SECRET=.+' }
if (-not $hasSecret) {
    $content += "SELF_HOST_AUTH_SECRET=dev-secret-token-12345"
}
$content | Set-Content .env
Write-Host "Done! Updated .env file to use selfhost mode."
