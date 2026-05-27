import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────
/// AppColors — Design Tokens (สี)
/// ──────────────────────────────────────────────────
/// อ้างอิงจาก Design System ใน docs/03_UI_UX_SPEC.md
///
/// หลักการ:
/// - ไม่ใช้สีแดงเป็น primary (วัฒนธรรมไทย: แดง = หนี้/ความเสี่ยง)
/// - เลือก Teal/Emerald สื่อ "เงินดี สบายตา"
/// - Light + Dark mode แยกชัดเจน
/// - ทุกคู่สีผ่าน WCAG 2.1 AA contrast (≥ 4.5:1)
/// ──────────────────────────────────────────────────
abstract final class AppColors {
  AppColors._(); // ป้องกันการ instantiate

  // ═══════════════════════════════════════
  // PRIMARY — Brand color
  // ═══════════════════════════════════════
  static const Color primary = Color(0xFF0F766E); // teal-700
  static const Color primaryLight = Color(0xFF14B8A6); // teal-500
  static const Color primaryDark = Color(0xFF134E4A); // teal-900
  static const Color primaryContainer = Color(0xFFCCFBF1); // teal-100

  // ═══════════════════════════════════════
  // SEMANTIC — ใช้สื่อความหมาย
  // ═══════════════════════════════════════
  /// สำหรับ "รายรับ" (เงินเข้า) — เขียว
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);

  /// สำหรับ "รายจ่าย" (เงินออก) — แดง (ใช้น้อย เฉพาะ icon/badge)
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerContainer = Color(0xFFFEE2E2);

  /// สำหรับ FAB + alerts — amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);

  /// สำหรับ info badge
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════
  // NEUTRAL — Light Mode
  // ═══════════════════════════════════════
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF9FAFB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF3F4F6);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightDisabled = Color(0xFFD1D5DB);

  // ═══════════════════════════════════════
  // NEUTRAL — Dark Mode (OLED-friendly)
  // ═══════════════════════════════════════
  // ใช้ #0A0A0A แทน #000 เพื่อลด OLED burn-in
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF171717);
  static const Color darkCard = Color(0xFF1F1F1F);
  static const Color darkBorder = Color(0xFF2F2F2F);
  static const Color darkDivider = Color(0xFF262626);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFA3A3A3);
  static const Color darkTextTertiary = Color(0xFF6B6B6B);
  static const Color darkDisabled = Color(0xFF404040);

  // ═══════════════════════════════════════
  // CATEGORY COLORS — สำหรับ category badges
  // ═══════════════════════════════════════
  /// 12 สีพื้นฐาน user เลือกได้ตอนสร้างหมวด/บัญชี
  static const List<Color> categoryPalette = <Color>[
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFF59E0B), // amber
    Color(0xFFEAB308), // yellow
    Color(0xFF84CC16), // lime
    Color(0xFF22C55E), // green
    Color(0xFF10B981), // emerald
    Color(0xFF14B8A6), // teal
    Color(0xFF06B6D4), // cyan
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
  ];
}
