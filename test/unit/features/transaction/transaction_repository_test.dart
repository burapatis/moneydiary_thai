import 'package:flutter_test/flutter_test.dart';
import 'package:moneydiary_thai/core/errors/failures.dart';
import 'package:moneydiary_thai/features/account/data/repositories/account_repository_impl.dart';
import 'package:moneydiary_thai/features/account/domain/entities/account.dart';
import 'package:moneydiary_thai/features/category/data/repositories/category_repository_impl.dart';
import 'package:moneydiary_thai/features/category/domain/entities/category.dart';
import 'package:moneydiary_thai/features/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:moneydiary_thai/features/transaction/domain/entities/transaction.dart';
import 'package:moneydiary_thai/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:moneydiary_thai/services/database/app_database.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late TransactionRepositoryImpl repo;
  late AccountRepositoryImpl accountRepo;
  late CategoryRepositoryImpl categoryRepo;

  /// IDs ที่จะใช้ใน test
  late String testAccountId;
  late String testExpenseCategoryId;
  late String testIncomeCategoryId;

  setUp(() async {
    db = createTestDatabase();
    repo = TransactionRepositoryImpl(db);
    accountRepo = AccountRepositoryImpl(db);
    categoryRepo = CategoryRepositoryImpl(db);

    // สร้าง account ทดสอบ
    final DateTime now = DateTime.now();
    final Account account = Account(
      id: '',
      name: 'Test Cash',
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

    // ใช้ default categories ที่ seeder สร้างไว้
    final List<Category> expenses =
        (await categoryRepo.getByType(CategoryType.expense)).dataOrNull!;
    testExpenseCategoryId = expenses.first.id;

    final List<Category> incomes =
        (await categoryRepo.getByType(CategoryType.income)).dataOrNull!;
    testIncomeCategoryId = incomes.first.id;
  });

  tearDown(() async {
    await db.close();
  });

  /// helper สร้าง transaction
  Transaction makeTx({
    String id = '',
    double amount = 100,
    TransactionType type = TransactionType.expense,
    String? accountId,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    final DateTime now = DateTime.now();
    return Transaction(
      id: id,
      accountId: accountId ?? testAccountId,
      categoryId: categoryId ??
          (type == TransactionType.expense
              ? testExpenseCategoryId
              : testIncomeCategoryId),
      amount: amount,
      type: type,
      date: date ?? now,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('TransactionRepository', () {
    group('create', () {
      test('should create transaction with generated id', () async {
        final Result<Transaction> result = await repo.create(makeTx());

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.id.isNotEmpty, true);
      });

      test('should reject amount = 0', () async {
        final Result<Transaction> result = await repo.create(makeTx(amount: 0));

        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<ValidationFailure>());
      });

      test('should reject negative amount', () async {
        final Result<Transaction> result =
            await repo.create(makeTx(amount: -100));

        expect(result.failureOrNull, isA<ValidationFailure>());
      });

      test('should reject empty accountId', () async {
        final Result<Transaction> result =
            await repo.create(makeTx(accountId: ''));

        expect(result.failureOrNull, isA<ValidationFailure>());
      });

      test('should reject empty categoryId', () async {
        final Result<Transaction> result =
            await repo.create(makeTx(categoryId: ''));

        expect(result.failureOrNull, isA<ValidationFailure>());
      });

      test('should accept Thai note', () async {
        final Result<Transaction> result = await repo.create(
          makeTx(note: 'กาแฟลาเต้ร้อน Starbucks สาขา MBK'),
        );

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.note, 'กาแฟลาเต้ร้อน Starbucks สาขา MBK');
      });
    });

    group('getById', () {
      test('should return transaction when exists', () async {
        final Transaction created = (await repo.create(makeTx())).dataOrNull!;
        final Result<Transaction> result = await repo.getById(created.id);

        expect(result.dataOrNull?.id, created.id);
      });

      test('should return NotFoundFailure when not exists', () async {
        final Result<Transaction> result = await repo.getById('non-existent');

        expect(result.failureOrNull, isA<NotFoundFailure>());
      });
    });

    group('update', () {
      test('should update amount', () async {
        final Transaction created =
            (await repo.create(makeTx(amount: 100))).dataOrNull!;

        await repo.update(created.copyWith(amount: 250));

        final Transaction? fetched = (await repo.getById(created.id)).dataOrNull;
        expect(fetched?.amount, 250);
      });

      test('should reject invalid amount on update', () async {
        final Transaction created = (await repo.create(makeTx())).dataOrNull!;

        final Result<Transaction> result =
            await repo.update(created.copyWith(amount: 0));

        expect(result.failureOrNull, isA<ValidationFailure>());
      });
    });

    group('delete', () {
      test('should delete transaction', () async {
        final Transaction created = (await repo.create(makeTx())).dataOrNull!;
        final Result<void> result = await repo.delete(created.id);

        expect(result.isSuccess, true);
        expect((await repo.getById(created.id)).isFailure, true);
      });

      test('should return NotFoundFailure when deleting non-existent', () async {
        final Result<void> result = await repo.delete('non-existent');

        expect(result.failureOrNull, isA<NotFoundFailure>());
      });
    });

    group('getByDateRange', () {
      test('should return transactions in range', () async {
        final DateTime today = DateTime(2026, 5, 25);
        final DateTime yesterday = DateTime(2026, 5, 24);
        final DateTime tomorrow = DateTime(2026, 5, 26);

        await repo.create(makeTx(amount: 100, date: today));
        await repo.create(makeTx(amount: 200, date: yesterday));
        await repo.create(makeTx(amount: 300, date: tomorrow));

        final Result<List<Transaction>> result = await repo.getByDateRange(
          from: DateTime(2026, 5, 25),
          to: DateTime(2026, 5, 25, 23, 59, 59),
        );

        expect(result.dataOrNull?.length, 1);
        expect(result.dataOrNull?.first.amount, 100);
      });
    });

    group('getSummary', () {
      test('should calculate income and expense', () async {
        final DateTime today = DateTime(2026, 5, 25, 12);

        await repo.create(
          makeTx(amount: 500, type: TransactionType.income, date: today),
        );
        await repo.create(
          makeTx(amount: 200, type: TransactionType.expense, date: today),
        );
        await repo.create(
          makeTx(amount: 100, type: TransactionType.expense, date: today),
        );

        final Result<TransactionSummary> result = await repo.getSummary(
          from: DateTime(2026, 5, 25),
          to: DateTime(2026, 5, 25, 23, 59, 59),
        );

        expect(result.isSuccess, true);
        final TransactionSummary s = result.dataOrNull!;
        expect(s.income, 500);
        expect(s.expense, 300);
        expect(s.net, 200);
      });

      test('should return zero when no transactions', () async {
        final Result<TransactionSummary> result = await repo.getSummary(
          from: DateTime(2026, 1, 1),
          to: DateTime(2026, 1, 31),
        );

        expect(result.dataOrNull?.income, 0);
        expect(result.dataOrNull?.expense, 0);
      });
    });

    group('sumByCategory', () {
      test('should group sums by category', () async {
        final DateTime today = DateTime(2026, 5, 25, 12);

        // 2 expense transactions ใน category เดียวกัน
        await repo.create(makeTx(
          amount: 100,
          type: TransactionType.expense,
          categoryId: testExpenseCategoryId,
          date: today,
        ));
        await repo.create(makeTx(
          amount: 200,
          type: TransactionType.expense,
          categoryId: testExpenseCategoryId,
          date: today,
        ));

        final Result<Map<String, double>> result = await repo.sumByCategory(
          from: DateTime(2026, 5, 25),
          to: DateTime(2026, 5, 25, 23, 59, 59),
          type: TransactionType.expense,
        );

        expect(result.dataOrNull?[testExpenseCategoryId], 300);
      });
    });
  });
}
