import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/database/database_providers.dart';
import '../../../../services/preferences_service.dart';
import '../../domain/entities/account.dart';

/// ──────────────────────────────────────────────────
/// Account Providers — เพิ่มเติมจาก transaction_providers.dart
/// ──────────────────────────────────────────────────

/// Stream ของบัญชีทั้งหมด (ไม่รวม archived)
final StreamProvider<List<Account>> accountsProvider =
    StreamProvider<List<Account>>((Ref ref) {
  return ref.watch(accountRepositoryProvider).watchAll();
});

/// บัญชีตัวแรก (มี default "เงินสด" หลัง seed)
/// ใช้เป็น default ตอน Quick-Add ถ้ายังไม่เคยเลือก
final Provider<AsyncValue<Account?>> firstAccountProvider =
    Provider<AsyncValue<Account?>>((Ref ref) {
  final AsyncValue<List<Account>> async = ref.watch(accountsProvider);
  return async.whenData((List<Account> accounts) {
    return accounts.isEmpty ? null : accounts.first;
  });
});

/// ──────────────────────────────────────────────────
/// LastUsedAccountId — จำบัญชีล่าสุดที่ผู้ใช้เลือก
/// ──────────────────────────────────────────────────
class LastUsedAccountIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(AppConstants.prefKeyLastUsedAccountId);
  }

  Future<void> setId(String accountId) async {
    state = accountId;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefKeyLastUsedAccountId, accountId);
  }
}

final NotifierProvider<LastUsedAccountIdNotifier, String?>
    lastUsedAccountIdProvider =
    NotifierProvider<LastUsedAccountIdNotifier, String?>(
        LastUsedAccountIdNotifier.new);

/// บัญชีที่ควร select default ใน Quick-Add
/// Logic: last-used → first account → null
final Provider<AsyncValue<Account?>> defaultAccountProvider =
    Provider<AsyncValue<Account?>>((Ref ref) {
  final AsyncValue<List<Account>> accountsAsync = ref.watch(accountsProvider);
  final String? lastUsedId = ref.watch(lastUsedAccountIdProvider);

  return accountsAsync.whenData((List<Account> accounts) {
    if (accounts.isEmpty) return null;

    // ลองหาบัญชีที่ผู้ใช้เลือกล่าสุด
    if (lastUsedId != null) {
      for (final Account a in accounts) {
        if (a.id == lastUsedId) return a;
      }
    }

    // ไม่เจอ → ใช้ตัวแรก
    return accounts.first;
  });
});
