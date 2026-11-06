# SpendSmart — Viva Notes (Copy-Ready)

## 1. Short project introduction

**SpendSmart is a Flutter and Dart personal expense-tracking application designed for students.** It lets a user record expenses, organize them by category, monitor a monthly budget, review spending charts, create savings goals, and adjust app settings. The interface supports light and dark themes and multiple display currencies.

The current project is a **front-end demo**: its starting content comes from local sample data, and the providers keep most changes in memory while the app is running. `SharedPreferences` saves selected preferences such as theme, currency, and notification toggles. The app does not connect to a real authentication service or remote database.

### One-minute explanation

> “SpendSmart is built with Flutter, so one Dart codebase can provide a cross-platform mobile-style UI. The app starts in `main.dart`, where I register state providers, then `app.dart` builds the `MaterialApp` with light and dark themes. Screens are in `lib/screens`, reusable interface components are in `lib/core/widgets`, and shared colors, formatting, validation, and motion helpers are in `lib/core`. Provider classes manage expenses, budgets, goals, notifications, user details, currency, and theme. Sample records are defined in `lib/data/sample_data.dart`. When a provider changes, it calls `notifyListeners()` and listening widgets rebuild.”

## 2. Project structure and how data flows

```text
lib/
├── main.dart                 App entry point and provider setup
├── app.dart                  MaterialApp, themes, and first screen
├── core/
│   ├── widgets/              Reusable UI components used by screens
│   ├── theme/                Colors, gradients, text styles, ThemeData
│   ├── constants/            Shared labels, sizes, keys, motion tokens
│   ├── utils/                Currency/date formatters and validators
│   └── motion/               Animation, haptics, logo, route transitions
├── data/sample_data.dart     Initial demo user, expenses, goals, etc.
├── models/                   Data structures for app entities
├── providers/                App state and operations
└── screens/                  Full-page UI and screen-specific components
```

### Explain the data flow

1. `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()` and runs the app inside a `MultiProvider`.
2. Each `ChangeNotifierProvider` creates one provider, for example `ExpenseProvider`.
3. Providers initialize their state, commonly by copying a list from `SampleData`.
4. A screen reads state with Provider, such as `context.watch<ExpenseProvider>()`, or requests an operation with `context.read<ExpenseProvider>()`.
5. The provider changes its state and calls `notifyListeners()`.
6. Widgets listening to that provider rebuild and show the updated values.
7. `app.dart` watches `ThemeProvider` to choose the active `ThemeMode`.

**Why use providers?** They separate app state and business operations from presentation widgets, provide shared state to multiple screens, and make UI updates reactive without manually passing every value through every constructor.

## 3. Reusable widget folder — `lib/core/widgets/`

These widgets are small reusable building blocks. Screens compose them rather than reimplementing the same button, card, or empty state repeatedly.

