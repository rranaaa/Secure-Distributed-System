Set-Location "$PSScriptRoot\.."

$token = node .\api\generateToken.js
[System.IO.File]::WriteAllText((Join-Path $PWD "body.json"), '{"task":"rate-test"}')

for ($i=1; $i -le 30; $i++) {
    $code = curl.exe -s -o NUL -w "%{http_code}" -k -X POST "https://localhost/task" `
      -H "Content-Type: application/json" `
      -H "Authorization: Bearer $token" `
      --data-binary "@body.json"
    Write-Host "Request $i => HTTP $code"
}
