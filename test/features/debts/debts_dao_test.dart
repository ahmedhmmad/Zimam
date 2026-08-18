import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/enums.dart';
import 'package:zimam/core/fx/fx_rate.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/debts/data/debts_dao.dart';
import 'package:zimam/features/debts/domain/debt_cost.dart';

/// The frozen rate has to survive the round trip through storage, or the whole
/// drift feature is decoration. These tests go through the real database.
void main() {
  final usd = CurrencyRegistry.of('USD');
  final jod = CurrencyRegistry.of('JOD');

  final borrowedOn = DateTime.utc(2025, 3, 14);
  final today = DateTime.utc(2026, 3, 20);

  late AppDatabase db;
  late DebtsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = DebtsDao(db);
  });

  tearDown(() async => db.close());

  FxRate rateOf(String value, {DateTime? on}) => FxRate.parse(
    base: usd,
    quote: jod,
    rate: value,
    rateDate: on ?? borrowedOn,
    fetchedAt: on ?? borrowedOn,
  );

  Future<void> createDebt({
    String id = 'd1',
    String amount = '2000.00',
    String rate = '0.709',
    DebtDirection direction = DebtDirection.iOwe,
  }) => dao.create(
    id: id,
    counterparty: 'Ahmad Q.',
    direction: direction,
    principal: Money.parse(amount, usd),
    homeCurrency: jod,
    rateAtCreation: rateOf(rate),
    createdOn: borrowedOn,
  );

  test('the creation rate round trips exactly', () async {
    await createDebt();
    final debt = (await dao.getAll()).single;

    expect(debt.rateAtCreation.rateScaled, rateOf('0.709').rateScaled);
    expect(debt.rateAtCreation.asDecimalString, '0.709');
    expect(debt.rateAtCreation.base, usd);
    expect(debt.rateAtCreation.quote, jod);
  });

  test('a debt created at an old rate shows repayment cost drift', () async {
    // The phase's stated done-condition.
    await createDebt();
    final debt = (await dao.byId('d1'))!;

    final cost = const DebtCostCalculator().compute(
      debt,
      todaysRate: rateOf('0.731', on: today),
    )!;

    expect(cost.costAtOriginalRate, Money.parse('1418.000', jod));
    expect(cost.costAtTodaysRate, Money.parse('1462.000', jod));
    expect(cost.totalDrift, Money.parse('44.000', jod));
    expect(cost.isWorseFor(DebtDirection.iOwe), isTrue);
  });

  test('partial payments reduce the balance accurately', () async {
    // The phase's other stated done-condition.
    await createDebt();

    await dao.addPayment(
      id: 'p1',
      debtId: 'd1',
      amount: Money.parse('500.00', usd),
      rateAtPayment: rateOf('0.750', on: DateTime.utc(2025, 9, 1)),
      paidOn: DateTime.utc(2025, 9, 1),
    );
    await dao.addPayment(
      id: 'p2',
      debtId: 'd1',
      amount: Money.parse('250.00', usd),
      rateAtPayment: rateOf('0.720', on: DateTime.utc(2026, 1, 5)),
      paidOn: DateTime.utc(2026, 1, 5),
    );

    final debt = (await dao.byId('d1'))!;
    expect(debt.paid, Money.parse('750.00', usd));
    expect(debt.outstanding, Money.parse('1250.00', usd));
    expect(debt.isSettled, isFalse);
  });

  test('each payment keeps its own rate, not a shared one', () async {
    await createDebt();
    await dao.addPayment(
      id: 'p1',
      debtId: 'd1',
      amount: Money.parse('100.00', usd),
      rateAtPayment: rateOf('0.750', on: DateTime.utc(2025, 9, 1)),
      paidOn: DateTime.utc(2025, 9, 1),
    );
    await dao.addPayment(
      id: 'p2',
      debtId: 'd1',
      amount: Money.parse('100.00', usd),
      rateAtPayment: rateOf('0.690', on: DateTime.utc(2026, 1, 5)),
      paidOn: DateTime.utc(2026, 1, 5),
    );

    final debt = (await dao.byId('d1'))!;
    final costs = debt.payments.map((p) => p.costInHomeCurrency).toList();

    // Same 100 USD, different days, different real cost.
    expect(costs[0], Money.parse('75.000', jod));
    expect(costs[1], Money.parse('69.000', jod));
  });

  test('payments come back in the order they were made', () async {
    await createDebt();
    for (final (id, day) in [('p2', 20), ('p1', 5), ('p3', 25)]) {
      await dao.addPayment(
        id: id,
        debtId: 'd1',
        amount: Money.parse('10.00', usd),
        rateAtPayment: rateOf('0.709', on: DateTime.utc(2025, 9, day)),
        paidOn: DateTime.utc(2025, 9, day),
      );
    }
    final debt = (await dao.byId('d1'))!;
    expect(
      debt.payments.map((p) => p.paidOn.day),
      orderedEquals([5, 20, 25]),
    );
  });

  test('settling and reopening', () async {
    await createDebt();
    await dao.setSettled('d1', settled: true);
    expect((await dao.byId('d1'))!.isSettled, isTrue);

    await dao.setSettled('d1', settled: false);
    expect((await dao.byId('d1'))!.isSettled, isFalse);
  });

  test('a soft-deleted debt disappears from the ledger', () async {
    await createDebt();
    await dao.softDelete('d1');
    expect(await dao.getAll(), isEmpty);
    expect(await dao.byId('d1'), isNull);
  });

  test('deleting a debt takes its payments with it', () async {
    await createDebt();
    await dao.addPayment(
      id: 'p1',
      debtId: 'd1',
      amount: Money.parse('100.00', usd),
      rateAtPayment: rateOf('0.709'),
      paidOn: borrowedOn,
    );

    await (db.delete(db.debts)..where((d) => d.id.equals('d1'))).go();
    expect(await db.select(db.debtPayments).get(), isEmpty);
  });

  test('both directions are stored and read back', () async {
    await createDebt(id: 'd1');
    await createDebt(id: 'd2', direction: DebtDirection.owedToMe);

    final all = await dao.getAll();
    expect(
      all.map((d) => d.direction).toSet(),
      {DebtDirection.iOwe, DebtDirection.owedToMe},
    );
  });

  group('amending a debt', () {
    test('leaves the frozen rate untouched', () async {
      // The point of allowing edits at all: correcting a typo must not
      // silently re-baseline the comparison the whole feature rests on.
      await createDebt();
      final before = (await dao.byId('d1'))!.rateAtCreation;

      await dao.updateDetails(
        id: 'd1',
        counterparty: 'Ahmad Qasem',
        direction: DebtDirection.iOwe,
        principal: Money.parse('2500.00', usd),
        notes: 'corrected',
      );

      final after = (await dao.byId('d1'))!;
      expect(after.rateAtCreation.rateScaled, before.rateScaled);
      expect(after.rateAtCreation.rateDate, before.rateDate);
      expect(after.createdOn, borrowedOn);
      expect(after.currency, usd);
    });

    test('a corrected principal is valued at the original rate', () async {
      await createDebt();
      await dao.updateDetails(
        id: 'd1',
        counterparty: 'Ahmad Q.',
        direction: DebtDirection.iOwe,
        principal: Money.parse('2500.00', usd),
      );

      final cost = const DebtCostCalculator().compute(
        (await dao.byId('d1'))!,
        todaysRate: rateOf('0.731', on: today),
      )!;

      // 2,500 x 0.709 = 1,772.500, not 2,500 at some newer rate.
      expect(cost.costAtOriginalRate, Money.parse('1772.500', jod));
      expect(cost.costAtTodaysRate, Money.parse('1827.500', jod));
    });

    test('updates the editable fields', () async {
      await createDebt();
      final due = DateTime.utc(2026, 12, 1);
      await dao.updateDetails(
        id: 'd1',
        counterparty: 'Layla H.',
        direction: DebtDirection.owedToMe,
        principal: Money.parse('900.00', usd),
        dueOn: due,
        notes: 'moved to the other side',
      );

      final debt = (await dao.byId('d1'))!;
      expect(debt.counterparty, 'Layla H.');
      expect(debt.direction, DebtDirection.owedToMe);
      expect(debt.principal, Money.parse('900.00', usd));
      expect(debt.dueOn, due);
      expect(debt.notes, 'moved to the other side');
    });

    test('payments and their own rates survive an edit', () async {
      await createDebt();
      await dao.addPayment(
        id: 'p1',
        debtId: 'd1',
        amount: Money.parse('500.00', usd),
        rateAtPayment: rateOf('0.750', on: DateTime.utc(2025, 9, 1)),
        paidOn: DateTime.utc(2025, 9, 1),
      );

      await dao.updateDetails(
        id: 'd1',
        counterparty: 'Ahmad Q.',
        direction: DebtDirection.iOwe,
        principal: Money.parse('2500.00', usd),
      );

      final debt = (await dao.byId('d1'))!;
      expect(debt.payments, hasLength(1));
      expect(
        debt.payments.single.costInHomeCurrency,
        Money.parse('375.000', jod),
      );
      // Outstanding tracks the corrected principal.
      expect(debt.outstanding, Money.parse('2000.00', usd));
    });

    test('clearing the due date and notes is possible', () async {
      await dao.create(
        id: 'd9',
        counterparty: 'X',
        direction: DebtDirection.iOwe,
        principal: Money.parse('100.00', usd),
        homeCurrency: jod,
        rateAtCreation: rateOf('0.709'),
        createdOn: borrowedOn,
        dueOn: DateTime.utc(2026, 1, 1),
        notes: 'temporary',
      );

      await dao.updateDetails(
        id: 'd9',
        counterparty: 'X',
        direction: DebtDirection.iOwe,
        principal: Money.parse('100.00', usd),
      );

      final debt = (await dao.byId('d9'))!;
      expect(debt.dueOn, isNull);
      expect(debt.notes, isNull);
    });
  });

  test('the home currency at creation is preserved', () async {
    // If the user later switches home currency, this debt's original cost
    // must still mean what it meant when it was recorded.
    await createDebt();
    expect((await dao.byId('d1'))!.homeCurrency, jod);
  });
}
