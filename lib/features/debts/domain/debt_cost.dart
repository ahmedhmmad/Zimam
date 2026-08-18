import '../../../core/database/enums.dart';
import '../../../core/fx/fx_rate.dart';
import '../../../core/money/money.dart';
import 'debt.dart';

/// What a debt has cost, and what it will cost, in the home currency.
///
/// The point of the whole ledger. Someone who borrowed 2,000 dollars when the
/// dinar was stronger owes the same 2,000 dollars today and a different number
/// of dinars — and unless something says so, that difference is invisible
/// until the moment they transfer the money.
final class DebtCost {
  const DebtCost({
    required this.costAtOriginalRate,
    required this.costAtTodaysRate,
    required this.paidSoFar,
    required this.paidAtOriginalRate,
    required this.outstandingToday,
    required this.outstandingAtOriginalRate,
  });

  /// What the whole principal would have cost on the day it was recorded.
  final Money costAtOriginalRate;

  /// What the whole principal would cost if settled entirely today.
  final Money costAtTodaysRate;

  /// What the instalments actually cost, each at its own day's rate.
  final Money paidSoFar;

  /// What those same instalments would have cost at the original rate.
  final Money paidAtOriginalRate;

  /// What the remaining balance would cost today.
  final Money outstandingToday;

  /// What the remaining balance would have cost at the original rate.
  final Money outstandingAtOriginalRate;

  /// Drift already locked in by payments made — money genuinely spent, or
  /// saved, because of when the instalments happened to fall.
  Money get realisedDrift => paidSoFar - paidAtOriginalRate;

  /// Drift still riding on the unpaid balance. Moves until it is settled.
  Money get unrealisedDrift => outstandingToday - outstandingAtOriginalRate;

  /// The whole difference between what the debt looked like on day one and
  /// what it has actually amounted to.
  Money get totalDrift => realisedDrift + unrealisedDrift;

  /// Whether the rate has moved against the user.
  ///
  /// Direction is the whole question. A debt growing in home-currency terms is
  /// bad news when you owe it and good news when you are owed it, so the same
  /// arithmetic has to be read two different ways depending on which side of
  /// the debt the user is on.
  bool isWorseFor(DebtDirection direction) {
    if (totalDrift.isZero) return false;
    return switch (direction) {
      DebtDirection.iOwe => totalDrift.isPositive,
      DebtDirection.owedToMe => totalDrift.isNegative,
    };
  }

  bool get hasDrift => !totalDrift.isZero;
}

/// Computes what a debt has cost and will cost.
///
/// Pure and synchronous: it takes today's rate rather than fetching one, so
/// the arithmetic can be tested exhaustively without a database or a network.
final class DebtCostCalculator {
  const DebtCostCalculator();

  /// [todaysRate] converts the debt's currency to its home currency now.
  /// Null when no rate is cached, in which case only the historical figures
  /// are knowable and [DebtCost] is not returned at all.
  DebtCost? compute(Debt debt, {required FxRate? todaysRate}) {
    if (todaysRate == null) return null;

    final original = debt.rateAtCreation;

    // Each instalment converted at the rate on the day it was actually paid —
    // this is what the user really handed over.
    final paidSoFar = Money.sum(
      debt.payments.map((p) => p.costInHomeCurrency),
      debt.homeCurrency,
    );

    // The same instalments valued at the original rate, so the comparison is
    // like-for-like on quantity and differs only by rate.
    final paidAtOriginalRate = Money.sum(
      debt.payments.map((p) => original.convert(p.amount)),
      debt.homeCurrency,
    );

    final outstanding = debt.outstanding;

    return DebtCost(
      costAtOriginalRate: original.convert(debt.principal),
      costAtTodaysRate: todaysRate.convert(debt.principal),
      paidSoFar: paidSoFar,
      paidAtOriginalRate: paidAtOriginalRate,
      outstandingToday: todaysRate.convert(outstanding),
      outstandingAtOriginalRate: original.convert(outstanding),
    );
  }
}

/// The Debts screen's headline figures.
final class DebtPosition {
  const DebtPosition({
    required this.iOwe,
    required this.owedToMe,
    required this.net,
    required this.unconvertible,
  });

  /// Outstanding balances converted to the home currency at today's rates.
  final Money iOwe;
  final Money owedToMe;

  /// Positive means the user is owed more than they owe.
  final Money net;

  /// Debts left out because no rate was available — counted, not hidden.
  final int unconvertible;

  bool get isComplete => unconvertible == 0;
  bool get isEmpty => iOwe.isZero && owedToMe.isZero && unconvertible == 0;
}
