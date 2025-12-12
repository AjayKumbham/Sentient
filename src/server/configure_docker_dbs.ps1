# Update PostgreSQL settings for Docker databases
Write-Host "Updating .env.selfhost for Docker databases..." -ForegroundColor Cyan

function Update-EnvVariable {
    param(
        [string]$FilePath,
        [string]$Key,
        [string]$Value
    )
    
    $content = Get-Content $FilePath -Raw
    
    if ($content -match "(?m)^$Key=") {
        $content = $content -replace "(?m)^$Key=.*", "$Key=$Value"
        Write-Host "  Updated $Key" -ForegroundColor Green
    } else {
        $content += "`n$Key=$Value"
        Write-Host "  Added $Key" -ForegroundColor Green
    }
    
    $content | Set-Content $FilePath -NoNewline
}

# Update PostgreSQL settings for Docker
Update-EnvVariable ".env.selfhost" "POSTGRES_HOST" "localhost"
Update-EnvVariable ".env.selfhost" "POSTGRES_PORT" "5432"
Update-EnvVariable ".env.selfhost" "POSTGRES_USER" "sentient"
Update-EnvVariable ".env.selfhost" "POSTGRES_PASSWORD" "sentient_dev_password"
Update-EnvVariable ".env.selfhost" "POSTGRES_DB" "mcp_memory"

Write-Host ""
Write-Host "Configuration updated for Docker databases!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start Docker Desktop" -ForegroundColor White
Write-Host "2. Run: docker-compose -f docker-compose.dev-dbs.yml up -d" -ForegroundColor White
Write-Host "3. Run: .\start_mcp_servers.ps1" -ForegroundColor White
