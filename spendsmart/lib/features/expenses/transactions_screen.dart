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
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _filter = AppStrings.all;

  static const _filters = [
    AppStrings.all,
    AppStrings.food,
    AppStrings.transport,
    AppStrings.bills,
    AppStrings.groceries,
    AppStrings.others,
  ];

  static const _filterCatIds = {
    AppStrings.all: null,
    AppStrings.food: 'food',
    AppStrings.transport: 'transport',
    AppStrings.bills: 'bills',
    AppStrings.groceries: 'groceries',
    AppStrings.others: 'others',
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Expense> _applyFilters(List<Expense> all) {
    // Always start from a fresh growable list — the source list from
    // ExpenseProvider.expenses is unmodifiable and would throw on .sort().
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

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final all = expenses.expenses;
    final filtered = _applyFilters(all);

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
                Text(AppStrings.transactions, style: TextStyles.h1(context)),
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'}',
                  style: TextStyles.caption(context,
                      weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: TextStyles.body(context),
              decoration: InputDecoration(
                hintText: AppStrings.searchTransactions,
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
          const SizedBox(height: 12),
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
                        color: sel
                            ? AppColors.primaryIndigo
                            : AppColorsOf.border(context),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      f,
                      style: TextStyles.caption(context, weight: FontWeight.w600)
                          .copyWith(
                        color: sel
                            ? Colors.white
                            : AppColorsOf.secondaryText(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.search_off_rounded,
                    title: AppStrings.noTransactions,
                    subtitle: AppStrings.noTransactionsSubtitle,
                  )
                : RefreshIndicator(
                    color: AppColors.primaryIndigo,
                    backgroundColor: AppColorsOf.card(context),
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 600));
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final e = filtered[i];
                        final cat = SampleData.categoryById(e.categoryId);
                        return StaggeredEntrance(
                          index: i,
                          child: _GroupedTransactionTile(
                            expense: e,
                            category: cat,
                          ),
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(category.icon, color: category.color, size: 22),
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
