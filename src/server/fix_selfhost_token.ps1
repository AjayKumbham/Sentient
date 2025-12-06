$envSelfhostFile = ".env.selfhost"

if (Test-Path $envSelfhostFile) {
    $content = Get-Content $envSelfhostFile
    $hasSecret = $content | Where-Object { $_ -match '^SELF_HOST_AUTH_SECRET=' }
    
    if ($hasSecret) {
        $content = $content -replace '^SELF_HOST_AUTH_SECRET=.*', 'SELF_HOST_AUTH_SECRET=dev-secret-token-12345'
    } else {
        $content += ""
        $content += "SELF_HOST_AUTH_SECRET=dev-secret-token-12345"
    }
    
    $content | Set-Content $envSelfhostFile
    Write-Host "Updated .env.selfhost with auth secret"
} else {
    Write-Host "File not found"
}
