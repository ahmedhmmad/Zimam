import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/debts/presentation/debts_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/wealth/presentation/wealth_screen.dart';
import '../widgets/home_shell.dart';

/// Path constants. Screens navigate with these, never with string literals.
abstract final class AppRoutes {
  static const wealth = '/wealth';
  static const accounts = '/accounts';
  static const debts = '/debts';
  static const settings = '/settings';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.wealth,
    routes: [
      // The three bottom-navigation destinations. Each branch keeps its own
      // navigation stack, so drilling into an account and switching tabs does
      // not lose your place.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wealth,
                builder: (context, state) => const WealthScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.accounts,
                builder: (context, state) => const AccountsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.debts,
                builder: (context, state) => const DebtsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Settings sits above the shell: it is not a destination, and it should
      // cover the navigation bar rather than appear as a fourth tab.
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(state.error?.toString() ?? 'Route not found')),
    ),
  );
});
