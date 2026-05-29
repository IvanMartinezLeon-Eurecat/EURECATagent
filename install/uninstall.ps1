# EURECAT agent Uninstaller for Windows (PowerShell)

$Blue = [System.ConsoleColor]::Blue
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor $Blue
    Write-Host "║  $($Message.PadRight(38))              ║" -ForegroundColor $Blue
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor $Blue
    Write-Host ""
}

# Header
Write-Header "EURECAT agent Uninstaller"

$agentConfigDir = Join-Path $HOME ".pi\agent"

Write-Host "This will uninstall Pi from your system and remove EURECAT configuration from $agentConfigDir." -ForegroundColor $Yellow
Write-Host ""

$confirmation = Read-Host "Are you sure? (y/n)"
if ($confirmation -ne "y" -and $confirmation -ne "Y") {
    Write-Host "Uninstallation cancelled." -ForegroundColor $Yellow
    exit 0
}

Write-Host ""
Write-Host "Removing Pi packages managed by EURECAT..." -ForegroundColor $Yellow
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
    & $piExecutable remove npm:@catdaemon/pi-code-intelligence 2>$null
    & $piExecutable remove npm:pi-mcp-adapter 2>$null
    & $piExecutable remove npm:pi-subagents 2>$null
}

Write-Host "Uninstalling Pi coding agent..." -ForegroundColor $Yellow
Write-Host ""

# Uninstall Pi using npm
npm uninstall -g @earendil-works/pi-coding-agent
if ($LASTEXITCODE -ne 0) {
    Write-Host "Pi uninstallation failed." -ForegroundColor $Red
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
    (Join-Path $agentConfigDir "npm\node_modules\pi-subagents")
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
Write-Header "Pi uninstalled successfully!"
Write-Host ""
Write-Host "EURECAT configuration removed from $agentConfigDir" -ForegroundColor $Green
Write-Host ""

Write-Host "If you installed Pi with a different package manager:" -ForegroundColor $Yellow
Write-Host "  - pnpm: pnpm remove -g @earendil-works/pi-coding-agent"
Write-Host "  - Yarn: yarn global remove @earendil-works/pi-coding-agent"
Write-Host "  - Bun:  bun uninstall -g @earendil-works/pi-coding-agent"
Write-Host ""

Read-Host "Press Enter to close"
