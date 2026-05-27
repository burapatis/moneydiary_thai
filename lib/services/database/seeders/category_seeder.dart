import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

/// ──────────────────────────────────────────────────
/// CategorySeeder — ใส่หมวด default 25 หมวด
/// ──────────────────────────────────────────────────
/// อ้างอิงจาก docs/02_ARCHITECTURE.md §4.2
///
/// **18 หมวดรายจ่าย:**
/// อาหาร, กาแฟ-ขนม, ตลาด, เดินทาง, น้ำมัน, ค่าบ้าน,
/// ค่าน้ำ-ค่าไฟ, โทรศัพท์, ช้อปปิ้ง, เสื้อผ้า, นวด-สปา,
/// บันเทิง, การศึกษา, สุขภาพ, ทำบุญ, สัตว์เลี้ยง, ของขวัญ, อื่นๆ
///
/// **7 หมวดรายรับ:**
/// เงินเดือน, ฟรีแลนซ์, ขายของ, ของขวัญรับ, ดอกเบี้ย, คืนเงิน, อื่นๆ
/// ──────────────────────────────────────────────────
abstract final class CategorySeeder {
  CategorySeeder._();

  static const Uuid _uuid = Uuid();

  /// Seed default categories ลง database
  /// เรียกครั้งเดียวตอน app เปิดครั้งแรก (ใน migration onCreate)
  static Future<void> seed(AppDatabase db) async {
    final DateTime now = DateTime.now();
    int sortOrder = 0;

    // ════════════════════════════════════════════
    // EXPENSE CATEGORIES (รายจ่าย) - 18 หมวด
    // ════════════════════════════════════════════
    final List<_CategoryData> expenses = <_CategoryData>[
      _CategoryData(
        nameTh: 'อาหาร',
        nameEn: 'Food',
        icon: 'restaurant',
        color: '0xFFEF4444', // red
      ),
      _CategoryData(
        nameTh: 'กาแฟ-ขนม',
        nameEn: 'Coffee & Snacks',
        icon: 'local_cafe',
        color: '0xFFF97316', // orange
      ),
      _CategoryData(
        nameTh: 'ตลาดสด-ของชำ',
        nameEn: 'Groceries',
        icon: 'shopping_basket',
        color: '0xFFF59E0B', // amber
      ),
      _CategoryData(
        nameTh: 'เดินทาง',
        nameEn: 'Transport',
        icon: 'directions_car',
        color: '0xFF3B82F6', // blue
      ),
      _CategoryData(
        nameTh: 'น้ำมัน',
        nameEn: 'Fuel',
        icon: 'local_gas_station',
        color: '0xFF06B6D4', // cyan
      ),
      _CategoryData(
        nameTh: 'ค่าบ้าน-ค่าเช่า',
        nameEn: 'Rent',
        icon: 'home',
        color: '0xFF8B5CF6', // violet
      ),
      _CategoryData(
        nameTh: 'ค่าน้ำ-ค่าไฟ-เน็ต',
        nameEn: 'Utilities',
        icon: 'electric_bolt',
        color: '0xFFEAB308', // yellow
      ),
      _CategoryData(
        nameTh: 'ค่าโทรศัพท์-แพ็กเกจ',
        nameEn: 'Mobile',
        icon: 'phone_iphone',
        color: '0xFF14B8A6', // teal
      ),
      _CategoryData(
        nameTh: 'ช้อปปิ้ง',
        nameEn: 'Shopping',
        icon: 'shopping_bag',
        color: '0xFFEC4899', // pink
      ),
      _CategoryData(
        nameTh: 'เสื้อผ้า-เครื่องสำอาง',
        nameEn: 'Clothing & Beauty',
        icon: 'checkroom',
        color: '0xFFEC4899',
      ),
      _CategoryData(
        nameTh: 'นวด-สปา',
        nameEn: 'Spa & Massage',
        icon: 'spa',
        color: '0xFF10B981', // emerald
      ),
      _CategoryData(
        nameTh: 'บันเทิง',
        nameEn: 'Entertainment',
        icon: 'movie',
        color: '0xFF8B5CF6',
      ),
      _CategoryData(
        nameTh: 'การศึกษา-คอร์ส',
        nameEn: 'Education',
        icon: 'school',
        color: '0xFF3B82F6',
      ),
      _CategoryData(
        nameTh: 'สุขภาพ-ยา',
        nameEn: 'Health',
        icon: 'medical_services',
        color: '0xFFEF4444',
      ),
      _CategoryData(
        nameTh: 'ทำบุญ-บริจาค',
        nameEn: 'Donation',
        icon: 'volunteer_activism',
        color: '0xFFF59E0B',
      ),
      _CategoryData(
        nameTh: 'สัตว์เลี้ยง',
        nameEn: 'Pet',
        icon: 'pets',
        color: '0xFF84CC16', // lime
      ),
      _CategoryData(
        nameTh: 'ของขวัญ-ซองงาน',
        nameEn: 'Gifts & Ceremonies',
        icon: 'card_giftcard',
        color: '0xFFEC4899',
      ),
      _CategoryData(
        nameTh: 'อื่นๆ',
        nameEn: 'Misc',
        icon: 'category',
        color: '0xFF6B7280', // gray
      ),
    ];

    for (final _CategoryData c in expenses) {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: _uuid.v4(),
              nameTh: c.nameTh,
              nameEn: c.nameEn,
              icon: c.icon,
              color: c.color,
              type: 'expense',
              sortOrder: Value<int>(sortOrder++),
              isDefault: const Value<bool>(true),
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );
    }

