import 'package:flutter/material.dart';
import '../../core/motion/haptics.dart';
import '../theme/app_colors.dart';

/// Swipe-to-reveal-actions wrapper — a safer alternative to [Dismissible].
///
/// Swipe LEFT to reveal action buttons (e.g. Delete + Edit) behind the tile.
/// The tile slides away but **stays in place** — no auto-delete. The user
/// must tap an action button to confirm.
///
/// This fixes the "scroll triggers auto-delete" bug: vertical scroll
/// gestures are ignored because we only listen to horizontal drag, and
/// even a full horizontal swipe doesn't delete — it just reveals the
/// actions. The user explicitly taps Delete to confirm.
///
/// Tapping the tile itself (or tapping it after revealing actions) hides
/// the actions and restores the tile to its resting position.
///
/// Usage:
///   SwipeToRevealActions(
///     key: ValueKey('item-${item.id}'),
///     actions: [
///       SwipeAction(
///         label: 'Edit',
///         icon: Icons.edit_rounded,
///         color: AppColors.primaryIndigo,
///         onTap: () => ...,
///       ),
///       SwipeAction(
///         label: 'Delete',
///         icon: Icons.delete_outline_rounded,
///         color: AppColors.danger,
///         onTap: () => ...,
///       ),
///     ],
///     child: MyTile(),
///   )
class SwipeToRevealActions extends StatefulWidget {
  final List<SwipeAction> actions;
  final Widget child;
  final Key? swipeKey;

  const SwipeToRevealActions({
    super.key,
    required this.actions,
    required this.child,
    this.swipeKey,
  });

  @override
  State<SwipeToRevealActions> createState() => _SwipeToRevealActionsState();
}

class _SwipeToRevealActionsState extends State<SwipeToRevealActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  // 0.0 = tile at rest (actions hidden). 1.0 = fully revealed (actions visible).
  double _dragExtent = 0.0;
  bool _isOpen = false;

  // How far the tile must be dragged before the actions "snap" open.
  static const double _openThreshold = 0.35;
  // Maximum drag fraction (1.0 = actions fully revealed).
  static const double _maxDrag = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 0.0,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Only respond to LEFTWARD drags (negative deltaX).
    // Rightward drags are ignored — prevents conflicts with vertical scroll.
    if (details.delta.dx > 0 && !_isOpen) return;
    final width = context.size?.width ?? 1.0;
    // Action area width = number of actions × ~80px each
    final actionWidth = (widget.actions.length * 80.0).clamp(80.0, 240.0);
    final fractionDelta = -details.delta.dx / actionWidth;
    _dragExtent = (_dragExtent + fractionDelta).clamp(0.0, _maxDrag);
    _controller.value = _dragExtent;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // Snap open if dragged past threshold, otherwise snap closed.
    final shouldOpen = _dragExtent > _openThreshold;
    _dragExtent = shouldOpen ? 1.0 : 0.0;
    _isOpen = shouldOpen;
    if (shouldOpen) {
      _controller.forward();
      Haptics.light();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    _dragExtent = 0.0;
    _isOpen = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Action area width — each action is ~80px wide
    final actionWidth = (widget.actions.length * 80.0).clamp(80.0, 240.0);
    // Translate the tile leftward as the controller animates 0 → 1
    final translate = -_controller.value * actionWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onTap: () {
        if (_isOpen) {
          // If actions are revealed, tapping the tile closes them.
          _close();
        }
        // Otherwise the tap goes through to the child (via the Stack's
        // transparent layer on top — but we use a simple approach:
        // if closed, the child receives the tap because the GestureDetector
        // only intercepts horizontal drags).
      },
      child: ClipRRect(
        child: Stack(
          children: [
            // ── Background: action buttons (revealed as tile slides left) ──
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actions.reversed.map((a) {
                  return GestureDetector(
                    onTap: () {
                      Haptics.selection();
                      _close();
                      a.onTap();
                    },
                    child: Container(
                      width: 80,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            a.color.withOpacity(0.85),
                            a.color,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(a.icon, color: Colors.white, size: 20),
                          const SizedBox(height: 2),
                          Text(
                            a.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList().cast<Widget>(),
              ),
            ),
            // ── Foreground: the actual tile, translated left ──
            Transform.translate(
              offset: Offset(translate, 0),
              child: Material(
                color: Colors.transparent,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single swipe-revealed action button (e.g. Delete, Edit).
class SwipeAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SwipeAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
