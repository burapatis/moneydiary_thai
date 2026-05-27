import 'package:flutter_test/flutter_test.dart';
import 'package:moneydiary_thai/core/errors/failures.dart';
import 'package:moneydiary_thai/features/category/data/repositories/category_repository_impl.dart';
import 'package:moneydiary_thai/features/category/domain/entities/category.dart';
import 'package:moneydiary_thai/services/database/app_database.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl repo;

  setUp(() {
    db = createTestDatabase();
    repo = CategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// helper สร้าง category
  Category makeCategory({
    String id = '',
    String nameTh = 'หมวดทดสอบ',
    String nameEn = 'Test Category',
    CategoryType type = CategoryType.expense,
    bool isDefault = false,
  }) {
    final DateTime now = DateTime.now();
    return Category(
      id: id,
      nameTh: nameTh,
      nameEn: nameEn,
      icon: 'category',
      color: '0xFF10B981',
      type: type,
      sortOrder: 0,
      isDefault: isDefault,
      hidden: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CategoryRepository', () {
    group('default seeding', () {
      test('should have 25 default categories after first open', () async {
        // db เพิ่ง create → seed ทำงานแล้ว
        final Result<List<Category>> result = await repo.getAll();

        expect(result.isSuccess, true);
        // 18 expense + 7 income = 25
        expect(result.dataOrNull?.length, 25);
      });

      test('should have 18 expense categories', () async {
        final Result<List<Category>> result =
            await repo.getByType(CategoryType.expense);

        expect(result.dataOrNull?.length, 18);
      });

      test('should have 7 income categories', () async {
        final Result<List<Category>> result =
            await repo.getByType(CategoryType.income);

        expect(result.dataOrNull?.length, 7);
      });

      test('should include essential Thai categories', () async {
        final List<Category>? all = (await repo.getAll()).dataOrNull;
        final List<String> names = all!.map((Category c) => c.nameTh).toList();

        expect(names, contains('อาหาร'));
        expect(names, contains('ทำบุญ-บริจาค'));
        expect(names, contains('นวด-สปา'));
        expect(names, contains('ตลาดสด-ของชำ'));
        expect(names, contains('เงินเดือน'));
      });

      test('all default categories should have isDefault = true', () async {
        final List<Category>? all = (await repo.getAll()).dataOrNull;
        expect(
          all!.every((Category c) => c.isDefault),
          true,
        );
      });
    });

    group('create custom category', () {
      test('should create and set isDefault = false', () async {
        final Category custom = makeCategory(
          nameTh: 'คอร์สเรียน',
          nameEn: 'Course',
          isDefault: true, // user พยายามใส่ true — repo ต้องบังคับ false
        );

        final Result<Category> result = await repo.create(custom);

        expect(result.isSuccess, true);
        expect(result.dataOrNull?.isDefault, false);
        expect(result.dataOrNull?.nameTh, 'คอร์สเรียน');
      });
    });

    group('hide / unhide default', () {
      test('should hide default category', () async {
        final List<Category> defaults = (await repo.getAll()).dataOrNull!;
        final Category first = defaults.first;

        await repo.hide(first.id);

        // default ใช้ getAll (excluding hidden) → ไม่เห็น
        final List<Category> visible = (await repo.getAll()).dataOrNull!;
        expect(visible.any((Category c) => c.id == first.id), false);

        // get includeHidden → เห็น
        final List<Category> all =
            (await repo.getAll(includeHidden: true)).dataOrNull!;
        expect(all.any((Category c) => c.id == first.id), true);
      });

      test('should unhide category', () async {
        final List<Category> defaults = (await repo.getAll()).dataOrNull!;
        final Category first = defaults.first;

        await repo.hide(first.id);
        await repo.unhide(first.id);

        final List<Category> visible = (await repo.getAll()).dataOrNull!;
        expect(visible.any((Category c) => c.id == first.id), true);
      });
    });

    group('delete', () {
      test('should refuse to delete default category', () async {
        final List<Category> defaults = (await repo.getAll()).dataOrNull!;
        final Category first = defaults.first;

        final Result<void> result = await repo.delete(first.id);

        expect(result.isFailure, true);
        expect(result.failureOrNull, isA<ValidationFailure>());
      });

      test('should delete custom category', () async {
        final Category created =
            (await repo.create(makeCategory())).dataOrNull!;

        final Result<void> result = await repo.delete(created.id);

        expect(result.isSuccess, true);
        expect((await repo.getById(created.id)).isFailure, true);
      });
    });
  });
}
