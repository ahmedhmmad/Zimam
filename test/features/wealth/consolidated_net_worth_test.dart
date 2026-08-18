import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/enums.dart';
import 'package:zimam/core/database/fx_rates_dao.dart';
import 'package:zimam/core/fx/fx_provider_client.dart';
import 'package:zimam/core/fx/fx_rate.dart';
import 'package:zimam/core/fx/fx_service.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/accounts/data/accounts_dao.dart';
import 'package:zimam/features/wealth/application/wealth_service.dart';

class _Offline implements FxProviderClient {
  @override
  Future<List<FxRate>> fetchLatest(Currency base) async =>
      throw const FxFetchException('offline');
}

/// Phase 2's acceptance condition, stated as a test:
///
/// > a user can add three accounts in three different currencies and see a
/// > correct consolidated net worth in a fourth currency.
///
/// Run against the real database and the real FX service, with only the
/// network stubbed out — so it exercises the whole path from a typed balance
/// to the figure on the hero line.
void main() {
  final usd = CurrencyRegistry.of('USD');
  final aed = CurrencyRegistry.of('AED');
  final egp = CurrencyRegistry.of('EGP');
  final jod = CurrencyRegistry.of('JOD'); // the fourth, home currency

  late AppDatabase db;
  late AccountsDao accountsDao;
  late WealthService wealth;

  final today = DateTime.utc(2026, 3, 20);

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    accountsDao = AccountsDao(db);
    final rates = FxRatesDao(db);

    // The provider quotes against USD, so JOD conversions triangulate.
    await rates.upsertAll([
      for (final (quote, rate) in [
        (jod, '0.709'),
        (aed, '3.6725'),
        (egp, '48.5'),
      ])
        FxRate.parse(
          base: usd,
          quote: quote,
          rate: rate,
          rateDate: today,
          fetchedAt: today,
        ),
    ]);

    wealth = WealthService(
      accountsDao: accountsDao,
      fx: FxService(dao: rates, client: _Offline(), clock: () => today),
    );
  });

  tearDown(() async => db.close());

  Future<void> addAccount(
    String id,
    String name,
    Currency currency,
    String balance,
  ) => accountsDao.create(
    id: id,
    snapshotId: '${id}_s',
    name: name,
    currency: currency,
    type: AccountType.bank,
    openingBalance: Money.parse(balance, currency),
    observedAt: today,
  );

  test('three currencies consolidate into a fourth', () async {
    await addAccount('a1', 'Emirates NBD', aed, '32400.00');
    await addAccount('a2', 'Wise', usd, '4780.25');
    await addAccount('a3', 'Banque Misr', egp, '41200.00');

    final accounts = await accountsDao.getAll();
    final result = await wealth.compute(
      accounts: accounts,
      homeCurrency: jod,
      now: today,
    );

    expect(result.homeCurrency, jod);
    expect(result.accountsIncluded, 3);
    expect(
      result.accountsUnconvertible,
      0,
      reason: 'every currency has a rate, so nothing may be dropped',
    );

    // Worked by hand:
    //   32,400.00 AED / 3.6725 = 8,822.33 USD  x 0.709 = 6,254.83 JOD
    //    4,780.25 USD                          x 0.709 = 3,389.20 JOD
    //   41,200.00 EGP / 48.5    =   849.48 USD x 0.709 =   602.28 JOD
    //                                          total  = 10,246.31 JOD
    final total = result.total.minorUnits;
    expect(
      (total - 10246310).abs(),
      lessThan(2000),
      reason: 'expected about 10,246 JOD, got ${result.total}',
    );

    // The holdings must add up to the headline figure, or the composition bar
    // is telling a different story from the hero number above it.
    final summed = Money.sum(
      result.holdings.map((h) => h.inHomeCurrency),
      jod,
    );
    expect(summed, result.total);
  });

  test('holdings are ordered largest first, for the colour ramp', () async {
    await addAccount('a1', 'Small', egp, '1000.00');
    await addAccount('a2', 'Large', aed, '32400.00');
    await addAccount('a3', 'Middle', usd, '4780.25');

    final result = await wealth.compute(
      accounts: await accountsDao.getAll(),
      homeCurrency: jod,
      now: today,
    );

    final values = result.holdings
        .map((h) => h.inHomeCurrency.minorUnits)
        .toList();
    expect(
      values,
      orderedEquals(List.of(values)..sort((a, b) => b.compareTo(a))),
    );
    expect(result.holdings.first.currency, aed);
  });

  test('shares sum to one', () async {
    await addAccount('a1', 'One', aed, '10000.00');
    await addAccount('a2', 'Two', usd, '5000.00');

    final result = await wealth.compute(
      accounts: await accountsDao.getAll(),
      homeCurrency: jod,
      now: today,
    );

    final shares = result.holdings.map((h) => h.shareOf(result.total));
    expect(shares.reduce((a, b) => a + b), closeTo(1.0, 1e-6));
  });

  test('an archived account leaves net worth but keeps its history', () async {
    await addAccount('a1', 'Active', aed, '10000.00');
    await addAccount('a2', 'Old', usd, '5000.00');

    final before = await wealth.compute(
      accounts: await accountsDao.getAll(),
      homeCurrency: jod,
      now: today,
    );
    await accountsDao.setArchived('a2', archived: true);
    final after = await wealth.compute(
      accounts: await accountsDao.getAll(),
      homeCurrency: jod,
      now: today,
    );

    expect(after.accountsIncluded, before.accountsIncluded - 1);
    expect(after.total < before.total, isTrue);
    expect(
      await accountsDao.historyFor('a2'),
      isNotEmpty,
      reason: 'archiving must not discard the snapshots',
    );
  });

  test('an account in a currency with no rate is reported, not hidden',
      () async {
    final vnd = CurrencyRegistry.of('VND'); // no rate seeded
    await addAccount('a1', 'Known', aed, '10000.00');
    await addAccount('a2', 'Unknown', vnd, '5000000');

    final result = await wealth.compute(
      accounts: await accountsDao.getAll(),
      homeCurrency: jod,
      now: today,
    );

    expect(result.accountsIncluded, 1);
    expect(result.accountsUnconvertible, 1);
    expect(
      result.isComplete,
      isFalse,
      reason: 'the screen must be able to say the total is partial',
    );
  });

  test('updating a balance appends a snapshot rather than replacing one',
      () async {
    await addAccount('a1', 'Bank al Etihad', jod, '9120.500');
    await accountsDao.recordBalance(
      snapshotId: 's2',
      accountId: 'a1',
      amount: Money.parse('9500.000', jod),
      observedAt: today.add(const Duration(days: 1)),
    );

    final history = await accountsDao.historyFor('a1');
    expect(history, hasLength(2));

    final accounts = await accountsDao.getAll();
    expect(
      accounts.single.balance,
      Money.parse('9500.000', jod),
      reason: 'the newest snapshot is the current balance',
    );
  });

  test('no accounts gives an empty result, not a crash', () async {
    final result = await wealth.compute(
      accounts: const [],
      homeCurrency: jod,
      now: today,
    );
    expect(result.isEmpty, isTrue);
    expect(result.total, Money.zero(jod));
    expect(result.holdings, isEmpty);
  });
}
