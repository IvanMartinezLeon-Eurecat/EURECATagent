#!/bin/bash

# EURECAT agent Uninstaller for Linux/macOS
# Uninstall script for EURECATagent

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== EURECATagent Uninstaller (Linux/macOS) ===${NC}"
echo ""

# Check if npm is installed
if ! command -v npm &>/dev/null; then
	echo -e "${RED}✗ Error: npm is not installed.${NC}"
	exit 1
fi

echo -e "${YELLOW}This will uninstall EURECATagent from your system.${NC}"
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
	echo -e "${YELLOW}Uninstallation cancelled.${NC}"
	exit 0
fi

AGENT_CONFIG_DIR="${HOME}/.pi/agent"

PI_BIN=""
if command -v pi &>/dev/null; then
	PI_BIN="$(command -v pi)"
else
	NPM_GLOBAL_PREFIX="$(npm prefix -g 2>/dev/null || true)"
	if [ -n "${NPM_GLOBAL_PREFIX}" ] && [ -x "${NPM_GLOBAL_PREFIX}/bin/pi" ]; then
		PI_BIN="${NPM_GLOBAL_PREFIX}/bin/pi"
	fi
fi

check_pi_package_presence() {
	local pkg="$1"
	local label="$2"
	if [ -n "${PI_BIN}" ]; then
		local list_output
		list_output="$(\"${PI_BIN}\" list 2>/dev/null || true)"
		if echo "${list_output}" | grep -q "${pkg}" 2>/dev/null; then
			echo -e "  ${GREEN}✓${NC} ${label}"
			return 0
		fi
	fi
	echo -e "  ${YELLOW}⚠${NC} ${label}: No instalado"
	return 0
}

check_config_presence() {
	local file="$1"
	local label="$2"
	if [ -f "${AGENT_CONFIG_DIR}/${file}" ] || [ -d "${AGENT_CONFIG_DIR}/${file}" ]; then
		echo -e "  ${GREEN}✓${NC} ${label}"
	else
		echo -e "  ${YELLOW}⚠${NC} ${label}: No encontrado"
	fi
	return 0
}

echo ""
echo -e "${YELLOW}Checking installed packages...${NC}"
check_pi_package_presence "@catdaemon/pi-code-intelligence" "Code Intelligence"
check_pi_package_presence "pi-mcp-adapter" "MCP Adapter"
check_pi_package_presence "pi-subagents" "Coding Agent"
check_pi_package_presence "pi-lean-ctx" "Lean Context"

echo ""
echo -e "${YELLOW}Checking subagent config...${NC}"
check_config_presence "agents/generic-context-builder.md" "generic-context-builder"
check_config_presence "agents/generic-planner.md" "generic-planner"
check_config_presence "agents/generic-worker.md" "generic-worker"
check_config_presence "agents/generic-reviewer.md" "generic-reviewer"
check_config_presence "agents/generic-parallel-review.md" "generic-parallel-review"
check_config_presence "chains/generic-discovery.chain.md" "generic-discovery chain"
check_config_presence "chains/generic-implement-safe.chain.md" "generic-implement-safe chain"
check_config_presence "chains/generic-research-and-plan.chain.md" "generic-research-and-plan chain"

echo ""
echo -e "${YELLOW}Removing EURECAT packages...${NC}"

if [ -n "${PI_BIN}" ]; then
	echo -e "${YELLOW}  Desinstalando Ask User...${NC}"
	if "${PI_BIN}" remove npm:pi-ask-user >/dev/null 2>&1; then
		echo -e "${GREEN}  ✓ Ask User desinstalado${NC}"
	else
		echo -e "${YELLOW}  ⚠ Ask User no estaba instalado${NC}"
	fi

	echo -e "${YELLOW}  Desinstalando Web Access...${NC}"
	if "${PI_BIN}" remove npm:pi-web-access >/dev/null 2>&1; then
		echo -e "${GREEN}  ✓ Web Access desinstalado${NC}"
	else
		echo -e "${YELLOW}  ⚠ Web Access no estaba instalado${NC}"
	fi

	echo -e "${YELLOW}  Desinstalando Lean Context...${NC}"
	if "${PI_BIN}" remove npm:pi-lean-ctx >/dev/null 2>&1; then
		echo -e "${GREEN}  ✓ Lean Context desinstalado${NC}"
	else
		echo -e "${YELLOW}  ⚠ Lean Context no estaba instalado${NC}"
	fi

	echo -e "${YELLOW}  Desinstalando Code Intelligence...${NC}"
	if "${PI_BIN}" remove npm:@catdaemon/pi-code-intelligence >/dev/null 2>&1; then
		echo -e "${GREEN}  ✓ Code Intelligence desinstalado${NC}"
	else
		echo -e "${YELLOW}  ⚠ Code Intelligence no estaba instalado${NC}"
	fi

	echo -e "${YELLOW}  Desinstalando MCP Adapter...${NC}"
	if "${PI_BIN}" remove npm:pi-mcp-adapter >/dev/null 2>&1; then
		echo -e "${GREEN}  ✓ MCP Adapter desinstalado${NC}"
	else
		echo -e "${YELLOW}  ⚠ MCP Adapter no estaba instalado${NC}"
	fi

	echo -e "${YELLOW}  Desinstalando Coding Agent...${NC}"
	if "${PI_BIN}" remove npm:pi-subagents >/dev/null 2>&1; then
		echo -e "${GREEN}  ✓ Coding Agent desinstalado${NC}"
	else
		echo -e "${YELLOW}  ⚠ Coding Agent no estaba instalado${NC}"
	fi
