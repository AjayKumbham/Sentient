# Update MongoDB URI to point to localhost
$content = Get-Content .env
$content = $content -replace '^MONGO_URI=.*', 'MONGO_URI=mongodb://localhost:27017/'
$content | Set-Content .env
Write-Host "Updated MONGO_URI to use localhost MongoDB"
