import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/enums.dart';
import 'package:zimam/core/fx/fx_rate.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/debts/domain/debt.dart';
import 'package:zimam/features/debts/domain/debt_cost.dart';

/// Phase 4's done-condition: a debt created at an old rate shows repayment
/// cost drift, and partial payments reduce the balance accurately.
void main() {
  final usd = CurrencyRegistry.of('USD');
  final jod = CurrencyRegistry.of('JOD');
  final aed = CurrencyRegistry.of('AED');

  final borrowedOn = DateTime.utc(2025, 3, 14);
  final today = DateTime.utc(2026, 3, 20);

  const calculator = DebtCostCalculator();

  FxRate rate(String value, {Currency? base, DateTime? on}) => FxRate.parse(
    base: base ?? usd,
    quote: jod,
    rate: value,
    rateDate: on ?? borrowedOn,
    fetchedAt: on ?? borrowedOn,
  );

  Debt debt({
    String principal = '2000.00',
    Currency? currency,
    String rateThen = '0.709',
    DebtDirection direction = DebtDirection.iOwe,
    List<DebtPayment> payments = const [],
  }) {
    final c = currency ?? usd;
    return Debt(
      id: 'd1',
      counterparty: 'Ahmad Q.',
      direction: direction,
      principal: Money.parse(principal, c),
      homeCurrency: jod,
      rateAtCreation: rate(rateThen, base: c),
      createdOn: borrowedOn,
      payments: payments,
    );
  }

  DebtPayment payment(
    String amount, {
    required String atRate,
    Currency? currency,
    DateTime? on,
    String id = 'p1',
  }) {
    final c = currency ?? usd;
    return DebtPayment(
      id: id,
      debtId: 'd1',
      amount: Money.parse(amount, c),
      paidOn: on ?? today,
      rateAtPayment: rate(atRate, base: c, on: on ?? today),
    );
  }

  group('the historical rate is frozen', () {
    test('original cost is computed at the rate on the day it was recorded',
        () {
      // 2,000 USD at 0.709 = 1,418.000 JOD, and that never changes however
      // the market moves afterwards.
      final cost = calculator.compute(debt(), todaysRate: rate('0.731'))!;
      expect(cost.costAtOriginalRate, Money.parse('1418.000', jod));
    });

    test("today's cost uses today's rate", () {
      // 2,000 USD at 0.731 = 1,462.000 JOD
      final cost = calculator.compute(debt(), todaysRate: rate('0.731'))!;
      expect(cost.costAtTodaysRate, Money.parse('1462.000', jod));
    });

    test('the drift is the difference between them', () {
      final cost = calculator.compute(debt(), todaysRate: rate('0.731'))!;
      expect(cost.totalDrift, Money.parse('44.000', jod));
      expect(cost.hasDrift, isTrue);
    });

    test('a rate that has not moved shows no drift', () {
      final cost = calculator.compute(debt(), todaysRate: rate('0.709'))!;
      expect(cost.totalDrift, Money.zero(jod));
      expect(cost.hasDrift, isFalse);
      expect(cost.isWorseFor(DebtDirection.iOwe), isFalse);
    });

    test('no cached rate means no comparison rather than a wrong one', () {
      expect(calculator.compute(debt(), todaysRate: null), isNull);
    });
  });

  group('direction changes what the drift means', () {
    test('a debt growing in home terms is worse when you owe it', () {
      final cost = calculator.compute(
        debt(direction: DebtDirection.iOwe),
        todaysRate: rate('0.731'),
      )!;
      expect(cost.totalDrift.isPositive, isTrue);
      expect(cost.isWorseFor(DebtDirection.iOwe), isTrue);
    });

    test('the same movement is better when you are owed it', () {
      // Identical arithmetic, opposite reading: money owed to you becoming
      // worth more dinars is good news.
      final cost = calculator.compute(
        debt(direction: DebtDirection.owedToMe),
        todaysRate: rate('0.731'),
      )!;
      expect(cost.totalDrift.isPositive, isTrue);
      expect(cost.isWorseFor(DebtDirection.owedToMe), isFalse);
    });

    test('a falling rate is better for a borrower', () {
      final cost = calculator.compute(
        debt(),
        todaysRate: rate('0.690'),
      )!;
      expect(cost.totalDrift.isNegative, isTrue);
      expect(cost.isWorseFor(DebtDirection.iOwe), isFalse);
    });
  });

  group('partial payments', () {
    test('reduce the outstanding balance in the debt currency', () {
      final d = debt(payments: [payment('200.00', atRate: '0.710')]);
      expect(d.paid, Money.parse('200.00', usd));
      expect(d.outstanding, Money.parse('1800.00', usd));
      expect(d.isSettled, isFalse);
    });

    test('several payments accumulate', () {
      final d = debt(
        payments: [
          payment('200.00', atRate: '0.710', id: 'p1'),
          payment('300.00', atRate: '0.720', id: 'p2'),
          payment('100.00', atRate: '0.700', id: 'p3'),
        ],
      );
      expect(d.paid, Money.parse('600.00', usd));
      expect(d.outstanding, Money.parse('1400.00', usd));
    });

    test('paying the whole principal settles the debt', () {
      final d = debt(payments: [payment('2000.00', atRate: '0.731')]);
      expect(d.outstanding, Money.zero(usd));
      expect(d.isSettled, isTrue);
    });

    test('overpaying floors at zero rather than showing a negative balance',
        () {
      // A data-entry slip should not read as the counterparty owing you.
      final d = debt(payments: [payment('2500.00', atRate: '0.731')]);
      expect(d.outstanding, Money.zero(usd));
      expect(d.isSettled, isTrue);
    });

    test('each payment costs what the rate was on its own day', () {
      final p = payment('200.00', atRate: '0.710');
      expect(p.costInHomeCurrency, Money.parse('142.000', jod));
    });
  });

  group('realised and unrealised drift', () {
    test('split so paid and unpaid portions are not conflated', () {
      // 2,000 USD borrowed at 0.709. 500 repaid at 0.750, rate now 0.731.
      final d = debt(payments: [payment('500.00', atRate: '0.750')]);
      final cost = calculator.compute(d, todaysRate: rate('0.731'))!;

      // Realised: 500 x 0.750 = 375.000, versus 500 x 0.709 = 354.500
      expect(cost.paidSoFar, Money.parse('375.000', jod));
      expect(cost.paidAtOriginalRate, Money.parse('354.500', jod));
      expect(cost.realisedDrift, Money.parse('20.500', jod));

      // Unrealised: 1,500 x 0.731 = 1,096.500, versus 1,500 x 0.709 = 1,063.500
      expect(cost.outstandingToday, Money.parse('1096.500', jod));
      expect(cost.outstandingAtOriginalRate, Money.parse('1063.500', jod));
      expect(cost.unrealisedDrift, Money.parse('33.000', jod));

      expect(cost.totalDrift, Money.parse('53.500', jod));
    });

    test('a settled debt has no unrealised drift left', () {
      final d = debt(payments: [payment('2000.00', atRate: '0.750')]);
      final cost = calculator.compute(d, todaysRate: rate('0.900'))!;

      expect(cost.unrealisedDrift, Money.zero(jod));
      // All of it is locked in: 2,000 x (0.750 - 0.709) = 82.000
      expect(cost.realisedDrift, Money.parse('82.000', jod));
      expect(cost.totalDrift, cost.realisedDrift);
    });

    test('with no payments, all drift is unrealised', () {
      final cost = calculator.compute(debt(), todaysRate: rate('0.731'))!;
      expect(cost.realisedDrift, Money.zero(jod));
      expect(cost.unrealisedDrift, cost.totalDrift);
    });

    test('realised plus unrealised always equals the total', () {
      // The identity that makes the two lines trustworthy.
      for (final todays in ['0.600', '0.709', '0.800', '1.200']) {
        final d = debt(
          payments: [
            payment('300.00', atRate: '0.690', id: 'p1'),
            payment('450.00', atRate: '0.780', id: 'p2'),
          ],
        );
        final cost = calculator.compute(d, todaysRate: rate(todays))!;
        expect(
          cost.realisedDrift + cost.unrealisedDrift,
          cost.totalDrift,
          reason: 'failed at rate $todays',
        );
      }
    });
  });

  group('across decimal scales', () {
    test('a three-decimal debt in a two-decimal home currency', () {
      final d = Debt(
        id: 'd2',
        counterparty: 'Layla H.',
        direction: DebtDirection.owedToMe,
        principal: Money.parse('1500.00', aed),
        homeCurrency: jod,
        rateAtCreation: FxRate.parse(
          base: aed,
          quote: jod,
          rate: '0.193',
          rateDate: borrowedOn,
          fetchedAt: borrowedOn,
        ),
        createdOn: borrowedOn,
      );

      final cost = calculator.compute(
        d,
        todaysRate: FxRate.parse(
          base: aed,
          quote: jod,
          rate: '0.199',
          rateDate: today,
          fetchedAt: today,
        ),
      )!;

      // 1,500 x 0.193 = 289.500 JOD; 1,500 x 0.199 = 298.500 JOD
      expect(cost.costAtOriginalRate, Money.parse('289.500', jod));
      expect(cost.costAtTodaysRate, Money.parse('298.500', jod));
      expect(cost.totalDrift, Money.parse('9.000', jod));
    });
  });

  group('overdue', () {
    test('a settled debt is never overdue', () {
      final d = Debt(
        id: 'd3',
        counterparty: 'X',
        direction: DebtDirection.iOwe,
        principal: Money.parse('100.00', usd),
        homeCurrency: jod,
        rateAtCreation: rate('0.709'),
        createdOn: borrowedOn,
        dueOn: DateTime.utc(2025, 6, 1),
        payments: [payment('100.00', atRate: '0.709')],
      );
      expect(d.isOverdue, isFalse);
    });

    test('a debt with no due date is never overdue', () {
      expect(debt().isOverdue, isFalse);
    });
  });

  group('mismatched quote currencies', () {
    test('refuses to compare rates quoted in different currencies', () {
      // The crash a user hit: after changing home currency, the caller passed
      // a rate quoted in the new home currency for a debt recorded under the
      // old one, and the subtraction reached EGP minus USD.
      final egp = CurrencyRegistry.of('EGP');
      final todayInEgp = FxRate.parse(
        base: usd,
        quote: egp,
        rate: '48.5',
        rateDate: today,
        fetchedAt: today,
      );

      // debt() is recorded with JOD as its home currency.
      expect(calculator.compute(debt(), todaysRate: todayInEgp), isNull);
    });

    test('refuses a rate whose base is not the debt currency', () {
      final aedRate = FxRate.parse(
        base: aed,
        quote: jod,
        rate: '0.193',
        rateDate: today,
        fetchedAt: today,
      );
      expect(calculator.compute(debt(), todaysRate: aedRate), isNull);
    });

    test('accepts a correctly quoted rate', () {
      expect(
        calculator.compute(debt(), todaysRate: rate('0.731')),
        isNotNull,
      );
    });
  });
}
