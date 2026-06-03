# Keko (Flutter) Exploration Strategy - Example

> **Real-world example using the Keko Flutter project**  
> Reference this as a template for Flutter/Dart projects

---

## Keko Project Exploration Strategy

**Project:** Keko Order Management (Flutter)  
**Tech Stack:** Flutter 3.12+, Dart, BLoC state management  
**Key Patterns:** Domain/Data/Presentation, Cubits, GoRouter navigation  
**Status:** Active, Mandatory for all agent work  

---

## Key Concepts

### Architecture Pattern
- **Clean Architecture** with feature-based organization
- **Domain/Data/Presentation** layers per feature
- **BLoC/Cubit** for state management
- **GoRouter** with StatefulShellRoute for navigation

### Main Features
```
lib/features/
├── auth/               # Authentication with Cubit
├── products/           # Product catalog with filtering
├── cart/               # Shopping cart (in-memory)
├── orders/             # Order management with status tracking
├── profile/            # User profile with order statistics
└── home/               # Dashboard with navigation
```

### Localization
- **Languages:** English, Spanish, Catalan (auto-selected by device)
- **System:** flutter_localizations + ARB files
- **Access:** `context.l10n.keyName` for all UI strings
- **Rule:** No untranslated text allowed in UI

---

## Common Searches & Examples

### Example 1: Understanding Order Status Tracking

**Goal:** How are order states managed and how is history tracked?

**❌ Wrong Way (wastes 300+ tokens):**
```bash
grep -r "status" lib/features/orders/
grep -r "OrderCubit" lib/
find lib/features/orders -name "*.dart" | xargs grep "state\|history"
```

**✅ Right Way (uses ~80 tokens):**

```dart
// Step 1: Understand the pattern
code_intelligence_search({
  query: "order status management and history tracking implementation",
  currentFiles: ["lib/features/orders/domain/entities/order.dart"]
})

// Result: Shows Order entity with statusHistory list, StatusChange entity, updateOrderStatus method

// Step 2: See what depends on it
code_intelligence_impact({
  paths: ["lib/features/orders/presentation/cubits/order_cubit.dart"]
})

// Result: Shows OrderDetailScreen, OrderListScreen, HomeScreen all consume OrderCubit

// Step 3: Verify exact implementation (if needed)
bash grep -n "updateOrderStatus" lib/features/orders/presentation/cubits/order_cubit.dart
```

**Expected Output:**
- Order entity with `List<OrderItem> items` and `List<StatusChange> history`
- StatusChange with `status`, `changedAt`, `note` fields
- OrderCubit with `updateOrderStatus(orderId, newStatus, {note})`
- TimelineView displaying history on OrderDetailScreen

**Token Savings:** ~220 tokens (73% reduction)

---

### Example 2: Finding All Translations (i18n Keys)

**Goal:** Where are all the user-facing strings defined, and how to add a new translation?

**❌ Wrong Way:**
```bash
grep -r "Text(" lib/features/*/presentation/
find lib -name "*.arb"
grep -r "context.l10n" lib/
```

**✅ Right Way:**

```dart
// Step 1: Find translation system
code_intelligence_search({
  query: "localization and AppLocalizations setup"
})

// Result: Points to lib/l10n/ with app_en.arb, app_es.arb, app_ca.arb

// Step 2: Understand how strings are accessed
code_intelligence_search({
  query: "context.l10n usage pattern in UI widgets"
})

// Result: Shows extension in lib/core/extensions/localization_extension.dart

// Step 3: Verify exact extension (optional)
bash grep -n "extension.*BuildContext" lib/core/extensions/localization_extension.dart
```

**Expected Output:**
- `lib/l10n/app_en.arb`, `app_es.arb`, `app_ca.arb` with all keys
- Extension `context.l10n` for easy access
- All screens use `context.l10n.keyName` for UI strings
- `flutter gen-l10n` generates code after changes

