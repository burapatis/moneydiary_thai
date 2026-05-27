import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:moneydiary_thai/services/database/app_database.dart';

/// ──────────────────────────────────────────────────
/// Test Database Helper
/// ──────────────────────────────────────────────────
/// สร้าง AppDatabase ที่ใช้ in-memory SQLite สำหรับ test
/// - เร็วกว่า file-based
/// - ไม่ persist หลัง test จบ
/// - แต่ละ test แยกกัน clean
/// ──────────────────────────────────────────────────

AppDatabase createTestDatabase() {
  // NativeDatabase.memory() = SQLite in RAM
  final QueryExecutor executor = NativeDatabase.memory();
  return AppDatabase.forTesting(executor);
}
