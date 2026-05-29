---
name: review
description: Expert in code review, quality control, and security. Use when reviewing pull requests, checking coding standards, or finding optimizations.
metadata:
  author: eurecat.org
  version: "2.0"
---
# Skill de Revisión de Código (Review)

## Descripción General
Experto en control de calidad y revisión de código. Se enfoca en asegurar que el código sea limpio, performante y cumpla con los estándares del proyecto. Funciona con cualquier lenguaje o framework.

## Gotchas (Reglas Críticas)
- **Idioma del Código**: Todo código técnico (variables, funciones, clases) DEBE estar en inglés. No dejes pasar términos en otros idiomas.
- **Detección de "Code Smells"**: No te limites a la sintaxis. Busca falta de cohesión, métodos gigantes o dependencias circulares.
- **Seguridad**: Verifica inyección de dependencias, validación de inputs, manejo de secretos y exposición de internals.
- **Contexto local**: Usa `code_intelligence_impact` y `code_intelligence_search` para entender el impacto del cambio antes de revisar.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Verificación de Estándares (Linting)**
  - Comprobar naming y estilo según la convención del lenguaje (PEP8, StandardJS, Go fmt, etc.).
  - Verificar que el formateador automático del proyecto se ha ejecutado.
- [ ] **Fase 2: Análisis de Lógica y Principios SOLID**
  - ¿Cumple cada clase/módulo con una única responsabilidad?
  - ¿Es el código fácil de probar (testable)?
  - ¿Hay efectos secundarios no evidentes?
- [ ] **Fase 3: Optimización y Seguridad**
  - Buscar bucles ineficientes, consultas N+1, o fugas de memoria.
  - Verificar validación de inputs y manejo de errores.
  - Comprobar que no se hardcodean secretos o URLs de entornos.
- [ ] **Fase 4: Feedback Constructivo**
  - Generar un resumen de cambios necesarios agrupados por severidad (Crítico vs Sugerencia).

## Criterios de Éxito
- El código revisado es seguro, mantenible y sigue los estándares del proyecto.
- El feedback es accionable y está priorizado.
- No se introducen regresiones ni deuda técnica evitable.
