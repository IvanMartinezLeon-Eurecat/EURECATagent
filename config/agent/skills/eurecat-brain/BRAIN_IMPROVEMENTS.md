# 🧠 Plan de Mejora: Brain v1.1 — Scan, Auditoría y Caducidad

**Objetivo:** Elevar el Brain de EurecatAgent a una madurez v1.0 estable  
**Alcance:** 3 nuevas capacidades principales  
**Estimación:** 3-4 sprints  
**Estado:** Especificación (NO IMPLEMENTADO)

---

## 📋 Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Capacidad 1: Scan Automático de Stack](#capacidad-1-scan-automático-de-stack)
3. [Capacidad 2: Auditoría y Revisión](#capacidad-2-auditoría-y-revisión)
4. [Capacidad 3: Caducidad y Ciclo de Vida](#capacidad-3-caducidad-y-ciclo-de-vida)
5. [Nuevos Comandos CLI](#nuevos-comandos-cli)
6. [Cambios de Arquitectura](#cambios-de-arquitectura)
7. [Plan de Implementación](#plan-de-implementación)
8. [Criterios de Aceptación](#criterios-de-aceptación)

---

## Visión General

### Estado Actual

El Brain de EurecatAgent (v1.0) ya tiene:
- ✅ Almacenamiento Markdown en `.eurecatagent/brain/memories/`
- ✅ Metadata básica (id, type, status, platform, area, date)
- ✅ Comandos: `init`, `save`, `context`, `search`
- ✅ Integración con skills (eurecat-brain.ts)

Pero **NO tiene:**
- ❌ Detección automática de stack
- ❌ Auditoría de temporales vencidos
- ❌ Caducidad de workarounds
- ❌ CLI para review, promote, bump

### Estado Destino (v1.1)

Después de las mejoras:
- ✅ `eurecat brain scan` — Detecta stack automáticamente
- ✅ `eurecat brain context --section stack` — Muestra stack detectado
- ✅ `eurecat brain review` — Lista temporales vencidos
- ✅ `eurecat brain promote <id> --status <new>` — Cambia estado
- ✅ `eurecat brain bump <id> --review-after YYYY-MM-DD` — Extiende plazo
- ✅ `eurecat brain context --status temporary` — Filtra por estado
- ✅ Soporte de `review_after` en entradas temporary

---

## Capacidad 1: Scan Automático de Stack

### Propósito

Detectar automáticamente el stack del proyecto (lenguajes, frameworks, librerías) sin intervención manual.

### Inspiración: referencia de mercado

Una solución de referencia detecta:
```
Android (Kotlin, Gradle, KMP, Firebase, Koin, Compose, etc.)
iOS (Swift, CocoaPods, SwiftUI, Alamofire, etc.)
Flutter (Dart, pub, Riverpod, GetX, etc.)
React Native (JavaScript/TypeScript, npm, Redux, Expo, etc.)
KMP (Kotlin, gradle, multiplatform, expect/actual, etc.)
Shared (Git, npm, docker, GitHub Actions, etc.)
```

### Implementación: EurecatAgent

#### Detectores por extensión/archivo

**Detectar por archivos de configuración:**

| Stack | Archivos Detectores |
|-------|-------------------|
| **Web Frontend** | `package.json`, `tsconfig.json`, `webpack.config.js`, `.next/`, `vite.config.js`, `angular.json` |
| **Web Backend** | `go.mod`, `Cargo.toml`, `pyproject.toml`, `requirements.txt`, `pom.xml`, `build.gradle`, `composer.json`, `Gemfile` |
| **iOS** | `Podfile`, `.xcodeproj`, `Package.swift`, `.h`/`.m`/`.swift` files |
| **Android** | `build.gradle.kts`/`build.gradle`, `AndroidManifest.xml`, `.kt`/`.java` files |
| **KMP** | `build.gradle.kts` con `kotlin("multiplatform")`, `expect`/`actual` keywords |
| **Flutter** | `pubspec.yaml`, `.dart` files, `lib/main.dart` |
| **React Native** | `package.json` con `react-native`, `app.json`, `index.js` |
| **Docker** | `Dockerfile`, `docker-compose.yml`, `.dockerignore` |
| **CI/CD** | `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/config.yml` |
| **Python** | `pyproject.toml`, `requirements.txt`, `Pipfile`, `setup.py` |
| **Go** | `go.mod`, `go.sum`, `.go` files |
| **Rust** | `Cargo.toml`, `Cargo.lock`, `.rs` files |
| **Node.js** | `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` |

**Detectar librerías por patrones:**

```
Firebase → buscar "firebase" en package.json, build.gradle, Podfile, pubspec.yaml
Koin → buscar "io.insert-koin" en build.gradle.kts
Compose → buscar "androidx.compose" en build.gradle.kts
SwiftUI → buscar "SwiftUI" en *.swift o Podfile
Riverpod → buscar "riverpod" en pubspec.yaml
Redux → buscar "redux" en package.json
Alamofire → buscar "Alamofire" en Podfile
CocoaPods → existencia de Podfile
Gradle → existencia de build.gradle o build.gradle.kts
```

#### Estructura de `scan.json`

**Nuevo archivo:** `.eurecatagent/brain/scan.json`

```json
{
  "version": "1.0",
  "scanned_at": "2026-05-27T14:30:45Z",
  "project_root": "/Users/user/code/my-app",
  "detected_stacks": {
    "web": {
      "detected": true,
      "type": "frontend",
      "confidence": "high",
      "tech": {
        "JavaScript/TypeScript": {
          "detected": true,
          "files": ["package.json", "tsconfig.json"]
        },
        "React": {
          "detected": true,
          "version_hint": "^18.2.0",
          "file": "package.json"
        },
        "Vite": {
          "detected": true,
          "file": "vite.config.js"
        }
      }
    },
    "android": {
      "detected": true,
      "type": "mobile",
      "confidence": "high",
      "tech": {
        "Kotlin": {
          "detected": true,
          "files": ["src/main/kotlin/*.kt"]
        },
        "Gradle": {
          "detected": true,
          "file": "build.gradle.kts"
        },
        "Firebase": {
          "detected": true,
          "file": "build.gradle.kts"
        },
        "Koin": {
          "detected": true,
          "file": "build.gradle.kts"
        },
        "Compose": {
          "detected": true,
          "file": "build.gradle.kts"
        }
      }
    },
    "ios": {
      "detected": false,
      "type": "mobile",
      "confidence": null
    },
    "docker": {
      "detected": true,
      "type": "devops",
      "confidence": "high",
      "tech": {
        "Docker": {
          "detected": true,
          "files": ["Dockerfile", "docker-compose.yml"]
        }
      }
    },
    "ci_cd": {
      "detected": true,
      "type": "infrastructure",
      "confidence": "high",
      "tech": {
        "GitHub Actions": {
          "detected": true,
          "files": [".github/workflows/ci.yml", ".github/workflows/cd.yml"]
        }
      }
    }
  },
  "warnings": [
    "No iOS/Swift files detected",
    ".env file detected but not read",
    "Large .git directory (consider .gitignore)",
    "Sensitive files ignored: google-services.json, local.properties"
  ],
  "scan_options": {
    "max_depth": 6,
    "ignore_dirs": ["node_modules", ".git", "build", "dist", ".gradle"],
    "follow_symlinks": false
  }
}
```

#### Comando: `eurecat brain scan`

```bash
eurecat brain scan              # Detecta stack, crea/actualiza scan.json
eurecat brain scan --root .     # Apunta a directorio específico (para monorepos)
eurecat brain scan --show       # Muestra resultado sin guardar
eurecat brain scan --force      # Redetecta incluso si existe scan.json
```

**Salida (stdout):**
```
🔍 Escaneando proyecto en: /Users/user/code/my-app

✓ Frontend (Web)
  • JavaScript/TypeScript
  • React 18.2.0
  • Vite
  • npm

✓ Mobile (Android)
  • Kotlin
  • Gradle (build.gradle.kts)
  • Firebase
  • Koin (Dependency Injection)
  • Jetpack Compose

✓ DevOps
  • Docker
  • GitHub Actions

⚠ Warnings:
  • No iOS detected
  • .env file detected (not read)
  • Sensitive files ignored: google-services.json

✔ Guardado en: .eurecatagent/brain/scan.json
```

#### Integración con `context`

```bash
eurecat brain context --section stack

# Output:
# ## Stack Detectado (2026-05-27T14:30:45Z)
#
# ### Frontend
# - JavaScript/TypeScript
# - React 18.2.0
# - Vite
# - npm
#
# ### Android
# - Kotlin
# - Gradle (build.gradle.kts)
# - Firebase
# - Koin
# - Jetpack Compose
#
# ### DevOps
# - Docker
# - GitHub Actions
#
# ### Warnings
# - No iOS detected
# - .env file detected (not read)
```

---

## Capacidad 2: Auditoría y Revisión

### Propósito

Identificar automáticamente entradas `temporary` cuya fecha de revisión (`review_after`) ha vencido.

### Comando: `eurecat brain review`

```bash
eurecat brain review                      # Lista temporales vencidos
eurecat brain review --section bugfixes   # Solo en esa sección
eurecat brain review --upcoming 30        # Vence en próximos 30 días
eurecat brain review --json               # Output JSON
```

#### Salida (stdout)

```
🔍 Auditoría de entradas temporales

⏰ VENCIDAS (hace 5 días):
  [1] use-cocoapods-workaround-20260322-140000
      Archivo: bugfixes.md (línea 45)
      Vencida: 2026-05-22
      Acción: eurecat brain promote <id> --status deprecated|active

⏰ VENCIDAS (hace 2 días):
  [2] firebase-ios-build-fix-20260425-090000
      Archivo: bugfixes.md (línea 78)
      Vencida: 2026-05-25
      Acción: eurecat brain promote <id> --status deprecated|active

📅 PRÓXIMAS A VENCER (en 3 días):
  [3] docker-build-cache-temp-20260501-160000
      Archivo: bugfixes.md (línea 112)
      Vencida: 2026-05-30
      Acción: eurecat brain bump <id> --review-after <fecha>

✔ Resumen: 2 vencidas, 1 próxima a vencer, 12 activas, 0 deprecated

Sugerencia: Ejecuta 'eurecat brain context --section bugfixes --status temporary'
para revisar los detalles de cada entrada vencida.
```

#### Integración: Pre-commit Hook

Agregar a `.git/hooks/pre-commit`:
```bash
#!/bin/bash
eurecat brain review --json >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Hay entradas temporales vencidas en el Brain. Ejecuta:"
  echo "   eurecat brain review"
  exit 1
fi
exit 0
```

---

## Capacidad 3: Caducidad y Ciclo de Vida

### Propósito

Permitir que workarounds temporales tengan fecha de revisión automática y avancen en su ciclo de vida.

### Cambio de Formato: Agregar `review_after`

**Antes (v1.0):**
```markdown
## Usar CocoaPods 1.15.x sin CamelCase

- id: use-cocoapods-workaround-20260322-140000
- type: platform_workaround
- status: temporary
- platform: ios
- area: cocoapods
- date: 2026-03-22
- files: iosApp/Podfile

### Contexto
CocoaPods 1.15 falla con módulos en CamelCase...
```

**Después (v1.1):**
```markdown
## Usar CocoaPods 1.15.x sin CamelCase

- id: use-cocoapods-workaround-20260322-140000
- type: platform_workaround
- status: temporary
- platform: ios
- area: cocoapods
- date: 2026-03-22
- review_after: 2026-06-22    ← NUEVO: 3 meses para revisar
- files: iosApp/Podfile

### Contexto
CocoaPods 1.15 falla con módulos en CamelCase...
```

### Comandos: `promote` y `bump`

#### `eurecat brain promote <id>`

Cambia el estado de una entrada:

```bash
eurecat brain promote use-cocoapods-workaround-20260322-140000 --status active
  # Convierte "temporary" → "active" (se queda permanentemente)

eurecat brain promote use-cocoapods-workaround-20260322-140000 --status deprecated
  # Convierte "temporary"/"active" → "deprecated" (ya no aplica)

eurecat brain promote use-cocoapods-workaround-20260322-140000 --status active \
  --clear-review-after
  # Cambia status y elimina review_after
```

**Salida:**
```
✔ Entrada actualizada:
  ID: use-cocoapods-workaround-20260322-140000
  Status: temporary → active
  review_after: 2026-06-22 (sin cambios)
  Archivo: .eurecatagent/brain/memories/bugfixes.md
```

#### `eurecat brain bump <id>`

Extiende solo la fecha de revisión:

```bash
eurecat brain bump use-cocoapods-workaround-20260322-140000 \
  --review-after 2026-09-22
  # Extiende la revisión a 3 meses más (sin tocar status)

eurecat brain bump use-cocoapods-workaround-20260322-140000 \
  --clear-review-after
  # Elimina la fecha (si el workaround se convirtió en permanente)
```

**Salida:**
```
✔ Entrada actualizada:
  ID: use-cocoapods-workaround-20260322-140000
  Status: temporary (sin cambios)
  review_after: 2026-06-22 → 2026-09-22
  Archivo: .eurecatagent/brain/memories/bugfixes.md
```

### Ciclo de Vida Visualizado

```
1. Workaround temporal encontrado
   ↓
   save bugfix --status temporary --review-after 2026-06-22
   ↓
2. Se guarda en bugfixes.md con review_after
   ↓
   ┌─────────────────────────────────┐
   │ brain review (cada semana)       │
   │ ¿Está vencida? NO → continuar  │
   └─────────────────────────────────┘
   ↓
3. Fecha de revisión se aproxima (--upcoming 30)
   ↓
   Team decide: ¿Es permanente o está fixed?
   ├─ Se quedará permanentemente
   │  └─ promote --status active --clear-review-after
   │     ↓
   │     Se convierte en decisión permanente
   │
   └─ Fue arreglado en el framework
      └─ promote --status deprecated
         ↓
         Entra en histórico (ya no aparece en context)

4. Si aún es válido pero necesita más tiempo
   └─ bump --review-after 2026-09-22
      ↓
      Se extiende el plazo (visible en upcoming)
```

---

## Nuevos Comandos CLI

### Resumen de Cambios

| Comando | Nuevo | Cambio |
|---------|-------|--------|
| `eurecat brain init` | ❌ | ✅ Ahora crea `scan.json` vacío |
| `eurecat brain scan` | ✅ | — |
| `eurecat brain save` | ❌ | ✅ Ahora soporta `--review-after` para temporary |
| `eurecat brain context` | ❌ | ✅ Ahora soporta `--section stack`, `--status temporary`, filtros |
| `eurecat brain search` | ❌ | ✅ Ahora soporta `--status`, `--platform` |
| `eurecat brain review` | ✅ | — |
| `eurecat brain promote` | ✅ | — |
| `eurecat brain bump` | ✅ | — |

### Referencia Completa

```bash
# SCAN
eurecat brain scan [flags]
  --root <path>        Directorio raíz (default: current)
  --show               Muestra sin guardar
  --force              Redetecta aunque exista scan.json

# SAVE (enhanced)
eurecat brain save <type> [flags]
  <type>               decision|bugfix|testing|style
  --title <str>        Título descriptivo
  --platform <str>     general|web|android|ios|kmp|flutter|react-native
  --area <str>         Área/categoría libre
  --status <str>       active|temporary|deprecated (default: active)
  --review-after <date> YYYY-MM-DD (requerido si --status temporary)
  --files <files>      Archivos afectados (comma-separated)
  --body <str>         Contenido de la entrada
  --root <path>        Directorio raíz (default: current)

# CONTEXT (enhanced)
eurecat brain context [flags]
  --section <str>      stack|decisions|bugfixes|testing|style-guides (comma-separated)
  --platform <str>     general|web|android|ios|... (exact match)
  --status <str>       active|temporary|deprecated
  --area <str>         Substring match
  --json               Output JSON
  --root <path>        Directorio raíz (default: current)

# SEARCH (enhanced)
eurecat brain search <query> [flags]
  <query>              Texto libre
  --section <str>      Filtra por sección (comma-separated)
  --platform <str>     Filtra por plataforma
  --status <str>       Filtra por estado
  --json               Output JSON
  --root <path>        Directorio raíz (default: current)

# REVIEW (new)
eurecat brain review [flags]
  --section <str>      Filtra por sección
  --upcoming <N>       Muestra vencidas + próximas en N días (default: solo vencidas)
  --json               Output JSON
  --root <path>        Directorio raíz (default: current)

# PROMOTE (new)
eurecat brain promote <id> [flags]
  <id>                 ID de la entrada
  --status <str>       Nueva estado: active|temporary|deprecated
  --clear-review-after Elimina la fecha de revisión
  --root <path>        Directorio raíz (default: current)

# BUMP (new)
eurecat brain bump <id> [flags]
  <id>                 ID de la entrada
  --review-after <date> Nueva fecha: YYYY-MM-DD
  --clear-review-after Elimina la fecha de revisión
  --root <path>        Directorio raíz (default: current)
```

---

## Cambios de Arquitectura

### Estructura de Directorios (No cambia)

```
.eurecatagent/brain/
├── config.json        ← metadata del proyecto
├── scan.json          ← NUEVO: stack detectado
└── memories/
    ├── decisions.md   ← decisions
    ├── bugfixes.md    ← bugfixes (ahora con review_after)
    ├── testing.md     ← testing patterns
    └── style-guides.md ← style rules
```

### Cambios a `config.json`

**Antes:**
```json
{
  "version": "1.0",
  "created": "2026-05-27",
  "project": "EurecatAgent"
}
```

**Después:**
```json
{
  "version": "1.1",
  "created": "2026-05-27",
  "updated": "2026-05-27T14:30:00Z",
  "project": "EurecatAgent",
  "brain": {
    "sections": {
      "decisions": "architecture_decision",
      "bugfixes": "bug_fix|platform_workaround",
      "testing": "testing_pattern",
      "style-guides": "style_rule"
    },
    "default_review_days": 90,
    "platforms": ["general", "web", "android", "ios", "kmp", "flutter", "react-native", "backend", "devops"]
  },
  "scan": {
    "last_scanned": "2026-05-27T14:30:45Z",
    "max_depth": 6,
    "ignore_dirs": ["node_modules", ".git", "build", "dist", ".gradle", "target", "venv", ".next"]
  }
}
```

### Módulos Go a Agregar

```
cli/internal/brain/
├── detector.go          ← Stack detection (scan)
├── scanner.go           ← Ejecuta detector sobre proyecto
├── parser.go            ← Parser Markdown (ya existe, mejorar)
├── auditor.go           ← Review de temporales vencidos
├── promoter.go          ← Promote/bump de entradas
└── types.go             ← Tipos (Entry, Stack, Scan)

cli/cmd/
├── brain.go             ← Grupo de comandos `eurecat brain`
├── brain_scan.go        ← Subcomando `scan`
├── brain_save.go        ← Mejorado para `--review-after`
├── brain_context.go     ← Mejorado para filtros
├── brain_search.go      ← Mejorado para filtros
├── brain_review.go      ← Subcomando `review`
├── brain_promote.go     ← Subcomando `promote`
└── brain_bump.go        ← Subcomando `bump`
```

### Cambios a Skill `eurecat-brain.ts`

**Actual (v1.0):**
```typescript
export const eurecatBrainSkill = {
  init: () => shell.sync('eurecat brain init'),
  save: (type, options) => shell.sync('eurecat brain save', type, options),
  context: (filters) => shell.sync('eurecat brain context', filters),
  search: (query, filters) => shell.sync('eurecat brain search', query, filters),
}
```

**Futuro (v1.1):**
```typescript
export const eurecatBrainSkill = {
  // Existing
  init: () => shell.sync('eurecat brain init'),
  save: (type, options) => shell.sync('eurecat brain save', type, options),
  context: (filters) => shell.sync('eurecat brain context', filters),
  search: (query, filters) => shell.sync('eurecat brain search', query, filters),
  
  // New
  scan: (options) => shell.sync('eurecat brain scan', options),
  review: (options) => shell.sync('eurecat brain review', options),
  promote: (id, status) => shell.sync('eurecat brain promote', id, status),
  bump: (id, reviewAfter) => shell.sync('eurecat brain bump', id, reviewAfter),
}
```

---

## Plan de Implementación

### Fase 1: Scan Automático (1.5 sprints)

**Sprint 1.1:**
- [ ] Módulo `cli/internal/brain/types.go` — Tipos de entrada y stack
- [ ] Módulo `cli/internal/brain/detector.go` — Detectores por stack
- [ ] Módulo `cli/internal/brain/scanner.go` — Orquesta scan sobre proyecto
- [ ] Tests unitarios de detectores (15+ casos)

**Sprint 1.2:**
- [ ] Comando `cli/cmd/brain_scan.go` — CLI `eurecat brain scan`
- [ ] Generar `scan.json`
- [ ] Integración con `brain context --section stack`
- [ ] Tests E2E de scan

**Criterios de Aceptación:**
- ✅ Detecta 80%+ de stacks comunes
- ✅ `scan.json` generado correctamente
- ✅ `eurecat brain context --section stack` imprime stack
- ✅ Sin falsos positivos relevantes

---

### Fase 2: Auditoría y Revisión (1.5 sprints)

**Sprint 2.1:**
- [ ] Mejorar parser Markdown para manejar `review_after`
- [ ] Módulo `cli/internal/brain/auditor.go` — Detecta vencidos
- [ ] Comando `cli/cmd/brain_review.go` — CLI `eurecat brain review`
- [ ] Tests de auditoría

**Sprint 2.2:**
- [ ] Mejorar `save` para soportar `--review-after`
- [ ] Mejorar `context` para filtrar por `--status`
- [ ] Pre-commit hook integrado
- [ ] Tests E2E de auditoría

**Criterios de Aceptación:**
- ✅ `review` detecta correctamente temporales vencidos
- ✅ `--upcoming 30` funciona
- ✅ Pre-commit hook frena pushes con vencidos
- ✅ Output legible y accionable

---

### Fase 3: Ciclo de Vida (1.5 sprints)

**Sprint 3.1:**
- [ ] Módulo `cli/internal/brain/promoter.go` — Lógica de promote/bump
- [ ] Comando `cli/cmd/brain_promote.go` — CLI `promote`
- [ ] Comando `cli/cmd/brain_bump.go` — CLI `bump`
- [ ] Tests de ciclo de vida

**Sprint 3.2:**
- [ ] Actualizar skill `eurecat-brain.ts` con nuevos métodos
- [ ] Documentación de flujos (en SKILL.md)
- [ ] Hook en skills: proponer `promote`/`bump` al final
- [ ] Tests E2E completos

**Criterios de Aceptación:**
- ✅ `promote` cambia correctamente status
- ✅ `bump` extiende review_after
- ✅ `--clear-review-after` funciona
- ✅ Skill propone promover al final de flujos

---

### Fase 4: Integración y Documentación (0.5 sprints)

**Sprint 4:**
- [ ] Actualizar `BRAIN_IMPROVEMENTS.md` → `BRAIN.md`
- [ ] Actualizar `agent/skills/eurecat-brain/SKILL.md`
- [ ] Actualizar `README.md` con ejemplos
- [ ] Migración de configuraciones de v1.0 → v1.1
- [ ] Release notes

**Criterios de Aceptación:**
- ✅ Documentación completa y clara
- ✅ Ejemplos end-to-end funcionales
- ✅ Guía de migración para usuarios existentes
- ✅ Tutorial interactivo (5 min)

---

## Criterios de Aceptación

### Funcionalidad

- ✅ Scan automático detecta 80%+ de stacks comunes (web, mobile, backend, devops)
- ✅ Auditoría detecta correctamente temporales vencidos (0 falsos negativos)
- ✅ Promote/bump funcionan sin corromper Markdown
- ✅ Filtros (`--status`, `--platform`, `--section`) funcionan combinados
- ✅ Offline 100% (sin llamadas de red)

### Calidad

- ✅ Unit tests: 85%+ cobertura
- ✅ E2E tests: todos los flujos principales
- ✅ No hay regresiones en v1.0 (backward compatible)
- ✅ Performance: scan en <2s para proyectos típicos
- ✅ Salida JSON valida (puede parsearse)

### UX

- ✅ Output humano legible y accionable
- ✅ Mensajes de error claros con sugerencias
- ✅ `--help` documentado
- ✅ Integración con hooks de git (pre-commit)
- ✅ Color/emoji para diferenciar estados (✅ ⚠️ ❌)

### Documentación

- ✅ SKILL.md actualizado con nuevos comandos
- ✅ README.md con ejemplos
- ✅ Tutorial step-by-step para scan + review + promote
- ✅ FAQ con troubleshooting
- ✅ Guía de migración v1.0 → v1.1

---

## Riesgos y Mitigaciones

### Riesgo 1: Detección de stack incompleta

**Problema:** Algunos stacks no se detectan, o hay falsos positivos.

**Mitigación:**
- Comenzar con stacks comunes (web, mobile, backend)
- Hacer la detección extensible (plugins)
- Permitir configuración manual en `config.json` (`--override-stack`)
- Feedback comunitario (GitHub issues)

### Riesgo 2: Performance del scan

**Problema:** Escanear proyecto grande es lento.

**Mitigación:**
- Limitar profundidad (`max_depth: 6`)
- Ignorar directorios conocidos (node_modules, .git, etc.)
- Opción `--fast` (solo archivos de config, no contenido)
- Caché en `scan.json` (no redetectar automáticamente)

### Riesgo 3: Corrupción de Markdown

**Problema:** Promote/bump mal manejo rompe archivos .md.

**Mitigación:**
- Tests exhaustivos de parser
- Usar AST para manipular, no regex
- Backup automático antes de modify
- Rollback si falla (`--undo`)

### Riesgo 4: Fricción de UX

**Problema:** Nuevos comandos no son intuitivos.

**Mitigación:**
- CLI consistente con Cobra
- `--help` exhaustivo
- Tutorial interactivo (`eurecat brain tutorial`)
- Command suggestions si hay typo

---

## Línea de Tiempo

```
Semana 1-2: Fase 1 (Scan)
Semana 3-4: Fase 2 (Auditoría)
Semana 5-6: Fase 3 (Ciclo de vida)
Semana 7: Fase 4 (Integración + Release)

Total: ~7 semanas (1.75 meses)
```

---

## Conclusión

Este plan elevaría el Brain de EurecatAgent a una **madurez v1.0**, agregando:

1. ✅ **Scan automático** — Detecta stack sin intervención
2. ✅ **Auditoría** — Identifica temporales vencidos antes de que se olviden
3. ✅ **Caducidad** — Workarounds con ciclo de vida explícito
4. ✅ **CLI robusta** — promote, bump, review con filtros

Manteniendo la **simplicidad** y **portabilidad** que caracteriza a EurecatAgent.

**Nota:** Este es un documento de ESPECIFICACIÓN. No implementa cambios. Para proceder, revisar con el equipo y dar luz verde.

