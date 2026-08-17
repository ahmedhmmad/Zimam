import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';

void main() {
  final jod = CurrencyRegistry.of('JOD'); // 3 places
  final usd = CurrencyRegistry.of('USD'); // 2 places
  final jpy = CurrencyRegistry.of('JPY'); // 0 places

  group('parsing', () {
    test('reads a plain decimal exactly', () {
      expect(Money.parse('10.00', usd).minorUnits, 1000);
      expect(Money.parse('1234.56', usd).minorUnits, 123456);
      expect(Money.parse('0.01', usd).minorUnits, 1);
    });

    test('scales by the currency, not by a fixed factor', () {
      // The same text is a different number of minor units per currency.
      expect(Money.parse('10', usd).minorUnits, 1000);
      expect(Money.parse('10', jod).minorUnits, 10000);
      expect(Money.parse('10', jpy).minorUnits, 10);
    });

    test('pads short fractions rather than misreading them', () {
      // "1.5" JOD is one and a half dinars — 1500 fils, not 15 or 150.
      expect(Money.parse('1.5', jod).minorUnits, 1500);
      expect(Money.parse('1.05', jod).minorUnits, 1050);
      expect(Money.parse('1.005', jod).minorUnits, 1005);
      expect(Money.parse('1.5', usd).minorUnits, 150);
    });

    test('handles signs', () {
      expect(Money.parse('-10.00', usd).minorUnits, -1000);
      expect(Money.parse('+10.00', usd).minorUnits, 1000);
      expect(Money.parse('-0.01', usd).minorUnits, -1);
    });

    test('ignores grouping separators and whitespace', () {
      expect(Money.parse(' 1,234.56 ', usd).minorUnits, 123456);
      expect(Money.parse('1_234.56', usd).minorUnits, 123456);
      expect(Money.parse('1 234.56', usd).minorUnits, 123456);
    });

    test('accepts Arabic-Indic digits and separators', () {
      // Typed on an Arabic keyboard, this must parse identically.
      expect(Money.parse('١٢٣٤٫٥٦', usd).minorUnits, 123456);
      expect(Money.parse('١٬٢٣٤٫٥٦', usd).minorUnits, 123456);
      expect(Money.parse('١٠٫٠٠٠', jod).minorUnits, 10000);
    });

    test('accepts a bare fraction and a bare whole', () {
      expect(Money.parse('.5', usd).minorUnits, 50);
      expect(Money.parse('7', usd).minorUnits, 700);
    });

    test('rejects too many decimal places instead of rounding them away', () {
      // A third decimal in USD is a typo, not something to silently discard.
      expect(() => Money.parse('1.005', usd), throwsFormatException);
      expect(() => Money.parse('1.0001', jod), throwsFormatException);
      expect(() => Money.parse('1.5', jpy), throwsFormatException);
    });

    test('rejects nonsense', () {
      expect(() => Money.parse('', usd), throwsFormatException);
      expect(() => Money.parse('abc', usd), throwsFormatException);
      expect(() => Money.parse('1.2.3', usd), throwsFormatException);
      expect(() => Money.parse('1..2', usd), throwsFormatException);
      expect(() => Money.parse('-', usd), throwsFormatException);
      expect(() => Money.parse('+', usd), throwsFormatException);
      expect(() => Money.parse('.', usd), throwsFormatException);
      expect(() => Money.parse('-.', usd), throwsFormatException);
    });
  });

  group('arithmetic', () {
    test('adds and subtracts', () {
      expect(
        (Money.parse('10.00', usd) + Money.parse('5.50', usd)).minorUnits,
        1550,
      );
      expect(
        (Money.parse('10.00', usd) - Money.parse('12.50', usd)).minorUnits,
        -250,
      );
    });

    test('negates and takes absolute value', () {
      expect((-Money.parse('10.00', usd)).minorUnits, -1000);
      expect(Money.parse('-10.00', usd).abs().minorUnits, 1000);
      expect(Money.parse('10.00', usd).abs().minorUnits, 1000);
    });

    test('multiplies by a whole number', () {
      expect((Money.parse('1.05', usd) * 3).minorUnits, 315);
      expect((Money.parse('1.05', usd) * 0).minorUnits, 0);
      expect((Money.parse('1.05', usd) * -2).minorUnits, -210);
    });

    test('refuses to mix currencies', () {
      final a = Money.parse('10.00', usd);
      final b = Money.parse('10.000', jod);
      expect(() => a + b, throwsA(isA<CurrencyMismatchException>()));
      expect(() => a - b, throwsA(isA<CurrencyMismatchException>()));
      expect(() => a.compareTo(b), throwsA(isA<CurrencyMismatchException>()));
    });

    test('sums a list', () {
      final total = Money.sum([
        Money.parse('1.11', usd),
        Money.parse('2.22', usd),
        Money.parse('3.33', usd),
      ], usd);
      expect(total.minorUnits, 666);
      expect(Money.sum(const [], usd), Money.zero(usd));
    });

    test('sum rejects a stray currency', () {
      expect(
        () => Money.sum([
          Money.parse('1.00', usd),
          Money.parse('1.000', jod),
        ], usd),
        throwsA(isA<CurrencyMismatchException>()),
      );
    });

    test('no floating point drift when summing repeatedly', () {
      // The canonical double failure: 0.1 + 0.2 != 0.3. Ten cents added a
      // hundred times must be exactly ten dollars, not 9.999999999999998.
      var total = Money.zero(usd);
      for (var i = 0; i < 100; i++) {
        total += Money.parse('0.10', usd);
      }
      expect(total.minorUnits, 1000);
      expect(total, Money.parse('10.00', usd));
    });
  });

  group('scaledBy rounding', () {
    test('rounds half away from zero, symmetrically', () {
      // 5 / 2 = 2.5 -> 3, and -5 / 2 = -2.5 -> -3. A debt and a credit of the
      // same size must round to the same magnitude.
      expect(Money.fromMinorUnits(5, usd).scaledBy(1, 2).minorUnits, 3);
      expect(Money.fromMinorUnits(-5, usd).scaledBy(1, 2).minorUnits, -3);
      expect(Money.fromMinorUnits(15, usd).scaledBy(1, 2).minorUnits, 8);
      expect(Money.fromMinorUnits(-15, usd).scaledBy(1, 2).minorUnits, -8);
    });

    test('rounds below and above the half correctly', () {
      expect(Money.fromMinorUnits(4, usd).scaledBy(1, 3).minorUnits, 1); // 1.33
      expect(Money.fromMinorUnits(5, usd).scaledBy(1, 3).minorUnits, 2); // 1.67
      expect(Money.fromMinorUnits(-4, usd).scaledBy(1, 3).minorUnits, -1);
      expect(Money.fromMinorUnits(-5, usd).scaledBy(1, 3).minorUnits, -2);
    });

    test('handles a negative denominator', () {
      expect(Money.fromMinorUnits(10, usd).scaledBy(1, -2).minorUnits, -5);
      expect(Money.fromMinorUnits(-10, usd).scaledBy(1, -2).minorUnits, 5);
    });

    test('is exact for large amounts that would overflow a double', () {
      // 2^53 + 1 is not representable as a double; BigInt intermediates keep
      // this exact.
      final big = Money.fromMinorUnits(9007199254740993, usd);
      expect(big.scaledBy(1, 1).minorUnits, 9007199254740993);
    });

    test('rejects a zero denominator', () {
      expect(
        () => Money.parse('1.00', usd).scaledBy(1, 0),
        throwsArgumentError,
      );
    });
  });

  group('comparison', () {
    test('orders and compares', () {
      final small = Money.parse('1.00', usd);
      final large = Money.parse('2.00', usd);
      expect(small < large, isTrue);
      expect(small <= large, isTrue);
      expect(large > small, isTrue);
      expect(large >= small, isTrue);
      expect(small >= Money.parse('1.00', usd), isTrue);
      expect(small.compareTo(large), lessThan(0));
    });

    test('equality includes the currency', () {
      expect(Money.fromMinorUnits(1000, usd), Money.fromMinorUnits(1000, usd));
      expect(
        Money.fromMinorUnits(1000, usd),
        isNot(Money.fromMinorUnits(1000, jod)),
      );
      expect(
        Money.fromMinorUnits(1000, usd).hashCode,
        Money.fromMinorUnits(1000, usd).hashCode,
      );
    });
  });

  group('parts and predicates', () {
    test('splits whole and fractional units', () {
      final m = Money.parse('12.34', usd);
      expect(m.wholeUnits, 12);
      expect(m.fractionalUnits, 34);

      final j = Money.parse('12.345', jod);
      expect(j.wholeUnits, 12);
      expect(j.fractionalUnits, 345);

      final y = Money.parse('1234', jpy);
      expect(y.wholeUnits, 1234);
      expect(y.fractionalUnits, 0);
    });

    test('keeps the sign on both parts', () {
      final m = Money.parse('-12.34', usd);
      expect(m.wholeUnits, -12);
      expect(m.fractionalUnits, -34);
    });

    test('predicates', () {
      expect(Money.zero(usd).isZero, isTrue);
      expect(Money.parse('-0.01', usd).isNegative, isTrue);
      expect(Money.parse('0.01', usd).isPositive, isTrue);
      expect(Money.zero(usd).isPositive, isFalse);
      expect(Money.zero(usd).isNegative, isFalse);
    });

    test('shareOf is a proportion, and safe at zero', () {
      final part = Money.parse('25.00', usd);
      final total = Money.parse('100.00', usd);
      expect(part.shareOf(total), closeTo(0.25, 1e-12));
      expect(part.shareOf(Money.zero(usd)), 0);
    });
  });

  group('toString', () {
    test('renders each currency at its own scale', () {
      expect(Money.parse('1234.56', usd).toString(), '1234.56 USD');
      expect(Money.parse('1234.567', jod).toString(), '1234.567 JOD');
      expect(Money.parse('1234', jpy).toString(), '1234 JPY');
    });

    test('renders negatives and sub-unit amounts', () {
      expect(Money.parse('-0.05', usd).toString(), '-0.05 USD');
      expect(Money.parse('0.007', jod).toString(), '0.007 JOD');
      expect(Money.zero(jod).toString(), '0.000 JOD');
    });
  });
}
