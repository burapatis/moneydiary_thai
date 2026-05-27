import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// ──────────────────────────────────────────────────
/// BuildContextExtensions — ลด boilerplate
/// ──────────────────────────────────────────────────
/// แทนที่จะเขียน Theme.of(context).colorScheme.primary
/// เขียน context.colors.primary แทน
/// ──────────────────────────────────────────────────
extension BuildContextExtensions on BuildContext {
  /// ────────────────
  /// Theme shortcuts
  /// ────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  /// ตรวจสอบ dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// ────────────────
  /// MediaQuery shortcuts
  /// ────────────────
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// ตรวจสอบขนาดหน้าจอตาม Design Spec §7
  bool get isSmallScreen => screenWidth < 375;
  bool get isMediumScreen => screenWidth >= 375 && screenWidth < 414;
  bool get isLargeScreen => screenWidth >= 414;
  bool get isTablet => screenWidth >= 768;

  /// ────────────────
  /// Navigation shortcuts
  /// ────────────────
  NavigatorState get nav => Navigator.of(this);

  /// ────────────────
  /// Show snackbar (toast) — ใช้บ่อย
  /// ────────────────
  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
        duration: duration,
      ),
    );
  }
}
