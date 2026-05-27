/// ──────────────────────────────────────────────────
/// Custom Exceptions — สำหรับ data layer
/// ──────────────────────────────────────────────────
/// throw ที่ data layer แล้ว catch + convert เป็น Failure ที่ repository
/// ──────────────────────────────────────────────────

class DatabaseException implements Exception {
  DatabaseException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'DatabaseException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

class CacheException implements Exception {
  CacheException(this.message);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class FileException implements Exception {
  FileException(this.message);
  final String message;

  @override
  String toString() => 'FileException: $message';
}
