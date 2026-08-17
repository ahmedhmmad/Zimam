import '../money/currency.dart';
import '../money/money.dart';

/// An exchange rate for one pair on one day, as an exact integer.
///
/// A rate is a ratio, so representing it as a double would reintroduce the
/// drift that integer money exists to prevent — the conversion would be the
/// one place a fraction of a fils leaks back in. The rate is therefore held
/// as `rate × 10^8`, and conversion runs through [BigInt] so nothing
/// overflows on the way.
///
/// Eight decimal places is not arbitrary: weak-currency pairs need it. One
/// Kuwaiti dinar is roughly 160,000 Vietnamese dong, so the reverse rate is
/// about 0.00000625 — four or six places would quantise that into nonsense.
final class FxRate {
  const FxRate({
    required this.base,
    required this.quote,
    required this.rateScaled,
    required this.rateDate,
    required this.fetchedAt,
  });

  /// Builds a rate from a decimal string, exactly, without a double.
  factory FxRate.parse({
    required Currency base,
    required Currency quote,
    required String rate,
    required DateTime rateDate,
    required DateTime fetchedAt,
  }) {
    return FxRate(
      base: base,
      quote: quote,
      rateScaled: parseScaled(rate),
      rateDate: rateDate,
      fetchedAt: fetchedAt,
    );
  }

  /// How many decimal places [rateScaled] carries.
  static const int scaleDigits = 8;

  /// 10^[scaleDigits].
  static const int scaleFactor = 100000000;

  final Currency base;
  final Currency quote;

  /// The rate × [scaleFactor]. 1 base currency buys this many quote currency.
  final int rateScaled;

  /// The day this rate is *for*, at UTC midnight.
  final DateTime rateDate;

  /// When it was retrieved, which is not the same thing — see [stalenessFrom].
  final DateTime fetchedAt;

  /// A rate of exactly 1, for converting a currency to itself.
  factory FxRate.identity(Currency currency, DateTime asOf) => FxRate(
    base: currency,
    quote: currency,
    rateScaled: scaleFactor,
    rateDate: asOf,
    fetchedAt: asOf,
  );

  bool get isIdentity => base == quote;

  /// Parses a decimal rate string into scaled integer form, truncating below
  /// the eighth place rather than rounding — a rate is an observation, and
  /// inventing precision it did not have would be worse than dropping it.
  static int parseScaled(String rate) {
    final text = rate.trim();
    if (text.isEmpty) throw FormatException('Empty rate', rate);

    var negative = false;
    var body = text;
    if (body.startsWith('-')) {
      negative = true;
      body = body.substring(1);
    }

    // Exponent form shows up in JSON for very small rates (1e-7).
    if (body.contains('e') || body.contains('E')) {
      return _parseExponential(body, negative, rate);
    }

    final parts = body.split('.');
    if (parts.length > 2) throw FormatException('Malformed rate', rate);
    final whole = parts[0].isEmpty ? '0' : parts[0];
    var fraction = parts.length == 2 ? parts[1] : '';
    if (whole.isEmpty && fraction.isEmpty) {
      throw FormatException('Malformed rate', rate);
    }
    if (fraction.length > scaleDigits) {
      fraction = fraction.substring(0, scaleDigits);
    }
    fraction = fraction.padRight(scaleDigits, '0');

    final value = int.tryParse('$whole$fraction');
    if (value == null) throw FormatException('Rate out of range', rate);
    return negative ? -value : value;
  }

  static int _parseExponential(String body, bool negative, String original) {
    final value = double.tryParse(body);
    if (value == null) throw FormatException('Malformed rate', original);
    // Round-trip through a fixed-point string so the scaled integer, not the
    // double, is what gets stored.
    final fixed = value.toStringAsFixed(scaleDigits);
    final scaled = parseScaled(fixed);
    return negative ? -scaled : scaled;
  }

  /// Converts [amount] into [quote], rounding half away from zero.
  ///
  /// Handles the differing decimal scales of the two currencies: converting
  /// 10.00 USD (2 places) into JOD (3 places) has to shift by a factor of ten
  /// as well as apply the rate.
  Money convert(Money amount) {
    if (amount.currency != base) {
      throw CurrencyMismatchException(base, amount.currency, 'convert');
    }
    if (isIdentity) return amount;

    // target = source × rate × 10^(quoteDigits − baseDigits)
    var numerator =
        BigInt.from(amount.minorUnits) * BigInt.from(rateScaled);
    var denominator = BigInt.from(scaleFactor);

    final shift = quote.decimalDigits - base.decimalDigits;
    final shiftFactor = BigInt.from(10).pow(shift.abs());
    if (shift > 0) {
      numerator *= shiftFactor;
    } else if (shift < 0) {
      denominator *= shiftFactor;
    }

    final negative = numerator.isNegative;
    final magnitude = numerator.abs();
    final quotient = magnitude ~/ denominator;
    final remainder = magnitude.remainder(denominator);
    final rounded = remainder * BigInt.two >= denominator
        ? quotient + BigInt.one
        : quotient;

    return Money.fromMinorUnits(
      (negative ? -rounded : rounded).toInt(),
      quote,
    );
  }

  /// The reciprocal, for converting back the other way.
  ///
  /// Inverting loses precision below the eighth place, so a value converted
  /// out and back will not always land on the original amount. That is a
  /// property of fixed-point rates, not a bug — but it is why the app stores
  /// both directions from the provider where it can, rather than inverting.
  FxRate inverted() {
    if (rateScaled == 0) {
      throw StateError('Cannot invert a zero rate');
    }
    final numerator = BigInt.from(scaleFactor) * BigInt.from(scaleFactor);
    final inverted = numerator ~/ BigInt.from(rateScaled);
    return FxRate(
      base: quote,
      quote: base,
      rateScaled: inverted.toInt(),
      rateDate: rateDate,
      fetchedAt: fetchedAt,
    );
  }

  /// How far out of date this rate is, relative to [now].
  Duration stalenessFrom(DateTime now) => now.difference(rateDate);

  /// Human-readable decimal form, trailing zeros trimmed.
  String get asDecimalString {
    final negative = rateScaled < 0;
    final digits = rateScaled.abs().toString().padLeft(scaleDigits + 1, '0');
    final whole = digits.substring(0, digits.length - scaleDigits);
    var fraction = digits.substring(digits.length - scaleDigits);
    fraction = fraction.replaceFirst(RegExp(r'0+$'), '');
    final sign = negative ? '-' : '';
    return fraction.isEmpty ? '$sign$whole' : '$sign$whole.$fraction';
  }

  @override
  bool operator ==(Object other) =>
      other is FxRate &&
      other.base == base &&
      other.quote == quote &&
      other.rateScaled == rateScaled &&
      other.rateDate == rateDate;

  @override
  int get hashCode => Object.hash(base, quote, rateScaled, rateDate);

  @override
  String toString() =>
      '1 ${base.code} = $asDecimalString ${quote.code} '
      '(${rateDate.toIso8601String().substring(0, 10)})';
}
