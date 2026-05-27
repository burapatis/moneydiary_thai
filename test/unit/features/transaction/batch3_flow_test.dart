import 'package:flutter_test/flutter_test.dart';
import 'package:moneydiary_thai/core/errors/failures.dart';
import 'package:moneydiary_thai/features/account/data/repositories/account_repository_impl.dart';
import 'package:moneydiary_thai/features/account/domain/entities/account.dart';
import 'package:moneydiary_thai/features/category/data/repositories/category_repository_impl.dart';
import 'package:moneydiary_thai/features/category/domain/entities/category.dart';
import 'package:moneydiary_thai/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:moneydiary_thai/features/transaction/domain/entities/transaction.dart';
import 'package:moneydiary_thai/services/database/app_database.dart';

import '../../../helpers/test_database.dart';

/// ──────────────────────────────────────────────────
/// Batch 3 — Integration tests สำหรับ full transaction flow
/// ──────────────────────────────────────────────────
void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl txRepo;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;
  late String testAccountId;
  late String testCategoryId;

  setUp(() async {
    db = createTestDatabase();
    txRepo = TransactionRepositoryImpl(db);
    accountRepo = AccountRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);

    // สร้าง account (default seeder ของ test ไม่ทำงาน เพราะ in-memory)
    final DateTime now = DateTime.now();
    final Account account = Account(
      id: '',
      name: 'เงินสด',
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
    testAccountId = (await accountRepo.create(account)).dataOrNull!.id;

    // ใช้ default category ที่ category seeder ใส่ไว้
    final List<Category> expenses =
        (await categoryRepo.getByType(CategoryType.expense)).dataOrNull!;
    testCategoryId = expenses.first.id;
  });

  tearDown(() async {
    await db.close();
  });

  group('Batch 3: Quick-Add Flow', () {
    test('Full Quick-Add flow: create → list → edit → delete', () async {
      // 1. Create transaction
      final Transaction tx = Transaction(
        id: '',
        accountId: testAccountId,
        categoryId: testCategoryId,
        amount: 65,
        type: TransactionType.expense,
        date: DateTime.now(),
        note: 'กาแฟเช้า',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final Result<Transaction> createResult = await txRepo.create(tx);
      expect(createResult.isSuccess, true);
      final Transaction created = createResult.dataOrNull!;
      expect(created.amount, 65);
      expect(created.note, 'กาแฟเช้า');

      // 2. ดึงผ่าน watchAll ต้องเห็น
      final List<Transaction> allTxs = (await txRepo.getAll()).dataOrNull!;
      expect(allTxs.length, 1);

      // 3. Edit (เปลี่ยน amount + note)
      final Transaction updated = created.copyWith(
        amount: 75,
        note: 'กาแฟลาเต้',
      );
      final Result<Transaction> updateResult = await txRepo.update(updated);
      expect(updateResult.isSuccess, true);
      expect(updateResult.dataOrNull?.amount, 75);
      expect(updateResult.dataOrNull?.note, 'กาแฟลาเต้');

      // 4. Delete
      final Result<void> deleteResult = await txRepo.delete(created.id);
      expect(deleteResult.isSuccess, true);

      // 5. List ต้องว่าง
      final List<Transaction> afterDelete =
          (await txRepo.getAll()).dataOrNull!;
      expect(afterDelete, isEmpty);
    });

    test('Multiple transactions same day — summary correct', () async {
      final DateTime today = DateTime.now();
      final List<({double amount, TransactionType type})> data =
          <({double amount, TransactionType type})>[
        (amount: 100, type: TransactionType.expense),
        (amount: 200, type: TransactionType.expense),
        (amount: 50, type: TransactionType.expense),
        (amount: 500, type: TransactionType.income),
      ];

      for (final ({double amount, TransactionType type}) d in data) {
        await txRepo.create(Transaction(
          id: '',
          accountId: testAccountId,
          categoryId: testCategoryId,
          amount: d.amount,
          type: d.type,
          date: today,
          createdAt: today,
          updatedAt: today,
        ));
      }

      // ตรวจสอบ summary
      final summary = (await txRepo.getSummary(
        from: DateTime(today.year, today.month, today.day),
        to: DateTime(today.year, today.month, today.day, 23, 59, 59),
      ))
          .dataOrNull!;

      expect(summary.expense, 350); // 100+200+50
      expect(summary.income, 500);
      expect(summary.net, 150); // 500 - 350
    });

    test('Cannot delete account with transactions', () async {
      // สร้าง transaction บนบัญชีนี้
      await txRepo.create(Transaction(
        id: '',
        accountId: testAccountId,
        categoryId: testCategoryId,
        amount: 100,
        type: TransactionType.expense,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // ลองลบบัญชี → ต้องถูก reject
      final Result<void> result = await accountRepo.delete(testAccountId);
      expect(result.isFailure, true);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });
}
