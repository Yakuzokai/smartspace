@echo off
title SmartSpace — Open Windows Firewall Ports
echo ================================================================
echo       SMARTSPACE — WINDOWS FIREWALL INBOUND PORT CONFIG
echo ================================================================
echo.
echo This utility configures Windows Defender Firewall to allow inbound
echo connections for local LAN testing (e.g. mobile/tablet devices) on:
echo   - Port 5173 (Vite Frontend)
echo   - Port 8000 (Laravel API Gateway)
echo   - Port 8001 (FastAPI AI Microservice)
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ================================================================
    echo [!] ADMINISTRATOR PRIVILEGES REQUIRED
    echo Please right-click this batch file and select "Run as administrator".
    echo ================================================================
    echo.
    pause
    exit /b 1
)

echo Adding inbound firewall rule for Port 5173 (Frontend)...
netsh advfirewall firewall delete rule name="SmartSpace Frontend (5173)" >nul 2>&1
netsh advfirewall firewall add rule name="SmartSpace Frontend (5173)" dir=in action=allow protocol=TCP localport=5173 >nul

echo Adding inbound firewall rule for Port 8000 (Laravel Gateway)...
netsh advfirewall firewall delete rule name="SmartSpace Backend (8000)" >nul 2>&1
netsh advfirewall firewall add rule name="SmartSpace Backend (8000)" dir=in action=allow protocol=TCP localport=8000 >nul

echo Adding inbound firewall rule for Port 8001 (FastAPI AI Microservice)...
netsh advfirewall firewall delete rule name="SmartSpace AI Service (8001)" >nul 2>&1
netsh advfirewall firewall add rule name="SmartSpace AI Service (8001)" dir=in action=allow protocol=TCP localport=8001 >nul

echo.
echo ================================================================
echo [SUCCESS] Inbound firewall ports (5173, 8000, 8001) are now open!
echo ================================================================
echo.
pause
