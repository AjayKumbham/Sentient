# Update client .env.local file for selfhost mode
$envFile = ".env.local"

# Create content line by line
$lines = @(
    "# Environment: selfhost",
    "NEXT_PUBLIC_ENVIRONMENT=selfhost",
    "",
    "# Backend server URL (accessible from browser)",
    "NEXT_PUBLIC_APP_SERVER_URL=http://localhost:8000",
    "",
    "# Internal server URL (for server-side API calls)",
    "INTERNAL_APP_SERVER_URL=http://localhost:8000",
    "",
    "# Client base URL",
    "APP_BASE_URL=http://localhost:3000",
    "NEXT_PUBLIC_APP_BASE_URL=http://localhost:3000",
    "",
    "# Self-host auth token (must match server SELF_HOST_AUTH_SECRET)",
    "SELF_HOST_AUTH_TOKEN=dev-secret-token-12345",
    "",
    "# MongoDB (for server actions)",
    "MONGO_URI=mongodb://localhost:27017/",
    "MONGO_DB_NAME=sentient_selfhost_db",
    "",
    "# Auth0 (not used in selfhost mode)",
    "AUTH0_SECRET=dummy",
    "AUTH0_ISSUER_BASE_URL=dummy",
    "AUTH0_CLIENT_ID=dummy",
    "AUTH0_CLIENT_SECRET=dummy",
    "AUTH0_AUDIENCE=dummy",
    "AUTH0_SCOPE=dummy"
)

$lines | Set-Content $envFile
Write-Host "Updated .env.local for selfhost mode"
