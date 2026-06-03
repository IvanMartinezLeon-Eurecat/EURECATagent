# EURECAT Engineering Best Practices

> **General engineering standards for all EURECAT projects**  
> Use alongside project-specific guides

---

## Core Principles

### 1. Code Intelligence First
- Always use `code_intelligence_search` and `code_intelligence_impact` before bash searches
- See: [EXPLORATION_STRATEGY.md](EXPLORATION_STRATEGY.md)

### 2. Clean Architecture
- Separate concerns: Domain → Data → Presentation
- Keep business logic independent of frameworks
- Test-first when possible

### 3. Localization (i18n)
- **Rule:** No untranslated user-facing text
- All supported languages from day one
- Auto-detect device locale

### 4. Zero Dead Code
- YAGNI: You Aren't Gonna Need It
- Remove unused functions, constants, imports
- Regular cleanup in code reviews

### 5. Dependency Injection
- Accept dependencies via constructor, not service locators
- Makes testing easier, code more transparent
- Use framework DI when available

---

## Language-Specific Standards

### Dart/Flutter

**Architecture:**
- Domain/Data/Presentation layers per feature
- BLoC/Cubit for state management
- GoRouter for navigation (not Navigator)

**Code Style:**
- Follow `effective_dart` lints
- Use `const` constructors
- Private class names with `_`

**Localization:**
- Use `flutter_localizations` + ARB files
- Access via `context.l10n.keyName`
- All UI strings must be localized

**Testing:**
- Unit test business logic (Cubits, Repositories)
- Widget test critical UI flows
- Run `flutter test` before commit

**Command:**
```bash
flutter analyze      # Code quality check
flutter test         # Run tests
flutter gen-l10n     # Generate localization code
```

---

### TypeScript/JavaScript

**Architecture:**
- Feature-based folder structure
- Separate API clients from business logic
- Type-safe everywhere (`strict: true`)

**Code Style:**
- Use `eslint` + `prettier`
- Const first, let never, var never
- Explicit types for function parameters/returns

**Testing:**
- Jest for unit tests
- React Testing Library for components
- Cypress/Playwright for E2E

**Localization:**
- Use i18n-js, react-i18next, or similar
- Load translations at app startup
- Store in JSON/YAML, load by locale

**Command:**
```bash
npm run lint         # ESLint + Prettier
npm run test         # Run tests
npm run build        # Compile TypeScript
```

---

### Python

**Architecture:**
- Clear separation of concerns (controllers, services, models)
- Use dataclasses or Pydantic for models
- Dependency injection via constructor or FastAPI/Flask

**Code Style:**
- Follow PEP 8 (use Black formatter)
- Type hints for all functions
- Use mypy for static type checking

**Testing:**
- pytest for unit tests
- Fixtures for setup/teardown
- Mock external services

**Localization:**
- Use `gettext` or `Babel`
- Store `.po` / `.pot` files
- Lazy-load translations per request

**Command:**
```bash
black .              # Format code
mypy src/            # Type check
pytest               # Run tests
```

---

### Go

**Architecture:**
- Clean architecture with interfaces
- Dependency injection via struct fields
- Clear error handling (not exceptions)

**Code Style:**
- Use `gofmt` (automatic)
- CamelCase for exported, lowercase for private
- Error handling: `if err != nil { return err }`

**Testing:**
- Table-driven tests
- Use `testing.T` (built-in)
- Mocking with interfaces

**Localization:**
- Use `go-i18n` or similar
- YAML/JSON translation files
- Load per language at startup

**Command:**
```bash
go fmt ./...         # Format code
go vet ./...         # Static checks
go test ./...        # Run tests
```

---

## Knowledge Management

### Recording Learnings

When you discover a pattern or need to enforce a rule, record it:

```
code_intelligence_record_learning({
  title: "Short title",
  summary: "What to remember and why",
  ruleType: "prefer_pattern|avoid_pattern|architecture|workflow|...",
  appliesWhen: "When this rule applies",
  prefer: "What to do instead",
  avoid: "What to avoid",
  confidence: 0.85,  // 0-1
  priority: 80,       // 0-100
  status: "active"    // "active" or "draft"
})
```

**Examples:**
- "Use code_intelligence_search before bash grep"
- "Constructor injection, never service locators"
- "All UI strings must be localized"
- "Record durable decisions in code_intelligence_record_learning"

### Sharing Knowledge

- Document recurring patterns in project's `docs/`
- Add examples to this guide
- Share in team channels with context
- Review learnings quarterly

---

## Code Review Standards

### What to Check

1. **Architecture Compliance**
   - Does it follow the project's structure?
   - Are concerns properly separated?
   - Is dependency injection used correctly?

2. **Code Quality**
   - Passes lint/format checks?
   - Has tests (unit/widget/E2E)?
   - No dead code?
   - Clear variable/function names?

3. **Localization**
   - All user-facing strings translated?
   - No hardcoded English?
   - ARB/translation files updated?

4. **Documentation**
   - README/comments updated?
   - Complex logic explained?
   - Running instructions clear?

5. **Performance**
   - No N+1 queries?
   - Appropriate caching?
   - Reasonable bundle size?

