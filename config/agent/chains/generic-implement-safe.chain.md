---
name: generic-implement-safe
description: Scout, plan, implement, and review a change with a single writer
---

## scout
output: implement/context-scout.md
progress: true

Explore the codebase for: {task}

Find the relevant files, dependencies, tests, and likely impact points before implementation starts.

## generic-planner
reads: implement/context-scout.md
output: implement/plan.md
progress: true

Create a minimal implementation plan for: {task}

Base the plan on the scout output and the actual codebase.

## generic-worker
reads: implement/context-scout.md, implement/plan.md
output: implement/result.md
progress: true

Implement the approved change for: {task}

Use the provided context and plan. Keep edits minimal, follow local patterns, and validate the result with focused checks.

## generic-reviewer
reads: implement/context-scout.md, implement/plan.md, implement/result.md
output: implement/review.md
progress: true

Review the current implementation for: {task}

Inspect the actual diff and changed files. This final step is review-only: do not modify project files. Report blockers, risks, and validation gaps clearly.
