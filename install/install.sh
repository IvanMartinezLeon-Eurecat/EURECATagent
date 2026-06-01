#!/bin/bash

# Instalador de EURECATagent para Linux/macOS

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== EURECATagent Installer (Linux/macOS) ===${NC}"
echo ""

if ! command -v node &>/dev/null; then
	echo -e "${RED}✗ Error: Node.js no está instalado.${NC}"
	echo -e "${YELLOW}Instala Node.js v18.0.0 o superior desde https://nodejs.org/${NC}"
	exit 1
fi

echo -e "${GREEN}✓ Node.js $(node -v) detectado${NC}"

if ! command -v npm &>/dev/null; then
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

	cat >>"${rc_file}" <<'EOF'
# >>> EURECAT agent PATH >>>
export PATH="$HOME/.pi/agent/bin:$PATH"
# <<< EURECAT agent PATH <<<
EOF
}

resolve_real_pi_bin() {
	local wrapper_candidate="${AGENT_BIN_DIR}/pi"
	local candidate=""

	if command -v pi &>/dev/null; then
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

check_pi_package() {
	local pkg="$1"
	local label="$2"
	local list_output
	list_output="$(\"${PI_BIN}\" list 2>/dev/null || true)"
	if echo "${list_output}" | grep -q "${pkg}"; then
		echo -e "${GREEN}✓ ${label}${NC}: Instalado y activo"
		return 0
	else
		echo -e "${RED}✗ ${label}${NC}: No detectado en 'pi list'"
		return 1
	fi
}

verify_subagent_config() {
	local required=(
		"generic-context-builder.md"
		"generic-planner.md"
		"generic-worker.md"
		"generic-reviewer.md"
		"generic-parallel-review.md"
	)
	local missing=0
	for f in "${required[@]}"; do
		if [ ! -f "${AGENT_CONFIG_DIR}/agents/${f}" ]; then
			((missing++))
		fi
	done
	if [ ${missing} -eq 0 ]; then
		echo -e "${GREEN}✓ Subagentes genéricos${NC}: Configuración copiada correctamente"
	else
		echo -e "${RED}✗ Subagentes genéricos${NC}: Faltan ${missing} archivo(s) — la configuración no se copió completamente"
		return 1
	fi
}

echo -e "${YELLOW}Instalando EURECATagent...${NC}"
if ! npm install -g --loglevel=error --ignore-scripts @earendil-works/pi-coding-agent >/dev/null 2>&1; then
	echo -e "${RED}✗ Error: No se pudo instalar @earendil-works/pi-coding-agent${NC}"
	exit 1
fi

echo -e "${YELLOW}Copiando la configuración de EURECATagent...${NC}"
if [ ! -d "${CONFIG_SOURCE_DIR}" ]; then
	echo -e "${RED}✗ Error: No se encontró la carpeta de configuración en ${CONFIG_SOURCE_DIR}${NC}"
	exit 1
fi

mkdir -p "${AGENT_CONFIG_DIR}"
cp -R "${CONFIG_SOURCE_DIR}/." "${AGENT_CONFIG_DIR}/"
echo -e "${GREEN}✓ Configuración copiada ${NC}"
verify_subagent_config

echo -e "${YELLOW}Instalando y activando paquetes...${NC}"
PI_BIN="$(resolve_real_pi_bin || true)"

if [ -z "${PI_BIN}" ]; then
	echo -e "${RED}✗ Error: No se pudo localizar el ejecutable de pi después de la instalación.${NC}"
	exit 1
fi

echo -e "${YELLOW}Instalando Coding Agent...${NC}"
if "${PI_BIN}" install npm:pi-subagents >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Paquete Coding Agent instalado${NC}"
else
	echo -e "${RED}✗ Error al instalar Coding Agent (pi-subagents)${NC}"
	exit 1
fi

echo -e "${YELLOW}Instalando MCP Adapter...${NC}"
if "${PI_BIN}" install npm:pi-mcp-adapter >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Paquete MCP Adapter instalado${NC}"
else
	echo -e "${RED}✗ Error al instalar MCP Adapter (pi-mcp-adapter)${NC}"
	exit 1
fi

echo -e "${YELLOW}Instalando Code Intelligence...${NC}"
if "${PI_BIN}" install npm:@catdaemon/pi-code-intelligence >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Paquete Code Intelligence instalado${NC}"
else
	echo -e "${RED}✗ Error al instalar Code Intelligence (@catdaemon/pi-code-intelligence)${NC}"
	exit 1
fi

echo -e "${YELLOW}Instalando Web Access...${NC}"
if "${PI_BIN}" install npm:pi-web-access >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Paquete Web Access instalado${NC}"
else
	echo -e "${RED}✗ Error al instalar Web Access (pi-web-access)${NC}"
	exit 1
fi

echo -e "${YELLOW}Instalando Ask User...${NC}"
if "${PI_BIN}" install npm:pi-ask-user >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Paquete Ask User instalado${NC}"
else
	echo -e "${RED}✗ Error al instalar Ask User (pi-ask-user)${NC}"
	exit 1
fi

echo -e "${YELLOW}Instalando Lean Context (pi-lean-ctx)...${NC}"

# lean-ctx binary (Rust) — opcional, para compresión de tokens
if command -v cargo &>/dev/null; then
	echo -e "${YELLOW}  Instalando lean-ctx binary via cargo...${NC}"
	if cargo install lean-ctx 2>/dev/null; then
		echo -e "${GREEN}✓ lean-ctx binary instalado${NC}"
	else
		echo -e "${YELLOW}⚠ lean-ctx binary: falló la instalación con cargo (opcional)${NC}"
	fi
elif command -v brew &>/dev/null; then
	echo -e "${YELLOW}  Instalando lean-ctx binary via brew...${NC}"
	if brew tap yvgude/lean-ctx 2>/dev/null && brew install lean-ctx 2>/dev/null; then
		echo -e "${GREEN}✓ lean-ctx binary instalado${NC}"
	else
		echo -e "${YELLOW}⚠ lean-ctx binary: falló la instalación con brew (opcional)${NC}"
	fi
else
	echo -e "${YELLOW}⚠ lean-ctx binary: ni cargo ni brew disponibles. Instálalo manualmente: cargo install lean-ctx${NC}"
fi

if "${PI_BIN}" install npm:pi-lean-ctx >/dev/null 2>&1; then
	echo -e "${GREEN}✓ Paquete Lean Context instalado${NC}"
else
	echo -e "${RED}✗ Error al instalar Lean Context (pi-lean-ctx)${NC}"
	exit 1
fi

if [ ! -f "${TEMPLATE_DIR}/pi-unix-wrapper.sh" ]; then
	echo -e "${RED}✗ Error: No se encontró la plantilla del wrapper en ${TEMPLATE_DIR}/pi-unix-wrapper.sh${NC}"
	exit 1
fi

mkdir -p "${AGENT_BIN_DIR}"
PI_BIN_ESCAPED="$(printf '%s' "${PI_BIN}" | sed 's/[&|]/\\&/g')"
sed "s|__PI_REAL_BIN__|${PI_BIN_ESCAPED}|g" "${TEMPLATE_DIR}/pi-unix-wrapper.sh" >"${WRAPPER_PATH}"
chmod +x "${WRAPPER_PATH}"

# Crear comando eurecatagent
EURE_WRAPPER_PATH="${AGENT_BIN_DIR}/eurecatagent"
sed "s|__PI_REAL_BIN__|${PI_BIN_ESCAPED}|g" "${TEMPLATE_DIR}/eurecatagent-wrapper.sh" >"${EURE_WRAPPER_PATH}"
chmod +x "${EURE_WRAPPER_PATH}"

append_path_block "${HOME}/.profile"
append_path_block "${HOME}/.bashrc"
append_path_block "${HOME}/.zshrc"
export PATH="${AGENT_BIN_DIR}:$PATH"

echo -e "${GREEN}[OK] EURECATagent installed at ${WRAPPER_PATH}${NC}"

echo ""

if command -v pi &>/dev/null; then
	echo -e "${GREEN}[OK] EURECATagent is available in your PATH${NC}"
else
	echo -e "${YELLOW}[WARN] Restart your terminal or run: source ~/.bashrc${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. cd /your/project  &&  eurecatagent"
echo "  2. /login  or  export ANTHROPIC_API_KEY=your-key"
echo "  3. /code-intelligence-doctor  &&  /enable-code-intelligence"
echo "  4. Docs: https://pi.dev/docs/latest"
echo ""
echo -e "${BLUE}Config installed:${NC} ${AGENT_CONFIG_DIR}"
echo ""
