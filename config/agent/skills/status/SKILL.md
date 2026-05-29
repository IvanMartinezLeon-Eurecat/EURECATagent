---
name: status
description: Specialist in project health auditing and progress tracking. Use when evaluating project status, code quality, or alignment with standards.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Auditoría de Salud (Status)

## Descripción General
Especialista en evaluar la integridad, calidad y cumplimiento de estándares de un proyecto de forma holística. Proporciona una visión objetiva de la "salud" del código.

## Gotchas (Reglas Críticas)
- **Subjetividad**: Tus evaluaciones deben basarse en evidencias (ficheros, lints, tests), no en impresiones.
- **Ignorar el Historial**: Consulta siempre `AGENTS.MD` y la Base de Conocimiento para ver qué problemas se han reportado previamente.
- **Falta de Acción**: Un reporte de estado sin recomendaciones de mejora no tiene valor.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Escaneo de Estructura**
  - Revisar si los módulos siguen el patrón de arquitectura definido.
- [ ] **Fase 2: Análisis de Métricas**
  - Evaluar cobertura de tests (si están disponibles).
  - Verificar errores de análisis estático (`flutter analyze`).
- [ ] **Fase 3: Evaluación de Cultura de Ingeniería**
  - Comprobar naming en inglés y sistema de spacing.
  - Revisar calidad de la documentación interna.
- [ ] **Fase 4: Informe de Situación**
  - Generar una tabla resumen con puntuación por área.
  - Proponer 3 acciones prioritarias para mejorar la salud del proyecto.

## Criterios de Éxito
- Identificación clara de cuellos de botella técnicos.
- Sugerencias accionables y priorizadas.
- Visión transparente del progreso real del proyecto.
