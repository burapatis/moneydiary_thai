import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

/// ──────────────────────────────────────────────────
/// TransactionDao — operations เกี่ยวกับ transactions
/// ──────────────────────────────────────────────────
/// ⚡ DAO นี้คือ "หัวใจ" ของแอป — query ที่ใช้บ่อยสุด
/// ──────────────────────────────────────────────────
@DriftAccessor(tables: <Type>[Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  /// ดึงทั้งหมด (latest first)
  Future<List<TransactionRow>> getAll() {
    return (select(transactions)
          ..orderBy(<OrderClauseGenerator<$TransactionsTable>>[
            ($TransactionsTable t) =>
                OrderingTerm(expression: t.date, mode: OrderingMode.desc),
            ($TransactionsTable t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Stream — UI subscribe เพื่ออัปเดตอัตโนมัติ
  Stream<List<TransactionRow>> watchAll() {
    return (select(transactions)
          ..orderBy(<OrderClauseGenerator<$TransactionsTable>>[
            ($TransactionsTable t) =>
                OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// ดึงในช่วงวันที่ (inclusive both ends)
  Future<List<TransactionRow>> getByDateRange({
    required DateTime from,
    required DateTime to,
  }) {
    return (select(transactions)
          ..where(($TransactionsTable t) =>
              t.date.isBiggerOrEqualValue(from) &
              t.date.isSmallerOrEqualValue(to))
          ..orderBy(<OrderClauseGenerator<$TransactionsTable>>[
            ($TransactionsTable t) =>
                OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Stream by date range — ใช้กับ Home (วันนี้/เดือนนี้)
  Stream<List<TransactionRow>> watchByDateRange({
    required DateTime from,
    required DateTime to,
  }) {
    return (select(transactions)
          ..where(($TransactionsTable t) =>
              t.date.isBiggerOrEqualValue(from) &
              t.date.isSmallerOrEqualValue(to))
          ..orderBy(<OrderClauseGenerator<$TransactionsTable>>[
            ($TransactionsTable t) =>
                OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// ดึง by id
  Future<TransactionRow?> getById(String id) {
    return (select(transactions)
          ..where(($TransactionsTable t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// ดึง transactions ของบัญชี (สำหรับ filter)
  Future<List<TransactionRow>> getByAccount(String accountId) {
    return (select(transactions)
          ..where(($TransactionsTable t) => t.accountId.equals(accountId))
          ..orderBy(<OrderClauseGenerator<$TransactionsTable>>[
            ($TransactionsTable t) =>
                OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// ดึง transactions ของหมวด
  Future<List<TransactionRow>> getByCategory(String categoryId) {
    return (select(transactions)
          ..where(($TransactionsTable t) => t.categoryId.equals(categoryId))
          ..orderBy(<OrderClauseGenerator<$TransactionsTable>>[
            ($TransactionsTable t) =>
                OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// สร้าง transaction
  Future<int> insertTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  /// อัปเดต — auto-update updatedAt
  Future<bool> updateTransaction(TransactionsCompanion entry) {
    final TransactionsCompanion withTs = entry.copyWith(
      updatedAt: Value<DateTime>(DateTime.now()),
    );
    return update(transactions).replace(withTs);
  }

  /// ลบ (hard delete — เพราะไม่มี FK pointing to transactions)
  Future<int> deleteTransaction(String id) {
    return (delete(transactions)
          ..where(($TransactionsTable t) => t.id.equals(id)))
        .go();
  }

  // ════════════════════════════════════════════════
  // AGGREGATIONS — สำหรับ Home + Reports
  // ════════════════════════════════════════════════

  /// คำนวณยอดรวม income/expense ในช่วงวันที่
  Future<({double income, double expense})> sumByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final Expression<double> incomeSum = CustomExpression<double>(
      "COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0)",
    );
    final Expression<double> expenseSum = CustomExpression<double>(
      "COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0)",
    );

    final TypedResult result = await (selectOnly(transactions)
          ..addColumns(<Expression<Object>>[incomeSum, expenseSum])
          ..where(transactions.date.isBiggerOrEqualValue(from) &
              transactions.date.isSmallerOrEqualValue(to)))
        .getSingle();

    return (
      income: result.read(incomeSum) ?? 0.0,
      expense: result.read(expenseSum) ?? 0.0,
    );
  }

  /// Stream of sums (สำหรับ home หน้าจอที่ live update)
  Stream<({double income, double expense})> watchSumByDateRange({
    required DateTime from,
    required DateTime to,
  }) {
    final Expression<double> incomeSum = CustomExpression<double>(
      "COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0)",
    );
    final Expression<double> expenseSum = CustomExpression<double>(
      "COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0)",
    );

    final query = selectOnly(transactions)
      ..addColumns(<Expression<Object>>[incomeSum, expenseSum])
      ..where(transactions.date.isBiggerOrEqualValue(from) &
          transactions.date.isSmallerOrEqualValue(to));

    return query.watchSingle().map((TypedResult result) {
      return (
        income: result.read(incomeSum) ?? 0.0,
        expense: result.read(expenseSum) ?? 0.0,
      );
    });
  }

  /// รวมยอดต่อหมวด (สำหรับ pie chart)
  Future<Map<String, double>> sumByCategory({
    required DateTime from,
    required DateTime to,
    String? type, // 'expense' หรือ 'income' หรือ null = ทั้งหมด
  }) async {
    final Expression<double> totalAmount = transactions.amount.sum();

    final query = selectOnly(transactions)
      ..addColumns(<Expression<Object>>[transactions.categoryId, totalAmount])
      ..where(transactions.date.isBiggerOrEqualValue(from) &
          transactions.date.isSmallerOrEqualValue(to))
      ..groupBy(<Expression<Object>>[transactions.categoryId]);

    if (type != null) {
      query.where(transactions.type.equals(type));
    }

    final List<TypedResult> rows = await query.get();
    final Map<String, double> result = <String, double>{};
    for (final TypedResult row in rows) {
      final String categoryId = row.read(transactions.categoryId)!;
      final double sum = row.read(totalAmount) ?? 0.0;
      result[categoryId] = sum;
    }
    return result;
  }

  /// นับจำนวน
  Future<int> count() async {
    final Expression<int> countExpr = transactions.id.count();
    final TypedResult result = await (selectOnly(transactions)
          ..addColumns(<Expression<Object>>[countExpr]))
        .getSingle();
    return result.read(countExpr) ?? 0;
  }
}
