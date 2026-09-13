@echo off
title SmartSpace - Synchronize 3D Models
color 0b

echo =======================================================================
echo          SMARTSPACE 3D FURNITURE MODEL SYNCHRONIZER
echo =======================================================================
echo Scanning backend/storage/app/public/furniture/models for GLB files...
echo.

cd /d "%~dp0backend"
php artisan furniture:sync-models

echo.
echo =======================================================================
echo Synchronization complete! You can close this window.
echo =======================================================================
pause
