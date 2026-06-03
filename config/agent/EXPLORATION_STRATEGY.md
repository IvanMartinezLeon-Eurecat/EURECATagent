# Codebase Exploration Strategy (Generic)

> **Universal Guide for All Projects**  
> This document applies to any software project using code_intelligence tools.  
> Reference this in your project's docs/EXPLORATION_STRATEGY.md or similar.

---

## Core Rule: Prefer Code Intelligence Tools Over Bash Searches

**Status:** Best Practice / Recommended  
**Scope:** All codebase exploration, analysis, and refactoring tasks

When analyzing or searching a repository, follow this hierarchy to maximize efficiency and minimize token usage.

---

## The Three-Step Hierarchy

### Step 1: Semantic Search (Default First Choice)

```dart
code_intelligence_search({
  query: "your semantic question",
  currentFiles: ["path/to/file.ts"],  // optional: narrow context
  mode: "hybrid"  // semantic + lexical combined
})
```

**When to use:**
- Looking for patterns, implementations, or how features work
- Understanding architecture or design decisions
- Finding related code across multiple files
- Debugging: "why is this not working?"

**Examples (Language-Agnostic):**
- "Find authentication flow"
- "How is data validation implemented?"
- "What's the error handling pattern?"
- "Where is the main configuration?"
- "Find all state management code"

**Advantages:**
- ✅ Understands code meaning (semantic, not string-based)
- ✅ Returns relevant code chunks with context
- ✅ Shows relationships and patterns
- ✅ Indexed and fast
- ✅ Works across file types (Python, Dart, TypeScript, Go, etc.)

---

### Step 2: Dependency Analysis (For Impact Understanding)

```dart
code_intelligence_impact({
  paths: ["src/services/auth.ts"],
  maxFiles: 16
})
```

**When to use:**
- Understanding what depends on a file or module
- Finding all callers of a function
- Assessing impact of changes
- Discovering test files related to code
- Finding counterpart files (e.g., tests paired with source)

**Examples:**
- "What breaks if I change this service?"
- "What files import this module?"
- "Find all callers of authenticate()"
- "What tests cover this component?"
- "Show me related files (tests, implementations, configs)"

**Advantages:**
- ✅ Shows import relationships automatically
- ✅ Identifies callers and consumers
- ✅ Suggests related tests
- ✅ Prevents accidental breakage
- ✅ Language-agnostic (Python, TypeScript, Go, Rust, etc.)

---

### Step 3: Narrow Bash/CLI Queries (Only After Narrowing Scope)

```bash
# ✅ CORRECT: Exact match in known location
grep -n "exact_string" src/services/auth.ts

# ✅ CORRECT: Narrow regex in specific directory
rg "function_name\(" src/services/ --type ts

# ✅ CORRECT: Line numbers for verification
grep -n "exact pattern" src/config/

# Python example:
grep -n "def authenticate" src/auth/handler.py
```

**When to use:**
- Confirming exact strings or line numbers
- Final verification after intelligence tools narrowed scope
- Counting occurrences of a known pattern
- Cross-checking results

**Examples:**
- "Confirm this error message"
- "Find all references to userId"
- "Verify the exact function signature"
- "Count occurrences in this file"

**Advantages:**
- ✅ Fast for targeted, precise lookups
- ✅ Shows line numbers
- ✅ Minimal token overhead when scope is known

---

## Anti-Patterns ❌ (Never Do This)

```bash
# ❌ BAD: Broad unfocused search
grep -r "anything" src/

# ❌ BAD: Exploratory without purpose
find src/ -name "*.ts" | xargs grep pattern

# ❌ BAD: Random directory listing (no goal)
ls -la src/ && ls -la lib/ && find . -name "*.md"

# ❌ BAD: Loses context
rg pattern --no-heading src/

# ❌ BAD: Unfocused recursive grep
grep -r "import\|export" src/  # too many results, no goal
```

**Why these are bad:**
- 📊 Produce 200–500+ tokens of noise
- ⏱️ Slow to execute
- 🎯 Unfocused results
- 💰 Wastes context budget
- 🔍 Hard to find signal in noise
- 🌍 Language-specific tools don't scale across codebases

---

## Tool Comparison Matrix

