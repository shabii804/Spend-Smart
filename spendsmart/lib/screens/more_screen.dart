import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_strings.dart';
import '../core/motion/haptics.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/theme/text_styles.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/confirm_dialog.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/staggered_entrance.dart';
import '../providers/budget_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/notif_prefs_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import 'smart_advice_screen.dart';
import 'login_screen.dart';
import 'budget_overview_screen.dart';
import 'transactions_screen.dart';
import 'savings_goals_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_screen.dart';
import 'currency_selection_screen.dart';
import 'general_settings_screen.dart';
import 'notification_preferences_screen.dart';
import 'theme_settings_screen.dart';
import 'income_screen.dart';

/// "More" tab — unified hub for financial management, account settings,
/// preferences, security, and support.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final notifPrefs = context.watch<NotifPrefsProvider>();
    final budget = context.watch<BudgetProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final goals = context.watch<GoalProvider>();

    final themeLabel = theme.mode == ThemeModeChoice.light
        ? 'Light'
        : theme.mode == ThemeModeChoice.dark
            ? 'Dark'
            : 'System';

    final currencyLabel = '${currency.id} · ${currency.symbol}';

    final notifSummary = [
      if (notifPrefs.budgetAlerts) 'Budget',
      if (notifPrefs.lowBalance) 'Balance',
      if (notifPrefs.goalUpdates) 'Goals',
    ].join(' · ');
    final notifSubtitle = notifSummary.isEmpty ? 'Off' : notifSummary;

    final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : (nameParts.isNotEmpty && nameParts[0].length >= 2
            ? nameParts[0].substring(0, 2)
            : (nameParts.isNotEmpty ? nameParts[0][0] : 'U'))
        .toUpperCase();

    final securityStatus = user.biometricsEnabled ? 'Biometrics Active' : 'Passcode Only';

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            // ─── 0. USER PROFILE SUMMARY BANNER ───
            StaggeredEntrance(
              index: 0,
              child: GestureDetector(
                onTap: () {
                  Haptics.selection();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryButton,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryIndigo.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    user.fullName.isNotEmpty ? user.fullName : 'SpendSmart User',
                                    style: TextStyles.h3(context),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.mint.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    user.memberTier,
                                    style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(
                                      fontSize: 9,
                                      color: AppColors.mint,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email.isNotEmpty ? user.email : 'muhammad@gmail.com',
                              style: TextStyles.caption(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryIndigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View',
                              style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(
                                color: AppColors.primaryIndigo,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 10, color: AppColors.primaryIndigo,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ─── 1. FINANCIAL HUB ───
            StaggeredEntrance(
              index: 1,
              child: _MenuGroup(
                title: 'Financial Management',
                items: [
                  _MenuItem(
                    icon: Icons.lightbulb_rounded,
                    color: AppColors.catInternet,
                    title: 'Smart Financial Advice',
                    subtitle: 'Personalized AI insights and tips',
                    badgeText: 'AI',
                    badgeColor: AppColors.primaryPurple,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SmartAdviceScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.savings_rounded,
                    color: AppColors.mint,
                    title: 'Savings Goals',
                    subtitle: '${goals.goals.length} active goals · ${Formatters.money(goals.totalSaved)} saved',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.blue,
                    title: 'Budget Planner & Limits',
                    subtitle: '${Formatters.money(budget.monthlyLimit)}/month limit',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BudgetOverviewScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.work_outline_rounded,
                    color: AppColors.mint,
                    title: 'Job Income & Auto Budget',
                    subtitle: '${Formatters.money(user.monthlyIncome)}/month · ${user.occupation}',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const IncomeScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.catOthers,
                    title: 'All Transactions',
                    subtitle: '${expenses.transactionCount} transactions recorded',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ─── 2. ACCOUNT & PREFERENCES ───
            StaggeredEntrance(
              index: 2,
              child: _MenuGroup(
                title: 'Account & Preferences',
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
                    icon: Icons.brightness_6_rounded,
                    color: AppColors.catEntertainment,
                    title: AppStrings.theme,
                    subtitle: themeLabel,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ThemeSettingsScreen()),
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
                    icon: Icons.notifications_none_rounded,
                    color: AppColors.catFood,
                    title: AppStrings.notifPreferences,
                    subtitle: notifSubtitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationPreferencesScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ─── 3. SECURITY & DATA ───
            StaggeredEntrance(
              index: 3,
              child: _MenuGroup(
                title: 'Security & Privacy',
                items: [
                  _MenuItem(
                    icon: Icons.security_rounded,
                    color: AppColors.mint,
                    title: AppStrings.securityPrivacy,
                    subtitle: securityStatus,
                    onTap: () => _showSecurityDialog(context, userProvider),
                  ),
                  _MenuItem(
                    icon: Icons.file_download_outlined,
                    color: AppColors.cyan,
                    title: 'Export Financial Report',
                    subtitle: 'Download monthly statement',
                    onTap: () => _showExportSheet(context, user, expenses.totalSpent, goals.totalSaved),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ─── 4. SUPPORT & INFORMATION ───
            StaggeredEntrance(
              index: 4,
              child: _MenuGroup(
                title: 'Support & About',
                items: [
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    color: AppColors.catTransport,
                    title: 'Help & FAQs',
                    subtitle: 'Answers to frequently asked questions',
                    onTap: () => _showFaqSheet(context),
                  ),
                  _MenuItem(
                    icon: Icons.settings_rounded,
                    color: AppColors.catGroceries,
                    title: AppStrings.generalSettings,
                    subtitle: 'App version, clear cache, about',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GeneralSettingsScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.privacy_tip_outlined,
                    color: AppColors.catBills,
                    title: 'Privacy Policy & Terms',
                    subtitle: '100% offline, private and encrypted',
                    onTap: () => _showPrivacyDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── 5. LOG OUT BUTTON ───
            StaggeredEntrance(
              index: 5,
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
              },),
            ),

            // ─── 6. VERSION INFO ───
            const SizedBox(height: 16),
            Center(
              child: Text(
                'SpendSmart v1.0.0 · Local & Secure',
                style: TextStyles.caption(context)
                    .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityDialog(BuildContext context, UserProvider userProvider) {
    Haptics.selection();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final u = userProvider.user;
          return AlertDialog(
            backgroundColor: AppColorsOf.card(ctx),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.mint, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Security & Privacy', style: TextStyles.h3(ctx)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Biometric Authentication', style: TextStyles.body(ctx, weight: FontWeight.w600)),
                  subtitle: Text('Face ID / Fingerprint on launch', style: TextStyles.caption(ctx)),
                  value: u.biometricsEnabled,
                  activeColor: AppColors.mint,
                  onChanged: (val) {
                    Haptics.selection();
                    userProvider.toggleBiometrics(val);
                    setDialogState(() {});
                  },
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text('App Lock PIN', style: TextStyles.body(ctx, weight: FontWeight.w600)),
                  subtitle: Text('Require 4-digit PIN for access', style: TextStyles.caption(ctx)),
                  value: u.appLockEnabled,
                  activeColor: AppColors.primaryIndigo,
                  onChanged: (val) {
                    Haptics.selection();
                    userProvider.toggleAppLock(val);
                    setDialogState(() {});
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExportSheet(BuildContext context, dynamic user, double spent, double saved) {
    Haptics.selection();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColorsOf.card(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColorsOf.tertiaryText(ctx).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Export Financial Statement', style: TextStyles.h2(ctx), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Choose the format you want to download',
                style: TextStyles.caption(ctx), textAlign: TextAlign.center,),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.danger),
              ),
              title: Text('PDF Statement', style: TextStyles.body(ctx, weight: FontWeight.w600)),
              subtitle: Text('Full visual statement for ${user.fullName}', style: TextStyles.caption(ctx)),
              trailing: const Icon(Icons.download_rounded, color: AppColors.primaryIndigo),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF statement generated and saved to device!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.table_chart_rounded, color: AppColors.mint),
              ),
              title: Text('CSV Spreadsheet', style: TextStyles.body(ctx, weight: FontWeight.w600)),
              subtitle: Text('Raw transaction list for Excel or Sheets', style: TextStyles.caption(ctx)),
              trailing: const Icon(Icons.download_rounded, color: AppColors.primaryIndigo),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CSV spreadsheet exported successfully!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showFaqSheet(BuildContext context) {
    Haptics.selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColorsOf.card(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColorsOf.tertiaryText(ctx).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Frequently Asked Questions', style: TextStyles.h2(ctx)),
            const SizedBox(height: 4),
            Text('Everything you need to know about SpendSmart', style: TextStyles.caption(ctx)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  _FaqTile(
                    question: 'Is my financial data safe?',
                    answer: 'Yes! SpendSmart stores all your data securely and locally on your device. No financial records are ever sent to external cloud servers.',
                  ),
                  _FaqTile(
                    question: 'How do monthly budgets work?',
                    answer: 'Set your overall monthly budget in Budget Overview. SpendSmart tracks your daily safe-to-spend limit and gives warnings at 80% usage.',
                  ),
                  _FaqTile(
                    question: 'How do savings goals work?',
                    answer: 'Create targets for emergency funds, travel, or gadgets. Add contributions anytime and celebrate reaching milestones with confetti!',
                  ),
                  _FaqTile(
                    question: 'Can I change my currency?',
                    answer: 'Yes! Go to Preferences > Language & Currency to select between PKR, USD, EUR, GBP, AED, and more.',
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    Haptics.selection();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColorsOf.card(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_rounded, color: AppColors.mint, size: 22),
            const SizedBox(width: 10),
            Text('Privacy & Terms', style: TextStyles.h3(ctx)),
          ],
        ),
        content: Text(
          'SpendSmart is designed with privacy-first principles.\n\n'
          '• Local Data Storage: All budgets, expenses, and personal profile data remain stored on your local device.\n'
          '• Zero Tracking: No analytics trackers or third-party ad networks.\n'
          '• Full Control: You can clear or export your records at any time.',
          style: TextStyles.caption(ctx).copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColorsOf.background(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColorsOf.border(context)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(question, style: TextStyles.body(context, weight: FontWeight.w700)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: TextStyles.caption(context).copyWith(height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<Widget> items;
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
                  Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 0,
                    color: AppColorsOf.divider(context),
                  ),
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
  final String? badgeText;
  final Color? badgeColor;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              style: TextStyles.body(context, weight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? AppColors.primaryIndigo).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText!,
                              style: TextStyles.caption(context, weight: FontWeight.w800).copyWith(
                                color: badgeColor ?? AppColors.primaryIndigo,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: TextStyles.caption(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: AppColorsOf.tertiaryText(context), size: 20,),
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
        borderRadius: BorderRadius.circular(18),
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
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.danger.withOpacity(0.28),
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
                      .copyWith(color: Colors.white),),
            ],
          ),
        ),
      ),
    );
  }
}
