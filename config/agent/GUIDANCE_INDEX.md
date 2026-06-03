# IML: Index & Quick Navigation

> **Implementation & Learning Guidelines for EURECAT Projects**

---

## 📊 Folder Structure

```
iml/
├── README.md                           ⭐ Start here - Overview & quick links
├── INDEX.md                            ← You are here
├── EXPLORATION_STRATEGY.md             🔍 Generic exploration guide (all projects)
├── BEST_PRACTICES.md                   ✅ Engineering standards (all projects)
├── templates/
│   ├── project-exploration-guide.md    📋 Copy & customize for your project
│   └── project-standards.md            📋 (Coming soon) Project-specific rules
└── examples/
    ├── exploration-flutter-keko.md     💡 Real example: Flutter/Keko project
    └── exploration-generic.md          💡 (Coming soon) Generic template example
```

---

## 🎯 Choose Your Path

### 👤 I'm a Developer (First Time Here)

1. **Read:** [`README.md`](README.md) — Get oriented (5 min)
2. **Read:** [`EXPLORATION_STRATEGY.md`](EXPLORATION_STRATEGY.md) — Learn how to search (10 min)
3. **Reference:** [`BEST_PRACTICES.md`](BEST_PRACTICES.md) — Keep as guide (skim)
4. **Look:** [`examples/`](#examples) — See real examples (5 min)

**Time Needed:** ~20 minutes

---

### 🏢 I'm Setting Up a New Project

1. **Read:** [`README.md`](README.md) — Get oriented
2. **Copy:** [`templates/project-exploration-guide.md`](templates/project-exploration-guide.md) to your project's `docs/exploration-strategy.md`
3. **Customize:** Replace `[EXAMPLE_X]` placeholders with your project specifics
4. **Share:** Link team members to the customized guide
5. **Reference:** [`BEST_PRACTICES.md`](BEST_PRACTICES.md) for standards

**Time Needed:** ~30 minutes

---

### 🔍 I Need to Search the Codebase

1. **Go:** [`EXPLORATION_STRATEGY.md`](EXPLORATION_STRATEGY.md)
2. **Choose:** Follow the 3-step hierarchy:
   - ✅ Step 1: `code_intelligence_search` (semantic)
   - ✅ Step 2: `code_intelligence_impact` (dependencies)
   - ✅ Step 3: `bash grep` (verification, narrow scope only)
3. **Result:** ~70% fewer tokens, faster, more accurate

**Quick Reference:** See [Quick Reference Card](#quick-reference-card) below

---

### 📚 I'm Reviewing Code

1. **Check:** [`BEST_PRACTICES.md`](BEST_PRACTICES.md) — Does it follow standards?
2. **Use:** [`EXPLORATION_STRATEGY.md`](EXPLORATION_STRATEGY.md) — Did they search efficiently?
3. **Suggest:** Reference the appropriate section in your feedback

---

### 📝 I Found a Pattern Worth Documenting

1. **Add to:** Project's `docs/` folder or IML templates
2. **Record:** Use `code_intelligence_record_learning()` to make it durable
3. **Share:** Tell the team about it

---

## 📖 File Descriptions

| File | Purpose | Audience | Time |
|------|---------|----------|------|
| **README.md** | Overview, structure, getting started | Everyone | 5 min |
| **EXPLORATION_STRATEGY.md** | How to search codebases efficiently | Developers, all projects | 15 min |
| **BEST_PRACTICES.md** | Engineering standards across languages | Leads, reviewers | 20 min |
| **templates/project-exploration-guide.md** | Copy this to your project, customize | Project leads | 10 min |
| **examples/exploration-flutter-keko.md** | Real-world example with Keko/Flutter | Flutter devs, teams | 10 min |

---

## 🚀 Quick Reference Card

**Every codebase search follows this:**

```dart
// Step 1: Semantic search (understand the pattern)
code_intelligence_search({ 
  query: "what are you looking for?" 
})

// Step 2: Dependency analysis (understand impact)
code_intelligence_impact({ 
  paths: ["path/to/file"] 
})

// Step 3: Exact verification (narrow scope only)
bash grep -n "exact_string" path/to/file.ext
```

**Result:** 60–80% fewer tokens ✨

---

## 🔗 Quick Links

### Core Resources
- **EURECATagent Main:** `../README.md` (main repo)
- **Keko Project:** Example Flutter project following these standards
- **Code Intelligence:** Run `/code-intelligence-doctor` in Pi

### External
- **Flutter i18n:** https://flutter.dev/docs/development/accessibility-and-localization/internationalization
- **Clean Architecture:** Uncle Bob's Architecture
- **Semantic Versioning:** https://semver.org/

---

## ❓ FAQ

**Q: Where do I start?**  
A: Read [`README.md`](README.md) (5 min), then [`EXPLORATION_STRATEGY.md`](EXPLORATION_STRATEGY.md) (10 min).

**Q: What if my project is different?**  
A: Copy [`templates/project-exploration-guide.md`](templates/project-exploration-guide.md) and customize with your specifics.

**Q: Who maintains IML?**  
A: EURECAT Engineering Leadership. Submit PRs for improvements.

**Q: How do I propose changes?**  
A: Create an issue or PR referencing this folder.

---

## 📈 Stats & Benefits

### Time Savings
- **Per search:** 60–80% fewer tokens
- **Per project:** ~30% overall token savings
- **Per team:** Consistent approach, faster onboarding

### Quality Improvements
- Fewer missed dependencies
- Better code understanding
- Reduced bugs from incomplete refactors
- Durable knowledge capture

---

## 📅 Version & Status

- **Created:** June 2026
- **Status:** Active, EURECAT-wide
- **Last Updated:** June 2026
- **Maintainer:** EURECAT Engineering

---

## 🎓 Learning Paths

### For Beginners
1. IML/README.md
2. IML/EXPLORATION_STRATEGY.md
3. IML/examples/exploration-flutter-keko.md (if Flutter)
4. Practice with a real project

### For Leads
1. IML/README.md
2. IML/EXPLORATION_STRATEGY.md
3. IML/BEST_PRACTICES.md
4. Copy & customize templates for your project
5. Train your team

### For Architects
1. IML/BEST_PRACTICES.md
2. Review IML/ for patterns
3. Contribute improvements
4. Record learnings via code_intelligence

---

**Ready? Start with [`README.md`](README.md) → [`EXPLORATION_STRATEGY.md`](EXPLORATION_STRATEGY.md) → Practice!** 🚀
