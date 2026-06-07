import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/report/presentation/screens/reports_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/transaction/presentation/screens/transactions_screen.dart';
import '../widgets/main_scaffold.dart';
import '../../l10n/gen/app_localizations.dart';

/// ──────────────────────────────────────────────────
/// App Router — กำหนดเส้นทางการนำทางทั้งหมด
/// ──────────────────────────────────────────────────
/// ใช้ go_router ที่ declarative + รองรับ deep link
/// + รองรับ StatefulShellRoute สำหรับ bottom nav ที่ preserve state
/// ──────────────────────────────────────────────────

/// Route paths รวมที่นี่ป้องกัน typo
abstract final class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String reports = '/reports';
  static const String transactions = '/transactions';
  static const String settings = '/settings';
}

/// Riverpod provider สำหรับ GoRouter (สามารถ test ได้)
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      // ───── Shell route สำหรับ Bottom Nav ─────
      // StatefulShellRoute ให้แต่ละ tab มี navigator แยก
      // = preserve state เมื่อเปลี่ยน tab
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Branch 1: Home
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          // Branch 2: Reports
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.reports,
                name: 'reports',
                builder: (BuildContext context, GoRouterState state) =>
                    const ReportsScreen(),
              ),
            ],
          ),
          // Branch 3: Transactions
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.transactions,
                name: 'transactions',
                builder: (BuildContext context, GoRouterState state) =>
                    const TransactionsScreen(),
              ),
            ],
          ),
          // Branch 4: Settings
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    // Error fallback
    errorBuilder: (BuildContext context, GoRouterState state) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      return Scaffold(
        body: Center(
          child: Text(l10n.routerPageNotFound(state.uri.toString())),
        ),
      );
    },
  );
});
