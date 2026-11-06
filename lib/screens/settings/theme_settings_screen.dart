import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.themeSettings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: _ThemeCard(
                    icon: Icons.light_mode_rounded,
                    title: AppStrings.light,
                    subtitle: AppStrings.lightSubtitle,
                    color: AppColors.catBills,
                    selected: theme.mode == ThemeModeChoice.light,
                    onTap: () => theme.setMode(ThemeModeChoice.light),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ThemeCard(
                    icon: Icons.dark_mode_rounded,
                    title: AppStrings.dark,
                    subtitle: AppStrings.darkSubtitle,
                    color: AppColors.primaryIndigo,
                    selected: theme.mode == ThemeModeChoice.dark,
                    onTap: () => theme.setMode(ThemeModeChoice.dark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ThemeCard(
              icon: Icons.brightness_auto_rounded,
              title: AppStrings.system,
              subtitle: AppStrings.systemSubtitle,
              color: AppColors.mint,
              selected: theme.mode == ThemeModeChoice.system,
              onTap: () => theme.setMode(ThemeModeChoice.system),
              wide: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Theme persists across app restarts.',
              style: TextStyles.caption(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool wide;

  const _ThemeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          customBorder: Border.all(
            color: selected ? color : AppColorsOf.border(context),
            width: selected ? 1.6 : 1,
          ),
          child: wide
              ? Row(
                  children: [
                    _icon(context),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: TextStyles.body(context, weight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(subtitle, style: TextStyles.caption(context)),
                        ],
                      ),
                    ),
                    if (selected) _check(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _icon(context),
                        if (selected) _check(),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(title,
                        style: TextStyles.body(context, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyles.caption(context)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _icon(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _check() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
    );
  }
}
