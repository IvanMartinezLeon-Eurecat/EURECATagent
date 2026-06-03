# Project Exploration Strategy Template

> **Copy this file to your project and customize**  
> Path: `docs/exploration-strategy.md` or similar  
> Based on: `iml/EXPLORATION_STRATEGY.md`

---

## [PROJECT_NAME] Exploration Strategy

**Project:** [Your Project Name]  
**Tech Stack:** [e.g., Flutter/Dart, TypeScript/React, Python/Django, Go/gRPC]  
**Status:** Active / Mandatory  
**Last Updated:** [Date]

---

## Overview

All team members and agents working on **[PROJECT_NAME]** must follow this exploration strategy to maximize efficiency and minimize token usage in Pi.

### Key Principle
**Prefer code intelligence tools over broad bash searches.**

Every search in this codebase should follow:

1. ✅ **Semantic Search** — `code_intelligence_search` for patterns
2. ✅ **Dependency Analysis** — `code_intelligence_impact` for relationships
3. ✅ **Exact Verification** — bash `grep -n` for narrow scope **only**

**Result:** 60–80% fewer tokens, faster insights, better accuracy.

---

## The Three-Step Hierarchy

### Step 1: Semantic Search

```dart
code_intelligence_search({
  query: "what are you looking for?",
  currentFiles: ["lib/features/..."],  // optional: narrow by current context
  mode: "hybrid"
})
```

### Step 2: Dependency Analysis

```dart
code_intelligence_impact({
  paths: ["lib/features/auth/..."],
  maxFiles: 16
})
```

### Step 3: Narrow Bash Verification

```bash
grep -n "exact_string" lib/path/to/file.dart
```

---

## Project-Specific Examples

### Common Search 1: [EXAMPLE_1]

**Goal:** [Describe what you want to find]

**❌ Wrong Approach:**
```bash
grep -r "pattern" lib/
find lib/ -name "*.dart" | xargs grep something
```

**✅ Right Approach:**
```dart
code_intelligence_search({
  query: "semantic description of what you're looking for"
})

code_intelligence_impact({
  paths: ["lib/path/to/relevant/file.dart"]
})

bash grep -n "exact_match" lib/path/to/file.dart  // verify if needed
```

**Expected Result:** [Describe what good results look like]

---

### Common Search 2: [EXAMPLE_2]

**Goal:** [Describe]

**Query:** `code_intelligence_search({ query: "..." })`

**Result:** [Expected output]

---

### Common Search 3: [EXAMPLE_3]

**Goal:** [Describe]

**Query:** `code_intelligence_impact({ paths: [...] })`

**Result:** [Expected output]

---

## Tech Stack Specifics

### [Language/Framework]

**What code_intelligence_search finds well:**
- [Pattern 1]
- [Pattern 2]
- [Pattern 3]

**What code_intelligence_impact is useful for:**
- [Relationship 1]
- [Relationship 2]
- [Relationship 3]

**Example queries:**
```
"Find [pattern]"
"How is [feature] implemented?"
"Where is the [configuration]?"
```

---

## Repository Structure Quick Reference

```
[PROJECT_NAME]/
├── [Directory1]/
│   ├── [Pattern1]
│   └── [Pattern2]
├── [Directory2]/
│   ├── [Tests]
│   └── [Configs]
└── docs/
    └── exploration-strategy.md  # (this file)
```

**Key conventions:**
- [Convention 1]
- [Convention 2]
- [Convention 3]

---

## Team Standards

### Mandatory Rules
1. Always use code_intelligence_search before broad bash searches
2. Use code_intelligence_impact to understand impact before changes
3. Only use bash grep for verification in known, narrow scope
4. Document your search strategy in commit messages or PRs

### Code Intelligence Learnings
This project records durable learnings via `code_intelligence_record_learning`. See:
- Recorded learnings: [Link or `/code-intelligence-doctor` in Pi]
- Contribution: Use `code_intelligence_record_learning` to record new patterns

### Token Budget
- Expected tokens per exploration task: **80–100** (not 300+)
- If your search exceeds 150 tokens, you likely used bash search. Use code_intelligence instead.

---

## Troubleshooting

### Q: My code_intelligence_search returned no results

**A:** Try these:
1. Rephrase the query more specifically
2. Use `currentFiles` to narrow context
3. Check if the codebase is indexed: run `/code-intelligence-doctor` in Pi
4. If index is stale, run `/enable-code-intelligence` to refresh

### Q: I need to find something but don't know where

**A:** Start with an exploratory `code_intelligence_search` query, then narrow:
```dart
code_intelligence_search({ query: "broad description of feature" })
code_intelligence_impact({ paths: [results_from_above] })
bash grep -n "exact_match" [narrowed_path]  // final verification
```

### Q: Can I use bash grep directly?

**A:** Only in these cases:
- You know the exact file and just need to verify a line
- You're cross-checking results from code_intelligence tools
- You're searching in config files or generated code

Even then, narrow the scope first: `grep -n "x" path/to/known/file.ext`

---

## Related Resources

- **Generic Exploration Guide:** [Reference iml/EXPLORATION_STRATEGY.md](../../iml/EXPLORATION_STRATEGY.md)
- **EURECATagent Docs:** [See main README]
- **Code Intelligence in Pi:** Run `/code-intelligence-doctor` in Pi
- **Project README:** [Link to main README]

---

## Contributing

Found a new pattern or optimization? Help improve this guide:

1. Test your approach and measure token usage
2. Document it here with example before/after
3. Consider recording a `code_intelligence_record_learning` entry
4. Submit a PR or share with the team

---

## Version History

| Date | Changes | Author |
|------|---------|--------|
| [DATE] | Initial version | [Your Name] |

---

**For questions:** See [PROJECT_CONTACT] or refer to the generic [iml/EXPLORATION_STRATEGY.md](../../iml/EXPLORATION_STRATEGY.md)
