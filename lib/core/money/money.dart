import 'currency.dart';

/// Thrown when two amounts in different currencies are combined.
///
/// This is deliberately an error rather than an implicit conversion. Adding
/// AED to JOD requires a rate, a rate has a date, and the date changes the
/// answer — so the caller must go through the FX service and say which day
/// they mean.
class CurrencyMismatchException implements Exception {
  const CurrencyMismatchException(this.left, this.right, this.operation);

  final Currency left;
  final Currency right;
  final String operation;

  @override
  String toString() =>
      'CurrencyMismatchException: cannot $operation ${left.code} and '
      '${right.code} directly — convert one of them first';
}

/// An exact amount of money: integer minor units plus its currency.
///
/// **Never use a double for money.** 0.1 + 0.2 is not 0.3 in binary floating
/// point, and a wealth tracker that silently drifts by a fraction of a fils
/// every time it sums a portfolio is worse than useless. Every amount in this
/// app — in memory, in the database, in the parser, on screen — is a [Money].
///
/// [minorUnits] is scaled by the currency, not by a fixed factor: 1000 is
/// 10.00 USD, 1.000 JOD, or 1000 JPY. That is why [currency] is carried
/// alongside rather than assumed.
final class Money implements Comparable<Money> {
  /// Wraps a raw minor-unit count. This is the storage-facing constructor —
  /// database rows and notification parsers produce minor units directly.
  const Money.fromMinorUnits(this.minorUnits, this.currency);

  /// Zero in [currency]. Zero is still currency-bearing: "nothing" in one
  /// currency cannot be added to something in another without a rate.
  const Money.zero(this.currency) : minorUnits = 0;

  /// Parses a decimal string exactly, without going through a double.
  ///
  /// Accepts an optional sign, digits, and at most [Currency.decimalDigits]
  /// decimal places. Grouping separators (`,` `_` and the Arabic thousands
  /// mark) are ignored, and both `.` and the Arabic decimal separator are
  /// accepted, so text typed on an Arabic keyboard parses the same way.
  ///
  /// Throws [FormatException] on anything else — including too many decimal
  /// places, which is a real mistake rather than something to round away:
  /// "1.005" in a 2-place currency means the user mistyped.
  factory Money.parse(String source, Currency currency) {
    var text = source.trim();
    if (text.isEmpty) {
      throw FormatException('Empty amount', source);
    }

    // Normalise Arabic-Indic digits and separators before parsing.
    text = _toWesternDigits(text)
        .replaceAll('٬', '') // Arabic thousands separator
        .replaceAll('٫', '.') // Arabic decimal separator
        .replaceAll(',', '')
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .replaceAll(' ', '');

    var negative = false;
    if (text.startsWith('-')) {
      negative = true;
      text = text.substring(1);
    } else if (text.startsWith('+')) {
      text = text.substring(1);
    }

    final parts = text.split('.');
    if (parts.length > 2) {
      throw FormatException('More than one decimal separator', source);
    }

    final fraction = parts.length == 2 ? parts[1] : '';
    // A sign or a lone separator with no digits at all is not zero, it is
    // malformed. Without this, "-" would quietly parse as 0.
    if (parts[0].isEmpty && fraction.isEmpty) {
      throw FormatException('No digits in amount', source);
    }
    final whole = parts[0].isEmpty ? '0' : parts[0];

    if (!_isDigits(whole) || (fraction.isNotEmpty && !_isDigits(fraction))) {
      throw FormatException('Not a decimal number', source);
    }
    if (fraction.length > currency.decimalDigits) {
      throw FormatException(
        '${currency.code} has ${currency.decimalDigits} decimal places, '
        'got ${fraction.length}',
        source,
      );
    }

    final padded = fraction.padRight(currency.decimalDigits, '0');
    final digits = '$whole$padded';
    final value = int.tryParse(digits);
    if (value == null) {
      throw FormatException('Amount is too large to represent', source);
    }
    return Money.fromMinorUnits(negative ? -value : value, currency);
  }

  /// The amount, in the currency's smallest unit. Fils for JOD, cents for USD,
  /// whole yen for JPY.
  final int minorUnits;

  final Currency currency;

  bool get isZero => minorUnits == 0;
  bool get isNegative => minorUnits < 0;
  bool get isPositive => minorUnits > 0;

  /// The whole-unit part, truncated toward zero. 1234 USD cents -> 12.
  int get wholeUnits => minorUnits ~/ currency.minorUnitsPerMajor;

  /// The fractional part in minor units, carrying the sign of the amount.
  int get fractionalUnits => minorUnits.remainder(currency.minorUnitsPerMajor);

