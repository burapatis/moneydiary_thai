import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../domain/entities/report_summary.dart';

/// ──────────────────────────────────────────────────
/// CategoryPieChart — Pie chart รายจ่ายตามหมวด
/// ──────────────────────────────────────────────────
/// แสดง top categories + center hole มียอดรวม
/// แตะ section → highlight
/// ──────────────────────────────────────────────────
class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    super.key,
    required this.spendings,
    required this.totalExpense,
  });

  final List<CategorySpending> spendings;
  final double totalExpense;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.spendings.isEmpty) {
      return _buildEmpty(context);
    }

    // แสดง top 6 + รวมที่เหลือเป็น "อื่นๆ"
    final List<CategorySpending> displaySpendings = _prepareDisplayData();

    return Column(
      children: <Widget>[
        SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 70,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: _buildSections(displaySpendings),
                ),
              ),
              // Center text — ยอดรวม
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'รวมรายจ่าย',
                    style: context.textTheme.bodySmall,
                  ),
                  Text(
                    Formatters.formatMoney(widget.totalExpense),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Legend
        _buildLegend(context, displaySpendings),
      ],
    );
  }

  /// เตรียมข้อมูล: top 6 + รวมที่เหลือ
  List<CategorySpending> _prepareDisplayData() {
    if (widget.spendings.length <= 6) return widget.spendings;

    final List<CategorySpending> top6 = widget.spendings.take(6).toList();
    return top6;
  }

  List<PieChartSectionData> _buildSections(
    List<CategorySpending> spendings,
  ) {
    return List<PieChartSectionData>.generate(spendings.length, (int i) {
      final CategorySpending s = spendings[i];
      final bool isTouched = i == _touchedIndex;
      final double radius = isTouched ? 36 : 28;
      final Color color = ColorParser.parse(s.category.color);

      return PieChartSectionData(
        value: s.amount,
        color: color,
        radius: radius,
        showTitle: isTouched,
        title: '${s.percentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontFamily: 'Sarabun',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(
    BuildContext context,
    List<CategorySpending> spendings,
  ) {
    return Column(
      children: spendings.map((CategorySpending s) {
        final Color color = ColorParser.parse(s.category.color);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: <Widget>[
              // Color dot + icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconResolver.resolve(s.category.icon),
                  size: 18,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Name + count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.category.nameTh,
                      style: context.textTheme.bodyMedium,
                    ),
                    Text(
                      '${s.transactionCount} รายการ · ${s.percentage.toStringAsFixed(1)}%',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              // Amount
              Text(
                Formatters.formatMoney(s.amount),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: context.colors.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ยังไม่มีรายจ่ายในช่วงนี้',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
