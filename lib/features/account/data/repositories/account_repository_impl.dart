import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../services/database/app_database.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

/// ──────────────────────────────────────────────────
/// AccountRepositoryImpl — Drift implementation
/// ──────────────────────────────────────────────────
/// Bridge ระหว่าง:
///   - Drift AccountRow (DB layer)
///   - Account entity (Domain layer)
///
/// แปลงไป-มาผ่าน `_toEntity` และ `_toCompanion`
/// ──────────────────────────────────────────────────
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._db);

  final AppDatabase _db;
  static const Uuid _uuid = Uuid();

  @override
  Future<Result<List<Account>>> getAll({bool includeArchived = false}) async {
    try {
      final List<AccountRow> rows =
          await _db.accountDao.getAll(includeArchived: includeArchived);
      final List<Account> entities = rows.map(_toEntity).toList();
      return Result<List<Account>>.success(entities);
    } catch (e) {
      return Result<List<Account>>.failure(
        DatabaseFailure(message: 'ดึงบัญชีล้มเหลว: $e'),
      );
    }
  }

  @override
  Stream<List<Account>> watchAll({bool includeArchived = false}) {
    return _db.accountDao
        .watchAll(includeArchived: includeArchived)
        .map((List<AccountRow> rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<Account>> getById(String id) async {
    try {
      final AccountRow? row = await _db.accountDao.getById(id);
      if (row == null) {
        return Result<Account>.failure(
          NotFoundFailure(message: 'ไม่พบบัญชี', entity: 'Account'),
        );
      }
      return Result<Account>.success(_toEntity(row));
    } catch (e) {
      return Result<Account>.failure(
        DatabaseFailure(message: 'ดึงบัญชีล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<Account>> create(Account account) async {
    try {
      // ถ้า id ว่าง — generate
      final String id = account.id.isEmpty ? _uuid.v4() : account.id;
      final DateTime now = DateTime.now();
      final Account toSave = account.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
      );

      await _db.accountDao.insertAccount(_toCompanion(toSave, insert: true));
      return Result<Account>.success(toSave);
    } catch (e) {
      return Result<Account>.failure(
        DatabaseFailure(message: 'สร้างบัญชีล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<Account>> update(Account account) async {
    try {
      // ตรวจสอบว่ามีอยู่จริง
      final AccountRow? existing = await _db.accountDao.getById(account.id);
      if (existing == null) {
        return Result<Account>.failure(
          NotFoundFailure(message: 'ไม่พบบัญชี', entity: 'Account'),
        );
      }

      final Account updated = account.copyWith(updatedAt: DateTime.now());
      await _db.accountDao.updateAccount(_toCompanion(updated, insert: false));
      return Result<Account>.success(updated);
    } catch (e) {
      return Result<Account>.failure(
        DatabaseFailure(message: 'อัปเดตบัญชีล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<void>> archive(String id) async {
    try {
      await _db.accountDao.archive(id);
      return Result<void>.success(null);
    } catch (e) {
      return Result<void>.failure(
        DatabaseFailure(message: 'archive บัญชีล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final bool ok = await _db.accountDao.deleteIfNoTransactions(id);
      if (!ok) {
        return Result<void>.failure(
          const ValidationFailure(
            message: 'ลบบัญชีไม่ได้ เนื่องจากมีรายการธุรกรรมอยู่ — ใช้ archive แทน',
          ),
        );
      }
      return Result<void>.success(null);
    } catch (e) {
      return Result<void>.failure(
        DatabaseFailure(message: 'ลบบัญชีล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<double>> calculateBalance(String accountId) async {
    try {
      final double balance = await _db.accountDao.calculateBalance(accountId);
      return Result<double>.success(balance);
    } catch (e) {
      return Result<double>.failure(
        DatabaseFailure(message: 'คำนวณยอดล้มเหลว: $e'),
      );
    }
  }

  // ════════════════════════════════════════════════
  // MAPPERS
  // ════════════════════════════════════════════════

  /// AccountRow (drift) → Account (entity)
  Account _toEntity(AccountRow row) {
    return Account(
      id: row.id,
      name: row.name,
      type: AccountType.fromString(row.type),
      icon: row.icon,
      color: row.color,
      initialBalance: row.initialBalance,
      currency: row.currency,
      archived: row.archived,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Account (entity) → AccountsCompanion (drift insert/update)
  AccountsCompanion _toCompanion(Account a, {required bool insert}) {
    return AccountsCompanion(
      id: insert ? Value<String>(a.id) : Value<String>(a.id),
      name: Value<String>(a.name),
      type: Value<String>(a.type.name),
      icon: Value<String>(a.icon),
      color: Value<String>(a.color),
      initialBalance: Value<double>(a.initialBalance),
      currency: Value<String>(a.currency),
      archived: Value<bool>(a.archived),
      sortOrder: Value<int>(a.sortOrder),
      createdAt: Value<DateTime>(a.createdAt),
      updatedAt: Value<DateTime>(a.updatedAt),
    );
  }
}
