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
import '../../providers/notif_prefs_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../auth/login_screen.dart';
import '../budgets/budget_overview_screen.dart';
import '../expenses/transactions_screen.dart';
import '../goals/savings_goals_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../settings/currency_selection_screen.dart';
import '../settings/general_settings_screen.dart';
import '../settings/notification_preferences_screen.dart';
import '../settings/theme_settings_screen.dart';

/// "More" tab — the hub for secondary features and settings.
///
/// Replaces the old Profile tab in the bottom nav. Contains:
///   • Goals (was a bottom-nav tab — moved here per user request)
///   • Account group: Personal Info, Budget Settings, Notification Preferences
///   • Preferences group: Security & Privacy, Language & Currency, Theme
///   • More group: Help & Support, General Settings
///   • Logout button + version info
///
/// The Profile screen itself (identity card with avatar + stats) is now
/// accessed via the avatar tap on the home header, NOT from this tab.
/// This avoids duplication — More is the settings hub, Profile is the
/// identity card.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final notifPrefs = context.watch<NotifPrefsProvider>();
    final budget = context.watch<BudgetProvider>();

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

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text('More', style: TextStyles.h1(context)),
          const SizedBox(height: 20),

          // ─── QUICK ACCESS GROUP — Goals is the headline feature ───
          // Goals was previously a bottom-nav tab. Now lives here as the
          // first item so users can still reach it in one tap from More.
          StaggeredEntrance(
            index: 0,
            child: _MenuGroup(
              title: 'Quick Access',
              items: [
                _MenuItem(
                  icon: Icons.savings_rounded,
                  color: AppColors.mint,
                  title: 'Savings Goals',
                  subtitle: 'Track your savings progress',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SavingsGoalsScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.blue,
                  title: 'All Transactions',
                  subtitle: 'View your spending history',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TransactionsScreen()),
                  ),
                ),
              ],
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

          // ─── MORE GROUP ───
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

          // ─── LOG OUT BUTTON ───
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
                context.read<UserProvider>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            }),
          ),

          // ─── VERSION INFO ───
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
