@echo off
echo ==================== NORMAL REQUEST ====================
powershell -ExecutionPolicy Bypass -File scripts\01-normal-request.ps1

echo.
echo ==================== LOAD BALANCING ====================
powershell -ExecutionPolicy Bypass -File scripts\02-load-balancing.ps1

echo.
echo ==================== UNAUTHORIZED ====================
powershell -ExecutionPolicy Bypass -File scripts\03-unauthorized.ps1

echo.
echo ==================== RATE LIMIT ====================
powershell -ExecutionPolicy Bypass -File scripts\04-rate-limit.ps1

echo.
echo ==================== WORKER CHECK ====================
powershell -ExecutionPolicy Bypass -File scripts\05-worker-check.ps1

echo.
echo ==================== DATABASE CHECK ====================
powershell -ExecutionPolicy Bypass -File scripts\06-db-check.ps1

pause
