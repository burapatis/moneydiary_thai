import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/domain/repositories/transaction_repository.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../../transaction/presentation/widgets/quick_add_sheet.dart';
import '../../../transaction/presentation/widgets/transaction_list_item.dart';

/// ──────────────────────────────────────────────────
/// Home Screen — Today + This Month + Recent
/// ──────────────────────────────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final AsyncValue<TransactionSummary> todaySummaryAsync =
        ref.watch(todaySummaryStreamProvider);
    final AsyncValue<TransactionSummary> monthSummaryAsync =
        ref.watch(thisMonthSummaryStreamProvider);
    final AsyncValue<List<Transaction>> todayTxsAsync =
        ref.watch(todayTransactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: <Widget>[
            const SizedBox(height: AppSpacing.sm),

            // ─── วันนี้ ───
            Text(l10n.homeToday, style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            todaySummaryAsync.when(
              data: (TransactionSummary s) => SectionCard(
                variant: SectionCardVariant.primary,
                child: Text(
                  Formatters.formatMoney(s.net),
                  style: context.textTheme.displayLarge?.copyWith(
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              loading: () => const _LoadingPlaceholder(),
              error: (Object e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: AppSpacing.md),

            // Income/Expense cards
            todaySummaryAsync.when(
              data: (TransactionSummary s) => Row(
                children: <Widget>[
                  Expanded(
                    child: _SummaryCard(
                      label: l10n.homeIncome,
                      amount: s.income,
                      variant: SectionCardVariant.income,
                      color: AppColors.success,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SummaryCard(
                      label: l10n.homeExpense,
                      amount: s.expense,
                      variant: SectionCardVariant.expense,
                      color: AppColors.danger,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(height: 80),
              error: (Object e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ─── เดือนนี้ ───
            Text(l10n.homeThisMonth, style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),

            monthSummaryAsync.when(
              data: (TransactionSummary s) {
                return SectionCard(
                  variant: SectionCardVariant.info,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _MonthRow(
                        label: l10n.homeIncome,
                        amount: s.income,
                        color: AppColors.success,
                      ),
                      const Divider(),
                      _MonthRow(
                        label: l10n.homeExpense,
                        amount: s.expense,
                        color: AppColors.danger,
                      ),
                      const Divider(),
                      _MonthRow(
                        label: l10n.homeBalance,
                        amount: s.net,
                        color: context.colors.onSurface,
                        bold: true,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const _LoadingPlaceholder(),
              error: (Object e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ─── รายการล่าสุดวันนี้ ───
            todayTxsAsync.when(
              data: (List<Transaction> txs) {
                if (txs.isEmpty) return _buildEmptyState(context, l10n);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.homeRecentTransactions,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SectionCard(
                      variant: SectionCardVariant.neutral,
                      child: Column(
                        children: txs
                            .take(5)
                            .map((Transaction tx) => TransactionListItem(
                                  transaction: tx,
                                  onTap: () => QuickAddSheet.show(
                                    context,
                                    editingTransaction: tx,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (Object e, _) => const SizedBox.shrink(),
            ),

            // Padding ล่างสุดเผื่อ FAB
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: <Widget>[
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: context.colors.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.homeEmptyTitle,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.homeEmptySubtitle,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Card สำหรับ "รายรับ/รายจ่ายวันนี้"
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.variant,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final SectionCardVariant variant;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      variant: variant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: context.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Formatters.formatMoney(amount),
            style: context.textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _MonthRow extends StatelessWidget {
  const _MonthRow({
    required this.label,
    required this.amount,
    required this.color,
    this.bold = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            Formatters.formatMoney(amount),
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
