import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// สีพื้นการ์ดแยกหัวข้อ — ใช้ทั้งแอปให้มองเห็นส่วนต่างกันชัด
enum SectionCardVariant {
  primary,
  income,
  expense,
  info,
  insight,
  neutral,
}

/// การ์ดหัวข้อ — พื้นหลังตาม [SectionCardVariant]
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.variant = SectionCardVariant.neutral,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final SectionCardVariant variant;
  final EdgeInsetsGeometry padding;

  static Color backgroundColor(
    BuildContext context,
    SectionCardVariant variant,
  ) {
    if (variant == SectionCardVariant.neutral) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color base = switch (variant) {
      SectionCardVariant.primary => AppColors.primaryContainer,
      SectionCardVariant.income => AppColors.successContainer,
      SectionCardVariant.expense => AppColors.dangerContainer,
      SectionCardVariant.info => AppColors.infoContainer,
      SectionCardVariant.insight => AppColors.warningContainer,
      SectionCardVariant.neutral =>
        Theme.of(context).colorScheme.surfaceContainerHighest,
    };
    return isDark ? base.withValues(alpha: 0.35) : base;
  }

  static SectionCardVariant variantAtIndex(int index) {
    const List<SectionCardVariant> cycle = <SectionCardVariant>[
      SectionCardVariant.primary,
      SectionCardVariant.income,
      SectionCardVariant.info,
      SectionCardVariant.insight,
      SectionCardVariant.neutral,
    ];
    return cycle[index % cycle.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor(context, variant),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );
  }
}
