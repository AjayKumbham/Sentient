# Update MongoDB URI in .env.selfhost file
$envSelfhostFile = ".env.selfhost"

if (Test-Path $envSelfhostFile) {
    $content = Get-Content $envSelfhostFile
    $content = $content -replace '^MONGO_URI=.*', 'MONGO_URI=mongodb://localhost:27017/'
    $content | Set-Content $envSelfhostFile
    Write-Host "Updated MONGO_URI in .env.selfhost to use localhost"
} else {
    Write-Host "Warning: .env.selfhost file not found"
}
