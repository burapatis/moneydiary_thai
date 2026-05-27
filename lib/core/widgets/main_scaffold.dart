import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/transaction/presentation/widgets/quick_add_sheet.dart';
import '../../l10n/gen/app_localizations.dart';
import '../extensions/build_context_extensions.dart';

/// ──────────────────────────────────────────────────
/// MainScaffold — Bottom Navigation พร้อม FAB กลาง
/// ──────────────────────────────────────────────────
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  /// เปิด Quick-Add Bottom Sheet (Batch 3 — ของจริงแล้ว!)
  void _openQuickAdd(BuildContext context) {
    QuickAddSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openQuickAdd(context),
        tooltip: l10n.commonAdd,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            const SizedBox(width: 64),
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
    final Color inactiveColor =
        context.isDarkMode ? Colors.white60 : Colors.black54;

    return Expanded(
      child: InkWell(
        onTap: onTap,
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
