import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../services/database/database_providers.dart';
import '../../../account/domain/entities/account.dart';
import '../../../account/presentation/providers/account_providers.dart';
import '../../../category/domain/entities/category.dart';
import '../../../category/presentation/providers/category_providers.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import 'account_selector.dart';
import 'category_chip.dart';

/// ──────────────────────────────────────────────────
/// QuickAddSheet — เพิ่มรายการเร็วๆ ใน 3 วินาที
/// ──────────────────────────────────────────────────
/// Flow:
///   1. กด FAB → เปิด sheet
///   2. Toggle expense/income (default expense)
///   3. กรอกจำนวน (autofocus)
///   4. เลือกหมวด (มี last-used default)
///   5. เลือกบัญชี (last-used default)
///   6. กด "บันทึก" → toast + ปิด sheet
/// ──────────────────────────────────────────────────
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, this.editingTransaction});

  /// ถ้าเป็น null = เพิ่มใหม่
  /// ถ้าไม่ใช่ null = แก้ไข existing
  final Transaction? editingTransaction;

  /// Helper เปิด sheet จากที่อื่น
  static Future<void> show(
    BuildContext context, {
    Transaction? editingTransaction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        // ใส่ใน Padding ที่ตอบสนอง keyboard
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: QuickAddSheet(editingTransaction: editingTransaction),
        );
      },
    );
  }

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  final FocusNode _amountFocus = FocusNode();

  TransactionType _type = TransactionType.expense;
  Category? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // ถ้า editing — pre-fill ค่าเดิม
    final Transaction? editing = widget.editingTransaction;
    if (editing != null) {
      _type = editing.type;
      _amountController = TextEditingController(
        text: editing.amount.toStringAsFixed(
          editing.amount.truncateToDouble() == editing.amount ? 0 : 2,
        ),
      );
      _noteController = TextEditingController(text: editing.note ?? '');
      _selectedDate = editing.date;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
    }

    // Autofocus amount หลัง frame แรก render เสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  /// คำนวณว่าสามารถ save ได้หรือยัง
  bool get _canSave {
    final double? amount = Formatters.parseAmount(_amountController.text);
    return amount != null &&
        amount > 0 &&
        _selectedCategory != null &&
        _selectedAccount != null &&
        !_isSaving;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: AppRadius.bottomSheet,
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: <Widget>[
              const SizedBox(height: AppSpacing.sm),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.editingTransaction == null
                        ? l10n.transactionAddTitle
                        : l10n.transactionEditTitle,
                    style: context.textTheme.titleLarge,
                  ),
                  Row(
                    children: <Widget>[
                      // Delete button (เฉพาะ edit mode)
                      if (widget.editingTransaction != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.danger,
                          onPressed: _confirmDelete,
                          tooltip: l10n.commonDelete,
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: l10n.commonCancel,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Type toggle (expense / income)
              _buildTypeToggle(l10n),

              const SizedBox(height: AppSpacing.lg),

              // Amount input (Hero)
              _buildAmountInput(l10n),

              const SizedBox(height: AppSpacing.lg),

              // Category picker
              _buildCategorySection(l10n),

              const SizedBox(height: AppSpacing.lg),

              // Account selector
              _buildAccountSection(l10n),

              const SizedBox(height: AppSpacing.md),

              // Note input
              _buildNoteInput(l10n),

              const SizedBox(height: AppSpacing.md),

              // Date/time
              _buildDateSection(l10n),

              const SizedBox(height: AppSpacing.xl),

              // Save button
              _buildSaveButton(l10n),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  /// ────────────────
  /// Sections
  /// ────────────────
  Widget _buildTypeToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _typeButton(
              label: l10n.transactionTypeExpense,
              type: TransactionType.expense,
              color: AppColors.danger,
              icon: Icons.arrow_upward,
            ),
          ),
          Expanded(
            child: _typeButton(
              label: l10n.transactionTypeIncome,
              type: TransactionType.income,
              color: AppColors.success,
              icon: Icons.arrow_downward,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeButton({
    required String label,
    required TransactionType type,
    required Color color,
    required IconData icon,
  }) {
    final bool isSelected = _type == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
          _selectedCategory = null; // reset เพราะหมวด income/expense ต่างกัน
        });
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: AppRadius.smAll,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 18, color: isSelected ? color : null),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.titleSmall?.copyWith(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(AppLocalizations l10n) {
    final Color amountColor = _type == TransactionType.expense
        ? AppColors.danger
        : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.transactionAmount,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _amountController,
          focusNode: _amountFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            // อนุญาตเฉพาะตัวเลข + จุดทศนิยม + จุลภาค
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          textAlign: TextAlign.center,
          style: AppTypography.display.copyWith(color: amountColor),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: AppTypography.display.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.3),
            ),
            suffixText: '฿',
            suffixStyle: AppTypography.h2.copyWith(color: amountColor),
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: context.colors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: context.colors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdAll,
              borderSide: BorderSide(color: amountColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          onChanged: (_) => setState(() {}), // re-evaluate _canSave
        ),
      ],
    );
  }

  Widget _buildCategorySection(AppLocalizations l10n) {
    final AsyncValue<List<Category>> categoriesAsync = _type ==
            TransactionType.expense
        ? ref.watch(expenseCategoriesStreamProvider)
        : ref.watch(incomeCategoriesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.transactionCategory,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        categoriesAsync.when(
          data: (List<Category> categories) {
            if (categories.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: Text(
                    l10n.categoryEmpty,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              );
            }

            if (_selectedCategory == null) {
              final String? lastUsedId =
                  ref.read(lastUsedCategoryIdProvider);
              final Category? lastUsed = lastUsedId == null
                  ? null
                  : categories
                      .where((Category c) => c.id == lastUsedId)
                      .firstOrNull;
              _selectedCategory = lastUsed ?? categories.first;
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categories.map((Category cat) {
                  return CategoryChip(
                    category: cat,
                    isSelected: _selectedCategory?.id == cat.id,
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      HapticFeedback.selectionClick();
                    },
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (Object e, _) => Text(l10n.commonError),
        ),
      ],
    );
  }

  Widget _buildAccountSection(AppLocalizations l10n) {
    final AsyncValue<Account?> defaultAccountAsync =
        ref.watch(defaultAccountProvider);

    // Auto-select default account ถ้ายังไม่มี selection
    if (_selectedAccount == null) {
      defaultAccountAsync.whenData((Account? a) {
        if (a != null && _selectedAccount == null) {
          // ต้องใช้ postFrameCallback เพราะอยู่ใน build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedAccount = a);
            }
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.transactionAccount,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AccountSelector(
          selectedAccount: _selectedAccount,
          onChanged: (Account a) {
            setState(() => _selectedAccount = a);
          },
        ),
      ],
    );
  }

  Widget _buildNoteInput(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${l10n.transactionNote} (${l10n.commonOptional})',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _noteController,
          maxLines: 2,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: l10n.transactionNoteHint,
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(AppLocalizations l10n) {
    final String locale = Localizations.localeOf(context).languageCode;
    final String dateLabel =
        '${Formatters.formatRelativeDate(_selectedDate, locale: locale)}  '
        '${Formatters.formatTime(_selectedDate)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.transactionDate,
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Material(
          color: context.colors.surfaceContainerHighest,
          borderRadius: AppRadius.mdAll,
          child: InkWell(
            onTap: _pickDateTime,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_today_outlined,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          dateLabel,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.transactionDateHint,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_calendar_outlined,
                    color: context.colors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return FilledButton(
      onPressed: _canSave ? _save : null,
      child: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(l10n.commonSave),
    );
  }

  /// ────────────────
  /// Date/Time picker
  /// ────────────────
  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  /// ────────────────
  /// Save action
  /// ────────────────
  Future<void> _save() async {
    final double? amount = Formatters.parseAmount(_amountController.text);
    if (amount == null || amount <= 0) return;
    if (_selectedCategory == null || _selectedAccount == null) return;

    setState(() => _isSaving = true);

    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState nav = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    final Transaction tx = Transaction(
      id: widget.editingTransaction?.id ?? '',
      accountId: _selectedAccount!.id,
      categoryId: _selectedCategory!.id,
      amount: amount,
      type: _type,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: widget.editingTransaction?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(transactionRepositoryProvider);
    final Result<Transaction> result = widget.editingTransaction == null
        ? await repo.create(tx)
        : await repo.update(tx);

    if (!mounted) return;

    if (result.isSuccess) {
      // จำ last-used เพื่อ pre-fill ครั้งถัดไป
      await ref
          .read(lastUsedCategoryIdProvider.notifier)
          .setId(_selectedCategory!.id);
      await ref
          .read(lastUsedAccountIdProvider.notifier)
          .setId(_selectedAccount!.id);

      // Haptic feedback (สำเร็จ)
      HapticFeedback.lightImpact();

      // Toast success
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(l10n.transactionSavedSuccess),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      nav.pop();
    } else {
      // Error
      setState(() => _isSaving = false);
      final Failure? failure = result.failureOrNull;
      messenger.showSnackBar(
        SnackBar(
          content: Text(failure?.message ?? l10n.commonError),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  /// ────────────────
  /// Delete action — เฉพาะ edit mode
  /// ────────────────
  Future<void> _confirmDelete() async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(l10n.transactionDeleteConfirm),
          content: Text(l10n.transactionDeleteConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final NavigatorState nav = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(transactionRepositoryProvider);

    final Result<void> result =
        await repo.delete(widget.editingTransaction!.id);

    if (!mounted) return;

    if (result.isSuccess) {
      HapticFeedback.lightImpact();
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.transactionDeletedSuccess),
          duration: const Duration(seconds: 2),
        ),
      );
      nav.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? l10n.commonError),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
