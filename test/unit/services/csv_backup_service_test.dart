import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moneydiary_thai/features/account/domain/entities/account.dart';
import 'package:moneydiary_thai/features/category/domain/entities/category.dart';
import 'package:moneydiary_thai/features/transaction/domain/entities/transaction.dart';
import 'package:moneydiary_thai/services/backup/csv_backup_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Mock path_provider เพื่อให้ getTemporaryDirectory ทำงานใน test
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getTemporaryPath() async {
    final Directory dir = Directory.systemTemp.createTempSync('mdtest_');
    return dir.path;
  }
}

void main() {
  late CsvBackupService service;

  setUpAll(() {
    PathProviderPlatform.instance = _FakePathProvider();
  });

  setUp(() {
    service = CsvBackupService();
  });

  Category makeCategory(String id, String nameTh) {
    final DateTime now = DateTime.now();
    return Category(
      id: id,
      nameTh: nameTh,
      nameEn: 'Test',
      icon: 'category',
      color: '0xFF10B981',
      type: CategoryType.expense,
      sortOrder: 0,
      isDefault: false,
      hidden: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Account makeAccount(String id, String name) {
    final DateTime now = DateTime.now();
    return Account(
      id: id,
      name: name,
      type: AccountType.cash,
      icon: 'wallet',
      color: '0xFF10B981',
      initialBalance: 0,
      currency: 'THB',
      archived: false,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CsvBackupService', () {
    test('export then parse round-trip preserves data', () async {
      final DateTime txDate = DateTime(2026, 5, 28, 14, 30);
      final List<Transaction> transactions = <Transaction>[
        Transaction(
          id: 'tx1',
          accountId: 'acc1',
          categoryId: 'cat1',
          amount: 65.0,
          type: TransactionType.expense,
          date: txDate,
          note: 'กาแฟลาเต้',
          createdAt: txDate,
          updatedAt: txDate,
        ),
      ];

      final Map<String, Category> categoryMap = <String, Category>{
        'cat1': makeCategory('cat1', 'กาแฟ-ขนม'),
      };
      final Map<String, Account> accountMap = <String, Account>{
        'acc1': makeAccount('acc1', 'เงินสด'),
      };

      // Export
      final exportResult = await service.exportToCsv(
        transactions: transactions,
        categoryMap: categoryMap,
        accountMap: accountMap,
      );
      expect(exportResult.isSuccess, true);
      final String path = exportResult.dataOrNull!;
      expect(File(path).existsSync(), true);

      // Parse back
      final parseResult = await service.parseCsv(path);
      expect(parseResult.isSuccess, true);
      final List<ImportedRow> rows = parseResult.dataOrNull!;

      expect(rows.length, 1);
      expect(rows.first.amount, 65.0);
      expect(rows.first.categoryName, 'กาแฟ-ขนม');
      expect(rows.first.accountName, 'เงินสด');
      expect(rows.first.note, 'กาแฟลาเต้');
      expect(rows.first.type, 'expense');

      // Clean up
      File(path).deleteSync();
    });

    test('export handles Thai text + multiple transactions', () async {
      final DateTime now = DateTime(2026, 5, 28, 10);
      final List<Transaction> transactions = <Transaction>[
        Transaction(
          id: 't1',
          accountId: 'a1',
          categoryId: 'c1',
          amount: 100,
          type: TransactionType.expense,
          date: now,
          note: 'โจ๊กหมู',
          createdAt: now,
          updatedAt: now,
        ),
        Transaction(
          id: 't2',
          accountId: 'a1',
          categoryId: 'c2',
          amount: 5000,
          type: TransactionType.income,
          date: now,
          note: null,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final Map<String, Category> categoryMap = <String, Category>{
        'c1': makeCategory('c1', 'อาหาร'),
        'c2': makeCategory('c2', 'เงินเดือน'),
      };
      final Map<String, Account> accountMap = <String, Account>{
        'a1': makeAccount('a1', 'เงินสด'),
      };

      final exportResult = await service.exportToCsv(
        transactions: transactions,
        categoryMap: categoryMap,
        accountMap: accountMap,
      );
      expect(exportResult.isSuccess, true);

      final parseResult = await service.parseCsv(exportResult.dataOrNull!);
      final List<ImportedRow> rows = parseResult.dataOrNull!;

      expect(rows.length, 2);
      expect(rows[0].note, 'โจ๊กหมู');
      expect(rows[1].type, 'income');
      expect(rows[1].amount, 5000);

      File(exportResult.dataOrNull!).deleteSync();
    });

    test('parse missing file returns failure', () async {
      final result = await service.parseCsv('/nonexistent/path/file.csv');
      expect(result.isFailure, true);
    });
  });
}
