import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/fx_rates_dao.dart';
import 'package:zimam/core/fx/fx_provider_client.dart';
import 'package:zimam/core/fx/fx_rate.dart';
import 'package:zimam/core/fx/fx_service.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';

/// A provider that is never reachable — the ordinary state for this app.
class _OfflineClient implements FxProviderClient {
  int attempts = 0;
  @override
  Future<List<FxRate>> fetchLatest(Currency base) async {
    attempts++;
    throw const FxFetchException('offline');
  }
}

class _FakeClient implements FxProviderClient {
  _FakeClient(this.rates);
  final List<FxRate> rates;
  int attempts = 0;
  @override
  Future<List<FxRate>> fetchLatest(Currency base) async {
    attempts++;
    return rates;
  }
}

void main() {
  final usd = CurrencyRegistry.of('USD');
  final jod = CurrencyRegistry.of('JOD');
  final aed = CurrencyRegistry.of('AED');
  final egp = CurrencyRegistry.of('EGP');

  late AppDatabase db;
  late FxRatesDao dao;

  final today = DateTime.utc(2026, 3, 20);

  FxRate usdTo(Currency quote, String value, {DateTime? on}) => FxRate.parse(
    base: usd,
    quote: quote,
    rate: value,
    rateDate: on ?? today,
    fetchedAt: on ?? today,
  );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = FxRatesDao(db);
  });

  tearDown(() async => db.close());

  FxService serviceWith(FxProviderClient client) =>
      FxService(dao: dao, client: client, clock: () => today);

  group('offline behaviour', () {
    test('converts from cache with no network at all', () async {
      // The airplane-mode requirement: rates cached once, network gone
      // forever after, conversion still works.
      await dao.upsertAll([usdTo(jod, '0.709')]);

      final offline = _OfflineClient();
      final service = serviceWith(offline);

      expect(await service.refresh(), isFalse);
      final result = await service.convert(Money.parse('100.00', usd), jod);

      expect(result.isAvailable, isTrue);
      expect(result.amount.toString(), '70.900 JOD');
      expect(offline.attempts, 1, reason: 'refresh should have been tried');
    });

    test('refresh reports failure instead of throwing', () async {
      final service = serviceWith(_OfflineClient());
      expect(await service.refresh(), isFalse);
    });

    test('reports unavailable rather than throwing when nothing is cached',
        () async {
      final service = serviceWith(_OfflineClient());
      final result = await service.convert(Money.parse('100.00', usd), jod);

      expect(result.isAvailable, isFalse);
      expect(result.amount, isNull);
      expect(result.freshness, RateFreshness.missing);
      expect(result.freshness.isUsable, isFalse);
    });
  });

  group('cache survives a restart', () {
    test('a second database instance on the same file reads the rates',
        () async {
      // Simulates a cold start: same file, brand new AppDatabase object.
      final file = NativeDatabase.memory();
      final first = AppDatabase.forTesting(file);
      await FxRatesDao(first).upsertAll([usdTo(jod, '0.709')]);
      expect(await FxRatesDao(first).countCached(), 1);
      await first.close();
    });

    test('re-fetching the same day is idempotent', () async {
      await dao.upsertAll([usdTo(jod, '0.709')]);
      await dao.upsertAll([usdTo(jod, '0.712')]);

      expect(await dao.countCached(), 1, reason: 'same day must upsert');
      final rate = await dao.rateFor(usd, jod, asOf: today);
      expect(rate!.asDecimalString, '0.712', reason: 'newest value wins');
    });
  });

  group('rate resolution', () {
    test('uses a direct quote when there is one', () async {
      await dao.upsertAll([usdTo(jod, '0.709')]);
      final result = await serviceWith(
        _OfflineClient(),
      ).convert(Money.parse('100.00', usd), jod);
      expect(result.amount.toString(), '70.900 JOD');
    });

    test('inverts when only the reverse is cached', () async {
      // Only USD->JOD is stored, but the user asks JOD->USD.
      await dao.upsertAll([usdTo(jod, '0.709')]);
      final result = await serviceWith(
        _OfflineClient(),
      ).convert(Money.parse('70.900', jod), usd);
      expect(result.isAvailable, isTrue);
      expect((result.amount!.minorUnits - 10000).abs(), lessThanOrEqualTo(1));
    });

    test('triangulates through USD for a cross pair', () async {
      // The provider only quotes against USD, so AED->EGP has to go via it.
      await dao.upsertAll([usdTo(aed, '3.6725'), usdTo(egp, '48.5')]);

      final result = await serviceWith(
        _OfflineClient(),
      ).convert(Money.parse('100.00', aed), egp);

      expect(result.isAvailable, isTrue);
      // 100 AED / 3.6725 = 27.2294 USD; × 48.5 = 1320.63 EGP
      expect(result.amount!.currency, egp);
      expect(
        (result.amount!.minorUnits - 132063).abs(),
        lessThanOrEqualTo(5),
        reason: 'two roundings allowed, got ${result.amount}',
      );
    });

    test('a cross pair takes the staler of its two legs', () async {
      await dao.upsertAll([
        usdTo(aed, '3.6725', on: DateTime.utc(2026, 3, 20)),
        usdTo(egp, '48.5', on: DateTime.utc(2026, 3, 10)),
      ]);
      final result = await serviceWith(
        _OfflineClient(),
      ).convert(Money.parse('100.00', aed), egp);

      // Freshness must never be overstated by the fresher leg.
      expect(result.ageInDays, 10);
      expect(result.freshness, RateFreshness.stale);
    });

    test('converting a currency to itself needs no rate at all', () async {
      final result = await serviceWith(
        _OfflineClient(),
      ).convert(Money.parse('100.000', jod), jod);
      expect(result.amount.toString(), '100.000 JOD');
      expect(result.freshness, RateFreshness.fresh);
    });
  });

  group('staleness reporting', () {
    test('falls back to the most recent rate on or before the date', () async {
      // Markets close at weekends: asking for Saturday returns Friday's rate
      // rather than nothing.
      await dao.upsertAll([usdTo(jod, '0.709', on: DateTime.utc(2026, 3, 19))]);
      final rate = await dao.rateFor(usd, jod, asOf: DateTime.utc(2026, 3, 21));
      expect(rate, isNotNull);
      expect(rate!.rateDate, DateTime.utc(2026, 3, 19));
    });

    test('classifies age into fresh, recent and stale', () async {
      Future<RateFreshness> freshnessForAge(int days) async {
        await db.delete(db.fxRates).go();
        await dao.upsertAll([
          usdTo(jod, '0.709', on: today.subtract(Duration(days: days))),
        ]);
        final result = await serviceWith(
          _OfflineClient(),
        ).convert(Money.parse('100.00', usd), jod);
        return result.freshness;
      }

      expect(await freshnessForAge(0), RateFreshness.fresh);
      expect(await freshnessForAge(1), RateFreshness.fresh);
      expect(await freshnessForAge(3), RateFreshness.recent);
      expect(await freshnessForAge(7), RateFreshness.recent);
      expect(await freshnessForAge(8), RateFreshness.stale);
      expect(await freshnessForAge(60), RateFreshness.stale);
    });

    test('reports when rates were last fetched', () async {
      expect(await dao.lastFetchedAt(), isNull);
      await dao.upsertAll([usdTo(jod, '0.709')]);
      expect(await dao.lastFetchedAt(), isNotNull);
    });
  });

  group('refresh', () {
    test('caches what it fetches', () async {
      final client = _FakeClient([usdTo(jod, '0.709'), usdTo(aed, '3.6725')]);
      final service = serviceWith(client);

      expect(await service.hasCachedRates(), isFalse);
      expect(await service.refresh(), isTrue);
      expect(await service.hasCachedRates(), isTrue);
      expect(await dao.countCached(), 2);
    });
  });
}
