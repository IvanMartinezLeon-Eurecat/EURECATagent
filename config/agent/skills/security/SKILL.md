---
name: security
description: Expert in application security, vulnerability detection, and secure coding practices. Use when reviewing code for security issues, handling secrets, or validating inputs.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Seguridad (Security)

## Descripción General
Experto en seguridad de aplicaciones. Se enfoca en identificar y prevenir vulnerabilidades comunes en cualquier language y framework. Aplica el OWASP Top 10 como referencia base.

## Gotchas (Reglas Críticas)
- **Secretos en código**: Prohibido hardcodear API keys, tokens, contraseñas o URLs de entornos. Usa variables de entorno o gestores de secretos.
- **Validación de inputs**: Nunca confíes en datos de usuario, headers, query params o cuerpos de petición. Valida tipo, longitud, rango y formato.
- **Inyección**: Usa queries parametrizadas (SQL, NoSQL, shell). Prohibido concatenar cadenas para construir consultas.
- **Dependencias**: Revisa periódicamente vulnerabilidades conocidas (`npm audit`, `pip audit`, `trivy`, `dependabot`).
- **Logs**: No expongas información sensible en logs (passwords, tokens, datos personales).

## Flujo de Trabajo (Workflow)
- [ ] **Fase 1: Revisión de Secretos**
  - Buscar tokens, claves o URLs hardcodeadas en el código y config.
  - Verificar que `.env` está en `.gitignore` y que los secrets usan variables de entorno.
- [ ] **Fase 2: Validación de Inputs**
  - Revisar endpoints, formularios, y cualquier punto de entrada de datos externos.
  - Asegurar validación de tipo, sanitización y límites de tamaño.
- [ ] **Fase 3: Autenticación y Autorización**
  - Verificar que los endpoints protegidos requieren autenticación.
  - Comprobar que no hay escalado de privilegios (un usuario no puede acceder a datos de otro).
- [ ] **Fase 4: Dependencias y Configuración**
  - Ejecutar `npm audit`, `pip audit` o equivalente.
  - Verificar que no hay dependencias con vulnerabilidades conocidas (CVEs).
- [ ] **Fase 5: Headers y Transporte**
  - Asegurar HTTPS, HSTS, Content-Security-Policy, y otros headers de seguridad.
  - Verificar que cookies tienen flags Secure, HttpOnly, SameSite.

## Criterios de Éxito
- No hay secretos en el repositorio.
- Todos los inputs externos están validados y sanitizados.
- Las dependencias están actualizadas sin CVEs críticas.
- La aplicación sigue las mejores prácticas de OWASP.
