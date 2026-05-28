import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/preferences_service.dart';

/// ──────────────────────────────────────────────────
/// Biometric Lock — ล็อกแอปด้วย Face ID / Touch ID
/// ──────────────────────────────────────────────────

/// LocalAuthentication instance
final Provider<LocalAuthentication> localAuthProvider =
    Provider<LocalAuthentication>((Ref ref) => LocalAuthentication());

/// ตรวจสอบว่าเครื่องรองรับ biometric ไหม
final FutureProvider<bool> biometricAvailableProvider =
    FutureProvider<bool>((Ref ref) async {
  final LocalAuthentication auth = ref.read(localAuthProvider);
  try {
    final bool canCheck = await auth.canCheckBiometrics;
    final bool isSupported = await auth.isDeviceSupported();
    return canCheck && isSupported;
  } catch (_) {
    return false;
  }
});

/// สถานะ biometric lock เปิด/ปิด (เก็บใน SharedPreferences)
class BiometricLockNotifier extends Notifier<bool> {
  @override
  bool build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(AppConstants.prefKeyBiometricLock) ?? false;
  }

  /// เปิด/ปิด biometric lock
  /// คืน true ถ้าสำเร็จ
  Future<bool> setEnabled(bool enabled) async {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);

    if (enabled) {
      // ต้อง authenticate สำเร็จก่อน ถึงจะเปิดได้
      final bool authenticated = await authenticate(
        reason: 'ยืนยันตัวตนเพื่อเปิดใช้การล็อกแอป',
      );
      if (!authenticated) return false;
    }

    state = enabled;
    await prefs.setBool(AppConstants.prefKeyBiometricLock, enabled);
    return true;
  }

  /// เรียก biometric prompt
  Future<bool> authenticate({
    String reason = 'ยืนยันตัวตนเพื่อเข้าใช้แอป',
  }) async {
    final LocalAuthentication auth = ref.read(localAuthProvider);
    try {
      return await auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // อนุญาต PIN/passcode fallback
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

final NotifierProvider<BiometricLockNotifier, bool> biometricLockProvider =
    NotifierProvider<BiometricLockNotifier, bool>(BiometricLockNotifier.new);
