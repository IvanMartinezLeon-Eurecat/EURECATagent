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

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  EURECAT agent                        ║${NC}"
echo -e "${BLUE}║  Uninstallation Script                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if npm is installed
if ! command -v npm &> /dev/null; then
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

echo ""
echo -e "${YELLOW}Removing EURECAT packages...${NC}"

PI_BIN=""
if command -v pi &> /dev/null; then
    PI_BIN="$(command -v pi)"
else
    NPM_GLOBAL_PREFIX="$(npm prefix -g 2>/dev/null || true)"
    if [ -n "${NPM_GLOBAL_PREFIX}" ] && [ -x "${NPM_GLOBAL_PREFIX}/bin/pi" ]; then
        PI_BIN="${NPM_GLOBAL_PREFIX}/bin/pi"
    fi
fi

if [ -n "${PI_BIN}" ]; then
    "${PI_BIN}" remove npm:@catdaemon/pi-code-intelligence || true
    "${PI_BIN}" remove npm:pi-mcp-adapter || true
    "${PI_BIN}" remove npm:pi-subagents || true
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
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  EURECATagent uninstalled successfully!║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ EURECAT configuration removed from ${AGENT_CONFIG_DIR}${NC}"
echo ""

# Check alternative package managers
echo -e "${YELLOW}If you installed EURECATagent with a different package manager:${NC}"
echo "  - pnpm: pnpm remove -g @earendil-works/pi-coding-agent"
echo "  - Yarn: yarn global remove @earendil-works/pi-coding-agent"
echo "  - Bun:  bun uninstall -g @earendil-works/pi-coding-agent"
echo ""
