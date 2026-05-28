import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../../services/database/database_providers.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../domain/entities/account.dart';
import '../providers/account_providers.dart';
import 'account_edit_screen.dart';

/// ──────────────────────────────────────────────────
/// AccountListScreen — จัดการบัญชี
/// ──────────────────────────────────────────────────
class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => const AccountListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Account>> accountsAsync =
        ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('จัดการบัญชี'),
      ),
      body: accountsAsync.when(
        data: (List<Account> accounts) {
          if (accounts.isEmpty) {
            return _buildEmpty(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: 100,
            ),
            itemCount: accounts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext ctx, int i) {
              return _AccountListItem(account: accounts[i]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AccountEditScreen.show(context),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มบัญชี'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: context.colors.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ยังไม่มีบัญชี',
            style: context.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

/// One account row — shows balance + name + type
class _AccountListItem extends ConsumerWidget {
  const _AccountListItem({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color color = ColorParser.parse(account.color);
    final IconData icon = IconResolver.resolve(account.icon);

    // Watch real balance (initialBalance + transactions)
    final AsyncValue<double> balanceAsync = ref.watch(
      _accountBalanceProvider(account.id),
    );

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(account.name),
      subtitle: Text(_typeLabel(account.type)),
      trailing: balanceAsync.when(
        data: (double balance) => Text(
          Formatters.formatCurrency(balance),
          style: context.textTheme.titleMedium?.copyWith(
            color: balance >= 0 ? context.colors.primary : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        loading: () => const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (Object e, _) => const Text('—'),
      ),
      onTap: () => AccountEditScreen.show(context, editing: account),
    );
  }

  String _typeLabel(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'เงินสด';
      case AccountType.bank:
        return 'ธนาคาร';
      case AccountType.ewallet:
        return 'E-Wallet';
      case AccountType.credit:
        return 'บัตรเครดิต';
      case AccountType.other:
        return 'อื่นๆ';
    }
  }
}

/// Per-account balance stream (auto-refresh on transaction changes)
final _accountBalanceProvider =
    FutureProvider.autoDispose.family<double, String>((Ref ref, String accountId) async {
  // Reactively recompute when transactions change
  ref.watch(transactionsStreamProvider);
  final result =
      await ref.read(accountRepositoryProvider).calculateBalance(accountId);
  return result.dataOrNull ?? 0;
});
