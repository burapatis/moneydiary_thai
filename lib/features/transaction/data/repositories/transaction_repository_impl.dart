import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../services/database/app_database.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._db);

  final AppDatabase _db;
  static const Uuid _uuid = Uuid();

  @override
  Future<Result<List<Transaction>>> getAll() async {
    try {
      final List<TransactionRow> rows = await _db.transactionDao.getAll();
      return Result<List<Transaction>>.success(rows.map(_toEntity).toList());
    } catch (e) {
      return Result<List<Transaction>>.failure(
        DatabaseFailure(message: 'ดึงรายการล้มเหลว: $e'),
      );
    }
  }

  @override
  Stream<List<Transaction>> watchAll() {
    return _db.transactionDao
        .watchAll()
        .map((List<TransactionRow> rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<List<Transaction>>> getByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final List<TransactionRow> rows =
          await _db.transactionDao.getByDateRange(from: from, to: to);
      return Result<List<Transaction>>.success(rows.map(_toEntity).toList());
    } catch (e) {
      return Result<List<Transaction>>.failure(
        DatabaseFailure(message: 'ดึงรายการล้มเหลว: $e'),
      );
    }
  }

  @override
  Stream<List<Transaction>> watchByDateRange({
    required DateTime from,
    required DateTime to,
  }) {
    return _db.transactionDao
        .watchByDateRange(from: from, to: to)
        .map((List<TransactionRow> rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<Transaction>> getById(String id) async {
    try {
      final TransactionRow? row = await _db.transactionDao.getById(id);
      if (row == null) {
        return Result<Transaction>.failure(
          NotFoundFailure(message: 'ไม่พบรายการ', entity: 'Transaction'),
        );
      }
      return Result<Transaction>.success(_toEntity(row));
    } catch (e) {
      return Result<Transaction>.failure(
        DatabaseFailure(message: 'ดึงรายการล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<Transaction>> create(Transaction transaction) async {
    // ── Validation ──
    if (transaction.amount <= 0) {
      return Result<Transaction>.failure(
        const ValidationFailure(
          message: 'จำนวนเงินต้องมากกว่า 0',
          field: 'amount',
        ),
      );
    }
    if (transaction.accountId.isEmpty) {
      return Result<Transaction>.failure(
        const ValidationFailure(
          message: 'ต้องเลือกบัญชี',
          field: 'accountId',
        ),
      );
    }
    if (transaction.categoryId.isEmpty) {
      return Result<Transaction>.failure(
        const ValidationFailure(
          message: 'ต้องเลือกหมวด',
          field: 'categoryId',
        ),
      );
    }

    try {
      final String id =
          transaction.id.isEmpty ? _uuid.v4() : transaction.id;
      final DateTime now = DateTime.now();
      final Transaction toSave = transaction.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
      );

      await _db.transactionDao
          .insertTransaction(_toCompanion(toSave, insert: true));
      return Result<Transaction>.success(toSave);
    } catch (e) {
      return Result<Transaction>.failure(
        DatabaseFailure(message: 'บันทึกรายการล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<Transaction>> update(Transaction transaction) async {
    if (transaction.amount <= 0) {
      return Result<Transaction>.failure(
        const ValidationFailure(
          message: 'จำนวนเงินต้องมากกว่า 0',
          field: 'amount',
        ),
      );
    }

    try {
      final TransactionRow? existing =
          await _db.transactionDao.getById(transaction.id);
      if (existing == null) {
        return Result<Transaction>.failure(
          NotFoundFailure(message: 'ไม่พบรายการ', entity: 'Transaction'),
        );
      }
      final Transaction updated =
          transaction.copyWith(updatedAt: DateTime.now());
      await _db.transactionDao
          .updateTransaction(_toCompanion(updated, insert: false));
      return Result<Transaction>.success(updated);
    } catch (e) {
      return Result<Transaction>.failure(
        DatabaseFailure(message: 'อัปเดตรายการล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final int deleted = await _db.transactionDao.deleteTransaction(id);
      if (deleted == 0) {
        return Result<void>.failure(
          NotFoundFailure(message: 'ไม่พบรายการ', entity: 'Transaction'),
        );
      }
      return Result<void>.success(null);
    } catch (e) {
      return Result<void>.failure(
        DatabaseFailure(message: 'ลบรายการล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<TransactionSummary>> getSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final ({double income, double expense}) sums =
          await _db.transactionDao.sumByDateRange(from: from, to: to);
      return Result<TransactionSummary>.success(
        TransactionSummary(income: sums.income, expense: sums.expense),
      );
    } catch (e) {
      return Result<TransactionSummary>.failure(
        DatabaseFailure(message: 'คำนวณสรุปล้มเหลว: $e'),
      );
    }
  }

  @override
  Stream<TransactionSummary> watchSummary({
    required DateTime from,
    required DateTime to,
  }) {
    return _db.transactionDao
        .watchSumByDateRange(from: from, to: to)
        .map((({double income, double expense}) sums) {
      return TransactionSummary(income: sums.income, expense: sums.expense);
    });
  }

  @override
  Future<Result<Map<String, double>>> sumByCategory({
    required DateTime from,
    required DateTime to,
    TransactionType? type,
  }) async {
    try {
      final Map<String, double> result = await _db.transactionDao.sumByCategory(
        from: from,
        to: to,
        type: type?.name,
      );
      return Result<Map<String, double>>.success(result);
    } catch (e) {
      return Result<Map<String, double>>.failure(
        DatabaseFailure(message: 'คำนวณตามหมวดล้มเหลว: $e'),
      );
    }
  }

  // ════════════════════════════════════════════════
  // MAPPERS
  // ════════════════════════════════════════════════
  Transaction _toEntity(TransactionRow row) {
    return Transaction(
      id: row.id,
      accountId: row.accountId,
      categoryId: row.categoryId,
      amount: row.amount,
      type: TransactionType.fromString(row.type),
      date: row.date,
      note: row.note,
      transferToAccountId: row.transferToAccountId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  TransactionsCompanion _toCompanion(Transaction t, {required bool insert}) {
    return TransactionsCompanion(
      id: Value<String>(t.id),
      accountId: Value<String>(t.accountId),
      categoryId: Value<String>(t.categoryId),
      amount: Value<double>(t.amount),
      type: Value<String>(t.type.name),
      date: Value<DateTime>(t.date),
      note: Value<String?>(t.note),
      transferToAccountId: Value<String?>(t.transferToAccountId),
      createdAt: Value<DateTime>(t.createdAt),
      updatedAt: Value<DateTime>(t.updatedAt),
    );
  }
}
