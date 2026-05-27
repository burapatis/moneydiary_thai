import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────────
/// IconResolver — แปลง icon name string เป็น IconData
/// ──────────────────────────────────────────────────
/// ใน database เก็บ icon เป็น string เช่น "restaurant", "local_cafe"
/// (เพื่อเลี่ยง dependency กับ Flutter ใน domain layer)
///
/// ที่นี่ map ไปเป็น Material IconData จริงตอน render UI
/// ──────────────────────────────────────────────────
abstract final class IconResolver {
  IconResolver._();

  /// Lookup table: icon name → IconData
  /// เพิ่มเข้าใหม่ตามต้องการ (ต้องตรงกับใน category_seeder.dart)
  static const Map<String, IconData> _map = <String, IconData>{
    // Expense icons
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'shopping_basket': Icons.shopping_basket,
    'directions_car': Icons.directions_car,
    'local_gas_station': Icons.local_gas_station,
    'home': Icons.home,
    'electric_bolt': Icons.electric_bolt,
    'phone_iphone': Icons.phone_iphone,
    'shopping_bag': Icons.shopping_bag,
    'checkroom': Icons.checkroom,
    'spa': Icons.spa,
    'movie': Icons.movie,
    'school': Icons.school,
    'medical_services': Icons.medical_services,
    'volunteer_activism': Icons.volunteer_activism,
    'pets': Icons.pets,
    'card_giftcard': Icons.card_giftcard,
    'category': Icons.category,
    // Income icons
    'work': Icons.work,
    'design_services': Icons.design_services,
    'storefront': Icons.storefront,
    'redeem': Icons.redeem,
    'trending_up': Icons.trending_up,
    'undo': Icons.undo,
    'attach_money': Icons.attach_money,
    // Account icons
    'wallet': Icons.account_balance_wallet,
    'account_balance': Icons.account_balance,
    'credit_card': Icons.credit_card,
    'savings': Icons.savings,
  };

  /// แปลง icon name → IconData
  /// ถ้าไม่เจอ → คืน Icons.category (fallback)
  static IconData resolve(String name) {
    return _map[name] ?? Icons.category;
  }

  /// ดึง icon names ทั้งหมด (สำหรับ icon picker ใน Batch 4)
  static List<String> get allNames => _map.keys.toList();
}

/// ──────────────────────────────────────────────────
/// ColorParser — แปลง hex string จาก DB → Color
/// ──────────────────────────────────────────────────
abstract final class ColorParser {
  ColorParser._();

  /// "0xFF10B981" → Color(0xFF10B981)
  static Color parse(String hex, {Color fallback = const Color(0xFF6B7280)}) {
    try {
      // รองรับทั้ง "0xFFRRGGBB" และ "#RRGGBB"
      String cleaned = hex.trim();
      if (cleaned.startsWith('#')) {
        cleaned = '0xFF${cleaned.substring(1)}';
      }
      return Color(int.parse(cleaned));
    } catch (_) {
      return fallback;
    }
  }
}
