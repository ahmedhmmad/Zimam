import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../accounts/domain/account.dart';
import '../../wealth/domain/net_worth.dart';
import 'insight.dart';

/// Everything a rule is allowed to look at.
///
/// Assembled once and handed to every rule, so rules cannot reach into the
/// database, cannot perform I/O, and cannot disagree with each other about
/// what the numbers are. That is what makes them plain functions to test.
final class InsightContext {
  const InsightContext({
    required this.netWorth,
    required this.accounts,
    required this.homeCurrency,
    required this.now,
    required this.thresholds,
    this.fxDrift30,
    this.fxDrift90,
    this.homeValueOf = _identity,
  });

  final NetWorth netWorth;

  /// Live accounts only — archived ones are not something to act on.
  final List<Account> accounts;

  final Currency homeCurrency;
  final DateTime now;
  final InsightThresholds thresholds;

  /// Exchange-rate-only movement over each window. Null when there is no
  /// history far enough back to compare against.
  final Money? fxDrift30;
  final Money? fxDrift90;

  /// Converts an account's native balance to the home currency.
  ///
  /// Injected rather than looked up so the rules stay synchronous and pure;
  /// the async conversion happens once, before the engine runs.
  final Money Function(Money amount) homeValueOf;

  static Money _identity(Money amount) => amount;

  /// Share of net worth an amount represents, 0 when there is nothing.
  double shareOfWealth(Money amount) {
    if (netWorth.total.isZero) return 0;
    return (amount.minorUnits.abs() / netWorth.total.minorUnits.abs())
        .clamp(0.0, 1.0);
  }
}

/// User-tunable limits.
final class InsightThresholds {
  const InsightThresholds({
    required this.scatteredBelow,
    this.concentrationShare = 0.6,
    this.dormantAfter = const Duration(days: 60),
    this.minimumMateriality = 0.005,
  });

  /// A balance below this counts as "small", in the home currency. User-set,
  /// because what counts as forgettable depends entirely on the person.
  final Money scatteredBelow;

  /// Above this share in a single currency, concentration is worth mentioning.
  final double concentrationShare;

  /// No balance update in this long and an account is dormant.
  final Duration dormantAfter;

  /// Insights below this share of net worth are dropped.
  ///
  /// A card that reports half a dinar is noise, and noise is what makes people
  /// stop reading the cards that matter.
  final double minimumMateriality;
}

/// A single rule.
///
/// Adding an insight means writing one of these and adding it to the engine's
/// list — no changes to the engine, the context or the UI's card switch beyond
/// the new details type, which the compiler will demand.
abstract interface class InsightRule {
  InsightKind get kind;

  /// Returns null when the rule has nothing to say, which is the common case.
  Insight? evaluate(InsightContext context);
}
