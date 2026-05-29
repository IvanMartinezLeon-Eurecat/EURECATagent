---
name: fix
description: Specialist in diagnosing and resolving technical issues, bugs, and lints. Use when fixing compilation errors, runtime exceptions, or logic bugs.
metadata:
  author: eurecat.org
  version: "2.0"
---
# Skill de Corrección de Errores (Fix)

## Descripción General
Especialista en diagnóstico y resolución de problemas técnicos. Experto en lectura de logs, depuración de estado y corrección de regresiones. Funciona con cualquier lenguaje o framework.

## Gotchas (Reglas Críticas)
- **Arreglos "Parche"**: No te limites a ocultar el error. Encuentra la causa raíz.
- **Regresiones**: Cada vez que arregles algo, verifica que no has roto otra funcionalidad relacionada.
- **Lints**: No ignores los warnings del compilador/linter. Un warning hoy es un crash mañana.
- **Un cambio a la vez**: Cambia una sola cosa y verifica antes de pasar a la siguiente.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Reproducción Confiable**
  - Identificar los pasos mínimos para provocar el fallo.
  - Si es posible, crear un test que falle (Red) antes de corregir.
- [ ] **Fase 2: Aislamiento del Error**
  - Determinar si el fallo es de datos (API/DB), lógica (servicio/controlador) o presentación (UI/componente).
  - Usar logs, depurador, o herramientas del lenguaje (`strace`, `lsof`, browser devtools, etc.).
- [ ] **Fase 3: Aplicación de la Corrección**
  - Aplicar el cambio mínimo necesario que solucione el problema.
  - Seguir los estándares de naming y estilo del proyecto.
- [ ] **Fase 4: Validación y Limpieza**
  - Ejecutar el linter y los tests del proyecto (`npm test`, `go test`, `pytest`, etc.).
  - Asegurar que la solución es escalable y no una excepción puntual.
  - Si el bug es recurrente o el workaround no obvio, preguntar si se guarda en la memoria del proyecto.

## Criterios de Éxito
- El error se reproduce, se corrige y no reaparece en regresiones.
- La solución está documentada (comentario, test, o learning persistido).
- No se introducen nuevos warnings ni deuda técnica.
