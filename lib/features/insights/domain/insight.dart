import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

/// Which rule produced an insight. Also the dismissal key's prefix.
enum InsightKind { fxDrift, concentration, scatteredBalances, dormancy }

/// The numbers behind an insight.
///
/// Structured data, not sentences. The domain stays free of English so the
/// rules can be unit tested without a localisation delegate, and so the same
/// insight phrases itself correctly in Arabic. Presentation turns these into
/// text.
sealed class InsightDetails {
  const InsightDetails();
}

/// What the market did to an untouched balance.
final class FxDriftDetails extends InsightDetails {
  const FxDriftDetails({required this.change, required this.days});

  /// Signed: negative means the rates moved against the user.
  final Money change;

  /// The window this covers — 30 or 90 days.
  final int days;

  bool get isLoss => change.isNegative;
}

/// How much of the whole sits in one currency.
final class ConcentrationDetails extends InsightDetails {
  const ConcentrationDetails({
    required this.currency,
    required this.share,
    required this.amount,
  });

  final Currency currency;

  /// 0..1.
  final double share;
  final Money amount;
}

/// The Scattered Balance Radar: small forgotten holdings, added up.
final class ScatteredDetails extends InsightDetails {
  const ScatteredDetails({
    required this.total,
    required this.accountCount,
    required this.institutionCount,
    required this.threshold,
  });

  /// Combined value of everything under [threshold], in the home currency.
  final Money total;
  final int accountCount;

  /// How many separate places they are spread across — the number that makes
  /// consolidation feel worth doing.
  final int institutionCount;
  final Money threshold;
}

/// Balances nobody has looked at in a while.
final class DormancyDetails extends InsightDetails {
  const DormancyDetails({
    required this.accountCount,
    required this.oldestDays,
    required this.total,
  });

  final int accountCount;
  final int oldestDays;

  /// Combined value of the dormant accounts, in the home currency. This is
  /// what makes one dormant account worth more attention than another.
  final Money total;
}

/// One card on the Wealth screen.
final class Insight {
  const Insight({
    required this.kind,
    required this.details,
    required this.materiality,
    required this.signature,
  });

  final InsightKind kind;
  final InsightDetails details;

  /// How much is at stake, as a share of net worth — 0..1.
  ///
  /// Expressed as a fraction rather than an amount so that rules measuring
  /// quite different things can be ranked against each other honestly. "2% of
  /// your wealth moved on rates" and "2% is sitting forgotten" deserve
  /// comparable prominence; a raw currency amount would let a rule that
  /// happens to touch bigger numbers always win.
  final double materiality;

  /// Identity for dismissal.
  ///
  /// Includes a coarse bucket of the underlying figure, not just the rule
  /// name. Dismissing "68% is in one currency" should stay dismissed while
  /// that stays roughly true — but if it climbs to 90% the situation has
  /// materially changed and the card has earned another appearance. Keyed on
  /// the rule alone it would be silenced forever; keyed on the exact value it
  /// would reappear on every trivial fluctuation.
  final String signature;
}
