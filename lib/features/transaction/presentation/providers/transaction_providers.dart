import 'package:flutter_riverpod/flutter_riverpod.dart';

// แก้ไข: เพิ่ม ../ อีก 1 ขั้น (รวมเป็น 4 ขั้น) เพราะอยู่ลึกใน
// lib/features/transaction/presentation/providers/
// ต้อง back กลับ providers → presentation → transaction → features → lib
import '../../../../core/utils/date_helpers.dart';
import '../../../../services/database/database_providers.dart';
import '../../../account/domain/entities/account.dart';
import '../../../category/domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

/// ──────────────────────────────────────────────────
/// Data Providers — Reactive streams สำหรับ UI
/// ──────────────────────────────────────────────────
/// UI จะ watch providers เหล่านี้ → auto-update เมื่อ DB เปลี่ยน
/// ──────────────────────────────────────────────────

// ═══════════════════════════════════════════════════
// ACCOUNTS
// ═══════════════════════════════════════════════════

/// Stream ของบัญชีทั้งหมด (ไม่รวม archived)
final StreamProvider<List<Account>> accountsStreamProvider =
    StreamProvider<List<Account>>((Ref ref) {
  return ref.watch(accountRepositoryProvider).watchAll();
});

// ═══════════════════════════════════════════════════
// CATEGORIES
// ═══════════════════════════════════════════════════

/// Stream ของหมวดทั้งหมด (ไม่รวม hidden)
final StreamProvider<List<Category>> categoriesStreamProvider =
    StreamProvider<List<Category>>((Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

/// Stream หมวดเฉพาะ expense (สำหรับ Quick-Add ตอนเลือก expense)
final StreamProvider<List<Category>> expenseCategoriesStreamProvider =
    StreamProvider<List<Category>>((Ref ref) {
  return ref
      .watch(categoryRepositoryProvider)
      .watchByType(CategoryType.expense);
});

/// Stream หมวดเฉพาะ income
final StreamProvider<List<Category>> incomeCategoriesStreamProvider =
    StreamProvider<List<Category>>((Ref ref) {
  return ref
      .watch(categoryRepositoryProvider)
      .watchByType(CategoryType.income);
});

// ═══════════════════════════════════════════════════
// TRANSACTIONS
// ═══════════════════════════════════════════════════

/// Stream ของ transactions ทั้งหมด
final StreamProvider<List<Transaction>> transactionsStreamProvider =
    StreamProvider<List<Transaction>>((Ref ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// Stream ของ transactions วันนี้
final StreamProvider<List<Transaction>> todayTransactionsStreamProvider =
    StreamProvider<List<Transaction>>((Ref ref) {
  final DateTime now = DateTime.now();
  return ref.watch(transactionRepositoryProvider).watchByDateRange(
        from: DateHelpers.startOfDay(now),
        to: DateHelpers.endOfDay(now),
      );
});

/// Stream ของ transactions เดือนนี้
final StreamProvider<List<Transaction>> thisMonthTransactionsStreamProvider =
    StreamProvider<List<Transaction>>((Ref ref) {
  final DateTime now = DateTime.now();
  return ref.watch(transactionRepositoryProvider).watchByDateRange(
        from: DateHelpers.startOfMonth(now),
        to: DateHelpers.endOfMonth(now),
      );
});

// ═══════════════════════════════════════════════════
// SUMMARIES (รายรับ-รายจ่ายรวม)
// ═══════════════════════════════════════════════════

/// สรุปวันนี้
final StreamProvider<TransactionSummary> todaySummaryStreamProvider =
    StreamProvider<TransactionSummary>((Ref ref) {
  final DateTime now = DateTime.now();
  return ref.watch(transactionRepositoryProvider).watchSummary(
        from: DateHelpers.startOfDay(now),
        to: DateHelpers.endOfDay(now),
      );
});

/// สรุปเดือนนี้
final StreamProvider<TransactionSummary> thisMonthSummaryStreamProvider =
    StreamProvider<TransactionSummary>((Ref ref) {
  final DateTime now = DateTime.now();
  return ref.watch(transactionRepositoryProvider).watchSummary(
        from: DateHelpers.startOfMonth(now),
        to: DateHelpers.endOfMonth(now),
      );
});
