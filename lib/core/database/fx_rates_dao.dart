import 'package:drift/drift.dart';

import '../fx/fx_rate.dart';
import '../money/currency.dart';
import 'app_database.dart';
import 'tables.dart';

part 'fx_rates_dao.g.dart';

/// The local rate cache — what makes conversion work with no network.
@DriftAccessor(tables: [FxRates])
class FxRatesDao extends DatabaseAccessor<AppDatabase> with _$FxRatesDaoMixin {
  FxRatesDao(super.db);

  /// The rate for [base]/[quote] on or before [asOf], most recent first.
  ///
  /// "On or before" rather than "on": markets close at weekends and holidays,
  /// so asking for Saturday's rate should return Friday's rather than
  /// nothing. The returned rate carries its own [FxRate.rateDate], so the
  /// caller can see how far back it had to reach and tell the user.
  Future<FxRate?> rateFor(
    Currency base,
    Currency quote, {
    required DateTime asOf,
  }) async {
    if (base == quote) return FxRate.identity(base, asOf);

    final query = select(fxRates)
      ..where(
        (r) =>
            r.baseCode.equals(base.code) &
            r.quoteCode.equals(quote.code) &
            r.rateDate.isSmallerOrEqualValue(asOf) &
            r.deletedAt.isNull(),
      )
      ..orderBy([(r) => OrderingTerm.desc(r.rateDate)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row == null ? null : _toRate(row, base, quote);
  }

  /// The newest cached rate for the pair, whatever its date. Used to report
  /// staleness when there is nothing recent enough to be trustworthy.
  Future<FxRate?> latestFor(Currency base, Currency quote) =>
      rateFor(base, quote, asOf: DateTime.now().toUtc());

  /// Upserts a batch, replacing any existing rate for the same
  /// (base, quote, date). Re-fetching the same day is idempotent.
  Future<void> upsertAll(Iterable<FxRate> rates) async {
    await batch((b) {
      for (final rate in rates) {
        b.insert(
          fxRates,
          FxRatesCompanion.insert(
            baseCode: rate.base.code,
            quoteCode: rate.quote.code,
            rateScaled: rate.rateScaled,
            rateDate: rate.rateDate,
            fetchedAt: rate.fetchedAt,
            updatedAt: Value(DateTime.now()),
          ),
          onConflict: DoUpdate(
            (_) => FxRatesCompanion(
              rateScaled: Value(rate.rateScaled),
              fetchedAt: Value(rate.fetchedAt),
              updatedAt: Value(DateTime.now()),
              deletedAt: const Value(null),
            ),
            target: [fxRates.baseCode, fxRates.quoteCode, fxRates.rateDate],
          ),
        );
      }
    });
  }

  /// The most recent fetch across all pairs, for "rates updated N ago".
  Future<DateTime?> lastFetchedAt() async {
    final maxFetched = fxRates.fetchedAt.max();
    final row = await (selectOnly(fxRates)..addColumns([maxFetched]))
        .getSingleOrNull();
    return row?.read(maxFetched);
  }

  Future<int> countCached() async {
    final total = fxRates.baseCode.count();
    final row = await (selectOnly(fxRates)..addColumns([total])).getSingle();
    return row.read(total) ?? 0;
  }

  FxRate _toRate(CachedFxRate row, Currency base, Currency quote) => FxRate(
    base: base,
    quote: quote,
    rateScaled: row.rateScaled,
    rateDate: row.rateDate,
    fetchedAt: row.fetchedAt,
  );
}
