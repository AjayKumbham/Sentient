# Update .env file to use selfhost mode
$envFile = ".env"
$content = Get-Content $envFile

# Update ENVIRONMENT to selfhost
$content = $content -replace '^ENVIRONMENT=.*', 'ENVIRONMENT=selfhost'

# Check if SELF_HOST_AUTH_SECRET exists and is not empty
$hasSecret = $content | Where-Object { $_ -match '^SELF_HOST_AUTH_SECRET=.+' }

if (-not $hasSecret) {
    # Add or update the secret
    $content = $content -replace '^SELF_HOST_AUTH_SECRET=.*', ''
    $content = $content | Where-Object { $_ -ne '' -or $_ -notmatch '^SELF_HOST_AUTH_SECRET=' }
    $content += ""
    $content += "SELF_HOST_AUTH_SECRET=dev-secret-token-12345"
}

# Save the file
$content | Set-Content $envFile

Write-Host "✓ Updated .env file:"
Write-Host "  - ENVIRONMENT=selfhost"
Write-Host "  - SELF_HOST_AUTH_SECRET is set"
Write-Host ""
Write-Host "Please restart your server for changes to take effect."
