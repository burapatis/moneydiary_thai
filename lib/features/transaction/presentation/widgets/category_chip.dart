import 'package:flutter/material.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/icon_resolver.dart';
import '../../../category/domain/entities/category.dart';

/// ──────────────────────────────────────────────────
/// CategoryChip — chip แสดง category ใน picker
/// ──────────────────────────────────────────────────
/// แสดง icon + ชื่อภาษาไทย ใน horizontal scrollable list
/// ──────────────────────────────────────────────────
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = ColorParser.parse(category.color);
    final IconData iconData = IconResolver.resolve(category.icon);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 76,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? categoryColor.withValues(alpha: 0.15)
              : context.colors.surfaceContainerHighest,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected ? categoryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 20,
                color: categoryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              category.nameTh,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
