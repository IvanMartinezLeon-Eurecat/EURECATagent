---
name: workflow-coordination
description: Specialist in safe concurrent execution, conflict prevention, and worktree isolation for multi-agent workflows.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Coordinación de Workflows

## Descripción General
Experto en ejecución segura de flujos multi-agente. Se enfoca en prevenir conflictos de archivos, coordinar workers concurrentes y asegurar que los subagentes no se pisen entre sí.

## Modelo de Confianza (Thread Safety)

| Agente | Permiso de escritura | Puede ejecutarse en paralelo |
|---|---|---|
| **generic-context-builder** | ❌ Solo lectura | ✅ Sí, seguro |
| **generic-planner** | ❌ Solo lectura | ✅ Sí, seguro |
| **generic-reviewer** | ❌ Solo lectura (review-only) | ✅ Sí, seguro |
| **generic-worker** | ✅ Escribe archivos | ❌ No, single writer |
| **scout** | ❌ Solo lectura | ✅ Sí, seguro |
| **researcher** | ❌ Solo lectura | ✅ Sí, seguro |

## Reglas de Coordinación

### 1. Workers nunca en paralelo

Dos `generic-worker` ejecutándose a la vez **siempre** producirán conflictos. Usa siempre cadenas secuenciales:

```text
✅ Correcto: chain secuencial
  planner → worker → reviewer

❌ Incorrecto: workers paralelos
  worker "feature A"  +  worker "feature B"  # ← conflicto garantizado
```

### 2. Aislar workers con `worktree` (si es unavoidable)

Si por algún caso necesitas workers concurrentes (ej: dos features independientes), usa `worktree: true`:

```text
/parallel
  tasks:
    - agent: generic-worker
      task: "feature A"
    - agent: generic-worker
      task: "feature B"
  concurrency: 2
  worktree: true    # ← crea worktrees aislados
```

Cada worker opera en su propio worktree de git. Los cambios no se solapan.

### 3. Read-only agents son seguros en paralelo

`context-builder`, `planner`, `reviewer`, `scout`, `researcher` solo leen archivos. Puedes lanzarlos en paralelo sin riesgo:

```text
✅ Seguro: revisión paralela
  reviewer "ángulo 1"  +  reviewer "ángulo 2"
```

### 4. Ramas de git para aislamiento

Para cambios grandes, cada worker debería operar en su propia rama:

```bash
git checkout -b feature/worker-A
# worker implementa aquí
git checkout -b feature/worker-B
# otro worker implementa aquí
```

Luego se fusionan ordenadamente.

### 5. Detección de conflicto temprana

El `generic-worker` debe, antes de empezar a escribir:
- Verificar `git status` — si hay cambios sin commit, parar y avisar.
- Verificar que nadie más está escribiendo (no hay señal de "writer ocupado").
- Si encuentra conflicto, reportarlo con `contact_supervisor` en vez de sobrescribir.

## Flujo Recomendado para Cambios

```
[Idea] → scout → context-builder → planner → worker → reviewer
         (read)    (read)           (read)   (write)  (read-only)
```

Este flujo es inherentemente seguro porque:
- Las fases de lectura pueden paralelizarse entre sí
- La escritura ocurre una sola vez, al final
- La revisión post-escritura verifica que no hay regresiones

## Criterios de Éxito
- Nunca dos workers escribiendo a la vez sin worktree.
- Worktrees usados para toda ejecución paralela de workers.
- Los read-only agents se lanzan sin restricciones de concurrencia.
- Cualquier conflicto detectado se reporta, no se sobrescribe silenciosamente.
