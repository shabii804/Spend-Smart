import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../data/sample_data.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import 'edit_expense_screen.dart';
import 'expense_details_screen.dart';

class TransactionsScreen extends StatefulWidget {
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
    final date =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
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

  void _deleteExpense(Expense expense) {
    final prov = context.read<ExpenseProvider>();
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
          prov.addExpense(deleted);
          Haptics.selection();
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
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (canPop) {
              Navigator.of(context).maybePop();
            }
          },
        ),
        // Trailing: compact item count badge
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${filtered.length}',
                  style: TextStyles.caption(context, weight: FontWeight.w700)
                      .copyWith(color: AppColors.primaryIndigo),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ═══ COMPACT SUMMARY STRIP ═══
            // Merged item count + month total + day count into ONE row.
            // Was previously 2 separate rows (~80px). Now ~40px — saves 40px.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryIndigo.withOpacity(0.10)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down_rounded,
                        size: 14, color: AppColors.danger),
                    const SizedBox(width: 6),
                    Text(
                        '${Formatters.money(monthTotal)} this month',
                        style: TextStyles.caption(context,
                            weight: FontWeight.w700)),
                    const Spacer(),
                    Text(
                      '${grouped.length} ${grouped.length == 1 ? 'day' : 'days'}',
                      style: TextStyles.caption(context).copyWith(
                          color: AppColorsOf.tertiaryText(context), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ═══ SEARCH BAR (compact) ═══
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  style: TextStyles.body(context).copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search transactions',
                    hintStyle: TextStyle(fontSize: 13),
                    prefixIcon:
                        const Icon(Icons.search_rounded, size: 18),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 36),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ═══ FILTER CHIPS (compact, 36px height) ═══
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final sel = _filter == f;
                  return GestureDetector(
                    onTap: () {
                      Haptics.selection();
                      setState(() => _filter = f);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primaryIndigo
                            : AppColorsOf.card(context),
                        border: Border.all(
                          color: sel
                              ? AppColors.primaryIndigo
                              : AppColorsOf.border(context),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
            const SizedBox(height: 6),
            // ═══ TRANSACTION LIST ═══
            // Each tile is now TAP-TO-EXPAND — tap to reveal Delete + Edit
            // buttons inline. Much more discoverable than swipe.
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
                        Haptics.selection();
                        await Future.delayed(
                            const Duration(milliseconds: 600));
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
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              // Date header + daily total
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(label,
                                        style: TextStyles.caption(context,
                                                weight: FontWeight.w700)
                                            .copyWith(
                                                color: AppColorsOf
                                                    .secondaryText(context))),
                                    Text(
                                        '-${Formatters.money(total)}',
                                        style: TextStyles.caption(context,
                                                weight: FontWeight.w700)
                                            .copyWith(
                                              color: AppColors.danger,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures()
                                              ],
                                            )),
                                  ],
                                ),
                              ),
                              // Day group card with tap-to-expand tiles
                              GlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  children: [
                                    for (int i = 0;
                                        i < group.value.length;
                                        i++) ...[
                                      StaggeredEntrance(
                                        index: i,
                                        child: _ExpandableTransactionTile(
                                          expense: group.value[i],
                                          category: SampleData.categoryById(
                                              group.value[i].categoryId),
                                          onDelete: _deleteExpense,
                                        ),
                                      ),
                                      if (i !=
                                          group.value.length - 1)
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// _ExpandableTransactionTile — TAP TO REVEAL Delete + Edit buttons.
//
// Default state: shows icon + title + date + amount (same as before).
// Expanded state (after tap): shows a divider + Edit + Delete buttons
// below the tile content. Tap again to collapse.
//
// This replaces the SwipeToRevealActions pattern which was not
// discoverable — the user didn't know they could swipe. Tapping is
// the natural interaction.
// ═══════════════════════════════════════════════════════════════════
class _ExpandableTransactionTile extends StatefulWidget {
  final Expense expense;
  final Category category;
  final void Function(Expense expense) onDelete;

  const _ExpandableTransactionTile({
    required this.expense,
    required this.category,
    required this.onDelete,
  });

  @override
  State<_ExpandableTransactionTile> createState() =>
      _ExpandableTransactionTileState();
}

class _ExpandableTransactionTileState
    extends State<_ExpandableTransactionTile> {
  bool _isExpanded = false;

  void _toggle() {
    Haptics.selection();
    setState(() => _isExpanded = !_isExpanded);
  }

  Future<void> _confirmDelete() async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete expense?',
      body:
          'Delete "${widget.expense.title}" (${Formatters.money(widget.expense.amount)})? '
          'This can be undone via the snackbar.',
      confirmLabel: 'Delete',
      danger: true,
      icon: Icons.delete_outline_rounded,
    );
    if (ok == true) {
      widget.onDelete(widget.expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _toggle,
        child: Column(
          children: [
            // ─── Tile content (always visible) ───
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Category icon
                  Hero(
                    tag: 'expense-icon-${widget.expense.id}',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            widget.category.color.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(widget.category.icon,
                          color: widget.category.color, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.expense.title,
                          style: TextStyles.body(context,
                              weight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.relativeDateTime(
                              widget.expense.date),
                          style: TextStyles.caption(context)
                              .copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Amount (red with - prefix)
                  Text(
                    '-${Formatters.money(widget.expense.amount)}',
                    style: TextStyles.body(context, weight: FontWeight.w700)
                        .copyWith(
                      color: AppColors.danger,
                      fontFeatures: const [
                        FontFeature.tabularFigures()
                      ],
                    ),
                  ),
                  // Expand/collapse chevron
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColorsOf.tertiaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            // ─── Expanded action buttons (animated) ───
            AnimatedCrossCross(
              show: _isExpanded,
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Action buttons row (Edit + Delete) ───
  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: Column(
        children: [
          Divider(
            height: 1,
            color: AppColorsOf.divider(context),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // ── Edit button ──
              Expanded(
                child: _inlineActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  color: AppColors.primaryIndigo,
                  onTap: () {
                    Haptics.selection();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            EditExpenseScreen(expenseId: widget.expense.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // ── Delete button ──
              Expanded(
                child: _inlineActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: AppColors.danger,
                  onTap: _confirmDelete,
                ),
              ),
              const SizedBox(width: 8),
              // ── View Details button ──
              Expanded(
                child: _inlineActionButton(
                  icon: Icons.visibility_outlined,
                  label: 'Details',
                  color: AppColors.blue,
                  onTap: () {
                    Haptics.selection();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ExpenseDetailsScreen(
                            expenseId: widget.expense.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inlineActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.20), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// AnimatedCrossCross — smoothly shows/hides a child widget with a
// crossfade + height animation. Used by _ExpandableTransactionTile.
// ═══════════════════════════════════════════════════════════════════
class AnimatedCrossCross extends StatelessWidget {
  final bool show;
  final Widget child;

  const AnimatedCrossCross({
    super.key,
    required this.show,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: show
          ? child
          : const SizedBox.shrink(),
    );
  }
}
