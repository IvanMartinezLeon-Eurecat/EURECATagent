@echo off
REM EURECAT agent Uninstaller for Windows (Batch)

setlocal enabledelayedexpansion

echo.
echo === EURECATagent Uninstaller (Windows CMD) ===
echo.

set "AGENT_CONFIG_DIR=%USERPROFILE%\.pi\agent"

echo This will uninstall EURECATagent and remove its configuration from %AGENT_CONFIG_DIR%.
set /p confirmation="Are you sure? (y/n): "

if /i not "%confirmation%"=="y" (
    echo Uninstallation cancelled.
    pause
    exit /b 0
)

echo.
echo Removing EURECAT packages...
echo.

set "PI_CMD="
where pi >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('where pi') do (
        set "PI_CMD=%%i"
        goto :pi_remove_ready
    )
)
for /f "tokens=*" %%i in ('npm prefix -g') do set "NPM_GLOBAL_PREFIX=%%i"
if exist "%NPM_GLOBAL_PREFIX%\pi.cmd" set "PI_CMD=%NPM_GLOBAL_PREFIX%\pi.cmd"

:pi_remove_ready
if defined PI_CMD (
    echo [INFO] Desinstalando Ask User...
    call "%PI_CMD%" remove npm:pi-ask-user >nul 2>nul
    if errorlevel 1 (
        echo [WARN] Ask User no estaba instalado
    ) else (
        echo [OK] Ask User desinstalado
    )
    echo [INFO] Desinstalando Web Access...
    call "%PI_CMD%" remove npm:pi-web-access >nul 2>nul
    if errorlevel 1 (
        echo [WARN] Web Access no estaba instalado
    ) else (
        echo [OK] Web Access desinstalado
    )
    echo [INFO] Desinstalando Code Intelligence...
    call "%PI_CMD%" remove npm:@catdaemon/pi-code-intelligence >nul 2>nul
    if errorlevel 1 (
        echo [WARN] Code Intelligence no estaba instalado
    ) else (
        echo [OK] Code Intelligence desinstalado
    )
    echo [INFO] Desinstalando MCP Adapter...
    call "%PI_CMD%" remove npm:pi-mcp-adapter >nul 2>nul
    if errorlevel 1 (
        echo [WARN] MCP Adapter no estaba instalado
    ) else (
        echo [OK] MCP Adapter desinstalado
    )
    echo [INFO] Desinstalando Coding Agent...
    call "%PI_CMD%" remove npm:pi-subagents >nul 2>nul
    if errorlevel 1 (
        echo [WARN] Coding Agent no estaba instalado
    ) else (
        echo [OK] Coding Agent desinstalado
    )
)

echo.
echo Uninstalling EURECATagent...
echo.

call npm uninstall -g @earendil-works/pi-coding-agent
if errorlevel 1 (
    echo EURECATagent uninstallation failed.
    pause
    exit /b 1
)

