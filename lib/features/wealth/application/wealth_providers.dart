import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../accounts/application/accounts_providers.dart';
import '../domain/net_worth.dart';
import 'wealth_service.dart';

final wealthServiceProvider = Provider<WealthService>(
  (ref) => WealthService(
    accountsDao: ref.watch(accountsDaoProvider),
    fx: ref.watch(fxServiceProvider),
  ),
);

/// The Wealth screen's whole model.
///
/// Null while the home currency is unset — that is the onboarding state, not
/// an error, and the router sends the user to onboarding rather than showing
/// a figure with no currency behind it.
final netWorthProvider = FutureProvider<NetWorth?>((ref) async {
  final home = await ref.watch(homeCurrencyProvider.future);
  if (home == null) return null;

  final accounts = await ref.watch(accountsProvider.future);
  return ref.watch(wealthServiceProvider).compute(
    accounts: accounts,
    homeCurrency: home,
  );
});

/// Whether onboarding still needs to run. Drives the router's redirect.
final needsOnboardingProvider = Provider<AsyncValue<bool>>(
  (ref) => ref.watch(homeCurrencyProvider).whenData((c) => c == null),
);

/// Fires a rate refresh once at startup, and reports whether it succeeded.
///
/// Failure is unremarkable — the app runs from cache — so this returns a bool
/// rather than throwing, and nothing blocks on it.
final rateRefreshProvider = FutureProvider<bool>(
  (ref) => ref.watch(fxServiceProvider).refresh(),
);

/// When rates were last successfully fetched, for the staleness line.
final lastRateRefreshProvider = FutureProvider<DateTime?>((ref) async {
  // Depend on the refresh so this recomputes once it completes.
  await ref.watch(rateRefreshProvider.future);
  return ref.watch(fxServiceProvider).lastRefreshedAt();
});
