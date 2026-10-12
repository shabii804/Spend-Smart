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
  const HomeScreen({super.key});

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

    final recent = expenses.recentTransactions(5);
    final top = expenses.topCategories(4);
    final weekly = expenses.last7Days();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _appHeader(context, notif.unreadCount),
                const SizedBox(height: 20),
                _greetingRow(context, greeting, user.fullName),
              ]),
            ),
          ),
          // Budget hero with parallax — translates slower than scroll
          SliverToBoxAdapter(
            child: _ParallaxHero(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _budgetHero(context, spent, remaining, percent, limit),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _quickActions(context),
                const SizedBox(height: 28),
                ChartEntrance(
                  child: WeeklyBarChart(data: weekly),
                ),
                const SizedBox(height: 28),
                SectionHeader(
                  title: 'Top Categories',
                  actionLabel: 'See All',
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TransactionsScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _topCategoriesScroll(context, top),
                const SizedBox(height: 28),
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
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryButton,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Greeting row — BIG name, light subtitle (clear hierarchy)
  // ────────────────────────────────────────────────────────────────
  Widget _greetingRow(BuildContext context, String greeting, String fullName) {
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
              // Date merged into subtitle (replaces date pill)
              Text('${Formatters.dateShort(DateTime.now())} · Small steps make big progress',
                  style: TextStyles.caption(context)
                      .copyWith(color: AppColorsOf.tertiaryText(context))),
            ],
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Budget hero — gradient card with CIRCULAR donut progress
  // ────────────────────────────────────────────────────────────────
  Widget _budgetHero(
      BuildContext context, double spent, double remaining, double percent, double limit) {
    final pctInt = (percent * 100).clamp(0, 999).toInt();
    // Days left in month + safe-to-spend calculation
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysLeft = (endOfMonth.day - now.day).clamp(0, 31);
    final safeToSpend = daysLeft > 0 ? (remaining / daysLeft).clamp(0.0, double.infinity) : remaining;
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
                const SizedBox(height: 8),
                // 40px display amount
                AnimatedMoney(
                  amount: limit,
                  style: TextStyles.moneyHero(context, color: Colors.white),
                ),
                const SizedBox(height: 12),
                // Safe to spend today
                Text('Safe to spend today: ${Formatters.money(safeToSpend)}',
                    style: TextStyles.caption(context, weight: FontWeight.w600)
                        .copyWith(color: Colors.white.withOpacity(0.9))),
                const SizedBox(height: 4),
                // Rs. X left, N days to go
                Text('${Formatters.money(remaining.abs())} left · $daysLeft days to go',
                    style: TextStyles.caption(context)
                        .copyWith(color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.spentThisMonth,
                            style: TextStyles.label(context).copyWith(
                                color: Colors.white.withOpacity(0.7))),
                        const SizedBox(height: 2),
                        AnimatedMoney(
                          amount: spent,
                          style: TextStyles.money(context,
                              size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.remaining,
                            style: TextStyles.label(context).copyWith(
                                color: Colors.white.withOpacity(0.7))),
                        const SizedBox(height: 2),
                        AnimatedMoney(
                          amount: remaining.abs(),
                          style: TextStyles.money(context,
                              size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Circular donut progress — color changes at 80% / 100%
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$pctInt%',
                        style: TextStyles.money(context,
                            size: 22, color: Colors.white)),
                    Text('used',
                        style: TextStyles.caption(context).copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10)),
                  ],
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
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
                    width: 48,
                    height: 48,
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
                    child: Icon(t.$2, color: t.$3, size: 28),
                  ),
                  const SizedBox(height: 8),
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
          return Container(
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
                    Text(
                      '${category.name} · ${Formatters.dateTime(expense.date)}',
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

/// Parallax wrapper — translates child slower than scroll for depth effect.
/// Uses NotificationListener to track scroll without managing a controller.
class _ParallaxHero extends StatefulWidget {
  final Widget child;
  const _ParallaxHero({required this.child});

  @override
  State<_ParallaxHero> createState() => _ParallaxHeroState();
}

class _ParallaxHeroState extends State<_ParallaxHero> {
  double _offset = 0.0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final pixels = notification.metrics.pixels;
          if (pixels >= 0) {
            setState(() {
              // Parallax depth: hero moves up at 25% of scroll speed
              _offset = (pixels * 0.25).clamp(0.0, 120.0);
            });
          }
        }
        return false;
      },
      child: Transform.translate(
        offset: Offset(0, -_offset),
        child: widget.child,
      ),
    );
  }
}

/// Notifications bell button that wiggles periodically when there are
/// unread notifications. Red dot badge appears with a scale pop.
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

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Schedule the first wiggle after 800ms, then repeat every 4 seconds.
    // Only wiggles when there are unread notifications (checked in _scheduleNext).
    _scheduleNext(const Duration(milliseconds: 800));
  }

  void _scheduleNext(Duration delay) {
    Future.delayed(delay, () {
      if (!mounted) return;
      if (widget.unread > 0 && !AppMotion.reduceMotion(context)) {
        _wiggle.forward(from: 0);
      }
      _scheduleNext(const Duration(seconds: 4));
    });
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
              if (widget.unread > 0)
                Positioned(
                  top: 8,
                  right: 9,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: AppMotion.base,
                    curve: AppMotion.celebrate,
                    builder: (context, v, child) {
                      return Transform.scale(scale: v, child: child);
                    },
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
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
