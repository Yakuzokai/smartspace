@echo off
setlocal enabledelayedexpansion
title SmartSpace — Service Launcher

echo ================================================================
echo            SMARTSPACE — ALL-IN-ONE SERVICE LAUNCHER
echo ================================================================
echo.
echo Architecture:
echo   * Frontend (Vue 3 + Three.js):  http://127.0.0.1:5173
echo   * API Gateway (Laravel 11):     http://127.0.0.1:8000
echo   * AI Microservice (FastAPI):    http://127.0.0.1:8001 (Internal)
echo.
echo ----------------------------------------------------------------
echo [1/3] Starting Laravel 11 Gateway on Port 8000...
start "SmartSpace Backend (:8000)" cmd /k "cd /d "%~dp0backend" && title SmartSpace Backend :8000 && php artisan serve --port=8000"

echo [2/3] Starting FastAPI AI Microservice on Port 8001...
start "SmartSpace AI Service (:8001)" cmd /k "cd /d "%~dp0ai-service" && title SmartSpace AI Microservice :8001 && .\venv\Scripts\python.exe -m uvicorn app.main:app --port 8001 --host 127.0.0.1 --reload"

echo [3/3] Starting Vue 3 + Vite Frontend on Port 5173...
start "SmartSpace Frontend (:5173)" cmd /k "cd /d "%~dp0frontend" && title SmartSpace Frontend :5173 && npm run dev"

echo ----------------------------------------------------------------
echo.
echo All 3 service processes have been launched in separate terminals!
echo Waiting for servers to initialize...
timeout /t 3 /nobreak >nul

echo Opening SmartSpace in default browser...
start http://127.0.0.1:5173/

echo.
echo ================================================================
echo   SmartSpace is running!
echo   * Web App:    http://127.0.0.1:5173
echo   * Health API: http://127.0.0.1:8000/api/v1/system/health
echo   * To stop all servers, simply run: stop.bat
echo ================================================================
echo.
echo Press any key to close this launcher window (servers will keep running).
pause >nul
