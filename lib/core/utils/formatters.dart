import 'package:intl/intl.dart';

/// ──────────────────────────────────────────────────
/// Formatters — ฟังก์ชันแปลงข้อมูลให้แสดงผลถูกต้อง
/// ──────────────────────────────────────────────────
abstract final class Formatters {
  Formatters._();

  /// ────────────────
  /// CURRENCY
  /// ────────────────
  /// format จำนวนเงินตามภาษา
  ///
  /// ตัวอย่าง:
  ///   formatCurrency(1234.5, 'th') => "1,234.50 ฿"
  ///   formatCurrency(1234.5, 'en') => "฿1,234.50"
  static String formatCurrency(
    double amount, {
    String locale = 'th_TH',
    String symbol = '฿',
    int decimals = 2,
  }) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimals,
    );
    return formatter.format(amount);
  }

  /// format จำนวนเงินแบบกระชับ (สำหรับ chart label)
  ///
  /// ตัวอย่าง:
  ///   formatCurrencyCompact(1500) => "1.5K"
  ///   formatCurrencyCompact(2500000) => "2.5M"
  static String formatCurrencyCompact(double amount, {String locale = 'th_TH'}) {
    final NumberFormat formatter = NumberFormat.compactCurrency(
      locale: locale,
      symbol: '฿',
      decimalDigits: 1,
    );
    return formatter.format(amount);
  }

  /// format ตัวเลขแบบไม่มี currency symbol
  static String formatNumber(num value, {int decimals = 0}) {
    return NumberFormat.decimalPatternDigits(
      locale: 'th_TH',
      decimalDigits: decimals,
    ).format(value);
  }

  /// ────────────────
  /// DATE / TIME
  /// ────────────────
  /// format วันที่เป็น "28 พ.ค. 2569" (พ.ศ. ตามวัฒนธรรมไทย)
  static String formatDateShortTh(DateTime date) {
    final DateFormat formatter = DateFormat('d MMM', 'th');
    final int yearBe = date.year + 543; // ค.ศ. → พ.ศ.
    return '${formatter.format(date)} ${yearBe.toString().substring(2)}';
  }

  /// format วันที่แบบยาว "28 พฤษภาคม 2569"
  static String formatDateLongTh(DateTime date) {
    final DateFormat formatter = DateFormat('d MMMM', 'th');
    final int yearBe = date.year + 543;
    return '${formatter.format(date)} $yearBe';
  }

  /// format วันที่แบบสากล "28/05/2026" หรือ "May 28, 2026"
  static String formatDate(DateTime date, {String locale = 'th'}) {
    if (locale == 'th') {
      return formatDateShortTh(date);
    }
    return DateFormat('MMM d, y', locale).format(date);
  }

  /// format เวลา "14:32"
  static String formatTime(DateTime time, {bool use24Hour = true}) {
    final DateFormat formatter =
        use24Hour ? DateFormat('HH:mm') : DateFormat('h:mm a');
    return formatter.format(time);
  }

  /// "วันนี้", "เมื่อวาน" หรือ format ปกติ (รองรับ th/en)
  static String formatRelativeDate(DateTime date, {String locale = 'th'}) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime target = DateTime(date.year, date.month, date.day);
    final int diffDays = target.difference(today).inDays;

    if (locale == 'en') {
      if (diffDays == 0) return 'Today';
      if (diffDays == -1) return 'Yesterday';
      if (diffDays == 1) return 'Tomorrow';
      if (diffDays > -7 && diffDays < 0) return '${diffDays.abs()} days ago';
      return formatDate(date, locale: 'en');
    }

    if (diffDays == 0) return 'วันนี้';
    if (diffDays == -1) return 'เมื่อวาน';
    if (diffDays == 1) return 'พรุ่งนี้';
    if (diffDays > -7 && diffDays < 0) {
      return '${diffDays.abs()} วันก่อน';
    }
    return formatDateShortTh(date);
  }

  /// @deprecated ใช้ formatRelativeDate แทน
  static String formatRelativeDateTh(DateTime date) =>
      formatRelativeDate(date, locale: 'th');

  /// format เดือน-ปี เช่น "พฤษภาคม 2569"
  static String formatMonthYearTh(DateTime date) {
    final DateFormat formatter = DateFormat('MMMM', 'th');
    final int yearBe = date.year + 543;
    return '${formatter.format(date)} $yearBe';
  }

  /// ────────────────
  /// PARSING
  /// ────────────────
  /// parse จำนวนเงินจาก string ที่อาจมี comma/space
  /// คืน null ถ้าผิดรูปแบบ
  static double? parseAmount(String input) {
    if (input.isEmpty) return null;
    final String cleaned = input
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('฿', '')
        .replaceAll('THB', '')
        .trim();
    return double.tryParse(cleaned);
  }
}
