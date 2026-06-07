import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

/// ──────────────────────────────────────────────────
/// AccountSeeder — สร้างบัญชี "เงินสด" default
/// ──────────────────────────────────────────────────
/// เรียกครั้งแรกที่เปิดแอป — ถ้ายังไม่มีบัญชีเลย
/// จะสร้าง "เงินสด" 1 บัญชี เพื่อให้ user สามารถเริ่มจดได้ทันที
/// (ลด friction — ไม่ต้องสร้างบัญชีก่อนจด)
/// ──────────────────────────────────────────────────
abstract final class AccountSeeder {
  AccountSeeder._();

  static const Uuid _uuid = Uuid();

  /// Seed default account ถ้ายังไม่มี
  static Future<void> seedIfEmpty(AppDatabase db) async {
    final int count = await db.accountDao.count();
    if (count > 0) return; // มีแล้ว skip

    final DateTime now = DateTime.now();
    await db.into(db.accounts).insert(
          AccountsCompanion.insert(
            id: _uuid.v4(),
            name: 'เงินสด',
            type: 'cash',
            icon: 'wallet',
            color: '0xFF10B981', // emerald
            initialBalance: const Value<double>(0.0),
            currency: const Value<String>('THB'),
            sortOrder: const Value<int>(0),
            createdAt: Value<DateTime>(now),
            updatedAt: Value<DateTime>(now),
          ),
        );
  }
}
