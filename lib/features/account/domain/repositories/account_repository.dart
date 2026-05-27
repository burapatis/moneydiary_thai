import '../../../../core/errors/failures.dart';
import '../entities/account.dart';

/// ──────────────────────────────────────────────────
/// AccountRepository — interface ของ data layer
/// ──────────────────────────────────────────────────
/// Domain layer ใช้ interface นี้ — ไม่รู้จัก drift หรือ DB
/// Implementation อยู่ที่ data/repositories/account_repository_impl.dart
/// ──────────────────────────────────────────────────
abstract interface class AccountRepository {
  /// ดึงบัญชีทั้งหมด
  Future<Result<List<Account>>> getAll({bool includeArchived = false});

  /// Stream เพื่อ UI subscribe
  Stream<List<Account>> watchAll({bool includeArchived = false});

  /// ดึงบัญชี 1 ตัว
  Future<Result<Account>> getById(String id);

  /// สร้างบัญชีใหม่
  Future<Result<Account>> create(Account account);

  /// อัปเดต
  Future<Result<Account>> update(Account account);

  /// Archive
  Future<Result<void>> archive(String id);

  /// ลบจริง (เฉพาะถ้าไม่มี transactions)
  /// Return: success ถ้าลบสำเร็จ, failure ถ้ามี transactions ค้าง
  Future<Result<void>> delete(String id);

  /// คำนวณยอดเงินบัญชี
  Future<Result<double>> calculateBalance(String accountId);
}