| Goal | Tool | Speed | Tokens | Accuracy | Works With |
|------|------|-------|--------|----------|-----------|
| Find concept/pattern | `code_intelligence_search` | ⚡⚡⚡ | 50–100 | ⭐⭐⭐⭐⭐ | Any language |
| Understand impact | `code_intelligence_impact` | ⚡⚡⚡ | 50–100 | ⭐⭐⭐⭐⭐ | Any language |
| Verify exact line | `bash grep -n` | ⚡⚡ | 20–50 | ⭐⭐⭐⭐ | Any language |
| Broad exploration | `bash grep -r` | ⚠️ | 200–500 | ⭐⭐ | ❌ AVOID |
| Find in tree | `code_intelligence_search` | ⚡⚡⚡ | 50–100 | ⭐⭐⭐⭐⭐ | Any language |

---

## Real-World Examples

### Example 1: TypeScript/Node.js Backend

**❌ The Wrong Way**
```bash
grep -r "authenticate" src/
grep -r "userId" src/
find src/ -name "*auth*" -type f
rg "auth\|session" src/ --type ts
```
Result: 300+ lines, no context, wasted tokens.

**✅ The Right Way**
```dart
code_intelligence_search({
  query: "authentication and user session flow"
})

code_intelligence_impact({
  paths: ["src/services/auth.ts"]
})

bash grep -n "authenticate" src/services/auth.ts  // verify
```
Result: Precise, contextualized, 60% fewer tokens.

---

### Example 2: Python Data Pipeline

**❌ The Wrong Way**
```bash
grep -r "def process" src/
find . -name "*pipeline*" -type f
ls -la src/ && ls -la src/processors/
```

**✅ The Right Way**
```dart
code_intelligence_search({
  query: "data processing pipeline and transformations"
})

code_intelligence_impact({
  paths: ["src/processors/transformer.py"]
})

bash grep -n "def process_data" src/processors/transformer.py
```

---

### Example 3: Go Microservice

**❌ The Wrong Way**
```bash
grep -r "Handler" .
grep -r "middleware" .
find . -name "*.go" | xargs grep error
```

**✅ The Right Way**
```dart
code_intelligence_search({
  query: "HTTP request handlers and middleware chain"
})

code_intelligence_impact({
  paths: ["handler/auth_handler.go"]
})

bash grep -n "func.*Handler" handler/auth_handler.go
```

---

## Token Savings Summary

| Scenario | Old Way | New Way | Savings |
|----------|---------|---------|---------|
| Find feature implementation | `grep -r` (300 tokens) | `code_intelligence_search` (60 tokens) | **80%** |
| Understand impact of change | Manual inspection (200+ tokens) | `code_intelligence_impact` (80 tokens) | **60%** |
| Debug integration issue | Multiple searches (400+ tokens) | Semantic search + impact (150 tokens) | **63%** |
| Refactor module | Broad greps (500+ tokens) | Intelligence + verify (120 tokens) | **76%** |
| **Average savings per task** | **~350 tokens** | **~100 tokens** | **~71%** |

---

## Language-Specific Notes

### Python Projects
```python
# ✅ code_intelligence_search works for:
# - Finding class definitions and implementations
# - Understanding decorator patterns
# - Tracing async/await flows
# - Finding all uses of a module or function

# ✅ code_intelligence_impact works for:
# - What imports this module
# - All callers of a function
# - Related test files
```

### TypeScript/JavaScript Projects
```typescript
// ✅ code_intelligence_search works for:
// - Finding React components and hooks
// - Understanding state management
// - Tracing async flows
// - Finding API endpoints

// ✅ code_intelligence_impact works for:
// - Component dependencies
// - Hook consumers
// - Import chains
// - Test counterparts
```

### Go Projects
```go
// ✅ code_intelligence_search works for:
// - Finding handler functions
// - Understanding middleware chains
// - Tracing error handling
// - Finding configuration initialization

// ✅ code_intelligence_impact works for:
// - Package dependencies
// - Interface implementations
// - All callers of a function
```

### Dart/Flutter Projects
```dart
// ✅ code_intelligence_search works for:
// - Finding BLoC/Cubit patterns
// - Understanding navigation flows
// - Tracing state updates
// - Finding widget hierarchies

// ✅ code_intelligence_impact works for:
// - Widget dependencies
// - BLoC consumers
// - Navigator call sites
// - Test coverage
```

---

## Implementation Checklist

