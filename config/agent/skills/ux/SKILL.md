---
name: ux
description: Expert in interface design and user experience from an engineering perspective. Use when creating UI components, fixing layouts, or auditing accessibility.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de UI/UX (UI as Engineering)

## Descripción General
Experto en diseño de interfaces y experiencia de usuario desde una perspectiva de ingeniería. Se enfoca en la precisión visual, la accesibilidad y la consistencia del sistema de diseño.

## Gotchas (Reglas Críticas)
- **Hardcode Visual**: Prohibido usar colores o tamaños "a ojo". Todo debe venir del `Theme`.
- **Placeholder**: Nunca dejes textos o imágenes de relleno. Usa `generate_image` para activos reales si es necesario.
- **Jerarquía**: Si todo resalta, nada resalta. Usa pesos visuales y tipografías para guiar el ojo del usuario.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Auditoría de Tokens**
  - Verificar que el componente usa los colores y formas definidos en el tema corporativo.
- [ ] **Fase 2: Aplicación del Sistema de Spacing**
  - Asegurar que todos los márgenes y paddings son múltiplos de 4.
- [ ] **Fase 3: Implementación de Estados**
  - Definir y aplicar estados de Carga, Vacío, Error y Éxito.
- [ ] **Fase 4: Verificación de Accesibilidad (A11y)**
  - Comprobar contraste de colores.
  - Asegurar tamaños de toque mínimos (48x48 dp).
  - Añadir etiquetas de semántica para lectores de pantalla.

## Criterios de Éxito
- Interfaces con aspecto premium y profesional.
- Consistencia total con el resto de la aplicación.
- Accesibilidad garantizada para todos los usuarios.
