import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography scale per spec:
/// H1: 26/600 | H2: 22/600 | H3: 18/600 | Body: 14/400 | Caption: 12/400
/// Money amounts: 20–28px, w600, tabular figures.
/// All text uses Plus Jakarta Sans.
///
/// When no color is supplied, the text style falls back to a sensible default;
/// the caller typically wraps it with .copyWith(color: AppColorsOf.mainText(context)).
class TextStyles {
  TextStyles._();

  static TextStyle h1(BuildContext context, {Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.2,
        letterSpacing: -0.4,
      );

  static TextStyle h2(BuildContext context, {Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle h3(BuildContext context, {Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle body(BuildContext context,
          {Color? color, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: weight,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.5,
      );

  static TextStyle caption(BuildContext context,
          {Color? color, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: weight,
        color: color ?? AppColorsOf.secondaryText(context),
        height: 1.4,
      );

  /// Money label inside small cards (total spent, remaining, etc.)
  static TextStyle money(BuildContext context,
          {Color? color, double size = 22, FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.2,
        letterSpacing: -0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Hero amount for dashboard hero card.
  static TextStyle moneyHero(BuildContext context, {Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.1,
        letterSpacing: -0.6,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextStyle label(BuildContext context, {Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.tertiaryText(context),
        height: 1.4,
        letterSpacing: 0.4,
      );
}
