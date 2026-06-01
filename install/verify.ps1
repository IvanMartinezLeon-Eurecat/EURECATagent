$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue

$checksPass = 0
$checksFail = 0

Write-Host ""
Write-Host "=== EURECATagent Verification ===" -ForegroundColor $Blue
Write-Host ""

function Check-Command {
    param([string]$Command, [string]$PrettyName = $Command)

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        try {
            $version = & $Command --version 2>$null
            Write-Host "✓ $PrettyName : $version" -ForegroundColor $Green
        } catch {
            Write-Host "✓ $PrettyName : Instalado" -ForegroundColor $Green
        }
        $global:checksPass++
    } else {
        Write-Host "✗ $PrettyName : No instalado" -ForegroundColor $Red
        $global:checksFail++
    }
}

Write-Host "== Verificaciones del Sistema ==" -ForegroundColor $Blue
Write-Host ""
Check-Command "node" "Node.js"
Check-Command "npm" "npm"
Check-Command "pi" "EURECATagent"
Check-Command "eurecatagent" "EURECATagent CLI"

Write-Host ""
Write-Host "== Variables de Entorno (Opcional) ==" -ForegroundColor $Blue
Write-Host ""
if ($env:ANTHROPIC_API_KEY) {
    Write-Host "✓ ANTHROPIC_API_KEY : Configurada" -ForegroundColor $Green
    $global:checksPass++
} else {
    Write-Host "⚠ ANTHROPIC_API_KEY : No configurada (puedes usar /login en EURECATagent)" -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "== Información de EURECATagent ==" -ForegroundColor $Blue
Write-Host ""

if (Get-Command pi -ErrorAction SilentlyContinue) {
    $agentConfigDir = Join-Path $HOME ".pi\agent"
    if (Test-Path (Join-Path $agentConfigDir "settings.json")) {
        Write-Host "✓ Configuración EURECAT : $agentConfigDir" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "⚠ Configuración EURECAT : No encontrada en $agentConfigDir" -ForegroundColor $Yellow
    }

    $piPackages = pi list 2>$null
    if ($piPackages -match "pi-subagents") {
        Write-Host "✓ Coding Agent : Instalado y activo" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "✗ Coding Agent : No detectado en 'pi list'" -ForegroundColor $Red
        $global:checksFail++
    }

    if ($piPackages -match "pi-mcp-adapter") {
        Write-Host "✓ MCP Adapter : Instalado y activo" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "✗ MCP Adapter : No detectado en 'pi list'" -ForegroundColor $Red
        $global:checksFail++
    }

    if ($piPackages -match "@catdaemon/pi-code-intelligence") {
        Write-Host "✓ Code Intelligence : Instalado y activo" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "✗ Code Intelligence : No detectado en 'pi list'" -ForegroundColor $Red
        $global:checksFail++
    }

    $agentMcpConfig = Join-Path $agentConfigDir "mcp.json"
    if ((Test-Path $agentMcpConfig) -and ((Get-Content $agentMcpConfig -Raw) -match '"context-mode"')) {
        Write-Host "✓ context-mode MCP : Configurado en $agentMcpConfig" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "⚠ context-mode MCP : No detectado en $agentMcpConfig" -ForegroundColor $Yellow
    }

    $routerExtension = Join-Path $agentConfigDir "extensions\ai-router.ts"
    if (Test-Path $routerExtension) {
        Write-Host "✓ ai-router extension : Instalada" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "⚠ ai-router extension : No encontrada en $routerExtension" -ForegroundColor $Yellow
    }

    $genericAgents = @(
        (Join-Path $agentConfigDir "agents\generic-context-builder.md"),
        (Join-Path $agentConfigDir "agents\generic-planner.md"),
        (Join-Path $agentConfigDir "agents\generic-worker.md"),
        (Join-Path $agentConfigDir "agents\generic-reviewer.md"),
        (Join-Path $agentConfigDir "agents\generic-parallel-review.md")
    )
    $missingGenericAgents = ($genericAgents | Where-Object { -not (Test-Path $_) }).Count
    if ($missingGenericAgents -eq 0) {
        Write-Host "✓ Subagentes genéricos : Instalados en $agentConfigDir\agents" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "✗ Subagentes genéricos : Faltan $missingGenericAgents archivo(s) en $agentConfigDir\agents" -ForegroundColor $Red
        $global:checksFail++
    }

    $genericChains = @(
        (Join-Path $agentConfigDir "chains\generic-discovery.chain.md"),
        (Join-Path $agentConfigDir "chains\generic-implement-safe.chain.md"),
        (Join-Path $agentConfigDir "chains\generic-research-and-plan.chain.md")
    )
    $missingGenericChains = ($genericChains | Where-Object { -not (Test-Path $_) }).Count
    if ($missingGenericChains -eq 0) {
        Write-Host "✓ Chains genéricas : Instaladas en $agentConfigDir\chains" -ForegroundColor $Green
        $global:checksPass++
    } else {
        Write-Host "✗ Chains genéricas : Faltan $missingGenericChains archivo(s) en $agentConfigDir\chains" -ForegroundColor $Red
        $global:checksFail++
    }
} else {
    Write-Host "EURECATagent no está instalado" -ForegroundColor $Red
    Write-Host "Ejecuta: .\install.ps1"
}

Write-Host ""
Write-Host "== Summary ==" -ForegroundColor $Blue
Write-Host ""
if ($checksFail -eq 0) {
    Write-Host "✓ All checks passed" -ForegroundColor $Green
} else {
    Write-Host "✗ $checksFail check(s) failed — run install.ps1 first" -ForegroundColor $Red
}
Write-Host ""
