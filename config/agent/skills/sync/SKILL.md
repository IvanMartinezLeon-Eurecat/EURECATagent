---
name: sync
description: Specialist in agent intelligence synchronization. Use when updating skills, knowledge base, or configuration from the central repository.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Sincronización (Sync)

## Descripción General
Especialista en mantener actualizada la "inteligencia" del agente mediante la sincronización con el repositorio central del proyecto. Asegura que todo el equipo trabaje con las mismas reglas.

## Gotchas (Reglas Críticas)
- **Sobrescritura Local**: `sync` sobrescribe archivos en `~/.pi/agent/`. Si el usuario ha hecho cambios manuales ahí, se perderán. Advierte siempre.
- **Versiones Desfasadas**: Si el script falla, el agente podría estar usando instrucciones antiguas. Verifica siempre el éxito de la operación.

## Flujo de Trabajo (Workflow)
- [ ] **Paso 1: Detección de Entorno**
  - Identificar el sistema operativo y el script correspondiente (`.sh` o `.ps1`).
- [ ] **Paso 2: Ejecución del Comando**
  - Proporcionar al usuario el comando exacto para sincronizar.
  - Ejemplo: `./pi-eurecat-bash.sh` o `.\pi-eurecat-powershell.ps1`.
- [ ] **Paso 3: Verificación de Integridad**
  - Comprobar que las carpetas `skills/`, `knowledge/` y `themes/` se han actualizado correctamente.
- [ ] **Paso 4: Recarga de Configuración**
  - Sugerir el uso de `/reload` si el cliente lo soporta para aplicar cambios inmediatamente.

## Criterios de Éxito
- Agente operando con las últimas versiones de Skills y Knowledge.
- Entorno de configuración (`~/.pi/agent/`) íntegro y sin errores.
- Difusión inmediata de nuevos estándares al equipo.
