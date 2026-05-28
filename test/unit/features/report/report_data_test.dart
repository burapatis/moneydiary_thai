import 'package:flutter_test/flutter_test.dart';
import 'package:moneydiary_thai/features/account/data/repositories/account_repository_impl.dart';
import 'package:moneydiary_thai/features/account/domain/entities/account.dart';
import 'package:moneydiary_thai/features/category/data/repositories/category_repository_impl.dart';
import 'package:moneydiary_thai/features/category/domain/entities/category.dart';
import 'package:moneydiary_thai/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:moneydiary_thai/features/transaction/domain/entities/transaction.dart';
import 'package:moneydiary_thai/services/database/app_database.dart';

import '../../../helpers/test_database.dart';

/// ──────────────────────────────────────────────────
/// Batch 5 — Report data tests
/// ──────────────────────────────────────────────────
/// ทดสอบว่า sumByCategory + getSummary ให้ข้อมูลที่ถูกต้อง
/// สำหรับ pie chart และ insights
/// ──────────────────────────────────────────────────
void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl txRepo;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;
  late String accountId;
  late List<Category> expenseCategories;

  setUp(() async {
    db = createTestDatabase();
    txRepo = TransactionRepositoryImpl(db);
    accountRepo = AccountRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);

    final DateTime now = DateTime.now();
    accountId = (await accountRepo.create(Account(
      id: '',
      name: 'Test',
      type: AccountType.cash,
      icon: 'wallet',
      color: '0xFF10B981',
      initialBalance: 0,
      currency: 'THB',
      archived: false,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    )))
        .dataOrNull!
        .id;

    expenseCategories =
        (await categoryRepo.getByType(CategoryType.expense)).dataOrNull!;
  });

  tearDown(() async {
    await db.close();
  });

  group('Batch 5: Report Data', () {
    test('sumByCategory groups expenses correctly for pie chart', () async {
      final DateTime date = DateTime(2026, 5, 15, 12);
      final String catFood = expenseCategories[0].id;
      final String catCoffee = expenseCategories[1].id;

      // อาหาร: 100 + 200 = 300
      await txRepo.create(_makeTx(accountId, catFood, 100, date));
      await txRepo.create(_makeTx(accountId, catFood, 200, date));
      // กาแฟ: 50
      await txRepo.create(_makeTx(accountId, catCoffee, 50, date));

      final result = await txRepo.sumByCategory(
        from: DateTime(2026, 5, 1),
        to: DateTime(2026, 5, 31, 23, 59, 59),
        type: TransactionType.expense,
      );

      final Map<String, double> sums = result.dataOrNull!;
      expect(sums[catFood], 300);
      expect(sums[catCoffee], 50);
    });

    test('summary calculates income, expense, net for the period', () async {
      final DateTime date = DateTime(2026, 5, 15, 12);
      final String catFood = expenseCategories[0].id;
      final List<Category> incomeCategories =
          (await categoryRepo.getByType(CategoryType.income)).dataOrNull!;
      final String catSalary = incomeCategories[0].id;

      await txRepo.create(_makeTx(accountId, catFood, 300, date));
      await txRepo.create(_makeTx(
        accountId,
        catSalary,
        5000,
        date,
        type: TransactionType.income,
      ));

      final summary = (await txRepo.getSummary(
        from: DateTime(2026, 5, 1),
        to: DateTime(2026, 5, 31, 23, 59, 59),
      ))
          .dataOrNull!;

      expect(summary.income, 5000);
      expect(summary.expense, 300);
      expect(summary.net, 4700);
    });

    test('period isolation: May vs June separated', () async {
      final String catFood = expenseCategories[0].id;

      // พฤษภาคม: 1000
      await txRepo.create(
          _makeTx(accountId, catFood, 1000, DateTime(2026, 5, 15)));
      // มิถุนายน: 500
      await txRepo.create(
          _makeTx(accountId, catFood, 500, DateTime(2026, 6, 15)));

      final maySum = (await txRepo.getSummary(
        from: DateTime(2026, 5, 1),
        to: DateTime(2026, 5, 31, 23, 59, 59),
      ))
          .dataOrNull!;
      final juneSum = (await txRepo.getSummary(
        from: DateTime(2026, 6, 1),
        to: DateTime(2026, 6, 30, 23, 59, 59),
      ))
          .dataOrNull!;

      expect(maySum.expense, 1000);
      expect(juneSum.expense, 500);
    });
  });
}

Transaction _makeTx(
  String accountId,
  String categoryId,
  double amount,
  DateTime date, {
  TransactionType type = TransactionType.expense,
}) {
  final DateTime now = DateTime.now();
  return Transaction(
    id: '',
    accountId: accountId,
    categoryId: categoryId,
    amount: amount,
    type: type,
    date: date,
    createdAt: now,
    updatedAt: now,
  );
}
