import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/enums.dart';
import '../../../core/fx/fx_rate.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../data/debts_dao.dart';
import '../domain/debt.dart';
import '../domain/debt_cost.dart';

final debtsDaoProvider = Provider<DebtsDao>(
  (ref) => DebtsDao(ref.watch(databaseProvider)),
);

final debtsProvider = StreamProvider<List<Debt>>(
  (ref) => ref.watch(debtsDaoProvider).watchAll(),
);

final debtByIdProvider = Provider.family<AsyncValue<Debt?>, String>(
  (ref, id) => ref
      .watch(debtsProvider)
      .whenData((all) => all.where((d) => d.id == id).firstOrNull),
);

/// A currency pair. Records compare by value, so this works as a family key.
typedef CurrencyPair = ({Currency from, Currency to});

/// Today's rate for an explicit pair.
///
/// Keyed on both ends rather than just the source, because two callers need
/// two *different* quote currencies and conflating them was a crash:
///
/// * The cost breakdown must quote in the debt's own stored home currency —
///   the one frozen at creation — since that is the unit `rateAtCreation` is
///   in and the comparison subtracts the two.
/// * The ledger total must quote in the *current* home currency, because it is
///   summing unlike debts into one figure on screen.
///
/// When the user changes their home currency after recording a debt those two
/// differ, and a single provider returning "the home currency" gave the cost
/// calculation a rate quoted in the wrong unit.
///
/// Null when nothing is cached — callers then show the historical figures
/// alone rather than inventing a comparison.
final rateForPairProvider = FutureProvider.family<FxRate?, CurrencyPair>((
  ref,
  pair,
) async {
  if (pair.from == pair.to) {
    return FxRate.identity(pair.from, DateTime.now().toUtc());
  }

  final fx = ref.watch(fxServiceProvider);
  final unit = Money.fromMinorUnits(
    pair.from.minorUnitsPerMajor,
    pair.from,
  );
  final converted = await fx.convert(unit, pair.to);
  if (!converted.isAvailable) return null;

  // Rebuild the per-unit result as a rate so the debt maths can use the same
  // conversion path as everything else.
  return FxRate(
    base: pair.from,
    quote: pair.to,
    rateScaled: _scaledFrom(converted.amount!, pair.from, pair.to),
    rateDate: converted.rate?.rateDate ?? DateTime.now().toUtc(),
    fetchedAt: converted.rate?.fetchedAt ?? DateTime.now().toUtc(),
  );
});

/// Today's rate from [currency] into the app's current home currency.
final todaysRateProvider = FutureProvider.family<FxRate?, Currency>((
  ref,
  currency,
) async {
  final home = await ref.watch(homeCurrencyProvider.future);
  if (home == null) return null;
  return ref.watch(rateForPairProvider((from: currency, to: home)).future);
});

/// One major unit of [from] is worth [perUnit] of [to]; express that as a
/// rate scaled by [FxRate.scaleFactor].
int _scaledFrom(Money perUnit, Currency from, Currency to) {
  // perUnit is in `to`'s minor units for one major unit of `from`, so the
  // rate is perUnit / to.minorUnitsPerMajor.
  return (BigInt.from(perUnit.minorUnits) *
          BigInt.from(FxRate.scaleFactor) ~/
          BigInt.from(to.minorUnitsPerMajor))
      .toInt();
}

/// The cost breakdown for one debt.
final debtCostProvider = FutureProvider.family<DebtCost?, String>((
  ref,
  debtId,
) async {
  // Awaited rather than sampled: reading the stream's current snapshot
  // returns null while it is still loading, which blanked the cost card on
  // the first frame and left it blank until something else forced a rebuild.
  final debts = await ref.watch(debtsProvider.future);
  final debt = debts.where((d) => d.id == debtId).firstOrNull;
  if (debt == null) return null;

  // The debt's own home currency, not the app's current one: the comparison
  // subtracts today's cost from the cost at creation, and both have to be in
  // the unit the frozen rate was recorded in.
  final rate = await ref.watch(
    rateForPairProvider((from: debt.currency, to: debt.homeCurrency)).future,
  );
  return const DebtCostCalculator().compute(debt, todaysRate: rate);
});

/// The Debts screen's headline: what is owed each way, and the net.
final debtPositionProvider = FutureProvider<DebtPosition?>((ref) async {
  final home = await ref.watch(homeCurrencyProvider.future);
  if (home == null) return null;

  final debts = await ref.watch(debtsProvider.future);
  var iOwe = Money.zero(home);
  var owedToMe = Money.zero(home);
  var unconvertible = 0;

  for (final debt in debts) {
    if (debt.isSettled) continue;
    final rate = await ref.watch(todaysRateProvider(debt.currency).future);
    if (rate == null) {
      unconvertible++;
      continue;
    }
    // Outstanding, not principal: a debt half repaid is half a debt.
    final converted = rate.convert(debt.outstanding);
    switch (debt.direction) {
      case DebtDirection.iOwe:
        iOwe += converted;
      case DebtDirection.owedToMe:
        owedToMe += converted;
    }
  }

  return DebtPosition(
    iOwe: iOwe,
    owedToMe: owedToMe,
    net: owedToMe - iOwe,
    unconvertible: unconvertible,
  );
});
