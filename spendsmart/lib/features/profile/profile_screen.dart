import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/currency_provider.dart';
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
    final initials = user.fullName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
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

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          Text(AppStrings.profile, style: TextStyles.h1(context)),
          const SizedBox(height: 20),
          // ─── PREMIUM TAPPABLE PROFILE HEADER CARD ───
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
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
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryIndigo.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.primaryIndigo, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // ─── ACCOUNT GROUP ───
          _MenuGroup(
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
                subtitle: AppStrings.budgetMonthly,
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
          const SizedBox(height: 24),
          // ─── PREFERENCES GROUP ───
          _MenuGroup(
            title: 'Preferences',
            items: [
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                color: AppColors.mint,
                title: AppStrings.securityPrivacy,
                subtitle: 'Biometrics & App Lock',
                onTap: () {},
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
          const SizedBox(height: 24),
          // ─── MORE GROUP ───
          _MenuGroup(
            title: 'More',
            items: [
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
          const SizedBox(height: 24),
          // ─── STANDALONE LOG OUT BUTTON ───
          _LogOutButton(onTap: () async {
            final ok = await ConfirmDialog.show(
              context,
              title: AppStrings.logOut,
              body: AppStrings.logoutConfirmBody,
              confirmLabel: AppStrings.logOut,
              danger: true,
              icon: Icons.logout_rounded,
            );
            if (ok == true && context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            }
          }),
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
            color: AppColors.danger.withOpacity(0.08),
            border: Border.all(color: AppColors.danger.withOpacity(0.18)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
              const SizedBox(width: 8),
              Text(
                AppStrings.logOut,
                style: TextStyles.body(context, weight: FontWeight.w700)
                    .copyWith(color: AppColors.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
