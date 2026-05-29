# 🧠 Brain v1.1 — Ejemplos Prácticos y Diagramas

**Complemento a:** BRAIN_IMPROVEMENTS.md  
**Propósito:** Casos de uso reales, flujos visuales, ejemplos de comandos  

---

## 📚 Tabla de Contenidos

1. [Ejemplos Prácticos: Caso 1 — Firebase iOS](#ejemplos-prácticos-caso-1--firebase-ios)
2. [Ejemplos Prácticos: Caso 2 — Refactor de DI](#ejemplos-prácticos-caso-2--refactor-de-di)
3. [Diagramas de Flujo](#diagramas-de-flujo)
4. [Salidas Esperadas (Antes/Después)](#salidas-esperadas-antesantes)
5. [Guía de Migración v1.0 → v1.1](#guía-de-migración-v10--v11)
6. [FAQ de Implementación](#faq-de-implementación)

---

## Ejemplos Prácticos: Caso 1 — Firebase iOS

### Escenario

Tu equipo desarrolla una app iOS + Android (KMP) con Firebase. En iOS, descubren que Firebase 11.x rompe el build por un issue con módulos en CocoaPods 1.15.

**Día 1:** Descubrimiento del problema  
**Día 2:** Se implementa workaround temporal (minúsculas en Podfile)  
**Día 60:** Llega CocoaPods 1.16 con fix → revisión pendiente

---

### Flujo Detallado (v1.1)

#### 1️⃣ Lunes 14:30 — Discovery (fix skill)

```bash
# Técnico está en fix skill debugueando iOS build failure
# Al final de la skill, detecta que esto es un workaround temporal

# fix skill propone:
# "Este looks como un temporal workaround. ¿Lo guardo en Brain para review en 3 meses?"

# Técnico confirma (yes)
# fix skill ejecuta automáticamente:

eurecat brain save bugfix \
  --title "CocoaPods 1.15.x no soporta módulos en CamelCase en Podfile" \
  --platform ios \
  --area cocoapods \
  --status temporary \
  --review-after 2026-08-27 \
  --files iosApp/Podfile \
  --body "
### Contexto
Firebase 11.x en iOS causa error de build:
\`\`\`
error: unable to find sdk 'iphoneos'
\`\`\`

Root cause: CocoaPods 1.15 falla al resolver módulos con CamelCase en Podfile.
Issue: CocoaPods#11234 (esperando 1.16)

### Solución
Cambiar 'composeApp' → 'composeapp' en Podfile (línea 12):
\`\`\`ruby
target 'composeapp' do
  pod 'Firebase', '~> 11.0'
end
\`\`\`

Esto es workaround temporal hasta que CocoaPods 1.16 salga.
"

# Output:
# ✔ Guardado en: .eurecatagent/brain/memories/bugfixes.md
# ID: cocoapods-camelcase-workaround-20260527-143030
# review_after: 2026-08-27 (3 meses)
```

**Resultado en `bugfixes.md`:**
```markdown
## CocoaPods 1.15.x no soporta módulos en CamelCase en Podfile

- id: cocoapods-camelcase-workaround-20260527-143030
- type: platform_workaround
- status: temporary
- platform: ios
- area: cocoapods
- date: 2026-05-27
- review_after: 2026-08-27
- files: iosApp/Podfile

### Contexto
Firebase 11.x en iOS causa error de build...
[contenido completo...]
```

---

#### 2️⃣ Cada semana — `review` automático

```bash
# El equipo ejecuta en CI/CD:
eurecat brain review

# Output (todo OK):
# ✔ Resumen: 0 vencidas, 1 próxima a vencer (en 71 días), 5 activas
```

---

#### 3️⃣ 25 de Agosto (3 meses después) — Review Time

```bash
# Team lead ejecuta review:
eurecat brain review

# Output:
# ⏰ VENCIDAS (TODAY):
#   [1] cocoapods-camelcase-workaround-20260527-143030
#       Archivo: bugfixes.md (línea 45)
#       Vencida: 2026-08-27
#       Acción: eurecat brain promote <id> --status deprecated|active
#
# Próximos pasos:
#   A. CocoaPods 1.16 fue released → cambiar a deprecated
#   B. Aún no released → bump a 2026-11-27

# Team lead verifica CocoaPods releases...
# CocoaPods 1.16.0 fue lanzado el 2026-08-24 ✓

# Ejecuta:
eurecat brain promote cocoapods-camelcase-workaround-20260527-143030 \
  --status deprecated

# Output:
# ✔ Entrada actualizada:
#   ID: cocoapods-camelcase-workaround-20260527-143030
#   Status: temporary → deprecated
#   Archivo: .eurecatagent/brain/memories/bugfixes.md
#   
#   Próximos pasos:
#   1. Actualiza la app a CocoaPods 1.16+
#   2. Cambia Podfile: composeapp → composeApp
#   3. Confirma que el build siga exitoso
#   4. Commit y push (la entrada quedará en histórico)
```

**Resultado en `bugfixes.md`:**
```markdown
## CocoaPods 1.15.x no soporta módulos en CamelCase en Podfile

- id: cocoapods-camelcase-workaround-20260527-143030
- type: platform_workaround
- status: deprecated                    ← CAMBIÓ DE temporary A deprecated
- platform: ios
- area: cocoapods
- date: 2026-05-27
- review_after: 2026-08-27
- files: iosApp/Podfile

### Contexto
...

### Status
Marked as deprecated on 2026-08-27 — CocoaPods 1.16.0 released with fix.
```

**Más adelante:**
```bash
# Team actualiza app a CocoaPods 1.16, cambia composeApp,
# y confirma que build funciona.

# Entrada ahora aparece en:
eurecat brain context --section bugfixes --status deprecated

# Pero NO aparece en:
eurecat brain context --section bugfixes --status active|temporary
```

---

### Comparativa: v1.0 vs v1.1

| Momento | v1.0 (Actual) | v1.1 (Propuesto) |
|---------|---------------|-----------------|
| **Día 1: Save** | Manual con `--status active` | Fix skill propone → CLI genera `review_after` |
| **Día 30** | Nada (se olvida) | Silencioso (fecha dentro de 60 días) |
| **Día 60** | Nada (se olvida más) | `brain review --upcoming 30` muestra aviso |
| **Día 89** | Nada (vencido, sin saberlo) | `brain review` muestra VENCIDA |
| **Día 91** | Nada (sin saberlo) | Team lead ve que está vencida, ejecuta `promote` |

**Resultado:** Workarounds se revisan **proactivamente**, no por inercia.

---

## Ejemplos Prácticos: Caso 2 — Refactor de DI

### Escenario

El equipo decide cambiar de Service Locator (manual) a Koin (KMP-friendly). Es una decisión arquitectónica **permanente**, no temporal.

---

### Flujo Detallado (v1.1)

#### 1️⃣ Lunes — Decisión en spec-driven-development skill

```bash
# Team lead / architect ejecuta spec-driven-development skill
# Al final, skill propone:
# "Esta es una decisión arquitectónica importante. ¿La guardo en Brain?"

# Confirma

eurecat brain save decision \
  --title "Usar Koin como DI en todo el KMP (shared + platform-specific)" \
  --platform general \
  --area dependency_injection \
  --status active \
  --files common/build.gradle.kts,iosApp/build.gradle.kts,androidApp/build.gradle.kts \
  --body "
### Decisión
Usar Koin como inyector de dependencias en:
- shared/ (Kotlin Multiplatform)
- iosApp/ (iOS-specific)
- androidApp/ (Android-specific)

### Razón
1. **KMP-friendly**: Koin soporta expect/actual de Kotlin sin magia
2. **Menos boilerplate**: No requiere code generation como Hilt
3. **Test-friendly**: Mock provider fácil
4. **Community**: Soporte activo, documentación buena
5. **Runtime**: Sin reflection pesada (lazy evaluation)

### Alternativas Consideradas
- Google Hilt: Requiere Android platform, no es KMP-native
- Manual DI: Boilerplate insostenible en proyectos grandes
- Dagger2: Generación en tiempo de compilación, más lento en iteraciones

### Archivos Afectados
- common/build.gradle.kts (agregar koin dependency)
- common/src/.../di/AppModule.kt (definir módulos)
- iosApp/build.gradle.kts (agregar koin-ios)
- androidApp/build.gradle.kts (agregar koin-android)

### Timeline
- Sprint 1: Refactor shared/
- Sprint 2: Refactor iosApp/
- Sprint 3: Refactor androidApp/ + cleanup

### Responsable
@tech-lead (arquitectura), @ios-dev (iOS), @android-dev (Android)
"

# Output:
# ✔ Guardado en: .eurecatagent/brain/memories/decisions.md
# ID: use-koin-as-di-20260527-140000
# Status: active (permanente, sin review_after)
```

**Resultado en `decisions.md`:**
```markdown
## Usar Koin como DI en todo el KMP (shared + platform-specific)

- id: use-koin-as-di-20260527-140000
- type: architecture_decision
- status: active
- platform: general
- area: dependency_injection
- date: 2026-05-27
- files: common/build.gradle.kts, iosApp/build.gradle.kts, androidApp/build.gradle.kts

### Decisión
Usar Koin como inyector de dependencias...
[contenido completo...]
```

---

#### 2️⃣ Semanas después — New dev onboarding

```bash
# Nuevo developer se une al equipo
# Lee la documentación, pero quiere entender las decisiones arquitectónicas

eurecat brain context --section decisions

# Output:
# ## Decisiones Arquitectónicas (Detectadas: 2026-05-27)
#
# ### 1. Usar Koin como DI en todo el KMP
# - Status: active (permanente)
# - Platform: general
# - Area: dependency_injection
# - Date: 2026-05-27
#
# **Resumen:**
# Inyector de dependencias KMP-friendly sin code generation.
# Razón: Soporte multiplatforma, menos boilerplate, test-friendly.
#
# [Ver completo: eurecat brain search koin]

# Ejecuta:
eurecat brain search koin

# Output:
# Encontrado 1 resultado:
#
# ## Usar Koin como DI en todo el KMP
# [snippet de 200 chars...]
#
# Archivos: common/build.gradle.kts, iosApp/build.gradle.kts, ...
# Responsables: @tech-lead, @ios-dev, @android-dev

# Lee completo:
cat .eurecatagent/brain/memories/decisions.md
```

**Resultado:** New dev entiende decisiones sin repreguntar.

---

## Diagramas de Flujo

### 1. Flujo: Scan Automático

```
┌─────────────────────────┐
│  eurecat brain scan     │
└────────────┬────────────┘
             │
             ▼
    ┌────────────────────┐
    │ Detectar archivos:  │
    │ • package.json     │
    │ • build.gradle.kts │
    │ • Podfile          │
    │ • pubspec.yaml     │
    │ • Dockerfile       │
    │ • go.mod           │
    │ etc...             │
    └────────────┬───────┘
             │
             ▼
    ┌────────────────────┐
    │ Analizar contenido  │
    │ Buscar patrones:    │
    │ • "firebase"        │
    │ • "koin"            │
    │ • "compose"         │
    │ etc...              │
    └────────────┬───────┘
             │
             ▼
    ┌────────────────────┐
    │ Construir scan.json:│
    │ {                  │
    │   stacks: [...]    │
    │   warnings: [...]  │
    │   timestamp        │
    │ }                  │
    └────────────┬───────┘
             │
             ▼
    ┌────────────────────┐
    │ Guardar en:        │
    │ .eurecatagent/brain/ │
    │ scan.json          │
    └────────────┬───────┘
             │
             ▼
    ┌─────────────────────┐
    │ ✔ Escaneo completo  │
    └─────────────────────┘

El stack se puede consultar con:
  eurecat brain context --section stack
```

### 2. Flujo: Review de Temporales

```
┌──────────────────────┐
│ eurecat brain review │
└──────────┬───────────┘
           │
           ▼
  ┌────────────────────┐
  │ Leer todos los     │
  │ memories/*.md      │
  └────────────┬───────┘
           │
           ▼
  ┌────────────────────────┐
  │ Filtrar:               │
  │ status == "temporary"  │
  └────────────┬───────────┘
           │
           ▼
  ┌────────────────────────────┐
  │ Para cada entrada:         │
  │ ¿review_after < TODAY?     │
  │   SI  → VENCIDA            │
  │   NO  → OK (active)        │
  └────────────┬───────────────┘
           │
           ▼
  ┌────────────────────────────┐
  │ Con --upcoming N:          │
  │ ¿review_after < TODAY+30d?│
  │   SI  → PRÓXIMA A VENCER   │
  │   NO  → OK (lejos)         │
  └────────────┬───────────────┘
           │
           ▼
  ┌──────────────────────────┐
  │ Mostrar:                 │
  │ ⏰ VENCIDAS              │
  │ 📅 PRÓXIMAS A VENCER    │
  │ ✔ RESUMEN               │
  └──────────────────────────┘

Exit code:
  0 = Sin vencidas
  1 = Hay vencidas (fail pre-commit hook)
```

### 3. Flujo: Ciclo de Vida de una Entrada

```
1. CREAR (save)
   │
   ├─ --status active     ┐
   │  ✔ Se queda por siempre
   │
   └─ --status temporary  ┐
      + --review-after DD │
      ✔ Vuelve a revisar en DD

2. REVISAR (review)
   │
   ├─ Está vencida? SÍ
   │  └─ Mostrar en output
   │
   └─ Está próxima? (--upcoming N)
      └─ Mostrar en output

3. ACTUAR (promote o bump)
   │
   ├─ promote --status active
   │  ✔ Se convierte en decisión permanente
   │
   ├─ promote --status deprecated
   │  ✔ Ya no aplica (entra en histórico)
   │
   └─ bump --review-after NUEVA_FECHA
      ✔ Extiende plazo sin cambiar status

4. FIN
   ✔ Entrada completa su ciclo de vida
```

### 4. Flujo: Integración con Skills

```
Fix Skill
  │
  ├─ [ENTRADA] Diagnosis de bug
  ├─ [ANÁLISIS] Root cause + solución
  ├─ [APLICACIÓN] Fix implementado
  │
  └─ [SALIDA]
     ¿Es recurrente o workaround temporal?
     
     SÍ → "¿Lo guardo en Brain?"
          │
          SI → eurecat brain save bugfix \
                 --status temporary \
                 --review-after 2026-08-27
          │
          ✔ Guardado en bugfixes.md
     │
     NO → Continuar

Architecture Skill (similar)
  │
  └─ [SALIDA]
     ¿Es decisión significativa?
     
     SÍ → "¿Lo guardo en Brain?"
          │
          SI → eurecat brain save decision \
                 --status active
          │
          ✔ Guardado en decisions.md
     │
     NO → Continuar

Cada skill propone, el user confirma.
Brain CLI se ejecuta automáticamente.
```

---

## Salidas Esperadas (Antes/Después)

### Comando: `context`

#### ANTES (v1.0)

```bash
$ eurecat brain context --section bugfixes

## Bugfixes (Detectadas: 2026-05-20)

### 1. Firebase iOS build failure
- Status: active
- Platform: ios
- Area: firebase
- Date: 2026-05-01

[contenido...]

### 2. DataStore race condition (VENCIDA)
- Status: temporary
- Platform: general
- Area: datastore
- Date: 2026-03-15
- review_after: 2026-04-15  ← ¡VENCIDA, PERO NO LO DICE!

[contenido...]

---

✔ 2 entradas
```

#### DESPUÉS (v1.1)

```bash
$ eurecat brain context --section bugfixes

## Bugfixes (Detectadas: 2026-05-20)

### 1. Firebase iOS build failure
- Status: active
- Platform: ios
- Area: firebase
- Date: 2026-05-01
- review_after: (sin fecha — permanente)

[contenido...]

### 2. DataStore race condition ⏰ VENCIDA
- Status: temporary
- Platform: general
- Area: datastore
- Date: 2026-03-15
- review_after: 2026-04-15  ← VENCIDA desde 2026-05-05
- Action: eurecat brain promote <id> --status active|deprecated

[contenido...]

---

✔ Resumen: 1 active, 1 temporary (VENCIDA)
⚠️  Nota: Ejecuta 'eurecat brain review' para auditoría completa
```

---

### Comando: `review`

#### ANTES (v1.0)

No existe. No hay forma de auditartemporales.

#### DESPUÉS (v1.1)

```bash
$ eurecat brain review

🔍 Auditoría de entradas temporales

⏰ VENCIDAS (hace 45 días):
  [1] datastore-race-condition-20260315-100000
      Archivo: bugfixes.md (línea 78)
      Vencida: 2026-04-15
      Acción: eurecat brain promote <id> --status deprecated|active

⏰ VENCIDAS (hace 5 días):
  [2] cocoapods-camelcase-workaround-20260527-143030
      Archivo: bugfixes.md (línea 45)
      Vencida: 2026-08-27
      Acción: eurecat brain promote <id> --status deprecated|active

📅 PRÓXIMAS A VENCER (en 8 días):
  [3] docker-build-cache-temp-20260501-160000
      Archivo: bugfixes.md (línea 112)
      Vencida: 2026-05-31
      Acción: eurecat brain bump <id> --review-after <fecha>

✔ Resumen: 2 vencidas, 1 próxima, 8 active, 2 deprecated

⚠️ Recomendación: Ejecuta
   eurecat brain context --section bugfixes --status temporary
   para ver detalles de los temporales.
```

**Con `--upcoming 30`:**
```bash
$ eurecat brain review --upcoming 30

[mismo output de arriba, pero incluye PRÓXIMAS A VENCER en 30 días]

📅 PRÓXIMAS A VENCER (en 8 días):
  [3] docker-build-cache-temp-20260501-160000
      Vencida: 2026-05-31
      
📅 PRÓXIMAS A VENCER (en 15 días):
  [4] gradle-version-pin-20260315-140000
      Vencida: 2026-06-06

...

✔ Resumen: 2 vencidas, 3 próximas (30d), 8 active, 2 deprecated

💡 Tip: Planifica el próximo sprint considerando revisiones vencidas.
```

---

### Comando: `scan`

#### ANTES (v1.0)

No existe.

#### DESPUÉS (v1.1)

```bash
$ eurecat brain scan

🔍 Escaneando proyecto en: /Users/ivan/code/my-app

✓ Frontend (Web)
  • JavaScript/TypeScript (package.json)
  • React 18.2.0 (package.json)
  • Vite (vite.config.js)
  • npm (package-lock.json)
  • TailwindCSS (tailwind.config.js)

✓ Mobile (Android)
  • Kotlin (src/main/kotlin/*.kt)
  • Gradle (build.gradle.kts)
  • Firebase (build.gradle.kts)
  • Koin 3.5.0 (build.gradle.kts)
  • Jetpack Compose (build.gradle.kts)

✓ DevOps
  • Docker (Dockerfile, docker-compose.yml)
  • GitHub Actions (.github/workflows/ci.yml, cd.yml)

⚠ Warnings:
  • No iOS detected
  • .env file detected (not read for security)
  • Sensitive files ignored: google-services.json, local.properties

✔ Guardado en: .eurecatagent/brain/scan.json (2026-05-27T14:30:45Z)

Próximos pasos:
  1. Verifica: eurecat brain context --section stack
  2. Agrega al .gitignore: .eurecatagent/brain/scan.json (opcional)
  3. Re-ejecuta cuando cambies dependencias: eurecat brain scan
```

---

## Guía de Migración v1.0 → v1.1

### Para Equipos Existentes

#### Paso 1: Backup (Seguridad)

```bash
# Haz backup de tu Brain actual
cp -r .eurecatagent/brain .eurecatagent/brain.backup-20260527

# Verifica que los datos están intactos
ls -la .eurecatagent/brain/memories/
```

#### Paso 2: Actualizar config.json

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
    "last_scanned": null,
    "max_depth": 6,
    "ignore_dirs": ["node_modules", ".git", "build", "dist", ".gradle", "target", "venv", ".next"]
  }
}
```

**Cómo actualizar:**
```bash
# Edita manualmente o ejecuta:
cat > .eurecatagent/brain/config.json << 'EOF'
{
  "version": "1.1",
  "created": "2026-05-27",
  "updated": "2026-05-27T14:30:00Z",
  "project": "EurecatAgent",
  "brain": {
    "default_review_days": 90
  }
}
EOF
```

#### Paso 3: Ejecutar Scan

```bash
eurecat brain scan

# Output:
# ✔ Guardado en: .eurecatagent/brain/scan.json
```

#### Paso 4: Revisar Brain Existente

```bash
# Mira si hay temporales sin review_after
eurecat brain context --section bugfixes

# Si alguno tiene `status: temporary` sin `review_after`:
# Edita manualmente y agrega:
# - review_after: YYYY-MM-DD (90 días después de today)
```

**Ejemplo:**
```markdown
## Mi workaround temporal antiguo

- id: old-workaround-20260301-100000
- type: platform_workaround
- status: temporary
- platform: ios
- area: something
- date: 2026-03-01
- review_after: 2026-06-01   ← AGRÉGALO SI NO EXISTE
```

#### Paso 5: Test de Comandos Nuevos

```bash
# Prueba scan
eurecat brain scan --show

# Prueba review
eurecat brain review

# Prueba search con filtros
eurecat brain search something --status temporary

# Prueba context con filtros
eurecat brain context --section bugfixes --status temporary
```

#### Paso 6: Integra en CI/CD

```bash
# Agregar a .github/workflows/ci.yml o similar:

  - name: Brain Audit
    run: |
      eurecat brain review
      if [ $? -ne 0 ]; then
        echo "❌ Hay entradas temporales vencidas"
        exit 1
      fi
```

#### Paso 7: Comunicar al Equipo

Envía email/Slack:
```
🧠 Actualización: Brain v1.1 disponible

Nuevas capacidades:
✅ Scan automático de stack
✅ Auditoría de temporales vencidos  
✅ Ciclo de vida con promote/bump

Cambios:
• Archivos temporales ahora tienen review_after
• Se detecta stack automáticamente
• CI/CD puede auditartemporales

Próximos pasos:
1. Ejecuta: eurecat brain scan
2. Revisa: eurecat brain review
3. Actualiza temporales antiguos

Preguntas? →  #engineering
```

---

## FAQ de Implementación

### P1: ¿Qué pasa si cargo un proyecto v1.0 sin migrar?

**R:** Seguirá funcionando. Los comandos v1.0 (`save`, `context`, `search`) son backward compatible. Los nuevos comandos (`scan`, `review`, `promote`, `bump`) requieren v1.1.

### P2: ¿Necesito actualizar `config.json` manualmente?

**R:** No obligatorio. Pero recomendado para:
- Aprovechar filtros de plataforma
- Configurar `default_review_days`
- Personalizar directorios ignorados en scan

Si no actualizas, usará defaults y funciona igual.

### P3: ¿Qué pasa si `review_after` es inválida?

**R:** El parser es indulgente:
- Fecha inválida → se ignora (entra en "sin fecha")
- Fecha futura → OK (countdown normal)
- Fecha pasada → aparece en `review` como VENCIDA

### P4: ¿Puedo automatizar `promote` tras un PR?

**R:** Sí. Desde CI/CD:

```bash
# En workflow.yml, tras merge:
- name: Check and promote if CocoaPods 1.16+
  run: |
    cocoapods_version=$(grep "cocoapods" Podfile | grep -o '[0-9.]*')
    if [[ "$cocoapods_version" > "1.15" ]]; then
      eurecat brain promote cocoapods-camelcase-workaround-20260527-143030 \
        --status deprecated
    fi
```

### P5: ¿Y si hay muchos temporales vencidos?

**R:** `review` los lista. `promote` uno a uno:

```bash
# Script para deprecar varios:
for id in $(eurecat brain review --json | jq '.expired[] | .id'); do
  eurecat brain promote "$id" --status deprecated
done
```

### P6: ¿Cómo filtro por múltiples plataformas?

**R:**

```bash
# Android O iOS
eurecat brain context --platform android
eurecat brain context --platform ios

# Combinado (no soportado aún, usa search):
eurecat brain search firebase --platform android
eurecat brain search firebase --platform ios
```

### P7: ¿Se sincroniza el Brain entre máquinas?

**R:** Vía git (como archivos normales):

```bash
git add .eurecatagent/brain/memories/
git add .eurecatagent/brain/config.json
git commit -m "Brain: Update bugfixes"
git push

# Otros devs:
git pull
eurecat brain review
```

No hay sincronización automática/cloud. Puro git.

### P8: ¿Puedo usar `review_after` en decisiones activas?

**R:** No recomendado. `review_after` es para:
- `status: temporary` — workarounds con plazo
- No para `status: active` — decisiones permanentes

Si quieres recordar una decisión anualmente, documenta en `### Revisión Anual` dentro de la entrada.

### P9: ¿El scan es lento en proyectos grandes?

**R:** El scan típico (<1000 archivos) tarda <500ms. Para proyectos enormes (>100k files):

```bash
eurecat brain scan --fast   # Solo config files, no contenido
eurecat brain scan          # Scan completo (más lento, más preciso)
```

### P10: ¿Qué sucede si edito un `.md` a mano?

**R:** Está permitido. El parser re-lee en cada comando. Restricciones:
- Mantén estructura `## Título` + metadata + body
- No dupliques `id:` entre entradas
- Mantén formato YAML-ish en metadata (- key: value)

Si rompes estructura, el parser saltará la entrada.

---

## Conclusión

Este documento proporciona **ejemplos concretos** y **diagramas visuales** para entender cómo v1.1 mejora el Brain de EurecatAgent.

**Próximos pasos:**
1. ✅ Leer `BRAIN_IMPROVEMENTS.md` (especificación técnica)
2. ✅ Leer este documento (ejemplos prácticos)
3. 🔲 Presentar al equipo para feedback
4. 🔲 Dar luz verde a implementación

