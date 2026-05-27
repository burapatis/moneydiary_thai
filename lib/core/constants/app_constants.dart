/// ──────────────────────────────────────────────────
/// AppConstants — ค่าคงที่ของแอป
/// ──────────────────────────────────────────────────
abstract final class AppConstants {
  AppConstants._();

  /// ชื่อแอป (แสดงในที่ต่างๆ)
  static const String appName = 'MoneyDiary Thai';
  static const String appNameTh = 'สมุดบันทึกเงินไทย';

  /// Version (ดึงจาก pubspec.yaml ผ่าน package_info_plus ใน production)
  static const String appVersion = '0.1.0';

  /// Currency เริ่มต้น
  static const String defaultCurrency = 'THB';
  static const String defaultCurrencySymbol = '฿';

  /// Locale เริ่มต้น (ไทย)
  static const String defaultLocale = 'th';

  /// SharedPreferences keys — รวมที่นี่ป้องกัน typo
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyLocale = 'locale';
  static const String prefKeyOnboardingDone = 'onboarding_done';
  static const String prefKeyAnalyticsOptIn = 'analytics_opt_in';
  static const String prefKeyBiometricLock = 'biometric_lock';
  static const String prefKeyLastUsedCategoryId = 'last_used_category_id';
  static const String prefKeyLastUsedAccountId = 'last_used_account_id';

  /// Secure Storage keys
  static const String secureKeyDbEncryption = 'db_encryption_key';

  /// External URLs (ดึงจาก .env ใน production)
  static const String urlPrivacyPolicy = 'https://moneydiary.app/privacy';
  static const String urlTermsOfService = 'https://moneydiary.app/terms';
  static const String urlSupport = 'mailto:support@moneydiary.app';

  /// Performance budgets
  static const Duration animationFast = Duration(milliseconds: 100);
  static const Duration animationNormal = Duration(milliseconds: 200);
  static const Duration animationSlow = Duration(milliseconds: 300);

  /// Toast/Snackbar duration
  static const Duration toastDuration = Duration(seconds: 2);
}
