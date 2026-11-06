# SpendSmart — VIVA Notes

Quick reference for the project viva. Everything here reflects the actual code in this repository.

---

## 1. Project Overview

- **What:** A premium student expense-tracking Flutter app (Mobile Application Development university project).
- **Scope:** Frontend only — all data is local sample data managed with Provider. No backend, no real authentication.
- **Platforms:** Web (primary, deployed to GitHub Pages) and Android.

---

## 2. Tech Stack

| Component | Choice | Why |
|---|---|---|
| Framework | Flutter (Material 3) | Single codebase for web + Android |
| State management | Provider | Official recommended approach for small apps |
| Charts | fl_chart | Donut, bar and line charts |
| Persistence | shared_preferences | Theme, currency, first-launch flag, notification prefs |
| Fonts | google_fonts | Plus Jakarta Sans, fetched at runtime |
| Formatting | intl | Currency and date formatting |

---

## 3. Architecture (`lib/`)

- `main.dart` — entry point; wires all providers with `MultiProvider`.
- `app.dart` — `MaterialApp` root; light + dark `ThemeData`, theme mode from provider.
- `core/` — shared building blocks:
  - `constants/` — app-wide constants and strings.
  - `theme/` — colors, gradients, text styles, ThemeData.
  - `utils/` — formatters, validators.
  - `widgets/` — reusable components (buttons, glass card, floating nav bar, stat card…).
  - `motion/` — animation system (entrances, haptics, app logo).
- `models/` — plain data classes: Expense, Category, Budget, Goal, AppNotification, UserProfile.
- `data/sample_data.dart` — **single source of truth for all demo data**.
- `providers/` — `ChangeNotifier` state: expense, budget, goal, theme, currency, notification, notification prefs, user.
- `screens/` — one folder per feature: splash, onboarding, auth, dashboard, expenses, budgets, analytics, goals, advice, notifications, profile, settings.

---

## 4. Data Flow (frequent viva question)

```
SampleData → Providers (ChangeNotifier) → Screens (watch / Consumer)
```

Every add/edit/delete calls `notifyListeners()`, so dashboard, transactions, analytics and budget progress update instantly. Widgets contain **zero hardcoded money values** — they read from providers.

---

## 5. Key Concepts to Be Ready to Explain

- **Provider vs setState** — avoids prop-drilling; only widgets listening to a provider rebuild.
- **ChangeNotifier / notifyListeners** — the observable pattern behind Provider.
- **IndexedStack** — keeps all tabs alive in the floating bottom-nav shell (state preserved).
- **ThemeMode (light/dark/system)** — persisted with shared_preferences, restored on restart.
- **First-launch flag** — onboarding runs once; the flag is stored in SharedPreferences.
- **Currency switching** — display-only formatting via intl; amounts stay in base currency.

---

## 6. Likely Viva Questions

**Q: Is this connected to a real database?**
A: No — frontend only. All data comes from `lib/data/sample_data.dart` and lives in memory + preferences.

**Q: How does the login work?**
A: Simulated local auth screens (login / register / forgot password) — no real authentication service.

**Q: How do charts update when I add an expense?**
A: The expense provider notifies listeners; dashboard line chart, analytics donut/bar and budget bars all rebuild from provider data.

**Q: What is a Provider?**
A: A wrapper around InheritedWidget that exposes ChangeNotifier state down the widget tree and rebuilds only listening widgets.

**Q: How is the theme persisted?**
A: `ThemeProvider` writes the chosen ThemeMode to SharedPreferences on change and restores it at startup.

**Q: What are the app's limitations?** (good to admit honestly)
A: No backend, no real auth, sample data resets on reinstall, currency switching is display-only.

---

## 7. Screen Count

**30+ screens** across: splash, onboarding (3 pages), auth (3), dashboard, expenses (6), budgets (2), analytics, goals (4), advice, notifications, profile (2), settings (4).
