import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

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
// ONBOARDING DONE
// ═══════════════════════════════════════════════════

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(AppConstants.prefKeyOnboardingDone) ?? false;
  }

  Future<void> markDone() async {
    state = true;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.prefKeyOnboardingDone, true);
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