**Pattern to Remember:**
```dart
// Always use this in any UI:
Text(context.l10n.loginTitle)  // NOT Text('Welcome Back')

// Add new translations:
// 1. Add to lib/l10n/app_en.arb, app_es.arb, app_ca.arb
// 2. Run: flutter gen-l10n
// 3. Use: context.l10n.newKeyName in UI
```

---

### Example 3: Tracing a Cart Item Through the System

**Goal:** What happens when a user adds a product to cart? (from tap to screen update)

**❌ Wrong Way:**
```bash
grep -r "addItem" lib/
grep -r "CartItem" lib/
grep -r "CartCubit" lib/
# Results: 50+ matches, no flow understanding
```

**✅ Right Way:**

```dart
// Step 1: Understand the cart data flow
code_intelligence_search({
  query: "cart add item flow from product screen to cart cubit"
})

// Result: Points to CartCubit.addItem(), CartItem entity, ProductListScreen

// Step 2: See what consumes cart state
code_intelligence_impact({
  paths: ["lib/features/cart/presentation/cubits/cart_cubit.dart"]
})

// Result: Shows CartScreen, ProductListScreen (badge), main.dart (global provider)

// Step 3: Optional - verify the exact cubit method
bash grep -n "void addItem" lib/features/cart/presentation/cubits/cart_cubit.dart
```

**Expected Flow:**
1. User taps "Add to Cart" on product → `_showAddToCartSheet()` bottom sheet
2. Selects quantity → confirms
3. `context.read<CartCubit>().addItem(product, quantity)` called
4. CartCubit adds CartItem to state
5. CartScreen rebuilds with new item
6. ProductListScreen badge updates (shows total items)

**Key Files:**
- `lib/features/cart/domain/entities/cart_item.dart` — CartItem entity
- `lib/features/cart/presentation/cubits/cart_cubit.dart` — CartCubit with addItem, updateQuantity, removeItem
- `lib/main.dart` — CartCubit provided globally
- `lib/features/cart/presentation/screens/cart_screen.dart` — UI

---

### Example 4: Finding Where Order Creation Happens

**Goal:** How are orders created from cart items?

**❌ Wrong Way:**
```bash
grep -r "createOrder" lib/
grep -r "Order(" lib/
find lib/features/orders -name "*datasource*"
```

**✅ Right Way:**

```dart
// Step 1: Find order creation logic
code_intelligence_search({
  query: "order creation from cart items and initial order state",
  currentFiles: ["lib/features/cart/presentation/screens/cart_screen.dart"]
})

// Result: Shows createOrderFromCart in OrderCubit

// Step 2: See the full order lifecycle
code_intelligence_impact({
  paths: ["lib/features/orders/presentation/cubits/order_cubit.dart"]
})

// Result: Shows what depends on OrderCubit (HomeScreen, OrderListScreen, ProfileScreen, OrderDetailScreen)

// Step 3: Trace the order data source (optional)
bash grep -n "class OrderLocalDataSource" lib/features/orders/data/datasources/order_local_datasource.dart
```

**Key Methods:**
- `OrderCubit.createOrderFromCart(List<OrderItem> items)` — Creates new order
- `OrderCubit.updateOrderStatus(id, status, {note})` — Changes order status
- `OrderCubit.cancelOrder(id)` — Sets status to Cancelled
- `OrderLocalDataSource` — In-memory order storage with mock data

**Mock Data Loaded In:**
```dart
// Initial orders seeded in OrderLocalDataSource._cachedOrders
// Supports state changes during a session (not persisted)
```

---

### Example 5: Checking Localization Coverage

**Goal:** Ensure all UI strings are translated (no hardcoded strings in screens)

**❌ Wrong Way:**
```bash
grep -r "Text\(" lib/features/*/presentation/screens/
grep -r "const Text" lib/
find lib -name "*.dart" -exec grep "Text('.*')" {} \;
```

**✅ Right Way:**

