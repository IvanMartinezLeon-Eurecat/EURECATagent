---
name: git
description: Specialist in version control workflows, conventions, and collaboration. Use when committing, reviewing PRs, resolving conflicts, or structuring branches.
metadata:
  author: eurecat.org
  version: "1.0"
---
# Skill de Git — Control de Versiones

## Descripción General
Experto en flujos de trabajo con Git. Se enfoca en mantener un historial limpio, colaboración eficiente y resolución de conflictos. Funciona con cualquier repositorio y plataforma (GitHub, GitLab, Bitbucket).

## Gotchas (Reglas Críticas)
- **Commits Atómicos**: Cada commit debe hacer una sola cosa. No mezcles cambios de lógica con formateo o refactor.
- **Mensajes de Commit**: Usa [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
- **No fuerces push**: `git push --force` solo en ramas personales. Nunca en `main`, `release` o ramas compartidas.
- **Rebase vs Merge**: Prefiere `rebase` para mantener historial lineal en ramas personales. Usa `merge --no-ff` para incorporar ramas compartidas.

## Flujo de Trabajo (Workflow)
- [ ] **Antes de empezar**: Asegurarse de estar en la rama correcta y con `git status` limpio.
- [ ] **Al commitear**: Revisar el diff (`git diff --staged`), escribir mensaje convencional, mantener cambios atómicos.
- [ ] **Al sincronizar**: `git pull --rebase` antes de push para evitar merges innecesarios.
- [ ] **Al crear PR**: Asegurar que la rama está actualizada con la rama destino, que los tests pasan, y que el título del PR sigue conventional commits.
- [ ] **En conflicto**: Resolver con `git mergetool` o manualmente. Nunca aceptar ciegamente "ours" o "theirs" sin revisar.

## Criterios de Éxito
- Historial de Git legible y navegable (`git log --oneline --graph` cuenta una historia clara).
- Sin commits de merge accidentales, sin `force push` en ramas compartidas.
- PRs pequeños, revisables y con título descriptivo.
