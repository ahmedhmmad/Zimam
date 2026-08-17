import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/fx/fx_rate.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';

void main() {
  final usd = CurrencyRegistry.of('USD'); // 2 places
  final jod = CurrencyRegistry.of('JOD'); // 3 places
  final jpy = CurrencyRegistry.of('JPY'); // 0 places
  final kwd = CurrencyRegistry.of('KWD'); // 3 places
  final vnd = CurrencyRegistry.of('VND'); // 0 places

  final date = DateTime.utc(2026, 3, 14);

  FxRate rate(Currency base, Currency quote, String value) => FxRate.parse(
    base: base,
    quote: quote,
    rate: value,
    rateDate: date,
    fetchedAt: date,
  );

  group('parsing rates', () {
    test('scales to eight decimal places', () {
      expect(FxRate.parseScaled('1'), 100000000);
      expect(FxRate.parseScaled('0.709'), 70900000);
      expect(FxRate.parseScaled('1.41043000'), 141043000);
    });

    test('keeps precision needed by weak-currency pairs', () {
      // 1 KWD is roughly 160,000 VND, so the reverse rate is about 6.25e-6.
      // Four or six decimal places would quantise this into nonsense.
      expect(FxRate.parseScaled('0.00000625'), 625);
      expect(FxRate.parseScaled('0.00000001'), 1);
    });

    test('truncates below the eighth place rather than inventing precision', () {
      expect(FxRate.parseScaled('0.123456789'), 12345678);
    });

    test('reads exponential notation', () {
      expect(FxRate.parseScaled('6.25e-6'), 625);
      expect(FxRate.parseScaled('1E0'), 100000000);
    });

    test('rejects malformed input', () {
      expect(() => FxRate.parseScaled(''), throwsFormatException);
      expect(() => FxRate.parseScaled('abc'), throwsFormatException);
      expect(() => FxRate.parseScaled('1.2.3'), throwsFormatException);
    });

    test('round trips to a decimal string', () {
      expect(rate(usd, jod, '0.709').asDecimalString, '0.709');
      expect(rate(usd, jod, '1').asDecimalString, '1');
      expect(rate(usd, vnd, '0.00000625').asDecimalString, '0.00000625');
    });
  });

  group('conversion across differing decimal scales', () {
    test('two places to three places', () {
      // 100.00 USD at 0.709 = 70.900 JOD
      final result = rate(usd, jod, '0.709').convert(Money.parse('100.00', usd));
      expect(result.currency, jod);
      expect(result.minorUnits, 70900);
      expect(result.toString(), '70.900 JOD');
    });

    test('three places to two places', () {
      // 70.900 JOD at 1.41043 = 99.99 USD
      final result = rate(
        jod,
        usd,
        '1.41043',
      ).convert(Money.parse('70.900', jod));
      expect(result.currency, usd);
      expect(result.toString(), '100.00 USD');
    });

    test('two places to zero places', () {
      // 100.00 USD at 157.25 = 15725 JPY, with no fractional yen.
      final result = rate(usd, jpy, '157.25').convert(
        Money.parse('100.00', usd),
      );
      expect(result.currency, jpy);
      expect(result.minorUnits, 15725);
      expect(result.toString(), '15725 JPY');
    });

    test('zero places to three places', () {
      // 10000 JPY at 0.0045 = 45.000 JOD
      final result = rate(jpy, jod, '0.0045').convert(
        Money.parse('10000', jpy),
      );
      expect(result.toString(), '45.000 JOD');
    });

    test('a hugely disparate pair stays sane', () {
      // 1 KWD at 81000 = 81,000 VND
      final result = rate(kwd, vnd, '81000').convert(Money.parse('1', kwd));
      expect(result.minorUnits, 81000);
    });

    test('refuses an amount in the wrong currency', () {
      expect(
        () => rate(usd, jod, '0.709').convert(Money.parse('1.000', jod)),
        throwsA(isA<CurrencyMismatchException>()),
      );
    });

    test('identity conversion returns the amount untouched', () {
      final amount = Money.parse('12.345', jod);
      expect(FxRate.identity(jod, date).convert(amount), amount);
    });
  });

  group('rounding', () {
    test('rounds half away from zero, symmetrically', () {
      // 0.05 USD at 0.5 = 0.025 -> rounds to 0.03, and the negative to -0.03.
      // USD -> EUR: same scale, so only the rate's rounding is under test.
      // An identity pair would short-circuit and prove nothing.
      final eur = CurrencyRegistry.of('EUR');
      final half = rate(usd, eur, '0.5');
      expect(half.convert(Money.fromMinorUnits(5, usd)).minorUnits, 3);
      expect(half.convert(Money.fromMinorUnits(-5, usd)).minorUnits, -3);
    });

    test('does not drift on a large balance', () {
      // A big balance converted must not lose or gain units to rounding.
      final result = rate(usd, jod, '0.709').convert(
        Money.parse('1000000.00', usd),
      );
      expect(result.toString(), '709000.000 JOD');
    });
  });

  group('inversion', () {
    test('produces the reciprocal', () {
      final forward = rate(usd, jod, '0.709');
      final back = forward.inverted();
      expect(back.base, jod);
      expect(back.quote, usd);
      // 1 / 0.709 = 1.41043724...
      expect(back.rateScaled, 141043723);
    });

    test('round trips approximately, and the loss is documented', () {
      final forward = rate(usd, jod, '0.709');
      final there = forward.convert(Money.parse('100.00', usd));
      final back = forward.inverted().convert(there);
      // Inversion truncates below the eighth place, so this lands within a
      // minor unit rather than exactly on 100.00.
      expect((back.minorUnits - 10000).abs(), lessThanOrEqualTo(1));
    });

    test('refuses to invert a zero rate', () {
      final zero = FxRate(
        base: usd,
        quote: jod,
        rateScaled: 0,
        rateDate: date,
        fetchedAt: date,
      );
      expect(zero.inverted, throwsStateError);
    });
  });

  group('staleness', () {
    test('measures from the rate date, not the fetch time', () {
      // A rate *for* the 14th fetched on the 20th is six days stale, however
      // recently it was downloaded.
      final r = FxRate(
        base: usd,
        quote: jod,
        rateScaled: FxRate.scaleFactor,
        rateDate: DateTime.utc(2026, 3, 14),
        fetchedAt: DateTime.utc(2026, 3, 20),
      );
      expect(r.stalenessFrom(DateTime.utc(2026, 3, 20)).inDays, 6);
    });
  });
}
