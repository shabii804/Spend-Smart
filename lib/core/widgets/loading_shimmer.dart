import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Lightweight shimmer placeholder for dashboard first frame.
class LoadingShimmer extends StatefulWidget {
  final Widget child;
  const LoadingShimmer({super.key, required this.child});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkElevated : AppColors.lightDivider;
    final highlight = isDark
        ? AppColors.darkCard
        : Colors.white;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                base,
                highlight,
                base,
              ],
              stops: [
                0.0,
                _c.value,
                1.0,
              ],
            ).createShader(rect);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton block used by dashboard loading state.
class SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    this.height = 12,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
