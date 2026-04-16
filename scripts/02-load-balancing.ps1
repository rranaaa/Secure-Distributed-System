Set-Location "$PSScriptRoot\.."

$token = node .\api\generateToken.js
[System.IO.File]::WriteAllText((Join-Path $PWD "body.json"), '{"task":"lb-test"}')

for ($i=1; $i -le 10; $i++) {
    Write-Host "Request $i"
    curl.exe -s -k -X POST "https://localhost/task" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $token" `
      --data-binary "@body.json"
    Write-Host ""
    Start-Sleep -Seconds 1
}
