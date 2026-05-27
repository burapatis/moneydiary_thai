// ──────────────────────────────────────────────────
// Smoke Test — ทดสอบว่าแอป boot ขึ้นมาได้
// ──────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneydiary_thai/app.dart';
import 'package:moneydiary_thai/services/database/database_providers.dart';
import 'package:moneydiary_thai/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_database.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('App boots and shows 4-tab bottom nav', (WidgetTester tester) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final testDb = createTestDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(testDb),
        ],
        child: const MoneyDiaryApp(),
      ),
    );

    await tester.pumpAndSettle();

    // ตรวจสอบโครงสร้าง
    expect(find.byType(BottomAppBar), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
    expect(find.byIcon(Icons.list_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    await testDb.close();
  });

  testWidgets('Can switch to Reports tab', (WidgetTester tester) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final testDb = createTestDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(testDb),
        ],
        child: const MoneyDiaryApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bar_chart_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bar_chart), findsOneWidget);

    await testDb.close();
  });
}
