import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────
/// AppRadius — Design Tokens (border radius)
/// ──────────────────────────────────────────────────
abstract final class AppRadius {
  AppRadius._();

  /// 8pt — chips, small buttons
  static const double sm = 8.0;
  static const Radius smRadius = Radius.circular(sm);
  static const BorderRadius smAll = BorderRadius.all(smRadius);

  /// 12pt — cards, inputs (default)
  static const double md = 12.0;
  static const Radius mdRadius = Radius.circular(md);
  static const BorderRadius mdAll = BorderRadius.all(mdRadius);

  /// 16pt — modals, bottom sheets
  static const double lg = 16.0;
  static const Radius lgRadius = Radius.circular(lg);
  static const BorderRadius lgAll = BorderRadius.all(lgRadius);

  /// Bottom sheet — โค้งบนเท่านั้น
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: lgRadius,
    topRight: lgRadius,
  );

  /// 24pt — FAB, hero cards
  static const double xl = 24.0;
  static const Radius xlRadius = Radius.circular(xl);
  static const BorderRadius xlAll = BorderRadius.all(xlRadius);

  /// 9999 — pill buttons, avatars
  static const double full = 9999.0;
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
