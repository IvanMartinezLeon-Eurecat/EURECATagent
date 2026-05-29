---
name: eurecat-brain
description: Per-project living memory for decisions, bugfixes, testing patterns, and style guides. Use when you need to recall past decisions, save a workaround, or check if something was already tried.
metadata:
  author: eurecat.org
  version: "1.0"
  requires:
    - architecture
    - fix
    - testing
---
# Eurecat Brain — Memoria de Proyecto

Brain es la memoria viva del proyecto. Mientras que las skills enseñan *cómo* trabajar, Brain guarda *qué se decidió, qué se rompió y cómo se arregló*.

Los datos se almacenan en `<repo>/.eurecatagent/brain/` como Markdown plano, versionable en git y legible por humanos.

## Estructura de Datos

```
<repo>/.eurecatagent/brain/
├── config.json
└── memories/
    ├── decisions.md        ← decisiones de arquitectura
    ├── bugfixes.md         ← bugs, workarounds, errores recurrentes
    ├── testing.md          ← patrones de testing no obvios
    └── style-guides.md     ← convenciones locales (naming, imports, etc.)
```

### Formato de cada entrada

Cada entrada es un H2 (`##`) seguido de metadatos YAML-ish y cuerpo Markdown:

```markdown
## Título Descriptivo

- id: titulo-slug-20260527-143025
- type: bug_fix | architecture_decision | testing_pattern | platform_workaround | style_rule
- status: active | temporary | deprecated
- platform: general | web | android | ios | kmp | flutter | react-native
- area: <categoría libre, ej: firebase_auth, dependency_injection>
- date: 2026-05-27
- review_after: 2026-08-27      ← solo para temporary
- files: src/main.kt, src/util.kt

### Contexto
¿Por qué ocurrió? ¿Qué desencadenó esta decisión o bug?

### Contenido
La decisión, la causa raíz, o el patrón.

### Archivos Afectados
- ruta/al/archivo
```

## Comandos

Usa los comandos `/eurecat-brain` mediante `bash` (o el comando disponible) para gestionar el Brain:

### `init` — Inicializar Brain

```bash
pi -c "/eurecat-brain init"
```

Crea la estructura de directorios y ficheros. Es **idempotente**: no sobrescribe nada existente.

### `save` — Guardar una entrada

```bash
pi -c '/eurecat-brain save decision \
  --title "Usar Koin para DI" \
  --platform general \
  --area dependency_injection \
  --body "Decisión: Usar Koin como DI en todo el proyecto compartido.\nRazón: KMP-friendly, sin code generation."'
```

Guardar bugfix:
```bash
pi -c '/eurecat-brain save bugfix \
  --title "Podfile composeApp en minúsculas hasta CocoaPods 1.16" \
  --platform ios \
  --area cocoapods \
  --status temporary \
  --review-after 2026-08-15 \
  --files iosApp/Podfile \
  --body "CocoaPods 1.15 falla con CamelCase. Workaround hasta 1.16."'
```

Guardar patrón de testing:
```bash
pi -c '/eurecat-brain save testing \
  --title "Esperar a que DataStore vacíe tras clear()" \
  --platform general \
  --area datastore \
  --body "dataStore.edit { it.clear() } no es síncrono.\nUsar: dataStore.data.first { it.asMap().isEmpty() }"'
```

Guardar guía de estilo:
```bash
pi -c '/eurecat-brain save style \
  --title "Preferir sealed class sobre enum en dominios complejos" \
  --area kotlin \
  --body "En dominios con estado, sealed class permite más flexibilidad que enum."'
```

### `context` — Consultar toda la memoria

```bash
pi -c '/eurecat-brain context'
pi -c '/eurecat-brain context --section decisions'
pi -c '/eurecat-brain context --section bugfixes --platform ios'
pi -c '/eurecat-brain context --section decisions,bugfixes --status temporary'
```

Devuelve Markdown listo para que el agente lo lea: configuración + stack detectado + entradas filtradas.

### `search` — Buscar en la memoria

```bash
pi -c '/eurecat-brain search koin'
pi -c '/eurecat-brain search firebase --platform ios'
pi -c '/eurecat-brain search --status temporary'
```

Devuelve entradas que coinciden, con snippet.

### `review` — Auditoría de entradas temporales vencidas

```bash
pi -c '/eurecat-brain review'
```

Lista entradas `temporary` cuya `review_after` ha pasado. Útil como pre-commit gate.

### `promote` — Cambiar estado de una entrada

```bash
pi -c '/eurecat-brain promote <id> --status active'
pi -c '/eurecat-brain promote <id> --status deprecated'
```

### `bump` — Extender fecha de revisión

```bash
pi -c '/eurecat-brain bump <id> --review-after 2026-10-01'
```

## Ciclo de Vida de una Entrada

```
[active] ──► [temporary] ──► review ──► promote o bump
    │                            │
    └────────────────────────────┘
         (nunca expires)
```

1. Se crea como `active` (decisión permanente) o `temporary` (workaround con caducidad)
2. Cada `temporary` tiene `review_after` — fecha en la que alguien debe revisarlo
3. `review` lista los vencidos
4. `promote` cambia a `active` (se queda) o `deprecated` (ya no aplica)
5. `bump` extiende la fecha si el workaround sigue siendo válido

## Hooks en Skills (Cuándo proponer guardar)

Las skills que interactúan con Brain deben proponer guardar al final de su flujo:

### fix → bugfix
Al final de **Fase 4** (Validación y Limpieza), si el bug es recurrente o el workaround no obvio:
> "He identificado un patrón que podría ser útil guardar en Brain como bugfix. ¿Lo guardo?"

Si el usuario confirma, ejecutar `save bugfix`.

### testing → testing pattern
Al final del flujo de testing, si el test captura un patrón no obvio:
> "Este patrón de testing podría ser relevante para otros tests similares. ¿Lo guardo en Brain?"

Si confirma, ejecutar `save testing`.

### architecture → decision
Tras una decisión de arquitectura significativa (durante el diseño), al final:
> "Esta decisión de arquitectura debería quedar registrada. ¿La guardo en Brain?"

Si confirma, ejecutar `save decision`.

### documentation → style guide
Si durante el trabajo se descubre una convención local que no está documentada:
> "He encontrado una convención que no está documentada. ¿La guardo como guía de estilo en Brain?"

Si confirma, ejecutar `save style`.

**Reglas del hook:**
- Siempre preguntar, nunca guardar sin confirmación
- Solo proponer si el proyecto tiene Brain inicializado (existe `.eurecatagent/brain/config.json`)
- Si no existe, el hook se salta silenciosamente
- Usar el comando `pi -c "/eurecat-brain save ..."` para guardar

## Criterios de Éxito
- Cualquier decisión de arquitectura significativa queda registrada con su razonamiento
- Los workarounds temporales tienen fecha de revisión y no se olvidan
- Los patrones de testing no obvios se comparten entre desarrolladores y agentes
- `review` no devuelve entradas vencidas (el equipo las mantiene al día)
- Un desarrollador nuevo puede entender el historial de decisiones del proyecto en 5 minutos
