Set-Location "$PSScriptRoot"

Write-Host "Switching Nginx to HTTP mode..."

@"
events {}

http {
    upstream backend {
        server api1:3000;
        server api2:3000;
        server api3:3000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host `$host;
            proxy_set_header X-Forwarded-For `$remote_addr;
        }
    }
}
"@ | Set-Content .\nginx\nginx.conf

Write-Host "Restarting containers..."
docker compose down
docker compose up --build -d

Write-Host "Waiting for RabbitMQ to be ready..."

$ready = $false
for ($i = 0; $i -lt 20; $i++) {
    $logs = docker logs secure_rabbitmq 2>&1

    if ($logs -match "Server startup complete") {
        $ready = $true
        break
    }

    Start-Sleep -Seconds 2
}

if (-not $ready) {
    Write-Host "RabbitMQ did not start in time!" -ForegroundColor Red
    exit 1
}

Write-Host "RabbitMQ is ready!"

# Restart APIs to ensure clean connection
docker restart api1 api2 api3

Start-Sleep -Seconds 3

$token = node .\api\generateToken.js
[System.IO.File]::WriteAllText((Join-Path $PWD "body.json"), '{"task":"mitm-http-test"}')

Write-Host ""
Write-Host "=== START WIRESHARK CAPTURE NOW ==="
Write-Host "Use filter: http"
Write-Host "You should see:"
Write-Host "- Authorization header"
Write-Host "- JWT token"
Write-Host "- JSON payload"
Write-Host ""

Pause

Write-Host "Sending HTTP request..."
curl.exe -X POST "http://localhost/task" `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $token" `
  --data-binary "@body.json"

Write-Host ""
Write-Host "HTTP MITM test sent. Check Wireshark for visible token and payload."
