import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../providers/budget_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/notif_prefs_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../budgets/budget_overview_screen.dart';
import 'edit_profile_screen.dart';
import '../settings/currency_selection_screen.dart';
import '../settings/notification_preferences_screen.dart';

/// Premium Profile screen — identity card + account + preferences + logout.
///
/// Sections:
///   • Premium header: avatar + name + email + stats (Spent/Txns/Saved) + Edit
///   • Account: Personal Info, Budget Settings, Notification Preferences
///   • Preferences: Theme quick-toggle (Light/Dark/System), Language & Currency, Security
///   • Logout (premium red gradient button)
///   • Version info
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final expenses = context.watch<ExpenseProvider>();
    final goals = context.watch<GoalProvider>();
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final notifPrefs = context.watch<NotifPrefsProvider>();
    final budget = context.watch<BudgetProvider>();

    // ─── Initials calculation (handles single-word names) ───
    final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : (nameParts.isNotEmpty && nameParts[0].length >= 2
            ? nameParts[0].substring(0, 2)
            : (nameParts.isNotEmpty ? nameParts[0][0] : ''))
        .toUpperCase();

    final monthSpent = expenses.totalSpent;
    final txnCount = expenses.transactionCount;
    final goalsSaved = goals.totalSaved;

    final themeLabel = theme.mode == ThemeModeChoice.light
        ? 'Light'
        : theme.mode == ThemeModeChoice.dark
            ? 'Dark'
            : 'System';

    final currencyLabel = '${currency.id} · ${currency.symbol}';

    final notifSummary = [
      if (notifPrefs.budgetAlerts) 'Budget',
      if (notifPrefs.lowBalance) 'Low Balance',
      if (notifPrefs.goalUpdates) 'Goals',
    ].join(' · ');
    final notifSubtitle = notifSummary.isEmpty ? 'Off' : notifSummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            // ═══ PREMIUM HEADER CARD ═══
            StaggeredEntrance(
              index: 0,
              child: GestureDetector(
                onTap: () {
                  Haptics.selection();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryButton,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryIndigo.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName,
                                    style: TextStyles.h3(context),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(user.email,
                                    style: TextStyles.caption(context),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryIndigo.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit_rounded,
                                    color: AppColors.primaryIndigo, size: 13),
                                const SizedBox(width: 4),
                                Text('Edit',
                                    style: TextStyles.caption(context, weight: FontWeight.w700)
                                        .copyWith(color: AppColors.primaryIndigo, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, thickness: 1, color: AppColorsOf.divider(context)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCell(
                              label: 'Spent',
                              value: Formatters.money(monthSpent),
                              color: AppColors.danger,
                            ),
                          ),
                          _StatDivider(),
                          Expanded(
                            child: _StatCell(
                              label: 'Txns',
                              value: '$txnCount',
                              color: AppColors.primaryIndigo,
                            ),
                          ),
                          _StatDivider(),
                          Expanded(
                            child: _StatCell(
                              label: 'Saved',
                              value: Formatters.money(goalsSaved),
                              color: AppColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ═══ ACCOUNT SECTION ═══
            StaggeredEntrance(
              index: 1,
              child: _MenuGroup(
                title: 'Account',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    color: AppColors.primaryIndigo,
                    title: AppStrings.personalInfo,
                    subtitle: user.fullName,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.blue,
                    title: AppStrings.budgetSettings,
                    subtitle: '${Formatters.money(budget.monthlyLimit)}/mo',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BudgetOverviewScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    color: AppColors.catEntertainment,
                    title: AppStrings.notifPreferences,
                    subtitle: notifSubtitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const NotificationPreferencesScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ═══ PREFERENCES SECTION (with inline Theme toggle) ═══
            StaggeredEntrance(
              index: 2,
              child: _MenuGroup(
                title: 'Preferences',
                items: [
                  // ── Theme quick-toggle (inline segmented control) ──
                  _MenuItem(
                    icon: Icons.brightness_6_rounded,
                    color: AppColors.catInternet,
                    title: AppStrings.theme,
                    subtitle: themeLabel,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const _ThemeQuickToggleSheet()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.language_rounded,
                    color: AppColors.catBills,
                    title: AppStrings.languageCurrency,
                    subtitle: 'English · $currencyLabel',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CurrencySelectionScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.lock_outline_rounded,
                    color: AppColors.mint,
                    title: AppStrings.securityPrivacy,
                    subtitle: 'Biometrics & App Lock',
                    onTap: () {
                      Haptics.selection();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Security & Privacy — coming soon'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ═══ LOGOUT BUTTON (premium red gradient) ═══
            StaggeredEntrance(
              index: 3,
              child: _LogOutButton(onTap: () async {
                final ok = await ConfirmDialog.show(
                  context,
                  title: AppStrings.logOut,
                  body: AppStrings.logoutConfirmBody,
                  confirmLabel: AppStrings.logOut,
                  danger: true,
                  icon: Icons.logout_rounded,
                );
                if (ok == true && context.mounted) {
                  Haptics.heavy();
                  context.read<UserProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              }),
            ),

            // ═══ VERSION INFO ═══
            const SizedBox(height: 16),
            Center(
              child: Text(
                'SpendSmart v1.0.0',
                style: TextStyles.caption(context)
                    .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with a segmented control for quick theme switching.
/// Opens when the user taps "Theme" in the Preferences section.
/// Lets the user switch between Light / Dark / System without pushing
/// a full screen — much faster than the ThemeSettingsScreen.
class _ThemeQuickToggleSheet extends StatelessWidget {
  const _ThemeQuickToggleSheet();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColorsOf.tertiaryText(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Theme', style: TextStyles.h2(context), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Choose how SpendSmart looks',
              style: TextStyles.caption(context),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Segmented control
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColorsOf.card(context),
              border: Border.all(color: AppColorsOf.border(context)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                for (final mode in ThemeModeChoice.values)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Haptics.selection();
                        theme.setMode(mode);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: theme.mode == mode
                              ? AppGradients.primaryButton
                              : null,
                          color: theme.mode == mode ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          mode == ThemeModeChoice.light
                              ? 'Light'
                              : mode == ThemeModeChoice.dark
                                  ? 'Dark'
                                  : 'System',
                          textAlign: TextAlign.center,
                          style: TextStyles.caption(context, weight: FontWeight.w700)
                              .copyWith(
                            color: theme.mode == mode
                                ? Colors.white
                                : AppColorsOf.secondaryText(context),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Preview of current theme
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorsOf.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColorsOf.border(context)),
            ),
            child: Row(
              children: [
                Icon(
                  theme.mode == ThemeModeChoice.dark
                      ? Icons.dark_mode_rounded
                      : theme.mode == ThemeModeChoice.light
                          ? Icons.light_mode_rounded
                          : Icons.brightness_auto_rounded,
                  color: AppColors.primaryIndigo,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    theme.mode == ThemeModeChoice.dark
                        ? 'Dark mode is active'
                        : theme.mode == ThemeModeChoice.light
                            ? 'Light mode is active'
                            : 'Following system setting',
                    style: TextStyles.body(context, weight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Done'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Menu group — label + GlassCard with dividers between items
// ─────────────────────────────────────────────────────────────────
class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: TextStyles.label(context)),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1)
                  Divider(height: 1, indent: 16, endIndent: 0,
                      color: AppColorsOf.divider(context)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.22),
                      color.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyles.body(context, weight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: TextStyles.caption(context),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: AppColorsOf.tertiaryText(context), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium logout button — solid red gradient with glow shadow.
class _LogOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.danger, AppColors.danger.withOpacity(0.85)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(AppStrings.logOut,
                  style: TextStyles.body(context, weight: FontWeight.w700)
                      .copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact stat cell used in the profile header.
class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyles.body(context, weight: FontWeight.w700)
                .copyWith(color: color, fontSize: 14,
                    fontFeatures: const [FontFeature.tabularFigures()])),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyles.caption(context)
                .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 10)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 32, margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColorsOf.divider(context),
    );
  }
}
