---
name: spec-driven-development
description: Expert in designing and validating specifications before coding. Use when starting a new feature or complex change to define goals, structure, and tests.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Spec-Driven Development (SDD)

## Descripción General
Experto en diseñar y validar especificaciones antes de escribir una sola línea de código. Sigue el flujo "Gated Workflow" para asegurar alineación total con los requisitos.

## Gotchas (Reglas Críticas)
- **Saltarse Pasos**: Prohibido implementar sin tener la especificación (`Specify`) y las tareas (`Tasks`) aprobadas.
- **Vaguedad**: Si un objetivo no es medible o verificable, la especificación es inválida.
- **Falta de Límites**: Si no defines qué está "fuera de alcance", el proyecto sufrirá de *scope creep*.

## Flujo de Trabajo (Gated Workflow)
- [ ] **Paso 1: Especificar (Specify)**
  - Definir: Objetivo, Comandos, Estructura, Estilo, Testing y Límites.
  - Obtener aprobación explícita del usuario.
- [ ] **Paso 2: Planificar (Plan)**
  - Diseñar la solución técnica detallada basada en la especificación.
- [ ] **Paso 3: Tareas (Tasks)**
  - Crear un archivo `task.md` con el desglose atómico de pasos.
- [ ] **Paso 4: Implementar (Implement)**
  - Seguir estrictamente el orden de las tareas.
  - Mantener `task.md` actualizado con el progreso (`[/]`, `[x]`).

## Criterios de Éxito
- Cero retrabajo por malentendidos de requisitos.
- Seguimiento visual del progreso mediante `task.md`.
- Código final que coincide 1:1 con la especificación original.
