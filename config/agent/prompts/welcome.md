<!--
/welcome — Muestra los comandos y flujos disponibles
-->
# EURECATagent — Comandos rápidos

## Instalación

```bash
# Una vez instalado, Pi ya está disponible en tu PATH
pi
```

## Subagentes y chains

Usa estos comandos dentro de Pi para delegar trabajo:

```
/run-chain generic-implement-safe -- describe tu tarea aquí
/run-chain generic-fix-bug -- describe el bug aquí
/run-chain generic-discovery -- explora esta parte del código
/run-chain generic-research-and-plan -- investiga y planifica
```

## Agentes individuales

```
/run generic-reviewer "Revisa este código con foco en regresiones"
/run generic-parallel-review "Revisa este cambio (seguridad + tests + simplicidad)"
/run generic-doc-writer "Escribe un README para este módulo"
```

## Diagnóstico

```
/router-status        - estado del routing y capacidades
/code-intelligence-doctor
/enable-code-intelligence
/mcp                  - herramientas de contexto pesado
```

## Atajos

```
/settings             - configuración del agente
/model                - cambiar modelo
/theme                - cambiar tema
```

## Skills activas

Se cargan automáticamente según la tarea. No necesitas invocarlas manualmente.
