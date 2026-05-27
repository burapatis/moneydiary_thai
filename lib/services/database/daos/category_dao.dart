import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

/// ──────────────────────────────────────────────────
/// CategoryDao — operations เกี่ยวกับ categories
/// ──────────────────────────────────────────────────
@DriftAccessor(tables: <Type>[Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase> with _$CategoryDaoMixin {
  CategoryDao(super.db);

  /// ดึง categories ทั้งหมด (เรียง type → sortOrder)
  Future<List<CategoryRow>> getAll({bool includeHidden = false}) {
    final SimpleSelectStatement<$CategoriesTable, CategoryRow> query =
        select(categories)
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            ($CategoriesTable t) =>
                OrderingTerm(expression: t.type, mode: OrderingMode.asc),
            ($CategoriesTable t) =>
                OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
          ]);
    if (!includeHidden) {
      query.where(($CategoriesTable t) => t.hidden.equals(false));
    }
    return query.get();
  }

  /// Stream — UI subscribe
  Stream<List<CategoryRow>> watchAll({bool includeHidden = false}) {
    final SimpleSelectStatement<$CategoriesTable, CategoryRow> query =
        select(categories)
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            ($CategoriesTable t) =>
                OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
          ]);
    if (!includeHidden) {
      query.where(($CategoriesTable t) => t.hidden.equals(false));
    }
    return query.watch();
  }

  /// ดึงเฉพาะ type (income หรือ expense)
  Future<List<CategoryRow>> getByType(String type, {bool includeHidden = false}) {
    final SimpleSelectStatement<$CategoriesTable, CategoryRow> query =
        select(categories)
          ..where(($CategoriesTable t) => t.type.equals(type))
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            ($CategoriesTable t) =>
                OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
          ]);
    if (!includeHidden) {
      query.where(($CategoriesTable t) => t.hidden.equals(false));
    }
    return query.get();
  }

  /// Stream by type
  Stream<List<CategoryRow>> watchByType(String type, {bool includeHidden = false}) {
    final SimpleSelectStatement<$CategoriesTable, CategoryRow> query =
        select(categories)
          ..where(($CategoriesTable t) => t.type.equals(type))
          ..orderBy(<OrderClauseGenerator<$CategoriesTable>>[
            ($CategoriesTable t) =>
                OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
          ]);
    if (!includeHidden) {
      query.where(($CategoriesTable t) => t.hidden.equals(false));
    }
    return query.watch();
  }

  /// ดึงด้วย id
  Future<CategoryRow?> getById(String id) {
    return (select(categories)..where(($CategoriesTable t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// สร้างหมวดใหม่
  Future<int> insertCategory(CategoriesCompanion entry) {
    return into(categories).insert(entry);
  }

  /// อัปเดต
  Future<bool> updateCategory(CategoriesCompanion entry) {
    final CategoriesCompanion withTs = entry.copyWith(
      updatedAt: Value<DateTime>(DateTime.now()),
    );
    return update(categories).replace(withTs);
  }

  /// hide หมวด (สำหรับ default — ลบไม่ได้)
  Future<int> hideCategory(String id) {
    return (update(categories)..where(($CategoriesTable t) => t.id.equals(id)))
        .write(CategoriesCompanion(
      hidden: const Value<bool>(true),
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
  }

  /// unhide หมวด
  Future<int> unhideCategory(String id) {
    return (update(categories)..where(($CategoriesTable t) => t.id.equals(id)))
        .write(CategoriesCompanion(
      hidden: const Value<bool>(false),
      updatedAt: Value<DateTime>(DateTime.now()),
    ));
  }

  /// ลบหมวด — เฉพาะ custom (ไม่ใช่ default)
  /// Default หมวด ใช้ hide แทน
  Future<bool> deleteIfCustom(String id) async {
    final CategoryRow? cat = await getById(id);
    if (cat == null || cat.isDefault) return false;

    await (delete(categories)..where(($CategoriesTable t) => t.id.equals(id))).go();
    return true;
  }

  /// นับจำนวน — ใช้ใน migration เช็คว่า seed แล้วยัง
  Future<int> count() async {
    final Expression<int> countExpr = categories.id.count();
    final TypedResult result = await (selectOnly(categories)
          ..addColumns(<Expression<Object>>[countExpr]))
        .getSingle();
    return result.read(countExpr) ?? 0;
  }
}
