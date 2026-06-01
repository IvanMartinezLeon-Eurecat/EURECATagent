# EURECAT agent Uninstaller for Windows (PowerShell)

$Blue = [System.ConsoleColor]::Blue
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow

Write-Host ""
Write-Host "=== EURECATagent Uninstaller (Windows PowerShell) ===" -ForegroundColor $Blue
Write-Host ""

$agentConfigDir = Join-Path $HOME ".pi\agent"

Write-Host "This will uninstall EURECATagent and remove its configuration from $agentConfigDir." -ForegroundColor $Yellow
Write-Host ""

$confirmation = Read-Host "Are you sure? (y/n)"
if ($confirmation -ne "y" -and $confirmation -ne "Y") {
    Write-Host "Uninstallation cancelled." -ForegroundColor $Yellow
    exit 0
}

Write-Host ""
Write-Host "Removing EURECAT packages..." -ForegroundColor $Yellow
Write-Host ""

$piExecutable = $null
$piCommand = Get-Command pi -ErrorAction SilentlyContinue
if ($piCommand) {
    $piExecutable = $piCommand.Source
} else {
    $npmGlobalPrefix = (npm prefix -g 2>$null).Trim()
    $piCommandPath = Join-Path $npmGlobalPrefix "pi.cmd"
    if (Test-Path $piCommandPath) {
        $piExecutable = $piCommandPath
    }
}

if ($piExecutable) {
    Write-Host "  Desinstalando Ask User..." -ForegroundColor $Yellow
    & $piExecutable remove npm:pi-ask-user >$null 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Ask User desinstalado" -ForegroundColor $Green
    } else {
        Write-Host "  ⚠ Ask User no estaba instalado" -ForegroundColor $Yellow
    }

    Write-Host "  Desinstalando Web Access..." -ForegroundColor $Yellow
    & $piExecutable remove npm:pi-web-access >$null 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Web Access desinstalado" -ForegroundColor $Green
    } else {
        Write-Host "  ⚠ Web Access no estaba instalado" -ForegroundColor $Yellow
    }

    Write-Host "  Desinstalando Lens..." -ForegroundColor $Yellow
    & $piExecutable remove npm:pi-lens >$null 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Lens desinstalado" -ForegroundColor $Green
    } else {
        Write-Host "  ⚠ Lens no estaba instalado" -ForegroundColor $Yellow
    }

    Write-Host "  Desinstalando Code Intelligence..." -ForegroundColor $Yellow
    & $piExecutable remove npm:@catdaemon/pi-code-intelligence >$null 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Code Intelligence desinstalado" -ForegroundColor $Green
    } else {
        Write-Host "  ⚠ Code Intelligence no estaba instalado" -ForegroundColor $Yellow
    }

    Write-Host "  Desinstalando MCP Adapter..." -ForegroundColor $Yellow
    & $piExecutable remove npm:pi-mcp-adapter >$null 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ MCP Adapter desinstalado" -ForegroundColor $Green
    } else {
        Write-Host "  ⚠ MCP Adapter no estaba instalado" -ForegroundColor $Yellow
    }

    Write-Host "  Desinstalando Coding Agent..." -ForegroundColor $Yellow
    & $piExecutable remove npm:pi-subagents >$null 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Coding Agent desinstalado" -ForegroundColor $Green
    } else {
        Write-Host "  ⚠ Coding Agent no estaba instalado" -ForegroundColor $Yellow
    }
}

Write-Host "Uninstalling EURECATagent..." -ForegroundColor $Yellow
Write-Host ""

# Uninstall the underlying agent using npm
npm uninstall -g @earendil-works/pi-coding-agent
if ($LASTEXITCODE -ne 0) {
    Write-Host "EURECATagent uninstallation failed." -ForegroundColor $Red
    Read-Host "Press Enter to close"
    exit $LASTEXITCODE
}

Write-Host "Removing EURECAT configuration from $agentConfigDir..." -ForegroundColor $Yellow

$pathsToRemove = @(
    (Join-Path $agentConfigDir "APPEND_SYSTEM.md"),
    (Join-Path $agentConfigDir "logo.txt"),
    (Join-Path $agentConfigDir "settings.json"),
    (Join-Path $agentConfigDir "mcp.json"),
    (Join-Path $agentConfigDir "extensions\eurecat-header.ts"),
    (Join-Path $agentConfigDir "extensions\ai-router.ts"),
    (Join-Path $agentConfigDir "themes\eurecat-theme.json"),
    (Join-Path $agentConfigDir "agents\generic-context-builder.md"),
    (Join-Path $agentConfigDir "agents\generic-planner.md"),
    (Join-Path $agentConfigDir "agents\generic-worker.md"),
    (Join-Path $agentConfigDir "agents\generic-reviewer.md"),
    (Join-Path $agentConfigDir "agents\generic-parallel-review.md"),
    (Join-Path $agentConfigDir "chains\generic-discovery.chain.md"),
    (Join-Path $agentConfigDir "chains\generic-implement-safe.chain.md"),
    (Join-Path $agentConfigDir "chains\generic-research-and-plan.chain.md"),
    (Join-Path $agentConfigDir "skills\architecture"),
    (Join-Path $agentConfigDir "skills\documentation"),
    (Join-Path $agentConfigDir "skills\eurecat-brain"),
    (Join-Path $agentConfigDir "skills\fix"),
    (Join-Path $agentConfigDir "skills\learn"),
    (Join-Path $agentConfigDir "skills\review"),
    (Join-Path $agentConfigDir "skills\spec-driven-development"),
    (Join-Path $agentConfigDir "skills\status"),
    (Join-Path $agentConfigDir "skills\sync"),
    (Join-Path $agentConfigDir "skills\testing"),
    (Join-Path $agentConfigDir "skills\ux"),
    (Join-Path $agentConfigDir "npm\node_modules\@catdaemon\pi-code-intelligence"),
    (Join-Path $agentConfigDir "npm\node_modules\pi-mcp-adapter"),
    (Join-Path $agentConfigDir "npm\node_modules\pi-subagents"),
    (Join-Path $agentConfigDir "bin\eurecatagent"),
    (Join-Path $agentConfigDir "bin\eurecatagent.cmd"),
    (Join-Path $agentConfigDir "bin\pi"),
    (Join-Path $agentConfigDir "bin\pi.cmd")
)

foreach ($path in $pathsToRemove) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
    }
}

$dirsToCleanup = @(
    (Join-Path $agentConfigDir "extensions"),
    (Join-Path $agentConfigDir "themes"),
    (Join-Path $agentConfigDir "agents"),
    (Join-Path $agentConfigDir "chains"),
    (Join-Path $agentConfigDir "skills"),
    (Join-Path $agentConfigDir "npm\node_modules\@catdaemon"),
    (Join-Path $agentConfigDir "npm\node_modules"),
    (Join-Path $agentConfigDir "npm"),
    $agentConfigDir,
    (Join-Path $HOME ".pi")
)

foreach ($dir in $dirsToCleanup) {
    if ((Test-Path $dir) -and ((Get-ChildItem -Force -ErrorAction SilentlyContinue $dir | Measure-Object).Count -eq 0)) {
        Remove-Item -Path $dir -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "[OK] EURECATagent uninstalled" -ForegroundColor $Green
Write-Host "[OK] Configuration removed from $agentConfigDir" -ForegroundColor $Green
Write-Host ""
Write-Host "Other package managers: pnpm remove -g ... / yarn global remove ... / bun uninstall -g ..." -ForegroundColor $Yellow
Write-Host ""

Read-Host "Press Enter to close"
