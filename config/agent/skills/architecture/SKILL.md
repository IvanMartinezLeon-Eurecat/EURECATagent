---
name: architecture
description: Expert in software architecture, modularity, and system design. Use when evaluating structure, dependencies, or planning large refactors. Framework-agnostic.
metadata:
  author: eurecat.org
  version: "2.0"
---
# Skill de Arquitectura de Software

## Descripción General
Experto en arquitectura de software, modularidad y diseño de sistemas. Se enfoca en crear sistemas escalables, mantenibles y desacoplados. Aplica principios SOLID, separación de responsabilidades y gestión de dependencias. Funciona con cualquier lenguaje o framework.

## Gotchas (Reglas Críticas)
- **Acoplamiento Oculto**: Evita importaciones cruzadas entre módulos. Todo paso de datos debe ser via API pública o interfaz.
- **Sobreingeniería**: No apliques patrones complejos (Hexagonal, CQRS, Event Sourcing) si una solución simple resuelve el problema.
- **Lógica en Presentación**: Prohibido poner lógica de negocio en la capa de UI, controladores HTTP o handlers. La lógica pertenece a la capa de dominio/servicio.
- **Dependencias**: Las dependencias deben apuntar hacia adentro (las capas de negocio no deben depender de frameworks o drivers externos).

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Análisis de Dependencias**
  - Identificar el módulo afectado y sus dependencias actuales.
  - Verificar si el cambio rompe el "Contrato de Arquitectura" (acoplamientos permitidos vs prohibidos).
- [ ] **Fase 2: Diseño de la Interfaz (API Pública)**
  - Definir qué expondrá el módulo al resto del sistema.
  - Asegurar que los detalles internos permanezcan privados.
- [ ] **Fase 3: Implementación por Capas**
  - Separar en: Dominio (lógica de negocio), Aplicación (casos de uso), Infraestructura (DB, APIs externas), Presentación (UI/API endpoints).
- [ ] **Fase 4: Verificación de Aislamiento**
  - Intentar "borrar" mentalmente el módulo: ¿se rompe el resto del sistema? Si no, el aislamiento es correcto.

## Criterios de Éxito
- Sistema modular: cambiar un módulo no requiere cambiar otros.
- Dependencias claras y unidireccionales.
- La lógica de negocio es testeable sin infraestructura real.
- Un nuevo desarrollador puede entender la estructura del proyecto en minutos.
