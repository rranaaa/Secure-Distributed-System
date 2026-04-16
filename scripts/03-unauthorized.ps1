Set-Location "$PSScriptRoot\.."

[System.IO.File]::WriteAllText((Join-Path $PWD "body.json"), '{"task":"unauthorized-test"}')

Write-Host "Sending unauthorized request..."
curl.exe -k -X POST "https://localhost/task" `
  -H "Content-Type: application/json" `
  --data-binary "@body.json"
