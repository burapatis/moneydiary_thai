import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// ตรวจว่าเป็นผู้ใช้เดิม (อัปเดตจาก v1.0.x / v1.1.x) ที่ควรข้าม first-launch flow
bool isLegacyExistingUser(SharedPreferences prefs) {
  if (prefs.getBool(AppConstants.prefKeyOnboardingDone) ?? false) {
    return true;
  }

  return prefs.containsKey(AppConstants.prefKeyThemeMode) ||
      prefs.containsKey(AppConstants.prefKeyLocale) ||
      prefs.containsKey(AppConstants.prefKeyBiometricLock) ||
      prefs.containsKey(AppConstants.prefKeyLastUsedCategoryId);
}
