@echo off
REM Instalador de EURECATagent para Windows CMD

setlocal enabledelayedexpansion

echo.
echo === EURECATagent Installer (Windows CMD) ===
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Node.js no está instalado.
    echo.
    echo Instala Node.js v18.0.0 o superior desde https://nodejs.org/
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo [OK] Node.js %NODE_VERSION% detectado

where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: npm no está instalado.
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo [OK] npm %NPM_VERSION% detectado
echo.

set "SCRIPT_DIR=%~dp0"
set "CONFIG_SOURCE_DIR=%SCRIPT_DIR%..\config\agent"
set "TEMPLATE_DIR=%SCRIPT_DIR%templates"
set "AGENT_CONFIG_DIR=%USERPROFILE%\.pi\agent"
set "AGENT_BIN_DIR=%AGENT_CONFIG_DIR%\bin"
set "WRAPPER_PATH=%AGENT_BIN_DIR%\pi.cmd"

echo Instalando EURECATagent...
echo.
call npm install -g --loglevel=error --ignore-scripts @earendil-works/pi-coding-agent 
if errorlevel 1 (
    echo [FAIL] EURECATagent installation failed
    pause
    exit /b 1
)

echo Copiando la configuración de EURECATagent a %AGENT_CONFIG_DIR%...
if not exist "%CONFIG_SOURCE_DIR%" (
    echo [FAIL] No se encontró la carpeta de configuración en %CONFIG_SOURCE_DIR%
    pause
    exit /b 1
)

if not exist "%AGENT_CONFIG_DIR%" mkdir "%AGENT_CONFIG_DIR%"
xcopy "%CONFIG_SOURCE_DIR%\*" "%AGENT_CONFIG_DIR%\" /E /I /Y >nul
if %errorlevel% geq 4 (
    echo [FAIL] Could not copy configuration files
    pause
    exit /b 1
)
echo [OK] Configuración copiada en %AGENT_CONFIG_DIR%

echo Instalando y activando paquetes...
set "PI_CMD="
where pi >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('where pi') do (
        if /I not "%%~fi"=="%WRAPPER_PATH%" (
            set "PI_CMD=%%~fi"
            goto :pi_command_resolved
        )
    )
)
for /f "tokens=*" %%i in ('npm prefix -g') do set "NPM_GLOBAL_PREFIX=%%i"
if not defined PI_CMD if exist "%NPM_GLOBAL_PREFIX%\pi.cmd" set "PI_CMD=%NPM_GLOBAL_PREFIX%\pi.cmd"

:pi_command_resolved
if not defined PI_CMD (
    echo [FAIL] No se pudo localizar el ejecutable de pi después de la instalación
    pause
    exit /b 1
)

echo [INFO] Instalando Coding Agent...
call "%PI_CMD%" install npm:pi-subagents >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Error al instalar Coding Agent (pi-subagents)
    pause
    exit /b 1
) else (
    echo [OK] Paquete Coding Agent instalado
)
echo [INFO] Instalando MCP Adapter...
call "%PI_CMD%" install npm:pi-mcp-adapter >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Error al instalar MCP Adapter (pi-mcp-adapter)
    pause
    exit /b 1
) else (
    echo [OK] Paquete MCP Adapter instalado
)
echo [INFO] Instalando Code Intelligence...
call "%PI_CMD%" install npm:@catdaemon/pi-code-intelligence >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Error al instalar Code Intelligence (@catdaemon/pi-code-intelligence)
    pause
    exit /b 1
) else (
    echo [OK] Paquete Code Intelligence instalado
)
echo [INFO] Instalando Lens...
call "%PI_CMD%" install npm:pi-lens >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Error al instalar Lens (pi-lens)
    pause
    exit /b 1
) else (
    echo [OK] Paquete Lens instalado
)
echo [INFO] Instalando Web Access...
call "%PI_CMD%" install npm:pi-web-access >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Error al instalar Web Access (pi-web-access)
    pause
    exit /b 1
) else (
    echo [OK] Paquete Web Access instalado
)
echo [INFO] Instalando Ask User...
call "%PI_CMD%" install npm:pi-ask-user >nul 2>nul
if errorlevel 1 (
    echo [FAIL] Error al instalar Ask User (pi-ask-user)
    pause
    exit /b 1
) else (
    echo [OK] Paquete Ask User instalado
)

if not exist "%TEMPLATE_DIR%\pi.cmd" (
    echo [FAIL] No se encontró la plantilla del wrapper en %TEMPLATE_DIR%\pi.cmd
    pause
    exit /b 1
)

if not exist "%AGENT_BIN_DIR%" mkdir "%AGENT_BIN_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$template = Get-Content -Path '%TEMPLATE_DIR%\pi.cmd' -Raw; $content = $template.Replace('__PI_REAL_BIN__', '%PI_CMD%'); Set-Content -Path '%WRAPPER_PATH%' -Value $content -Encoding ASCII"
if errorlevel 1 exit /b 1

REM Crear comando eurecatagent
if exist "%TEMPLATE_DIR%\eurecatagent.cmd" (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$template = Get-Content -Path '%TEMPLATE_DIR%\eurecatagent.cmd' -Raw; $content = $template.Replace('__PI_REAL_BIN__', '%PI_CMD%'); Set-Content -Path '%AGENT_BIN_DIR%\eurecatagent.cmd' -Value $content -Encoding ASCII"
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "$dir = '%AGENT_BIN_DIR%'; $userPath = [Environment]::GetEnvironmentVariable('Path', 'User'); $parts = @(); if ($userPath) { $parts = $userPath.Split(';') | Where-Object { $_ -and $_.Trim() -ne '' } }; if (-not ($parts -contains $dir)) { [Environment]::SetEnvironmentVariable('Path', (($dir + ';' + ($parts -join ';')).Trim(';')), 'User') }"
set "PATH=%AGENT_BIN_DIR%;%PATH%"

echo [OK] EURECATagent installed at %WRAPPER_PATH%

echo.

where pi >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] EURECATagent is available in your PATH
) else (
    echo [WARN] Restart your terminal to refresh PATH.
)

echo.
echo Next steps:
echo   1. Start: cd /your/project  ^&^&  eurecatagent
echo   2. Auth:  /login  or  set ANTHROPIC_API_KEY=your-key
echo   3. Repo:  /code-intelligence-doctor  ^&^&  /enable-code-intelligence
echo   4. Docs:  https://pi.dev/docs/latest
echo.
echo Config: %AGENT_CONFIG_DIR%
echo.

pause
