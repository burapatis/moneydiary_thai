/// ──────────────────────────────────────────────────
/// AppConstants — ค่าคงที่ของแอป
/// ──────────────────────────────────────────────────
abstract final class AppConstants {
  AppConstants._();

  /// ชื่อแอป (แสดงในที่ต่างๆ)
  static const String appName = 'บัญชีวิถีไทย';
  static const String appNameTh = 'สมุดบันทึกเงินไทย';

  /// Version fallback — ใช้ package_info_plus ใน UI จริง
  static const String appVersionFallback = '1.1.0';

  /// Currency เริ่มต้น
  static const String defaultCurrency = 'THB';
  static const String defaultCurrencySymbol = '฿';

  /// Locale เริ่มต้น (ไทย)
  static const String defaultLocale = 'th';

  /// SharedPreferences keys — รวมที่นี่ป้องกัน typo
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyLocale = 'locale';
  static const String prefKeyOnboardingDone = 'onboarding_done';
  static const String prefKeyTermsAccepted = 'terms_accepted';
  static const String prefKeyUsageGuideDone = 'usage_guide_done';
  static const String prefKeyAnalyticsOptIn = 'analytics_opt_in';
  static const String prefKeyBiometricLock = 'biometric_lock';
  static const String prefKeyLastUsedCategoryId = 'last_used_category_id';
  static const String prefKeyLastUsedAccountId = 'last_used_account_id';
  static const String prefKeyTextScale = 'text_scale';

  /// External URLs — อ่านจาก .env ผ่าน EnvConfig (fallback ค่าจริงบน GitHub Pages)
  static const String urlPrivacyPolicy =
      'https://burapatis.github.io/app/apps/banchee-witheethai/privacy.html';
  static const String urlTermsOfService =
      'https://burapatis.github.io/app/apps/banchee-witheethai/terms.html';
  static const String urlSupportHelp =
      'https://burapatis.github.io/app/apps/banchee-witheethai/support.html';
  static const String urlSupport = 'mailto:support@moneydiary.app';

  /// Performance budgets
  static const Duration animationFast = Duration(milliseconds: 100);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 300);

  /// Toast/Snackbar duration
  static const Duration toastDuration = Duration(seconds: 2);
}
