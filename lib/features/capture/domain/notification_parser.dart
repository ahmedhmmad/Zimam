import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import 'captured_notification.dart';
import 'parser_rule.dart';

/// What a rule extracted from one notification.
///
/// A *suggestion*, never a ledger entry. Nothing here is written to an account
/// until the user has looked at it and said yes — a regex over a bank's prose
/// is a guess, however good, and a wrong balance silently entered is worse
/// than no balance at all.
final class ParsedNotification {
  const ParsedNotification({
    required this.ruleId,
    required this.amount,
    required this.direction,
    required this.postedAt,
    this.balanceAfter,
    this.merchant,
  });

  final String ruleId;
  final Money amount;
  final TransactionDirection direction;
  final DateTime postedAt;

  /// The account balance the message reported, when it stated one. This is the
  /// figure worth capturing — it is an observation of the true balance rather
  /// than something inferred by arithmetic.
  final Money? balanceAfter;

  final String? merchant;

  /// The amount signed by direction, for display.
  Money get signedAmount =>
      direction == TransactionDirection.debit ? -amount : amount;

  @override
  String toString() =>
      'ParsedNotification($ruleId, $direction $amount, balance $balanceAfter)';
}

/// Applies rules to notifications.
///
/// Pure and synchronous. The input is arbitrary text from third-party apps, so
/// everything here has to be safe against nonsense: a rule that matches
/// garbage must produce nothing rather than a plausible-looking wrong number.
final class NotificationParser {
  const NotificationParser(this.rules);

  final List<ParserRule> rules;

  /// Currency symbols and local abbreviations seen in real notifications.
  ///
  /// Kept deliberately small and unambiguous. `$` is *not* here: it could be
  /// USD, CAD, AUD or a dozen others, and this app's whole point is that
  /// guessing which one is unacceptable.
  static const Map<String, String> _currencyAliases = {
    'JD': 'JOD',
    'د.أ': 'JOD',
    'دينار': 'JOD',
    'AED': 'AED',
    'درهم': 'AED',
    'ر.س': 'SAR',
    'ريال': 'SAR',
    'ج.م': 'EGP',
    'جنيه': 'EGP',
    '£': 'GBP',
    '€': 'EUR',
  };

  /// Returns null when nothing matched, which is the common case and not an
  /// error — most notifications are not transactions.
  ParsedNotification? parse(CapturedNotification notification) {
    for (final rule in rules) {
      if (!rule.matchesPackage(notification.packageName)) continue;

      final ParsedNotification? parsed;
      try {
        parsed = _apply(rule, notification);
      } on Object {
        // One bad rule must not stop the others from being tried. Rules can
        // arrive from a remote pack, so this is untrusted input.
        continue;
      }
      if (parsed != null) return parsed;
    }
    return null;
  }

  ParsedNotification? _apply(
    ParserRule rule,
    CapturedNotification notification,
  ) {
    final match = rule.pattern.firstMatch(notification.text);
    if (match == null) return null;

    final amountText = _group(match, 'amount');
    if (amountText == null) return null;

    final currency = _resolveCurrency(match, rule, notification.text);
    if (currency == null) return null;

    final amount = _parseMoney(amountText, currency);
    // A zero or negative "amount" means the pattern latched onto the wrong
    // number — a reference or a date — so the match is discarded rather than
    // offered as a transaction.
    if (amount == null || !amount.isPositive) return null;

    final direction = _resolveDirection(rule, notification.text);
    if (direction == null) return null;

    final balanceText = _group(match, 'balance');
    final balance = balanceText == null
        ? null
        : _parseMoney(balanceText, currency);

    final merchant = _group(match, 'merchant')?.trim();

    return ParsedNotification(
      ruleId: rule.id,
      amount: amount,
      direction: direction,
      postedAt: notification.postedAt,
      balanceAfter: balance,
      merchant: (merchant == null || merchant.isEmpty) ? null : merchant,
    );
  }

  /// Reads a named group, tolerating rules that do not define it.
  static String? _group(RegExpMatch match, String name) {
    if (!match.groupNames.contains(name)) return null;
    final value = match.namedGroup(name);
    return (value == null || value.isEmpty) ? null : value;
  }

  Currency? _resolveCurrency(
    RegExpMatch match,
    ParserRule rule,
    String text,
  ) {
    final captured = _group(match, 'currency');
    if (captured != null) {
      final direct = CurrencyRegistry.tryOf(captured);
      if (direct != null) return direct;
      final alias = _currencyAliases[captured.trim()];
      if (alias != null) return CurrencyRegistry.tryOf(alias);
    }

    final fallback = rule.defaultCurrencyCode;
    if (fallback != null) return CurrencyRegistry.tryOf(fallback);

    // No currency named and no default. Refusing beats assuming: an amount
    // filed under the wrong currency corrupts the net worth silently.
    return null;
  }

  TransactionDirection? _resolveDirection(ParserRule rule, String text) {
    if (rule.direction != null) return rule.direction;

    final lower = text.toLowerCase();
    final debit = rule.debitKeywords.any(
      (k) => lower.contains(k.toLowerCase()),
    );
    final credit = rule.creditKeywords.any(
      (k) => lower.contains(k.toLowerCase()),
    );

    // Both or neither means the message is ambiguous, and a guess would be a
    // coin flip on whether money came in or went out.
    if (debit == credit) return null;
    return debit ? TransactionDirection.debit : TransactionDirection.credit;
  }

  /// Parses an amount out of prose, tolerating the separators banks use.
  static Money? _parseMoney(String raw, Currency currency) {
    var text = raw.trim();
    if (text.isEmpty) return null;

    // Strip anything that is not a digit, separator or sign. Notifications
    // wrap amounts in currency codes, symbols and directional marks.
    text = text.replaceAll(RegExp(r'[^\d٠-٩۰-۹.,٫٬\-]'), '');
    if (text.isEmpty) return null;

    // European formatting: 1.234,56 — the comma is the decimal separator.
    // Detected by the last comma sitting after the last dot.
    final lastDot = text.lastIndexOf('.');
    final lastComma = text.lastIndexOf(',');
    if (lastComma > lastDot) {
      text = text.replaceAll('.', '').replaceAll(',', '.');
    }

    try {
      final money = Money.parse(text, currency);
      return money;
    } on FormatException {
      // A message may quote more precision than the currency has — a rate, or
      // a foreign amount. Truncating would invent a figure, so it is dropped.
      return null;
    }
  }
}