| File | Main widget/API | Viva explanation |
|---|---|---|
| `animated_money.dart` | `AnimatedMoney` | Displays a monetary amount that animates/counts when its value changes; used for dashboard and summary figures. |
| `app_icon_button.dart` | `AppIconButton` | Standard icon-only action button with a defined touch target and semantic label, used for actions such as back, edit, delete, or notifications. |
| `app_snackbar.dart` | `AppSnackbar` | Central helper for feedback messages; can show an optional action such as Undo and gives haptic feedback. |
| `app_text_field.dart` | `AppTextField`, `PasswordField` | Shared labeled input with controller, validation, keyboard, prefix/suffix, and enabled options. `PasswordField` adds a show/hide control. |
| `category_chip.dart` | `CategoryChip` | Compact selectable category control showing an icon, label, and selected state. |
| `confetti_burst.dart` | `ConfettiBurst` | Shows a short, custom confetti animation, suitable for a goal or success moment. |
| `confirm_dialog.dart` | `ConfirmDialog` | Reusable confirmation dialog for consequential actions, such as delete or logout. |
| `empty_state.dart` | `EmptyState` | Consistent empty-list presentation with icon, title, subtitle, and entrance animation; supports reduced-motion behavior. |
| `error_state.dart` | `ErrorState` | Error presentation with message and optional Retry callback. |
| `floating_nav_bar.dart` | `FloatingNavBar` | Floating bottom navigation with four tab slots and a central FAB callback; includes selection/press animations. |
| `glass_card.dart` | `GlassCard` | Shared rounded, theme-aware surface/card with optional padding, margin, color, border, and tap behavior. |
| `loading_shimmer.dart` | `LoadingShimmer`, `SkeletonBlock` | Shimmer/skeleton placeholders used to represent content while loading. |
| `modern_icon_badge.dart` | `ModernIconBadge` | Decorative icon container with gradient, optional glow, and optional tap animation. |
| `money_text.dart` | `MoneyText` | Text widget for formatting and displaying money consistently with the app’s current currency. |
| `premium_motion.dart` | `PremiumLoadingIndicator`, `MorphingLoadingButton`, `AmbientBackgroundAnimation`, `PasswordStrengthMeter`, `PremiumSuccessAnimation`, `AnimatedAuthRoute` | Collection of polished loading, background, password-strength, success, and authentication-transition UI helpers. |
| `primary_button.dart` | `PrimaryButton` | Main call-to-action button with gradient, optional icon, loading state, haptic feedback, and press-scale animation. |
| `progress_bar.dart` | `ProgressBar`, `ProgressBarFraction` | Reusable progress indicators for budget usage, goals, and category spending. |
| `screen_entrance.dart` | `ScreenEntrance`, `ChartEntrance` | Entrance effects for screen content and charts. |
| `secondary_button.dart` | `SecondaryButton` | Alternative action button for non-primary actions, with a consistent style and press response. |
| `section_header.dart` | `SectionHeader` | Standard title/header for a section, optionally paired with an action. |
| `staggered_entrance.dart` | `StaggeredEntrance` | Animates a list of children into view in sequence rather than all at once. |
| `stat_card.dart` | `StatCard`, `QuickActionTile` | Small summary/stat card and reusable dashboard quick-action tile. |
| `success_overlay.dart` | `SuccessOverlay` | Presents a success dialog/overlay with an animated visual confirmation. |
| `swipe_to_reveal_actions.dart` | `SwipeToRevealActions`, `SwipeAction` | Reveals actions when a list item is swiped, such as edit or delete. |

### Widget questions you may be asked

**Q: Why create reusable widgets?**  
A: They reduce duplicated code, keep a consistent visual design, and let a change to a shared component improve every screen that uses it.

**Q: When do you choose `StatelessWidget` or `StatefulWidget`?**  
A: I use a `StatelessWidget` when the widget only renders values passed to it. I use a `StatefulWidget` when it owns temporary UI state or an animation controller, such as a password visibility toggle or a press animation.

**Q: Why dispose animation controllers or text controllers?**  
A: They own resources and listeners. Disposing them when the state object is removed prevents resource leaks and callbacks after the widget is gone.

**Q: What is the difference between an empty state and an error state?**  
A: Empty state means there is no content to display; error state means an operation failed. An error state may provide a Retry callback.

## 4. Screen files — `lib/screens/`

The screen folder contains full-page screens and some screen-specific chart/authentication components. Navigation is mainly pushed with `Navigator` for sub-pages, while `MainShell` switches the four primary tabs.

### App launch and authentication

| File | What it does |
|---|---|
| `splash_screen.dart` | Animated launch screen; decides when to continue into the app/onboarding flow. |
| `onboarding_screen.dart` | Introductory onboarding pages for a first-time user. |
| `login_screen.dart` | Local/demo sign-in form; not backed by a real authentication server. |
| `register_screen.dart` | Registration form using shared validation and user-profile state; demo/local behavior. |
| `forgot_password_screen.dart` | Email form and confirmation UI for a simulated password-reset flow. |
| `shared_auth_components.dart` | Shared authentication layout/components to keep auth screens visually consistent. |

### Main navigation and dashboard