For **ANY** codebase exploration task:

- [ ] Start with `code_intelligence_search` for semantic understanding
- [ ] Use `code_intelligence_impact` to see dependencies and impact
- [ ] Only use bash for final verification in **narrow, known scope**
- [ ] Document your search strategy (what tool was used, why)
- [ ] Verify results make sense before acting on them
- [ ] Avoid `grep -r` or `find` without prior narrowing

---

## Decision Tree

```
Need to find something in the codebase? YES
  ↓
Do you know what you're looking for (concept, pattern)? YES
  ↓
Use code_intelligence_search
  ↓
Need to understand what depends on this? YES
  ↓
Use code_intelligence_impact
  ↓
Need to verify exact line/string? YES
  ↓
Use bash grep in NARROW SCOPE (one file or one directory)
  ↓
Done ✓

---

Don't know what you're looking for? YES
  ↓
Use code_intelligence_search with exploratory query
  ↓
Follow flow above
```

---

## FAQ

**Q: But I already know exactly which file I need. Why not just grep?**  
A: Even if you know the file, `code_intelligence_search` on that file gives you context instantly (what calls it, patterns, related code). For bare line verification, use bash **after** getting context.

**Q: What if code_intelligence tools don't return what I expect?**  
A: Try rephrasing your query more specifically. Use currentFiles to narrow scope. If still stuck, narrow the scope manually then use targeted bash.

**Q: Can I use bash for quick checks?**  
A: Yes, for exact string verification in **known, narrow locations**. Example: `grep -n "userId" src/user/model.ts`

**Q: Should I always use code_intelligence_search first?**  
A: Yes, 95% of the time. The only exceptions are:
- Confirming an exact line in a file you already have open
- Narrow string matching in a specific known file
- Ultra-quick verification

**Q: Why is this better for teams?**  
A: Consistency. Everyone uses the same approach → fewer mistakes, faster onboarding, predictable token usage.

**Q: Does this work for monorepos?**  
A: Yes! code_intelligence_search and code_intelligence_impact work across the entire codebase, making them especially powerful for monorepos.

**Q: What about searching package dependencies or external code?**  
A: code_intelligence_search indexes your local code only. For external packages, use their documentation or GitHub search.

---

## Quick Reference Card

```dart
// 🚀 SEMANTIC SEARCH (Do this first)
code_intelligence_search({ 
  query: "what are you looking for?" 
})

// 🔗 DEPENDENCY ANALYSIS (Then this)
code_intelligence_impact({ 
  paths: ["path/to/file"] 
})

// ✓ EXACT VERIFICATION (Only if needed)
bash grep -n "exact_string" path/to/file.ext
```

---

## For Project Maintainers

### Adopting This Strategy

1. **Reference in your README:**
   ```markdown
   ## Exploration Guidelines
   
   When searching the codebase, see [Exploration Strategy](docs/exploration-strategy.md)
   ```

2. **Reference in contributing guide:**
   ```markdown
   Contributors: follow the 3-step hierarchy in Exploration Strategy
   ```

3. **Record in code_intelligence_record_learning:**
   ```
   Mandatory exploration tool hierarchy: 
   (1) code_intelligence_search, (2) code_intelligence_impact, 
   (3) bash grep (narrow only)
   ```

4. **Train your team:**
   - Share this guide
   - Show before/after token comparisons
   - Review search patterns in PRs/commits

---

## Customizing for Your Project

Copy this file and adapt:

```markdown
# [Your Project] Exploration Strategy

[Copy generic sections above, customize examples]

### Project-Specific Examples

**Our tech stack:** TypeScript, React, Node.js

**Common searches in our codebase:**
- "Find API endpoint handlers" → `code_intelligence_search`
- "What components use this hook?" → `code_intelligence_impact`
- etc.

### Our Commitments
- All agents must follow 3-step hierarchy
- Mandatory in PRs and code reviews
- Reviewed for token efficiency
```

---

## Related Resources

- **Code Intelligence Documentation:** See pi docs on code_intelligence_search and code_intelligence_impact
- **Token Optimization:** See docs on context windows and token budgets
- **Best Practices:** See workflow guidelines for your framework/language

---

**Last Updated:** June 2026  
**Status:** Generic Best Practice (Recommended for All Projects)  
**Maintenance:** Update as new tools or patterns emerge
