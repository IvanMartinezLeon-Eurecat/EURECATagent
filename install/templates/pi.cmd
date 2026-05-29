@echo off
setlocal enabledelayedexpansion

set "PI_REAL_BIN=__PI_REAL_BIN__"
set "PROJECT_ROOT="

where git >nul 2>nul
if %errorlevel% equ 0 (
    for /f "usebackq delims=" %%i in (`git rev-parse --show-toplevel 2^>nul`) do (
        set "PROJECT_ROOT=%%i"
        goto :project_root_resolved
    )
)

:project_root_resolved
if not defined PROJECT_ROOT set "PROJECT_ROOT=%CD%"
set "XDG_DATA_HOME=%PROJECT_ROOT%\.eurecat-data"

call "%PI_REAL_BIN%" %*
set "EXIT_CODE=%ERRORLEVEL%"
endlocal & exit /b %EXIT_CODE%
