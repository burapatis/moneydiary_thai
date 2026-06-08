import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/report_summary.dart';
import '../providers/report_providers.dart';
import '../widgets/category_pie_chart.dart';

/// ──────────────────────────────────────────────────
/// ReportsScreen — Tab "รายงาน" (Batch 5)
/// ──────────────────────────────────────────────────
/// - Period selector (วัน/สัปดาห์/เดือน/ปี)
/// - Month navigator (เลื่อนซ้าย-ขวา)
/// - Income/Expense/Net summary
/// - Pie chart รายจ่ายตามหมวด
/// - Insight cards
/// ──────────────────────────────────────────────────
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ReportPeriod period = ref.watch(reportPeriodProvider);
    final AsyncValue<ReportSummary> reportAsync =
        ref.watch(reportSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Period selector
            _buildPeriodSelector(context, ref, period),

            // Date navigator
            _buildDateNavigator(context, ref, reportAsync),

            // Body
            Expanded(
              child: reportAsync.when(
                data: (ReportSummary report) =>
                    _buildReport(context, ref, report),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (Object e, _) =>
                    Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Period selector — วัน/สัปดาห์/เดือน/ปี
  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    ReportPeriod current,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: ReportPeriod.values.map((ReportPeriod p) {
          final bool isSelected = p == current;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(reportPeriodProvider.notifier).setPeriod(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary
                      : Colors.transparent,
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  p.labelTh,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : context.colors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Date navigator — เลื่อนซ้าย-ขวา
  Widget _buildDateNavigator(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<ReportSummary> reportAsync,
  ) {
    final String label = reportAsync.maybeWhen(
      data: (ReportSummary r) => _formatPeriodLabel(r),
      orElse: () => '—',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                ref.read(reportAnchorProvider.notifier).previous(),
          ),
          GestureDetector(
            onTap: () => ref.read(reportAnchorProvider.notifier).reset(),
            child: Text(
              label,
              style: context.textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                ref.read(reportAnchorProvider.notifier).next(),
          ),
        ],
      ),
    );
  }

  String _formatPeriodLabel(ReportSummary r) {
    switch (r.period) {
      case ReportPeriod.day:
        return Formatters.formatDateLongTh(r.from);
      case ReportPeriod.week:
        return '${Formatters.formatDateShortTh(r.from)} - ${Formatters.formatDateShortTh(r.to)}';
      case ReportPeriod.month:
        return Formatters.formatMonthYearTh(r.from);
      case ReportPeriod.year:
        return 'ปี ${r.from.year + 543}';
    }
  }

  /// Body หลัก
  Widget _buildReport(
    BuildContext context,
    WidgetRef ref,
    ReportSummary report,
  ) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        // Summary cards
        _buildSummaryCards(context, report),
        const SizedBox(height: AppSpacing.lg),

        // Insight card
        _buildInsightCard(context, ref, report),
        const SizedBox(height: AppSpacing.lg),

        // Pie chart section
        if (report.totalExpense > 0) ...<Widget>[
          Text(
            AppLocalizations.of(context).reportsExpenseByCategory,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            color: SectionCard.backgroundColor(
              context,
              SectionCardVariant.expense,
            ),
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: CategoryPieChart(
                spendings: report.categorySpendings,
                totalExpense: report.totalExpense,
              ),
            ),
          ),
        ] else
          _buildEmptyState(context),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, ReportSummary report) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: SectionCard(
                variant: SectionCardVariant.income,
                child: _miniStat(
                  context,
                  label: AppLocalizations.of(context).homeIncome,
                  value: report.totalIncome,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: SectionCard(
                variant: SectionCardVariant.expense,
                child: _miniStat(
                  context,
                  label: AppLocalizations.of(context).homeExpense,
                  value: report.totalExpense,
                  color: AppColors.danger,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          variant: SectionCardVariant.neutral,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).homeBalance,
                style: context.textTheme.bodyLarge,
              ),
              Text(
                Formatters.formatMoney(report.net),
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      children: <Widget>[
        Text(label, style: context.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          Formatters.formatMoney(value),
          style: context.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Insight card — เปรียบเทียบเดือนก่อน + savings rate
  Widget _buildInsightCard(
    BuildContext context,
    WidgetRef ref,
    ReportSummary report,
  ) {
    final AsyncValue<double> prevExpenseAsync =
        ref.watch(previousPeriodExpenseProvider);

    return prevExpenseAsync.maybeWhen(
      data: (double prevExpense) {
        final List<Widget> insights = <Widget>[];

        // Insight 1: เปรียบเทียบรายจ่าย
        if (prevExpense > 0 && report.totalExpense > 0) {
          final double change =
              ((report.totalExpense - prevExpense) / prevExpense) * 100;
          final bool isLess = change < 0;
          insights.add(_insightRow(
            context,
            icon: isLess ? Icons.trending_down : Icons.trending_up,
            color: isLess ? AppColors.success : AppColors.warning,
            text: isLess
                ? 'รายจ่ายลดลง ${change.abs().toStringAsFixed(0)}% จากช่วงก่อน 🎉'
                : 'รายจ่ายเพิ่มขึ้น ${change.toStringAsFixed(0)}% จากช่วงก่อน',
          ));
        }

        // Insight 2: savings rate
        if (report.totalIncome > 0) {
          final double rate = report.savingsRate;
          insights.add(_insightRow(
            context,
            icon: Icons.savings_outlined,
            color: rate >= 20 ? AppColors.success : AppColors.warning,
            text: rate >= 0
                ? 'อัตราการออม ${rate.toStringAsFixed(0)}% ของรายรับ'
                : 'ใช้จ่ายเกินรายรับ ${rate.abs().toStringAsFixed(0)}%',
          ));
        }

        // Insight 3: หมวดที่ใช้มากสุด
        if (report.categorySpendings.isNotEmpty) {
          final CategorySpending top = report.categorySpendings.first;
          insights.add(_insightRow(
            context,
            icon: Icons.star_outline,
            color: AppColors.info,
            text:
                'หมวดที่ใช้มากสุด: ${top.category.nameTh} (${top.percentage.toStringAsFixed(0)}%)',
          ));
        }

        if (insights.isEmpty) return const SizedBox.shrink();

        return SectionCard(
          variant: SectionCardVariant.insight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.lightbulb_outline,
                      size: 18, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    AppLocalizations.of(context).reportsInsightTitle,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ...insights,
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _insightRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: context.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: <Widget>[
          Icon(Icons.bar_chart_outlined,
              size: 80, color: context.colors.outline),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppLocalizations.of(context).reportsNoData,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'เริ่มบันทึกรายการเพื่อดูรายงาน',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
