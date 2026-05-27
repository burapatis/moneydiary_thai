import 'package:drift/drift.dart';

/// ──────────────────────────────────────────────────
/// Accounts Table — บัญชีของผู้ใช้
/// ──────────────────────────────────────────────────
/// อ้างอิง schema จาก docs/02_ARCHITECTURE.md §4.1
/// ──────────────────────────────────────────────────
@DataClassName('AccountRow')
class Accounts extends Table {
  /// UUID v4 (string, ไม่ใช่ autoincrement) — สำหรับรองรับ sync ใน Phase 2
  TextColumn get id => text()();

  /// ชื่อบัญชี (max 60 chars)
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// AccountType enum stored as string (cash|bank|ewallet|credit|other)
  TextColumn get type => text().withLength(max: 16)();

  /// Material icon name หรือ emoji
  TextColumn get icon => text().withLength(max: 40)();

  /// Hex color e.g. "0xFF10B981"
  TextColumn get color => text().withLength(max: 16)();

  /// ยอดเริ่มต้น
  RealColumn get initialBalance => real().withDefault(const Constant<double>(0.0))();

  /// ISO 4217
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant<String>('THB'))();

  /// archived = ซ่อนแต่ไม่ลบ
  BoolColumn get archived => boolean().withDefault(const Constant<bool>(false))();

  /// ลำดับการแสดง (น้อย = บน)
  IntColumn get sortOrder => integer().withDefault(const Constant<int>(0))();

  /// timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
