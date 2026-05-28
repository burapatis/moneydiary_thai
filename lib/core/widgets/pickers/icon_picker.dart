import 'package:flutter/material.dart';

import '../../extensions/build_context_extensions.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../utils/icon_resolver.dart';

/// ──────────────────────────────────────────────────
/// IconPicker — ให้ผู้ใช้เลือก icon
/// ──────────────────────────────────────────────────
/// ใช้ใน:
///   - หน้าสร้าง/แก้ category
///   - หน้าสร้าง/แก้ account
/// ──────────────────────────────────────────────────
class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.selectedIcon,
    required this.onSelected,
    required this.tintColor,
  });

  /// Icon name string ที่ถูกเลือก (เช่น "restaurant")
  final String selectedIcon;

  /// callback เมื่อเลือกใหม่
  final ValueChanged<String> onSelected;

  /// สีที่ใช้ตอน highlight (มาจาก color ของ category/account)
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final List<String> allIcons = IconResolver.allNames;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: allIcons.length,
      itemBuilder: (BuildContext ctx, int i) {
        final String name = allIcons[i];
        final bool isSelected = name == selectedIcon;
        return _IconButton(
          name: name,
          isSelected: isSelected,
          tintColor: tintColor,
          onTap: () => onSelected(name),
        );
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.name,
    required this.isSelected,
    required this.tintColor,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final Color tintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? tintColor.withValues(alpha: 0.15)
              : context.colors.surfaceContainerHighest,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected ? tintColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          IconResolver.resolve(name),
          color: isSelected ? tintColor : context.colors.onSurface,
          size: 22,
        ),
      ),
    );
  }
}
