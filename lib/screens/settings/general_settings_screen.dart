import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/currency_provider.dart';
import '../../providers/notif_prefs_provider.dart';
import '../../providers/theme_provider.dart';
import 'currency_selection_screen.dart';
import 'notification_preferences_screen.dart';
import 'theme_settings_screen.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final notifPrefs = context.watch<NotifPrefsProvider>();

    final themeLabel = theme.mode == ThemeModeChoice.light
        ? 'Light'
        : theme.mode == ThemeModeChoice.dark
            ? 'Dark'
            : 'System';

    final notifSummary = [
      if (notifPrefs.budgetAlerts) 'Budget',
      if (notifPrefs.lowBalance) 'Low Balance',
      if (notifPrefs.goalUpdates) 'Goals',
    ].join(' · ');
    final notifSubtitle = notifSummary.isEmpty ? 'All off' : notifSummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.generalSettings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _Group(
              title: 'Account',
              items: [
                _SettingsItem(
                  icon: Icons.lock_outline_rounded,
                  color: AppColors.mint,
                  title: AppStrings.securityPrivacy,
                  subtitle: 'Biometrics & App Lock',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.language_rounded,
                  color: AppColors.catBills,
                  title: AppStrings.languageCurrency,
                  subtitle: 'English · ${currency.id} ${currency.symbol}',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CurrencySelectionScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Group(
              title: 'Display',
              items: [
                _SettingsItem(
                  icon: Icons.brightness_6_rounded,
                  color: AppColors.catInternet,
                  title: AppStrings.theme,
                  subtitle: themeLabel,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ThemeSettingsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Group(
              title: 'Notifications',
              items: [
                _SettingsItem(
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
            _Group(
              title: 'About',
              items: [
                _SettingsItem(
                  icon: Icons.info_outline_rounded,
                  color: AppColors.primaryIndigo,
                  title: 'About SpendSmart',
                  subtitle: 'v1.0.0',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _Group({required this.title, required this.items});

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
                  Divider(height: 1, color: AppColorsOf.divider(context)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SettingsItem({
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
                    Text(title, style: TextStyles.body(context, weight: FontWeight.w600)),
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
