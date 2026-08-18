import '../../../../core/money/money.dart';
import '../insight.dart';
import '../insight_rule.dart';

/// Flags balances nobody has confirmed in a while.
///
/// A stale balance quietly corrupts everything above it: the net worth, the
/// composition bar and the FX drift are all computed from figures the user
/// last vouched for months ago. This is a housekeeping nudge, which is why it
/// is phrased and coloured as attention rather than loss — "you have not
/// updated this" is not the same claim as "you have lost money", and the app
/// must never conflate them.
final class DormancyRule implements InsightRule {
  const DormancyRule();

  @override
  InsightKind get kind => InsightKind.dormancy;

  @override
  Insight? evaluate(InsightContext context) {
    final limit = context.thresholds.dormantAfter;

    var oldestDays = 0;
    final dormant = <Money>[];

    for (final account in context.accounts) {
      final age = account.ageFrom(context.now);
      // A never-updated account is not dormant — it was just created, and its
      // opening balance is as fresh as anything else here.
      if (age == null || age < limit) continue;
      dormant.add(context.homeValueOf(account.balance));
      if (age.inDays > oldestDays) oldestDays = age.inDays;
    }

    if (dormant.isEmpty) return null;

    final total = Money.sum(dormant, context.homeCurrency);

    // Ranked by how much money is behind the stale figures, not by how many
    // accounts: one forgotten salary account matters more than four dusty
    // wallets holding pocket change.
    final materiality = context.shareOfWealth(total);
    if (materiality < context.thresholds.minimumMateriality) return null;

    return Insight(
      kind: kind,
      details: DormancyDetails(
        accountCount: dormant.length,
        oldestDays: oldestDays,
        total: total,
      ),
      materiality: materiality,
      // Bucketed by month, so a dismissed card returns once the situation is
      // meaningfully staler rather than on every passing day.
      signature: 'dormancy:${dormant.length}:${oldestDays ~/ 30}',
    );
  }
}
