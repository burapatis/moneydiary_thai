/// ──────────────────────────────────────────────────
/// AppSpacing — Design Tokens (spacing)
/// ──────────────────────────────────────────────────
/// 8-point grid system สำหรับ padding, margin, gap
/// อ้างอิง: docs/03_UI_UX_SPEC.md §3.3
/// ──────────────────────────────────────────────────
abstract final class AppSpacing {
  AppSpacing._();

  /// 4pt — extra small (gap ภายใน chip, icon padding)
  static const double xs = 4.0;

  /// 8pt — small (between items in list, small button padding)
  static const double sm = 8.0;

  /// 16pt — medium (screen horizontal padding, card padding) - DEFAULT
  static const double md = 16.0;

  /// 24pt — large (between sections)
  static const double lg = 24.0;

  /// 32pt — extra large (page hero spacing)
  static const double xl = 32.0;

  /// 48pt — 2x extra large (rare, hero areas)
  static const double xxl = 48.0;

  /// 64pt — 3x extra large (empty state padding)
  static const double xxxl = 64.0;

  /// Minimum touch target ขนาด (Apple HIG + Material)
  static const double minTouchTarget = 44.0;
}
