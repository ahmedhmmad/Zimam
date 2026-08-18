import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

/// One currency's contribution to net worth.
final class CurrencyHolding {
  const CurrencyHolding({
    required this.currency,
    required this.native,
    required this.inHomeCurrency,
    required this.accountCount,
  });

  final Currency currency;

  /// The total held in this currency, in that currency.
  final Money native;

  /// The same total converted to the home currency.
  final Money inHomeCurrency;

  final int accountCount;

  /// This holding's share of the whole, 0..1. A proportion for the bar, never
  /// money — nothing may turn it back into an amount.
  double shareOf(Money total) => inHomeCurrency.shareOf(total);
}

/// Net worth broken into the two things that can move it.
///
/// The whole premise of the app is that these are different facts. A balance
/// that has not been touched all month can still be worth noticeably less, and
/// a user who cannot see which of the two happened cannot act on either.
final class WealthChange {
  const WealthChange({
    required this.total,
    required this.fromActivity,
    required this.fromExchangeRates,
    required this.since,
  });

  /// The overall change over the period.
  final Money total;

  /// What the user actually moved: balances that went up or down, valued at
  /// today's rates.
  final Money fromActivity;

  /// What the market did: the opening balances, revalued from the old rates to
  /// the new ones.
  final Money fromExchangeRates;

  /// The start of the period being compared.
  final DateTime since;

  bool get isZero => total.isZero;
}

/// A consolidated view of everything the user holds.
final class NetWorth {
  const NetWorth({
    required this.total,
    required this.homeCurrency,
    required this.holdings,
    required this.accountsIncluded,
    required this.accountsUnconvertible,
    this.change,
  });

  /// Everything, in the home currency.
  final Money total;

  final Currency homeCurrency;

  /// Per-currency composition, largest first — the order the categorical
  /// colour ramp is assigned in.
  final List<CurrencyHolding> holdings;

  final int accountsIncluded;

  /// Accounts left out because no exchange rate was available for them.
  ///
  /// Surfaced rather than swallowed: a net worth that silently omits an
  /// account is a wrong number presented as a right one.
  final int accountsUnconvertible;

  /// Null when there is no earlier snapshot to compare against.
  final WealthChange? change;

  bool get isComplete => accountsUnconvertible == 0;
  bool get isEmpty => accountsIncluded == 0;
}

/// Splits a change in net worth into activity and exchange-rate movement.
///
/// The decomposition, for balances `B` and rates `R` at times 0 and 1:
///
/// ```
///   activity = Σ (B₁ − B₀) × R₁     what you moved, at today's prices
///   fx       = Σ B₀ × (R₁ − R₀)     what the market did to what you had
/// ```
///
/// These sum exactly to `Σ B₁R₁ − Σ B₀R₀`, the total change — the cross term
/// cancels, so nothing is double-counted and nothing goes missing. That
/// identity is asserted in the tests, because a split that does not reconcile
/// would quietly misattribute a loss.
///
/// Valuing activity at *today's* rates is the deliberate choice: it answers
/// "what is the money I moved worth now", which is the question someone
/// planning a transfer is actually asking.
final class WealthChangeCalculator {
  const WealthChangeCalculator();

  /// [openingBalances] and [closingBalances] are keyed by account id, each in
  /// its own native currency. [openingRates] and [closingRates] convert a
  /// currency code to the home currency at each end of the period.
  ///
  /// Accounts present only in [closingBalances] count entirely as activity —
  /// they are money newly recorded, not a market move. Accounts missing a rate
  /// at either end are skipped, since attributing them would require inventing
  /// a rate.
  WealthChange compute({
    required Map<String, Money> openingBalances,
    required Map<String, Money> closingBalances,
    required Money Function(Money amount) convertAtOpening,
    required Money Function(Money amount) convertAtClosing,
    required Currency homeCurrency,
    required DateTime since,
  }) {
    var activity = Money.zero(homeCurrency);
    var fx = Money.zero(homeCurrency);

    for (final entry in closingBalances.entries) {
      final closing = entry.value;
      final opening = openingBalances[entry.key];

      if (opening == null) {
        // Newly recorded money. All activity, no market component.
        activity += convertAtClosing(closing);
        continue;
      }
      if (opening.currency != closing.currency) {
        // An account's currency cannot change, so this is corrupt data rather
        // than a real movement. Skipping beats inventing a conversion.
        continue;
      }

      // (B₁ − B₀) × R₁
      activity += convertAtClosing(closing - opening);
      // B₀ × (R₁ − R₀)
      fx += convertAtClosing(opening) - convertAtOpening(opening);
    }

    // Money that existed at the start and is gone from the closing set — an
    // archived or deleted account. Its disappearance is activity.
    for (final entry in openingBalances.entries) {
      if (closingBalances.containsKey(entry.key)) continue;
      activity -= convertAtClosing(entry.value);
    }

    return WealthChange(
      total: activity + fx,
      fromActivity: activity,
      fromExchangeRates: fx,
      since: since,
    );
  }
}
