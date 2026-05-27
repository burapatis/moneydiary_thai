import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

/// ──────────────────────────────────────────────────
/// CategoryRepository — interface
/// ──────────────────────────────────────────────────
abstract interface class CategoryRepository {
  Future<Result<List<Category>>> getAll({bool includeHidden = false});

  Stream<List<Category>> watchAll({bool includeHidden = false});

  Future<Result<List<Category>>> getByType(
    CategoryType type, {
    bool includeHidden = false,
  });

  Stream<List<Category>> watchByType(
    CategoryType type, {
    bool includeHidden = false,
  });

  Future<Result<Category>> getById(String id);

  Future<Result<Category>> create(Category category);

  Future<Result<Category>> update(Category category);

  /// Hide หมวด default (ลบไม่ได้)
  Future<Result<void>> hide(String id);

  /// Unhide
  Future<Result<void>> unhide(String id);

  /// ลบ — เฉพาะ custom เท่านั้น
  Future<Result<void>> delete(String id);
}
