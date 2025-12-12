# Start Memory MCP Server in visible mode for debugging
Write-Host "Starting Memory MCP Server (visible for debugging)..." -ForegroundColor Cyan
Write-Host ""

$env:ENVIRONMENT = "selfhost"
& venv\Scripts\python.exe -m mcp_hub.memory.main
