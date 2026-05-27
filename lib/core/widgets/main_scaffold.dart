import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../extensions/build_context_extensions.dart';

/// ──────────────────────────────────────────────────
/// MainScaffold — Bottom Navigation พร้อม FAB กลาง
/// ──────────────────────────────────────────────────
/// ตาม Design Spec §2.2 — 4 tabs + FAB ตรงกลาง
/// FAB เปิด Quick-Add bottom sheet (จะเชื่อมต่อ Batch 3)
/// ──────────────────────────────────────────────────
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// เปลี่ยน tab โดย preserve state
  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      // initialLocation ถ้ากด tab เดิมซ้ำ จะกลับไปหน้าแรกของ stack
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  /// เปิด Quick-Add Bottom Sheet
  /// TODO(batch-3): เชื่อมต่อ Quick-Add Screen จริงใน Batch 3
  void _openQuickAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Quick-Add Bottom Sheet\n(จะ implement ใน Batch 3)',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,

      // ─── FAB ตรงกลางสำหรับ Quick-Add ───
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQuickAdd(context),
        tooltip: l10n.commonAdd,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ─── BottomAppBar เปิดช่อง FAB กลาง ───
      bottomNavigationBar: BottomAppBar(
        height: 64,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _NavBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: l10n.tabHome,
              isActive: currentIndex == 0,
              onTap: () => _goToBranch(0),
            ),
            _NavBarItem(
              icon: Icons.bar_chart_outlined,
              activeIcon: Icons.bar_chart,
              label: l10n.tabReports,
              isActive: currentIndex == 1,
              onTap: () => _goToBranch(1),
            ),
            const SizedBox(width: 64), // ช่องว่างสำหรับ FAB
            _NavBarItem(
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              label: l10n.tabTransactions,
              isActive: currentIndex == 2,
              onTap: () => _goToBranch(2),
            ),
            _NavBarItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: l10n.tabSettings,
              isActive: currentIndex == 3,
              onTap: () => _goToBranch(3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item เดี่ยวใน BottomAppBar
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color activeColor = context.colors.primary;
    final Color inactiveColor = context.isDarkMode
        ? Colors.white60
        : Colors.black54;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        // Semantic label สำหรับ screen reader
        child: Semantics(
          label: label,
          selected: isActive,
          button: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
