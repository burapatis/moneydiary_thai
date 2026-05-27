import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/account_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';
import 'seeders/category_seeder.dart';
import 'tables/accounts_table.dart';
import 'tables/categories_table.dart';
import 'tables/transactions_table.dart';

// ไฟล์นี้ generate โดย drift_dev (ห้ามแก้ด้วยมือ)
// รัน: dart run build_runner build --delete-conflicting-outputs
part 'app_database.g.dart';

/// ──────────────────────────────────────────────────
/// AppDatabase — Main Drift database class
/// ──────────────────────────────────────────────────
/// ประกอบด้วย:
///   - 3 tables (Accounts, Categories, Transactions)
///   - 3 DAOs (data access objects)
///   - Migration logic
///   - Auto-seed default categories ครั้งแรก
///
/// Encryption: ใน Batch 2 นี้ยังไม่ encrypt — เปิดใน Batch 8
/// (sqlcipher จะเพิ่มเมื่อรอบ polish เพราะ test ง่ายกว่าตอนยังไม่ encrypt)
/// ──────────────────────────────────────────────────
@DriftDatabase(
  tables: <Type>[
    Accounts,
    Categories,
    Transactions,
  ],
  daos: <Type>[
    AccountDao,
    CategoryDao,
    TransactionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// ใช้ใน test เพื่อ inject in-memory DB
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          // สร้าง tables ทั้งหมด
          await m.createAll();

          // Seed default categories (25 หมวดไทย)
          await CategorySeeder.seed(this);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // จะใช้ตอน Phase 2 เมื่อเปลี่ยน schema
          // ตัวอย่าง:
          // if (from < 2) {
          //   await m.addColumn(transactions, transactions.tags);
          // }
        },
        beforeOpen: (OpeningDetails details) async {
          // เปิด foreign keys (drift ปิด default)
          await customStatement('PRAGMA foreign_keys = ON');

          // ตรวจสอบว่ามี default categories แล้วหรือยัง
          // กรณีถ้ามี user ที่ migrate มาจาก version เก่าแบบไม่มี seeder
          final int categoryCount = await categoryDao.count();
          if (categoryCount == 0) {
            await CategorySeeder.seed(this);
          }
        },
      );
}

/// เชื่อมต่อ DB จริง (production)
/// drift_flutter จัดการ path provider ให้อัตโนมัติ
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'moneydiary',
    native: const DriftNativeOptions(
      // databasePath ส่วนนี้จะใช้ default ที่ปลอดภัย (app documents dir)
    ),
  );
}