```dart
// Step 1: Find all non-translated text
code_intelligence_search({
  query: "hardcoded English strings not using context.l10n in UI",
  currentFiles: ["lib/features/"]
})

// Result: If any found, lists them (should be empty if compliant)

// Step 2: Check localization extension usage
code_intelligence_impact({
  paths: ["lib/core/extensions/localization_extension.dart"]
})

// Result: Shows all files importing the extension, all screens should be here

// Step 3: Run the actual validation (optional)
bash grep -r "Text('" lib/features/*/presentation/screens/ | grep -v "context.l10n"
```

**Compliance Rule:**
Every `Text()`, tooltip, hint, label, SnackBar message in UI must use `context.l10n.key`.

**Pattern Check:**
```dart
// ✅ CORRECT
Text(context.l10n.loginTitle)
TextField(hintText: context.l10n.emailHint)
Tooltip(message: context.l10n.addToCartTooltip)

// ❌ WRONG (NOT ALLOWED)
Text('Login')
Text(AppConstants.title)
const Text('Button Label')
```

---

## Dart/Flutter-Specific Tips

### Cubit State Changes
**Search:** "How does [CubitName] emit state?"
```dart
code_intelligence_search({
  query: "OrderCubit state emissions and event handling"
})
```

### Widget Hierarchy
**Search:** "What widgets consume [HookOrProvider]?"
```dart
code_intelligence_impact({
  paths: ["lib/features/orders/presentation/cubits/order_cubit.dart"]
})
```

### Navigation Routes
**Search:** "What routes are available and how to navigate?"
```dart
code_intelligence_search({
  query: "GoRouter route configuration and StatefulShellRoute"
})
```

### Testing
**Search:** "What tests cover this feature?"
```dart
code_intelligence_impact({
  paths: ["lib/features/orders/presentation/cubits/order_cubit.dart"]
})
// Result includes test counterparts like order_cubit_test.dart
```

---

## Token Budget Expectations

| Task | Expected Tokens | Acceptable Range |
|------|-----------------|------------------|
| Find feature implementation | 80 | 60–120 |
| Understand impact of change | 100 | 80–150 |
| Trace data flow | 120 | 100–180 |
| Check test coverage | 90 | 70–130 |
| Add new translation | 60 | 40–100 |

**If your search exceeds the range:** You likely used broad bash. Switch to code_intelligence tools.

---

## Keko-Specific Rules

### Rule 1: All UI Text Must Be Localized
- Use `context.l10n.keyName` for every visible string
- Add key to `lib/l10n/app_en.arb`, `app_es.arb`, `app_ca.arb`
- Run `flutter gen-l10n` after changes
- **Violation:** Fails `/flutter analyze`, blocks PR

### Rule 2: Exploration First (Code Intelligence)
- Search semantically before bash
- Use `code_intelligence_impact` before refactoring
- Record learnings via `code_intelligence_record_learning`

### Rule 3: Clean Architecture Maintained
- All UI strings in Presentation layer use localization
- Data sources accept dependencies via constructor
- No dead code (YAGNI principle)
- Learnings recorded as `code_intelligence_record_learning` entries

---

## Quick Reference for Keko

```dart
// Find order logic
code_intelligence_search({ query: "order creation and status management" })

// See what depends on OrderCubit
code_intelligence_impact({ paths: ["lib/features/orders/..."] })

// Check localization
bash grep -n "context.l10n" lib/features/profile/presentation/screens/profile_screen.dart

// Verify test coverage
code_intelligence_impact({ paths: ["lib/features/profile/presentation/cubits/profile_cubit.dart"] })

// Find translation keys
bash grep "statTotal\|statReceived" lib/l10n/app_en.arb
```

---

## Links & References

- **Project README:** `docs/` in main repo
- **Generic Exploration Guide:** `iml/EXPLORATION_STRATEGY.md`
- **Code Intelligence Learnings:** Run `/code-intelligence-doctor` in Pi
- **Localization Files:** `lib/l10n/app_*.arb`
- **Architecture Pattern:** Clean Architecture by Uncle Bob

---

**Version:** 1.0  
**Last Updated:** June 2026  
**Status:** Example / Template for Flutter projects
