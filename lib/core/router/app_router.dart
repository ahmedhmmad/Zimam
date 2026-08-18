import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/account_form_screen.dart';
import '../../features/accounts/presentation/accounts_screen.dart';
import '../../features/debts/presentation/debt_detail_screen.dart';
import '../../features/debts/presentation/debt_form_screen.dart';
import '../../features/debts/presentation/debts_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/wealth/presentation/wealth_screen.dart';
import '../providers.dart';
import '../widgets/home_shell.dart';

/// Path constants. Screens navigate with these, never with string literals.
abstract final class AppRoutes {
  static const wealth = '/wealth';
  static const accounts = '/accounts';
  static const debts = '/debts';
  static const settings = '/settings';
  static const onboarding = '/onboarding';
  static const accountForm = '/account';
  static const debtForm = '/debt';
  static const debtDetail = '/debt-detail';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.wealth,

    /// Sends a first-run user to onboarding.
    ///
    /// Gated on the home currency rather than a "seen onboarding" flag,
    /// because the currency is what the rest of the app actually needs. While
    /// it is still loading the redirect stays put: bouncing to onboarding and
    /// back would flash the wrong screen on every cold start.
    redirect: (context, state) {
      final home = ref.read(homeCurrencyProvider);
      if (home.isLoading) return null;

      final needsOnboarding = home.value == null;
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (needsOnboarding && !atOnboarding) return AppRoutes.onboarding;
      if (!needsOnboarding && atOnboarding) return AppRoutes.wealth;
      return null;
    },
    refreshListenable: _ProviderRefresh(ref),

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

      // Above the shell: these cover the navigation bar rather than sitting
      // beside it as a fourth tab.
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountForm,
        builder: (context, state) =>
            AccountFormScreen(accountId: state.uri.queryParameters['id']),
      ),
      GoRoute(
        path: AppRoutes.debtForm,
        builder: (context, state) => const DebtFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.debtDetail,
        builder: (context, state) =>
            DebtDetailScreen(debtId: state.uri.queryParameters['id'] ?? ''),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(state.error?.toString() ?? 'Route not found')),
    ),
  );
});

/// Re-runs the redirect when the home currency arrives or changes.
class _ProviderRefresh extends ChangeNotifier {
  _ProviderRefresh(Ref ref) {
    ref.listen(homeCurrencyProvider, (_, _) => notifyListeners());
  }
}