| File | What it does |
|---|---|
| `main_shell.dart` | Main app shell: Home, Activity, Analytics, and More tabs; opens Add Expense from the central FAB and pushes other routes. |
| `home_screen.dart` | Dashboard with spending/budget summary, shortcuts, charts, categories, recent transactions, and profile access. |
| `spending_line_chart.dart` | Reusable dashboard line chart built with `fl_chart`. |
| `weekly_bar_chart.dart` | Weekly bar-chart component built with `fl_chart`. |
| `more_screen.dart` | More/features hub for secondary screens such as goals, budgets, settings, and advice. |

### Expenses and transactions

| File | What it does |
|---|---|
| `add_expense_screen.dart` | Form to create an expense and, where supported, populate an existing expense for editing. |
| `edit_expense_screen.dart` | Edit-expense entry point/wrapper that opens the shared expense form in edit mode. |
| `transactions_screen.dart` | Activity list with transaction browsing, search, and filtering. |
| `expense_details_screen.dart` | Details for a selected expense, with access to edit/delete actions. |
| `category_selection_screen.dart` | Category picker used when assigning a category to an expense. |
| `voice_entry_screen.dart` | Voice-entry-style UI for quickly drafting an expense; the project describes this as simulated, not a speech-recognition backend. |
| `receipt_scanner_screen.dart` | Receipt image selection/scanning-style flow using `image_picker`; do not describe it as a connected OCR service unless one is later added. |
| `split_bill_screen.dart` | Screen for the split-bill flow/calculation UI. |

### Budget and analytics

| File | What it does |
|---|---|
| `budget_overview_screen.dart` | Monthly budget summary and per-category spending progress. |
| `edit_budget_screen.dart` | Form to change the budget limit through `BudgetProvider`. |
| `analytics_screen.dart` | Daily/weekly/monthly spending summaries, category breakdown, and charts based on expense-provider data. |

### Savings goals

| File | What it does |
|---|---|
| `savings_goals_screen.dart` | Lists savings goals and overall goal progress. |
| `create_goal_screen.dart` | Form to create a goal, including its name, icon, target, planned saving, and target date. |
| `goal_details_screen.dart` | Details and progress for one goal, with actions such as adding money. |
| `add_money_screen.dart` | Adds an amount to a selected goal through `GoalProvider`. |

### Advice, notifications, profile, and settings

| File | What it does |
|---|---|
| `smart_advice_screen.dart` | Shows spending tips derived from current provider data. |
| `notifications_screen.dart` | Displays sample notifications and read/unread actions. |
| `profile_screen.dart` | Shows the current profile and profile statistics/actions. |
| `edit_profile_screen.dart` | Edits profile details through `UserProvider`. |
| `general_settings_screen.dart` | Settings hub linking to theme, currency, and notification preferences. |
| `notification_preferences_screen.dart` | Toggles notification preference flags. |
| `currency_selection_screen.dart` | Selects the display currency. This changes formatting, not exchange rates or stored values. |
| `theme_settings_screen.dart` | Selects light, dark, or system theme. |

### Development / preview

| File | What it does |
|---|---|
| `motion_debug_screen.dart` | Development showcase for animation and motion components; not a core expense-management screen. |

## 5. Other `lib/` files: state, models, and sample data

### Providers — `lib/providers/`

| File | Responsibility |
|---|---|
| `expense_provider.dart` | Owns the expense list; add/update/delete/look-up operations; derives totals, category/day/week/month aggregates, recent transactions, and chart data. |
| `budget_provider.dart` | Owns the monthly budget and updates the limit. |
| `goal_provider.dart` | Owns goals; add/update/delete, add savings to a goal, and calculate overall saved/target progress. |
| `theme_provider.dart` | Stores light/dark/system choice and loads/saves it with `SharedPreferences`. |
| `currency_provider.dart` | Stores selected currency ID, symbol, and locale; persists the choice and updates `Formatters`. |
| `notification_provider.dart` | Owns sample notification items, unread count, and mark-read operations. |
| `notif_prefs_provider.dart` | Stores the budget, low-balance, and goal-update preference toggles using `SharedPreferences`. |
| `user_provider.dart` | Owns current profile details and updates profile/security-toggle state in memory. |

### Models — `lib/models/`

