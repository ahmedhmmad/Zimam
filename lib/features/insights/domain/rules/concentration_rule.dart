import '../insight.dart';
import '../insight_rule.dart';

/// Flags when most of the user's wealth sits in one currency.
///
/// Stated as a fact, not as advice. "68% of your wealth is in one currency" is
/// something the user may not have noticed; "you should diversify" is a
/// recommendation this app is in no position to make, and would put it in
/// financial-advice territory it has no business in.
final class ConcentrationRule implements InsightRule {
  const ConcentrationRule();

  @override
  InsightKind get kind => InsightKind.concentration;

  @override
  Insight? evaluate(InsightContext context) {
    final holdings = context.netWorth.holdings;
    // One currency is not concentration, it is simply not being cross-border.
    // Telling someone with a single currency that 100% is in one currency is
    // noise, not insight.
    if (holdings.length < 2) return null;

    final largest = holdings.first; // holdings arrive sorted by value
    final share = largest.shareOf(context.netWorth.total);
    if (share < context.thresholds.concentrationShare) return null;

    return Insight(
      kind: kind,
      details: ConcentrationDetails(
        currency: largest.currency,
        share: share,
        amount: largest.inHomeCurrency,
      ),
      // The share itself is the materiality: how much is at stake is exactly
      // how much sits in that one currency.
      materiality: share,
      // Bucketed to 5% steps, so drifting from 68% to 69% does not bring a
      // dismissed card back, while 68% to 90% does.
      signature: 'concentration:${largest.currency.code}'
          ':${(share * 20).round()}',
    );
  }
}
