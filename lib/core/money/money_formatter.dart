import 'package:intl/intl.dart';

import 'money.dart';

/// Which numerals to draw an amount with.
///
/// A locale choice, not a language consequence. `intl` renders the `ar` locale
/// with Arabic-Indic digits (`١٢٣`) by default, but most Gulf and Levant
/// banking apps show Western digits, and plenty of Arabic speakers read prose
/// in Arabic while expecting figures in `123`. So the two decisions are
/// separated and the user owns this one. See `docs/ARCHITECTURE.md` §5.
enum DigitStyle {
  /// `1,234.560`. The default, in both languages.
  western,

  /// `١٬٢٣٤٫٥٦٠`.
  arabicIndic,
}

/// Renders [Money] as text.
///
/// The formatter takes the locale and the digit style as explicit inputs
/// rather than reading ambient state, which keeps it a pure function and
/// directly testable — and stops `intl` quietly deciding glyphs based on the
/// UI language when the user has asked for something else.
final class MoneyFormatter {
  const MoneyFormatter({
    required this.locale,
    this.digitStyle = DigitStyle.western,
  });

  final String locale;
  final DigitStyle digitStyle;

  /// `JOD 1,234.560` — the amount with its ISO code.
  ///
  /// The code rather than the symbol is the default throughout the app, and
  /// deliberately so: this is a multi-currency tracker where `$` could be USD,
  /// CAD, AUD or a dozen others, and `£` could be GBP or several pounds
  /// besides. Ambiguity about which currency a figure is in defeats the point.
  String format(Money money, {bool showCode = true}) {
    final digits = money.currency.decimalDigits;
    // Zero decimals here on purpose: this formatter supplies grouping and the
    // locale's separators for the whole part only. The fraction is appended
    // from integer minor units below, so no double ever touches the amount.
    final pattern = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 0,
    );

    final factor = money.currency.minorUnitsPerMajor;
    final units = money.minorUnits.abs();
    // Build the numeric text from integer parts so no double is ever involved.
    final whole = units ~/ factor;
    final fraction = units % factor;

    var text = pattern.format(whole);
    if (digits > 0) {
      final fractionText = fraction.toString().padLeft(digits, '0');
      text = '$text${_decimalSeparator(pattern)}$fractionText';
    }

    text = _applyDigitStyle(text);
    if (money.isNegative) text = '-$text';
    return showCode ? '${money.currency.code} $text' : text;
  }

  /// `+JOD 1,240.000` / `−JOD 214.300` — a change, with an explicit sign.
  ///
  /// Uses a real minus sign (U+2212) rather than a hyphen so the glyph lines
  /// up with the plus at the same optical weight in tabular figures.
  String formatSigned(Money money, {bool showCode = true}) {
    final magnitude = format(money.abs(), showCode: showCode);
    if (money.isZero) return magnitude;
    return money.isNegative ? '−$magnitude' : '+$magnitude';
  }

  /// `68%`. Takes the fraction from [Money.shareOf].
  String formatShare(double fraction, {int decimalDigits = 0}) {
    final pattern = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: decimalDigits,
    );
    return _applyDigitStyle(pattern.format(fraction));
  }

  String _decimalSeparator(NumberFormat pattern) =>
      pattern.symbols.DECIMAL_SEP;

  String _applyDigitStyle(String text) => switch (digitStyle) {
    DigitStyle.western => _toWestern(text),
    DigitStyle.arabicIndic => _toArabicIndic(text),
  };

  static const int _asciiZero = 0x30;
  static const int _arabicIndicZero = 0x0660;
  static const int _extendedArabicIndicZero = 0x06F0;
  static const String _arabicDecimal = '٫';
  static const String _arabicGroup = '٬';

  static String _toWestern(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= _arabicIndicZero && rune <= _arabicIndicZero + 9) {
        buffer.writeCharCode(_asciiZero + rune - _arabicIndicZero);
      } else if (rune >= _extendedArabicIndicZero &&
          rune <= _extendedArabicIndicZero + 9) {
        buffer.writeCharCode(_asciiZero + rune - _extendedArabicIndicZero);
      } else if (rune == _arabicDecimal.runes.first) {
        buffer.write('.');
      } else if (rune == _arabicGroup.runes.first) {
        buffer.write(',');
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static String _toArabicIndic(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= _asciiZero && rune <= _asciiZero + 9) {
        buffer.writeCharCode(_arabicIndicZero + rune - _asciiZero);
      } else if (rune == 0x2E) {
        buffer.write(_arabicDecimal);
      } else if (rune == 0x2C) {
        buffer.write(_arabicGroup);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}
