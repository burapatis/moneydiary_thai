import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/transactions_table.dart';

part 'account_dao.g.dart';

/// ──────────────────────────────────────────────────
/// AccountDao — operations เกี่ยวกับ accounts
/// ──────────────────────────────────────────────────
@DriftAccessor(tables: <Type>[Accounts, Transactions])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  /// ดึงบัญชีทั้งหมดที่ไม่ archived (เรียงตาม sortOrder)
  Future<List<AccountRow>> getAll({bool includeArchived = false}) {
    final SimpleSelectStatement<$AccountsTable, AccountRow> query = select(accounts)
      ..orderBy(<OrderClauseGenerator<$AccountsTable>>[
        ($AccountsTable t) =>
            OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
        ($AccountsTable t) =>
            OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
      ]);

    if (!includeArchived) {
      query.where(($AccountsTable t) => t.archived.equals(false));
    }
    return query.get();
  }

  /// Stream ของ accounts — UI subscribe เพื่ออัปเดตอัตโนมัติ
  Stream<List<AccountRow>> watchAll({bool includeArchived = false}) {
    final SimpleSelectStatement<$AccountsTable, AccountRow> query = select(accounts)
      ..orderBy(<OrderClauseGenerator<$AccountsTable>>[
        ($AccountsTable t) =>
            OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
      ]);
    if (!includeArchived) {
      query.where(($AccountsTable t) => t.archived.equals(false));
    }
    return query.watch();
  }

  /// ดึงบัญชี 1 ตัวด้วย id (null ถ้าไม่พบ)
  Future<AccountRow?> getById(String id) {
    return (select(accounts)..where(($AccountsTable t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// สร้างบัญชีใหม่
  Future<int> insertAccount(AccountsCompanion entry) {
    return into(accounts).insert(entry);
  }

  /// อัปเดต — auto update updatedAt
  Future<bool> updateAccount(AccountsCompanion entry) {
    final AccountsCompanion withTimestamp = entry.copyWith(
      updatedAt: Value<DateTime>(DateTime.now()),
    );
    return update(accounts).replace(withTimestamp);
  }

  /// Archive (ไม่ลบจริง เพราะมี transactions อ้างอิง)
  Future<int> archive(String id) {
    return (update(accounts)..where(($AccountsTable t) => t.id.equals(id)))
        .write(
      AccountsCompanion(
        archived: const Value<bool>(true),
        updatedAt: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  /// ลบจริง — เฉพาะเมื่อไม่มี transactions
  /// Return: true หากลบสำเร็จ, false หากมี transactions ผูกอยู่
  Future<bool> deleteIfNoTransactions(String id) async {
    // count transactions
    final Expression<int> countExpr = transactions.id.count();
    final TypedResult result = await (selectOnly(transactions)
          ..addColumns(<Expression<Object>>[countExpr])
          ..where(transactions.accountId.equals(id)))
        .getSingle();

    final int? count = result.read(countExpr);
    if ((count ?? 0) > 0) {
      return false; // มี transactions ห้ามลบ
    }

    await (delete(accounts)..where(($AccountsTable t) => t.id.equals(id))).go();
    return true;
  }

  /// คำนวณยอดเงินบัญชี (initialBalance + sum of signed transactions)
  /// expense → ลบ, income → บวก
  Future<double> calculateBalance(String accountId) async {
    final AccountRow? account = await getById(accountId);
    if (account == null) return 0;

    // sum โดยใช้ CASE WHEN — type=income บวก, type=expense ลบ
    final Expression<double> signedSum = CustomExpression<double>(
      "COALESCE(SUM(CASE WHEN type = 'income' THEN amount WHEN type = 'expense' THEN -amount ELSE 0 END), 0)",
    );

    final TypedResult result = await (selectOnly(transactions)
          ..addColumns(<Expression<Object>>[signedSum])
          ..where(transactions.accountId.equals(accountId)))
        .getSingle();

    final double sumAmount = result.read(signedSum) ?? 0.0;
    return account.initialBalance + sumAmount;
  }

  /// นับจำนวน accounts
  Future<int> count() async {
    final Expression<int> countExpr = accounts.id.count();
    final TypedResult result = await (selectOnly(accounts)
          ..addColumns(<Expression<Object>>[countExpr]))
        .getSingle();
    return result.read(countExpr) ?? 0;
  }
}
