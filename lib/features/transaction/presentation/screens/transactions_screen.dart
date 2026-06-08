import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_providers.dart';
import '../widgets/quick_add_sheet.dart';
import '../widgets/transaction_list_item.dart';

/// ──────────────────────────────────────────────────
/// TransactionsScreen — Tab "รายการ"
/// ──────────────────────────────────────────────────
/// แสดง transactions ทั้งหมด จัดกลุ่มตามวันที่ (DESC = ล่าสุดก่อน)
/// กดแต่ละ item → เปิด Quick-Add ในโหมด edit
/// ──────────────────────────────────────────────────
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Transaction>> async =
        ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionTitle),
      ),
      body: async.when(
        data: (List<Transaction> txs) {
          if (txs.isEmpty) {
            return _buildEmpty(context, l10n);
          }
          return _buildList(context, txs);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(
          child: Text('Error: $e', style: context.textTheme.bodyMedium),
        ),
      ),
    );
  }

  /// Empty state
  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: context.colors.outline,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.transactionEmptyTitle,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.transactionEmptySubtitle,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => QuickAddSheet.show(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.transactionEmptyAction),
            ),
          ],
        ),
      ),
    );
  }

  /// Grouped list — จัดกลุ่มตามวันที่
  Widget _buildList(BuildContext context, List<Transaction> txs) {
    // Group by date (YYYY-MM-DD)
    final Map<DateTime, List<Transaction>> grouped =
        <DateTime, List<Transaction>>{};
    for (final Transaction tx in txs) {
      final DateTime day = DateHelpers.startOfDay(tx.date);
      grouped.putIfAbsent(day, () => <Transaction>[]).add(tx);
    }
    final List<DateTime> sortedDays = grouped.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a)); // DESC

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        100,
      ),
      itemCount: sortedDays.length,
      itemBuilder: (BuildContext ctx, int i) {
        final DateTime day = sortedDays[i];
        final List<Transaction> dayTxs = grouped[day]!;

        // คำนวณยอดวันนั้น
        double dayExpense = 0;
        double dayIncome = 0;
        for (final Transaction tx in dayTxs) {
          if (tx.type == TransactionType.expense) {
            dayExpense += tx.amount;
          } else if (tx.type == TransactionType.income) {
            dayIncome += tx.amount;
          }
        }
        final double dayNet = dayIncome - dayExpense;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: SectionCard(
            variant: SectionCard.variantAtIndex(i),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.md,
                    bottom: AppSpacing.xs,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          Formatters.formatRelativeDateTh(day),
                          style: context.textTheme.labelLarge,
                        ),
                      ),
                      Text(
                        dayNet >= 0
                            ? '+${Formatters.formatMoney(dayNet)}'
                            : Formatters.formatMoney(dayNet),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ...dayTxs.map((Transaction tx) => TransactionListItem(
                      transaction: tx,
                      onTap: () => _onTxTap(ctx, tx),
                    )),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTxTap(BuildContext context, Transaction tx) {
    // เปิด Quick-Add ในโหมด edit
    QuickAddSheet.show(context, editingTransaction: tx);
  }
}
