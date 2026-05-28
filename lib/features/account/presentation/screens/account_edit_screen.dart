import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../../core/widgets/pickers/color_picker.dart';
import '../../../../core/widgets/pickers/icon_picker.dart';
import '../../../../services/database/database_providers.dart';
import '../../domain/entities/account.dart';

/// ──────────────────────────────────────────────────
/// AccountEditScreen — สร้าง/แก้บัญชี
/// ──────────────────────────────────────────────────
class AccountEditScreen extends ConsumerStatefulWidget {
  const AccountEditScreen({super.key, this.editing});

  final Account? editing;

  static Future<bool?> show(BuildContext context, {Account? editing}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext ctx) => AccountEditScreen(editing: editing),
      ),
    );
  }

  @override
  ConsumerState<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends ConsumerState<AccountEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _initialBalanceController;
  late String _selectedIcon;
  late String _selectedColor;
  late AccountType _selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final Account? a = widget.editing;
    _nameController = TextEditingController(text: a?.name ?? '');
    _initialBalanceController = TextEditingController(
      text: a == null || a.initialBalance == 0
          ? ''
          : a.initialBalance.toStringAsFixed(
              a.initialBalance.truncateToDouble() == a.initialBalance ? 0 : 2,
            ),
    );
    _selectedIcon = a?.icon ?? 'wallet';
    _selectedColor = a?.color ?? '0xFF10B981';
    _selectedType = a?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && !_isSaving;

  @override
  Widget build(BuildContext context) {
    final bool isNew = widget.editing == null;
    final Color tintColor = ColorParser.parse(_selectedColor);

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'สร้างบัญชีใหม่' : 'แก้ไขบัญชี'),
        actions: <Widget>[
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: _confirmArchive,
              tooltip: 'เก็บถาวร',
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            // Preview
            _buildPreview(tintColor),
            const SizedBox(height: AppSpacing.lg),

            // ชื่อบัญชี
            _buildLabel('ชื่อบัญชี'),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'เช่น K PLUS, SCB Easy, เงินสด',
              ),
              maxLength: 60,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),

            // ประเภทบัญชี
            _buildLabel('ประเภท'),
            const SizedBox(height: AppSpacing.sm),
            _buildTypeSelector(),
            const SizedBox(height: AppSpacing.md),

            // ยอดเริ่มต้น
            _buildLabel('ยอดเริ่มต้น'),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _initialBalanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: const InputDecoration(
                hintText: '0',
                suffixText: '฿',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon picker
            _buildLabel('เลือกไอคอน'),
            const SizedBox(height: AppSpacing.sm),
            IconPicker(
              selectedIcon: _selectedIcon,
              tintColor: tintColor,
              onSelected: (String name) =>
                  setState(() => _selectedIcon = name),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Color picker
            _buildLabel('เลือกสี'),
            const SizedBox(height: AppSpacing.sm),
            AppColorPicker(
              selectedColor: _selectedColor,
              onSelected: (String hex) =>
                  setState(() => _selectedColor = hex),
            ),
            const SizedBox(height: AppSpacing.xl),

            FilledButton(
              onPressed: _canSave ? _save : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('บันทึก'),
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
            _nameController.text.trim().isEmpty
                ? 'ชื่อบัญชี'
                : _nameController.text,
            style: context.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final List<({AccountType type, String label, IconData icon})> options =
        <({AccountType type, String label, IconData icon})>[
      (type: AccountType.cash, label: 'เงินสด', icon: Icons.money),
      (
        type: AccountType.bank,
        label: 'ธนาคาร',
        icon: Icons.account_balance
      ),
      (
        type: AccountType.ewallet,
        label: 'E-Wallet',
        icon: Icons.account_balance_wallet
      ),
      (type: AccountType.credit, label: 'เครดิต', icon: Icons.credit_card),
      (type: AccountType.other, label: 'อื่นๆ', icon: Icons.more_horiz),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((opt) {
        final bool isSelected = _selectedType == opt.type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = opt.type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colors.primary.withValues(alpha: 0.15)
                  : context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  opt.icon,
                  size: 16,
                  color: isSelected ? context.colors.primary : null,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  opt.label,
                  style: TextStyle(
                    color: isSelected ? context.colors.primary : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final NavigatorState nav = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(accountRepositoryProvider);

    final double initialBalance =
        Formatters.parseAmount(_initialBalanceController.text) ?? 0;

    final DateTime now = DateTime.now();
    final Account account = Account(
      id: widget.editing?.id ?? '',
      name: _nameController.text.trim(),
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
      initialBalance: initialBalance,
      currency: widget.editing?.currency ?? 'THB',
      archived: widget.editing?.archived ?? false,
      sortOrder: widget.editing?.sortOrder ?? 999,
      createdAt: widget.editing?.createdAt ?? now,
      updatedAt: now,
    );

    final Result<Account> result = widget.editing == null
        ? await repo.create(account)
        : await repo.update(account);

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

  Future<void> _confirmArchive() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('เก็บถาวรบัญชีนี้?'),
          content: const Text(
            'บัญชีนี้จะถูกซ่อนจาก list หลัก แต่ข้อมูลยังอยู่ครบถ้วน',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('เก็บถาวร'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final NavigatorState nav = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(accountRepositoryProvider);

    final Result<void> result = await repo.archive(widget.editing!.id);

    if (!mounted) return;

    if (result.isSuccess) {
      messenger.showSnackBar(
        const SnackBar(content: Text('เก็บถาวรแล้ว')),
      );
      nav.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'ผิดพลาด'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
