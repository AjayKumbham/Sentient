# Update Frontend to Use Docker Backend (Port 5000)

Write-Host "Updating frontend configuration to use Docker backend..." -ForegroundColor Cyan

$envFile = ".env.local"

if (Test-Path $envFile) {
    $content = Get-Content $envFile -Raw
    
    # Update port 8000 to 5000
    $content = $content -replace 'localhost:8000', 'localhost:5000'
    
    $content | Set-Content $envFile -NoNewline
    
    Write-Host "✓ Updated $envFile" -ForegroundColor Green
    Write-Host ""
    Write-Host "Backend URLs now point to:" -ForegroundColor Yellow
    Write-Host "  http://localhost:5000" -ForegroundColor White
    Write-Host ""
    Write-Host "Restart your frontend server (npm run dev) for changes to take effect" -ForegroundColor Cyan
} else {
    Write-Host "✗ $envFile not found" -ForegroundColor Red
}
