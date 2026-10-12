import 'package:flutter/material.dart';
import 'app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// SpendSmart Typography — Plus Jakarta Sans (bundled locally)
// Fixes broken "i" glyph that rendered as "m lestone", "Billls", etc.
//
// Scale (minimum 12px — never go below):
//   display   48/40  bold      — hero amounts, splash title
//   title     22     semibold   — screen titles
//   section   16     semibold   — section headers
//   body      14     regular    — default text
//   caption   12     regular    — small text, labels
//
// Money styles always use FontFeature.tabularFigures() for aligned digits.
// ═══════════════════════════════════════════════════════════════════

class TextStyles {
  TextStyles._();

  static const _font = 'PlusJakartaSans';
  static const _tabular = [FontFeature.tabularFigures()];

  // ── DISPLAY (hero amounts, splash) ──
  static TextStyle display(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.1,
        letterSpacing: -1.0,
      );

  static TextStyle displayMedium(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.15,
        letterSpacing: -0.8,
      );

  // ── TITLE (screen titles, card titles) ──
  static TextStyle h1(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle h2(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle h3(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.3,
        letterSpacing: -0.2,
      );

  // ── SECTION (section headers) ──
  static TextStyle section(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.35,
      );

  // ── BODY (default text) ──
  static TextStyle body(BuildContext context,
          {Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: _font,
        fontSize: 14,
        fontWeight: weight,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.5,
      );

  // ── CAPTION (small text — minimum 12px) ──
  static TextStyle caption(BuildContext context,
          {Color? color, FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: _font,
        fontSize: 12,
        fontWeight: weight,
        color: color ?? AppColorsOf.secondaryText(context),
        height: 1.4,
      );

  // ── LABEL (field labels, badges — 12px semibold) ──
  static TextStyle label(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? AppColorsOf.tertiaryText(context),
        height: 1.4,
        letterSpacing: 0.3,
      );

  // ── MONEY (tabular figures for aligned digits) ──
  static TextStyle money(BuildContext context,
          {Color? color, double size = 22, FontWeight weight = FontWeight.w600}) =>
      TextStyle(
        fontFamily: _font,
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.2,
        letterSpacing: -0.3,
        fontFeatures: _tabular,
      );

  static TextStyle moneyHero(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.1,
        letterSpacing: -0.8,
        fontFeatures: _tabular,
      );

  static TextStyle moneyDisplay(BuildContext context, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: color ?? AppColorsOf.mainText(context),
        height: 1.05,
        letterSpacing: -1.0,
        fontFeatures: _tabular,
      );
}
