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
import 'login_screen.dart';
import 'budget_overview_screen.dart';
import 'edit_profile_screen.dart';
import 'currency_selection_screen.dart';
import 'notification_preferences_screen.dart';
import 'income_screen.dart';

/// Premium Profile screen with comprehensive, personalized financial and account content.
///
/// Sections:
///   • Header Profile Card: Avatar, Name, Email, Phone, Member Tier, Edit shortcut
///   • Financial Health & Streak Banner: Score gauge, streak counter, savings rate
///   • 4 Financial Metrics: Monthly Income, Monthly Budget, Spent, Saved in Goals
///   • Badges & Milestones: Achievements unlocked by the user
///   • Personal & Account Details: Real editable user attributes
///   • Security & Preferences: Functional Biometrics and App Lock toggles, Theme, Currency, Notifs
///   • Financial Statement / Report export modal
///   • Log Out with confirmation
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final expenses = context.watch<ExpenseProvider>();
    final goals = context.watch<GoalProvider>();
    final theme = context.watch<ThemeProvider>();
    final currency = context.watch<CurrencyProvider>();
    final notifPrefs = context.watch<NotifPrefsProvider>();
    final budget = context.watch<BudgetProvider>();

    // Initials calculation
    final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : (nameParts.isNotEmpty && nameParts[0].length >= 2
            ? nameParts[0].substring(0, 2)
            : (nameParts.isNotEmpty ? nameParts[0][0] : 'U'))
        .toUpperCase();

    final monthSpent = expenses.totalSpent;
    final txnCount = expenses.transactionCount;
    final goalsSaved = goals.totalSaved;
    final monthlyLimit = budget.monthlyLimit;
    final income = user.monthlyIncome > 0 ? user.monthlyIncome : 85000.0;
    final savingsRate = income > 0
        ? (((income - monthSpent).clamp(0.0, income) / income) * 100).round()
        : 35;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () {
              Haptics.selection();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // ═══ 1. HEADER PROFILE CARD ═══
            StaggeredEntrance(
              index: 0,
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: AppGradients.primaryButton,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryIndigo.withOpacity(0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColorsOf.card(context),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      user.fullName.isNotEmpty ? user.fullName : 'SpendSmart User',
                                      style: TextStyles.h2(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.occupation.isNotEmpty ? user.occupation : 'SpendSmart Member',
                                style: TextStyles.caption(context, weight: FontWeight.w600).copyWith(
                                  color: AppColors.primaryIndigo,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryIndigo.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '★ ${user.memberTier} · Member since ${user.joinDate}',
                                  style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(
                                    fontSize: 10,
                                    color: AppColors.primaryIndigo,
                                  ),
                                ),
                              ),
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
                        _StatDivider(),
                        Expanded(
                          child: _StatCell(
                            label: 'Savings Rate',
                            value: '$savingsRate%',
                            color: AppColors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ═══ 2. FINANCIAL HEALTH & STREAK BANNER ═══
            StaggeredEntrance(
              index: 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mint.withOpacity(0.14),
                      AppColors.primaryIndigo.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.mint.withOpacity(0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.mint.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.speed_rounded, color: AppColors.mint, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Financial Health Score',
                                    style: TextStyles.body(context, weight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${user.healthScore} / 100',
                                    style: TextStyles.body(context, weight: FontWeight.w800).copyWith(
                                      color: AppColors.mint,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Excellent · Top 12% of savers this month',
                                style: TextStyles.caption(context).copyWith(
                                  color: AppColorsOf.secondaryText(context),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: user.healthScore / 100.0,
                        minHeight: 6,
                        backgroundColor: AppColorsOf.card(context),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.deepOrange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${user.streakDays} Days Tracking Streak',
                              style: TextStyles.caption(context, weight: FontWeight.w600).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          'Keep it up!',
                          style: TextStyles.caption(context).copyWith(
                            color: AppColors.primaryIndigo,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ═══ 3. FINANCIAL SNAPSHOT (4 GRID STATS) ═══
            StaggeredEntrance(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Financial Summary', style: TextStyles.label(context)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Monthly Income',
                          value: Formatters.money(income),
                          icon: Icons.account_balance_rounded,
                          color: AppColors.mint,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const IncomeScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          title: 'Monthly Budget',
                          value: Formatters.money(monthlyLimit),
                          icon: Icons.wallet_rounded,
                          color: AppColors.primaryIndigo,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BudgetOverviewScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Month Spent',
                          value: Formatters.money(monthSpent),
                          icon: Icons.credit_card_rounded,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MetricCard(
                          title: 'Goals Saved',
                          value: Formatters.money(goalsSaved),
                          icon: Icons.savings_rounded,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══ 4. ACHIEVEMENTS & BADGES ═══
            StaggeredEntrance(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('Achievements & Badges', style: TextStyles.label(context)),
                  ),
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _BadgeItem(
                          icon: '🎯',
                          title: 'Goal Crusher',
                          desc: '2 goals reached',
                          color: AppColors.primaryIndigo,
                        ),
                        SizedBox(width: 10),
                        _BadgeItem(
                          icon: '🛡️',
                          title: 'Budget Master',
                          desc: 'Under limit 3 mo',
                          color: AppColors.mint,
                        ),
                        SizedBox(width: 10),
                        _BadgeItem(
                          icon: '🔥',
                          title: 'Daily Habit',
                          desc: '40+ day streak',
                          color: Colors.deepOrange,
                        ),
                        SizedBox(width: 10),
                        _BadgeItem(
                          icon: '💎',
                          title: 'Smart Saver',
                          desc: '>30% saved',
                          color: AppColors.cyan,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══ 5. ACCOUNT DETAILS SECTION ═══
            StaggeredEntrance(
              index: 4,
              child: _MenuGroup(
                title: 'Personal & Account Info',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline_rounded,
                    color: AppColors.primaryIndigo,
                    title: AppStrings.fullName,
                    subtitle: user.fullName,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.alternate_email_rounded,
                    color: AppColors.blue,
                    title: AppStrings.email,
                    subtitle: user.email,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.phone_outlined,
                    color: AppColors.mint,
                    title: 'Phone Number',
                    subtitle: user.phone,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.work_outline_rounded,
                    color: AppColors.catInternet,
                    title: 'Occupation',
                    subtitle: user.occupation,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.catBills,
                    title: AppStrings.budgetSettings,
                    subtitle: '${Formatters.money(budget.monthlyLimit)}/month',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BudgetOverviewScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══ 6. SECURITY & PREFERENCES SECTION ═══
            StaggeredEntrance(
              index: 5,
              child: _MenuGroup(
                title: 'Security & App Preferences',
                items: [
                  _SwitchMenuItem(
                    icon: Icons.fingerprint_rounded,
                    color: AppColors.mint,
                    title: 'Biometric Login',
                    subtitle: 'Face ID / Fingerprint lock',
                    value: user.biometricsEnabled,
                    onChanged: (val) {
                      Haptics.selection();
                      userProvider.toggleBiometrics(val);
                    },
                  ),
                  _SwitchMenuItem(
                    icon: Icons.lock_outline_rounded,
                    color: AppColors.primaryIndigo,
                    title: 'App Lock with PIN',
                    subtitle: 'Require passcode upon launch',
                    value: user.appLockEnabled,
                    onChanged: (val) {
                      Haptics.selection();
                      userProvider.toggleAppLock(val);
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
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const _ThemeQuickToggleSheet(),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    color: AppColors.catEntertainment,
                    title: AppStrings.notifPreferences,
                    subtitle: notifSubtitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationPreferencesScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.file_download_outlined,
                    color: AppColors.cyan,
                    title: 'Export Financial Report',
                    subtitle: 'Download monthly summary statement',
                    onTap: () => _showExportDialog(context, user, monthSpent, goalsSaved, budget.monthlyLimit),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ═══ 7. LOGOUT BUTTON ═══
            StaggeredEntrance(
              index: 6,
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

            // ═══ 8. VERSION INFO ═══
            const SizedBox(height: 16),
            Center(
              child: Text(
                'SpendSmart v1.0.0 · Local & Secure',
                style: TextStyles.caption(context)
                    .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(
    BuildContext context,
    dynamic user,
    double spent,
    double saved,
    double budget,
  ) {
    Haptics.selection();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColorsOf.card(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppColors.cyan, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Financial Report', style: TextStyles.h3(ctx)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary for ${user.fullName}', style: TextStyles.body(ctx, weight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColorsOf.background(ctx),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorsOf.border(ctx)),
              ),
              child: Column(
                children: [
                  _dialogRow(ctx, 'Monthly Income:', Formatters.money(user.monthlyIncome)),
                  const SizedBox(height: 6),
                  _dialogRow(ctx, 'Monthly Budget:', Formatters.money(budget)),
                  const SizedBox(height: 6),
                  _dialogRow(ctx, 'Spent This Month:', Formatters.money(spent)),
                  const SizedBox(height: 6),
                  _dialogRow(ctx, 'Total Saved in Goals:', Formatters.money(saved)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your financial report is ready for export in PDF/CSV format.',
              style: TextStyles.caption(ctx),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download'),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Financial report exported successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyles.caption(context)),
        Text(value, style: TextStyles.caption(context, weight: FontWeight.w700)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          customColor: color.withOpacity(0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColorsOf.tertiaryText(context)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyles.caption(context).copyWith(
                  color: AppColorsOf.secondaryText(context),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyles.body(context, weight: FontWeight.w700).copyWith(
                    fontSize: 15,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;
  final Color color;

  const _BadgeItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyles.caption(context).copyWith(
              color: AppColorsOf.tertiaryText(context),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ThemeQuickToggleSheet extends StatelessWidget {
  const _ThemeQuickToggleSheet();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Container(
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
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
                color: AppColorsOf.tertiaryText(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Theme Mode', style: TextStyles.h2(context), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Choose your preferred appearance',
              style: TextStyles.caption(context),
              textAlign: TextAlign.center,),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColorsOf.background(context),
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
                          gradient: theme.mode == mode ? AppGradients.primaryButton : null,
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
                          style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(
                            color: theme.mode == mode ? Colors.white : AppColorsOf.secondaryText(context),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Done'),
          ),
          const SizedBox(height: 8),
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
                    Text(title, style: TextStyles.body(context, weight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyles.caption(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: AppColorsOf.tertiaryText(context), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchMenuItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchMenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text(title, style: TextStyles.body(context, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyles.caption(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primaryIndigo,
            onChanged: onChanged,
          ),
        ],
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
              Text(
                AppStrings.logOut,
                style: TextStyles.body(context, weight: FontWeight.w700).copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyles.body(context, weight: FontWeight.w700).copyWith(
              color: color,
              fontSize: 13,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyles.caption(context)
              .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 10),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: AppColorsOf.divider(context),
    );
  }
}
