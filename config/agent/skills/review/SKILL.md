---
name: review
description: Expert in code review, quality control, and security. Use when reviewing pull requests, checking coding standards, or finding optimizations.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Revisión de Código (Review)

## Descripción General
Experto en control de calidad y revisión de código. Se enfoca en asegurar que el código sea limpio, performante y cumpla estrictamente con los estándares de Eurecat.

## Gotchas (Reglas Críticas)
- **Idioma del Código**: Todo código técnico (variables, funciones, etc.) DEBE estar en inglés. No dejes pasar términos en otros idiomas.
- **Detección de "Code Smells"**: No te limites a la sintaxis. Busca falta de cohesión, métodos gigantes o dependencias circulares.
- **Mensajes de Error**: Verifica que los mensajes de error al usuario estén localizados y no expongan internals.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Verificación de Estándares (Linting)**
  - Comprobar naming (camelCase en Dart).
  - Verificar sistema de spacing (múltiplos de 4).
- [ ] **Fase 2: Análisis de Lógica y SOLID**
  - ¿Cumple cada clase con una única responsabilidad?
  - ¿Es el código fácil de probar (testable)?
- [ ] **Fase 3: Optimización y Seguridad**
  - Buscar bucles ineficientes o fugas de memoria.
  - Verificar validación de inputs y manejo de nulos.
- [ ] **Fase 4: Feedback Constructivo**
  - Generar un resumen de cambios necesarios agrupados por severidad (Crítico vs Sugerencia).

## Criterios de Éxito
- Feedback accionable y profesional.
- Detección proactiva de deuda técnica.
- Garantía de consistencia en todo el repositorio.
