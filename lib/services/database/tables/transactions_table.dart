import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

/// ──────────────────────────────────────────────────
/// Transactions Table — รายการธุรกรรม (หัวใจของแอป)
/// ──────────────────────────────────────────────────
@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();

  /// FK → accounts.id
  /// onDelete: ห้ามลบบัญชีที่มี transactions (archive แทน)
  TextColumn get accountId => text().references(Accounts, #id)();

  /// FK → categories.id
  TextColumn get categoryId => text().references(Categories, #id)();

  /// จำนวนเงิน (positive เสมอ — type บอกทิศ)
  RealColumn get amount => real()();

  /// income | expense | transfer
  TextColumn get type => text().withLength(max: 16)();

  /// วัน + เวลาของธุรกรรม
  DateTimeColumn get date => dateTime()();

  /// หมายเหตุ
  TextColumn get note => text().withLength(max: 500).nullable()();

  /// สำหรับ transfer
  TextColumn get transferToAccountId => text().nullable().references(Accounts, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
