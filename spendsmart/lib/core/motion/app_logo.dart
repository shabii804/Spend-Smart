import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// SpendSmart app logo drawn with CustomPainter — scales crisply at any size.
/// Variants: markOnly, markWithWordmarkHorizontal, markWithWordmarkStacked, monochrome.
///
/// Design: squircle (28% radius) with primary gradient,
/// white wallet glyph inside, cyan coin-dot clasp,
/// small growth spark on the flap.
class AppLogo extends StatelessWidget {
  final double size;
  final AppLogoVariant variant;
  final bool showGlow;

  const AppLogo({
    super.key,
    this.size = 72,
    this.variant = AppLogoVariant.markOnly,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppLogoVariant.markOnly:
        return _buildMark();
      case AppLogoVariant.monochrome:
        return _buildMark(monochrome: true);
      case AppLogoVariant.markWithWordmarkHorizontal:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMark(),
            const SizedBox(width: 10),
            _buildWordmark(),
          ],
        );
      case AppLogoVariant.markWithWordmarkStacked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMark(),
            const SizedBox(height: 8),
            _buildWordmark(),
            const SizedBox(height: 2),
            _buildTagline(),
          ],
        );
    }
  }

  Widget _buildMark({bool monochrome = false}) {
    return RepaintBoundary(
      child: Container(
        width: size,
        height: size,
        decoration: showGlow && !monochrome
            ? BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryIndigo.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              )
            : null,
        child: CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(monochrome: monochrome),
        ),
      ),
    );
  }

  Widget _buildWordmark() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.5,
        ),
        children: [
          const TextSpan(text: 'Spend', style: TextStyle(color: Colors.white)),
          TextSpan(
            text: 'Smart',
            style: TextStyle(
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
                ).createShader(Rect.fromLTWH(0, 0, size * 1.5, size * 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Track. Plan. Achieve.',
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: size * 0.16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF7C86A0),
        letterSpacing: 0.5,
      ),
    );
  }
}

enum AppLogoVariant {
  markOnly,
  markWithWordmarkHorizontal,
  markWithWordmarkStacked,
  monochrome,
}

class _LogoPainter extends CustomPainter {
  final bool monochrome;
  _LogoPainter({this.monochrome = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Squircle background ──
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.28),
    );

    final bgPaint = Paint()
      ..shader = monochrome
          ? null
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
            ).createShader(Rect.fromLTWH(0, 0, w, h));

    if (monochrome) {
      bgPaint.color = Colors.white;
    }

    canvas.drawRRect(rrect, bgPaint);

    // ── Inner highlight (white @ 12%, top-left) ──
    if (!monochrome) {
      final highlightPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 0.6,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawRRect(rrect, highlightPaint);
    }

    // ── Wallet glyph (white, centered) ──
    final walletPaint = Paint()
      ..color = monochrome ? AppColors.primaryIndigo : Colors.white
      ..style = PaintingStyle.fill;

    final walletW = w * 0.44;
    final walletH = h * 0.34;
    final walletX = (w - walletW) / 2;
    final walletY = (h - walletH) / 2;
    final walletR = walletH * 0.22;

    // Wallet body (rounded rect)
    final walletRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(walletX, walletY, walletW, walletH),
      Radius.circular(walletR),
    );
    canvas.drawRRect(walletRect, walletPaint);

    // Wallet flap (top portion, slightly offset)
    final flapH = walletH * 0.30;
    final flapRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(walletX, walletY, walletW, flapH),
      Radius.circular(walletR),
    );

    final flapPaint = Paint()
      ..color = (monochrome ? AppColors.primaryIndigo : Colors.white).withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(flapRect, flapPaint);

    // ── Cyan coin-dot clasp (right side of wallet) ──
    final dotRadius = w * 0.055;
    final dotX = walletX + walletW - dotRadius * 1.8;
    final dotY = walletY + walletH / 2;

    final dotPaint = Paint()
      ..color = monochrome ? AppColors.primaryIndigo : AppColors.cyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);

    // ── Growth spark (small upward arrow on the flap) ──
    final sparkPath = Path()
      ..moveTo(walletX + walletW * 0.25, walletY + flapH * 0.65)
      ..lineTo(walletX + walletW * 0.35, walletY + flapH * 0.30)
      ..lineTo(walletX + walletW * 0.45, walletY + flapH * 0.65);

    final sparkPaint = Paint()
      ..color = monochrome ? AppColors.primaryIndigo : AppColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(sparkPath, sparkPaint);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.monochrome != monochrome;
}
