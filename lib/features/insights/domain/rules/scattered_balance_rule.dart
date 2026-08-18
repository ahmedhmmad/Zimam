import '../../../../core/money/money.dart';
import '../insight.dart';
import '../insight_rule.dart';

/// The Scattered Balance Radar.
///
/// The app's headline feature, and the reason it exists: money left behind in
/// accounts too small to think about individually is invisible one balance at
/// a time and obvious in aggregate. A hundred here and eighty there across
/// four countries is real money that nobody is looking at.
///
/// The count of *institutions* is deliberately part of the finding. Five small
/// balances at one bank is tidy-up work; five across four institutions is the
/// thing worth doing something about, and it is the number that makes
/// consolidation feel worth the afternoon.
final class ScatteredBalanceRule implements InsightRule {
  const ScatteredBalanceRule();

  @override
  InsightKind get kind => InsightKind.scatteredBalances;

  @override
  Insight? evaluate(InsightContext context) {
    final threshold = context.thresholds.scatteredBelow;

    final small = <_SmallBalance>[];
    for (final account in context.accounts) {
      // Compared in the home currency, not natively: 500 of a weak currency
      // and 500 of a strong one are not remotely the same amount of forgotten
      // money, and a native comparison would flag the wrong ones.
      final home = context.homeValueOf(account.balance);
      if (home.isNegative || home.isZero) continue;
      if (home >= threshold) continue;
      small.add(
        _SmallBalance(
          home: home,
          institution: account.institution ?? account.name,
        ),
      );
    }

    // A single small balance is not "scattered" — it is one small balance.
    if (small.length < 2) return null;

    final total = Money.sum(
      small.map((s) => s.home),
      context.homeCurrency,
    );
    final institutions = small.map((s) => s.institution).toSet().length;

    final materiality = context.shareOfWealth(total);
    if (materiality < context.thresholds.minimumMateriality) return null;

    return Insight(
      kind: kind,
      details: ScatteredDetails(
        total: total,
        accountCount: small.length,
        institutionCount: institutions,
        threshold: threshold,
      ),
      materiality: materiality,
      signature: 'scattered:${small.length}:$institutions',
    );
  }
}

final class _SmallBalance {
  const _SmallBalance({required this.home, required this.institution});
  final Money home;
  final String institution;
}
