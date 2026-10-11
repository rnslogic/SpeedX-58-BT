@echo off
title RNSRetail Bluetooth Printer Auto-Setup
cd /d "%~dp0"
echo ===================================================
echo   RNSRetail Bluetooth Printer Auto-Setup Launcher
echo ===================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-BTPrinter.ps1"
if %errorlevel% neq 0 (
    echo.
    echo Script encountered an issue or required admin permissions.
)
pause
