import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_text_scale.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/biometric_lock_gate.dart';
import 'features/onboarding/presentation/screens/terms_acceptance_screen.dart';
import 'features/onboarding/presentation/screens/usage_guide_screen.dart';
import 'l10n/gen/app_localizations.dart';
import 'services/preferences_service.dart';

/// ──────────────────────────────────────────────────
/// MoneyDiaryApp — Root widget ของแอป
/// ──────────────────────────────────────────────────
class MoneyDiaryApp extends ConsumerWidget {
  const MoneyDiaryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);
    final Locale locale = ref.watch(localeProvider);
    final bool termsAccepted = ref.watch(termsAcceptedProvider);
    final bool usageGuideDone = ref.watch(usageGuideDoneProvider);

    final Widget? firstLaunchScreen = _firstLaunchScreen(
      termsAccepted: termsAccepted,
      usageGuideDone: usageGuideDone,
    );

    if (firstLaunchScreen != null) {
      return MaterialApp(
        title: 'MoneyDiary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (BuildContext context, Widget? child) =>
            _wrapWithUserTextScale(context, ref, child),
        home: firstLaunchScreen,
      );
    }

    return MaterialApp.router(
      title: 'MoneyDiary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(appRouterProvider),
      builder: (BuildContext context, Widget? child) {
        return BiometricLockGate(
          child: _wrapWithUserTextScale(context, ref, child),
        );
      },
    );
  }

  Widget? _firstLaunchScreen({
    required bool termsAccepted,
    required bool usageGuideDone,
  }) {
    if (!termsAccepted) {
      return const TermsAcceptanceScreen(mode: TermsScreenMode.firstLaunch);
    }
    if (!usageGuideDone) {
      return const UsageGuideScreen(mode: UsageGuideMode.firstLaunch);
    }
    return null;
  }

  Widget _wrapWithUserTextScale(
    BuildContext context,
    WidgetRef ref,
    Widget? child,
  ) {
    final double scale = ref.watch(textScaleProvider).scaleFactor;
    final MediaQueryData mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(scale)),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
