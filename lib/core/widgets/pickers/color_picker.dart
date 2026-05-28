import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/icon_resolver.dart';

/// ──────────────────────────────────────────────────
/// ColorPicker — ให้ผู้ใช้เลือกสี (12 สีพื้นฐาน)
/// ──────────────────────────────────────────────────
/// อ้างอิงสีจาก AppColors.categoryPalette
/// ──────────────────────────────────────────────────
class AppColorPicker extends StatelessWidget {
  const AppColorPicker({
    super.key,
    required this.selectedColor,
    required this.onSelected,
  });

  /// Color hex string ที่เลือก (เช่น "0xFF10B981")
  final String selectedColor;

  /// callback คืน hex string ใหม่
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final Color currentColor = ColorParser.parse(selectedColor);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: AppColors.categoryPalette.length,
      itemBuilder: (BuildContext ctx, int i) {
        final Color color = AppColors.categoryPalette[i];
        final bool isSelected = color.toARGB32() == currentColor.toARGB32();
        final String hex =
            '0x${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}';
        return _ColorButton(
          color: color,
          isSelected: isSelected,
          onTap: () => onSelected(hex),
        );
      },
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
