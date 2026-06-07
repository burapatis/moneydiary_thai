import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_text_scale.dart';
import '../core/utils/first_launch_helper.dart';

/// ──────────────────────────────────────────────────
/// PreferencesService — Riverpod providers สำหรับ user preferences
/// ──────────────────────────────────────────────────
/// ใช้ SharedPreferences สำหรับ settings ที่ไม่ sensitive
/// (theme, locale, onboarding_done, analytics_opt_in)
/// ──────────────────────────────────────────────────

/// Override ใน main.dart หลังจาก initialize
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

// ═══════════════════════════════════════════════════
// THEME MODE
// ═══════════════════════════════════════════════════

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    final String? saved = prefs.getString(AppConstants.prefKeyThemeMode);
    return _parseThemeMode(saved);
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefKeyThemeMode, mode.name);
  }

  ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// ═══════════════════════════════════════════════════
// LOCALE
// ═══════════════════════════════════════════════════

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    final String saved =
        prefs.getString(AppConstants.prefKeyLocale) ?? AppConstants.defaultLocale;
    return Locale(saved);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefKeyLocale, languageCode);
  }
}

final NotifierProvider<LocaleNotifier, Locale> localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

// ═══════════════════════════════════════════════════
// TEXT SCALE — ขนาดตัวอักษร (เหมาะผู้สูงวัย)
// ═══════════════════════════════════════════════════

class TextScaleNotifier extends Notifier<AppTextScale> {
  @override
  AppTextScale build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    return parseAppTextScale(prefs.getString(AppConstants.prefKeyTextScale));
  }

  Future<void> setScale(AppTextScale scale) async {
    state = scale;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefKeyTextScale, scale.name);
  }
}

final NotifierProvider<TextScaleNotifier, AppTextScale> textScaleProvider =
    NotifierProvider<TextScaleNotifier, AppTextScale>(TextScaleNotifier.new);

// ═══════════════════════════════════════════════════
// TERMS ACCEPTED
// ═══════════════════════════════════════════════════

class TermsAcceptedNotifier extends Notifier<bool> {
  @override
  bool build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(AppConstants.prefKeyTermsAccepted) ?? false) {
      return true;
    }
    return isLegacyExistingUser(prefs);
  }

  Future<void> accept() async {
    state = true;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefKeyTermsAccepted, true);
  }
}

final NotifierProvider<TermsAcceptedNotifier, bool> termsAcceptedProvider =
    NotifierProvider<TermsAcceptedNotifier, bool>(TermsAcceptedNotifier.new);

// ═══════════════════════════════════════════════════
// USAGE GUIDE DONE
// ═══════════════════════════════════════════════════

class UsageGuideDoneNotifier extends Notifier<bool> {
  @override
  bool build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool(AppConstants.prefKeyUsageGuideDone) ?? false) {
      return true;
    }
    return isLegacyExistingUser(prefs);
  }

  Future<void> markDone() async {
    state = true;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefKeyUsageGuideDone, true);
    await prefs.setBool(AppConstants.prefKeyOnboardingDone, true);
  }
}

final NotifierProvider<UsageGuideDoneNotifier, bool> usageGuideDoneProvider =
    NotifierProvider<UsageGuideDoneNotifier, bool>(UsageGuideDoneNotifier.new);

// ═══════════════════════════════════════════════════
// ONBOARDING DONE (legacy — ใช้ร่วมกับ usage guide)
// ═══════════════════════════════════════════════════

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(usageGuideDoneProvider);

  Future<void> markDone() async {
    await ref.read(usageGuideDoneProvider.notifier).markDone();
  }
}

final NotifierProvider<OnboardingNotifier, bool> onboardingDoneProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

// ═══════════════════════════════════════════════════
// ANALYTICS OPT-IN — default OFF (PDPA privacy-first)
// ═══════════════════════════════════════════════════

class AnalyticsConsentNotifier extends Notifier<bool> {
  @override
  bool build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(AppConstants.prefKeyAnalyticsOptIn) ?? false;
  }

  Future<void> setConsent({required bool consent}) async {
    state = consent;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefKeyAnalyticsOptIn, consent);
  }
}

final NotifierProvider<AnalyticsConsentNotifier, bool> analyticsConsentProvider =
    NotifierProvider<AnalyticsConsentNotifier, bool>(
        AnalyticsConsentNotifier.new);
