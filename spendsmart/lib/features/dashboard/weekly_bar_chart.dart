import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_money.dart';

/// Vertical bar chart for weekly spending on the home dashboard.
/// Bars grow from 0 to their final height on first render (animated entrance).
class WeeklyBarChart extends StatefulWidget {
  final List<MapEntry<String, double>> data; // [(day, total), ...]

  const WeeklyBarChart({super.key, required this.data});

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  bool _showData = false;

  @override
  void initState() {
    super.initState();
    // Slight delay so fl_chart's swap animation triggers and bars grow up.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final maxVal = data.fold<double>(0, (m, e) => e.value > m ? e.value : m);
    final safeMax = _niceMax(maxVal);
    final activeIdx = data.indexWhere((e) => e.value == maxVal);
    final safeActiveIdx = activeIdx < 0 ? 0 : activeIdx;
    final total = data.fold<double>(0, (s, e) => s + e.value);

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
              Text('Weekly Spending', style: TextStyles.h3(context)),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryIndigo,
                  minimumSize: const Size(0, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.viewAll,
                  style: TextStyles.caption(context, weight: FontWeight.w700)
                      .copyWith(color: AppColors.primaryIndigo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Animated total — count-up tween
          AnimatedMoney(
            amount: total,
            style: TextStyles.caption(context, weight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              // Longer swap animation = visible bar-grow entrance
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: safeMax,
                minY: 0,
                barGroups: [
                  for (int i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          // 0 on first render, real value after _showData flips
                          toY: _showData ? data[i].value : 0,
                          color: i == safeActiveIdx && maxVal > 0
                              ? AppColors.primaryIndigo
                              : AppColors.primaryIndigo.withOpacity(0.32),
                          width: 22,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          backDrawRodData: BackgroundBarChartRodData(
                            toY: safeMax,
                            color: AppColors.primaryIndigo.withOpacity(0.05),
                            show: true,
                          ),
                        ),
                      ],
                      showingTooltipIndicators: i == safeActiveIdx && maxVal > 0 && _showData
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
                        if (v == 0 || v == safeMax) return const SizedBox.shrink();
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
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].key,
                            style: TextStyles.caption(context).copyWith(
                              fontWeight: i == safeActiveIdx ? FontWeight.w700 : FontWeight.w400,
                              color: i == safeActiveIdx
                                  ? AppColors.primaryIndigo
                                  : AppColorsOf.secondaryText(context),
                              fontSize: 10,
                            ),
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
                        Formatters.moneyPlain(rod.toY),
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
    return ((v / 5000).ceil()) * 5000.0;
  }
}
