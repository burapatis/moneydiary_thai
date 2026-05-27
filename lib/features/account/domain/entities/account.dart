import 'package:equatable/equatable.dart';

/// ──────────────────────────────────────────────────
/// Account Entity — บัญชี (เงินสด, K PLUS, SCB, ฯลฯ)
/// ──────────────────────────────────────────────────
/// Pure Dart class — ไม่พึ่ง Flutter หรือ drift
/// อยู่ใน domain layer ตาม Clean Architecture
/// ──────────────────────────────────────────────────

/// ประเภทบัญชี — ใช้สื่อรูปแบบและ icon default
enum AccountType {
  /// เงินสด
  cash,

  /// บัญชีธนาคาร (K PLUS, SCB Easy, ฯลฯ)
  bank,

  /// E-wallet (ทรู มันนี่, ShopeePay)
  ewallet,

  /// บัตรเครดิต
  credit,

  /// อื่นๆ
  other;

  /// แปลงจาก string (จาก DB) เป็น enum
  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (AccountType type) => type.name == value,
      orElse: () => AccountType.other,
    );
  }
}

/// Account entity — ตัว business object
class Account extends Equatable {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.initialBalance,
    required this.currency,
    required this.archived,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  /// UUID v4
  final String id;

  /// ชื่อบัญชีที่ผู้ใช้ตั้ง (เช่น "เงินสด", "K PLUS")
  final String name;

  /// ประเภทบัญชี
  final AccountType type;

  /// Icon code (Material Symbols name หรือ custom emoji)
  final String icon;

  /// สี (hex string เช่น "0xFF10B981")
  /// เก็บเป็น string เพื่อเลี่ยง dependency กับ Flutter ใน domain layer
  final String color;

  /// ยอดเงินเริ่มต้น (ยอดยกมา) — บวกกับ transactions = ยอดปัจจุบัน
  final double initialBalance;

  /// สกุลเงิน ISO 4217 (THB, USD, ...)
  final String currency;

  /// archived = ซ่อนจาก list หลัก แต่ไม่ลบเพราะมี transactions ผูกอยู่
  final bool archived;

  /// ลำดับการแสดงใน list (น้อย = บนสุด)
  final int sortOrder;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// คัดลอกพร้อมแก้บางฟิลด์ (immutable pattern)
  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? icon,
    String? color,
    double? initialBalance,
    String? currency,
    bool? archived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        type,
        icon,
        color,
        initialBalance,
        currency,
        archived,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
