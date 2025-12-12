# Update both .env and .env.selfhost for Docker databases
Write-Host "Updating environment files for Docker databases..." -ForegroundColor Cyan

function Update-EnvVariable {
    param(
        [string]$FilePath,
        [string]$Key,
        [string]$Value
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "  Skipping $FilePath (not found)" -ForegroundColor Yellow
        return
    }
    
    $content = Get-Content $FilePath -Raw
    
    if ($content -match "(?m)^$Key=") {
        $content = $content -replace "(?m)^$Key=.*", "$Key=$Value"
        Write-Host "  Updated $Key in $FilePath" -ForegroundColor Green
    } else {
        $content += "`n$Key=$Value"
        Write-Host "  Added $Key to $FilePath" -ForegroundColor Green
    }
    
    $content | Set-Content $FilePath -NoNewline
}

# Update .env
Write-Host "`nUpdating .env..." -ForegroundColor Yellow
Update-EnvVariable ".env" "POSTGRES_HOST" "localhost"
Update-EnvVariable ".env" "POSTGRES_PORT" "5432"
Update-EnvVariable ".env" "POSTGRES_USER" "sentient"
Update-EnvVariable ".env" "POSTGRES_PASSWORD" "sentient_dev_password"
Update-EnvVariable ".env" "POSTGRES_DB" "mcp_memory"

# Update .env.selfhost
Write-Host "`nUpdating .env.selfhost..." -ForegroundColor Yellow
Update-EnvVariable ".env.selfhost" "POSTGRES_HOST" "localhost"
Update-EnvVariable ".env.selfhost" "POSTGRES_PORT" "5432"
Update-EnvVariable ".env.selfhost" "POSTGRES_USER" "sentient"
Update-EnvVariable ".env.selfhost" "POSTGRES_PASSWORD" "sentient_dev_password"
Update-EnvVariable ".env.selfhost" "POSTGRES_DB" "mcp_memory"

Write-Host ""
Write-Host "✓ Both environment files updated!" -ForegroundColor Green
Write-Host ""
Write-Host "Now run: start_mcp_servers.ps1" -ForegroundColor Cyan
