@echo off
REM Instalador de EURECATagent para Windows CMD

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════╗
echo ║  EURECATagent                          ║
echo ║  Instalador para Windows CMD           ║
echo ╚════════════════════════════════════════╝
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

echo Instalando Pi coding agent...
echo.
call npm install -g --ignore-scripts @earendil-works/pi-coding-agent
if errorlevel 1 (
    echo [FAIL] Pi installation failed
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

echo Instalando y activando paquetes de Pi...
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

call "%PI_CMD%" install npm:pi-subagents
if errorlevel 1 exit /b 1
call "%PI_CMD%" install npm:pi-mcp-adapter
if errorlevel 1 exit /b 1
call "%PI_CMD%" install npm:@catdaemon/pi-code-intelligence
if errorlevel 1 exit /b 1

if not exist "%TEMPLATE_DIR%\pi.cmd" (
    echo [FAIL] No se encontró la plantilla del wrapper en %TEMPLATE_DIR%\pi.cmd
    pause
    exit /b 1
)

if not exist "%AGENT_BIN_DIR%" mkdir "%AGENT_BIN_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$template = Get-Content -Path '%TEMPLATE_DIR%\pi.cmd' -Raw; $content = $template.Replace('__PI_REAL_BIN__', '%PI_CMD%'); Set-Content -Path '%WRAPPER_PATH%' -Value $content -Encoding ASCII"
if errorlevel 1 exit /b 1
powershell -NoProfile -ExecutionPolicy Bypass -Command "$dir = '%AGENT_BIN_DIR%'; $userPath = [Environment]::GetEnvironmentVariable('Path', 'User'); $parts = @(); if ($userPath) { $parts = $userPath.Split(';') | Where-Object { $_ -and $_.Trim() -ne '' } }; if (-not ($parts -contains $dir)) { [Environment]::SetEnvironmentVariable('Path', (($dir + ';' + ($parts -join ';')).Trim(';')), 'User') }"
set "PATH=%AGENT_BIN_DIR%;%PATH%"

echo [OK] pi-subagents instalado y activo
echo [OK] pi-mcp-adapter instalado y activo
echo [OK] @catdaemon/pi-code-intelligence instalado y activo
echo [OK] Launcher de Pi orientado a proyecto instalado en %WRAPPER_PATH%

echo.
echo ╔════════════════════════════════════════╗
echo ║  EURECATagent instalado correctamente  ║
echo ╚════════════════════════════════════════╝
echo.

where pi >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Pi ya está disponible en tu PATH
) else (
    echo [WARN] El comando Pi no está disponible todavía en tu PATH.
    echo        Cierra y vuelve a abrir Command Prompt o PowerShell para refrescar tu PATH.
)

echo.
echo Próximos pasos:
echo 1. Validación opcional: verify.bat
echo 2. Ve a tu directorio de proyecto: cd C:\path\to\your\project
echo 3. Inicia Pi: pi
echo 4. Pi almacenará la memoria de Code Intelligence en ^<project^>\.eurecat-data
echo 5. Autentícate con: /login
echo 6. O configura tu API key: set ANTHROPIC_API_KEY=your-key
echo 7. Comprueba el router: /router-status
echo 8. Prepara la inteligencia local: /code-intelligence-doctor
echo 9. Actívala en el repo: /enable-code-intelligence
echo 10. Comprueba MCP: /mcp
echo 11. Para descubrimiento estructural usa: code_intelligence_search
echo.
echo Configuración instalada: %AGENT_CONFIG_DIR%
echo Documentación: https://pi.dev/docs/latest
echo pi-subagents: https://pi.dev/packages/pi-subagents
echo pi-mcp-adapter: https://pi.dev/packages/pi-mcp-adapter
echo pi-code-intelligence: https://pi.dev/packages/@catdaemon/pi-code-intelligence
echo.

pause