echo Removing EURECAT configuration from %AGENT_CONFIG_DIR%...
if exist "%AGENT_CONFIG_DIR%\APPEND_SYSTEM.md" del /f /q "%AGENT_CONFIG_DIR%\APPEND_SYSTEM.md"
if exist "%AGENT_CONFIG_DIR%\logo.txt" del /f /q "%AGENT_CONFIG_DIR%\logo.txt"
if exist "%AGENT_CONFIG_DIR%\settings.json" del /f /q "%AGENT_CONFIG_DIR%\settings.json"
if exist "%AGENT_CONFIG_DIR%\mcp.json" del /f /q "%AGENT_CONFIG_DIR%\mcp.json"
if exist "%AGENT_CONFIG_DIR%\extensions\eurecat-header.ts" del /f /q "%AGENT_CONFIG_DIR%\extensions\eurecat-header.ts"
if exist "%AGENT_CONFIG_DIR%\extensions\ai-router.ts" del /f /q "%AGENT_CONFIG_DIR%\extensions\ai-router.ts"
if exist "%AGENT_CONFIG_DIR%\themes\eurecat-theme.json" del /f /q "%AGENT_CONFIG_DIR%\themes\eurecat-theme.json"
if exist "%AGENT_CONFIG_DIR%\agents\generic-context-builder.md" del /f /q "%AGENT_CONFIG_DIR%\agents\generic-context-builder.md"
if exist "%AGENT_CONFIG_DIR%\agents\generic-planner.md" del /f /q "%AGENT_CONFIG_DIR%\agents\generic-planner.md"
if exist "%AGENT_CONFIG_DIR%\agents\generic-worker.md" del /f /q "%AGENT_CONFIG_DIR%\agents\generic-worker.md"
if exist "%AGENT_CONFIG_DIR%\agents\generic-reviewer.md" del /f /q "%AGENT_CONFIG_DIR%\agents\generic-reviewer.md"
if exist "%AGENT_CONFIG_DIR%\agents\generic-parallel-review.md" del /f /q "%AGENT_CONFIG_DIR%\agents\generic-parallel-review.md"
if exist "%AGENT_CONFIG_DIR%\chains\generic-discovery.chain.md" del /f /q "%AGENT_CONFIG_DIR%\chains\generic-discovery.chain.md"
if exist "%AGENT_CONFIG_DIR%\chains\generic-implement-safe.chain.md" del /f /q "%AGENT_CONFIG_DIR%\chains\generic-implement-safe.chain.md"
if exist "%AGENT_CONFIG_DIR%\chains\generic-research-and-plan.chain.md" del /f /q "%AGENT_CONFIG_DIR%\chains\generic-research-and-plan.chain.md"
if exist "%AGENT_CONFIG_DIR%\skills\architecture" rd /s /q "%AGENT_CONFIG_DIR%\skills\architecture"
if exist "%AGENT_CONFIG_DIR%\skills\documentation" rd /s /q "%AGENT_CONFIG_DIR%\skills\documentation"
if exist "%AGENT_CONFIG_DIR%\skills\eurecat-brain" rd /s /q "%AGENT_CONFIG_DIR%\skills\eurecat-brain"
if exist "%AGENT_CONFIG_DIR%\skills\fix" rd /s /q "%AGENT_CONFIG_DIR%\skills\fix"
if exist "%AGENT_CONFIG_DIR%\skills\learn" rd /s /q "%AGENT_CONFIG_DIR%\skills\learn"
if exist "%AGENT_CONFIG_DIR%\skills\review" rd /s /q "%AGENT_CONFIG_DIR%\skills\review"
if exist "%AGENT_CONFIG_DIR%\skills\spec-driven-development" rd /s /q "%AGENT_CONFIG_DIR%\skills\spec-driven-development"
if exist "%AGENT_CONFIG_DIR%\skills\status" rd /s /q "%AGENT_CONFIG_DIR%\skills\status"
if exist "%AGENT_CONFIG_DIR%\skills\sync" rd /s /q "%AGENT_CONFIG_DIR%\skills\sync"
if exist "%AGENT_CONFIG_DIR%\skills\testing" rd /s /q "%AGENT_CONFIG_DIR%\skills\testing"
if exist "%AGENT_CONFIG_DIR%\skills\ux" rd /s /q "%AGENT_CONFIG_DIR%\skills\ux"
if exist "%AGENT_CONFIG_DIR%\npm\node_modules\@catdaemon\pi-code-intelligence" rd /s /q "%AGENT_CONFIG_DIR%\npm\node_modules\@catdaemon\pi-code-intelligence"
if exist "%AGENT_CONFIG_DIR%\npm\node_modules\pi-mcp-adapter" rd /s /q "%AGENT_CONFIG_DIR%\npm\node_modules\pi-mcp-adapter"
if exist "%AGENT_CONFIG_DIR%\npm\node_modules\pi-subagents" rd /s /q "%AGENT_CONFIG_DIR%\npm\node_modules\pi-subagents"
if exist "%AGENT_CONFIG_DIR%\bin\eurecatagent" del /f /q "%AGENT_CONFIG_DIR%\bin\eurecatagent"
if exist "%AGENT_CONFIG_DIR%\bin\eurecatagent.cmd" del /f /q "%AGENT_CONFIG_DIR%\bin\eurecatagent.cmd"
if exist "%AGENT_CONFIG_DIR%\bin\pi" del /f /q "%AGENT_CONFIG_DIR%\bin\pi"
if exist "%AGENT_CONFIG_DIR%\bin\pi.cmd" del /f /q "%AGENT_CONFIG_DIR%\bin\pi.cmd"
2>nul rd "%AGENT_CONFIG_DIR%\bin"
2>nul rd "%AGENT_CONFIG_DIR%\extensions"
2>nul rd "%AGENT_CONFIG_DIR%\themes"
2>nul rd "%AGENT_CONFIG_DIR%\agents"
2>nul rd "%AGENT_CONFIG_DIR%\chains"
2>nul rd "%AGENT_CONFIG_DIR%\skills"
2>nul rd "%AGENT_CONFIG_DIR%\npm\node_modules\@catdaemon"
2>nul rd "%AGENT_CONFIG_DIR%\npm\node_modules"
2>nul rd "%AGENT_CONFIG_DIR%\npm"
2>nul rd "%AGENT_CONFIG_DIR%"
2>nul rd "%USERPROFILE%\.pi"

echo.
echo [OK] EURECATagent uninstalled
echo [OK] Configuration removed from %AGENT_CONFIG_DIR%
echo.
echo [WARN] Other package managers: pnpm remove -g ... / yarn global remove ... / bun uninstall -g ...
echo.

pause
