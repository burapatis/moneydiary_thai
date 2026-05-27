import 'package:equatable/equatable.dart';

/// ──────────────────────────────────────────────────
/// Category Entity — หมวดหมู่ (อาหาร, ทำบุญ, นวด, ฯลฯ)
/// ──────────────────────────────────────────────────

/// ประเภทหมวด — รายรับ หรือ รายจ่าย
enum CategoryType {
  /// รายรับ
  income,

  /// รายจ่าย
  expense;

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (CategoryType t) => t.name == value,
      orElse: () => CategoryType.expense,
    );
  }
}

class Category extends Equatable {
  const Category({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.icon,
    required this.color,
    required this.type,
    this.parentId,
    required this.sortOrder,
    required this.isDefault,
    required this.hidden,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// ชื่อหมวดภาษาไทย (แสดงเป็น default ใน TH locale)
  final String nameTh;

  /// ชื่อหมวดภาษาอังกฤษ
  final String nameEn;

  /// Icon code
  final String icon;

  /// สี hex string
  final String color;

  /// income หรือ expense
  final CategoryType type;

  /// parent category id (null = root). ใช้ Phase 2 สำหรับ sub-categories
  final String? parentId;

  /// ลำดับการแสดง
  final int sortOrder;

  /// true = หมวด default ของระบบ (ลบไม่ได้ แต่ hide ได้)
  /// false = หมวด custom ของผู้ใช้
  final bool isDefault;

  /// ผู้ใช้ซ่อนหมวดนี้ (สำหรับ default ที่ลบไม่ได้)
  final bool hidden;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// ดึงชื่อตาม locale
  String displayName(String locale) {
    if (locale == 'en') return nameEn;
    return nameTh;
  }

  Category copyWith({
    String? id,
    String? nameTh,
    String? nameEn,
    String? icon,
    String? color,
    CategoryType? type,
    String? parentId,
    int? sortOrder,
    bool? isDefault,
    bool? hidden,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      nameTh: nameTh ?? this.nameTh,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      hidden: hidden ?? this.hidden,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        nameTh,
        nameEn,
        icon,
        color,
        type,
        parentId,
        sortOrder,
        isDefault,
        hidden,
        createdAt,
        updatedAt,
      ];
}
