Set-Location "$PSScriptRoot"

Write-Host "Switching Nginx to HTTPS mode..."

@"
events {}

http {
    limit_req_zone `$binary_remote_addr zone=api_limit:10m rate=5r/s;

    upstream backend {
        server api1:3000;
        server api2:3000;
        server api3:3000;
    }

    server {
        listen 80;
        server_name localhost;
        return 301 https://`$host`$request_uri;
    }

    server {
        listen 443 ssl;
        server_name localhost;

        ssl_certificate /etc/nginx/certs/server.crt;
        ssl_certificate_key /etc/nginx/certs/server.key;

        location / {
            limit_req zone=api_limit burst=10 nodelay;

            proxy_pass http://backend;
            proxy_set_header Host `$host;
            proxy_set_header X-Forwarded-For `$remote_addr;
            proxy_set_header X-Forwarded-Proto https;
        }
    }
}
"@ | Set-Content .\nginx\nginx.conf

Write-Host "Restarting containers..."
docker compose down
docker compose up --build -d

Start-Sleep -Seconds 5

$token = node .\api\generateToken.js
[System.IO.File]::WriteAllText((Join-Path $PWD "body.json"), '{"task":"mitm-https-test"}')

Write-Host ""
Write-Host "=== START WIRESHARK CAPTURE NOW ==="
Write-Host "Use filter: tls OR tcp.port == 443"
Write-Host "You should see:"
Write-Host "- TLS encrypted packets"
Write-Host "- No readable JWT token"
Write-Host "- No readable JSON payload"
Write-Host ""

Pause

Write-Host "Sending HTTPS request..."
curl.exe -k -X POST "https://localhost/task" `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $token" `
  --data-binary "@body.json"

Write-Host ""
Write-Host "HTTPS MITM test sent. Check Wireshark for encrypted traffic."
