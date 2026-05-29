# Instalación de EURECATagent

Guía principal para instalar el entorno **Pi + configuración EURECAT** desde este repositorio.

Este directorio contiene los scripts y documentos necesarios para dejar preparado un entorno homogéneo de trabajo con:

- **Pi** como agente base
- **pi-subagents** para delegación y coordinación entre agentes
- **pi-mcp-adapter** para integración MCP
- **@catdaemon/pi-code-intelligence** para búsqueda semántica e impacto
- **context-mode** para salidas grandes y contexto pesado
- **ai-router** para routing híbrido según el tipo de tarea
- subagentes y chains genéricas reutilizables entre proyectos

> Si vienes por primera vez al proyecto, puedes leer antes el `../README.md` de la raíz para entender la arquitectura completa del repositorio.

---

## Tabla de contenidos

- [Qué hace esta instalación](#qué-hace-esta-instalación)
- [Qué se copia al entorno del usuario](#qué-se-copia-al-entorno-del-usuario)
- [Requisitos previos](#requisitos-previos)
- [Instalación rápida](#instalación-rápida)
- [Instalación manual mínima](#instalación-manual-mínima)
- [Primer arranque de Pi](#primer-arranque-de-pi)
- [Flujo recomendado tras instalar](#flujo-recomendado-tras-instalar)
- [Resumen del routing híbrido](#resumen-del-routing-híbrido)
- [Subagentes y chains genéricas incluidas](#subagentes-y-chains-genéricas-incluidas)
- [Verificación](#verificación)
- [Documentación relacionada](#documentación-relacionada)
- [Notas operativas](#notas-operativas)

---

## Qué hace esta instalación

Los scripts de este directorio realizan estas acciones:

1. Instalan `@earendil-works/pi-coding-agent` globalmente.
2. Copian `config/agent/*` a `~/.pi/agent` o `%USERPROFILE%\.pi\agent`.
3. Instalan y activan:
   - `pi-subagents`
   - `pi-mcp-adapter`
   - `@catdaemon/pi-code-intelligence`
4. Configuran `context-mode` en `mcp.json`.
5. Dejan disponible la extensión `ai-router`.
6. Preparan un launcher `pi` orientado a contexto por proyecto.

El objetivo no es solo “tener Pi instalado”, sino disponer de una **base de trabajo coherente para EURECAT**.

---

## Qué se copia al entorno del usuario

La configuración fuente vive en:

- `../config/agent/`

Y se copia al entorno del usuario incluyendo, entre otros elementos:

- `settings.json`
- `mcp.json`
- `APPEND_SYSTEM.md`
- `extensions/`
- `agents/`
- `chains/`
- `skills/`
- `themes/`

Esto significa que los scripts de `install/` son la puerta de entrada, pero el comportamiento final del agente depende principalmente de la configuración mantenida en `config/agent/`.

---

## Requisitos previos

### Requisitos mínimos

- **Node.js** `>= 18.0.0`
- **npm** disponible en PATH
- conexión a internet para descargar paquetes npm

### Comprobación rápida

```bash
node --version
npm --version
```

---

## Instalación con un solo comando (curl / iwr)

Instala EURECATagent sin necesidad de clonar el repositorio.

### macOS / Linux / Windows (Git Bash / WSL)

```bash
curl -fsSL https://raw.githubusercontent.com/eurecat/EURECATagent/main/install.sh | sh
```

> También funciona en Windows si usas **Git Bash** o **WSL**.

### Windows PowerShell

```powershell
# Ejecutar como Administrador (recomendado) o usuario
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
iwr -useb https://raw.githubusercontent.com/eurecat/EURECATagent/main/install.ps1 | iex
```

### Windows CMD

```bat
curl -fsSL https://raw.githubusercontent.com/eurecat/EURECATagent/main/install.bat -o install.bat && install.bat
```

### Instalar una versión específica

```bash
# Por variable de entorno (Unix)
INSTALL_VERSION=v1.0.0 curl -fsSL https://raw.githubusercontent.com/eurecat/EURECATagent/main/install.sh | sh
```

```powershell
# Versión específica en PowerShell
$env:INSTALL_VERSION='v1.0.0'; iwr -useb https://raw.githubusercontent.com/eurecat/EURECATagent/main/install.ps1 | iex
```

---

## Instalación desde el repositorio

Si ya tienes clonado el repositorio:

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

### Windows Command Prompt

```bat
cd install
install.bat
```

---

## Instalación manual mínima

Si quieres instalar los paquetes base manualmente:

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
pi install npm:pi-subagents
pi install npm:pi-mcp-adapter
pi install npm:@catdaemon/pi-code-intelligence
```

> Importante: esta instalación manual cubre los paquetes, pero **no sustituye completamente** a los scripts de este repositorio, porque no copia por sí sola toda la configuración EURECAT. Si quieres dejar también `~/.pi/agent` alineado con este proyecto, usa el instalador automático.

---

## Primer arranque de Pi

Una vez terminada la instalación:

```bash
cd /ruta/a/tu/proyecto
pi
```

Dentro de Pi:

```text
/login
/router-status
/code-intelligence-doctor
/enable-code-intelligence
/mcp
```

---

## Flujo recomendado tras instalar

### 1. Confirmar routing y capacidades

```text
/router-status
```

Esto te indica si el entorno detecta correctamente:
- `code-intelligence`
- `pi-subagents`
- `context-mode`
- tipo de repositorio
- política de routing activa

### 2. Activar Code Intelligence en el repo actual

```text
/code-intelligence-doctor
/enable-code-intelligence
```

### 3. Usar el flujo adecuado según la tarea

#### Descubrimiento estructural
Usa primero:

```text
code_intelligence_search
code_intelligence_impact
code_intelligence_analyze_changes
```

Para preguntas como:
- dónde está implementada una lógica
- qué consumidores se verán afectados
- qué tests revisar antes de tocar un archivo compartido
- qué patrones existentes conviene reutilizar

#### Subagentes y workflows genéricos
Cuando el trabajo sea reutilizable entre proyectos, delega con la capa genérica instalada globalmente.

Casos típicos:
- discovery antes de editar
- planificar antes de implementar
- implementación segura con single writer
- review puntual o review paralelo
- investigación externa + contexto local + plan

Ejemplos:

```text
/run-chain generic-discovery -- entender esta parte del código
/run-chain generic-implement-safe -- aplicar este cambio con validación
/run generic-parallel-review "Revisa este cambio con foco en corrección, cobertura de tests y simplicidad"
```

#### Edición puntual
Cuando ya conoces los archivos relevantes, usa:

```text
read
edit
write
bash
```

#### Logs y salidas pesadas
Para outputs grandes o análisis que no conviene volcar en conversación, usa:

```text
/mcp
```

Y después las tools `ctx_` de `context-mode`.

---

## Resumen del routing híbrido

La instalación deja preparado un flujo híbrido con tres capas:

- `code_intelligence_*` para descubrimiento estructural e impacto
- `context-mode` para logs, salidas grandes y procesamiento pesado
- tools nativas de Pi (`read`, `edit`, `write`, `bash`) para implementación puntual

### Cuándo usar cada capa

#### Structural mode
Para preguntas como:
- dónde está implementado algo
- qué archivos están relacionados
- qué tests o consumidores pueden romperse
- qué patrón local conviene reutilizar

Empieza por:

```text
/code-intelligence-doctor
/enable-code-intelligence
code_intelligence_search
code_intelligence_impact
code_intelligence_analyze_changes
```

#### Review mode
Para revisión de cambios, calidad o seguridad:

```text
/code-intelligence-review
code_intelligence_analyze_changes
```

Y después lectura puntual en los archivos shortlistados.

#### Debug-heavy mode
Para logs o outputs grandes:

```text
/mcp
```

Y luego tools `ctx_` de `context-mode`.

#### General mode
Cuando ya sabes qué tocar:

```text
read
edit
write
bash
```

### Intención del diseño

La idea no es sustituir las tools nativas de Pi, sino ordenar el flujo:

- `code-intelligence` decide dónde mirar primero
- `context-mode` evita inundar la conversación con salida pesada
- las tools nativas ejecutan la implementación final

---

## Subagentes y chains genéricas incluidas

Esta configuración instala `pi-subagents` y además copia una capa genérica reutilizable para cualquier proyecto en:

- `~/.pi/agent/agents/`
- `~/.pi/agent/chains/`

### Subagentes genéricos

- `generic-context-builder` → construye contexto compacto y accionable antes de planificar o editar
- `generic-planner` → crea un plan mínimo y ejecutable
- `generic-worker` → implementa cambios pequeños y validados como **single writer**
- `generic-reviewer` → revisa planes, diffs e implementación con evidencia
- `generic-parallel-review` → orquesta revisión paralela con varios ángulos y devuelve una síntesis única

### Chains genéricas

- `generic-discovery` → `scout` + `generic-context-builder`
- `generic-implement-safe` → `scout` + `generic-planner` + `generic-worker` + `generic-reviewer`
- `generic-research-and-plan` → `researcher` + `scout` + `generic-planner`

### Cuándo usarlas

#### `generic-discovery`
Úsala cuando todavía no sabes:
- dónde está implementada una funcionalidad
- qué archivos deberías revisar primero
- qué superficie de impacto tiene un cambio

Ejemplo:

```text
/run-chain generic-discovery -- entender el flujo de autenticación
```

#### `generic-implement-safe`
Úsala para cambios normales o medianos donde quieras un flujo seguro con un solo writer.

Ejemplo:

```text
/run-chain generic-implement-safe -- aplicar este refactor siguiendo los patrones existentes
```

#### `generic-research-and-plan`
Úsala cuando necesites combinar documentación externa y contexto local antes de implementar.

Ejemplo:

```text
/run-chain generic-research-and-plan -- evaluar cómo integrar esta librería en el proyecto
```

#### `generic-reviewer`
Úsalo para revisión puntual de un diff, plan o implementación.

Ejemplo:

```text
/run generic-reviewer "Revisa este diff con foco en regresiones y validación"
```

#### `generic-parallel-review`
Úsalo cuando quieras una revisión más fuerte con varios ángulos en paralelo.

Ángulos por defecto:
- corrección y regresiones
- tests y validación
- simplicidad y mantenibilidad

Si el prompt habla de auth, permisos, secretos, privacidad o compliance, el tercer ángulo pasa a ser de seguridad.

Ejemplo:

```text
/run generic-parallel-review "Revisa este cambio con foco en regresiones, tests y complejidad"
```

### Relación con `ai-router`

La extensión `ai-router` no lanza estos subagentes automáticamente, pero ahora sí puede sugerirlos cuando detecta prompts de:

- descubrimiento estructural amplio
- implementación multi-fase
- revisión profunda
- investigación con referencias externas

La activación sigue siendo explícita: tú decides cuándo ejecutar `/run`, `/run-chain` o pedirlo en lenguaje natural.

---

## Verificación

### Linux / macOS

```bash
cd install
bash verify.sh
```

### Windows PowerShell

```powershell
cd install
.\verify.ps1
```

### Windows CMD

```bat
cd install
verify.bat
```

Las verificaciones comprueban, entre otros puntos:

- presencia de `node`, `npm` y `pi`
- instalación y activación de `pi-subagents`
- instalación y activación de `pi-mcp-adapter`
- instalación y activación de `@catdaemon/pi-code-intelligence`
- presencia de `context-mode` en `~/.pi/agent/mcp.json`
- disponibilidad de la extensión `ai-router`
- presencia de los subagentes genéricos instalados en `~/.pi/agent/agents`
- presencia de las chains genéricas instaladas en `~/.pi/agent/chains`

---

## Documentación relacionada

### Dentro de `install/`

- `README.md` → guía principal de instalación, routing y uso de subagentes/chains genéricas
- `SETUP_GUIDE.md` → guía detallada, validación y troubleshooting

### Referencias externas

- Pi: https://pi.dev/docs/latest
- pi-subagents: https://pi.dev/packages/pi-subagents
- pi-mcp-adapter: https://pi.dev/packages/pi-mcp-adapter
- pi-code-intelligence: https://pi.dev/packages/@catdaemon/pi-code-intelligence

---

## Notas operativas

- Los instaladores usan `npm install -g --ignore-scripts` para reducir la superficie de ejecución innecesaria.
- La configuración EURECAT añade reglas operativas al agente, incluyendo comunicación en castellano y restricciones de escritura fuera del directorio activo sin permiso explícito.
- `@catdaemon/pi-code-intelligence` se usa para descubrimiento estructural, impacto, review y learnings por repositorio.
- `context-mode` sigue siendo la vía recomendada para logs grandes, outputs pesados y procesamiento de contexto extenso.
- La extensión `ai-router` no sustituye a las tools nativas de Pi: ayuda a decidir **qué mirar primero** y **con qué herramienta conviene empezar**.

---

## Publicar un release

Para que el instalador `curl | sh` funcione, los scripts deben estar disponibles en una URL.

### Opción 1: Automático con GitHub Actions (recomendado)

El workflow `.github/workflows/release.yml` ya está configurado. Solo tienes que:

```bash
git tag v1.2.3
git push origin v1.2.3
```

Automáticamente se:
1. Genera el tarball
2. Crea un GitHub Release con los archivos adjuntos
3. Genera notas de release automáticas

### Opción 2: Manual desde terminal

```bash
# 1. Generar el tarball
bash scripts/build-release.sh v1.2.3

# 2. Crear tag y subirlo
git tag v1.2.3
git push origin v1.2.3

# 3. Crear release con gh CLI
gh release create v1.2.3 \
  dist/eurecatagent-v1.2.3.tar.gz \
  dist/eurecatagent.tar.gz \
  install/install.sh \
  install/install.ps1 \
  install/install.bat \
  --title "v1.2.3" \
  --notes "..."
```

### Opción 3: GitHub RAW (desarrollo)

Sin releases, apuntando directamente a `main`:

```bash
curl -fsSL https://raw.githubusercontent.com/eurecat/EURECATagent/main/install.sh | sh
```

> ⚠ **RAW no está pensado para producción.** Para instalaciones reproducibles, usa siempre un tag versionado.

### Opción 3: Dominio propio

Con un dominio propio (`eurecatagent.dev`), sirve el script desde un CDN o haz un redirect a GitHub RAW.

---

## Resumen rápido

Si quieres el flujo mínimo recomendado:

1. ejecuta el instalador de tu plataforma
2. valida con `verify.*`
3. abre `pi` dentro de un proyecto
4. ejecuta `/router-status`
5. activa Code Intelligence en el repo
6. prueba al menos uno de estos flujos: `generic-discovery` o `generic-implement-safe`
7. usa `code_intelligence_*` antes de explorar a ciegas
8. usa `context-mode` para salidas grandes
