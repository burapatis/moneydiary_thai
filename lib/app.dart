import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/gen/app_localizations.dart';
import 'services/preferences_service.dart';

/// ──────────────────────────────────────────────────
/// MoneyDiaryApp — Root widget ของแอป
/// ──────────────────────────────────────────────────
/// - ใช้ MaterialApp.router (สำหรับ go_router)
/// - Theme mode + Locale มาจาก Riverpod providers
/// - รองรับไทย + อังกฤษ
/// ──────────────────────────────────────────────────
class MoneyDiaryApp extends ConsumerWidget {
  const MoneyDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final Locale locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'MoneyDiary',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Routing
      routerConfig: router,

      // Localization
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // ทำให้ font scale ไม่เกิน 1.5 เพื่อไม่ให้ layout พัง
      // (ผู้ใช้ที่ตั้งค่าระบบใหญ่มากก็ยังอ่านได้ แต่ UI ไม่แตก)
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mq = MediaQuery.of(context);
        final double scale = mq.textScaler.scale(1).clamp(1.0, 1.5);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
