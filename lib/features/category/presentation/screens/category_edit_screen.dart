import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../../core/widgets/pickers/color_picker.dart';
import '../../../../core/widgets/pickers/icon_picker.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../services/database/database_providers.dart';
import '../../domain/entities/category.dart';

/// ──────────────────────────────────────────────────
/// CategoryEditScreen — สร้าง/แก้ category
/// ──────────────────────────────────────────────────
/// Routes:
///   - new: editing == null
///   - edit: editing != null
/// ──────────────────────────────────────────────────
class CategoryEditScreen extends ConsumerStatefulWidget {
  const CategoryEditScreen({
    super.key,
    this.editing,
    required this.type,
  });

  /// ถ้า null = สร้างใหม่
  final Category? editing;

  /// expense หรือ income (กำหนดตอนสร้าง)
  final CategoryType type;

  /// Helper เปิด screen
  static Future<bool?> show(
    BuildContext context, {
    Category? editing,
    CategoryType type = CategoryType.expense,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext ctx) => CategoryEditScreen(
          editing: editing,
          type: type,
        ),
      ),
    );
  }

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  late final TextEditingController _nameThController;
  late final TextEditingController _nameEnController;
  late String _selectedIcon;
  late String _selectedColor;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final Category? c = widget.editing;
    _nameThController = TextEditingController(text: c?.nameTh ?? '');
    _nameEnController = TextEditingController(text: c?.nameEn ?? '');
    _selectedIcon = c?.icon ?? 'category';
    _selectedColor = c?.color ?? '0xFF10B981';
  }

  @override
  void dispose() {
    _nameThController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameThController.text.trim().isNotEmpty &&
      _nameEnController.text.trim().isNotEmpty &&
      !_isSaving;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isNew = widget.editing == null;
    final Color tintColor = ColorParser.parse(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? l10n.categoryNew : l10n.categoryEdit),
        actions: <Widget>[
          if (!isNew && !(widget.editing?.isDefault ?? false))
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.danger,
              onPressed: _confirmDelete,
              tooltip: l10n.commonDelete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            // Preview (icon + ชื่อ)
            _buildPreview(tintColor),
            const SizedBox(height: AppSpacing.lg),

            // ชื่อภาษาไทย
            _buildLabel(l10n.categoryNameTh),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _nameThController,
              decoration: InputDecoration(
                hintText: l10n.categoryNameThHint,
              ),
              maxLength: 60,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),

            // ชื่อภาษาอังกฤษ
            _buildLabel(l10n.categoryNameEn),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _nameEnController,
              decoration: InputDecoration(
                hintText: l10n.categoryNameEnHint,
              ),
              maxLength: 60,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon picker
            _buildLabel(l10n.pickerChooseIcon),
            const SizedBox(height: AppSpacing.sm),
            IconPicker(
              selectedIcon: _selectedIcon,
              tintColor: tintColor,
              onSelected: (String name) =>
                  setState(() => _selectedIcon = name),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color picker
            _buildLabel(l10n.pickerChooseColor),
            const SizedBox(height: AppSpacing.sm),
            AppColorPicker(
              selectedColor: _selectedColor,
              onSelected: (String hex) =>
                  setState(() => _selectedColor = hex),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Save button
            FilledButton(
              onPressed: _canSave ? _save : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonSave),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: context.textTheme.labelLarge?.copyWith(
        color: context.colors.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildPreview(Color tintColor) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: tintColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconResolver.resolve(_selectedIcon),
              color: tintColor,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _nameThController.text.trim().isEmpty
                ? 'ชื่อหมวด'
                : _nameThController.text,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: widget.type == CategoryType.expense
                  ? AppColors.danger.withValues(alpha: 0.15)
                  : AppColors.success.withValues(alpha: 0.15),
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              widget.type == CategoryType.expense ? 'รายจ่าย' : 'รายรับ',
              style: context.textTheme.labelSmall?.copyWith(
                color: widget.type == CategoryType.expense
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final NavigatorState nav = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(categoryRepositoryProvider);

    final DateTime now = DateTime.now();
    final Category category = Category(
      id: widget.editing?.id ?? '',
      nameTh: _nameThController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      icon: _selectedIcon,
      color: _selectedColor,
      type: widget.type,
      sortOrder: widget.editing?.sortOrder ?? 999,
      isDefault: false,
      hidden: widget.editing?.hidden ?? false,
      createdAt: widget.editing?.createdAt ?? now,
      updatedAt: now,
    );

    final Result<Category> result = widget.editing == null
        ? await repo.create(category)
        : await repo.update(category);

    if (!mounted) return;

    if (result.isSuccess) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('บันทึกแล้ว'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
      nav.pop(true);
    } else {
      setState(() => _isSaving = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'เกิดข้อผิดพลาด'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('ลบหมวดนี้?'),
          content: const Text(
            'รายการที่ใช้หมวดนี้จะยังคงอยู่ แต่ต้องเปลี่ยนหมวดใหม่',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final NavigatorState nav = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(categoryRepositoryProvider);

    final Result<void> result = await repo.delete(widget.editing!.id);

    if (!mounted) return;

    if (result.isSuccess) {
      messenger.showSnackBar(
        const SnackBar(content: Text('ลบแล้ว')),
      );
      nav.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'ลบไม่ได้'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
