# Configure PostgreSQL for Local Development
Write-Host "Configuring PostgreSQL for local development..." -ForegroundColor Cyan

# Function to update .env file
function Update-EnvVariable {
    param(
        [string]$FilePath,
        [string]$Key,
        [string]$Value
    )
    
    $content = Get-Content $FilePath -Raw
    
    if ($content -match "(?m)^$Key=") {
        $content = $content -replace "(?m)^$Key=.*", "$Key=$Value"
        Write-Host "Updated $Key" -ForegroundColor Green
    } else {
        $content += "`n$Key=$Value"
        Write-Host "Added $Key" -ForegroundColor Green
    }
    
    $content | Set-Content $FilePath -NoNewline
}

# Update PostgreSQL connection to localhost
Update-EnvVariable ".env.selfhost" "POSTGRES_HOST" "localhost"

Write-Host ""
Write-Host "PostgreSQL configured for localhost" -ForegroundColor Green
Write-Host ""
Write-Host "Creating database if it doesn't exist..." -ForegroundColor Yellow

# Create the database using psql
$createDbCommand = @"
CREATE DATABASE sentient_memory_db;
"@

# Try to create database (will fail if exists, which is fine)
$env:PGPASSWORD = "sentient_postgres_password_123"
echo $createDbCommand | psql -h localhost -U sentient -d postgres 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Host "Database 'sentient_memory_db' created successfully" -ForegroundColor Green
} else {
    Write-Host "Database 'sentient_memory_db' may already exist (this is OK)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done! You can now start MCP servers with: .\start_mcp_servers.ps1" -ForegroundColor Cyan

