#!/bin/bash

# Instalador de EURECATagent para Linux/macOS

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  EURECATagent                          ║${NC}"
echo -e "${BLUE}║  Instalador para Linux/macOS           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Error: Node.js no está instalado.${NC}"
    echo -e "${YELLOW}Instala Node.js v18.0.0 o superior desde https://nodejs.org/${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js $(node -v) detectado${NC}"

if ! command -v npm &> /dev/null; then
    echo -e "${RED}✗ Error: npm no está instalado.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ npm $(npm -v) detectado${NC}"
echo ""

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE_DIR="${SCRIPT_DIR}/../config/agent"
TEMPLATE_DIR="${SCRIPT_DIR}/templates"
AGENT_CONFIG_DIR="${HOME}/.pi/agent"
AGENT_BIN_DIR="${AGENT_CONFIG_DIR}/bin"
WRAPPER_PATH="${AGENT_BIN_DIR}/pi"

append_path_block() {
    local rc_file="$1"
    local marker_start="# >>> EURECAT agent PATH >>>"

    mkdir -p "$(dirname "${rc_file}")"
    touch "${rc_file}"

    if grep -Fqs "${marker_start}" "${rc_file}"; then
        return 0
    fi

    cat >> "${rc_file}" <<'EOF'
# >>> EURECAT agent PATH >>>
export PATH="$HOME/.pi/agent/bin:$PATH"
# <<< EURECAT agent PATH <<<
EOF
}

resolve_real_pi_bin() {
    local wrapper_candidate="${AGENT_BIN_DIR}/pi"
    local candidate=""

    if command -v pi &> /dev/null; then
        candidate="$(command -v pi)"
        if [ "${candidate}" != "${wrapper_candidate}" ]; then
            printf '%s\n' "${candidate}"
            return 0
        fi
    fi

    local npm_global_prefix=""
    npm_global_prefix="$(npm prefix -g 2>/dev/null || true)"
    if [ -n "${npm_global_prefix}" ] && [ -x "${npm_global_prefix}/bin/pi" ]; then
        printf '%s\n' "${npm_global_prefix}/bin/pi"
        return 0
    fi

    return 1
}

echo -e "${YELLOW}Instalando Pi coding agent...${NC}"
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

echo -e "${YELLOW}Copiando la configuración de EURECATagent a ${AGENT_CONFIG_DIR}...${NC}"
if [ ! -d "${CONFIG_SOURCE_DIR}" ]; then
    echo -e "${RED}✗ Error: No se encontró la carpeta de configuración en ${CONFIG_SOURCE_DIR}${NC}"
    exit 1
fi

mkdir -p "${AGENT_CONFIG_DIR}"
cp -R "${CONFIG_SOURCE_DIR}/." "${AGENT_CONFIG_DIR}/"
echo -e "${GREEN}✓ Configuración copiada en ${AGENT_CONFIG_DIR}${NC}"

echo -e "${YELLOW}Instalando y activando paquetes de Pi...${NC}"
PI_BIN="$(resolve_real_pi_bin || true)"

if [ -z "${PI_BIN}" ]; then
    echo -e "${RED}✗ Error: No se pudo localizar el ejecutable de pi después de la instalación.${NC}"
    exit 1
fi

"${PI_BIN}" install npm:pi-subagents
"${PI_BIN}" install npm:pi-mcp-adapter
"${PI_BIN}" install npm:@catdaemon/pi-code-intelligence

if [ ! -f "${TEMPLATE_DIR}/pi-unix-wrapper.sh" ]; then
    echo -e "${RED}✗ Error: No se encontró la plantilla del wrapper en ${TEMPLATE_DIR}/pi-unix-wrapper.sh${NC}"
    exit 1
fi

mkdir -p "${AGENT_BIN_DIR}"
PI_BIN_ESCAPED="$(printf '%s' "${PI_BIN}" | sed 's/[&|]/\\&/g')"
sed "s|__PI_REAL_BIN__|${PI_BIN_ESCAPED}|g" "${TEMPLATE_DIR}/pi-unix-wrapper.sh" > "${WRAPPER_PATH}"
chmod +x "${WRAPPER_PATH}"

append_path_block "${HOME}/.profile"
append_path_block "${HOME}/.bashrc"
append_path_block "${HOME}/.zshrc"
export PATH="${AGENT_BIN_DIR}:$PATH"

echo -e "${GREEN}✓ pi-subagents instalado y activo${NC}"
echo -e "${GREEN}✓ pi-mcp-adapter instalado y activo${NC}"
echo -e "${GREEN}✓ @catdaemon/pi-code-intelligence instalado y activo${NC}"
echo -e "${GREEN}✓ Launcher de Pi orientado a proyecto instalado en ${WRAPPER_PATH}${NC}"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  EURECATagent instalado correctamente  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

if command -v pi &> /dev/null; then
    echo -e "${GREEN}✓ Pi ya está disponible en tu PATH${NC}"
else
    echo -e "${YELLOW}⚠ El comando Pi no está disponible todavía en tu PATH.${NC}"
    echo -e "${YELLOW}Prueba a reiniciar tu terminal o ejecutar: source ~/.bashrc${NC}"
fi

echo ""
echo -e "${BLUE}Próximos pasos:${NC}"
echo "1. Validación opcional: bash verify.sh"
echo "2. Ve a tu directorio de proyecto: cd /path/to/your/project"
echo "3. Inicia Pi: pi"
echo "4. Pi almacenará la memoria de Code Intelligence en <project>/.eurecat-data"
echo "5. Autentícate con: /login (para proveedores con suscripción)"
echo "6. O configura tu API key: export ANTHROPIC_API_KEY=your-key"
echo "7. Comprueba el router: /router-status"
echo "8. Prepara la inteligencia local: /code-intelligence-doctor"
echo "9. Actívala en el repo: /enable-code-intelligence"
echo "10. Comprueba MCP: /mcp"
echo "11. Para descubrimiento estructural usa: code_intelligence_search"
echo ""
echo -e "${BLUE}Configuración instalada:${NC} ${AGENT_CONFIG_DIR}"
echo -e "${BLUE}Documentación: https://pi.dev/docs/latest${NC}"
echo -e "${BLUE}pi-subagents: https://pi.dev/packages/pi-subagents${NC}"
echo -e "${BLUE}pi-mcp-adapter: https://pi.dev/packages/pi-mcp-adapter${NC}"
echo -e "${BLUE}pi-code-intelligence: https://pi.dev/packages/@catdaemon/pi-code-intelligence${NC}"
echo ""
