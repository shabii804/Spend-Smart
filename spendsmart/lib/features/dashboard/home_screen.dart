import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_money.dart';
import '../../core/widgets/screen_entrance.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../data/sample_data.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../analytics/analytics_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_details_screen.dart';
import '../expenses/transactions_screen.dart';
import '../expenses/voice_entry_screen.dart';
import '../goals/savings_goals_screen.dart';
import '../notifications/notifications_screen.dart';
import 'weekly_bar_chart.dart';

class HomeScreen extends StatefulWidget {
  /// Tap handler for the profile avatar in the top-right of the home header.
  /// Set by MainShell to switch to the Profile tab (index 3) instead of
  /// pushing a new route — keeps the bottom-nav in sync with the destination.
  final VoidCallback? onAvatarTap;

  const HomeScreen({super.key, this.onAvatarTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final budget = context.watch<BudgetProvider>();
    context.watch<GoalProvider>();
    final notif = context.watch<NotificationProvider>();
    final user = context.watch<UserProvider>().user;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning,'
        : hour < 17
            ? 'Good Afternoon,'
            : 'Good Evening,';

    final limit = budget.monthlyLimit;
    final spent = expenses.totalSpent;
    final remaining = limit - spent;
    final percent = limit == 0 ? 0.0 : spent / limit;

    // Safe-to-spend today — also surfaced in the greeting subtitle so the
    // user sees actionable data on first glance instead of a motivational quote.
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysLeft = (endOfMonth.day - now.day).clamp(0, 31);
    final safeToSpend = daysLeft > 0 ? (remaining / daysLeft).clamp(0.0, double.infinity) : remaining;

    final recent = expenses.recentTransactions(5);
    final top = expenses.topCategories(4);
    final weekly = expenses.last7Days();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        // Pull-to-refresh — manually refresh data on the home screen.
        color: AppColors.primaryIndigo,
        backgroundColor: AppColorsOf.card(context),
        onRefresh: () async {
          HapticFeedback.selectionClick();
          // Trigger a rebuild — providers will recalc from existing sample data.
          await Future.delayed(const Duration(milliseconds: 600));
          if (!context.mounted) return;
          setState(() {});
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _appHeader(context, notif.unreadCount),
                  const SizedBox(height: 14),
                  _greetingRow(context, greeting, user.fullName, spent, safeToSpend),
                ]),
              ),
            ),
            // Budget hero — NO parallax wrapper (the previous _ParallaxHero
            // was dead code: a NotificationListener inside a sliver doesn't
            // catch the parent CustomScrollView's scroll notifications, so
            // the offset stayed at 0 forever).
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _budgetHero(context, spent, remaining, percent, limit),
              ),
            ),
            SliverPadding(
              // Bottom padding adapts to the device's home-indicator inset +
              // 100px so the last item clears the floating bottom nav.
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.paddingOf(context).bottom + 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _quickActions(context),
                  const SizedBox(height: 16),
                  ChartEntrance(
                    child: WeeklyBarChart(data: weekly),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: 'Top Categories',
                    actionLabel: 'See All',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _topCategoriesScroll(context, top),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: AppStrings.recentTransactions,
                    actionLabel: AppStrings.viewAll,
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _recentList(context, recent),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // App header — logo + SpendSmart + tagline | bell + avatar
  // ────────────────────────────────────────────────────────────────
  Widget _appHeader(BuildContext context, int unread) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryButton,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.insights_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SpendSmart',
                style: TextStyles.body(context, weight: FontWeight.w700)
                    .copyWith(fontSize: 16)),
            Text('Track. Plan. Achieve.',
                style: TextStyles.caption(context).copyWith(fontSize: 10)),
          ],
        ),
        const Spacer(),
        _BellButton(
          unread: unread,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        const SizedBox(width: 8),
        // ── Profile avatar — now TAPPABLE ──
        // Switches to the Profile tab via the callback passed by MainShell.
        // Falls back to a no-op if no callback (e.g. preview/test render).
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onAvatarTap?.call();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryButton,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Greeting row — BIG name, light subtitle with ACTIONABLE data
  // (spent today + safe-to-spend today) instead of motivational fluff.
  // ────────────────────────────────────────────────────────────────
  Widget _greetingRow(
    BuildContext context,
    String greeting,
    String fullName,
    double spent,
    double safeToSpend,
  ) {
    final firstName = fullName.split(' ').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                  style: TextStyles.body(context,
                      color: AppColorsOf.secondaryText(context),
                      weight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('$firstName!',
                  style: TextStyles.h1(context).copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5)),
              const SizedBox(height: 4),
              // Actionable subtitle: date + safe-to-spend today.
              // Replaces the previous "Small steps make big progress" motivational
              // tagline that wasted prime real estate.
              Text(
                '${Formatters.dateShort(DateTime.now())} · ${Formatters.money(safeToSpend)} safe to spend today',
                style: TextStyles.caption(context)
                    .copyWith(color: AppColorsOf.tertiaryText(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Budget hero — gradient card with CIRCULAR donut progress
  // Compact: removed the redundant "Spent / Remaining" two-column row
  // (the donut already shows %; spent/remaining are implied by budget +
  // percent) and the "Safe to spend today" line (now surfaced in the
  // greeting subtitle). Saves ~50px so the Weekly bar chart fits above
  // the fold on a typical phone viewport.
  // ────────────────────────────────────────────────────────────────
  Widget _budgetHero(
      BuildContext context, double spent, double remaining, double percent, double limit) {
    // Days left in month + safe-to-spend calculation
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysLeft = (endOfMonth.day - now.day).clamp(0, 31);
    // Ring color: cyan → amber at 80% → red above 100%
    final ringColor = percent >= 1.0 ? AppColors.danger : percent >= 0.8 ? AppColors.warning : AppColors.cyan;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryIndigo.withOpacity(0.32),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.monthlyBudget,
                    style: TextStyles.label(context).copyWith(
                        color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 6),
                // Display amount
                AnimatedMoney(
                  amount: limit,
                  style: TextStyles.moneyHero(context, color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Rs. X left, N days to go — single compact line
                Text('${Formatters.money(remaining.abs())} left · $daysLeft days to go',
                    style: TextStyles.caption(context, weight: FontWeight.w600)
                        .copyWith(color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Circular donut progress — color changes at 80% / 100%
          // The percent text now animates in sync with the ring fill via
          // TweenAnimationBuilder (was previously a static Text).
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.18),
                    valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: percent.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) {
                    final pct = (v * 100).clamp(0, 999).toInt();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$pct%',
                            style: TextStyles.money(context,
                                size: 22, color: Colors.white)),
                        Text('used',
                            style: TextStyles.caption(context).copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Quick actions — premium rounded-square tiles with subtle shadow
  // ────────────────────────────────────────────────────────────────
  Widget _quickActions(BuildContext context) {
    final tiles = [
      ('Scan', Icons.document_scanner_rounded, AppColors.mint,
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              )),
      ('Voice', Icons.mic_rounded, AppColors.primaryPurple,
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VoiceEntryScreen()),
              )),
      ('Insights', Icons.insights_rounded, AppColors.primaryIndigo,
          () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              )),
      ('Goals', Icons.savings_rounded, AppColors.blue,
          () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const SavingsGoalsScreen()),
              )),
    ];
    return Row(
      children: tiles.map((t) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              t.$4();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: AppColorsOf.card(context),
                border: Border.all(color: AppColorsOf.border(context)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: Theme.of(context).brightness == Brightness.light
                    ? [
                        const BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          t.$3.withOpacity(0.22),
                          t.$3.withOpacity(0.10),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(t.$2, color: t.$3, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.$1,
                    style: TextStyles.caption(context, weight: FontWeight.w700)
                        .copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Top categories — horizontal scroll of small cards
  // ────────────────────────────────────────────────────────────────
  Widget _topCategoriesScroll(BuildContext context, List<MapEntry<Category, double>> items) {
    if (items.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppStrings.noDataYet,
          style: TextStyles.body(context,
              color: AppColorsOf.secondaryText(context)),
        ),
      );
    }
    // Use total spent as the denominator so the percentages reflect each
    // category's share of overall spending (not of the top category).
    final totalSpent = items.fold<double>(0.0, (s, e) => s + e.value);
    final safeTotal = totalSpent == 0 ? 1.0 : totalSpent;
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = items[i].key;
          final amt = items[i].value;
          final pct = ((amt / safeTotal) * 100).round();
          // ── Each card is now TAPPABLE ──
          // Tapping a category pushes TransactionsScreen with that
          // category pre-selected as the filter, so the user lands
          // directly on the filtered list.
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransactionsScreen(initialFilter: c.id),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 168,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColorsOf.card(context),
                border: Border.all(color: AppColorsOf.border(context)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.color.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(c.icon, color: c.color, size: 18),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('$pct%',
                            style: TextStyles.caption(context,
                                weight: FontWeight.w700).copyWith(color: c.color, fontSize: 11)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(c.name, style: TextStyles.body(context,
                      weight: FontWeight.w600), maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(Formatters.money(amt),
                      style: TextStyles.body(context, weight: FontWeight.w700)
                          .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Recent transactions — list with RED negative amounts
  // ────────────────────────────────────────────────────────────────
  Widget _recentList(BuildContext context, List<Expense> items) {
    if (items.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Text(AppStrings.noTransactions,
            style: TextStyles.body(context,
                color: AppColorsOf.secondaryText(context))),
      );
    }
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            StaggeredEntrance(
              index: i,
              child: _TransactionTile(
                expense: items[i],
                category: SampleData.categoryById(items[i].categoryId),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExpenseDetailsScreen(expenseId: items[i].id),
                  ),
                ),
              ),
            ),
            if (i != items.length - 1)
              Divider(height: 1, indent: 12, endIndent: 12,
                  color: AppColorsOf.divider(context)),
          ],
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Expense expense;
  final Category category;
  final VoidCallback onTap;

  const _TransactionTile({
    required this.expense,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              // Category-colored left accent bar — premium polish
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: TextStyles.body(context,
                            weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    // Use relative date formatting ("Today 8:45 AM",
                    // "Yesterday 9:13 AM", "Mon 10:00 AM") instead of the
                    // previous "Category · 10 Oct, 12:45 PM" which overflowed
                    // on narrow screens. The colored icon already conveys the
                    // category, so the name prefix was redundant.
                    Text(
                      Formatters.relativeDateTime(expense.date),
                      style: TextStyles.caption(context).copyWith(
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '-${Formatters.money(expense.amount)}',
                style: TextStyles.body(context, weight: FontWeight.w700)
                    .copyWith(
                        color: AppColors.danger,
                        fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Notifications bell button that wiggles once on mount (if there are
/// unread notifications) and again whenever the unread count INCREASES.
/// Red dot badge is 16px (was 8px) with a 2px white ring matching the
/// container background — easier to see, especially for low-vision users.
/// Respects reduce-motion (renders static, no wiggle).
class _BellButton extends StatefulWidget {
  final int unread;
  final VoidCallback onTap;

  const _BellButton({required this.unread, required this.onTap});

  @override
  State<_BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<_BellButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wiggle;
  // Track the previous unread count to detect INCREASES (new notification
  // arrived → wiggle once). Replaces the previous "wiggle every 4s forever"
  // loop which was distracting and battery-draining.
  int? _lastUnread;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lastUnread = widget.unread;
    // Wiggle once shortly after mount if there are unread notifications.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted &&
          widget.unread > 0 &&
          !AppMotion.reduceMotion(context)) {
        _wiggle.forward(from: 0);
      }
    });
  }

  @override
  void didUpdateWidget(_BellButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Wiggle when the unread count INCREASES (new notification arrived).
    if (widget.unread > (oldWidget.unread ?? 0) &&
        !AppMotion.reduceMotion(context)) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _wiggle.forward(from: 0);
      });
    }
    _lastUnread = widget.unread;
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Notifications${widget.unread > 0 ? ', ${widget.unread} unread' : ''}',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColorsOf.card(context),
            shape: BoxShape.circle,
            border: Border.all(color: AppColorsOf.border(context)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Bell icon (rotates back and forth when wiggle fires) ──
              AnimatedBuilder(
                animation: _wiggle,
                builder: (context, child) {
                  // 3 oscillations, ±15°, damped sin wave
                  final t = _wiggle.value;
                  final angle = (t * 6 * 3.14159) * (1 - t) * 0.26;
                  return Transform.rotate(angle: angle, child: child);
                },
                child: Icon(Icons.notifications_none_rounded,
                    color: AppColorsOf.mainText(context), size: 20),
              ),
              // ── Unread badge (scales in when unread > 0) ──
              // 16px badge with a 2px ring matching the container bg —
              // visible at a glance, easier for low-vision users.
              if (widget.unread > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: AppMotion.base,
                    curve: AppMotion.celebrate,
                    builder: (context, v, child) {
                      return Transform.scale(scale: v, child: child);
                    },
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColorsOf.card(context),
                          width: 2,
                        ),
                      ),
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
