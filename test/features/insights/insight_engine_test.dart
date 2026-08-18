import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/enums.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/accounts/domain/account.dart';
import 'package:zimam/features/insights/domain/insight.dart';
import 'package:zimam/features/insights/domain/insight_engine.dart';
import 'package:zimam/features/insights/domain/insight_rule.dart';
import 'package:zimam/features/wealth/domain/net_worth.dart';

/// Phase 3's done-condition: seeded data produces the expected insights.
void main() {
  final jod = CurrencyRegistry.of('JOD');
  final aed = CurrencyRegistry.of('AED');
  final usd = CurrencyRegistry.of('USD');

  final now = DateTime.utc(2026, 3, 20);
  const engine = InsightEngine();

  Money jd(String amount) => Money.parse(amount, jod);

  Account account(
    String id,
    String name,
    Currency currency,
    String balance, {
    String? institution,
    int? updatedDaysAgo,
    bool archived = false,
  }) => Account(
    id: id,
    name: name,
    currency: currency,
    type: AccountType.bank,
    balance: Money.parse(balance, currency),
    institution: institution,
    isArchived: archived,
    lastUpdatedAt: updatedDaysAgo == null
        ? null
        : now.subtract(Duration(days: updatedDaysAgo)),
  );

  NetWorth wealth(
    String total,
    List<(Currency, String, int)> holdings,
  ) => NetWorth(
    total: jd(total),
    homeCurrency: jod,
    holdings: [
      for (final (currency, value, count) in holdings)
        CurrencyHolding(
          currency: currency,
          // Values are stated at the home currency's scale for readability;
          // the native figure is irrelevant to these rules, so it is carried
          // at the same magnitude rather than re-scaled.
          native: Money.fromMinorUnits(jd(value).minorUnits, currency),
          inHomeCurrency: jd(value),
          accountCount: count,
        ),
    ]..sort(
      (a, b) =>
          b.inHomeCurrency.minorUnits.compareTo(a.inHomeCurrency.minorUnits),
    ),
    accountsIncluded: 3,
    accountsUnconvertible: 0,
  );

  InsightContext context({
    NetWorth? netWorth,
    List<Account> accounts = const [],
    Money? fxDrift30,
    Money? fxDrift90,
    InsightThresholds? thresholds,
  }) => InsightContext(
    netWorth: netWorth ?? wealth('10000.000', [(jod, '10000.000', 1)]),
    accounts: accounts,
    homeCurrency: jod,
    now: now,
    thresholds:
        thresholds ?? InsightThresholds(scatteredBelow: jd('100.000')),
    fxDrift30: fxDrift30,
    fxDrift90: fxDrift90,
    // Test balances are already stated in home-currency magnitudes, so the
    // identity conversion keeps the rules under test rather than the FX layer.
    homeValueOf: (m) => Money.fromMinorUnits(m.minorUnits, jod),
  );

  group('FX drift', () {
    test('reports rate-only movement', () {
      final insights = engine.evaluate(
        context(fxDrift30: jd('-214.300')),
      );
      final insight = insights.singleWhere(
        (i) => i.kind == InsightKind.fxDrift,
      );
      final details = insight.details as FxDriftDetails;

      expect(details.change, jd('-214.300'));
      expect(details.days, 30);
      expect(details.isLoss, isTrue);
    });

    test('reports gains as well as losses', () {
      // Only ever showing bad news trains people to dread the card.
      final insights = engine.evaluate(context(fxDrift30: jd('300.000')));
      final details =
          insights.single.details as FxDriftDetails;
      expect(details.isLoss, isFalse);
    });

    test('picks the more material of the two windows', () {
      final insights = engine.evaluate(
        context(fxDrift30: jd('-50.000'), fxDrift90: jd('-600.000')),
      );
      final details = insights.single.details as FxDriftDetails;
      expect(details.days, 90);
      expect(details.change, jd('-600.000'));
    });

    test('says nothing without history to compare against', () {
      expect(engine.evaluate(context()), isEmpty);
    });

    test('says nothing about a trivial movement', () {
      // 0.5 JOD out of 10,000 is noise, and noise is what stops people
      // reading the cards that matter.
      expect(engine.evaluate(context(fxDrift30: jd('0.500'))), isEmpty);
    });
  });

  group('concentration', () {
    test('flags a dominant currency', () {
      final insights = engine.evaluate(
        context(
          netWorth: wealth('10000.000', [
            (aed, '6800.000', 2),
            (jod, '2100.000', 1),
            (usd, '1100.000', 1),
          ]),
        ),
      );
      final insight = insights.singleWhere(
        (i) => i.kind == InsightKind.concentration,
      );
      final details = insight.details as ConcentrationDetails;

      expect(details.currency, aed);
      expect(details.share, closeTo(0.68, 0.001));
      expect(details.amount, jd('6800.000'));
    });

    test('stays quiet below the threshold', () {
      final insights = engine.evaluate(
        context(
          netWorth: wealth('10000.000', [
            (aed, '5000.000', 1),
            (jod, '5000.000', 1),
          ]),
        ),
      );
      expect(insights.where((i) => i.kind == InsightKind.concentration), isEmpty);
    });

    test('a single currency is not concentration', () {
      // Telling someone who holds one currency that 100% is in one currency
      // is noise, not insight.
      final insights = engine.evaluate(
        context(netWorth: wealth('10000.000', [(jod, '10000.000', 1)])),
      );
      expect(insights, isEmpty);
    });
  });

  group('scattered balances', () {
    test('adds up small holdings and counts the institutions', () {
      final insights = engine.evaluate(
        context(
          accounts: [
            account('a', 'Old current', jod, '40.000', institution: 'Bank A'),
            account('b', 'Wallet', jod, '25.500', institution: 'Wallet Co'),
            account('c', 'Student', jod, '80.100', institution: 'Bank B'),
            account('d', 'Petty cash', jod, '95.000', institution: 'Bank A'),
            account('e', 'Main', jod, '9000.000', institution: 'Bank C'),
          ],
        ),
      );
      final insight = insights.singleWhere(
        (i) => i.kind == InsightKind.scatteredBalances,
      );
      final details = insight.details as ScatteredDetails;

      expect(details.accountCount, 4);
      expect(details.total, jd('240.600'));
      expect(
        details.institutionCount,
        3,
        reason: 'two of them share Bank A',
      );
    });

    test('one small balance is not scattered', () {
      final insights = engine.evaluate(
        context(
          accounts: [
            account('a', 'Small', jod, '40.000'),
            account('b', 'Main', jod, '9000.000'),
          ],
        ),
      );
      expect(insights, isEmpty);
    });

    test('honours a user-set threshold', () {
      final accounts = [
        account('a', 'One', jod, '150.000'),
        account('b', 'Two', jod, '180.000'),
        account('c', 'Main', jod, '9000.000'),
      ];
      expect(
        engine.evaluate(context(accounts: accounts)),
        isEmpty,
        reason: 'both sit above the default 100 threshold',
      );

      final raised = engine.evaluate(
        context(
          accounts: accounts,
          thresholds: InsightThresholds(scatteredBelow: jd('200.000')),
        ),
      );
      expect(
        raised.where((i) => i.kind == InsightKind.scatteredBalances),
        hasLength(1),
      );
    });

    test('ignores zero and negative balances', () {
      final insights = engine.evaluate(
        context(
          accounts: [
            account('a', 'Empty', jod, '0.000'),
            account('b', 'Overdrawn', jod, '-50.000'),
            account('c', 'Main', jod, '9000.000'),
          ],
        ),
      );
      expect(insights, isEmpty);
    });
  });

  group('dormancy', () {
    test('flags accounts past the limit and totals what is behind them', () {
      final insights = engine.evaluate(
        context(
          accounts: [
            account('a', 'Egypt', jod, '600.000', updatedDaysAgo: 94),
            account('b', 'Old savings', jod, '900.000', updatedDaysAgo: 70),
            account('c', 'Main', jod, '8000.000', updatedDaysAgo: 2),
          ],
        ),
      );
      final insight = insights.singleWhere(
        (i) => i.kind == InsightKind.dormancy,
      );
      final details = insight.details as DormancyDetails;

      expect(details.accountCount, 2);
      expect(details.oldestDays, 94);
      expect(details.total, jd('1500.000'));
    });

    test('a never-updated account is not dormant', () {
      // It was just created; its opening balance is as fresh as anything.
      final insights = engine.evaluate(
        context(
          accounts: [account('a', 'Brand new', jod, '5000.000')],
        ),
      );
      expect(insights.where((i) => i.kind == InsightKind.dormancy), isEmpty);
    });

    test('stays quiet just inside the limit', () {
      final insights = engine.evaluate(
        context(
          accounts: [
            account('a', 'Recent', jod, '5000.000', updatedDaysAgo: 59),
          ],
        ),
      );
      expect(insights, isEmpty);
    });
  });

  group('ranking and dismissal', () {
    InsightContext busy() => context(
      netWorth: wealth('10000.000', [
        (aed, '7000.000', 2),
        (jod, '3000.000', 3),
      ]),
      accounts: [
        account('a', 'Small one', jod, '40.000', institution: 'Bank A'),
        account('b', 'Small two', jod, '30.000', institution: 'Bank B'),
        account('c', 'Dormant', jod, '900.000', updatedDaysAgo: 90),
      ],
      fxDrift30: jd('-214.300'),
    );

    test('all four rules can fire at once', () {
      final insights = engine.evaluate(busy());
      expect(
        insights.map((i) => i.kind).toSet(),
        {
          InsightKind.fxDrift,
          InsightKind.concentration,
          InsightKind.scatteredBalances,
          InsightKind.dormancy,
        },
      );
    });

    test('ranked by materiality, most significant first', () {
      final insights = engine.evaluate(busy());
      final scores = insights.map((i) => i.materiality).toList();
      expect(
        scores,
        orderedEquals(List.of(scores)..sort((a, b) => b.compareTo(a))),
      );
      // 70% in one currency dwarfs a 0.7% scattering.
      expect(insights.first.kind, InsightKind.concentration);
    });

    test('a dismissed signature is withheld', () {
      final all = engine.evaluate(busy());
      final target = all.first;

      final remaining = engine.evaluate(
        busy(),
        dismissedSignatures: {target.signature},
      );
      expect(remaining.map((i) => i.kind), isNot(contains(target.kind)));
      expect(remaining, hasLength(all.length - 1));
    });

    test('dismissal survives an immaterial change but not a large one', () {
      // Dismissing "70% in one currency" should stay dismissed at 71%, and
      // come back when it reaches 90% — the situation has changed by then.
      InsightContext at(String aedValue, String jodValue, String total) =>
          context(
            netWorth: wealth(total, [
              (aed, aedValue, 1),
              (jod, jodValue, 1),
            ]),
          );

      final dismissed = engine
          .evaluate(at('7000.000', '3000.000', '10000.000'))
          .single
          .signature;

      expect(
        engine.evaluate(
          at('7100.000', '2900.000', '10000.000'),
          dismissedSignatures: {dismissed},
        ),
        isEmpty,
        reason: '71% is the same situation as 70%',
      );

      expect(
        engine.evaluate(
          at('9000.000', '1000.000', '10000.000'),
          dismissedSignatures: {dismissed},
        ),
        hasLength(1),
        reason: '90% has materially changed and deserves another mention',
      );
    });

    test('a throwing rule does not take the screen down with it', () {
      const broken = InsightEngine(rules: [_ExplodingRule()]);
      expect(broken.evaluate(context()), isEmpty);
    });

    test('no data produces no cards rather than empty ones', () {
      expect(engine.evaluate(context()), isEmpty);
    });
  });
}

class _ExplodingRule implements InsightRule {
  const _ExplodingRule();

  @override
  InsightKind get kind => InsightKind.dormancy;

  @override
  Insight? evaluate(InsightContext context) => throw StateError('boom');
}