| File | Represents |
|---|---|
| `expense.dart` | An expense: ID, title, amount, category ID, date, and optional note. Includes `copyWith` for immutable-style updates. |
| `category.dart` | A category: stable ID, display name, icon, and color. |
| `budget.dart` | Monthly budget limit. |
| `goal.dart` | Savings goal with target/saved amounts, target date, monthly saving, progress, remaining amount, and completion status. |
| `app_notification.dart` | Notification content, type, icon/color, and read state. |
| `user_profile.dart` | User/profile fields used by the UI, such as name, email, income, and app preference flags. |

### Demo data

`data/sample_data.dart` is the source of the initial demo user, budget, category list, expense list, savings goals, and notifications. Expense records use `categoryId` to refer to category IDs. Keep those IDs consistent when changing sample data.

## 6. Shared core code — `lib/core/`

### Theme files

| File | Responsibility |
|---|---|
| `theme/app_theme.dart` | Builds the light and dark Material `ThemeData`, including text and input themes. |
| `theme/app_colors.dart` | Central color palette, semantic/category colors, and theme-aware color helpers/extensions. |
| `theme/app_gradients.dart` | Reusable gradients for buttons, FABs, progress, splash, and hero surfaces. |
| `theme/text_styles.dart` | Shared typography helpers so screens use consistent text styles. |

### Constants and utilities

| File | Responsibility |
|---|---|
| `constants/app_constants.dart` | Shared sizing/radius/duration values, persistence keys, and navigation/layout constants. |
| `constants/app_strings.dart` | Central user-facing labels and messages. |
| `constants/motion.dart` | Animation timing/curve tokens and stagger configuration. |
| `utils/formatters.dart` | Formats currency, dates, times, ranges, and relative time; currency settings are supplied by `CurrencyProvider`. |
| `utils/validators.dart` | Reusable form rules for required fields, email, password, confirmation, and positive amounts. |

### Motion and branding

| File | Responsibility |
|---|---|
| `motion/app_motion.dart` | Shared animation durations/curves, spring settings, stagger timing, and reduced-motion handling. |
| `motion/motion_widgets.dart` | General animation widgets, including press, shake, drawn checkmark, count-up text, shimmer, and icon bounce. |
| `motion/page_transitions.dart` | Shared smooth fade/page-transition helpers. |
| `motion/haptics.dart` | Central haptic-feedback helpers. |
| `motion/app_logo.dart` | Reusable app logo variants and custom logo painting. |

## 7. Package/library list

These are the direct dependencies in `pubspec.yaml`:

| Package | What it is used for in this project |
|---|---|
| `flutter` (SDK) | Core UI framework, widgets, navigation, Material design, and platform integration. |
| `cupertino_icons` | Cupertino-style icon set available to the UI. |
| `google_fonts` | Access to Google Fonts; the project uses Plus Jakarta Sans styling. Local font assets are also declared in `pubspec.yaml`. |
| `provider` | Dependency injection and reactive state management using `Provider`, `ChangeNotifierProvider`, and `ChangeNotifier`. |
| `fl_chart` | Line, bar, and donut/pie-style charts for spending analytics. |
| `shared_preferences` | Lightweight local persistence for preferences such as theme, currency, and notification toggles. It is not a replacement for a database. |
| `intl` | Locale-aware currency, number, date, and time formatting. |
| `image_picker` | Lets the receipt-scanner-style screen request/select an image from a device source. |

### Development dependencies

| Package | Purpose |
|---|---|
| `flutter_test` | Flutter widget/unit test framework. |
| `flutter_lints` | Dart/Flutter lint rules. |
| `flutter_launcher_icons` | Generates launcher icons from configured image assets. |
| `flutter_native_splash` | Generates native splash-screen resources from configuration. |

**Useful distinction:** `pubspec.yaml` lists packages available to the project; a package’s presence does not mean every screen uses it. `provider`, `fl_chart`, `intl`, `shared_preferences`, and `image_picker` are the key runtime packages to explain.

## 8. Important implementation details to explain

