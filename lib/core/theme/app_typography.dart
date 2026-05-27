import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────
/// AppTypography — Type Scale
/// ──────────────────────────────────────────────────
/// ใช้ฟอนต์ Sarabun เป็นหลัก รองรับไทย+อังกฤษ
/// อ่านง่ายใน mobile (x-height สูง)
///
/// Font weight mapping:
///   Regular   = 400
///   Medium    = 500
///   SemiBold  = 600
///   Bold      = 700
///
/// อ้างอิง: docs/03_UI_UX_SPEC.md §3.2
/// ──────────────────────────────────────────────────
abstract final class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Sarabun';

  // ═══════════════════════════════════════
  // Display — ใช้กับจำนวนเงิน Hero
  // ═══════════════════════════════════════
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25, // 40 / 32
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  // ═══════════════════════════════════════
  // Headings
  // ═══════════════════════════════════════
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  // ═══════════════════════════════════════
  // Body
  // ═══════════════════════════════════════
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  // ═══════════════════════════════════════
  // Caption / Small
  // ═══════════════════════════════════════
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
  );

  // ═══════════════════════════════════════
  // Number — tabular numbers สำหรับเลขเรียงสวยใน list
  // ═══════════════════════════════════════
  static const TextStyle numberLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle number = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle numberSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  // ═══════════════════════════════════════
  // Button
  // ═══════════════════════════════════════
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
  );
}