fi

echo -e "${YELLOW}Uninstalling EURECATagent...${NC}"

# Uninstall the underlying agent using npm
npm uninstall -g @earendil-works/pi-coding-agent

echo -e "${YELLOW}Removing EURECAT configuration from ${AGENT_CONFIG_DIR}...${NC}"
rm -f "${AGENT_CONFIG_DIR}/APPEND_SYSTEM.md"
rm -f "${AGENT_CONFIG_DIR}/logo.txt"
rm -f "${AGENT_CONFIG_DIR}/settings.json"
rm -f "${AGENT_CONFIG_DIR}/mcp.json"
rm -f "${AGENT_CONFIG_DIR}/extensions/eurecat-header.ts"
rm -f "${AGENT_CONFIG_DIR}/extensions/ai-router.ts"
rm -f "${AGENT_CONFIG_DIR}/themes/eurecat-theme.json"
rm -f "${AGENT_CONFIG_DIR}/agents/generic-context-builder.md"
rm -f "${AGENT_CONFIG_DIR}/agents/generic-planner.md"
rm -f "${AGENT_CONFIG_DIR}/agents/generic-worker.md"
rm -f "${AGENT_CONFIG_DIR}/agents/generic-reviewer.md"
rm -f "${AGENT_CONFIG_DIR}/agents/generic-parallel-review.md"
rm -f "${AGENT_CONFIG_DIR}/chains/generic-discovery.chain.md"
rm -f "${AGENT_CONFIG_DIR}/chains/generic-implement-safe.chain.md"
rm -f "${AGENT_CONFIG_DIR}/chains/generic-research-and-plan.chain.md"
rm -rf "${AGENT_CONFIG_DIR}/skills/architecture"
rm -rf "${AGENT_CONFIG_DIR}/skills/documentation"
rm -rf "${AGENT_CONFIG_DIR}/skills/eurecat-brain"
rm -rf "${AGENT_CONFIG_DIR}/skills/fix"
rm -rf "${AGENT_CONFIG_DIR}/skills/learn"
rm -rf "${AGENT_CONFIG_DIR}/skills/review"
rm -rf "${AGENT_CONFIG_DIR}/skills/spec-driven-development"
rm -rf "${AGENT_CONFIG_DIR}/skills/status"
rm -rf "${AGENT_CONFIG_DIR}/skills/sync"
rm -rf "${AGENT_CONFIG_DIR}/skills/testing"
rm -rf "${AGENT_CONFIG_DIR}/skills/ux"
rm -rf "${AGENT_CONFIG_DIR}/npm/node_modules/@catdaemon/pi-code-intelligence"
rm -rf "${AGENT_CONFIG_DIR}/npm/node_modules/pi-mcp-adapter"
rm -rf "${AGENT_CONFIG_DIR}/npm/node_modules/pi-subagents"
rm -rf "${AGENT_CONFIG_DIR}/npm/node_modules/pi-lean-ctx"

# Eliminar comandos
rm -f "${AGENT_CONFIG_DIR}/bin/eurecatagent"
rm -f "${AGENT_CONFIG_DIR}/bin/pi"
rmdir "${AGENT_CONFIG_DIR}/bin" 2>/dev/null || true

rmdir "${AGENT_CONFIG_DIR}/extensions" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}/themes" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}/agents" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}/chains" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}/skills" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}/npm/node_modules/@catdaemon" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}/npm/node_modules" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}/npm" 2>/dev/null || true
rmdir "${AGENT_CONFIG_DIR}" 2>/dev/null || true
rmdir "${HOME}/.pi" 2>/dev/null || true

echo ""
echo -e "${YELLOW}Verifying removal...${NC}"
if command -v pi &>/dev/null; then
	echo -e "  ${RED}✗${NC} pi sigue disponible en el PATH"
else
	echo -e "  ${GREEN}✓${NC} pi eliminado del PATH"
fi
if [ -d "${AGENT_CONFIG_DIR}" ]; then
	echo -e "  ${YELLOW}⚠${NC} ${AGENT_CONFIG_DIR} aún existe (pueden quedar residuos)"
else
	echo -e "  ${GREEN}✓${NC} Configuración eliminada de ${AGENT_CONFIG_DIR}"
fi
echo ""
echo -e "${GREEN}[OK] EURECATagent uninstalled${NC}"
echo ""
echo -e "${YELLOW}Other package managers: pnpm remove -g @earendil-works/pi-coding-agent / yarn global remove ... / bun uninstall -g ...${NC}"
echo ""
