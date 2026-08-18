import '../../../core/database/enums.dart';
import '../../../core/fx/fx_rate.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

/// A payment against a debt, carrying the rate on the day it was made.
///
/// The rate is frozen per payment for the same reason the debt freezes its
/// own: paying in instalments across a moving rate means each instalment cost
/// a different amount in the currency the user actually thinks in, and
/// averaging that away would hide the very thing this ledger exists to show.
final class DebtPayment {
  const DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.paidOn,
    required this.rateAtPayment,
    this.notes,
  });

  final String id;
  final String debtId;

  /// In the debt's currency.
  final Money amount;

  final DateTime paidOn;

  /// Debt currency to home currency, on [paidOn].
  final FxRate rateAtPayment;

  final String? notes;

  /// What this instalment actually cost in the home currency.
  Money get costInHomeCurrency => rateAtPayment.convert(amount);
}

/// An obligation, held in the currency it was actually incurred in.
final class Debt {
  const Debt({
    required this.id,
    required this.counterparty,
    required this.direction,
    required this.principal,
    required this.homeCurrency,
    required this.rateAtCreation,
    required this.createdOn,
    this.payments = const [],
    this.dueOn,
    this.settledAt,
    this.notes,
  });

  final String id;
  final String counterparty;
  final DebtDirection direction;

  /// The original amount, in its own currency. Never converted on the way in:
  /// a debt of 2,000 dollars is a debt of 2,000 dollars regardless of what
  /// that is worth today.
  final Money principal;

  /// The home currency *as it was when the debt was recorded*. If the user
  /// later changes their home currency, this debt's original cost must still
  /// mean what it meant at the time.
  final Currency homeCurrency;

  /// Debt currency to home currency, on [createdOn]. Written once, never
  /// updated — it is the historical fact the whole drift feature rests on.
  final FxRate rateAtCreation;

  final DateTime createdOn;
  final DateTime? dueOn;
  final DateTime? settledAt;
  final String? notes;

  final List<DebtPayment> payments;

  Currency get currency => principal.currency;

  bool get isSettled => settledAt != null || outstanding.isZero;

  /// Everything paid so far, in the debt's currency.
  Money get paid =>
      Money.sum(payments.map((p) => p.amount), currency);

  /// What is left to settle, in the debt's currency.
  ///
  /// Floored at zero: overpaying is a data-entry slip, and showing a negative
  /// balance owing would be more confusing than treating the debt as clear.
  Money get outstanding {
    final remaining = principal - paid;
    return remaining.isNegative ? Money.zero(currency) : remaining;
  }

  bool get isOverdue {
    final due = dueOn;
    if (due == null || isSettled) return false;
    return DateTime.now().toUtc().isAfter(due);
  }

  Debt copyWith({List<DebtPayment>? payments, DateTime? settledAt}) => Debt(
    id: id,
    counterparty: counterparty,
    direction: direction,
    principal: principal,
    homeCurrency: homeCurrency,
    rateAtCreation: rateAtCreation,
    createdOn: createdOn,
    payments: payments ?? this.payments,
    dueOn: dueOn,
    settledAt: settledAt ?? this.settledAt,
    notes: notes,
  );

  @override
  bool operator ==(Object other) => other is Debt && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
