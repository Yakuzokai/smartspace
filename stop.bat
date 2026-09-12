@echo off
title SmartSpace — Stop All Services

echo ================================================================
echo            SMARTSPACE — STOP ALL SERVICES
echo ================================================================
echo.
echo Terminating processes on SmartSpace ports (8000, 8001, 5173)...
echo.

for %%P in (8000 8001 5173) do (
    set found=0
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":%%P" ^| findstr "LISTENING"') do (
        echo [Port %%P] Terminating PID %%a...
        taskkill /F /PID %%a >nul 2>&1
        set found=1
    )
)

echo.
echo ----------------------------------------------------------------
echo All SmartSpace background processes have been stopped.
echo Ports 8000, 8001, and 5173 are now closed and freed!
echo ----------------------------------------------------------------
echo.
pause
