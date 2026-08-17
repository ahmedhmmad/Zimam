import '../database/fx_rates_dao.dart';
import '../money/currency.dart';
import '../money/money.dart';
import 'fx_provider_client.dart';
import 'fx_rate.dart';

/// How trustworthy a converted figure is.
///
/// Surfaced rather than hidden. A net worth computed from three-week-old
/// rates is still worth showing — it is far better than nothing — but the
/// user has to be told, because acting on a stale cross-border figure is
/// exactly how someone mistimes a transfer.
enum RateFreshness {
  /// Today's or yesterday's rate. Weekend gaps land here too.
  fresh,

  /// Between two and seven days old.
  recent,

  /// Over a week old. The UI should say so plainly.
  stale,

  /// Nothing cached for this pair at all — no conversion is possible.
  missing;

  bool get isUsable => this != RateFreshness.missing;
}

/// A converted amount together with how much to trust it.
///
/// Conversion returns this rather than a bare [Money] on purpose: it is not
/// possible to use the result without also receiving its provenance, so no
/// screen can accidentally present a stale figure as current.
final class ConversionResult {
  const ConversionResult({
    required this.amount,
    required this.freshness,
    this.rate,
    this.ageInDays,
  });

  /// Nothing cached for the pair. [amount] is null and callers must show a
  /// placeholder rather than a number.
  const ConversionResult.unavailable()
    : amount = null,
      rate = null,
      freshness = RateFreshness.missing,
      ageInDays = null;

  final Money? amount;
  final FxRate? rate;
  final RateFreshness freshness;

  /// How many days old the underlying rate is.
  final int? ageInDays;

  bool get isAvailable => amount != null;
}

/// Converts money between currencies, from cache first.
///
/// The cache is the primary source and the network is an optimisation, not
/// the other way round. [refresh] is the only method that touches the
/// network, and every conversion works without it ever having succeeded —
/// provided some rates were cached at least once.
final class FxService {
  FxService({
    required this.dao,
    required this.client,
    this.clock = _systemNow,
  });

  static DateTime _systemNow() => DateTime.now().toUtc();

  final FxRatesDao dao;
  final FxProviderClient client;

  /// Injectable so tests can pin "now" and assert staleness deterministically.
  final DateTime Function() clock;

  /// Converts [amount] into [target], using the rate for [asOf] or the most
  /// recent one before it.
  ///
  /// Never throws for a missing rate. A wealth screen that crashes because a
  /// rate is absent is worse than one showing a dash next to one line.
  Future<ConversionResult> convert(
    Money amount,
    Currency target, {
    DateTime? asOf,
  }) async {
    if (amount.currency == target) {
      final at = asOf ?? clock();
      return ConversionResult(
        amount: amount,
        rate: FxRate.identity(target, at),
        freshness: RateFreshness.fresh,
        ageInDays: 0,
      );
    }

    final at = asOf ?? clock();
    final rate = await _resolveRate(amount.currency, target, at);
    if (rate == null) return const ConversionResult.unavailable();

    final age = _daysBetween(rate.rateDate, at);
    return ConversionResult(
      amount: rate.convert(amount),
      rate: rate,
      freshness: _classify(age),
      ageInDays: age,
    );
  }

  /// Finds a rate for the pair, trying the direct quote, then the inverse.
  ///
  /// The provider quotes everything against one base, so a JOD→AED conversion
  /// usually has to go through the stored USD-based rates. Inverting is tried
  /// before triangulating because it loses less precision.
  Future<FxRate?> _resolveRate(
    Currency from,
    Currency to,
    DateTime asOf,
  ) async {
    final direct = await dao.rateFor(from, to, asOf: asOf);
    if (direct != null) return direct;

    final reverse = await dao.rateFor(to, from, asOf: asOf);
    if (reverse != null && reverse.rateScaled != 0) return reverse.inverted();

    return _triangulate(from, to, asOf);
  }

  /// Converts through the provider's base currency when no direct or inverse
  /// quote exists: from → USD → to.
  ///
  /// Two roundings instead of one, so the result can be a minor unit off a
  /// direct quote. That is the cost of a provider that only publishes one
  /// base, and it is far better than refusing to show the figure.
  Future<FxRate?> _triangulate(
    Currency from,
    Currency to,
    DateTime asOf,
  ) async {
    final pivot = CurrencyRegistry.tryOf(pivotCurrencyCode);
    if (pivot == null || from == pivot || to == pivot) return null;

    final fromPivot = await dao.rateFor(pivot, from, asOf: asOf);
    final toPivot = await dao.rateFor(pivot, to, asOf: asOf);
    if (fromPivot == null || toPivot == null || fromPivot.rateScaled == 0) {
      return null;
    }

    // rate(from→to) = rate(pivot→to) / rate(pivot→from)
    final scaled =
        (BigInt.from(toPivot.rateScaled) * BigInt.from(FxRate.scaleFactor)) ~/
        BigInt.from(fromPivot.rateScaled);

    final older = fromPivot.rateDate.isBefore(toPivot.rateDate)
        ? fromPivot
        : toPivot;

    return FxRate(
      base: from,
      quote: to,
      rateScaled: scaled.toInt(),
      // The staler of the two legs governs, so freshness is never overstated.
      rateDate: older.rateDate,
      fetchedAt: older.fetchedAt,
    );
  }

  /// The base the provider quotes against, and the pivot for triangulation.
  static const String pivotCurrencyCode = 'USD';

  /// Fetches today's rates and caches them.
  ///
  /// Returns false rather than throwing when the network is unavailable —
  /// being offline is an ordinary state for this app, not an error.
  Future<bool> refresh({Currency? base}) async {
    final pivot =
        base ?? CurrencyRegistry.tryOf(pivotCurrencyCode) ?? base;
    if (pivot == null) return false;
    try {
      final rates = await client.fetchLatest(pivot);
      await dao.upsertAll(rates);
      return true;
    } on FxFetchException {
      return false;
    }
  }

  /// When rates were last successfully fetched, for the staleness indicator.
  Future<DateTime?> lastRefreshedAt() => dao.lastFetchedAt();

  /// Whether any rates are cached. False means conversion is impossible and
  /// onboarding should try a refresh before showing a net-worth figure.
  Future<bool> hasCachedRates() async => await dao.countCached() > 0;

  static int _daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  static RateFreshness _classify(int ageInDays) {
    if (ageInDays <= 1) return RateFreshness.fresh;
    if (ageInDays <= 7) return RateFreshness.recent;
    return RateFreshness.stale;
  }
}
