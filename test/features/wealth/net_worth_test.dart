import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/wealth/domain/net_worth.dart';

/// The activity/FX split is the app's central claim, so it is tested as a
/// mathematical identity rather than by example alone: whatever the inputs,
/// activity + fx must equal the true change in total value. A split that does
/// not reconcile would misattribute a loss the user then acts on.
void main() {
  final jod = CurrencyRegistry.of('JOD');
  final usd = CurrencyRegistry.of('USD');
  final aed = CurrencyRegistry.of('AED');

  const calculator = WealthChangeCalculator();
  final since = DateTime.utc(2026, 2, 20);

  /// Converts at a fixed rate per currency, expressed as an integer ratio so
  /// the test never introduces a double either.
  Money Function(Money) converter(Map<String, (int, int)> rates) {
    return (amount) {
      if (amount.currency == jod) return amount;
      final ratio = rates[amount.currency.code]!;
      // Convert into JOD's 3-decimal scale from the source's own scale.
      final scaleShift = jod.minorUnitsPerMajor ~/
          amount.currency.minorUnitsPerMajor;
      final scaled = amount.scaledBy(ratio.$1 * scaleShift, ratio.$2);
      return Money.fromMinorUnits(scaled.minorUnits, jod);
    };
  }

  group('the split reconciles', () {
    test('activity plus fx equals the total change', () {
      // USD strengthens against JOD: 0.700 -> 0.709, while the user also
      // adds 100 USD and spends 50 AED.
      final opening = {
        'usd': Money.parse('1000.00', usd),
        'aed': Money.parse('500.00', aed),
      };
      final closing = {
        'usd': Money.parse('1100.00', usd),
        'aed': Money.parse('450.00', aed),
      };

      final atOpening = converter({'USD': (700, 1000), 'AED': (190, 1000)});
      final atClosing = converter({'USD': (709, 1000), 'AED': (193, 1000)});

      final change = calculator.compute(
        openingBalances: opening,
        closingBalances: closing,
        convertAtOpening: atOpening,
        convertAtClosing: atClosing,
        homeCurrency: jod,
        since: since,
      );

      // Independently computed true change: Σ B₁R₁ − Σ B₀R₀
      final totalOpening =
          atOpening(opening['usd']!) + atOpening(opening['aed']!);
      final totalClosing =
          atClosing(closing['usd']!) + atClosing(closing['aed']!);
      final trueChange = totalClosing - totalOpening;

      expect(
        change.fromActivity + change.fromExchangeRates,
        trueChange,
        reason: 'the two lines must account for the whole move',
      );
      expect(change.total, trueChange);
    });

    test('holds when rates move against the user', () {
      final opening = {'usd': Money.parse('1000.00', usd)};
      final closing = {'usd': Money.parse('1000.00', usd)};

      final atOpening = converter({'USD': (709, 1000)});
      final atClosing = converter({'USD': (690, 1000)});

      final change = calculator.compute(
        openingBalances: opening,
        closingBalances: closing,
        convertAtOpening: atOpening,
        convertAtClosing: atClosing,
        homeCurrency: jod,
        since: since,
      );

      // Untouched balance, so nothing is activity — all of it is the market.
      expect(change.fromActivity, Money.zero(jod));
      expect(change.fromExchangeRates.isNegative, isTrue);
      expect(change.total, change.fromExchangeRates);
    });
  });

  group('attribution', () {
    test('an untouched balance shows zero activity', () {
      final balances = {'usd': Money.parse('1000.00', usd)};
      final change = calculator.compute(
        openingBalances: balances,
        closingBalances: balances,
        convertAtOpening: converter({'USD': (700, 1000)}),
        convertAtClosing: converter({'USD': (709, 1000)}),
        homeCurrency: jod,
        since: since,
      );
      expect(change.fromActivity, Money.zero(jod));
      expect(change.fromExchangeRates.isPositive, isTrue);
    });

    test('a stable rate shows zero exchange-rate movement', () {
      const rate = {'USD': (709, 1000)};
      final change = calculator.compute(
        openingBalances: {'usd': Money.parse('1000.00', usd)},
        closingBalances: {'usd': Money.parse('1200.00', usd)},
        convertAtOpening: converter(rate),
        convertAtClosing: converter(rate),
        homeCurrency: jod,
        since: since,
      );
      expect(change.fromExchangeRates, Money.zero(jod));
      expect(change.fromActivity.isPositive, isTrue);
    });

    test('home-currency holdings never show exchange-rate movement', () {
      // A dinar is always a dinar. Any FX component here would be a bug.
      final change = calculator.compute(
        openingBalances: {'jod': Money.parse('1000.000', jod)},
        closingBalances: {'jod': Money.parse('1500.000', jod)},
        convertAtOpening: converter(const {}),
        convertAtClosing: converter(const {}),
        homeCurrency: jod,
        since: since,
      );
      expect(change.fromExchangeRates, Money.zero(jod));
      expect(change.fromActivity, Money.parse('500.000', jod));
    });

    test('a newly added account is activity, not a windfall', () {
      // Recording an account you already owned should not look like the
      // market handed you money.
      final change = calculator.compute(
        openingBalances: {},
        closingBalances: {'usd': Money.parse('1000.00', usd)},
        convertAtOpening: converter({'USD': (700, 1000)}),
        convertAtClosing: converter({'USD': (709, 1000)}),
        homeCurrency: jod,
        since: since,
      );
      expect(change.fromExchangeRates, Money.zero(jod));
      expect(change.fromActivity, Money.parse('709.000', jod));
    });

    test('a removed account reduces activity', () {
      final change = calculator.compute(
        openingBalances: {'usd': Money.parse('1000.00', usd)},
        closingBalances: {},
        convertAtOpening: converter({'USD': (709, 1000)}),
        convertAtClosing: converter({'USD': (709, 1000)}),
        homeCurrency: jod,
        since: since,
      );
      expect(change.fromActivity.isNegative, isTrue);
      expect(change.fromActivity, Money.parse('-709.000', jod));
    });
  });

  group('edge cases', () {
    test('no accounts gives a zero change, not a crash', () {
      final change = calculator.compute(
        openingBalances: {},
        closingBalances: {},
        convertAtOpening: converter(const {}),
        convertAtClosing: converter(const {}),
        homeCurrency: jod,
        since: since,
      );
      expect(change.total, Money.zero(jod));
      expect(change.isZero, isTrue);
    });

    test('a currency that changed under an account is skipped', () {
      // Corrupt data rather than a real movement — inventing a conversion
      // would be worse than omitting it.
      final change = calculator.compute(
        openingBalances: {'a': Money.parse('100.00', usd)},
        closingBalances: {'a': Money.parse('100.00', aed)},
        convertAtOpening: converter({'USD': (709, 1000), 'AED': (193, 1000)}),
        convertAtClosing: converter({'USD': (709, 1000), 'AED': (193, 1000)}),
        homeCurrency: jod,
        since: since,
      );
      expect(change.total, Money.zero(jod));
    });
  });

  group('holdings', () {
    test('share is a proportion of the whole', () {
      final total = Money.parse('1000.000', jod);
      final holding = CurrencyHolding(
        currency: usd,
        native: Money.parse('1000.00', usd),
        inHomeCurrency: Money.parse('680.000', jod),
        accountCount: 2,
      );
      expect(holding.shareOf(total), closeTo(0.68, 1e-9));
    });

    test('share of nothing is zero rather than a division by zero', () {
      final holding = CurrencyHolding(
        currency: usd,
        native: Money.zero(usd),
        inHomeCurrency: Money.zero(jod),
        accountCount: 1,
      );
      expect(holding.shareOf(Money.zero(jod)), 0);
    });
  });
}
