import '../../../core/fx/fx_service.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../accounts/data/accounts_dao.dart';
import '../../accounts/domain/account.dart';
import '../domain/net_worth.dart';

/// Assembles the Wealth screen's figures from accounts and cached rates.
///
/// Everything here is read-only and works offline: if rates are cached, the
/// net worth is computed; if they are not, the accounts that cannot be
/// converted are counted and reported rather than silently dropped.
final class WealthService {
  const WealthService({
    required this.accountsDao,
    required this.fx,
    this.comparisonWindow = const Duration(days: 30),
  });

  final AccountsDao accountsDao;
  final FxService fx;

  /// How far back the activity/FX split looks. Thirty days matches the
  /// "last 30 days" caption on the screen.
  final Duration comparisonWindow;

  Future<NetWorth> compute({
    required List<Account> accounts,
    required Currency homeCurrency,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now().toUtc();

    // Archived accounts keep their history but leave net worth.
    final live = accounts.where((a) => !a.isArchived).toList();

    final byCurrency = <Currency, List<Account>>{};
    for (final account in live) {
      byCurrency.putIfAbsent(account.currency, () => []).add(account);
    }

    var total = Money.zero(homeCurrency);
    var included = 0;
    var unconvertible = 0;
    final holdings = <CurrencyHolding>[];

    for (final entry in byCurrency.entries) {
      final currency = entry.key;
      final native = Money.sum(
        entry.value.map((a) => a.balance),
        currency,
      );

      final converted = await fx.convert(native, homeCurrency, asOf: at);
      if (!converted.isAvailable) {
        // No rate for this currency. Counted, not hidden — a total that
        // quietly omits an account is a wrong number worn as a right one.
        unconvertible += entry.value.length;
        continue;
      }

      included += entry.value.length;
      total += converted.amount!;
      holdings.add(
        CurrencyHolding(
          currency: currency,
          native: native,
          inHomeCurrency: converted.amount!,
          accountCount: entry.value.length,
        ),
      );
    }

    // Largest first: this is the order the categorical ramp is assigned in, so
    // the biggest holding always takes the strongest step.
    holdings.sort(
      (a, b) => b.inHomeCurrency.minorUnits.compareTo(a.inHomeCurrency.minorUnits),
    );

    final change = await _changeSince(
      accounts: live,
      homeCurrency: homeCurrency,
      now: at,
    );

    return NetWorth(
      total: total,
      homeCurrency: homeCurrency,
      holdings: holdings,
      accountsIncluded: included,
      accountsUnconvertible: unconvertible,
      change: change,
    );
  }

  /// The activity/FX split over [comparisonWindow].
  ///
  /// Returns null when there is nothing to compare against — a first run has
  /// no history, and inventing a baseline would report the user's opening
  /// balances as a gain they just made.
  Future<WealthChange?> _changeSince({
    required List<Account> accounts,
    required Currency homeCurrency,
    required DateTime now,
  }) async {
    final since = now.subtract(comparisonWindow);
    final opening = await accountsDao.balancesAsOf(since);
    if (opening.isEmpty) return null;

    final liveIds = accounts.map((a) => a.id).toSet();
    final closing = {
      for (final account in accounts) account.id: account.balance,
    };
    // Drop opening entries for accounts that are archived now: their
    // disappearance from net worth is not something the user "spent".
    opening.removeWhere((id, _) => !liveIds.contains(id));
    if (opening.isEmpty) return null;

    // Resolve both ends' rates once per currency rather than per account.
    final currencies = {
      ...opening.values.map((m) => m.currency),
      ...closing.values.map((m) => m.currency),
    };
    final openingRates = <Currency, Money Function(Money)>{};
    final closingRates = <Currency, Money Function(Money)>{};

    for (final currency in currencies) {
      final then = await fx.convert(
        Money.fromMinorUnits(currency.minorUnitsPerMajor, currency),
        homeCurrency,
        asOf: since,
      );
      final nowRate = await fx.convert(
        Money.fromMinorUnits(currency.minorUnitsPerMajor, currency),
        homeCurrency,
        asOf: now,
      );
      if (!then.isAvailable || !nowRate.isAvailable) continue;

      // Both ends convert through the same one-major-unit reference, so the
      // ratio is exact integer arithmetic rather than a re-derived rate.
      openingRates[currency] = (amount) => amount.scaledBy(
        then.amount!.minorUnits,
        currency.minorUnitsPerMajor,
      ).let(homeCurrency);
      closingRates[currency] = (amount) => amount.scaledBy(
        nowRate.amount!.minorUnits,
        currency.minorUnitsPerMajor,
      ).let(homeCurrency);
    }

    // Anything without rates at both ends cannot be attributed.
    opening.removeWhere((_, m) => !openingRates.containsKey(m.currency));
    closing.removeWhere((_, m) => !closingRates.containsKey(m.currency));
    if (opening.isEmpty && closing.isEmpty) return null;

    return const WealthChangeCalculator().compute(
      openingBalances: opening,
      closingBalances: closing,
      convertAtOpening: (m) => openingRates[m.currency]!(m),
      convertAtClosing: (m) => closingRates[m.currency]!(m),
      homeCurrency: homeCurrency,
      since: since,
    );
  }
}

extension on Money {
  /// Reinterprets a scaled result as being in [target].
  ///
  /// [Money.scaledBy] keeps the source currency because it cannot know a
  /// conversion happened; the ratio applied above is a home-currency-per-unit
  /// figure, so the result is already in home minor units and only the label
  /// needs correcting.
  Money let(Currency target) => Money.fromMinorUnits(minorUnits, target);
}
