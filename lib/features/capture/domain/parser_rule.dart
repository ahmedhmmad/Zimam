import '../../../core/money/currency.dart';
import 'captured_notification.dart';

/// Thrown when a rule pack cannot be understood.
class ParserRuleFormatException implements Exception {
  const ParserRuleFormatException(this.message, {this.ruleId});
  final String message;
  final String? ruleId;
  @override
  String toString() =>
      'ParserRuleFormatException${ruleId == null ? '' : ' [$ruleId]'}: '
      '$message';
}

/// One parsing rule, defined as data rather than code.
///
/// Rules are data on purpose. Every bank formats its notifications
/// differently, formats change without warning, and the app's audience uses
/// institutions no developer will ever have an account with — so the set of
/// patterns has to be extendable without shipping a new binary.
///
/// A rule is a package matcher plus one regular expression with named groups.
/// The groups are the field mapping: `amount`, `currency`, `balance` and
/// `merchant` are read straight out of the match by name.
final class ParserRule {
  const ParserRule({
    required this.id,
    required this.packages,
    required this.pattern,
    this.direction,
    this.debitKeywords = const [],
    this.creditKeywords = const [],
    this.defaultCurrencyCode,
  });

  /// Stable identifier, recorded on every suggestion so a bad rule can be
  /// traced back from a wrong figure.
  final String id;

  /// Android package names this rule applies to. Empty means any package,
  /// which is only sensible for very specific patterns.
  final List<String> packages;

  /// Matched against [CapturedNotification.text].
  final RegExp pattern;

  /// Fixed direction, when the rule only ever matches one kind of message.
  final TransactionDirection? direction;

  /// Words that decide the direction when [direction] is null. Checked
  /// case-insensitively against the whole notification.
  ///
  /// Keyword inference exists because most banks use one template for both
  /// directions and vary a single word — "debited"/"credited",
  /// "خصم"/"إيداع" — so a rule per direction would double the pack for no gain.
  final List<String> debitKeywords;
  final List<String> creditKeywords;

  /// Used when the message states an amount without naming its currency,
  /// which is common for domestic transactions.
  final String? defaultCurrencyCode;

  bool matchesPackage(String packageName) =>
      packages.isEmpty || packages.contains(packageName);

  /// Parses one rule from its JSON form.
  ///
  /// Validation is strict and throws: a malformed rule that silently did
  /// nothing would be worse than one that fails loudly, because the failure
  /// mode is a transaction quietly never being suggested.
  factory ParserRule.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const ParserRuleFormatException('Rule needs a non-empty id');
    }

    final patternSource = json['pattern'];
    if (patternSource is! String || patternSource.isEmpty) {
      throw ParserRuleFormatException('Rule needs a pattern', ruleId: id);
    }

    final RegExp pattern;
    try {
      pattern = RegExp(
        patternSource,
        caseSensitive: false,
        multiLine: true,
        dotAll: true,
      );
    } on FormatException catch (e) {
      throw ParserRuleFormatException(
        'Pattern is not a valid regular expression: ${e.message}',
        ruleId: id,
      );
    }

    final currency = json['defaultCurrency'];
    if (currency is String && !CurrencyRegistry.isKnown(currency)) {
      throw ParserRuleFormatException(
        'defaultCurrency "$currency" is not ISO 4217',
        ruleId: id,
      );
    }

    return ParserRule(
      id: id,
      packages: _stringList(json['packages']),
      pattern: pattern,
      direction: TransactionDirection.decode(json['direction'] as String?),
      debitKeywords: _stringList(json['debitKeywords']),
      creditKeywords: _stringList(json['creditKeywords']),
      defaultCurrencyCode: currency as String?,
    );
  }

  static List<String> _stringList(Object? value) {
    if (value == null) return const [];
    if (value is! List) return const [];
    return value.whereType<String>().toList(growable: false);
  }
}

/// A parsed set of rules, with the version it came from.
final class ParserRulePack {
  const ParserRulePack({required this.version, required this.rules});

  /// Increments with each published pack. A remote pack older than the bundled
  /// one is ignored, so a rollback upstream cannot downgrade a working app.
  final int version;

  final List<ParserRule> rules;

  factory ParserRulePack.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    if (version is! int) {
      throw const ParserRuleFormatException('Pack needs an integer version');
    }
    final rules = json['rules'];
    if (rules is! List) {
      throw const ParserRuleFormatException('Pack needs a rules array');
    }

    return ParserRulePack(
      version: version,
      rules: [
        for (final rule in rules)
          if (rule is Map<String, dynamic>) ParserRule.fromJson(rule),
      ],
    );
  }

  static const empty = ParserRulePack(version: 0, rules: []);
}
