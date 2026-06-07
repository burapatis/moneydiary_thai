import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// ──────────────────────────────────────────────────
/// AppTheme — สร้าง ThemeData สำหรับ Light + Dark mode
/// ──────────────────────────────────────────────────
/// ใช้ Material 3 (`useMaterial3: true`) เพื่อให้ได้ component
/// ที่ทันสมัย + animation default ดี
/// ──────────────────────────────────────────────────
abstract final class AppTheme {
  AppTheme._();

  /// ────────────────
  /// LIGHT MODE
  /// ────────────────
  static ThemeData get light => _build(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.warning,
          onSecondary: Colors.white,
          error: AppColors.danger,
          onError: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceContainerHighest: AppColors.lightCard,
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightDivider,
        ),
        scaffoldBg: AppColors.lightBackground,
        cardColor: AppColors.lightCard,
        dividerColor: AppColors.lightDivider,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
        textTertiary: AppColors.lightTextTertiary,
        statusBarStyle: SystemUiOverlayStyle.dark,
      );

  /// ────────────────
  /// DARK MODE
  /// ────────────────
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          onPrimary: Colors.black,
          primaryContainer: AppColors.primaryDark,
          onPrimaryContainer: AppColors.primaryContainer,
          secondary: AppColors.warning,
          onSecondary: Colors.black,
          error: AppColors.danger,
          onError: Colors.white,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkCard,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkDivider,
        ),
        scaffoldBg: AppColors.darkBackground,
        cardColor: AppColors.darkCard,
        dividerColor: AppColors.darkDivider,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
        textTertiary: AppColors.darkTextTertiary,
        statusBarStyle: SystemUiOverlayStyle.light,
      );

  /// ────────────────
  /// Build helper - ลด duplication ระหว่าง light/dark
  /// ────────────────
  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBg,
    required Color cardColor,
    required Color dividerColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required SystemUiOverlayStyle statusBarStyle,
  }) {
    final TextTheme textTheme = _buildTextTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardColor,
      dividerColor: dividerColor,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // AppBar — ชื่อหน้ากลางจอ สี primary เด่นชัด
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h2.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: statusBarStyle,
      ),

      // Card
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        margin: EdgeInsets.zero,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
        showDragHandle: true,
        dragHandleColor: textTertiary,
      ),

      // Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget + 4),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget + 4),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTypography.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          textStyle: AppTypography.button,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        hintStyle: AppTypography.body.copyWith(color: textTertiary),
      ),

      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          AppTypography.caption,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        side: BorderSide(color: dividerColor),
        labelStyle: AppTypography.caption,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        minVerticalPadding: AppSpacing.sm,
        titleTextStyle: AppTypography.bodyLarge.copyWith(color: textPrimary),
        subtitleTextStyle: AppTypography.body.copyWith(color: textSecondary),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        contentTextStyle: AppTypography.body.copyWith(color: Colors.white),
      ),
    );
  }

  /// ────────────────
  /// TextTheme — บอก Flutter ว่าใช้ style ไหนใน Text widget default
  /// ────────────────
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: AppTypography.display.copyWith(color: primary),
      displayMedium: AppTypography.h1.copyWith(color: primary),
      headlineLarge: AppTypography.h1.copyWith(color: primary),
      headlineMedium: AppTypography.h2.copyWith(color: primary),
      headlineSmall: AppTypography.h3.copyWith(color: primary),
      titleLarge: AppTypography.h2.copyWith(color: primary),
      titleMedium: AppTypography.h3.copyWith(color: primary),
      titleSmall: AppTypography.bodyMedium.copyWith(color: primary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: primary),
      bodyMedium: AppTypography.body.copyWith(color: primary),
      bodySmall: AppTypography.caption.copyWith(color: secondary),
      labelLarge: AppTypography.button.copyWith(color: primary),
      labelMedium: AppTypography.buttonSmall.copyWith(color: primary),
      labelSmall: AppTypography.caption.copyWith(color: secondary),
    );
  }
}
