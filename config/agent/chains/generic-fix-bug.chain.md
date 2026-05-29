---
name: generic-fix-bug
description: Quickly diagnose, fix, and validate a bug without planning overhead
---

## scout
output: fix/context-scout.md
progress: true

Explore the codebase for: {task}

Find the relevant files, error handling, tests, and recent changes related to the bug.

## generic-fixer
reads: fix/context-scout.md
output: fix/result.md
progress: true

Fix the bug described in: {task}

Use the scout findings. Apply the smallest correct fix, validate with tests, and report what changed and why.

## generic-reviewer
reads: fix/context-scout.md, fix/result.md
output: fix/review.md
progress: true

Review the fix applied for: {task}

Inspect the actual diff and changed files. This step is review-only: do not modify project files. Report blockers, regressions, or validation gaps.
