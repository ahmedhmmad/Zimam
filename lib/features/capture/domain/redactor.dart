/// Strips identifying detail out of a notification before it can be shared.
///
/// Used only by the opt-in "help improve parsing" action, and only on a single
/// item the user has picked. It runs *before* the payload is shown, so what
/// the user reviews and approves is byte-for-byte what would be sent.
///
/// The design assumption is that the redactor will miss things. It is a
/// mechanical filter over prose written by third parties in two languages, so
/// treating it as sufficient on its own would be wrong. It is one of three
/// safeguards, and the weakest of them: the user chooses the item, sees the
/// exact redacted text, and confirms. Nothing is ever sent in bulk or in the
/// background.
abstract final class NotificationRedactor {
  /// Every digit becomes `#`. Amounts, account numbers, card suffixes,
  /// reference numbers, dates and phone numbers are all digits, and the
  /// parsing problem being reported is about *shape* rather than value — the
  /// pattern that failed is just as diagnosable with the figures gone.
  static const String digitMask = '#';

  /// Replaces every digit, in every numeral system the app accepts.
  static String maskDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (_isDigit(rune)) {
        buffer.write(digitMask);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  static bool _isDigit(int rune) =>
      (rune >= 0x30 && rune <= 0x39) || // 0-9
      (rune >= 0x0660 && rune <= 0x0669) || // Arabic-Indic
      (rune >= 0x06F0 && rune <= 0x06F9); // Extended Arabic-Indic

  /// Tokens that look like an identifier rather than a word: long runs mixing
  /// letters and masked digits, e.g. an IBAN or a reference code.
  static final _identifierLike = RegExp(r'\b(?=\S*#)\S{6,}\b');

  /// Words following a salutation, which is where a name usually sits.
  ///
  /// Covers the common openings in both languages. Deliberately narrow: a
  /// broad "capitalised words are names" rule would eat the bank's own name
  /// and the currency, leaving a sample too gutted to diagnose anything.
  static final _salutation = RegExp(
    r'((?:dear|hello|hi|mr\.?|mrs\.?|ms\.?|عزيزي|عزيزتي|السيد|السيدة)\s+)'
    r'([^\s,.،]+(?:\s+[^\s,.،]+){0,2})',
    caseSensitive: false,
  );

  /// The full redaction, in the order the pieces depend on each other.
  static String redact(String input) {
    var text = maskDigits(input);
    text = text.replaceAllMapped(_salutation, (m) => '${m[1]}[name]');
    text = text.replaceAll(_identifierLike, '[ref]');
    // Long runs of mask characters carry no more information than short ones
    // and make the sample harder to read.
    text = text.replaceAll(RegExp('$digitMask{4,}'), '$digitMask$digitMask$digitMask$digitMask');
    return text.trim();
  }

  /// What would actually be transmitted for one sample.
  ///
  /// The package name is kept unredacted and deliberately so: it is the single
  /// most useful field for writing a rule, it identifies an application rather
  /// than a person, and it is already visible to every app on the device.
  static RedactedSample forSample({
    required String packageName,
    required String title,
    required String body,
  }) => RedactedSample(
    packageName: packageName,
    title: redact(title),
    body: redact(body),
  );
}

/// The exact payload a user is asked to approve.
final class RedactedSample {
  const RedactedSample({
    required this.packageName,
    required this.title,
    required this.body,
  });

  final String packageName;
  final String title;
  final String body;

  /// Rendered for the confirmation screen. This string is what the user reads
  /// and what gets sent — there is no second, richer version behind it.
  String get preview =>
      'app: $packageName\ntitle: $title\nbody: $body';

  Map<String, Object?> toJson() => {
    'package': packageName,
    'title': title,
    'body': body,
  };
}
