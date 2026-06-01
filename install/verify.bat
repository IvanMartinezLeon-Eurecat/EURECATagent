@echo off
REM Herramienta de verificación de EURECATagent para Windows CMD

setlocal enabledelayedexpansion
set checks_pass=0
set checks_fail=0

echo.
echo === EURECATagent Verification ===
echo.

echo == Verificaciones del Sistema ==
echo.
where node >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node --version') do set node_version=%%i
    echo [OK] Node.js: !node_version!
    set /a checks_pass+=1
) else (
    echo [FAIL] Node.js: No instalado
    set /a checks_fail+=1
)

where npm >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('npm --version') do set npm_version=%%i
    echo [OK] npm: !npm_version!
    set /a checks_pass+=1
) else (
    echo [FAIL] npm: No instalado
    set /a checks_fail+=1
)

where pi >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] Pi: Instalado
    set /a checks_pass+=1
) else (
    echo [FAIL] Pi: No instalado
    set /a checks_fail+=1
)

echo.
echo == Variables de Entorno (Opcional) ==
echo.
if defined ANTHROPIC_API_KEY (
    echo [OK] ANTHROPIC_API_KEY: Configurada
    set /a checks_pass+=1
) else (
    echo [WARN] ANTHROPIC_API_KEY: No configurada ^(puedes usar /login en EURECATagent^)
)

echo.
echo == Información de EURECATagent ==
echo.
where pi >nul 2>nul
if %errorlevel% equ 0 (
    set "AGENT_CONFIG_DIR=%USERPROFILE%\.pi\agent"
    if exist "!AGENT_CONFIG_DIR!\settings.json" (
        echo [OK] Configuración EURECAT: !AGENT_CONFIG_DIR!
        set /a checks_pass+=1
    ) else (
        echo [WARN] Configuración EURECAT: No encontrada en !AGENT_CONFIG_DIR!
    )

    pi list 2>nul | findstr /C:"pi-subagents" >nul
    if !errorlevel! equ 0 (
        echo [OK] Coding Agent: Instalado y activo
        set /a checks_pass+=1
    ) else (
        echo [FAIL] Coding Agent: No detectado en "pi list"
        set /a checks_fail+=1
    )

    pi list 2>nul | findstr /C:"pi-mcp-adapter" >nul
    if !errorlevel! equ 0 (
        echo [OK] MCP Adapter: Instalado y activo
        set /a checks_pass+=1
    ) else (
        echo [FAIL] MCP Adapter: No detectado en "pi list"
        set /a checks_fail+=1
    )

    pi list 2>nul | findstr /C:"@catdaemon/pi-code-intelligence" >nul
    if !errorlevel! equ 0 (
        echo [OK] Code Intelligence: Instalado y activo
        set /a checks_pass+=1
    ) else (
        echo [FAIL] Code Intelligence: No detectado en "pi list"
        set /a checks_fail+=1
    )

    pi list 2>nul | findstr /C:"pi-lens" >nul
    if !errorlevel! equ 0 (
        echo [OK] Lens: Instalado y activo
        set /a checks_pass+=1
    ) else (
        echo [FAIL] Lens: No detectado en "pi list"
        set /a checks_fail+=1
    )

    pi list 2>nul | findstr /C:"pi-web-access" >nul
    if !errorlevel! equ 0 (
        echo [OK] Web Access: Instalado y activo
        set /a checks_pass+=1
    ) else (
        echo [FAIL] Web Access: No detectado en "pi list"
        set /a checks_fail+=1
    )

    pi list 2>nul | findstr /C:"pi-ask-user" >nul
    if !errorlevel! equ 0 (
        echo [OK] Ask User: Instalado y activo
        set /a checks_pass+=1
    ) else (
        echo [FAIL] Ask User: No detectado en "pi list"
        set /a checks_fail+=1
    )

    if exist "!AGENT_CONFIG_DIR!\mcp.json" (
        findstr /C:"\"context-mode\"" "!AGENT_CONFIG_DIR!\mcp.json" >nul
        if !errorlevel! equ 0 (
            echo [OK] context-mode MCP: Configurado en !AGENT_CONFIG_DIR!\mcp.json
            set /a checks_pass+=1
        ) else (
            echo [WARN] context-mode MCP: No detectado en !AGENT_CONFIG_DIR!\mcp.json
        )
    )

    if exist "!AGENT_CONFIG_DIR!\extensions\ai-router.ts" (
        echo [OK] ai-router extension: Instalada
        set /a checks_pass+=1
    ) else (
        echo [WARN] ai-router extension: No encontrada
    )

    set /a missing_generic_agents=0
    if not exist "!AGENT_CONFIG_DIR!\agents\generic-context-builder.md" set /a missing_generic_agents+=1
    if not exist "!AGENT_CONFIG_DIR!\agents\generic-planner.md" set /a missing_generic_agents+=1
    if not exist "!AGENT_CONFIG_DIR!\agents\generic-worker.md" set /a missing_generic_agents+=1
    if not exist "!AGENT_CONFIG_DIR!\agents\generic-reviewer.md" set /a missing_generic_agents+=1
    if not exist "!AGENT_CONFIG_DIR!\agents\generic-parallel-review.md" set /a missing_generic_agents+=1
    if !missing_generic_agents! equ 0 (
        echo [OK] Subagentes genéricos: Instalados en !AGENT_CONFIG_DIR!\agents
        set /a checks_pass+=1
    ) else (
        echo [FAIL] Subagentes genéricos: Faltan !missing_generic_agents! archivo^(s^) en !AGENT_CONFIG_DIR!\agents
        set /a checks_fail+=1
    )

    set /a missing_generic_chains=0
    if not exist "!AGENT_CONFIG_DIR!\chains\generic-discovery.chain.md" set /a missing_generic_chains+=1
    if not exist "!AGENT_CONFIG_DIR!\chains\generic-implement-safe.chain.md" set /a missing_generic_chains+=1
    if not exist "!AGENT_CONFIG_DIR!\chains\generic-research-and-plan.chain.md" set /a missing_generic_chains+=1
    if !missing_generic_chains! equ 0 (
        echo [OK] Chains genéricas: Instaladas en !AGENT_CONFIG_DIR!\chains
        set /a checks_pass+=1
    ) else (
        echo [FAIL] Chains genéricas: Faltan !missing_generic_chains! archivo^(s^) en !AGENT_CONFIG_DIR!\chains
        set /a checks_fail+=1
    )
) else (
    echo [FAIL] EURECATagent no está instalado
    echo Ejecuta: install.bat
)

echo.
echo == Summary ==
echo.
if !checks_fail! equ 0 (
    echo [OK] All checks passed
) else (
    echo [FAIL] !checks_fail! check(s) failed — run install.bat first
)
echo.
pause
