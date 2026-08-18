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

/// Today's rate from a debt's currency to the home currency.
///
/// Null when nothing is cached — the detail screen then shows the historical
/// figures alone rather than inventing a comparison.
final todaysRateProvider = FutureProvider.family<FxRate?, Currency>((
  ref,
  currency,
) async {
  final home = await ref.watch(homeCurrencyProvider.future);
  if (home == null) return null;
  if (home == currency) {
    return FxRate.identity(currency, DateTime.now().toUtc());
  }

  final fx = ref.watch(fxServiceProvider);
  final unit = Money.fromMinorUnits(currency.minorUnitsPerMajor, currency);
  final converted = await fx.convert(unit, home);
  if (!converted.isAvailable) return null;

  // Rebuild the per-unit result as a rate so the debt maths can use the same
  // conversion path as everything else.
  return FxRate(
    base: currency,
    quote: home,
    rateScaled: _scaledFrom(converted.amount!, currency, home),
    rateDate: converted.rate?.rateDate ?? DateTime.now().toUtc(),
    fetchedAt: converted.rate?.fetchedAt ?? DateTime.now().toUtc(),
  );
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
  final debt = ref.watch(debtByIdProvider(debtId)).value;
  if (debt == null) return null;
  final rate = await ref.watch(todaysRateProvider(debt.currency).future);
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
