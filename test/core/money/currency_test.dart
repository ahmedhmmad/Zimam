import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/money/currency.dart';

void main() {
  group('decimal places', () {
    test('the three-place currencies are three places', () {
      // The app's own audience: a two-decimal assumption here would store
      // 10.000 JOD as 10.00 and lose a factor of ten.
      for (final code in ['BHD', 'IQD', 'JOD', 'KWD', 'LYD', 'OMR', 'TND']) {
        expect(
          CurrencyRegistry.of(code).decimalDigits,
          3,
          reason: '$code must have 3 decimal places',
        );
      }
    });

    test('the zero-place currencies are zero places', () {
      for (final code in [
        'BIF', 'CLP', 'DJF', 'GNF', 'ISK', 'JPY', 'KMF', 'KRW',
        'PYG', 'RWF', 'UGX', 'VND', 'VUV', 'XAF', 'XOF', 'XPF',
      ]) {
        expect(
          CurrencyRegistry.of(code).decimalDigits,
          0,
          reason: '$code must have 0 decimal places',
        );
      }
    });

    test('the four-place accounting units are four places', () {
      expect(CurrencyRegistry.of('CLF').decimalDigits, 4);
      expect(CurrencyRegistry.of('UYW').decimalDigits, 4);
    });

    test('ordinary currencies are two places', () {
      for (final code in ['USD', 'EUR', 'GBP', 'AED', 'EGP', 'SAR', 'TRY']) {
        expect(CurrencyRegistry.of(code).decimalDigits, 2);
      }
    });
  });

  group('minorUnitsPerMajor', () {
    test('matches the decimal count', () {
      expect(CurrencyRegistry.of('JPY').minorUnitsPerMajor, 1);
      expect(CurrencyRegistry.of('USD').minorUnitsPerMajor, 100);
      expect(CurrencyRegistry.of('JOD').minorUnitsPerMajor, 1000);
      expect(CurrencyRegistry.of('CLF').minorUnitsPerMajor, 10000);
    });
  });

  group('lookup', () {
    test('is case insensitive', () {
      expect(CurrencyRegistry.of('jod'), CurrencyRegistry.of('JOD'));
      expect(CurrencyRegistry.of('Jod').code, 'JOD');
    });

    test('throws on an unknown code rather than guessing', () {
      expect(
        () => CurrencyRegistry.of('XYZ'),
        throwsA(isA<UnknownCurrencyException>()),
      );
    });

    test('tryOf returns null where absence is expected', () {
      expect(CurrencyRegistry.tryOf('XYZ'), isNull);
      expect(CurrencyRegistry.tryOf('JOD'), isNotNull);
      expect(CurrencyRegistry.isKnown('EGP'), isTrue);
      expect(CurrencyRegistry.isKnown('nope'), isFalse);
    });
  });

  group('registry integrity', () {
    test('every entry is keyed by its own code, uppercase', () {
      CurrencyRegistry.byCode.forEach((key, currency) {
        expect(key, currency.code, reason: 'key $key does not match its entry');
        expect(key, key.toUpperCase(), reason: '$key must be uppercase');
        expect(key.length, 3, reason: '$key must be three letters');
      });
    });

    test('no entry has an implausible decimal count', () {
      for (final currency in CurrencyRegistry.byCode.values) {
        expect(
          currency.decimalDigits,
          inInclusiveRange(0, 4),
          reason: '${currency.code} has ${currency.decimalDigits} places',
        );
      }
    });

    test('equality is by code alone', () {
      const a = Currency(code: 'JOD', decimalDigits: 3, englishName: 'x');
      const b = Currency(code: 'JOD', decimalDigits: 3, englishName: 'y');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('all is sorted and complete', () {
      final all = CurrencyRegistry.all;
      expect(all.length, CurrencyRegistry.byCode.length);
      final codes = all.map((c) => c.code).toList();
      expect(codes, orderedEquals(List.of(codes)..sort()));
    });
  });
}