- **Reactive state:** Providers extend `ChangeNotifier`. Mutations call `notifyListeners()` to rebuild dependent widgets.
- **Charts:** Chart UI is drawn with `fl_chart`, while aggregation data comes from `ExpenseProvider`.
- **Money display:** `CurrencyProvider` updates the symbol and locale used by `Formatters`. Selecting USD/EUR/GBP changes display formatting only; the app does not convert the numeric amount using exchange rates.
- **Persistence boundary:** Theme, currency, and notification preferences use `SharedPreferences`. Demo expenses, goals, and user-profile changes are generally in-memory provider state; do not claim they are saved to a backend.
- **Navigation:** `MainShell` controls the four bottom tabs. The central FAB opens Add Expense. Secondary screens use Navigator routes and custom transitions.
- **Forms:** Shared fields and `Validators` reduce repeated input styling and validation logic.
- **Accessibility/interaction:** The shared icon button has a semantic label and touch-target sizing; buttons/widgets can provide haptic feedback and animations.
- **Stateful widget lifecycle:** Controllers and animation controllers should be disposed in `dispose()`.
- **Sample data period:** The expense provider intentionally anchors some dashboard/month calculations to the most recent expense month, so the October 2026 sample data remains visible even when the current month differs.

## 9. Common viva questions with ready answers

**Q: What is Flutter?**  
A: Flutter is Google’s UI toolkit for building apps from a shared Dart codebase. Its widget system describes the interface, and Flutter renders that interface for the target platform.

**Q: What is Dart?**  
A: Dart is the programming language used by this application. It supports object-oriented programming, null safety, asynchronous operations, and Flutter’s widget-based UI.

**Q: What is a widget?**  
A: A widget is an immutable description of part of the UI. Widgets can be composed into a tree; Flutter rebuilds the relevant parts when state or inputs change.

**Q: What is the purpose of `main.dart`?**  
A: It is the entry point. It initializes Flutter bindings, registers app-wide providers with `MultiProvider`, and runs `SpendSmartApp`.

**Q: What does `ChangeNotifier` do?**  
A: It exposes a notification mechanism. A provider changes its state and calls `notifyListeners()` so listening widgets can refresh.

**Q: What is the difference between `context.watch` and `context.read`?**  
A: `watch` subscribes the widget to changes and rebuilds it when the provider notifies. `read` accesses the provider without subscribing, which is useful for invoking an action.

**Q: What is `SharedPreferences` used for here?**  
A: It stores small key-value preferences locally, such as the theme, selected currency, and notification settings. It is not the app’s full database.

**Q: How are expenses represented?**  
A: Each `Expense` has an ID, title, amount, category ID, date, and optional note. The category ID links the record to the category list.

**Q: How do charts get their values?**  
A: `ExpenseProvider` calculates totals and time/category groupings, and chart widgets display those values using `fl_chart`.

**Q: Does changing currency convert the money?**  
A: No. It changes the currency symbol and locale used for formatting. There is no exchange-rate service in the current app.

**Q: Is the login connected to a server?**  
A: No. Authentication screens are local/demo UI and do not authenticate against a backend.

**Q: Why are reusable widgets important in this project?**  
A: Shared buttons, cards, fields, progress bars, and state widgets provide a consistent design and make changes easier to maintain.

**Q: What would you improve next?**  
A: I would add a secure authentication service and persistent database, validate the complete flows with integration tests, and then add real receipt OCR or speech recognition behind clear permission/error handling.

## 10. Short screen-demo order

1. Start at the splash/onboarding flow.
2. Show the main dashboard and explain the budget card and recent spending.
3. Add an expense and show its category/date/amount fields.
4. Open Activity and show search/filtering and expense details.
5. Show the Analytics charts and explain that provider aggregates feed them.
6. Open budgets and savings goals; demonstrate a progress update.
7. Finish with theme/currency/notification settings and clarify which preferences persist locally.

## 11. Accuracy notes for the presentation

- Say **“sample/local demo data”**, not “cloud database.”
- Say **“demo authentication UI”**, not “secure login system.”
- Say **“currency display selection”**, not “currency conversion.”
- Say **“receipt image selection/scanner-style flow”**, not “automatic OCR,” unless OCR is implemented separately.
- Say **“simulated voice-entry flow”**, not “speech recognition,” unless a speech-recognition package/service is added.
