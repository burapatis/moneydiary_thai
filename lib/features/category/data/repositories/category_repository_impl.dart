import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../../../services/database/app_database.dart';
import '../../../../services/database/tables/categories_table.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._db);

  final AppDatabase _db;
  static const Uuid _uuid = Uuid();

  @override
  Future<Result<List<Category>>> getAll({bool includeHidden = false}) async {
    try {
      final List<CategoryRow> rows =
          await _db.categoryDao.getAll(includeHidden: includeHidden);
      return Result<List<Category>>.success(rows.map(_toEntity).toList());
    } catch (e) {
      return Result<List<Category>>.failure(
        DatabaseFailure(message: 'ดึงหมวดล้มเหลว: $e'),
      );
    }
  }

  @override
  Stream<List<Category>> watchAll({bool includeHidden = false}) {
    return _db.categoryDao
        .watchAll(includeHidden: includeHidden)
        .map((List<CategoryRow> rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<List<Category>>> getByType(
    CategoryType type, {
    bool includeHidden = false,
  }) async {
    try {
      final List<CategoryRow> rows = await _db.categoryDao
          .getByType(type.name, includeHidden: includeHidden);
      return Result<List<Category>>.success(rows.map(_toEntity).toList());
    } catch (e) {
      return Result<List<Category>>.failure(
        DatabaseFailure(message: 'ดึงหมวดล้มเหลว: $e'),
      );
    }
  }

  @override
  Stream<List<Category>> watchByType(
    CategoryType type, {
    bool includeHidden = false,
  }) {
    return _db.categoryDao
        .watchByType(type.name, includeHidden: includeHidden)
        .map((List<CategoryRow> rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<Result<Category>> getById(String id) async {
    try {
      final CategoryRow? row = await _db.categoryDao.getById(id);
      if (row == null) {
        return Result<Category>.failure(
          NotFoundFailure(message: 'ไม่พบหมวด', entity: 'Category'),
        );
      }
      return Result<Category>.success(_toEntity(row));
    } catch (e) {
      return Result<Category>.failure(
        DatabaseFailure(message: 'ดึงหมวดล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<Category>> create(Category category) async {
    try {
      final String id = category.id.isEmpty ? _uuid.v4() : category.id;
      final DateTime now = DateTime.now();
      final Category toSave = category.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
        isDefault: false, // ผู้ใช้สร้างเอง → ไม่ใช่ default
      );
      await _db.categoryDao.insertCategory(_toCompanion(toSave, insert: true));
      return Result<Category>.success(toSave);
    } catch (e) {
      return Result<Category>.failure(
        DatabaseFailure(message: 'สร้างหมวดล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<Category>> update(Category category) async {
    try {
      final CategoryRow? existing = await _db.categoryDao.getById(category.id);
      if (existing == null) {
        return Result<Category>.failure(
          NotFoundFailure(message: 'ไม่พบหมวด', entity: 'Category'),
        );
      }
      final Category updated = category.copyWith(updatedAt: DateTime.now());
      await _db.categoryDao.updateCategory(_toCompanion(updated, insert: false));
      return Result<Category>.success(updated);
    } catch (e) {
      return Result<Category>.failure(
        DatabaseFailure(message: 'อัปเดตหมวดล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<void>> hide(String id) async {
    try {
      await _db.categoryDao.hideCategory(id);
      return Result<void>.success(null);
    } catch (e) {
      return Result<void>.failure(
        DatabaseFailure(message: 'ซ่อนหมวดล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<void>> unhide(String id) async {
    try {
      await _db.categoryDao.unhideCategory(id);
      return Result<void>.success(null);
    } catch (e) {
      return Result<void>.failure(
        DatabaseFailure(message: 'unhide หมวดล้มเหลว: $e'),
      );
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      final bool ok = await _db.categoryDao.deleteIfCustom(id);
      if (!ok) {
        return Result<void>.failure(
          const ValidationFailure(
            message: 'ลบหมวดเริ่มต้นไม่ได้ — ใช้ "ซ่อน" แทน',
          ),
        );
      }
      return Result<void>.success(null);
    } catch (e) {
      return Result<void>.failure(
        DatabaseFailure(message: 'ลบหมวดล้มเหลว: $e'),
      );
    }
  }

  // ════════════════════════════════════════════════
  // MAPPERS
  // ════════════════════════════════════════════════
  Category _toEntity(CategoryRow row) {
    return Category(
      id: row.id,
      nameTh: row.nameTh,
      nameEn: row.nameEn,
      icon: row.icon,
      color: row.color,
      type: CategoryType.fromString(row.type),
      parentId: row.parentId,
      sortOrder: row.sortOrder,
      isDefault: row.isDefault,
      hidden: row.hidden,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  CategoriesCompanion _toCompanion(Category c, {required bool insert}) {
    return CategoriesCompanion(
      id: Value<String>(c.id),
      nameTh: Value<String>(c.nameTh),
      nameEn: Value<String>(c.nameEn),
      icon: Value<String>(c.icon),
      color: Value<String>(c.color),
      type: Value<String>(c.type.name),
      parentId: Value<String?>(c.parentId),
      sortOrder: Value<int>(c.sortOrder),
      isDefault: Value<bool>(c.isDefault),
      hidden: Value<bool>(c.hidden),
      createdAt: Value<DateTime>(c.createdAt),
      updatedAt: Value<DateTime>(c.updatedAt),
    );
  }
}
