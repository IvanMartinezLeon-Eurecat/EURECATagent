# EURECATagent

Repositorio de **instalación, configuración y onboarding técnico** para un entorno de trabajo basado en **Pi** dentro de EURECAT.

Su función principal es dejar preparado un agente de desarrollo con una configuración homogénea, orientada a:

- descubrimiento estructural con **Code Intelligence**
- gestión de contexto pesado con **context-mode**
- automatización y delegación con **pi-subagents**
- extensibilidad mediante **extensions**, **skills** y **themes** propios

> Este repo no contiene una aplicación de negocio. Contiene la base para instalar y operar un entorno de Pi adaptado a la forma de trabajo de EURECAT.

---

## Tabla de contenidos

- [Objetivo](#objetivo)
- [Qué instala y configura](#qué-instala-y-configura)
- [Arquitectura del repositorio](#arquitectura-del-repositorio)
- [Mapa rápido del repo](#mapa-rápido-del-repo)
- [Estructura final recomendada](#estructura-final-recomendada)
- [Quick start para desarrolladores](#quick-start-para-desarrolladores)
- [Flujo recomendado dentro de Pi](#flujo-recomendado-dentro-de-pi)
- [Cómo funciona la configuración](#cómo-funciona-la-configuración)
- [Componentes técnicos clave](#componentes-técnicos-clave)
- [Scripts disponibles](#scripts-disponibles)
- [Verificación y diagnóstico](#verificación-y-diagnóstico)
- [Prueba de concepto incluida](#prueba-de-concepto-incluida)
- [Documentación interna](#documentación-interna)
- [Requisitos](#requisitos)

---

## Objetivo

Estandarizar cómo se instala y usa Pi en entornos EURECAT.

Este repositorio evita que cada desarrollador tenga que configurar manualmente:

- paquetes adicionales de Pi
- MCPs necesarios
- extensiones de routing
- subagentes y chains genéricas reutilizables
- skills internas
- tema visual y preferencias básicas
- flujo recomendado para tareas de análisis, review y edición

El resultado esperado es que dos desarrolladores distintos, tras ejecutar el instalador, trabajen con una experiencia casi idéntica.

---

## Qué instala y configura

Los scripts de instalación dejan preparado lo siguiente:

### Binario base
- `@earendil-works/pi-coding-agent`

### Paquetes de Pi
- `pi-subagents`
- `pi-mcp-adapter`
- `@catdaemon/pi-code-intelligence`

### Configuración de agente
Se copia `config/agent/*` a `~/.pi/agent`, incluyendo:

- `settings.json`
- `mcp.json`
- `APPEND_SYSTEM.md`
- `extensions/`
- `agents/`
- `chains/`
- `skills/`
- `themes/`

### Integraciones operativas
- `context-mode` como MCP lazy-loaded
- extensión `ai-router` para routing híbrido
- launcher `pi` orientado a contexto por proyecto

---

## Arquitectura del repositorio

El repositorio está organizado en tres capas:

### 1. Capa de instalación: `install/`
Contiene scripts multiplataforma y documentación operativa.

Responsabilidades:
- instalar Pi y paquetes asociados
- copiar configuración al home del usuario
- dejar disponible el wrapper `pi`
- validar instalación y entorno
- documentar troubleshooting y flujo recomendado

### 2. Capa de configuración: `config/agent/`
Contiene la configuración real que ejecutará el agente una vez instalada.

Responsabilidades:
- definir comportamiento base del agente
- activar MCPs
- inyectar instrucciones de sistema adicionales
- registrar extensiones y habilidades reutilizables
- registrar subagentes y chains genéricas reutilizables
- aplicar identidad visual EURECAT

### 3. Capa de demostración: `poc/`
Contiene ejemplos controlados para enseñar cómo usar capacidades avanzadas del entorno.

Responsabilidades:
- mostrar relaciones entre archivos para Code Intelligence
- ofrecer prompts y casos de prueba reproducibles
- servir de material de onboarding

---

## Mapa rápido del repo

```text
.
├── config/
│   └── agent/
│       ├── APPEND_SYSTEM.md          # reglas de sistema añadidas al agente
│       ├── settings.json             # ajustes base del agente
│       ├── mcp.json                  # definición MCP, incluyendo context-mode
│       ├── extensions/
│       │   ├── ai-router.ts          # routing híbrido según tipo de prompt
│       │   └── eurecat-header.ts     # personalización visual/comportamiento UI
│       ├── agents/                   # subagentes genéricos reutilizables
│       ├── chains/                   # workflows genéricos reutilizables
│       ├── skills/                   # skills especializadas EURECAT
│       └── themes/                   # tema visual del agente
├── install/
│   ├── install.sh                    # instalador Linux/macOS
│   ├── install.ps1                   # instalador Windows PowerShell
│   ├── install.bat                   # instalador Windows CMD
│   ├── verify.*                      # validación post-instalación
│   ├── uninstall.*                   # desinstalación
│   ├── templates/                    # wrappers y plantillas auxiliares
│   └── *.md                          # guías operativas
└── poc/
    └── code-intelligence-demo/       # ejemplo guiado para Code Intelligence
```

---

## Estructura final recomendada

Después de la limpieza documental, la estructura recomendada del repositorio queda así:

```text
.
├── README.md                        # visión general, onboarding y arquitectura
├── config/
│   └── agent/                      # configuración fuente que se copia a ~/.pi/agent
├── install/
│   ├── README.md                   # guía principal de instalación y routing
│   ├── SETUP_GUIDE.md              # validación, troubleshooting y diagnóstico
│   ├── install.*                   # instaladores por plataforma
│   ├── verify.*                    # scripts de verificación
│   ├── uninstall.*                 # scripts de desinstalación
│   └── templates/                  # wrappers auxiliares usados por los instaladores
└── poc/
    └── code-intelligence-demo/     # demo guiada de Code Intelligence
```

### Criterio de mantenimiento

La idea es mantener **pocos documentos y con responsabilidades claras**:

- `README.md` explica **qué es el repo y cómo orientarse**.
- `install/README.md` explica **cómo instalarlo y cómo usar el routing básico**.
- `install/SETUP_GUIDE.md` explica **cómo validarlo y diagnosticar problemas**.

Cualquier nueva documentación debería añadirse solo si aporta contenido no cubierto por estos tres documentos.

---

## Quick start para desarrolladores

### 1. Verifica prerequisitos

```bash
node --version
npm --version
```

Requisitos mínimos:
- Node.js `>= 18`
- npm disponible en PATH

### 2. Ejecuta el instalador

#### Linux / macOS

```bash
cd install
bash install.sh
```

#### Windows PowerShell

```powershell
cd install
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

#### Windows CMD

```bat
cd install
install.bat
```

### 3. Valida la instalación

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

### 4. Abre Pi en un proyecto

```bash
cd /ruta/a/tu/proyecto
pi
```

---

## Flujo recomendado dentro de Pi

Una vez dentro de Pi, el flujo operativo recomendado es:

```text
/login
/router-status
/code-intelligence-doctor
/enable-code-intelligence
/mcp
```

### Para descubrimiento estructural
Usa primero:

- `code_intelligence_search`
- `code_intelligence_impact`
- `code_intelligence_analyze_changes`

Úsalo para preguntas como:
- dónde está implementado algo
- qué archivos dependen de un módulo
- qué tests o consumidores pueden romperse
- qué patrones locales existen ya en el repo

### Para subagentes y workflows genéricos
Usa los agentes y chains genéricas instaladas globalmente cuando quieras delegar trabajo reutilizable entre proyectos.

Ejemplos útiles:

- `generic-context-builder` → construir contexto accionable antes de planificar
- `generic-planner` → convertir contexto en un plan mínimo
- `generic-worker` → implementar como single writer
- `generic-reviewer` → revisar un diff, plan o implementación
- `generic-parallel-review` → revisión paralela con varios ángulos
- `generic-discovery` → discovery antes de editar
- `generic-implement-safe` → scout + plan + implementación + review
- `generic-research-and-plan` → referencias externas + contexto local + plan

Ejemplos de uso:

```text
/run-chain generic-discovery -- entender esta parte del código
/run-chain generic-implement-safe -- aplicar este cambio con validación
/run generic-parallel-review "Revisa este cambio con foco en regresiones, validación y mantenibilidad"
```

### Para edición puntual
Cuando ya conoces los archivos relevantes, usa:

- `read`
- `edit`
- `write`
- `bash`

### Para logs o salidas grandes
Usa `context-mode` mediante tools `ctx_` accesibles por MCP.

Es el flujo recomendado para:
- logs extensos
- salidas de tests grandes
- búsquedas amplias
- agregación o parsing de información grande

---

## Cómo funciona la configuración

### `config/agent/settings.json`
Define ajustes base del agente, por ejemplo:
- tema activo
- preferencias de arranque
- opciones visuales

### `config/agent/mcp.json`
Declara servidores MCP. En este repo destaca:
- `context-mode`, cargado con `npx -y context-mode`

### `config/agent/APPEND_SYSTEM.md`
Añade reglas de comportamiento del agente. Entre ellas:
- comunicación siempre en castellano
- código técnico en inglés
- obligación de pedir permiso antes de escribir fuera del directorio activo

### `config/agent/extensions/ai-router.ts`
Es una pieza clave del repositorio.

Responsabilidades principales:
- detectar capacidad del entorno (`router_status`)
- clasificar el prompt en modos como `general`, `structural`, `review` y `debug-heavy`
- inyectar reglas de routing en el system prompt
- sugerir `code_intelligence_*` antes de hacer exploración amplia
- sugerir subagentes y chains genéricas cuando encajan con la tarea
- advertir cuando conviene usar `context-mode`

---

## Componentes técnicos clave

### `ai-router`
Capa de orquestación ligera para decidir qué herramienta conviene usar antes.

Aporta:
- heurística de clasificación de prompts
- status contextual en UI
- reglas de routing híbrido
- protección frente a búsquedas amplias innecesarias

### `@catdaemon/pi-code-intelligence`
Añade capacidades indexadas por repositorio para:
- búsqueda semántica
- análisis de impacto
- análisis de cambios
- review asistida
- learnings durables

### `context-mode`
Se usa como complemento cuando el problema no es “qué editar”, sino “cómo analizar mucho contexto sin saturar la conversación”.

Casos típicos:
- resumir logs
- procesar salidas grandes de herramientas
- indexar documentación o resultados intermedios
- consultar memoria contextual almacenada

### `pi-subagents`
Permite delegar o paralelizar trabajo con subagentes.

Útil para:
- análisis en paralelo
- cadenas de revisión/planificación
- handoffs controlados
- tareas multi-fase con coordinación
- workflows genéricos reutilizables entre proyectos

En esta configuración se complementa con agentes y chains genéricas instaladas desde `config/agent/agents/` y `config/agent/chains/`.

Set incluido actualmente:
- agentes: `generic-context-builder`, `generic-planner`, `generic-worker`, `generic-reviewer`, `generic-parallel-review`
- chains: `generic-discovery`, `generic-implement-safe`, `generic-research-and-plan`

### Skills EURECAT
El repo incorpora skills para tareas específicas:
- `architecture`
- `documentation`
- `eurecat-brain`
- `fix`
- `learn`
- `review`
- `spec-driven-development`
- `status`
- `sync`
- `testing`
- `ux`

---

## Scripts disponibles

### Instalación
- `install/install.sh`
- `install/install.ps1`
- `install/install.bat`

### Verificación
- `install/verify.sh`
- `install/verify.ps1`
- `install/verify.bat`

### Desinstalación
- `install/uninstall.sh`
- `install/uninstall.ps1`
- `install/uninstall.bat`

Todos los scripts están pensados para uso directo, sin depender de tooling adicional del repo.

---

## Verificación y diagnóstico

Además de los scripts `verify.*`, el stack recomienda estas comprobaciones dentro de Pi:

```text
/router-status
/code-intelligence-doctor
/enable-code-intelligence
/mcp
```

Qué valida cada una:

- `/router-status`: confirma si el routing híbrido detecta correctamente `code-intelligence`, `pi-subagents` y `context-mode`
- `/code-intelligence-doctor`: verifica la disponibilidad de Code Intelligence
- `/enable-code-intelligence`: activa indexación local para el repo actual
- `/mcp`: comprueba accesibilidad de MCPs y tools externas

---

## Prueba de concepto incluida

El repositorio incluye una demo técnica en:

- `poc/code-intelligence-demo/`

Su objetivo es enseñar, con un mini dominio de checkout, cómo usar:

- `code_intelligence_search`
- `code_intelligence_impact`
- `code_intelligence_analyze_changes`

Punto de entrada recomendado:
- `poc/code-intelligence-demo/README.md`

---

## Documentación interna

Dentro de `install/` se mantiene solo la documentación operativa necesaria:

- `install/README.md` → guía principal de instalación, routing y uso de subagentes/chains genéricas
- `install/SETUP_GUIDE.md` → instalación detallada, validación y troubleshooting

---

## Requisitos

### Sistema
- Linux, macOS o Windows
- Node.js `>= 18`
- npm `>= 8`

### Operativos
- conexión a internet para instalar paquetes npm
- permisos de escritura sobre `~/.pi/agent`
- terminal compatible con el script de la plataforma correspondiente

---

## Resumen para onboarding

Si acabas de llegar al proyecto, el recorrido mínimo recomendado es:

1. lee este `README.md`
2. ejecuta el instalador de tu plataforma en `install/`
3. ejecuta el verificador correspondiente
4. abre Pi dentro de un proyecto real
5. lanza `/router-status` y activa Code Intelligence
6. revisa `install/README.md` para ver el uso de subagentes y chains genéricas
7. prueba al menos uno de estos flujos: `generic-discovery` o `generic-implement-safe`
8. usa `poc/code-intelligence-demo/` para entender el flujo de análisis

Con eso deberías entender:
- qué instala este repo
- cómo se comporta el agente resultante
- qué herramientas usar primero según el tipo de tarea
- dónde extender la configuración si necesitas evolucionar el stack
