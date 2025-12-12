@echo off
echo Starting Memory MCP Server with environment variables...

set ENVIRONMENT=selfhost
set POSTGRES_USER=sentient
set POSTGRES_PASSWORD=sentient_dev_password
set POSTGRES_HOST=localhost
set POSTGRES_PORT=5432
set POSTGRES_DB=mcp_memory

venv\Scripts\python.exe -m mcp_hub.memory.main
