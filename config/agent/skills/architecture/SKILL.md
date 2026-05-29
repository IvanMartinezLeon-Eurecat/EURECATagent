---
name: architecture
description: Expert in software architecture, modularity, and system design. Use when evaluating structure, dependencies, or planning large refactors.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Arquitectura

## Descripción General
Experto en arquitectura de software, modularidad y diseño de sistemas. Se enfoca en crear sistemas escalables, mantenibles y desacoplados bajo los estándares de Eurecat.

## Gotchas (Reglas Críticas)
- **Acoplamiento Oculto**: Evita importaciones cruzadas entre módulos de features. Todo paso de datos debe ser via API pública.
- **Sobreingeniería**: No apliques patrones complejos (ej. Hexagonal completo) si un Cubit simple resuelve el problema.
- **Lógica en UI**: Prohibido cálculos pesados o lógica de negocio dentro del método `build`.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Análisis de Dependencias**
  - Identificar el módulo afectado y sus dependencias actuales.
  - Verificar si el cambio rompe el "Contrato de Arquitectura".
- [ ] **Fase 2: Diseño de la Interfaz (API Pública)**
  - Definir qué expondrá el módulo al resto de la app.
  - Asegurar que los modelos internos permanezcan privados.
- [ ] **Fase 3: Implementación por Capas**
  - Implementar Dominio (Entidades y Contratos).
  - Implementar Capa de Datos (Repositorios).
  - Implementar Presentación (Bloc/Cubit y Widgets).
- [ ] **Fase 4: Verificación de Aislamiento**
  - Intentar "borrar" mentalmente el módulo: ¿se rompe el resto de la app? Si no, el aislamiento es correcto.

## Criterios de Éxito
- Bajo acoplamiento y alta cohesión.
- Direcciones de dependencia claras (Dominio -> Datos -> UI).
- Cumplimiento del Contrato de Arquitectura del proyecto.
