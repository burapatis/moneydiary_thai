import 'package:flutter_test/flutter_test.dart';
import 'package:moneydiary_thai/core/errors/failures.dart';
import 'package:moneydiary_thai/features/account/data/repositories/account_repository_impl.dart';
import 'package:moneydiary_thai/features/account/domain/entities/account.dart';
import 'package:moneydiary_thai/services/database/app_database.dart';

import '../../../helpers/test_database.dart';

/// ──────────────────────────────────────────────────
/// Updated Tests สำหรับ AccountRepository
/// ──────────────────────────────────────────────────
/// หมายเหตุ: ตั้งแต่ Batch 3 — AppDatabase auto-seed "เงินสด" ตอน open
/// ดังนั้น test ต้อง:
///   - บวก 1 จาก expected (เพราะมี เงินสด default)
///   - หรือ ลบ default ออกก่อน assert
/// ──────────────────────────────────────────────────

void main() {
  late AppDatabase db;
  late AccountRepositoryImpl repo;

  setUp(() {
    db = createTestDatabase();
    repo = AccountRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// helper สร้าง account สำหรับ test
  Account makeAccount({
    String id = '',
    String name = 'Test Account',
    AccountType type = AccountType.cash,
    double initialBalance = 0,
  }) {
    final DateTime now = DateTime.now();
    return Account(
      id: id,
      name: name,
      type: type,
      icon: 'wallet',
      color: '0xFF10B981',
      initialBalance: initialBalance,
      currency: 'THB',
      archived: false,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('AccountRepository', () {
    group('create', () {
      test('should create account and return with generated id', () async {
        final Result<Account> result =
            await repo.create(makeAccount(name: 'บัญชีใหม่'));

        expect(result.isSuccess, true);
        final Account created = result.dataOrNull!;
        expect(created.id.isNotEmpty, true);
        expect(created.name, 'บัญชีใหม่');
      });

      test('should use provided id if not empty', () async {
        final Result<Account> result =
            await repo.create(makeAccount(id: 'custom-id-123'));

        expect(result.dataOrNull?.id, 'custom-id-123');
      });
    });

    group('getById', () {
      test('should return account when exists', () async {
        final Account created = (await repo.create(makeAccount())).dataOrNull!;

        final Result<Account> result = await repo.getById(created.id);

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.id, created.id);
      });

      test('should return NotFoundFailure when not exists', () async {
        final Result<Account> result = await repo.getById('non-existent-id');

        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<NotFoundFailure>());
      });
    });

    group('getAll', () {
      // หมายเหตุ: หลัง Batch 3 — DB จะมี "เงินสด" default 1 บัญชี
      test('should return only seeded default account when no user accounts',
          () async {
        final Result<List<Account>> result = await repo.getAll();

        expect(result.isSuccess, true);
        // มี seeded "เงินสด" 1 ตัว (ไม่ใช่ empty อีกต่อไป)
        expect(result.dataOrNull?.length, 1);
        expect(result.dataOrNull?.first.name, 'เงินสด');
      });

      test('should return all non-archived accounts (including default)',
          () async {
        await repo.create(makeAccount(name: 'A'));
        await repo.create(makeAccount(name: 'B'));
        await repo.create(makeAccount(name: 'C'));

        final Result<List<Account>> result = await repo.getAll();

        // 3 user + 1 default = 4
        expect(result.dataOrNull?.length, 4);
      });

      test('should exclude archived by default', () async {
        final Account a = (await repo.create(makeAccount(name: 'A'))).dataOrNull!;
        await repo.create(makeAccount(name: 'B'));
        await repo.archive(a.id);

        final Result<List<Account>> result = await repo.getAll();

        // 1 user (B) + 1 default (เงินสด) = 2  (A ถูก archive)
        expect(result.dataOrNull?.length, 2);
      });

      test('should include archived when requested', () async {
        final Account a = (await repo.create(makeAccount(name: 'A'))).dataOrNull!;
        await repo.create(makeAccount(name: 'B'));
        await repo.archive(a.id);

        final Result<List<Account>> result =
            await repo.getAll(includeArchived: true);

        // 2 user (A archived + B) + 1 default = 3
        expect(result.dataOrNull?.length, 3);
      });
    });

    group('update', () {
      test('should update name', () async {
        final Account created =
            (await repo.create(makeAccount(name: 'Old'))).dataOrNull!;
        final Account modified = created.copyWith(name: 'New');

        final Result<Account> result = await repo.update(modified);

        expect(result.isSuccess, true);
        final Account? fetched = (await repo.getById(created.id)).dataOrNull;
        expect(fetched?.name, 'New');
      });

      test('should return NotFoundFailure if account does not exist', () async {
        final Result<Account> result = await repo.update(
          makeAccount(id: 'non-existent'),
        );

        expect(result.failureOrNull, isA<NotFoundFailure>());
      });
    });

    group('archive', () {
      test('should set archived = true', () async {
        final Account a = (await repo.create(makeAccount())).dataOrNull!;
        await repo.archive(a.id);

        final Account? fetched = (await repo.getById(a.id)).dataOrNull;
        expect(fetched?.archived, true);
      });
    });

    group('calculateBalance', () {
      test('should return initialBalance when no transactions', () async {
        final Account a = (await repo.create(
          makeAccount(initialBalance: 1000),
        )).dataOrNull!;

        final Result<double> result = await repo.calculateBalance(a.id);

        expect(result.dataOrNull, 1000);
      });

      test('should return 0 for non-existent account', () async {
        final Result<double> result = await repo.calculateBalance('non-existent');

        expect(result.dataOrNull, 0);
      });
    });
  });
}
