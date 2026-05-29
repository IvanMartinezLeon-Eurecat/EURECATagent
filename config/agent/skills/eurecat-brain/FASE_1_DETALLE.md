# 🚀 Fase 1: Scan Automático de Stack — Desglose de Implementación

**Propósito:** Detectar automáticamente el stack del proyecto y guardarlo en `scan.json`  
**Duración:** 1.5 sprints (~10-12 días)  
**Resultado:** Comando `eurecat brain scan` funcional  
**Complejidad:** Media (Go básico, I/O, Markdown)

---

## 📋 Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Tareas Específicas](#tareas-específicas)
3. [Arquitectura de Módulos](#arquitectura-de-módulos)
4. [Ejemplos de Código](#ejemplos-de-código)
5. [Output Esperado](#output-esperado)
6. [Testing Strategy](#testing-strategy)
7. [Criterios de Aceptación](#criterios-de-aceptación)
8. [Timeline Realista](#timeline-realista)

---

## Visión General

### Qué Hace

```
Entrada:
  → Proyecto en /Users/user/code/my-app

Proceso:
  → Escanea directorios buscando archivos característicos
  → Detecta lenguajes, frameworks, librerías
  → Genera JSON con stack detectado

Salida:
  → .eurecatagent/brain/scan.json
  → Output legible en stdout
  → Warnings si detecta cosas raras
```

### Ejemplo de Uso

```bash
$ cd /Users/user/code/my-app
$ eurecat brain scan

🔍 Escaneando proyecto en: /Users/user/code/my-app

✓ Frontend (Web)
  • JavaScript/TypeScript (package.json)
  • React 18.2.0 (package.json)
  • Vite (vite.config.js)

✓ Mobile (Android)
  • Kotlin (src/main/kotlin/*.kt)
  • Gradle (build.gradle.kts)
  • Firebase (build.gradle.kts)

✓ DevOps
  • Docker (Dockerfile)
  • GitHub Actions (.github/workflows)

⚠ Warnings:
  • No iOS detected
  • .env file detected (not read for security)

✔ Guardado en: .eurecatagent/brain/scan.json
```

---

## Tareas Específicas

### Sprint 1.1: Core Detection Logic (5-6 días)

#### Tarea 1.1.1: Definir Tipos de Datos

**Archivo:** `cli/internal/brain/types.go`

```go
// Stack detection types
type StackCategory string

const (
    Web     StackCategory = "web"
    Mobile  StackCategory = "mobile"
    Backend StackCategory = "backend"
    DevOps  StackCategory = "devops"
    Shared  StackCategory = "shared"
)

type Technology struct {
    Name       string   `json:"name"`
    Detected   bool     `json:"detected"`
    Version    string   `json:"version,omitempty"`
    Evidence   []string `json:"evidence"`   // Archivos donde se detectó
}

type StackType struct {
    Detected      bool                    `json:"detected"`
    Category      string                  `json:"category"`
    Confidence    string                  `json:"confidence"`  // high, medium, low
    Technologies  map[string]*Technology  `json:"technologies"`
}

type ScanResult struct {
    Version        string                  `json:"version"`
    ScannedAt      time.Time               `json:"scanned_at"`
    ProjectRoot    string                  `json:"project_root"`
    DetectedStacks map[string]*StackType   `json:"detected_stacks"`
    Warnings       []string                `json:"warnings"`
    ScanOptions    ScanOptions             `json:"scan_options"`
}

type ScanOptions struct {
    MaxDepth       int      `json:"max_depth"`
    IgnoreDirs     []string `json:"ignore_dirs"`
    FollowSymlinks bool     `json:"follow_symlinks"`
}
```

**Checklist:**
- [ ] Tipos compilados sin errores
- [ ] Marshaling/Unmarshaling a JSON funciona
- [ ] Tests básicos de tipos

---

#### Tarea 1.1.2: Implementar Detector Base

**Archivo:** `cli/internal/brain/detector.go`

```go
package brain

import (
    "os"
    "path/filepath"
    "strings"
)

type Detector interface {
    Detect(projectRoot string) *StackType
    Category() string
}

// WebDetector detecta web (React, Vue, Angular, etc.)
type WebDetector struct{}

func (d *WebDetector) Category() string {
    return "web"
}

func (d *WebDetector) Detect(projectRoot string) *StackType {
    st := &StackType{
        Category:     "web",
        Technologies: make(map[string]*Technology),
    }

    // Detectar package.json
    pkgJsonPath := filepath.Join(projectRoot, "package.json")
    if _, err := os.Stat(pkgJsonPath); err == nil {
        st.Detected = true
        st.Confidence = "high"
        
        // Buscar tecnologías dentro de package.json
        st.Technologies["JavaScript/TypeScript"] = &Technology{
            Name:     "JavaScript/TypeScript",
            Detected: true,
            Evidence: []string{pkgJsonPath},
        }
        
        // Detectar React
        if detectReactInPackageJson(projectRoot) {
            st.Technologies["React"] = &Technology{
                Name:     "React",
                Detected: true,
                Version:  getReactVersion(projectRoot),
                Evidence: []string{pkgJsonPath},
            }
        }
        
        // Detectar Vite
        if fileExists(filepath.Join(projectRoot, "vite.config.js")) ||
           fileExists(filepath.Join(projectRoot, "vite.config.ts")) {
            st.Technologies["Vite"] = &Technology{
                Name:     "Vite",
                Detected: true,
                Evidence: []string{"vite.config.js", "vite.config.ts"},
            }
        }
    }

    return st
}

// AndroidDetector
type AndroidDetector struct{}

func (d *AndroidDetector) Category() string {
    return "mobile"
}

func (d *AndroidDetector) Detect(projectRoot string) *StackType {
    st := &StackType{
        Category:     "mobile",
        Technologies: make(map[string]*Technology),
    }

    // Detectar build.gradle.kts
    buildGradlePath := filepath.Join(projectRoot, "build.gradle.kts")
    if _, err := os.Stat(buildGradlePath); err == nil {
        st.Detected = true
        st.Confidence = "high"
        
        st.Technologies["Kotlin"] = &Technology{
            Name:     "Kotlin",
            Detected: true,
            Evidence: []string{buildGradlePath},
        }
        
        st.Technologies["Gradle"] = &Technology{
            Name:     "Gradle",
            Detected: true,
            Evidence: []string{buildGradlePath},
        }
        
        // Detectar Firebase en build.gradle.kts
        if detectInFile(buildGradlePath, "firebase") {
            st.Technologies["Firebase"] = &Technology{
                Name:     "Firebase",
                Detected: true,
                Evidence: []string{buildGradlePath},
            }
        }
        
        // Detectar Koin en build.gradle.kts
        if detectInFile(buildGradlePath, "io.insert-koin") {
            st.Technologies["Koin"] = &Technology{
                Name:     "Koin",
                Detected: true,
                Evidence: []string{buildGradlePath},
            }
        }
    }

    return st
}

// Helpers
func fileExists(path string) bool {
    _, err := os.Stat(path)
    return err == nil
}

func detectInFile(filePath, searchStr string) bool {
    data, err := os.ReadFile(filePath)
    if err != nil {
        return false
    }
    return strings.Contains(strings.ToLower(string(data)), strings.ToLower(searchStr))
}

func detectReactInPackageJson(projectRoot string) bool {
    pkgJsonPath := filepath.Join(projectRoot, "package.json")
    return detectInFile(pkgJsonPath, "\"react\"")
}

func getReactVersion(projectRoot string) string {
    // Parse package.json y extraer versión
    // (Simplificado aquí, en realidad parsear JSON)
    return "18.x" // placeholder
}
```

**Checklist:**
- [ ] WebDetector compila
- [ ] AndroidDetector compila
- [ ] Tests unitarios para cada detector (15+ casos)
- [ ] No crash con archivos malformados

---

#### Tarea 1.1.3: Implementar Scanner

**Archivo:** `cli/internal/brain/scanner.go`

```go
package brain

import (
    "fmt"
    "os"
    "path/filepath"
    "time"
)

type Scanner struct {
    projectRoot string
    maxDepth    int
    ignoreDirs  map[string]bool
}

func NewScanner(projectRoot string) *Scanner {
    return &Scanner{
        projectRoot: projectRoot,
        maxDepth:    6,
        ignoreDirs: map[string]bool{
            "node_modules": true,
            ".git":         true,
            "build":        true,
            "dist":         true,
            ".gradle":      true,
            "target":       true,
            ".next":        true,
        },
    }
}

func (s *Scanner) Scan() (*ScanResult, error) {
    result := &ScanResult{
        Version:        "1.1",
        ScannedAt:      time.Now(),
        ProjectRoot:    s.projectRoot,
        DetectedStacks: make(map[string]*StackType),
        Warnings:       []string{},
        ScanOptions: ScanOptions{
            MaxDepth:       s.maxDepth,
            FollowSymlinks: false,
            IgnoreDirs:     s.getIgnoreDirsList(),
        },
    }

    // Ejecutar detectores
    detectors := []Detector{
        &WebDetector{},
        &AndroidDetector{},
        &iOSDetector{},
        &DevOpsDetector{},
    }

    for _, detector := range detectors {
        stackType := detector.Detect(s.projectRoot)
        if stackType.Detected {
            result.DetectedStacks[detector.Category()] = stackType
        }
    }

    // Detectar cosas raras
    s.detectWarnings(result)

    return result, nil
}

func (s *Scanner) detectWarnings(result *ScanResult) {
    // Detectar .env sin leer contenido
    if fileExists(filepath.Join(s.projectRoot, ".env")) {
        result.Warnings = append(result.Warnings, ".env file detected (not read for security)")
    }

    // Detectar google-services.json
    sensitiveFiles := []string{
        "google-services.json",
        "GoogleService-Info.plist",
        "local.properties",
        ".keystore",
    }

    for _, sensitiveFile := range sensitiveFiles {
        if fileExists(filepath.Join(s.projectRoot, sensitiveFile)) {
            result.Warnings = append(result.Warnings,
                fmt.Sprintf("Sensitive file detected: %s (not read)", sensitiveFile))
        }
    }

    // Advertencia si no se detectó iOS
    if _, ok := result.DetectedStacks["mobile"]; ok {
        if !detectiOS(s.projectRoot) {
            result.Warnings = append(result.Warnings, "No iOS/Swift files detected")
        }
    }
}

func (s *Scanner) getIgnoreDirsList() []string {
    var dirs []string
    for dir := range s.ignoreDirs {
        dirs = append(dirs, dir)
    }
    return dirs
}

// Detectores adicionales (iOS, DevOps)
// ... (similar a WebDetector y AndroidDetector)
```

**Checklist:**
- [ ] Scanner compila
- [ ] Scan sin errores en proyecto real
- [ ] Performance: <2s en proyectos típicos
- [ ] Warnings se detectan correctamente

---

### Sprint 1.2: CLI Integration (5-6 días)

#### Tarea 1.2.1: Implementar Comando CLI

**Archivo:** `cli/cmd/brain_scan.go`

```go
package cmd

import (
    "encoding/json"
    "fmt"
    "os"
    "path/filepath"

    "github.com/spf13/cobra"
    "your-module/internal/brain"
)

var brainScanCmd = &cobra.Command{
    Use:   "scan",
    Short: "Detecta automáticamente el stack del proyecto",
    Long: `Escanea el proyecto actual y detecta:
  • Lenguajes (JavaScript, Python, Go, Kotlin, Swift, Dart, etc.)
  • Frameworks (React, Django, Spring, Compose, SwiftUI, Flutter, etc.)
  • Librerías (Firebase, Koin, Redux, Alamofire, etc.)
  • DevOps (Docker, GitHub Actions, Kubernetes, etc.)

Genera .eurecatagent/brain/scan.json con resultados.`,
    RunE: func(cmd *cobra.Command, args []string) error {
        return runBrainScan(cmd)
    },
}

func runBrainScan(cmd *cobra.Command) error {
    // Obtener flags
    rootPath := cmd.Flag("root").Value.String()
    if rootPath == "" {
        rootPath = "."
    }

    absRoot, err := filepath.Abs(rootPath)
    if err != nil {
        return fmt.Errorf("invalid root path: %w", err)
    }

    showFlag, _ := cmd.Flags().GetBool("show")
    forceFlag, _ := cmd.Flags().GetBool("force")

    // Crear scanner
    scanner := brain.NewScanner(absRoot)
    result, err := scanner.Scan()
    if err != nil {
        return fmt.Errorf("scan failed: %w", err)
    }

    // Imprimir output legible
    printScanOutput(result)

    // Si --show, no guardar
    if showFlag {
        return nil
    }

    // Verificar si scan.json ya existe (a menos que --force)
    brainDir := filepath.Join(absRoot, ".eurecatagent/brain")
    scanJsonPath := filepath.Join(brainDir, "scan.json")

    if fileExists(scanJsonPath) && !forceFlag {
        fmt.Printf("⚠️  scan.json ya existe. Usa --force para sobrescribir.\n")
        return nil
    }

    // Guardar scan.json
    jsonData, err := json.MarshalIndent(result, "", "  ")
    if err != nil {
        return fmt.Errorf("marshal JSON failed: %w", err)
    }

    if err := os.WriteFile(scanJsonPath, jsonData, 0644); err != nil {
        return fmt.Errorf("write scan.json failed: %w", err)
    }

    fmt.Printf("✔ Guardado en: %s\n", scanJsonPath)
    return nil
}

func printScanOutput(result *brain.ScanResult) {
    fmt.Printf("🔍 Escaneando proyecto en: %s\n\n", result.ProjectRoot)

    // Imprimir stacks detectados
    for stackName, stackType := range result.DetectedStacks {
        emoji := "✓"
        fmt.Printf("%s %s (%s)\n", emoji, capitalizeFirst(stackName), stackType.Confidence)

        for techName, tech := range stackType.Technologies {
            if tech.Detected {
                versionStr := ""
                if tech.Version != "" {
                    versionStr = fmt.Sprintf(" %s", tech.Version)
                }
                fmt.Printf("  • %s%s\n", techName, versionStr)
            }
        }
        fmt.Println()
    }

    // Imprimir warnings
    if len(result.Warnings) > 0 {
        fmt.Println("⚠ Warnings:")
        for _, warning := range result.Warnings {
            fmt.Printf("  • %s\n", warning)
        }
        fmt.Println()
    }
}

func init() {
    brainCmd.AddCommand(brainScanCmd)
    
    brainScanCmd.Flags().String("root", ".", "Root directory to scan")
    brainScanCmd.Flags().Bool("show", false, "Show results without saving")
    brainScanCmd.Flags().Bool("force", false, "Overwrite existing scan.json")
}

func capitalizeFirst(s string) string {
    if len(s) == 0 {
        return s
    }
    return strings.ToUpper(string(s[0])) + s[1:]
}
```

**Checklist:**
- [ ] Comando compila
- [ ] `eurecat brain scan` funciona
- [ ] Flags `--root`, `--show`, `--force` funcionan
- [ ] Output es legible y tiene colores

---

#### Tarea 1.2.2: Integración con `context`

**Archivo:** `cli/cmd/brain_context.go` (mejorar existente)

```go
// Agregar a la función runBrainContext():

func runBrainContext(cmd *cobra.Command) error {
    // ... (código existente)
    
    // NUEVO: Incluir stack si existe scan.json
    sections, _ := cmd.Flags().GetString("section")
    
    if shouldIncludeSection(sections, "stack") {
        stackOutput := includeStackInContext(brainDir)
        fmt.Println(stackOutput)
    }
    
    // ... (resto del código)
}

func includeStackInContext(brainDir string) string {
    scanJsonPath := filepath.Join(brainDir, "scan.json")
    
    data, err := os.ReadFile(scanJsonPath)
    if err != nil {
        return "" // Si no existe scan.json, no mostrar
    }
    
    var result brain.ScanResult
    if err := json.Unmarshal(data, &result); err != nil {
        return ""
    }
    
    // Formatear como Markdown
    output := fmt.Sprintf("## Stack Detectado (%s)\n\n", result.ScannedAt.Format("2006-01-02"))
    
    for stackName, stackType := range result.DetectedStacks {
        output += fmt.Sprintf("### %s\n", capitalizeFirst(stackName))
        for techName, tech := range stackType.Technologies {
            if tech.Detected {
                output += fmt.Sprintf("- %s\n", techName)
            }
        }
        output += "\n"
    }
    
    return output
}
```

**Checklist:**
- [ ] `eurecat brain context --section stack` muestra stack
- [ ] Funciona sin scan.json (no crash)
- [ ] Formato Markdown correcto

---

## Arquitectura de Módulos

```
cli/
├── cmd/
│   ├── brain.go                ← grupo de comandos (EXISTE)
│   └── brain_scan.go           ← NUEVO: implementar Tarea 1.2.1
│
└── internal/brain/
    ├── types.go                ← NUEVO: Tarea 1.1.1
    ├── detector.go             ← NUEVO: Tarea 1.1.2 (interfaces + Web, Android)
    ├── ios_detector.go         ← NUEVO: iOS detection
    ├── devops_detector.go      ← NUEVO: Docker, GitHub Actions, etc.
    ├── scanner.go              ← NUEVO: Tarea 1.1.3 (orquestar detectores)
    └── helpers.go              ← NUEVO: fileExists, detectInFile, etc.
```

---

## Ejemplos de Código

### Ejemplo 1: Detectar React en package.json

```go
func detectReactInPackageJson(projectRoot string) bool {
    pkgJsonPath := filepath.Join(projectRoot, "package.json")
    
    data, err := os.ReadFile(pkgJsonPath)
    if err != nil {
        return false
    }
    
    // Simple substring match (en práctica, parsear JSON)
    return strings.Contains(string(data), "\"react\"")
}
```

### Ejemplo 2: Extraer versión de Firebase

```go
func getFirebaseVersion(buildGradlePath string) string {
    data, _ := os.ReadFile(buildGradlePath)
    content := string(data)
    
    // Buscar línea como: com.google.firebase:firebase-bom:33.0.0
    lines := strings.Split(content, "\n")
    for _, line := range lines {
        if strings.Contains(line, "firebase-bom") {
            parts := strings.Split(line, ":")
            if len(parts) >= 3 {
                return parts[len(parts)-1]
            }
        }
    }
    return ""
}
```

### Ejemplo 3: Detectar Docker

```go
type DevOpsDetector struct{}

func (d *DevOpsDetector) Detect(projectRoot string) *StackType {
    st := &StackType{
        Category:     "devops",
        Technologies: make(map[string]*Technology),
    }

    // Detectar Docker
    if fileExists(filepath.Join(projectRoot, "Dockerfile")) ||
       fileExists(filepath.Join(projectRoot, "docker-compose.yml")) {
        st.Detected = true
        st.Confidence = "high"
        
        st.Technologies["Docker"] = &Technology{
            Name:     "Docker",
            Detected: true,
            Evidence: []string{"Dockerfile", "docker-compose.yml"},
        }
    }

    // Detectar GitHub Actions
    ghActionsDir := filepath.Join(projectRoot, ".github/workflows")
    if _, err := os.Stat(ghActionsDir); err == nil {
        st.Detected = true
        
        st.Technologies["GitHub Actions"] = &Technology{
            Name:     "GitHub Actions",
            Detected: true,
            Evidence: []string{".github/workflows"},
        }
    }

    return st
}
```

---

## Output Esperado

### Terminal Output

```bash
$ eurecat brain scan

🔍 Escaneando proyecto en: /Users/ivan/code/eurecat-agent

✓ Frontend (Web)
  • JavaScript/TypeScript
  • React 18.2.0
  • Vite
  • npm

✓ Mobile (Android)
  • Kotlin
  • Gradle (build.gradle.kts)
  • Firebase

✓ DevOps
  • Docker
  • GitHub Actions

⚠ Warnings:
  • No iOS detected
  • .env file detected (not read for security)

✔ Guardado en: .eurecatagent/brain/scan.json
```

### scan.json Output

```json
{
  "version": "1.1",
  "scanned_at": "2026-05-27T14:30:45Z",
  "project_root": "/Users/ivan/code/eurecat-agent",
  "detected_stacks": {
    "web": {
      "detected": true,
      "category": "web",
      "confidence": "high",
      "technologies": {
        "JavaScript/TypeScript": {
          "name": "JavaScript/TypeScript",
          "detected": true,
          "evidence": ["package.json", "tsconfig.json"]
        },
        "React": {
          "name": "React",
          "detected": true,
          "version": "18.2.0",
          "evidence": ["package.json"]
        }
      }
    },
    "devops": {
      "detected": true,
      "category": "devops",
      "confidence": "high",
      "technologies": {
        "Docker": {
          "name": "Docker",
          "detected": true,
          "evidence": ["Dockerfile"]
        }
      }
    }
  },
  "warnings": [
    "No iOS detected",
    ".env file detected (not read for security)"
  ],
  "scan_options": {
    "max_depth": 6,
    "follow_symlinks": false,
    "ignore_dirs": ["node_modules", ".git", "build", "dist"]
  }
}
```

---

## Testing Strategy

### Unit Tests (70% de cobertura)

**`detector_test.go`:**
```go
func TestWebDetectorReact(t *testing.T) {
    tmpDir := createTempProject(t, map[string]string{
        "package.json": `{"dependencies": {"react": "18.2.0"}}`,
    })
    
    detector := &WebDetector{}
    result := detector.Detect(tmpDir)
    
    assert.True(t, result.Detected)
    assert.NotNil(t, result.Technologies["React"])
    assert.Equal(t, "18.2.0", result.Technologies["React"].Version)
}

func TestAndroidDetectorKoin(t *testing.T) {
    tmpDir := createTempProject(t, map[string]string{
        "build.gradle.kts": `dependencies { implementation("io.insert-koin:koin-android:3.5.0") }`,
    })
    
    detector := &AndroidDetector{}
    result := detector.Detect(tmpDir)
    
    assert.True(t, result.Detected)
    assert.NotNil(t, result.Technologies["Koin"])
}

func TestScannerPerformance(t *testing.T) {
    // Asegurar que scan <2s en proyecto típico
    start := time.Now()
    scanner := NewScanner(".")
    scanner.Scan()
    elapsed := time.Since(start)
    
    assert.Less(t, elapsed, 2*time.Second)
}
```

### Integration Tests (10%)

```bash
# Crear proyecto real, ejecutar scan, verificar scan.json
#!/bin/bash
mkdir -p test-project/src
echo '{"name": "test", "dependencies": {"react": "18.0.0"}}' > test-project/package.json

eurecat brain scan --root test-project
assert_file_exists test-project/.eurecatagent/brain/scan.json
```

### E2E Tests (5%)

```go
func TestBrainScanE2E(t *testing.T) {
    // Ejecutar comando completo
    cmd := exec.Command("eurecat", "brain", "scan", "--root", ".")
    output, err := cmd.CombinedOutput()
    
    assert.NoError(t, err)
    assert.Contains(t, string(output), "✔ Guardado en:")
}
```

---

## Criterios de Aceptación

### Funcionalidad

- ✅ Detecta Web (React, Vue, Vite, webpack, npm, yarn, pnpm)
- ✅ Detecta Android (Kotlin, Gradle, Firebase, Koin, Compose)
- ✅ Detecta iOS (Swift, CocoaPods, SwiftUI)
- ✅ Detecta DevOps (Docker, GitHub Actions, CI/CD)
- ✅ Genera scan.json correcto
- ✅ Warnings para casos especiales (.env, sensibles)
- ✅ `--show` no guarda
- ✅ `--force` sobrescribe existente
- ✅ Performance <2s

### Calidad de Código

- ✅ 70%+ test coverage
- ✅ Cero panics en archivos malformados
- ✅ Sigue Go conventions (golint OK)
- ✅ Code review sin comments importantes

### UX

- ✅ Output legible con emojis
- ✅ Warnings claros
- ✅ Mensajes de error útiles
- ✅ `--help` documentado

### Compatibilidad

- ✅ Backward compatible (no rompe v1.0)
- ✅ Funciona offline (sin network calls)
- ✅ Cross-platform (macOS, Linux, Windows)

---

## Timeline Realista

```
Semana 1 (Sprint 1.1):
  Día 1-2:  Tarea 1.1.1 (tipos.go) — 4 horas
  Día 2-3:  Tarea 1.1.2 (detector.go) — 6 horas
  Día 4-5:  Tarea 1.1.3 (scanner.go) — 6 horas
  Día 5-6:  Tests unitarios — 4 horas
  SUBTOTAL: 20 horas

Semana 2 (Sprint 1.2):
  Día 1-2:  Tarea 1.2.1 (brain_scan.go) — 6 horas
  Día 2-3:  Tarea 1.2.2 (integración context) — 4 horas
  Día 4-5:  Tests E2E — 4 horas
  Día 5-6:  Code review + fixes — 4 horas
  SUBTOTAL: 18 horas

TOTAL: 38 horas ~= 1.5 sprints (a 2 semanas)
```

---

## Próximos Pasos Después de Fase 1

1. ✅ Fase 1 completada: `eurecat brain scan` funcional
2. 🔲 Fase 2: `eurecat brain review` (auditoría)
3. 🔲 Fase 3: `eurecat brain promote`/`bump` (ciclo de vida)
4. 🔲 Fase 4: Documentación + Release

---

## Resumen

**Fase 1** es una foundación sólida:
- Detectores limpios y extensibles
- CLI integrada correctamente
- Tests exhaustivos
- Bajo riesgo (es detección, no mutación)

Una vez que Fase 1 está lista y aprobada, las Fases 2-3 se vuelven mucho más simples porque ya tienes la infraestructura base.

