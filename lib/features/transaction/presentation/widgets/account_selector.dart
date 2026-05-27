import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../account/domain/entities/account.dart';
import '../../../account/presentation/providers/account_providers.dart';

/// ──────────────────────────────────────────────────
/// AccountSelector — dropdown เลือกบัญชี
/// ──────────────────────────────────────────────────
class AccountSelector extends ConsumerWidget {
  const AccountSelector({
    super.key,
    required this.selectedAccount,
    required this.onChanged,
  });

  final Account? selectedAccount;
  final ValueChanged<Account> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Account>> accountsAsync = ref.watch(accountsProvider);

    return accountsAsync.when(
      data: (List<Account> accounts) {
        if (accounts.isEmpty) {
          return _buildEmpty(context);
        }

        // ถ้า selectedAccount ไม่อยู่ใน accounts (เช่นเพิ่ง archived)
        // → fallback เป็นตัวแรก
        final Account current = accounts.firstWhere(
          (Account a) => a.id == selectedAccount?.id,
          orElse: () => accounts.first,
        );

        return InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: () => _showAccountPicker(context, accounts, current),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: context.colors.outline),
            ),
            child: Row(
              children: <Widget>[
                _accountIcon(current),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    current.name,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: context.colors.onSurface,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const _LoadingPlaceholder(),
      error: (Object e, _) => Text('Error: $e'),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        'ไม่พบบัญชี',
        style: context.textTheme.bodyMedium,
      ),
    );
  }

  Widget _accountIcon(Account a) {
    final Color color = ColorParser.parse(a.color);
    final IconData icon = IconResolver.resolve(a.icon);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  /// แสดง bottom sheet เลือกบัญชี
  Future<void> _showAccountPicker(
    BuildContext context,
    List<Account> accounts,
    Account current,
  ) async {
    final Account? selected = await showModalBottomSheet<Account>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    'เลือกบัญชี',
                    style: ctx.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...accounts.map((Account a) {
                  final bool isCurrent = a.id == current.id;
                  return ListTile(
                    leading: _accountIcon(a),
                    title: Text(a.name),
                    trailing: isCurrent
                        ? Icon(
                            Icons.check_circle,
                            color: ctx.colors.primary,
                          )
                        : null,
                    onTap: () => Navigator.of(ctx).pop(a),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      onChanged(selected);
    }
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
    );
  }
}
