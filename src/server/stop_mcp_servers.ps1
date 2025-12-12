# Stop All MCP Servers
Write-Host "Stopping all MCP servers..." -ForegroundColor Yellow

# Find and stop all Python processes running MCP servers
$mcpProcesses = Get-Process python -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -like "*mcp_hub*"
}

if ($mcpProcesses) {
    $mcpProcesses | Stop-Process -Force
    Write-Host "Stopped $($mcpProcesses.Count) MCP server(s)" -ForegroundColor Green
} else {
    Write-Host "No MCP servers found running" -ForegroundColor Yellow
}

Write-Host "Done!" -ForegroundColor Green
