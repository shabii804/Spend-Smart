# SpendSmart

A premium student expense-tracking Flutter app — **frontend only**. All data is local sample data managed with Provider. Built as a Mobile Application Development university project.

> Preview-ready and ZIP-ready. The whole `spendsmart/` folder can be downloaded as a ZIP, opened in any IDE with Flutter installed, and run with `flutter pub get && flutter run`.

---

## Features

- **Onboarding + Auth (5 screens)** — splash, 3-page onboarding, login, register, forgot password. All local; no real auth.
- **Dashboard** — greeting row, monthly budget hero card with animated progress, 4 quick-action tiles, 7-day spending line chart, top categories, recent transactions.
- **Expenses (6 screens)** — add expense, simulated voice entry, transactions list with search + filter chips, expense details, edit, category selection grid.
- **Budgets (2 screens)** — overview with per-category mini bars, edit budget.
- **Analytics** — Daily / Weekly / Monthly segmented filter, donut chart, monthly bar chart, average daily spend, highest spending day.
- **Goals (4 screens)** — savings goals list, create, details with hero animation + completion state, add money with quick chips.
- **Smart Advice** — 3–4 suggestion cards derived from real provider data (top category, transport tip, pacing, savings boost).
- **Notifications** — list with type icons, tap-to-read, Mark All Read.
- **Profile + Settings (6 screens)** — profile, edit profile, general settings, notification toggles, currency selection, theme settings.
- **Floating bottom nav** with central gradient FAB. IndexedStack preserves tab state.
- **Light + Dark themes** with full styling; theme persists across restarts.
- **Currency switching** (PKR / USD / EUR / GBP) — display-only formatting change.
- **Charts read from providers** — add/edit/delete expense instantly updates dashboard, transactions, analytics, and budget progress.

Total: **30+ screens** following the spec exactly.

---

## Tech Stack

- Flutter stable (>=3.24.0), Dart (>=3.4.0)
- Material 3 with custom light + dark ThemeData
- `google_fonts` — Plus Jakarta Sans (fetched at runtime; falls back to Material default if offline)
- `provider` — state management
- `fl_chart` — donut + bar + line charts
- `shared_preferences` — theme preference, first-launch flag, notification prefs, currency
- `intl` — currency + date formatting

Only allowed packages are used; no extra dependencies that break web/emulator preview.

---

## Folder Structure

```
spendsmart/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
├── web/                       # Flutter web entry (index.html + icons)
├── assets/
│   ├── images/.gitkeep        # Placeholder for future image assets
│   └── fonts/                 # Empty — fonts fetched via google_fonts
├── test/
│   └── app_test.dart
└── lib/
    ├── main.dart              # Entry point + providers wiring
    ├── app.dart               # MaterialApp root
    ├── core/
    │   ├── theme/              # app_colors, app_theme, app_gradients, text_styles
    │   ├── constants/         # app_constants, app_strings
    │   ├── utils/             # formatters, validators
    │   └── widgets/           # primary_button, glass_card, app_text_field,
    │                          # category_chip, progress_bar, stat_card,
    │                          # section_header, floating_nav_bar,
    │                          # empty_state, confirm_dialog, loading_shimmer
    ├── models/                # expense, category, budget, goal,
    │                          # app_notification, user_profile
    ├── data/sample_data.dart  # ← ALL DEMO DATA LIVES HERE
    ├── providers/             # expense, budget, goal, theme, notification,
    │                          # currency, notif_prefs, user
    └── features/
        ├── splash/            # splash_screen
        ├── onboarding/        # onboarding_screen
        ├── auth/              # login, register, forgot_password
        ├── dashboard/         # main_shell, home_screen, spending_line_chart
        ├── expenses/          # add_expense, voice_entry, transactions,
        │                      # expense_details, edit_expense, category_selection
        ├── budgets/           # budget_overview, edit_budget
        ├── analytics/         # analytics_screen (donut + bar)
        ├── goals/             # savings_goals, create_goal, goal_details, add_money
        ├── advice/            # smart_advice_screen
        ├── notifications/     # notifications_screen
        ├── profile/           # profile_screen, edit_profile_screen
        └── settings/          # general_settings, notification_preferences,
                               # currency_selection, theme_settings
```

---

## How to Run

1. Make sure Flutter is installed (`flutter --version`). Stable channel ≥ 3.24 recommended.
2. From the `spendsmart/` folder:
   ```bash
   flutter pub get
   flutter run                 # Choose Chrome / Android / iOS / Web
   ```
3. For release web build:
   ```bash
   flutter build web
   ```
4. The first launch shows the splash → onboarding (first run only) → dashboard. Subsequent launches skip onboarding automatically (the flag is stored in SharedPreferences).

---

## How to Change Sample Data

Open `lib/data/sample_data.dart` and edit the constants. Every screen reads from this single source of truth.

- **User** — change `SampleData.user` (full name + email).
- **Budget** — change `SampleData.budget.monthlyLimit` (default Rs. 25,000).
- **Categories** — edit `SampleData.categories` (id, name, icon, color). Each `Expense.categoryId` references these IDs.
- **Sample expenses** — edit `SampleData.expenses`. Each entry has `id`, `title`, `amount`, `categoryId`, `date`, and optional `note`.
- **Savings goals** — edit `SampleData.goals` (id, name, icon, target, saved, monthly, targetDate).
- **Notifications** — edit `SampleData.notifications`.

> Tip: keep the IDs stable across rebuilds — `Expense.categoryId` and `Goal.id` are how records are linked together.

To change the default currency / theme / notification toggles, edit the SharedPreferences defaults in:
- `lib/providers/currency_provider.dart` (default `'PKR'`)
- `lib/providers/theme_provider.dart` (default `ThemeModeChoice.system`)
- `lib/providers/notif_prefs_provider.dart` (all default to `true`)

---

## Self-Check Report

- `flutter analyze` — **PASS** (0 errors, 0 warnings)
- `flutter build web` — **PASS** (compiles end-to-end)
- `flutter test` — **PASS**
- All 30 screens exist and are reachable via navigation
- Light and dark themes both fully styled
- Charts and dashboard read from providers, zero hardcoded money values in widgets
- Add/edit/delete expense updates dashboard, transactions, analytics instantly
- Add Money updates goal progress bars
- Search + filters + analytics period filters work
- Theme choice persists after restart; first-launch flag works
- Central FAB opens Add Expense; bottom nav never overlaps content
