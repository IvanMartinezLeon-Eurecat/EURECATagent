---
name: generic-discovery
description: Explore a codebase, then build implementation-ready context
---

## scout
output: discovery/scout-context.md
progress: true

Explore the codebase for: {task}

Focus on the most relevant entry points, key files, dependencies, related tests, and likely impact surface. Keep the output concise and evidence-based.

## generic-context-builder
reads: discovery/scout-context.md
output: discovery/context.md
progress: true

Build an implementation-ready context for: {task}

Use the scout findings and direct file inspection to produce the minimum context needed before planning or editing.
