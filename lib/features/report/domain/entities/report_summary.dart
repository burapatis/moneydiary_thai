import 'package:equatable/equatable.dart';

import '../../../category/domain/entities/category.dart';

/// ──────────────────────────────────────────────────
/// Report Entities — โครงสร้างข้อมูลสำหรับ charts + insights
/// ──────────────────────────────────────────────────

/// ช่วงเวลาของรายงาน
enum ReportPeriod {
  day,
  week,
  month,
  year;

  String get labelTh {
    switch (this) {
      case ReportPeriod.day:
        return 'วัน';
      case ReportPeriod.week:
        return 'สัปดาห์';
      case ReportPeriod.month:
        return 'เดือน';
      case ReportPeriod.year:
        return 'ปี';
    }
  }
}

/// ข้อมูล 1 ชิ้นใน pie chart (รายจ่ายต่อหมวด)
class CategorySpending extends Equatable {
  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  final Category category;
  final double amount;

  /// สัดส่วน % ของยอดรวม (0-100)
  final double percentage;

  /// จำนวน transactions ในหมวดนี้
  final int transactionCount;

  @override
  List<Object?> get props =>
      <Object?>[category, amount, percentage, transactionCount];
}

/// สรุปรายงานของช่วงเวลาหนึ่ง
class ReportSummary extends Equatable {
  const ReportSummary({
    required this.period,
    required this.from,
    required this.to,
    required this.totalIncome,
    required this.totalExpense,
    required this.categorySpendings,
    required this.transactionCount,
  });

  final ReportPeriod period;
  final DateTime from;
  final DateTime to;
  final double totalIncome;
  final double totalExpense;

  /// รายจ่ายแยกตามหมวด (เรียงมาก→น้อย) สำหรับ pie chart
  final List<CategorySpending> categorySpendings;

  final int transactionCount;

  double get net => totalIncome - totalExpense;

  /// อัตราการออม (savings rate) % — income ที่เหลือ
  double get savingsRate {
    if (totalIncome == 0) return 0;
    return (net / totalIncome) * 100;
  }

  /// รายจ่ายเฉลี่ยต่อวัน
  double get avgExpensePerDay {
    final int days = to.difference(from).inDays + 1;
    if (days == 0) return 0;
    return totalExpense / days;
  }

  static final ReportSummary empty = ReportSummary(
    period: ReportPeriod.month,
    from: DateTime.now(),
    to: DateTime.now(),
    totalIncome: 0,
    totalExpense: 0,
    categorySpendings: const <CategorySpending>[],
    transactionCount: 0,
  );

  @override
  List<Object?> get props => <Object?>[
        period,
        from,
        to,
        totalIncome,
        totalExpense,
        categorySpendings,
        transactionCount,
      ];
}
