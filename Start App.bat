@echo off
start "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0serve.ps1"
timeout /t 2 /nobreak >nul
start "" http://localhost:8234/