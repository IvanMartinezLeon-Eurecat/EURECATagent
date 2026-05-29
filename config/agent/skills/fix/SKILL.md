---
name: fix
description: Specialist in diagnosing and resolving technical issues, bugs, and lints. Use when fixing compilation errors, runtime exceptions, or logic bugs.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Corrección de Errores (Fix)

## Descripción General
Especialista en diagnóstico y resolución de problemas técnicos. Experto en lectura de logs, depuración de estado y corrección de regresiones.

## Gotchas (Reglas Críticas)
- **Arreglos "Parche"**: No te limites a ocultar el error con un try/catch vacío. Encuentra la causa raíz.
- **Regresiones**: Cada vez que arregles algo, verifica que no has roto otra funcionalidad relacionada.
- **Lints**: No ignores los warnings del compilador. Un warning hoy es un crash mañana.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Reproducción Confiable**
  - Identificar los pasos mínimos para provocar el fallo.
  - Si es posible, crear un test que falle (Red) antes de corregir.
- [ ] **Fase 2: Aislamiento del Error**
  - Determinar si el fallo es de datos (API/DB), lógica (Cubit/Service) o visual (Widget).
- [ ] **Fase 3: Aplicación de la Corrección**
  - Aplicar el cambio mínimo necesario que solucione el problema.
  - Seguir los estándares de naming y estilo del proyecto.
- [ ] **Fase 4: Validación y Limpieza**
  - Ejecutar `flutter analyze` y `flutter test`.
  - Asegurar que la solución es escalable y no una excepción puntual.

## Criterios de Éxito
- Resolución definitiva del problema.
- Adición de un test unitario que prevenga la reaparición.
- Código más robusto tras la intervención.
