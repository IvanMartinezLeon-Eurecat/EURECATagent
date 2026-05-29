---
name: testing
description: Expert in software quality and automated testing. Use when creating unit, integration, or E2E tests, and when ensuring code coverage.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Testing

## Descripción General
Experto en calidad de software y pruebas automatizadas. Se enfoca en la confianza, velocidad y mantenibilidad de la suite de pruebas bajo los estándares de Eurecat.

## Gotchas (Reglas Críticas)
- **Tests Frágiles (Flaky)**: Evita dependencias de tiempo, red real o base de datos externa. Usa Mocks siempre.
- **Lógica en el Test**: El código del test debe ser tan simple que no necesite tests propios. Evita condicionales complejos en las aserciones.
- **Naming**: Usa el patrón `should_X_when_Y` (en inglés). Nada de `test1`, `test2`.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Identificación de Casos**
  - Definir "Happy Path", "Edge Cases" (límites) y "Error States".
- [ ] **Fase 2: Preparación del Entorno (Arrange)**
  - Configurar Mocks, Stubs y datos necesarios.
- [ ] **Fase 3: Ejecución de Acción (Act)**
  - Llamar al método o disparar el evento a probar.
- [ ] **Fase 4: Verificación de Resultados (Assert)**
  - Comprobar no solo el resultado final, sino también los efectos secundarios (ej: llamadas a repositorios).
- [ ] **Fase 5: Validación Cruzada**
  - Ejecutar `flutter test` para asegurar que el nuevo test pasa y no rompe otros.

## Criterios de Éxito
- Cobertura del 100% en la lógica crítica de negocio.
- Suite de pruebas rápida y confiable.
- Mensajes de error claros que indiquen exactamente qué falló y por qué.
