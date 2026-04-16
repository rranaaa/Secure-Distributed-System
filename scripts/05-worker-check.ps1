Set-Location "$PSScriptRoot\.."

Write-Host "Worker logs:"
docker logs worker --tail 50
