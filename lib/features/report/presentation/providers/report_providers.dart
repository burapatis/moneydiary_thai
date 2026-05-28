import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_helpers.dart';
import '../../../category/domain/entities/category.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../../../services/database/database_providers.dart';
import '../../domain/entities/report_summary.dart';

/// ──────────────────────────────────────────────────
/// Report Providers
/// ──────────────────────────────────────────────────

/// ช่วงเวลาที่เลือก (day/week/month/year)
class ReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.month;

  void setPeriod(ReportPeriod period) => state = period;
}

final NotifierProvider<ReportPeriodNotifier, ReportPeriod>
    reportPeriodProvider =
    NotifierProvider<ReportPeriodNotifier, ReportPeriod>(
        ReportPeriodNotifier.new);

/// วันที่อ้างอิง (anchor) — ใช้เลื่อนเดือน/ปี
/// เช่น ถ้า period=month, anchorDate ชี้ที่เดือนไหน
class ReportAnchorNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  /// เลื่อนไปก่อนหน้า (เดือน/ปี ก่อน)
  void previous() {
    final ReportPeriod period = ref.read(reportPeriodProvider);
    state = switch (period) {
      ReportPeriod.day => state.subtract(const Duration(days: 1)),
      ReportPeriod.week => state.subtract(const Duration(days: 7)),
      ReportPeriod.month => DateHelpers.addMonths(state, -1),
      ReportPeriod.year => DateTime(state.year - 1, state.month, state.day),
    };
  }

  /// เลื่อนไปถัดไป
  void next() {
    final ReportPeriod period = ref.read(reportPeriodProvider);
    state = switch (period) {
      ReportPeriod.day => state.add(const Duration(days: 1)),
      ReportPeriod.week => state.add(const Duration(days: 7)),
      ReportPeriod.month => DateHelpers.addMonths(state, 1),
      ReportPeriod.year => DateTime(state.year + 1, state.month, state.day),
    };
  }

  /// กลับมาวันนี้
  void reset() => state = DateTime.now();
}

final NotifierProvider<ReportAnchorNotifier, DateTime> reportAnchorProvider =
    NotifierProvider<ReportAnchorNotifier, DateTime>(ReportAnchorNotifier.new);

/// คำนวณช่วง from-to จาก period + anchor
({DateTime from, DateTime to}) _calculateRange(
  ReportPeriod period,
  DateTime anchor,
) {
  return switch (period) {
    ReportPeriod.day => (
        from: DateHelpers.startOfDay(anchor),
        to: DateHelpers.endOfDay(anchor),
      ),
    ReportPeriod.week => (
        from: DateHelpers.startOfWeek(anchor),
        to: DateHelpers.endOfWeek(anchor),
      ),
    ReportPeriod.month => (
        from: DateHelpers.startOfMonth(anchor),
        to: DateHelpers.endOfMonth(anchor),
      ),
    ReportPeriod.year => (
        from: DateHelpers.startOfYear(anchor),
        to: DateHelpers.endOfYear(anchor),
      ),
  };
}

/// Provider หลัก — คำนวณ ReportSummary จาก period + anchor + transactions
final FutureProvider<ReportSummary> reportSummaryProvider =
    FutureProvider<ReportSummary>((Ref ref) async {
  final ReportPeriod period = ref.watch(reportPeriodProvider);
  final DateTime anchor = ref.watch(reportAnchorProvider);

  // Re-compute เมื่อ transactions เปลี่ยน
  ref.watch(transactionsStreamProvider);

  final ({DateTime from, DateTime to}) range =
      _calculateRange(period, anchor);

  final TransactionRepository txRepo =
      ref.read(transactionRepositoryProvider);

  // 1. ดึง summary (income/expense รวม)
  final summaryResult = await txRepo.getSummary(
    from: range.from,
    to: range.to,
  );
  final TransactionSummary summary =
      summaryResult.dataOrNull ?? TransactionSummary.zero;

  // 2. ดึงรายจ่ายแยกตามหมวด (สำหรับ pie chart)
  final categorySumResult = await txRepo.sumByCategory(
    from: range.from,
    to: range.to,
    type: TransactionType.expense,
  );
  final Map<String, double> categorySums =
      categorySumResult.dataOrNull ?? <String, double>{};

  // 3. ดึง transactions ในช่วง (นับจำนวน + count ต่อหมวด)
  final txResult = await txRepo.getByDateRange(
    from: range.from,
    to: range.to,
  );
  final List<Transaction> txs = txResult.dataOrNull ?? <Transaction>[];

  // นับ transactions ต่อหมวด
  final Map<String, int> categoryCounts = <String, int>{};
  for (final Transaction tx in txs) {
    if (tx.type == TransactionType.expense) {
      categoryCounts[tx.categoryId] =
          (categoryCounts[tx.categoryId] ?? 0) + 1;
    }
  }

  // 4. ดึงข้อมูล category เพื่อ map id → entity
  final categoriesResult = await ref
      .read(categoryRepositoryProvider)
      .getAll(includeHidden: true);
  final List<Category> categories =
      categoriesResult.dataOrNull ?? <Category>[];
  final Map<String, Category> categoryMap = <String, Category>{
    for (final Category c in categories) c.id: c,
  };

  // 5. สร้าง CategorySpending list (เรียงมาก→น้อย)
  final double totalExpense = summary.expense;
  final List<CategorySpending> spendings = <CategorySpending>[];
  categorySums.forEach((String categoryId, double amount) {
    final Category? category = categoryMap[categoryId];
    if (category != null && amount > 0) {
      spendings.add(CategorySpending(
        category: category,
        amount: amount,
        percentage: totalExpense > 0 ? (amount / totalExpense) * 100 : 0,
        transactionCount: categoryCounts[categoryId] ?? 0,
      ));
    }
  });
  spendings.sort((CategorySpending a, CategorySpending b) =>
      b.amount.compareTo(a.amount));

  return ReportSummary(
    period: period,
    from: range.from,
    to: range.to,
    totalIncome: summary.income,
    totalExpense: summary.expense,
    categorySpendings: spendings,
    transactionCount: txs.length,
  );
});

/// Provider เปรียบเทียบกับช่วงก่อนหน้า (สำหรับ insight)
final FutureProvider<double> previousPeriodExpenseProvider =
    FutureProvider<double>((Ref ref) async {
  final ReportPeriod period = ref.watch(reportPeriodProvider);
  final DateTime anchor = ref.watch(reportAnchorProvider);
  ref.watch(transactionsStreamProvider);

  // คำนวณช่วงก่อนหน้า
  final DateTime prevAnchor = switch (period) {
    ReportPeriod.day => anchor.subtract(const Duration(days: 1)),
    ReportPeriod.week => anchor.subtract(const Duration(days: 7)),
    ReportPeriod.month => DateHelpers.addMonths(anchor, -1),
    ReportPeriod.year => DateTime(anchor.year - 1, anchor.month, anchor.day),
  };
  final ({DateTime from, DateTime to}) range =
      _calculateRange(period, prevAnchor);

  final summaryResult = await ref
      .read(transactionRepositoryProvider)
      .getSummary(from: range.from, to: range.to);
  return summaryResult.dataOrNull?.expense ?? 0;
});
