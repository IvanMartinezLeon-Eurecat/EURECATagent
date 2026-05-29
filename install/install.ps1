# Instalador de EURECATagent para Windows PowerShell

$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor $Blue
    Write-Host "║  $($Message.PadRight(38))              ║" -ForegroundColor $Blue
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor $Blue
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

Write-Header "Instalador de EURECATagent"
Write-Info "Instalador para Windows PowerShell"
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
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
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

& $piExecutable install npm:pi-subagents
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $piExecutable install npm:pi-mcp-adapter
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $piExecutable install npm:@catdaemon/pi-code-intelligence
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

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

Write-Success "pi-subagents instalado y activo"
Write-Success "pi-mcp-adapter instalado y activo"
Write-Success "@catdaemon/pi-code-intelligence instalado y activo"
Write-Success "EURECATagent instalado en $wrapperPath"

Write-Host ""
Write-Header "EURECATagent instalado correctamente"
Write-Host ""

if (Get-Command pi -ErrorAction SilentlyContinue) {
    Write-Success "EURECATagent ya está disponible en tu PATH"
} else {
    Write-Warning-Custom "El comando EURECATagent no está disponible todavía en tu PATH."
    Write-Info "Cierra y vuelve a abrir PowerShell o Command Prompt para refrescar tu PATH."
}

Write-Host ""
Write-Info "Próximos pasos:"
Write-Host "1. Validación opcional: .\verify.ps1"
Write-Host "2. Ve a tu directorio de proyecto: cd C:\path\to\your\project"
Write-Host "3. Inicia EURECATagent: eurecatagent"
Write-Host "4. EURECATagent almacenará la memoria de Code Intelligence en <project>/.eurecat-data"
Write-Host "5. Autentícate con: /login"
Write-Host "6. O configura tu API key: `$env:ANTHROPIC_API_KEY='your-key'"
Write-Host "7. Comprueba el router: /router-status"
Write-Host "8. Prepara la inteligencia local: /code-intelligence-doctor"
Write-Host "9. Actívala en el repo: /enable-code-intelligence"
Write-Host "10. Comprueba MCP: /mcp"
Write-Host "11. Para descubrimiento estructural usa: code_intelligence_search"
Write-Host ""
Write-Info "Configuración instalada: $agentConfigDir"
Write-Info "Documentación: https://pi.dev/docs/latest"
Write-Info "pi-subagents: https://pi.dev/packages/pi-subagents"
Write-Info "pi-mcp-adapter: https://pi.dev/packages/pi-mcp-adapter"
Write-Info "pi-code-intelligence: https://pi.dev/packages/@catdaemon/pi-code-intelligence"
Write-Host ""