  Money operator +(Money other) {
    _assertSameCurrency(other, 'add');
    return Money.fromMinorUnits(minorUnits + other.minorUnits, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other, 'subtract');
    return Money.fromMinorUnits(minorUnits - other.minorUnits, currency);
  }

  Money operator -() => Money.fromMinorUnits(-minorUnits, currency);

  /// Scales by a whole number — three identical transfers, say. Fractional
  /// scaling belongs in [scaledBy], which is explicit about rounding.
  Money operator *(int factor) =>
      Money.fromMinorUnits(minorUnits * factor, currency);

  Money abs() => Money.fromMinorUnits(minorUnits.abs(), currency);

  /// Multiplies by the exact fraction [numerator] / [denominator], rounding
  /// half away from zero.
  ///
  /// Expressed as a ratio rather than a double so no rounding happens before
  /// this method gets to decide how to round. Percentages, interest and
  /// exchange rates all arrive here as integer ratios.
  Money scaledBy(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError.value(denominator, 'denominator', 'Cannot be zero');
    }
    final scaled = _divideRoundingHalfAwayFromZero(
      BigInt.from(minorUnits) * BigInt.from(numerator),
      BigInt.from(denominator),
    );
    return Money.fromMinorUnits(scaled.toInt(), currency);
  }

  /// This amount as a share of [total], as a fraction between 0 and 1.
  ///
  /// Returns a double *on purpose*: the result is a proportion for a bar or a
  /// label, never money. Nothing may convert it back into an amount.
  double shareOf(Money total) {
    _assertSameCurrency(total, 'compare');
    if (total.minorUnits == 0) return 0;
    return minorUnits / total.minorUnits;
  }

  /// Sums [amounts], which must all share [currency].
  static Money sum(Iterable<Money> amounts, Currency currency) {
    var total = 0;
    for (final amount in amounts) {
      if (amount.currency != currency) {
        throw CurrencyMismatchException(currency, amount.currency, 'sum');
      }
      total += amount.minorUnits;
    }
    return Money.fromMinorUnits(total, currency);
  }

  void _assertSameCurrency(Money other, String operation) {
    if (currency != other.currency) {
      throw CurrencyMismatchException(currency, other.currency, operation);
    }
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other, 'compare');
    return minorUnits.compareTo(other.minorUnits);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Money &&
      other.minorUnits == minorUnits &&
      other.currency == currency;

  @override
  int get hashCode => Object.hash(minorUnits, currency);

  /// Unlocalised, for logs and test failures. User-facing text comes from
  /// `MoneyFormatter`, which knows the locale and the digit-style setting.
  @override
  String toString() {
    final sign = isNegative ? '-' : '';
    final units = minorUnits.abs();
    final factor = currency.minorUnitsPerMajor;
    if (currency.decimalDigits == 0) return '$sign$units ${currency.code}';
    final whole = units ~/ factor;
    final fraction = (units % factor)
        .toString()
        .padLeft(currency.decimalDigits, '0');
    return '$sign$whole.$fraction ${currency.code}';
  }
}

/// Integer division rounding halves away from zero.
///
/// Half away from zero, not banker's rounding: it is what people expect when
/// they check a conversion by hand, and it keeps `x` and `-x` symmetric, which
/// matters because a debt and a credit for the same amount must round to the
/// same magnitude.
BigInt _divideRoundingHalfAwayFromZero(BigInt numerator, BigInt denominator) {
  if (denominator.isNegative) {
    numerator = -numerator;
    denominator = -denominator;
  }
  final negative = numerator.isNegative;
  final absolute = numerator.abs();
  final quotient = absolute ~/ denominator;
  final remainder = absolute.remainder(denominator);
  final roundUp = remainder * BigInt.two >= denominator;
  final magnitude = roundUp ? quotient + BigInt.one : quotient;
  return negative ? -magnitude : magnitude;
}

bool _isDigits(String s) {
  if (s.isEmpty) return false;
  for (final unit in s.codeUnits) {
    if (unit < 0x30 || unit > 0x39) return false;
  }
  return true;
}

const int _arabicIndicZero = 0x0660; // ٠
const int _extendedArabicIndicZero = 0x06F0; // ۰

String _toWesternDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= _arabicIndicZero && rune <= _arabicIndicZero + 9) {
      buffer.writeCharCode(0x30 + (rune - _arabicIndicZero));
    } else if (rune >= _extendedArabicIndicZero &&
        rune <= _extendedArabicIndicZero + 9) {
      buffer.writeCharCode(0x30 + (rune - _extendedArabicIndicZero));
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}
