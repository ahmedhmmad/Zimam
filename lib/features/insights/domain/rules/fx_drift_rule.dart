import '../../../../core/money/money.dart';
import '../insight.dart';
import '../insight_rule.dart';

/// Reports value change caused by exchange rates alone.
///
/// The differentiator as a card: money that moved while the user did nothing.
/// It reports both directions — a favourable drift is as much a fact as an
/// unfavourable one, and only ever showing bad news would train people to
/// dread the card and stop reading it.
final class FxDriftRule implements InsightRule {
  const FxDriftRule();

  @override
  InsightKind get kind => InsightKind.fxDrift;

  @override
  Insight? evaluate(InsightContext context) {
    // Both windows are offered; the more material one is what gets said. A
    // quiet month inside a bad quarter is worth surfacing as the quarter.
    final candidates = <(Money, int)>[
      if (context.fxDrift30 != null) (context.fxDrift30!, 30),
      if (context.fxDrift90 != null) (context.fxDrift90!, 90),
    ];
    if (candidates.isEmpty) return null;

    candidates.sort(
      (a, b) => b.$1.minorUnits.abs().compareTo(a.$1.minorUnits.abs()),
    );
    final (change, days) = candidates.first;
    if (change.isZero) return null;

    final materiality = context.shareOfWealth(change);
    if (materiality < context.thresholds.minimumMateriality) return null;

    return Insight(
      kind: kind,
      details: FxDriftDetails(change: change, days: days),
      materiality: materiality,
      // Bucketed to whole percent so ordinary daily wobble does not
      // resurrect a dismissed card.
      signature: 'fxDrift:$days:${(materiality * 100).round()}'
          ':${change.isNegative ? 'down' : 'up'}',
    );
  }
}
