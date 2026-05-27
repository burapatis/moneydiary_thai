import 'package:drift/drift.dart';

/// ──────────────────────────────────────────────────
/// Categories Table — หมวดหมู่ (income/expense)
/// ──────────────────────────────────────────────────
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();

  /// ชื่อหมวดภาษาไทย (default)
  TextColumn get nameTh => text().withLength(min: 1, max: 60)();

  /// ชื่อหมวดภาษาอังกฤษ
  TextColumn get nameEn => text().withLength(min: 1, max: 60)();

  /// Icon (Material symbol name หรือ emoji)
  TextColumn get icon => text().withLength(max: 40)();

  /// Color hex string
  TextColumn get color => text().withLength(max: 16)();

  /// CategoryType: income | expense
  TextColumn get type => text().withLength(max: 16)();

  /// parent category id (nullable, Phase 2 ใช้สำหรับ sub-cat)
  TextColumn get parentId => text().nullable()();

  /// ลำดับการแสดง
  IntColumn get sortOrder => integer().withDefault(const Constant<int>(0))();

  /// หมวด default ของระบบ — ลบไม่ได้แต่ hide ได้
  BoolColumn get isDefault => boolean().withDefault(const Constant<bool>(false))();

  /// ผู้ใช้ซ่อนหมวดนี้
  BoolColumn get hidden => boolean().withDefault(const Constant<bool>(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
