import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../data/sample_data.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import 'expense_details_screen.dart';

class TransactionsScreen extends StatefulWidget {
  /// Optional initial category filter (e.g. 'food', 'transport').
  /// Set when navigating from "Top Categories" on the home screen so the
  /// user lands directly on the filtered list instead of "All".
  final String? initialFilter;

  const TransactionsScreen({super.key, this.initialFilter});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  late String _filter;

  static const _filters = [
    AppStrings.all,
    AppStrings.food,
    AppStrings.transport,
    AppStrings.groceries,
    AppStrings.bills,
    'Entertainment',
    'Internet',
    'Shopping',
    AppStrings.others,
  ];

  // Reverse map: categoryId → display label (for resolving initialFilter).
  static const _catIdToLabel = {
    'food': AppStrings.food,
    'transport': AppStrings.transport,
    'groceries': AppStrings.groceries,
    'bills': AppStrings.bills,
    'entertainment': 'Entertainment',
    'internet': 'Internet',
    'shopping': 'Shopping',
    'others': AppStrings.others,
  };

  static const _filterCatIds = {
    AppStrings.all: null,
    AppStrings.food: 'food',
    AppStrings.transport: 'transport',
    AppStrings.bills: 'bills',
    AppStrings.groceries: 'groceries',
    'Entertainment': 'entertainment',
    'Internet': 'internet',
    'Shopping': 'shopping',
    AppStrings.others: 'others',
  };

  @override
  void initState() {
    super.initState();
    // Resolve initialFilter (a category id) to its display label.
    // If the id isn't recognised, fall back to 'All'.
    _filter = (widget.initialFilter != null &&
            _catIdToLabel.containsKey(widget.initialFilter))
        ? _catIdToLabel[widget.initialFilter!]!
        : AppStrings.all;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Expense> _applyFilters(List<Expense> all) {
    var out = List<Expense>.of(all);
    final catId = _filterCatIds[_filter];
    if (catId != null) {
      out = out.where((e) => e.categoryId == catId).toList();
    }
    if (_search.trim().isNotEmpty) {
      final q = _search.trim().toLowerCase();
      out = out
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              (e.note?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  /// Group expenses by date for sticky headers.
  List<MapEntry<String, List<Expense>>> _groupByDate(List<Expense> expenses) {
    final groups = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = '${e.date.year}-${e.date.month}-${e.date.day}';
      groups.putIfAbsent(key, () => []).add(e);
    }
    return groups.entries.toList()
      ..sort((a, b) {
        final pa = a.key.split('-');
        final pb = b.key.split('-');
        final da = DateTime(int.parse(pa[0]), int.parse(pa[1]), int.parse(pa[2]));
        final db = DateTime(int.parse(pb[0]), int.parse(pb[1]), int.parse(pb[2]));
        return db.compareTo(da);
      });
  }

  String _dateLabel(String key) {
    final parts = key.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return Formatters.dateShort(date);
  }

  double _dayTotal(List<Expense> expenses) =>
      expenses.fold(0.0, (s, e) => s + e.amount);

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final all = expenses.expenses;
    final filtered = _applyFilters(all);
    final grouped = _groupByDate(filtered);
    final monthTotal = expenses.totalSpent;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transactions', style: TextStyles.h1(context)),
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'}',
                  style: TextStyles.caption(context, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Month summary strip
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryIndigo.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_down_rounded,
                      size: 16, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Text('This month: ${Formatters.money(monthTotal)} spent',
                      style: TextStyles.caption(context, weight: FontWeight.w700)),
                  const Spacer(),
                  Text('${grouped.length} ${grouped.length == 1 ? 'day' : 'days'}',
                      style: TextStyles.caption(context)
                          .copyWith(color: AppColorsOf.tertiaryText(context))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: TextStyles.body(context),
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final sel = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryIndigo
                          : AppColorsOf.card(context),
                      border: Border.all(
                        color: sel ? AppColors.primaryIndigo : AppColorsOf.border(context),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      f,
                      style: TextStyles.caption(context, weight: FontWeight.w600)
                          .copyWith(
                            color: sel ? Colors.white : AppColorsOf.secondaryText(context),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Grouped transaction list
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No transactions found',
                    subtitle: 'Try a different search or filter.',
                  )
                : RefreshIndicator(
                    color: AppColors.primaryIndigo,
                    backgroundColor: AppColorsOf.card(context),
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 600));
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                      itemCount: grouped.length,
                      itemBuilder: (_, gi) {
                        final group = grouped[gi];
                        final label = _dateLabel(group.key);
                        final total = _dayTotal(group.value);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Date header + daily total
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(label,
                                      style: TextStyles.caption(context, weight: FontWeight.w700)
                                          .copyWith(color: AppColorsOf.secondaryText(context))),
                                  Text('-${Formatters.money(total)}',
                                      style: TextStyles.caption(context, weight: FontWeight.w700)
                                          .copyWith(
                                            color: AppColors.danger,
                                            fontFeatures: const [FontFeature.tabularFigures()])),
                                ],
                              ),
                            ),
                            // Single card per day group with dividers
                            GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                children: [
                                  for (int i = 0; i < group.value.length; i++) ...[
                                    StaggeredEntrance(
                                      index: i,
                                      child: _GroupedTransactionTile(
                                        expense: group.value[i],
                                        category: SampleData.categoryById(group.value[i].categoryId),
                                      ),
                                    ),
                                    if (i != group.value.length - 1)
                                      Divider(
                                        height: 1,
                                        indent: 12,
                                        endIndent: 12,
                                        color: AppColorsOf.divider(context),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupedTransactionTile extends StatelessWidget {
  final Expense expense;
  final Category category;

  const _GroupedTransactionTile(
      {required this.expense, required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExpenseDetailsScreen(expenseId: expense.id),
          ),
        ),
        child: GlassCard(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: 'expense-icon-${expense.id}',
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(category.icon, color: category.color, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: TextStyles.body(context, weight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.name} · ${Formatters.dateTime(expense.date)}',
                      style: TextStyles.caption(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Formatters.money(expense.amount),
                style: TextStyles.body(context, weight: FontWeight.w700)
                    .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
