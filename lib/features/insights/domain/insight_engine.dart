import 'insight.dart';
import 'insight_rule.dart';
import 'rules/concentration_rule.dart';
import 'rules/dormancy_rule.dart';
import 'rules/fx_drift_rule.dart';
import 'rules/scattered_balance_rule.dart';

/// Runs the rules and ranks what they produce.
///
/// Pure and synchronous: given a context and a set of dismissals it returns
/// the same cards every time, which is what makes the whole feature testable
/// from seeded data rather than by staring at a screen.
final class InsightEngine {
  const InsightEngine({this.rules = defaultRules});

  /// The shipped rules. Adding one means adding it here and nowhere else.
  static const List<InsightRule> defaultRules = [
    FxDriftRule(),
    ConcentrationRule(),
    ScatteredBalanceRule(),
    DormancyRule(),
  ];

  final List<InsightRule> rules;

  /// Evaluates every rule, drops dismissed cards, and returns the rest
  /// ranked by materiality.
  ///
  /// [dismissedSignatures] holds signatures rather than rule names, so a card
  /// stays dismissed while the situation behind it stays roughly the same and
  /// returns when it has materially changed.
  List<Insight> evaluate(
    InsightContext context, {
    Set<String> dismissedSignatures = const {},
  }) {
    final insights = <Insight>[];

    for (final rule in rules) {
      // One rule throwing must not take the whole Wealth screen down with it.
      // An insight is a nicety; the net worth above it is not.
      final Insight? insight;
      try {
        insight = rule.evaluate(context);
      } on Object {
        continue;
      }
      if (insight == null) continue;
      if (dismissedSignatures.contains(insight.signature)) continue;
      insights.add(insight);
    }

    insights.sort((a, b) => b.materiality.compareTo(a.materiality));
    return insights;
  }
}
