# Start Core MCP Servers for Local Development
# This script starts the essential MCP servers needed for chat functionality

Write-Host "Starting Core MCP Servers..." -ForegroundColor Cyan
Write-Host ""

$venvPython = "venv\Scripts\python.exe"

# Check if venv exists
if (-not (Test-Path $venvPython)) {
    Write-Host "ERROR: Virtual environment not found at venv\" -ForegroundColor Red
    Write-Host "Please activate your virtual environment first" -ForegroundColor Yellow
    exit 1
}

Write-Host "Starting MCP servers in background..." -ForegroundColor Yellow
Write-Host ""

# Start Memory MCP Server (Port 8001)
Write-Host "1. Starting Memory MCP Server (http://localhost:8001)..." -ForegroundColor Green
$env:ENVIRONMENT = "selfhost"
Start-Process powershell -ArgumentList "-NoProfile", "-Command", "`$env:ENVIRONMENT='selfhost'; & '$venvPython' -m mcp_hub.memory.main" -WindowStyle Minimized

# Start History MCP Server (Port 9020)
Write-Host "2. Starting History MCP Server (http://localhost:9020)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoProfile", "-Command", "`$env:ENVIRONMENT='selfhost'; & '$venvPython' -m mcp_hub.history.main" -WindowStyle Minimized

# Start Tasks MCP Server (Port 9018)
Write-Host "3. Starting Tasks MCP Server (http://localhost:9018)..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoProfile", "-Command", "`$env:ENVIRONMENT='selfhost'; & '$venvPython' -m mcp_hub.tasks.main" -WindowStyle Minimized

Write-Host ""
Write-Host "Waiting for servers to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "===================================" -ForegroundColor Green
Write-Host "Core MCP Servers Started!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""
Write-Host "Running servers:" -ForegroundColor Cyan
Write-Host "- Memory MCP:  http://localhost:8001/sse" -ForegroundColor White
Write-Host "- History MCP: http://localhost:9020/sse" -ForegroundColor White
Write-Host "- Tasks MCP:   http://localhost:9018/sse" -ForegroundColor White
Write-Host ""
Write-Host "To stop all MCP servers, run: .\stop_mcp_servers.ps1" -ForegroundColor Yellow
Write-Host ""
