import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/haptics.dart';
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

  /// Delete an expense with haptic feedback + an UNDO snackbar.
  /// The snackbar restores the expense if the user taps UNDO within 6s.
  /// This is the action invoked by the Dismissible swipe-left gesture.
  void _deleteExpense(Expense expense, int indexInGroup, String groupKey) {
    final prov = context.read<ExpenseProvider>();
    // Cache the expense so we can restore it on undo.
    final deleted = expense;
    Haptics.heavy();
    prov.deleteExpense(expense.id);

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(
      content: Text('Deleted ${Formatters.money(expense.amount)} expense'),
      duration: const Duration(seconds: 6),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'UNDO',
        textColor: AppColors.primaryIndigo,
        onPressed: () {
          // Re-insert the expense at the same position (top of the list,
          // since ExpenseProvider.addExpense inserts at index 0).
          prov.addExpense(deleted);
          Haptics.selection();
          if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Expense restored'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    ));
  }

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
          // Grouped transaction list — each tile is now swipe-to-delete.
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
                            // Single card per day group with dividers.
                            // The card's vertical padding is now 0 (was 4) so
                            // the Dismissible tiles fill it edge-to-edge and
                            // the dividers sit flush against the tiles.
                            GlassCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  for (int i = 0; i < group.value.length; i++) ...[
                                    StaggeredEntrance(
                                      index: i,
                                      child: _DismissibleTransactionTile(
                                        expense: group.value[i],
                                        category:
                                            SampleData.categoryById(group.value[i].categoryId),
                                        indexInGroup: i,
                                        groupKey: group.key,
                                        onDelete: _deleteExpense,
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

  // ─────────────────────────────────────────────────────────────────
  // _DismissibleTransactionTile — wraps the original _GroupedTransactionTile
  // in a Dismissible widget so the user can swipe left to delete.
  // ─────────────────────────────────────────────────────────────────
  // Background: red gradient + trash icon (left-aligned, revealed as the
  // tile slides away to the right). Snack with UNDO restores the expense.
  //
  // The tile itself was also tightened:
  //   • Date now uses Formatters.relativeDateTime() ('Today 8:45 AM' instead
  //     of 'Food · 10 Oct, 12:45 PM') — compact, doesn't overflow.
  //   • Amount now red with '-' prefix, matching the home recent-tile + the
  //     day-group total above (was default text color, inconsistent).
  //   • Inner GlassCard margin bottom 10 → 0 so dividers sit flush.
}

/// Wraps a single transaction tile in a [Dismissible] so the user can
/// swipe LEFT to delete. Swipe-right is disabled (only delete is the
/// action — swipe-right for archive would clutter the gesture space).
///
/// The red background reveals a trash icon + "Delete" label as the tile
/// slides away. On dismiss, the parent's `onDelete` callback fires which
/// calls ExpenseProvider.deleteExpense + shows an UNDO snackbar.
class _DismissibleTransactionTile extends StatelessWidget {
  final Expense expense;
  final Category category;
  final int indexInGroup;
  final String groupKey;
  final void Function(Expense expense, int indexInGroup, String groupKey) onDelete;

  const _DismissibleTransactionTile({
    required this.expense,
    required this.category,
    required this.indexInGroup,
    required this.groupKey,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Unique key per expense so Dismissible tracks each tile independently.
      key: ValueKey('expense-${expense.id}'),
      // Only allow left-swipe (DismissDirection.endToStart) — swiping right
      // is reserved for future "archive" or "mark as recurring" gestures.
      direction: DismissDirection.endToStart,
      // Red gradient background + trash icon, revealed as the tile slides
      // away to the left.
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.danger.withOpacity(0.85),
              AppColors.danger,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(height: 2),
            Text('Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
      // Threshold: must swipe at least 30% of the tile width before the
      // delete commits — prevents accidental deletes from short swipes.
      dismissThresholds: const {
        DismissDirection.endToStart: 0.3,
      },
      confirmDismiss: (direction) async {
        // Show a confirmation dialog before deleting. This protects against
        // accidental swipes — though the UNDO snackbar also provides recovery.
        // For a transactions list, a confirmation might be too friction-y,
        // so we just return true (delete immediately) and rely on UNDO.
        // (The dialog is here as a hook — change return to `await showDialog`
        // to enable it.)
        return true;
      },
      onDismissed: (direction) {
        // Fire the parent callback which deletes + shows UNDO snackbar.
        onDelete(expense, indexInGroup, groupKey);
      },
      child: _GroupedTransactionTile(
        expense: expense,
        category: category,
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
        child: Padding(
          // Removed the GlassCard wrapper (now the parent GlassCard provides
          // the card chrome; this tile just has padding + the row content).
          // Bottom margin 10 → 0 so dividers sit flush between tiles.
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    // Use relative date formatting ('Today 8:45 AM',
                    // 'Yesterday 9:13 AM', 'Mon 10:00 AM') instead of the
                    // previous 'Food · 10 Oct, 12:45 PM' which overflowed
                    // on narrow screens. The colored icon already conveys
                    // the category, so the name prefix was redundant.
                    Text(
                      Formatters.relativeDateTime(expense.date),
                      style: TextStyles.caption(context).copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Amount now RED with '-' prefix — matches the home recent-tile
              // and the day-group total above (was default color, inconsistent).
              Text(
                '-${Formatters.money(expense.amount)}',
                style: TextStyles.body(context, weight: FontWeight.w700)
                    .copyWith(
                      color: AppColors.danger,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