    // ════════════════════════════════════════════
    // INCOME CATEGORIES (รายรับ) - 7 หมวด
    // ════════════════════════════════════════════
    final List<_CategoryData> incomes = <_CategoryData>[
      _CategoryData(
        nameTh: 'เงินเดือน',
        nameEn: 'Salary',
        icon: 'work',
        color: '0xFF10B981',
      ),
      _CategoryData(
        nameTh: 'งานเสริม-ฟรีแลนซ์',
        nameEn: 'Freelance',
        icon: 'design_services',
        color: '0xFF14B8A6',
      ),
      _CategoryData(
        nameTh: 'ขายของ',
        nameEn: 'Sales',
        icon: 'storefront',
        color: '0xFF06B6D4',
      ),
      _CategoryData(
        nameTh: 'ของขวัญ-โอนรับ',
        nameEn: 'Gift Received',
        icon: 'redeem',
        color: '0xFFEC4899',
      ),
      _CategoryData(
        nameTh: 'ดอกเบี้ย-ปันผล',
        nameEn: 'Interest',
        icon: 'trending_up',
        color: '0xFF22C55E',
      ),
      _CategoryData(
        nameTh: 'คืนเงิน',
        nameEn: 'Refund',
        icon: 'undo',
        color: '0xFF3B82F6',
      ),
      _CategoryData(
        nameTh: 'อื่นๆ',
        nameEn: 'Misc Income',
        icon: 'attach_money',
        color: '0xFF6B7280',
      ),
    ];

    // เริ่ม sortOrder ใหม่สำหรับ income
    int incomeSortOrder = 0;
    for (final _CategoryData c in incomes) {
      await db.into(db.categories).insert(
            CategoriesCompanion.insert(
              id: _uuid.v4(),
              nameTh: c.nameTh,
              nameEn: c.nameEn,
              icon: c.icon,
              color: c.color,
              type: 'income',
              sortOrder: Value<int>(incomeSortOrder++),
              isDefault: const Value<bool>(true),
              createdAt: Value<DateTime>(now),
              updatedAt: Value<DateTime>(now),
            ),
          );
    }
  }
}

/// Helper class — ใช้ภายในไฟล์นี้เท่านั้น
class _CategoryData {
  _CategoryData({
    required this.nameTh,
    required this.nameEn,
    required this.icon,
    required this.color,
  });

  final String nameTh;
  final String nameEn;
  final String icon;
  final String color;
}
