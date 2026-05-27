/// ──────────────────────────────────────────────────
/// DateHelpers — ฟังก์ชันช่วยเกี่ยวกับวันที่
/// ──────────────────────────────────────────────────
abstract final class DateHelpers {
  DateHelpers._();

  /// คืนค่า start (00:00) ของวันนี้
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// คืนค่า end (23:59:59) ของวันนี้
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// คืนค่า start ของสัปดาห์ (วันจันทร์ 00:00)
  static DateTime startOfWeek(DateTime date) {
    final int daysSinceMonday = date.weekday - DateTime.monday;
    return startOfDay(date.subtract(Duration(days: daysSinceMonday)));
  }

  /// คืนค่า end ของสัปดาห์ (วันอาทิตย์ 23:59:59)
  static DateTime endOfWeek(DateTime date) {
    final DateTime mondayStart = startOfWeek(date);
    return endOfDay(mondayStart.add(const Duration(days: 6)));
  }

  /// คืนค่า start ของเดือน (วันที่ 1 00:00)
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// คืนค่า end ของเดือน (วันสุดท้าย 23:59:59)
  static DateTime endOfMonth(DateTime date) {
    final DateTime nextMonth = DateTime(date.year, date.month + 1);
    return endOfDay(nextMonth.subtract(const Duration(days: 1)));
  }

  /// คืนค่า start ของปี
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year);
  }

  /// คืนค่า end ของปี
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// เพิ่ม/ลดเดือนแบบปลอดภัย (handle เดือนสั้น)
  static DateTime addMonths(DateTime date, int months) {
    final int totalMonths = date.month - 1 + months;
    final int year = date.year + (totalMonths ~/ 12);
    final int month = (totalMonths % 12) + 1;
    // คุมไม่ให้ overflow วันที่ (เช่น 31 ม.ค. + 1 เดือน ≠ 31 ก.พ.)
    final int day = date.day;
    final int lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final int safeDay = day > lastDayOfTargetMonth ? lastDayOfTargetMonth : day;
    return DateTime(year, month, safeDay, date.hour, date.minute, date.second);
  }

  /// ตรวจสอบว่าเป็นวันเดียวกัน
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// ตรวจสอบว่าเป็นเดือนเดียวกัน
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  /// คำนวณจำนวนวันในเดือน
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
