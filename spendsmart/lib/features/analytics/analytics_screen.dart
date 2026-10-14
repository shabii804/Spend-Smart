import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_money.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/screen_entrance.dart';
import '../../data/sample_data.dart';
import '../../providers/expense_provider.dart';

enum AnalyticsPeriod { daily, weekly, monthly }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsPeriod _period = AnalyticsPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final total = expenses.totalSpent;
    final avg = expenses.averageDailySpend;
    final highest = expenses.highestSpendingDay;
    final top = expenses.topCategories(8);
    final dailyMap = expenses.dailyTotals;
    final last7 = expenses.last7Days();
    final last4Weeks = expenses.last4Weeks();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.analytics),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (ModalRoute.of(context)?.canPop ?? false) {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: SafeArea(
        // Pull-to-refresh — manually refresh the analytics data.
        child: RefreshIndicator(
          color: AppColors.primaryIndigo,
          backgroundColor: AppColorsOf.card(context),
          onRefresh: () async {
            Haptics.selection();
            await Future.delayed(const Duration(milliseconds: 600));
            if (!context.mounted) return;
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              // Segmented control — now actually switches the chart view.
              _periodToggle(),
              const SizedBox(height: 12),
              // Two summary cards — deltas removed (were hardcoded "+12%"
              // and "+8%" fake values). Now shows a clean "this month" label
              // instead of misleading the user with fake percentages.
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Total Spending',
                      amount: total,
                      deltaText: 'this month',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.primaryIndigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Average Daily',
                      amount: avg,
                      deltaText: 'this month',
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Spending chart — switches between Daily (bar 7d),
              // Weekly (bar 4w), and Monthly (line) based on _period.
              ChartEntrance(
                child: _buildPeriodChart(expenses, dailyMap, total, last7, last4Weeks),
              ),
              const SizedBox(height: 12),
              // Spending Breakdown — donut + right legend
              ChartEntrance(
                delay: const Duration(milliseconds: 160),
                child: _BreakdownDonut(total: total, items: top),
              ),
              const SizedBox(height: 12),
              // Two insight cards at bottom
              Row(
                children: [
                  Expanded(
                    child: _InsightCard(
                      label: 'Highest Spending Day',
                      value: highest == null ? '-' : Formatters.money(highest.value),
                      sub: highest == null ? '-' : Formatters.dateShort(highest.key),
                      icon: Icons.event_rounded,
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InsightCard(
                      label: 'Top Category',
                      value: top.isEmpty
                          ? '-'
                          : '${((top.first.value / (total == 0 ? 1 : total)) * 100).round()}%',
                      sub: top.isEmpty ? '-' : top.first.key.name,
                      icon: Icons.emoji_events_rounded,
                      // Use the actual top category's color (was hardcoded
                      // to AppColors.catBills which is for the Bills category,
                      // not for "Top Category" in general).
                      color: top.isEmpty ? AppColors.primaryIndigo : top.first.key.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the chart widget matching the selected period.
  /// - Daily: vertical bar chart of last 7 days.
  /// - Weekly: vertical bar chart of last 4 weeks.
  /// - Monthly: smooth line/area chart across the current month.
  Widget _buildPeriodChart(
    ExpenseProvider expenses,
    Map<String, double> dailyMap,
    double total,
    List<MapEntry<String, double>> last7,
    List<MapEntry<String, double>> last4Weeks,
  ) {
    switch (_period) {
      case AnalyticsPeriod.daily:
        return _PeriodBarChart(
          data: last7,
          total: last7.fold(0.0, (s, e) => s + e.value),
          title: 'Daily Spending',
          subtitle: 'Last 7 days',
          icon: Icons.bar_chart_rounded,
        );
      case AnalyticsPeriod.weekly:
        return _PeriodBarChart(
          data: last4Weeks,
          total: last4Weeks.fold(0.0, (s, e) => s + e.value),
          title: 'Weekly Spending',
          subtitle: 'Last 4 weeks',
          icon: Icons.view_week_rounded,
          isWeekly: true,
        );
      case AnalyticsPeriod.monthly:
        return _SpendingAreaChart(dailyMap: dailyMap, total: total);
    }
  }

  Widget _periodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        border: Border.all(color: AppColorsOf.border(context)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (final p in AnalyticsPeriod.values)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Haptics.selection();
                  setState(() => _period = p);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _period == p ? AppGradients.primaryButton : null,
                    color: _period == p ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _periodLabel(p),
                    textAlign: TextAlign.center,
                    style: TextStyles.caption(context, weight: FontWeight.w700)
                        .copyWith(
                      color: _period == p
                          ? Colors.white
                          : AppColorsOf.secondaryText(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _periodLabel(AnalyticsPeriod p) {
    switch (p) {
      case AnalyticsPeriod.daily:
        return AppStrings.daily;
      case AnalyticsPeriod.weekly:
        return AppStrings.weekly;
      case AnalyticsPeriod.monthly:
        return AppStrings.monthly;
    }
  }
}

// ----------------------------------------------------------------
// Summary card — value + optional "this month" label (no fake deltas).
// Removed the hardcoded "+12%" / "+8%" delta parameters that were
// misleading the user. Now shows a clean subtitle instead.
// ----------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  final String label;
  final String deltaText;
  final IconData icon;
  final Color color;
  final double amount;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.deltaText,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: SizedBox(
        height: 80,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(label,
                      style: TextStyles.label(context),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
              ],
            ),
            const Spacer(),
            AnimatedMoney(
              amount: amount,
              style: TextStyles.money(context, size: 18)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 4),
            Text(deltaText,
                style: TextStyles.caption(context)
                    .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------
// Spending Overview — smooth area line chart across the full month.
// Generates a 1..N day series so the x-axis is calendar-correct.
// ----------------------------------------------------------------
class _SpendingAreaChart extends StatefulWidget {
  final Map<String, double> dailyMap;
  final double total;
  const _SpendingAreaChart({required this.dailyMap, required this.total});

  @override
  State<_SpendingAreaChart> createState() => _SpendingAreaChartState();
}

class _SpendingAreaChartState extends State<_SpendingAreaChart> {
  bool _showData = false;

  @override
  void initState() {
    super.initState();
    // Trigger line draw-in animation after first frame.
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a full-month series (day 1..lastDay) with 0 for missing days.
    final anchor = widget.dailyMap.keys.isNotEmpty
        ? _parseAnchorMonth(widget.dailyMap.keys.first)
        : DateTime.now();
    final lastDay = DateTime(anchor.year, anchor.month + 1, 0).day;
    final series = List.generate(lastDay, (i) {
      final day = i + 1;
      final key = '${anchor.year}-${anchor.month}-$day';
      return _DayPoint(day: day, value: widget.dailyMap[key] ?? 0.0);
    });

    if (series.every((e) => e.value == 0)) {
      // Empty state — was previously a plain GlassCard with text.
      // Now uses the shared EmptyState widget (animated medallion entrance)
      // for consistency with Transactions + Goals screens.
      return const SizedBox(
        height: 240,
        child: EmptyState(
          icon: Icons.bar_chart_outlined,
          title: 'No spending data yet',
          subtitle: 'Add an expense to see your monthly trend.',
        ),
      );
    }

    final maxVal = series.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final safeMax = _niceMax(maxVal);
    final activeIdx = series.indexWhere((e) => e.value == maxVal);
    final safeActiveIdx = activeIdx < 0 ? 0 : activeIdx;

    // Build spots: all 0 on first render, real values after _showData flips.
    final spots = [
      for (int i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), _showData ? series[i].value : 0),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      decoration: BoxDecoration(
        // Subtle linear gradient background — indigo tint fading to card surface.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryIndigo.withOpacity(0.06),
            AppColorsOf.card(context),
            AppColorsOf.card(context),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(color: AppColorsOf.border(context)),
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Overview', style: TextStyles.h3(context)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph_rounded,
                    color: AppColors.primaryIndigo, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${Formatters.money(widget.total)} this month',
            style: TextStyles.caption(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  horizontalInterval: safeMax / 4,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColorsOf.divider(context),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: safeMax,
                // Padding so the curve doesn't touch the edges.
                clipData: const FlClipData.none(),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: safeMax / 4,
                      getTitlesWidget: (v, _) {
                        if (v == safeMax) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            Formatters.moneyCompact(v),
                            style: TextStyles.caption(context).copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 5,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= series.length) return const SizedBox.shrink();
                        final day = series[i].day;
                        // Show every 5 days: 1, 5, 10, 15, 20, 25, 30 + last day
                        if (day == 1 || day == 5 || day == 10 || day == 15 ||
                            day == 20 || day == 25 || day == 30 || day == series.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('$day',
                                style: TextStyles.caption(context).copyWith(fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    curveSmoothness: 0.35,
                    preventCurveOverShooting: true,
                    barWidth: 3,
                    color: AppColors.primaryIndigo,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == safeActiveIdx) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: AppColors.primaryIndigo,
                          );
                        }
                        // Only show dots on days with transactions.
                        if (series[index].value == 0) {
                          return FlDotCirclePainter(
                            radius: 0,
                            color: Colors.transparent,
                            strokeWidth: 0,
                            strokeColor: Colors.transparent,
                          );
                        }
                        return FlDotCirclePainter(
                          radius: 2.5,
                          color: AppColors.primaryIndigo,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryIndigo.withOpacity(0.24),
                          AppColors.primaryIndigo.withOpacity(0.0),
                        ],
                      ),
                    ),
                    spots: spots,
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppColors.primaryIndigo,
                    tooltipRoundedRadius: 6,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    getTooltipItems: (spots) {
                      return spots.map((s) {
                        final i = s.x.toInt();
                        final day = (i >= 0 && i < series.length) ? series[i].day : (i + 1);
                        // Build a proper date for the tooltip label.
                        // Was "Day 12: 1500" — now "12 Oct: Rs. 1,500" (full
                        // currency formatting, includes symbol).
                        final date = DateTime(anchor.year, anchor.month, day);
                        final dateLabel = Formatters.dateShort(date);
                        return LineTooltipItem(
                          '$dateLabel: ${Formatters.money(s.y)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseAnchorMonth(String key) {
    // key format: "year-month-day" (e.g., "2026-10-7")
    final parts = key.split('-');
    if (parts.length >= 2) {
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
    }
    return DateTime.now();
  }

  /// Round up to a "nice" maximum for the y-axis: 1k, 2k, 5k, 10k, etc.
  double _niceMax(double v) {
    if (v <= 0) return 1000;
    if (v <= 500) return 500;
    if (v <= 1000) return 1000;
    if (v <= 2000) return 2000;
    if (v <= 3000) return 3000;
    if (v <= 5000) return 5000;
    if (v <= 10000) return 10000;
    final pow10 = math.pow(10, (math.log(v) / math.log(10)).ceil());
    return (v / pow10).ceil() * pow10.toDouble();
  }
}

class _DayPoint {
  final int day;
  final double value;
  const _DayPoint({required this.day, required this.value});
}

// ----------------------------------------------------------------
// Spending Breakdown — donut with % labels on slices + right legend
// ----------------------------------------------------------------
class _BreakdownDonut extends StatefulWidget {
  final double total;
  final List<MapEntry<dynamic, double>> items;
  const _BreakdownDonut({required this.total, required this.items});

  @override
  State<_BreakdownDonut> createState() => _BreakdownDonutState();
}

class _BreakdownDonutState extends State<_BreakdownDonut> {
  bool _showData = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox(
        height: 240,
        child: EmptyState(
          icon: Icons.pie_chart_outline_rounded,
          title: 'No breakdown yet',
          subtitle: 'Add an expense to see your category split.',
        ),
      );
    }
    final safeTotal = widget.total == 0 ? 1.0 : widget.total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withOpacity(0.06),
            AppColorsOf.card(context),
            AppColorsOf.card(context),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(color: AppColorsOf.border(context)),
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Spending Breakdown', style: TextStyles.h3(context)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColorsOf.card(context),
                  border: Border.all(color: AppColorsOf.border(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('This Month',
                    style: TextStyles.caption(context, weight: FontWeight.w700)
                        .copyWith(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Chart + center text ──
          // Fixed: donut was CLIPPED (outer diameter 154px > SizedBox 140px).
          // Reduced centerSpaceRadius 44→36 and section radius 32→26.
          // New outer radius = 36 + 26 + 1 = 63 → diameter 126px ≤ 140px. ✓
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 36,
                        sections: [
                          for (int i = 0; i < widget.items.length; i++)
                            PieChartSectionData(
                              color: widget.items[i].key.color,
                              value: _showData
                                  ? widget.items[i].value
                                  : 0.001,
                              title: '',
                              radius: 26,
                              borderSide: BorderSide(
                                color: AppColorsOf.card(context),
                                width: 2,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Center text — FittedBox prevents overflow on long amounts
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total Spent', style: TextStyles.label(context)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedMoney(
                          amount: widget.total,
                          style: TextStyles.money(context, size: 16),
                          durationMs: 1000,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Legend: stacked BELOW the chart (was side-by-side, which
          // caused overflow when 8 categories × 20px = 240px > chart 140px).
          // Now uses a Wrap with proper spacing — items wrap to multiple
          // rows on narrow screens instead of overflowing.
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: widget.items.map((e) {
              final c = e.key;
              final pctVal = ((e.value / safeTotal) * 100).round();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Category name — use Flexible with maxLines: 1 + ellipsis
                  // so long names like "Entertainment" don't push amounts off
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(
                      c.name,
                      style: TextStyles.caption(context,
                          weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.moneyPlain(e.value),
                    style: TextStyles.caption(context,
                        weight: FontWeight.w700).copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 11),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$pctVal%',
                    style: TextStyles.caption(context).copyWith(
                        color: AppColorsOf.tertiaryText(context),
                        fontSize: 10,
                        fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// Insight card at bottom
// ----------------------------------------------------------------
class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _InsightCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      customColor: color.withOpacity(0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(label, style: TextStyles.label(context)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyles.body(context, weight: FontWeight.w700)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: 2),
          Text(sub, style: TextStyles.caption(context), maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------
// _PeriodBarChart — vertical bar chart used by the Daily + Weekly
// views of the Analytics screen. Each bar represents one day (Daily
// view) or one week (Weekly view). The active bar (highest value) is
// highlighted in indigo; others use a translucent indigo fill.
//
// Premium polish:
//   • Bars grow from 0 to their final height on first render (1100ms
//     easeOutCubic) — same easing as the donut + line chart.
//   • Y-axis labels use compact money formatting ("2k", "5k").
//   • Active bar (the highest) shows a tooltip with the exact amount.
//   • Card chrome matches the Spending Overview card: subtle indigo
//     gradient bg + border + optional light-mode shadow.
// ----------------------------------------------------------------
class _PeriodBarChart extends StatefulWidget {
  final List<MapEntry<String, double>> data;
  final double total;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isWeekly;

  const _PeriodBarChart({
    required this.data,
    required this.total,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isWeekly = false,
  });

  @override
  State<_PeriodBarChart> createState() => _PeriodBarChartState();
}

class _PeriodBarChartState extends State<_PeriodBarChart> {
  bool _showData = false;

  @override
  void initState() {
    super.initState();
    // Trigger bar grow-in animation after first frame.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // All-zero empty state.
    if (widget.data.every((e) => e.value == 0)) {
      return SizedBox(
        height: 240,
        child: EmptyState(
          icon: Icons.bar_chart_outlined,
          title: widget.isWeekly ? 'No weekly data yet' : 'No daily data yet',
          subtitle: 'Add an expense to see your trend.',
        ),
      );
    }

    final maxVal = widget.data.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final safeMax = _niceMax(maxVal);
    final activeIdx = widget.data.indexWhere((e) => e.value == maxVal);
    final safeActiveIdx = activeIdx < 0 ? 0 : activeIdx;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryIndigo.withOpacity(0.06),
            AppColorsOf.card(context),
            AppColorsOf.card(context),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border.all(color: AppColorsOf.border(context)),
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: TextStyles.h3(context)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon,
                    color: AppColors.primaryIndigo, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${Formatters.money(widget.total)} · ${widget.subtitle}',
            style: TextStyles.caption(context),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: BarChart(
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: safeMax,
                minY: 0,
                barGroups: [
                  for (int i = 0; i < widget.data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          // 0 on first render, real value after _showData flips.
                          toY: _showData ? widget.data[i].value : 0,
                          color: i == safeActiveIdx && maxVal > 0
                              ? AppColors.primaryIndigo
                              : AppColors.primaryIndigo.withOpacity(0.32),
                          width: widget.isWeekly ? 36 : 28,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          backDrawRodData: BackgroundBarChartRodData(
                            toY: safeMax,
                            color: AppColors.primaryIndigo.withOpacity(0.05),
                            show: true,
                          ),
                        ),
                      ],
                      showingTooltipIndicators:
                          i == safeActiveIdx && maxVal > 0 && _showData
                              ? [0]
                              : [],
                    ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  horizontalInterval: safeMax / 4,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: AppColorsOf.divider(context),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: safeMax / 4,
                      getTitlesWidget: (v, _) {
                        if (v == 0 || v == safeMax) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            Formatters.moneyCompact(v),
                            style: TextStyles.caption(context)
                                .copyWith(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: widget.isWeekly ? 36 : 24,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= widget.data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.data[i].key,
                            style: TextStyles.caption(context).copyWith(
                              fontSize: widget.isWeekly ? 9 : 10,
                              fontWeight: i == safeActiveIdx
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: i == safeActiveIdx
                                  ? AppColors.primaryIndigo
                                  : AppColorsOf.secondaryText(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.primaryIndigo,
                    tooltipRoundedRadius: 6,
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        Formatters.money(rod.toY),
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Round up to a "nice" maximum for the y-axis: 1k, 2k, 5k, etc.
  double _niceMax(double v) {
    if (v <= 0) return 1000;
    if (v <= 500) return 500;
    if (v <= 1000) return 1000;
    if (v <= 2000) return 2000;
    if (v <= 3000) return 3000;
    if (v <= 5000) return 5000;
    if (v <= 10000) return 10000;
    final pow10 = math.pow(10, (math.log(v) / math.log(10)).ceil());
    return (v / pow10).ceil() * pow10.toDouble();
  }
}
