import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/account_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';
import 'seeders/account_seeder.dart';
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
          await m.createAll();
          // Seed default data: 25 categories + 1 cash account
          await CategorySeeder.seed(this);
          await AccountSeeder.seedIfEmpty(this);
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Phase 2 — schema migrations จะใส่ที่นี่
        },
        beforeOpen: (OpeningDetails details) async {
          // เปิด foreign keys (drift ปิด default)
          await customStatement('PRAGMA foreign_keys = ON');

          // Safety net — ถ้าด้วยเหตุผลใดก็ตาม seed ไม่ทำงานตอน onCreate
          final int categoryCount = await categoryDao.count();
          if (categoryCount == 0) {
            await CategorySeeder.seed(this);
          }
          await AccountSeeder.seedIfEmpty(this);
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'moneydiary',
    native: const DriftNativeOptions(),
  );
}
