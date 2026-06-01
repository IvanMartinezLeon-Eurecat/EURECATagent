# Instalador de EURECATagent para Windows PowerShell

$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=== $Message ===" -ForegroundColor $Blue
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $Red
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor $Blue
}

Write-Header "EURECATagent Installer (Windows PowerShell)"
Write-Host ""

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning-Custom "Este script se está ejecutando en modo usuario."
    Write-Info "Nota: npm puede solicitar privilegios de administrador."
    Write-Host ""
}

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Node.js no está instalado."
    Write-Info "Instala Node.js v18.0.0 o superior desde https://nodejs.org/"
    Write-Host ""
    exit 1
}
Write-Success "Node.js $(node --version) detectado"

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "npm no está instalado."
    exit 1
}
Write-Success "npm $(npm --version) detectado"
Write-Host ""

$configSourceDir = Join-Path (Split-Path -Parent $PSScriptRoot) "config\agent"
$templateDir = Join-Path $PSScriptRoot "templates"
$agentConfigDir = Join-Path $HOME ".pi\agent"
$agentBinDir = Join-Path $agentConfigDir "bin"
$wrapperPath = Join-Path $agentBinDir "pi.cmd"

function Resolve-RealPiExecutable {
    param([string]$WrapperPath)

    $piCommand = Get-Command pi -ErrorAction SilentlyContinue
    if ($piCommand -and $piCommand.Source -ne $WrapperPath) {
        return $piCommand.Source
    }

    $npmGlobalPrefix = (npm prefix -g).Trim()
    $candidate = Join-Path $npmGlobalPrefix "pi.cmd"
    if (Test-Path $candidate) {
        return $candidate
    }

    return $null
}

function Ensure-AgentBinOnUserPath {
    param([string]$AgentBinDir)

    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $segments = @()
    if ($currentUserPath) {
        $segments = $currentUserPath.Split(';') | Where-Object { $_ -and $_.Trim() -ne '' }
    }

    if ($segments -contains $AgentBinDir) {
        return
    }

    $newUserPath = @($AgentBinDir) + $segments
    [Environment]::SetEnvironmentVariable("Path", ($newUserPath -join ';'), "User")
}

Write-Info "Instalando EURECATagent..."
Write-Host ""
npm install -g --loglevel=error --ignore-scripts @earendil-works/pi-coding-agent
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Pi installation failed."
    exit $LASTEXITCODE
}

Write-Info "Copiando la configuración de EURECATagent a $agentConfigDir..."
if (-not (Test-Path $configSourceDir)) {
    Write-Error-Custom "No se encontró la carpeta de configuración en $configSourceDir"
    exit 1
}

New-Item -ItemType Directory -Path $agentConfigDir -Force | Out-Null
Copy-Item -Path (Join-Path $configSourceDir "*") -Destination $agentConfigDir -Recurse -Force
Write-Success "Configuración copiada en $agentConfigDir"

Write-Info "Instalando y activando paquetes..."
$piExecutable = Resolve-RealPiExecutable -WrapperPath $wrapperPath

if (-not $piExecutable) {
    Write-Error-Custom "No se pudo localizar el ejecutable de pi después de la instalación."
    exit 1
}

Write-Info "Instalando Coding Agent..."
& $piExecutable install npm:pi-subagents >$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Paquete Coding Agent instalado"
} else {
    Write-Error-Custom "Error al instalar Coding Agent (pi-subagents)"
    exit $LASTEXITCODE
}

Write-Info "Instalando MCP Adapter..."
& $piExecutable install npm:pi-mcp-adapter >$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Paquete MCP Adapter instalado"
} else {
    Write-Error-Custom "Error al instalar MCP Adapter (pi-mcp-adapter)"
    exit $LASTEXITCODE
}

Write-Info "Instalando Code Intelligence..."
& $piExecutable install npm:@catdaemon/pi-code-intelligence >$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Paquete Code Intelligence instalado"
} else {
    Write-Error-Custom "Error al instalar Code Intelligence (@catdaemon/pi-code-intelligence)"
    exit $LASTEXITCODE
}



Write-Info "Instalando Web Access..."
& $piExecutable install npm:pi-web-access >$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Paquete Web Access instalado"
} else {
    Write-Error-Custom "Error al instalar Web Access (pi-web-access)"
    exit $LASTEXITCODE
}

Write-Info "Instalando Ask User..."
& $piExecutable install npm:pi-ask-user >$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Paquete Ask User instalado"
} else {
    Write-Error-Custom "Error al instalar Ask User (pi-ask-user)"
    exit $LASTEXITCODE
}

Write-Info "Instalando Lean Context (pi-lean-ctx)..."

# lean-ctx binary (Rust) — opcional, para compresión de tokens
$cargoAvailable = Get-Command cargo -ErrorAction SilentlyContinue
if ($cargoAvailable) {
    Write-Info "  Instalando lean-ctx binary via cargo..."
    $cargoResult = cargo install lean-ctx 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        Write-Success "lean-ctx binary instalado"
    } else {
        Write-Warning-Custom "lean-ctx binary: falló la instalación con cargo (opcional)"
    }
} else {
    Write-Warning-Custom "lean-ctx binary: cargo no disponible. Instálalo manualmente con: cargo install lean-ctx"
}

& $piExecutable install npm:pi-lean-ctx >$null
if ($LASTEXITCODE -eq 0) {
    Write-Success "Paquete Lean Context instalado"
} else {
    Write-Error-Custom "Error al instalar Lean Context (pi-lean-ctx)"
    exit $LASTEXITCODE
}

$wrapperTemplatePath = Join-Path $templateDir "pi.cmd"
if (-not (Test-Path $wrapperTemplatePath)) {
    Write-Error-Custom "No se encontró la plantilla del wrapper en $wrapperTemplatePath"
    exit 1
}

New-Item -ItemType Directory -Path $agentBinDir -Force | Out-Null
$wrapperTemplate = Get-Content -Path $wrapperTemplatePath -Raw
$wrapperContent = $wrapperTemplate.Replace('__PI_REAL_BIN__', $piExecutable)
Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding ASCII

# Crear comando eurecatagent
$eureWrapperTemplatePath = Join-Path $templateDir "eurecatagent.cmd"
if (Test-Path $eureWrapperTemplatePath) {
    $eureCatAgentPath = Join-Path $agentBinDir "eurecatagent.cmd"
    $eureTemplate = Get-Content -Path $eureWrapperTemplatePath -Raw
    $eureContent = $eureTemplate.Replace('__PI_REAL_BIN__', $piExecutable)
    Set-Content -Path $eureCatAgentPath -Value $eureContent -Encoding ASCII
}

Ensure-AgentBinOnUserPath -AgentBinDir $agentBinDir
$env:Path = "$agentBinDir;$env:Path"

Write-Success "EURECATagent installed at $wrapperPath"

Write-Host ""
Write-Header "EURECATagent installed successfully"
Write-Host ""

if (Get-Command pi -ErrorAction SilentlyContinue) {
    Write-Success "EURECATagent is available in your PATH"
} else {
    Write-Warning-Custom "Restart your terminal to refresh PATH."
}

Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Start: cd /your/project  &&  eurecatagent"
Write-Host "  2. Auth:  /login  or  `$env:ANTHROPIC_API_KEY='your-key'"
Write-Host "  3. Repo:  /code-intelligence-doctor  &&  /enable-code-intelligence"
Write-Host "  4. Docs:  https://pi.dev/docs/latest"
Write-Host ""
Write-Info "Config: $agentConfigDir"
Write-Host ""
