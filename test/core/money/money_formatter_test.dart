import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/core/money/money_formatter.dart';

void main() {
  final jod = CurrencyRegistry.of('JOD');
  final usd = CurrencyRegistry.of('USD');
  final jpy = CurrencyRegistry.of('JPY');

  const en = MoneyFormatter(locale: 'en');
  const ar = MoneyFormatter(locale: 'ar');
  const arIndic = MoneyFormatter(
    locale: 'ar',
    digitStyle: DigitStyle.arabicIndic,
  );

  group('decimal places follow the currency', () {
    test('renders each currency at its own scale', () {
      expect(en.format(Money.parse('1234.56', usd)), 'USD 1,234.56');
      expect(en.format(Money.parse('1234.567', jod)), 'JOD 1,234.567');
      expect(en.format(Money.parse('1234', jpy)), 'JPY 1,234');
    });

    test('pads trailing zeros so columns line up', () {
      // 10 JOD must read 10.000, not 10 — the whole point of tabular figures
      // is that decimal points align down a list.
      expect(en.format(Money.parse('10', jod)), 'JOD 10.000');
      expect(en.format(Money.parse('10', usd)), 'USD 10.00');
      expect(en.format(Money.parse('0.5', jod)), 'JOD 0.500');
    });

    test('renders zero and sub-unit amounts', () {
      expect(en.format(Money.zero(jod)), 'JOD 0.000');
      expect(en.format(Money.parse('0.007', jod)), 'JOD 0.007');
      expect(en.format(Money.parse('0.07', usd)), 'USD 0.07');
    });

    test('renders negatives with a leading sign', () {
      expect(en.format(Money.parse('-1234.56', usd)), 'USD -1,234.56');
      expect(en.format(Money.parse('-0.01', usd)), 'USD -0.01');
    });

    test('can omit the code', () {
      expect(en.format(Money.parse('10', jod), showCode: false), '10.000');
    });
  });

  group('digit style', () {
    test('Arabic locale uses Western digits by default', () {
      // The decision recorded in ARCHITECTURE.md §5: Arabic prose, Western
      // figures, because that is what Gulf and Levant banking apps do.
      final text = ar.format(Money.parse('1234.567', jod));
      expect(text, contains('1'));
      expect(text, contains('.'));
      expect(text, isNot(contains('٫')));
      for (final arabicDigit in ['٠', '١', '٢', '٣', '٤']) {
        expect(text, isNot(contains(arabicDigit)));
      }
    });

    test('Arabic-Indic is available when asked for', () {
      final text = arIndic.format(Money.parse('1234.567', jod));
      expect(text, contains('١'));
      expect(text, contains('٫')); // Arabic decimal separator
      expect(text, isNot(contains('0')));
    });

    test('the style is independent of the locale', () {
      // An English speaker can ask for Arabic-Indic and vice versa; the two
      // settings do not imply each other.
      const enIndic = MoneyFormatter(
        locale: 'en',
        digitStyle: DigitStyle.arabicIndic,
      );
      expect(enIndic.format(Money.parse('12.34', usd)), contains('١'));
      expect(ar.format(Money.parse('12.34', usd)), contains('12'));
    });

    test('round trips through parse', () {
      // Whatever we render in either style, Money.parse must read back.
      final original = Money.parse('1234.567', jod);
      for (final formatter in [en, ar, arIndic]) {
        final text = formatter.format(original, showCode: false);
        expect(
          Money.parse(text, jod),
          original,
          reason: 'failed to round trip "$text"',
        );
      }
    });
  });

  group('signed amounts', () {
    test('shows an explicit plus for gains', () {
      expect(
        en.formatSigned(Money.parse('1240', jod)),
        '+JOD 1,240.000',
      );
    });

    test('uses a true minus sign, not a hyphen', () {
      final text = en.formatSigned(Money.parse('-214.3', jod));
      expect(text, '−JOD 214.300');
      expect(text.startsWith('−'), isTrue);
      expect(text.contains('-'), isFalse);
    });

    test('zero carries no sign', () {
      expect(en.formatSigned(Money.zero(jod)), 'JOD 0.000');
    });
  });

  group('shares', () {
    test('formats a proportion as a percentage', () {
      expect(en.formatShare(0.68), '68%');
      expect(en.formatShare(0.02), '2%');
      expect(en.formatShare(0.215, decimalDigits: 1), '21.5%');
    });

    test('respects the digit style', () {
      expect(arIndic.formatShare(0.68), contains('٦'));
      expect(ar.formatShare(0.68), contains('68'));
    });
  });
}
