import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../../services/database/database_providers.dart';
import '../../domain/entities/category.dart';
import 'category_edit_screen.dart';

/// ──────────────────────────────────────────────────
/// CategoryListScreen — จัดการหมวด
/// ──────────────────────────────────────────────────
/// Tabs:
///   - รายจ่าย (default)
///   - รายรับ
/// แสดงทั้ง active + hidden (มี toggle visibility)
/// ──────────────────────────────────────────────────
class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => const CategoryListScreen(),
      ),
    );
  }

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการหมวด'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(text: 'รายจ่าย'),
            Tab(text: 'รายรับ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _CategoryListTab(type: CategoryType.expense),
          _CategoryListTab(type: CategoryType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final CategoryType currentType = _tabController.index == 0
              ? CategoryType.expense
              : CategoryType.income;
          CategoryEditScreen.show(context, type: currentType);
        },
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มหมวด'),
      ),
    );
  }
}

/// One tab — list of categories for a given type
class _CategoryListTab extends ConsumerWidget {
  const _CategoryListTab({required this.type});

  final CategoryType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ใช้ provider ที่มี include hidden = true เพื่อแสดงทั้งหมด
    final repo = ref.watch(categoryRepositoryProvider);
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      _allCategoriesByTypeProvider(type),
    );

    return categoriesAsync.when(
      data: (List<Category> categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('ยังไม่มีหมวด'));
        }

        return ListView.separated(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: 100, // เผื่อ FAB
          ),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (BuildContext ctx, int i) {
            final Category c = categories[i];
            return _CategoryListItem(category: c, repo: repo);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, _) => Center(child: Text('Error: $e')),
    );
  }
}

/// Provider แยกที่ดึงทั้ง hidden + visible
final _allCategoriesByTypeProvider = StreamProvider.autoDispose
    .family<List<Category>, CategoryType>((Ref ref, CategoryType type) {
  return ref
      .watch(categoryRepositoryProvider)
      .watchByType(type, includeHidden: true);
});

/// One row in the list
class _CategoryListItem extends ConsumerWidget {
  const _CategoryListItem({required this.category, required this.repo});

  final Category category;
  final dynamic repo; // CategoryRepository

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color = ColorParser.parse(category.color);
    final IconData icon = IconResolver.resolve(category.icon);
    final bool isHidden = category.hidden;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isHidden ? 0.08 : 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isHidden ? color.withValues(alpha: 0.4) : color,
          size: 22,
        ),
      ),
      title: Text(
        category.nameTh,
        style: TextStyle(
          color: isHidden
              ? context.colors.onSurface.withValues(alpha: 0.5)
              : null,
          decoration: isHidden ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Row(
        children: <Widget>[
          if (category.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'เริ่มต้น',
                style: context.textTheme.labelSmall,
              ),
            ),
          if (category.isDefault) const SizedBox(width: 6),
          Text(
            category.nameEn,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Hide/Unhide toggle (only for default)
          if (category.isDefault)
            IconButton(
              icon: Icon(
                isHidden ? Icons.visibility_off : Icons.visibility,
                color: isHidden
                    ? context.colors.onSurface.withValues(alpha: 0.5)
                    : context.colors.primary,
              ),
              tooltip: isHidden ? 'แสดง' : 'ซ่อน',
              onPressed: () => _toggleHide(ref),
            ),
          // Edit (only for custom)
          if (!category.isDefault)
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _editCategory(context),
            ),
        ],
      ),
      onTap: category.isDefault
          ? () => _toggleHide(ref)
          : () => _editCategory(context),
    );
  }

  Future<void> _toggleHide(WidgetRef ref) async {
    if (category.hidden) {
      await repo.unhide(category.id);
    } else {
      await repo.hide(category.id);
    }
  }

  Future<void> _editCategory(BuildContext context) async {
    await CategoryEditScreen.show(
      context,
      editing: category,
      type: category.type,
    );
  }
}
