---
name: api-design
description: Expert in designing and reviewing APIs (REST, GraphQL). Use when defining endpoints, contracts, error handling, versioning, or client-server communication.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Diseño de APIs

## Descripción General
Experto en diseño de APIs REST y GraphQL. Se enfoca en crear interfaces consistentes, predecibles y fáciles de consumir. Aplica principios RESTful y convenciones estándar de la industria.

## Gotchas (Reglas Críticas)
- **Naming de recursos**: Usa sustantivos en plural (`/users`, `/orders`). No uses verbos en la URL (`/getUsers`, `/createOrder`). Los verbos son para los métodos HTTP.
- **Métodos HTTP correctos**: GET (leer), POST (crear), PUT (reemplazar), PATCH (actualizar parcial), DELETE (borrar). No uses POST para todo.
- **Códigos de estado**: Usa los códigos HTTP adecuados (200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 500 Internal Server Error).
- **Versionado**: Las APIs deben versionarse desde el día 1 (`/v1/`, `/v2/` o header `Accept: application/vnd.api+json;version=1`).
- **Errores consistentes**: Todos los errores deben tener una estructura uniforme: `{ error: { code, message, details? } }`.

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Definición de Recursos**
  - Identificar las entidades del dominio y sus relaciones.
  - Definir endpoints RESTful: `GET /v1/resource`, `POST /v1/resource`, etc.
- [ ] **Fase 2: Contrato de Datos**
  - Definir esquemas de request/response (tipos, campos obligatorios, formatos).
  - Documentar con OpenAPI (Swagger) o GraphQL SDL.
- [ ] **Fase 3: Manejo de Errores**
  - Definir estructura de error consistente para toda la API.
  - Asegurar que los mensajes de error son descriptivos pero no exponen internals.
- [ ] **Fase 4: Paginación, Filtros y Ordenación**
  - Paginación consistente: `?page=1&limit=20` con metadatos en respuesta (`{ total, page, limit, data: [...] }`).
  - Filtros con query params predecibles (`?status=active`).
  - Ordenación con `?sort=field` y `?sort=-field` (descendente).
- [ ] **Fase 5: Revisión de Seguridad**
  - Verificar autenticación y autorización en cada endpoint.
  - Ratelimiting, validación de payload, sanitización de parámetros.

## Criterios de Éxito
- API consistente: misma estructura de respuesta, mismo formato de error, mismos patrones en toda la superficie.
- Contrato claro y documentado (OpenAPI, Postman collection, o GraphQL schema).
- Consumidores pueden integrarse sin leer el código del backend.
- Cambios de API no rompen a clientes existentes (versionado y backward compatibility).
