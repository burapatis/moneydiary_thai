import 'package:equatable/equatable.dart';

/// ──────────────────────────────────────────────────
/// Transaction Entity — รายการธุรกรรม
/// ──────────────────────────────────────────────────

/// ประเภทธุรกรรม
enum TransactionType {
  /// รายรับ
  income,

  /// รายจ่าย
  expense,

  /// โอนระหว่างบัญชี (ใช้ใน Phase 2)
  transfer;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (TransactionType t) => t.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.transferToAccountId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// บัญชีต้นทาง
  final String accountId;

  /// หมวด (สำหรับ transfer = null ได้ใน Phase 2 — ใน MVP บังคับ)
  final String categoryId;

  /// จำนวนเงิน (positive เสมอ — type บอกทิศ)
  /// แม้รายจ่ายก็เก็บเป็น 100 ไม่ใช่ -100
  final double amount;

  /// income | expense | transfer
  final TransactionType type;

  /// วัน + เวลาของธุรกรรม (ผู้ใช้แก้ได้)
  final DateTime date;

  /// หมายเหตุ (free text, optional)
  final String? note;

  /// สำหรับ transfer เท่านั้น — บัญชีปลายทาง
  /// MVP ยังไม่ implement (Phase 2)
  final String? transferToAccountId;

  /// timestamp ระบบสร้าง
  final DateTime createdAt;

  /// timestamp ระบบแก้ครั้งล่าสุด
  final DateTime updatedAt;

  /// คำนวณว่าผลต่อยอดเงิน (signed amount)
  /// income → บวก, expense → ลบ
  double get signedAmount {
    switch (type) {
      case TransactionType.income:
        return amount;
      case TransactionType.expense:
        return -amount;
      case TransactionType.transfer:
        return 0; // โอนไม่กระทบยอดรวม (เงินยังอยู่)
    }
  }

  Transaction copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    double? amount,
    TransactionType? type,
    DateTime? date,
    String? note,
    String? transferToAccountId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      transferToAccountId: transferToAccountId ?? this.transferToAccountId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        accountId,
        categoryId,
        amount,
        type,
        date,
        note,
        transferToAccountId,
        createdAt,
        updatedAt,
      ];
}
