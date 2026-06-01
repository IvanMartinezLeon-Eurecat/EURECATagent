# Guía detallada de instalación y troubleshooting

Documento técnico para instalar, validar y diagnosticar el stack de **EURECATagent**.

Este archivo complementa `install/README.md`:

- `README.md` explica el flujo principal y resume el routing recomendado
- `SETUP_GUIDE.md` resuelve casos de instalación, validación y problemas frecuentes

---

## Tabla de contenidos

- [Cuándo usar esta guía](#cuándo-usar-esta-guía)
- [Requisitos](#requisitos)
- [Instalación recomendada](#instalación-recomendada)
- [Instalación manual y límites](#instalación-manual-y-límites)
- [Validación paso a paso](#validación-paso-a-paso)
- [Diagnóstico](#diagnóstico)
- [Problemas frecuentes](#problemas-frecuentes)
- [Checklist de soporte](#checklist-de-soporte)

---

## Cuándo usar esta guía

Usa este documento si necesitas alguna de estas tareas:

- instalar el stack en una máquina nueva
- entender qué valida realmente `verify.*`
- diagnosticar por qué `eurecatagent` no aparece en PATH
- revisar por qué falta `code intelligence` o `context-mode`
- confirmar si el router híbrido está funcionando correctamente

Si solo quieres empezar rápido, usa `install/README.md`.

---

## Requisitos

### Requisitos mínimos

- Node.js `>= 18`
- npm disponible en PATH
- conexión a internet para descargar paquetes npm
- permisos de escritura sobre el home del usuario

### Comprobación mínima

```bash
node --version
npm --version
```

Si alguno de los dos comandos falla, instala Node.js desde:

- https://nodejs.org/

---

## Instalación recomendada

### Linux / macOS

```bash
cd install
bash install.sh
```

### Windows PowerShell

```powershell
cd install
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

### Windows CMD

```bat
cd install
install.bat
```

### Qué hace el instalador

1. instala `@earendil-works/pi-coding-agent`
2. copia `config/agent/*` a `~/.pi/agent`
3. instala:
   - subagentes
   - adaptador MCP
   - code intelligence
   - Lean Context (compresión de tokens)
4. configura `context-mode`
5. deja disponible la extensión `ai-router`
6. crea o actualiza el comando `eurecatagent` (y `pi` como alias)

---

## Instalación manual y límites

> ⚠ No recomendada. Prefiere el instalador automático (un solo comando curl/iwr).

La instalación manual mínima instala los paquetes base (agente principal, subagentes, adaptador MCP, code intelligence y Lean Context). Ejecuta los comandos equivalentes que aparecen en los scripts de `install/`.

### Limitación importante

Este camino instala paquetes, pero no garantiza por sí solo que tu entorno quede alineado con este repositorio.

En particular, no asegura:

- copia completa de `config/agent/`
- `mcp.json` con `context-mode`
- extensiones locales como `ai-router`
- skills y tema EURECAT

Si buscas una instalación fiel a este repo, usa el instalador automático.

---

## Validación paso a paso

### 1. Validación del sistema

```bash
node --version
npm --version
pi --version
```

Qué debería pasar:
- `node` responde
- `npm` responde
- `pi` responde

### 2. Validación de paquetes Pi

```bash
pi list
```

Debe aparecer al menos:
- `subagentes`
- `adaptador MCP`
- `code intelligence`

### 3. Validación de configuración copiada

#### Linux / macOS

```bash
ls ~/.pi/agent
ls ~/.pi/agent/extensions
```

#### Windows PowerShell

```powershell
Get-ChildItem $HOME/.pi/agent
Get-ChildItem $HOME/.pi/agent/extensions
```

Debe existir, como mínimo:
- `~/.pi/agent/settings.json`
- `~/.pi/agent/mcp.json`
- `~/.pi/agent/extensions/ai-router.ts`
- `~/.pi/agent/agents/generic-context-builder.md`
- `~/.pi/agent/agents/generic-planner.md`
- `~/.pi/agent/agents/generic-worker.md`
- `~/.pi/agent/agents/generic-reviewer.md`
- `~/.pi/agent/agents/generic-parallel-review.md`
- `~/.pi/agent/chains/generic-discovery.chain.md`
- `~/.pi/agent/chains/generic-implement-safe.chain.md`
- `~/.pi/agent/chains/generic-research-and-plan.chain.md`

### 4. Validación automática con scripts

#### Linux / macOS

```bash
cd install
bash verify.sh
```

#### Windows PowerShell

```powershell
cd install
.\verify.ps1
```

#### Windows CMD

```bat
cd install
verify.bat
```

---

## Diagnóstico

Una vez instalado, entra en cualquier repositorio y ejecuta:

```text
/router-status
/code-intelligence-doctor
/enable-code-intelligence
/mcp
```

### Qué valida cada comando

#### `/router-status`
Confirma si el entorno detecta:
- tipo de repositorio
- `code-intelligence`
- `subagentes`
- `context-mode`
- política de routing activa

#### `/code-intelligence-doctor`
Comprueba que Code Intelligence puede funcionar correctamente en el entorno actual.

#### `/enable-code-intelligence`
Activa el repositorio actual para indexación y análisis estructural.

#### `/mcp`
Permite verificar que `context-mode` está disponible y que sus tools `ctx_` pueden invocarse.

---

## Problemas frecuentes

### `node: command not found` o `npm: command not found`

Causa probable:
- Node.js no está instalado
- PATH del sistema no está actualizado

Acción:
1. instala Node.js desde https://nodejs.org/
2. cierra y reabre la terminal
3. vuelve a ejecutar:

```bash
node --version
npm --version
```

### `pi: command not found` después de instalar

Causa probable:
- la terminal no ha recargado PATH
- el comando `eurecatagent` no está en el PATH actual

Acción en Linux/macOS:

```bash
source ~/.profile || true
source ~/.bashrc || true
source ~/.zshrc || true
which pi
```

Si sigue fallando, reejecuta `bash install.sh`.

### `pi list` no muestra `code intelligence`

Causa probable:
- instalación incompleta
- fallo durante `pi install`

Acción:
1. reejecuta el instalador de la plataforma
2. vuelve a comprobar:

```bash
pi list
```

### `context-mode` no aparece en `/mcp`

Causa probable:
- `mcp.json` no fue copiado correctamente
- `context-mode` no está definido en la configuración activa

Comprobación:

```bash
grep -n 'context-mode' ~/.pi/agent/mcp.json
```

Si no aparece, reejecuta el instalador.

### `/enable-code-intelligence` falla

Causa probable:
- el repo no está listo para indexarse todavía
- hay un problema local de permisos o configuración

Acción:
1. ejecuta antes `/code-intelligence-doctor`
2. revisa permisos de escritura en el repo
3. vuelve a lanzar `/enable-code-intelligence`

### El router funciona, pero no recomienda `code_intelligence_*`

Causa probable:
- el prompt no ha sido clasificado como tarea estructural
- el repositorio aún no tiene Code Intelligence activado

Acción:
1. ejecuta `/router-status`
2. ejecuta `/code-intelligence-doctor`
3. activa el repo con `/enable-code-intelligence`
4. revisa la sección de routing en `install/README.md`

### Los scripts funcionan, pero la experiencia no coincide con EURECAT

Causa probable:
- hubo instalación manual parcial
- `config/agent/` no se copió o se mezcló con una configuración previa

Acción:
1. revisa el contenido de `~/.pi/agent`
2. confirma que existen `settings.json`, `mcp.json`, `extensions/`, `agents/`, `chains/`, `skills/` y `themes/`, y que dentro de `agents/` y `chains/` están los artefactos genéricos instalados por EURECATagent
3. reejecuta el instalador automático si falta algo

---

## Checklist de soporte

Antes de pedir ayuda, recopila esta información:

### Sistema
- sistema operativo y versión
- salida de `node --version`
- salida de `npm --version`
- salida de `pi --version`

### Pi
- salida de `pi list`
- existencia de `~/.pi/agent/settings.json`
- existencia de `~/.pi/agent/mcp.json`
- existencia de `~/.pi/agent/extensions/ai-router.ts`
- existencia de `~/.pi/agent/agents/generic-context-builder.md`
- existencia de `~/.pi/agent/agents/generic-planner.md`
- existencia de `~/.pi/agent/agents/generic-worker.md`
- existencia de `~/.pi/agent/agents/generic-reviewer.md`
- existencia de `~/.pi/agent/agents/generic-parallel-review.md`
- existencia de `~/.pi/agent/chains/generic-discovery.chain.md`
- existencia de `~/.pi/agent/chains/generic-implement-safe.chain.md`
- existencia de `~/.pi/agent/chains/generic-research-and-plan.chain.md`

### Una vez arrancado
- resultado de `/router-status`
- resultado de `/code-intelligence-doctor`
- si `/mcp` muestra `context-mode`

Con esta información, la mayoría de problemas se pueden reproducir y diagnosticar más rápido.
