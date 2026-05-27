import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../account/domain/entities/account.dart';
import '../../../category/domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';

/// ──────────────────────────────────────────────────
/// TransactionListItem — แถวรายการธุรกรรมใน list
/// ──────────────────────────────────────────────────
class TransactionListItem extends ConsumerWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ดึงข้อมูลหมวด + บัญชี ผ่าน providers (cached)
    final AsyncValue<List<Category>> categoriesAsync =
        ref.watch(categoriesStreamProvider);
    final AsyncValue<List<Account>> accountsAsync =
        ref.watch(accountsStreamProvider);

    final Category? category = categoriesAsync.value
        ?.where((Category c) => c.id == transaction.categoryId)
        .firstOrNull;
    final Account? account = accountsAsync.value
        ?.where((Account a) => a.id == transaction.accountId)
        .firstOrNull;

    final Color amountColor = transaction.type == TransactionType.income
        ? AppColors.success
        : context.colors.onSurface;

    final String amountText = transaction.type == TransactionType.income
        ? '+${Formatters.formatCurrency(transaction.amount, decimals: 0)}'
        : '-${Formatters.formatCurrency(transaction.amount, decimals: 0)}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            // Icon
            _buildIcon(category),
            const SizedBox(width: AppSpacing.md),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    category?.nameTh ?? 'ไม่ระบุ',
                    style: context.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildSubtitle(transaction, account),
                    style: context.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              amountText,
              style: context.textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(Category? category) {
    final Color color = category != null
        ? ColorParser.parse(category.color)
        : const Color(0xFF6B7280);
    final IconData icon = category != null
        ? IconResolver.resolve(category.icon)
        : Icons.category;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  String _buildSubtitle(Transaction tx, Account? account) {
    final String time = Formatters.formatTime(tx.date);
    final String accountName = account?.name ?? '—';
    final String? note = tx.note;

    if (note != null && note.isNotEmpty) {
      return '$time · $accountName · $note';
    }
    return '$time · $accountName';
  }
}
