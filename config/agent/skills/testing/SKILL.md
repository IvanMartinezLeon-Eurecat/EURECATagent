---
name: testing
description: Expert in software quality and automated testing. Use when creating unit, integration, or E2E tests, and when ensuring code coverage.
metadata:
  author: eurecat.org
  version: "2.0"
---
# Skill de Testing

## Descripción General
Experto en calidad de software y pruebas automatizadas. Se enfoca en la confianza, velocidad y mantenibilidad de la suite de pruebas. Funciona con cualquier framework de testing (Jest, pytest, Go test, JUnit, etc.).

## Gotchas (Reglas Críticas)
- **Tests Frágiles (Flaky)**: Evita dependencias de tiempo, red real o base de datos externa. Usa Mocks/Stubs y controla el estado.
- **Lógica en el Test**: El código del test debe ser tan simple que no necesite tests propios. Evita condicionales complejos en las aserciones.
- **Naming**: Usa el patrón `should_X_when_Y` o similar (en inglés). Nada de `test1`, `test2`, `test_func`.
- **Cobertura**: No persigas el 100% a cualquier precio. Prioriza caminos críticos, casos borde y estados de error.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Identificación de Casos**
  - Definir "Happy Path", "Edge Cases" (límites) y "Error States".
- [ ] **Fase 2: Preparación del Entorno (Arrange)**
  - Configurar Mocks, Stubs y datos necesarios.
  - Aislar dependencias externas (API, DB, sistema de ficheros).
- [ ] **Fase 3: Ejecución de Acción (Act)**
  - Llamar al método o disparar el evento a probar.
- [ ] **Fase 4: Verificación de Resultados (Assert)**
  - Comprobar no solo el resultado final, sino también los efectos secundarios (ej: llamadas a servicios, estado mutado).
- [ ] **Fase 5: Validación Cruzada**
  - Ejecutar el comando de tests del proyecto (`npm test`, `go test ./...`, `pytest`, etc.) para asegurar que el nuevo test pasa y no rompe otros.
  - Verificar que los tests son independientes entre sí (no comparten estado mutable).

## Criterios de Éxito
- Suite de tests rápida, determinista y mantenible.
- Los tests fallan por razones claras y dan contexto suficiente para depurar.
- Cobertura significativa en caminos críticos y casos borde, sin obsesión por métricas.
