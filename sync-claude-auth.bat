@echo off
REM Windows Batch wrapper for PowerShell script
REM This makes it easier to run from Windows Explorer or CMD

echo Claude Auth Sync Tool
echo ====================
echo.

REM Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell not found!
    echo Please install PowerShell or use Git Bash with sync-claude-auth.sh
    pause
    exit /b 1
)

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0sync-claude-auth.ps1"

pause