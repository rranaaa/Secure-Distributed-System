Set-Location "$PSScriptRoot\.."

$token = node .\api\generateToken.js
[System.IO.File]::WriteAllText((Join-Path $PWD "body.json"), '{"task":"normal-test"}')

Write-Host "Sending normal request..."
curl.exe -k -X POST "https://localhost/task" `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $token" `
  --data-binary "@body.json"

Write-Host ""
Write-Host "Latest states:"
docker exec secure_db psql -U postgres -d secure_system -P pager=off -c "SELECT * FROM request_states ORDER BY timestamp DESC LIMIT 10;"
