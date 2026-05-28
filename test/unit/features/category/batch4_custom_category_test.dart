import 'package:flutter_test/flutter_test.dart';
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

  group('Batch 4: Custom Category Management', () {
    test('User creates custom category with all fields', () async {
      final DateTime now = DateTime.now();
      final Category newCategory = Category(
        id: '',
        nameTh: 'ค่าฟิตเนส',
        nameEn: 'Gym',
        icon: 'spa',
        color: '0xFFEC4899',
        type: CategoryType.expense,
        sortOrder: 999,
        isDefault: false,
        hidden: false,
        createdAt: now,
        updatedAt: now,
      );

      final result = await repo.create(newCategory);
      expect(result.isSuccess, true);
      final Category created = result.dataOrNull!;
      expect(created.id.isNotEmpty, true);
      expect(created.nameTh, 'ค่าฟิตเนส');
      expect(created.isDefault, false); // ผู้ใช้สร้าง = ไม่ใช่ default
    });

    test('Custom category can be edited', () async {
      final DateTime now = DateTime.now();
      final Category created = (await repo.create(Category(
        id: '',
        nameTh: 'ค่าหนังสือ',
        nameEn: 'Books',
        icon: 'school',
        color: '0xFF3B82F6',
        type: CategoryType.expense,
        sortOrder: 0,
        isDefault: false,
        hidden: false,
        createdAt: now,
        updatedAt: now,
      )))
          .dataOrNull!;

      final Category updated = created.copyWith(
        nameTh: 'ค่าหนังสือ + คอร์ส',
        color: '0xFF10B981',
      );
      final result = await repo.update(updated);
      expect(result.isSuccess, true);
      expect(result.dataOrNull?.nameTh, 'ค่าหนังสือ + คอร์ส');
      expect(result.dataOrNull?.color, '0xFF10B981');
    });

    test('Custom category can be deleted', () async {
      final DateTime now = DateTime.now();
      final Category created = (await repo.create(Category(
        id: '',
        nameTh: 'ทดสอบ',
        nameEn: 'Test',
        icon: 'category',
        color: '0xFF6B7280',
        type: CategoryType.expense,
        sortOrder: 0,
        isDefault: false,
        hidden: false,
        createdAt: now,
        updatedAt: now,
      )))
          .dataOrNull!;

      final result = await repo.delete(created.id);
      expect(result.isSuccess, true);

      final lookup = await repo.getById(created.id);
      expect(lookup.isFailure, true);
    });

    test('Hidden default categories excluded from default list', () async {
      final List<Category> initialVisible = (await repo.getAll()).dataOrNull!;
      final int initialCount = initialVisible.length;

      // ซ่อนหมวดแรก
      final Category first = initialVisible.first;
      await repo.hide(first.id);

      // นับใหม่ - ต้องลดลง 1
      final List<Category> nowVisible = (await repo.getAll()).dataOrNull!;
      expect(nowVisible.length, initialCount - 1);

      // includeHidden = true → เห็นทุกหมวด
      final List<Category> all =
          (await repo.getAll(includeHidden: true)).dataOrNull!;
      expect(all.length, initialCount);
    });
  });
}
