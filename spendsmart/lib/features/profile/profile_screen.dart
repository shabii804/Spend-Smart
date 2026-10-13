import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../settings/general_settings_screen.dart';
import '../settings/notification_preferences_screen.dart';
import '../settings/theme_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final notifPrefs = context.watch<NotifPrefsProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final goals = context.watch<GoalProvider>();
    final budget = context.watch<BudgetProvider>();

    // ─── Initials calculation (handles single-word names) ───
    // Was: `user.fullName.split(' ').map(...).take(2)` — for a single-word
    // name like "Muhammad", only "M" was shown. Now we pad with the second
    // letter of the first word if there's only one word.
    final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : (nameParts.isNotEmpty && nameParts[0].length >= 2
            ? nameParts[0].substring(0, 2)
            : (nameParts.isNotEmpty ? nameParts[0][0] : ''))
        .toUpperCase();

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

    // Stats for the header — premium profile screens show summary numbers.
    final monthSpent = expenses.totalSpent;
    final txnCount = expenses.transactionCount;
    final goalsSaved = goals.totalSaved;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(AppStrings.profile, style: TextStyles.h1(context)),
          const SizedBox(height: 20),

          // ─── PREMIUM PROFILE HEADER CARD WITH STATS ───
          // Now includes a 3-column stats row (Spent / Txns / Saved) so
          // the user sees their financial summary at a glance.
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
                          width: 64,
                          height: 64,
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
                              fontSize: 22,
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
                        // Edit pill — more obvious affordance than the previous
                        // chevron-in-circle. Says "Edit" so the user knows tapping
                        // the card opens the edit screen.
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
                    // Subtle divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColorsOf.divider(context),
                    ),
                    const SizedBox(height: 14),
                    // ─── Stats row ───
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
          const SizedBox(height: 24),

          // ─── ACCOUNT GROUP ───
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
                  // Show the actual monthly budget value (was a generic
                  // "Monthly Budget" label that didn't communicate the
                  // actual limit).
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
          const SizedBox(height: 24),

          // ─── PREFERENCES GROUP ───
          StaggeredEntrance(
            index: 2,
            child: _MenuGroup(
              title: 'Preferences',
              items: [
                _MenuItem(
                  icon: Icons.lock_outline_rounded,
                  color: AppColors.mint,
                  title: AppStrings.securityPrivacy,
                  subtitle: 'Biometrics & App Lock',
                  // Was: onTap: () {} (empty handler — tapping did nothing).
                  // Now shows a "coming soon" snackbar so the user gets
                  // feedback that the feature is planned but not yet built.
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
                  icon: Icons.brightness_6_rounded,
                  color: AppColors.catInternet,
                  title: AppStrings.theme,
                  subtitle: themeLabel,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── MORE GROUP (with Help & Support added) ───
          StaggeredEntrance(
            index: 3,
            child: _MenuGroup(
              title: 'More',
              items: [
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  color: AppColors.catTransport,
                  title: 'Help & Support',
                  subtitle: 'FAQ, contact us',
                  onTap: () {
                    Haptics.selection();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support — coming soon'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.settings_rounded,
                  color: AppColors.catOthers,
                  title: AppStrings.generalSettings,
                  subtitle: 'About, version 1.0.0',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GeneralSettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── STANDALONE LOG OUT BUTTON ───
          // Now actually clears the session via UserProvider.logout()
          // BEFORE navigating to LoginScreen. Previously it just navigated
          // without clearing the user data, so the session was only
          // visually "logged out" — the user data was still in the
          // provider tree.
          StaggeredEntrance(
            index: 4,
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
                // Clear the user session BEFORE navigating so the provider
                // tree is in a clean state. The next time the app launches
                // or the user navigates back, the splash screen will see
                // no logged-in user.
                context.read<UserProvider>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            }),
          ),

          // ─── VERSION INFO AT THE BOTTOM ───
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
    );
  }
}

/// Compact stat cell used in the profile header — label + value with
/// the value colored to match the semantic (spent=red, txns=indigo,
/// saved=mint).
class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

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

/// Vertical divider between stat cells.
class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColorsOf.divider(context),
    );
  }
}

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
          padding: const EdgeInsets.only(left: 4, bottom: 10),
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
  final bool isDanger;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDanger = false,
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
                    Text(
                      title,
                      style: TextStyles.body(context, weight: FontWeight.w600)
                          .copyWith(
                        color: isDanger ? AppColors.danger : null,
                      ),
                    ),
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
                  color: isDanger
                      ? AppColors.danger.withOpacity(0.4)
                      : AppColorsOf.tertiaryText(context),
                  size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Premium destructive-action style — solid red gradient instead of
    // the previous subtle red-tinted bg. The gradient makes it visually
    // distinct from the menu items above (which are all neutral).
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
              colors: [
                AppColors.danger,
                AppColors.danger.withOpacity(0.85),
              ],
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
              Text(
                AppStrings.logOut,
                style: TextStyles.body(context, weight: FontWeight.w700)
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
