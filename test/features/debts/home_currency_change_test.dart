import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/enums.dart';
import 'package:zimam/core/fx/fx_rate.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/debts/data/debts_dao.dart';
import 'package:zimam/features/debts/domain/debt_cost.dart';

/// Regression test for a crash seen on device.
///
/// A user recorded debts while their home currency was EGP, later switched it
/// to USD, and the Debts screen died with
/// `CurrencyMismatchException: cannot subtract USD and EGP directly`.
///
/// The cost breakdown had been handed a rate quoted in the *new* home currency
/// while the frozen creation rate was quoted in the old one, so the
/// subtraction had a different unit on each side. The comparison is now always
/// quoted in the debt's own stored home currency, while the ledger total — a
/// sum across unlike debts — uses the current one. Those two legitimately
/// differ, which is why a single "the home currency" rate could never have
/// served both.
void main() {
  final usd = CurrencyRegistry.of('USD');
  final egp = CurrencyRegistry.of('EGP');

  final recordedOn = DateTime.utc(2025, 3, 14);
  final today = DateTime.utc(2026, 3, 20);

  late AppDatabase db;
  late DebtsDao dao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DebtsDao(db);

    // Recorded back when the home currency was EGP.
    await dao.create(
      id: 'd1',
      counterparty: 'Ahmad Q.',
      direction: DebtDirection.iOwe,
      principal: Money.parse('2000.00', usd),
      homeCurrency: egp,
      rateAtCreation: FxRate.parse(
        base: usd,
        quote: egp,
        rate: '31.00',
        rateDate: recordedOn,
        fetchedAt: recordedOn,
      ),
      createdOn: recordedOn,
    );
  });

  tearDown(() async => db.close());

  FxRate todayRate(Currency quote, String value) => FxRate.parse(
    base: usd,
    quote: quote,
    rate: value,
    rateDate: today,
    fetchedAt: today,
  );

  test('the debt remembers the home currency it was recorded under', () async {
    // Even though the app's home currency has since changed.
    final debt = (await dao.byId('d1'))!;
    expect(debt.homeCurrency, egp);
    expect(debt.rateAtCreation.quote, egp);
  });

  test('quoting in the debt home currency produces the comparison', () async {
    final debt = (await dao.byId('d1'))!;

    // The pair the fixed provider now asks for: the debt's currency into the
    // debt's own home currency.
    final cost = const DebtCostCalculator().compute(
      debt,
      todaysRate: todayRate(egp, '48.50'),
    );

    expect(cost, isNotNull);
    expect(cost!.costAtOriginalRate, Money.parse('62000.00', egp));
    expect(cost.costAtTodaysRate, Money.parse('97000.00', egp));
    expect(cost.totalDrift, Money.parse('35000.00', egp));
    expect(cost.isWorseFor(DebtDirection.iOwe), isTrue);
  });

  test('quoting in the new home currency is refused, not crashed', () async {
    final debt = (await dao.byId('d1'))!;

    // What the buggy provider used to supply: a rate into the *current* home
    // currency, which does not match the frozen rate's quote.
    final cost = const DebtCostCalculator().compute(
      debt,
      todaysRate: todayRate(usd, '1.00'),
    );

    expect(
      cost,
      isNull,
      reason: 'a mismatched quote must yield no comparison rather than an '
          'exception that takes the screen down',
    );
  });

  test('the ledger total is a separate conversion into the current home', () async {
    // Summing unlike debts onto one screen legitimately uses today's home
    // currency, and that is a different question from what one debt has cost.
    // Both are right; they are simply not the same rate.
    final debt = (await dao.byId('d1'))!;
    expect(
      FxRate.identity(usd, today).convert(debt.outstanding),
      Money.parse('2000.00', usd),
    );
  });
}