### Checklist

- [ ] Code follows project architecture
- [ ] Passes linting and formatting
- [ ] Tests included (unit/widget/E2E)
- [ ] All UI strings localized
- [ ] No dead code
- [ ] Clear, documented, reviewable
- [ ] Performance acceptable

---

## Testing Standards

### Unit Testing

- Test business logic: Cubits, Services, Repositories
- Mock external dependencies
- Aim for >80% coverage in critical paths

**Example:**
```dart
test('OrderCubit emits loading then orders', () async {
  when(mockRepository.getOrders())
    .thenAnswer((_) async => mockOrders);
  
  expect(
    cubit.stream,
    emitsInOrder([
      OrderState(isLoading: true),
      OrderState(orders: mockOrders),
    ]),
  );
});
```

### Widget Testing

- Test critical user flows
- Verify UI updates on state changes
- Don't over-test (focus on logic)

**Example:**
```dart
testWidgets('Shows orders when loaded', (tester) async {
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
  
  expect(find.text('Order #123'), findsOneWidget);
});
```

### E2E Testing

- Test user journeys end-to-end
- Mock APIs for deterministic results
- Run in CI/CD pipeline

---

## CI/CD Standards

### Pre-Commit Checks
```bash
# Dart/Flutter
flutter analyze
dart format --set-exit-if-changed lib/ test/

# TypeScript
npm run lint --fix
npm run test

# Python
black .
mypy src/
pytest
```

### Pull Request Checks
- Code review approval required
- All tests pass
- No lint/format errors
- Localization files updated
- Documentation updated

### Deployment Checks
- Tagged version in CHANGELOG
- Version bump in version file
- All E2E tests passing
- Build artifact created

---

## Security Best Practices

### Authentication & Authorization
- Never log passwords or tokens
- Use environment variables for secrets
- Validate input on both client and server
- HTTPS only in production

### Data Protection
- Encrypt sensitive data at rest
- Use TLS for transit
- Sanitize user input
- Follow data protection regulations (GDPR, etc.)

### Dependency Management
- Regular security audits
- Update dependencies promptly
- Review breaking changes
- Lock dependency versions in production

---

## Performance Guidelines

### Web/Mobile
- Initial load < 3 seconds
- Time to Interactive < 5 seconds
- Bundle size < 1 MB (mobile), < 5 MB (web)
- 60 FPS animations

### Backend
- Response time < 200 ms (p50), < 1 s (p99)
- Database queries < 100 ms
- Cache frequently accessed data
- Monitor with appropriate metrics

### General
- Lazy-load heavy features
- Use CDN for assets
- Compress images, minify code
- Monitor and profile regularly

---

## Documentation Standards

### README.md
- Project overview
- Tech stack
- Quick start
- Architecture explanation
- Contributing guidelines

### API Documentation
- Endpoint signatures
- Request/response examples
- Error codes and meanings
- Rate limiting if applicable

### Code Comments
- Why, not what (code speaks for itself)
- Complex algorithms explained
- Edge cases documented
- Links to external resources

---

## Accessibility Standards

### Web/Mobile
- WCAG 2.1 AA compliance
- Keyboard navigation support
- Screen reader compatibility
- Color contrast ≥ 4.5:1

### General
- Clear error messages
- Logical tab order
- Readable font sizes
- Alternative text for images

---

## Version Management

### Semantic Versioning

```
MAJOR.MINOR.PATCH
```

- **MAJOR:** Incompatible API changes
- **MINOR:** Backward-compatible features
- **PATCH:** Bug fixes

**Example:** `v2.3.4` → breaking, feature, fix

### Changelog

Document in `CHANGELOG.md`:

```markdown
## v2.3.4 (2026-06-15)

### Added
- New feature X
- Support for Y

### Fixed
- Bug in Z
- Performance issue

### Changed
- Deprecated old API

### Breaking Changes
- Removed deprecated function
```

---

## FAQ

**Q: Do I need to follow all these standards?**  
A: Yes, for EURECAT projects. Project-specific guides may add or restrict.

**Q: What if my project has different conventions?**  
A: Document them clearly and reference these standards as baseline.

**Q: How do I propose changes to these standards?**  
A: Create an issue or PR in the main EURECAT repository.

**Q: Who enforces these?**  
A: Code review, linting, testing, and team culture.

---

## Resources

- **Code Intelligence:** [EXPLORATION_STRATEGY.md](EXPLORATION_STRATEGY.md)
- **Flutter:** https://flutter.dev/docs
- **TypeScript:** https://www.typescriptlang.org/docs/
- **Python:** https://pep8.org/ and https://mypy.readthedocs.io/
- **Go:** https://golang.org/doc/effective_go
- **i18n:**
  - Dart: https://flutter.dev/docs/development/accessibility-and-localization/internationalization
  - TypeScript: https://www.i18next.com/
  - Python: https://www.gnu.org/software/gettext/

---

**Version:** 1.0  
**Last Updated:** June 2026  
**Status:** EURECAT-wide Best Practice (Mandatory)  
**Maintained By:** EURECAT Engineering Leadership
