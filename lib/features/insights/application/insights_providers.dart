import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../wealth/application/wealth_providers.dart';
import '../domain/insight.dart';
import '../domain/insight_engine.dart';
import '../domain/insight_rule.dart';

final insightEngineProvider = Provider<InsightEngine>(
  (ref) => const InsightEngine(),
);

final dismissedInsightsProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(settingsDaoProvider).watchDismissedInsights(),
);

/// The scattered-balance threshold, as [Money] in the home currency.
///
/// Defaults to 100 major units when unset — a round number the user can then
/// move. There is no universally right value: what counts as forgettable
/// depends on the person, which is why it is a setting at all.
final scatteredThresholdProvider = FutureProvider<Money?>((ref) async {
  final home = await ref.watch(homeCurrencyProvider.future);
  if (home == null) return null;

  final stored = await ref
      .watch(settingsDaoProvider)
      .scatteredThresholdMinor();
  return Money.fromMinorUnits(
    stored ?? 100 * home.minorUnitsPerMajor,
    home,
  );
});

/// The ranked, undismissed cards for the Wealth screen.
final insightsProvider = FutureProvider<List<Insight>>((ref) async {
  final wealth = await ref.watch(netWorthProvider.future);
  final home = await ref.watch(homeCurrencyProvider.future);
  final threshold = await ref.watch(scatteredThresholdProvider.future);
  if (wealth == null || home == null || threshold == null) return const [];

  final accounts = await ref.watch(accountsProvider.future);
  final dismissed = await ref.watch(dismissedInsightsProvider.future);
  final fx = ref.watch(fxServiceProvider);
  final now = DateTime.now().toUtc();

  // Conversion happens here, once, so the rules themselves stay synchronous
  // and pure. A currency with no cached rate contributes nothing rather than
  // failing the whole set of cards.
  final rates = <String, Money>{};
  for (final currency in accounts.map((a) => a.currency).toSet()) {
    final unit = Money.fromMinorUnits(currency.minorUnitsPerMajor, currency);
    final converted = await fx.convert(unit, home, asOf: now);
    if (converted.isAvailable) rates[currency.code] = converted.amount!;
  }

  Money toHome(Money amount) {
    if (amount.currency == home) return amount;
    final perUnit = rates[amount.currency.code];
    if (perUnit == null) return Money.zero(home);
    return Money.fromMinorUnits(
      amount
          .scaledBy(perUnit.minorUnits, amount.currency.minorUnitsPerMajor)
          .minorUnits,
      home,
    );
  }

  final context = InsightContext(
    netWorth: wealth,
    accounts: accounts.where((a) => !a.isArchived).toList(),
    homeCurrency: home,
    now: now,
    thresholds: InsightThresholds(scatteredBelow: threshold),
    fxDrift30: wealth.change?.fromExchangeRates,
    homeValueOf: toHome,
  );

  return ref
      .watch(insightEngineProvider)
      .evaluate(context, dismissedSignatures: dismissed);
});

/// Dismisses a card and refreshes the list.
final insightDismisserProvider = Provider<Future<void> Function(String)>((ref) {
  return (signature) async {
    await ref.read(settingsDaoProvider).dismissInsight(signature);
    ref.invalidate(insightsProvider);
  };
});
