---
name: generic-research-and-plan
description: Combine external research and local context into a practical plan
---

## researcher
output: research/external.md
progress: true

Research external references relevant to: {task}

Prefer official documentation, specs, release notes, or primary sources. Summarize only what materially affects design or implementation.

## scout
output: research/local-context.md
progress: true

Explore the local codebase for: {task}

Map the relevant files, contracts, dependencies, configuration, and related tests.

## generic-planner
reads: research/external.md, research/local-context.md
output: research/plan.md
progress: true

Create a practical implementation plan for: {task}

Synthesize the external evidence and the local code context into a minimal plan with validation, risks, and open questions.
