import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/preferences_service.dart';

/// ──────────────────────────────────────────────────
/// Category Providers — เพิ่มเติม last-used memory
/// ──────────────────────────────────────────────────
/// (categoriesStreamProvider อยู่ใน transaction_providers.dart)

/// LastUsedCategoryId — จำหมวดล่าสุดที่ผู้ใช้เลือก (per type)
class LastUsedCategoryIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(AppConstants.prefKeyLastUsedCategoryId);
  }

  Future<void> setId(String categoryId) async {
    state = categoryId;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.prefKeyLastUsedCategoryId, categoryId);
  }
}

final NotifierProvider<LastUsedCategoryIdNotifier, String?>
    lastUsedCategoryIdProvider =
    NotifierProvider<LastUsedCategoryIdNotifier, String?>(
        LastUsedCategoryIdNotifier.new);
