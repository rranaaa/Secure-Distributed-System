Set-Location "$PSScriptRoot\.."

Write-Host "Recent audit logs:"
docker exec secure_db psql -U postgres -d secure_system -P pager=off -c "SELECT * FROM audit_logs ORDER BY timestamp DESC LIMIT 20;"

Write-Host ""
Write-Host "Recent request states:"
docker exec secure_db psql -U postgres -d secure_system -P pager=off -c "SELECT * FROM request_states ORDER BY timestamp DESC LIMIT 20;"
