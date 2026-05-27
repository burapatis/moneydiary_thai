import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/database/app_database.dart';
import 'services/database/database_providers.dart';
import 'services/preferences_service.dart';

/// ──────────────────────────────────────────────────
/// Entry Point ของแอป
/// ──────────────────────────────────────────────────
/// ก่อน runApp ต้อง initialize:
///   1. WidgetsFlutterBinding
///   2. lock orientation = portrait only
///   3. โหลด .env
///   4. โหลด date locale data
///   5. Initialize SharedPreferences (sync provider)
///   6. Initialize AppDatabase + seed default categories
///   7. Override providers ใน ProviderScope
/// ──────────────────────────────────────────────────
Future<void> main() async {
  // 1. Initialize Flutter framework
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Lock portrait orientation
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. Load .env (optional)
  try {
    await dotenv.load();
  } catch (_) {
    debugPrint('Warning: .env not loaded — using defaults');
  }

  // 4. Initialize date locale (Thai + English)
  await initializeDateFormatting('th');
  await initializeDateFormatting('en');

  // 5. Initialize SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // 6. Initialize AppDatabase
  // ครั้งแรกจะ run migration onCreate + seed 25 default categories
  final AppDatabase database = AppDatabase();

  // 7. Run app
  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const MoneyDiaryApp(),
    ),
  );
}
