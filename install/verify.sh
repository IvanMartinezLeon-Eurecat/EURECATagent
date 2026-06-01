#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== EURECATagent Verification ===${NC}"
echo ""

CHECKS_PASSED=0
CHECKS_FAILED=0

check_command() {
    local cmd=$1
    local pretty_name=${2:-$cmd}

    if command -v "$cmd" &> /dev/null; then
        local version=$("$cmd" --version 2>/dev/null || echo "N/A")
        echo -e "${GREEN}✓ $pretty_name${NC}: $version"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ $pretty_name${NC}: No instalado"
        ((CHECKS_FAILED++))
    fi
}

echo -e "${BLUE}== Verificaciones del Sistema ==${NC}"
echo ""
check_command "node" "Node.js"
check_command "npm" "npm"
check_command "pi" "EURECATagent"
check_command "eurecatagent" "EURECATagent CLI"

echo ""
echo -e "${BLUE}== Variables de Entorno (Opcional) ==${NC}"
echo ""
if [ -n "${ANTHROPIC_API_KEY}" ]; then
    echo -e "${GREEN}✓ ANTHROPIC_API_KEY${NC}: Configurada"
    ((CHECKS_PASSED++))
else
    echo -e "${YELLOW}⚠ ANTHROPIC_API_KEY${NC}: No configurada (puedes usar /login en EURECATagent)"
fi

echo ""
echo -e "${BLUE}== Información de EURECATagent ==${NC}"
echo ""

if command -v pi &> /dev/null; then
    AGENT_CONFIG_DIR="${HOME}/.pi/agent"

    if [ -f "${AGENT_CONFIG_DIR}/settings.json" ]; then
        echo -e "${GREEN}✓ Configuración EURECAT${NC}: ${AGENT_CONFIG_DIR}"
        ((CHECKS_PASSED++))
    else
        echo -e "${YELLOW}⚠ Configuración EURECAT${NC}: No encontrada en ${AGENT_CONFIG_DIR}"
    fi

    PI_LIST="$(pi list 2>/dev/null || true)"
    if echo "${PI_LIST}" | grep -q "pi-subagents"; then
        echo -e "${GREEN}✓ Coding Agent${NC}: Instalado y activo"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ Coding Agent${NC}: No detectado en 'pi list'"
        ((CHECKS_FAILED++))
    fi

    if echo "${PI_LIST}" | grep -q "pi-mcp-adapter"; then
        echo -e "${GREEN}✓ MCP Adapter${NC}: Instalado y activo"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ MCP Adapter${NC}: No detectado en 'pi list'"
        ((CHECKS_FAILED++))
    fi

    if echo "${PI_LIST}" | grep -q "@catdaemon/pi-code-intelligence"; then
        echo -e "${GREEN}✓ Code Intelligence${NC}: Instalado y activo"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ Code Intelligence${NC}: No detectado en 'pi list'"
        ((CHECKS_FAILED++))
    fi

    if [ -f "${AGENT_CONFIG_DIR}/mcp.json" ] && grep -q '"context-mode"' "${AGENT_CONFIG_DIR}/mcp.json"; then
        echo -e "${GREEN}✓ context-mode MCP${NC}: Configurado en ${AGENT_CONFIG_DIR}/mcp.json"
        ((CHECKS_PASSED++))
    else
        echo -e "${YELLOW}⚠ context-mode MCP${NC}: No detectado en ${AGENT_CONFIG_DIR}/mcp.json"
    fi

    if [ -f "${AGENT_CONFIG_DIR}/extensions/ai-router.ts" ]; then
        echo -e "${GREEN}✓ ai-router extension${NC}: Instalada"
        ((CHECKS_PASSED++))
    else
        echo -e "${YELLOW}⚠ ai-router extension${NC}: No encontrada en ${AGENT_CONFIG_DIR}/extensions"
    fi

    GENERIC_AGENTS=(
        "generic-context-builder.md"
        "generic-planner.md"
        "generic-worker.md"
        "generic-reviewer.md"
        "generic-parallel-review.md"
    )
    MISSING_GENERIC_AGENTS=0
    for agent_file in "${GENERIC_AGENTS[@]}"; do
        if [ ! -f "${AGENT_CONFIG_DIR}/agents/${agent_file}" ]; then
            ((MISSING_GENERIC_AGENTS++))
        fi
    done
    if [ ${MISSING_GENERIC_AGENTS} -eq 0 ]; then
        echo -e "${GREEN}✓ Subagentes genéricos${NC}: Instalados en ${AGENT_CONFIG_DIR}/agents"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ Subagentes genéricos${NC}: Faltan ${MISSING_GENERIC_AGENTS} archivo(s) en ${AGENT_CONFIG_DIR}/agents"
        ((CHECKS_FAILED++))
    fi

    GENERIC_CHAINS=(
        "generic-discovery.chain.md"
        "generic-implement-safe.chain.md"
        "generic-research-and-plan.chain.md"
    )
    MISSING_GENERIC_CHAINS=0
    for chain_file in "${GENERIC_CHAINS[@]}"; do
        if [ ! -f "${AGENT_CONFIG_DIR}/chains/${chain_file}" ]; then
            ((MISSING_GENERIC_CHAINS++))
        fi
    done
    if [ ${MISSING_GENERIC_CHAINS} -eq 0 ]; then
        echo -e "${GREEN}✓ Chains genéricas${NC}: Instaladas en ${AGENT_CONFIG_DIR}/chains"
        ((CHECKS_PASSED++))
    else
        echo -e "${RED}✗ Chains genéricas${NC}: Faltan ${MISSING_GENERIC_CHAINS} archivo(s) en ${AGENT_CONFIG_DIR}/chains"
        ((CHECKS_FAILED++))
    fi
else
    echo -e "${RED}EURECATagent no está instalado${NC}"
    echo "Ejecuta: bash install.sh"
fi

echo ""
echo -e "${BLUE}== Summary ==${NC}"
echo ""
if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed${NC}"
else
    echo -e "${RED}✗ ${CHECKS_FAILED} check(s) failed — run install.sh first${NC}"
fi
echo ""
