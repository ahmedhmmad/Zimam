import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/capture/domain/captured_notification.dart';
import 'package:zimam/features/capture/domain/notification_parser.dart';
import 'package:zimam/features/capture/domain/parser_rule.dart';

/// The parser's input is arbitrary text written by third parties, so the cases
/// that matter most are the ones where it must produce *nothing* rather than a
/// plausible-looking wrong number.
void main() {
  final jod = CurrencyRegistry.of('JOD');
  final usd = CurrencyRegistry.of('USD');
  final aed = CurrencyRegistry.of('AED');
  final at = DateTime.utc(2026, 3, 20, 14, 30);

  late NotificationParser parser;

  setUpAll(() {
    // The pack that actually ships, not a fixture — so a broken rule fails
    // here rather than on a user's phone.
    final file = File('assets/parser_rules/rules.json');
    final pack = ParserRulePack.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
    parser = NotificationParser(pack.rules);
  });

  CapturedNotification note(String body, {String title = '', String? pkg}) =>
      CapturedNotification(
        packageName: pkg ?? 'com.example.bank',
        title: title,
        body: body,
        postedAt: at,
      );

  group('the shipped pack loads', () {
    test('parses and has rules', () {
      expect(parser.rules, isNotEmpty);
      for (final rule in parser.rules) {
        expect(rule.id, isNotEmpty);
      }
    });

    test('rule ids are unique', () {
      final ids = parser.rules.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('English alerts', () {
    test('reads a debit with a resulting balance', () {
      final parsed = parser.parse(
        note(
          'Your account has been debited JOD 45.500 at CARREFOUR. '
          'Available balance JOD 1,204.750',
        ),
      );

      expect(parsed, isNotNull);
      expect(parsed!.amount, Money.parse('45.500', jod));
      expect(parsed.direction, TransactionDirection.debit);
      expect(parsed.balanceAfter, Money.parse('1204.750', jod));
      expect(parsed.postedAt, at);
    });

    test('reads a credit', () {
      final parsed = parser.parse(
        note('Your salary has been credited USD 3,200.00 to your account'),
      );
      expect(parsed!.direction, TransactionDirection.credit);
      expect(parsed.amount, Money.parse('3200.00', usd));
    });

    test('reads an amount-first alert', () {
      final parsed = parser.parse(
        note('AED 250.00 has been debited from your card at Talabat'),
      );
      expect(parsed!.amount, Money.parse('250.00', aed));
      expect(parsed.direction, TransactionDirection.debit);
    });

    test('uses the title as well as the body', () {
      // Banks split the same sentence differently, and some put the amount in
      // the title.
      final parsed = parser.parse(
        note(
          'Available balance JOD 900.000',
          title: 'Purchase of JOD 15.250 at a merchant',
        ),
      );
      expect(parsed!.amount, Money.parse('15.250', jod));
    });

    test('signs the amount by direction for display', () {
      final debit = parser.parse(note('debited JOD 10.000'))!;
      expect(debit.signedAmount, Money.parse('-10.000', jod));

      final credit = parser.parse(note('credited JOD 10.000'))!;
      expect(credit.signedAmount, Money.parse('10.000', jod));
    });
  });

  group('Arabic alerts', () {
    test('reads a debit', () {
      final parsed = parser.parse(note('تم خصم 45.500 JOD من حسابك'));
      expect(parsed, isNotNull);
      expect(parsed!.amount, Money.parse('45.500', jod));
      expect(parsed.direction, TransactionDirection.debit);
    });

    test('reads a credit', () {
      final parsed = parser.parse(note('تم إيداع 1,500.00 AED في حسابك'));
      expect(parsed!.direction, TransactionDirection.credit);
      expect(parsed.amount, Money.parse('1500.00', aed));
    });

    test('reads Arabic-Indic digits', () {
      // The same message a phone set to Arabic would show.
      final parsed = parser.parse(note('تم خصم ٤٥٫٥٠٠ د.أ من حسابك'));
      expect(parsed, isNotNull);
      expect(parsed!.amount, Money.parse('45.500', jod));
    });

    test('reads a local currency abbreviation', () {
      final parsed = parser.parse(note('تم خصم 20.000 دينار من حسابك'));
      expect(parsed!.amount.currency, jod);
    });
  });

  group('refuses rather than guesses', () {
    test('an unrelated notification produces nothing', () {
      expect(parser.parse(note('Your package will arrive tomorrow')), isNull);
      expect(parser.parse(note('3 new messages')), isNull);
      expect(parser.parse(note('')), isNull);
    });

    test('a dollar sign is not treated as a currency', () {
      // $ could be USD, CAD, AUD or a dozen others, and this app exists
      // precisely because which one it is matters.
      expect(parser.parse(note('debited \$45.00 at a shop')), isNull);
    });

    test('an amount with no currency anywhere produces nothing', () {
      expect(parser.parse(note('debited 45.500 from your account')), isNull);
    });

    test('an ambiguous direction produces nothing', () {
      // Both words present: guessing which way the money went is a coin flip.
      expect(
        parser.parse(note('JOD 10.000 debited and credited in error')),
        isNull,
      );
    });

    test('a zero amount is rejected', () {
      // A pattern that latched onto a reference number or a date rather than
      // an amount.
      expect(parser.parse(note('debited JOD 0.000 today')), isNull);
    });

    test('more precision than the currency has is rejected', () {
      // JOD has three places; four means the pattern caught a rate or a
      // foreign amount, and truncating would invent a figure.
      expect(parser.parse(note('debited JOD 45.5001 today')), isNull);
    });

    test('an unknown currency code produces nothing', () {
      expect(parser.parse(note('debited XYZ 45.00 today')), isNull);
    });
  });

  group('malformed rules', () {
    test('a rule with a broken pattern is rejected at load', () {
      expect(
        () => ParserRule.fromJson({'id': 'bad', 'pattern': '([unclosed'}),
        throwsA(isA<ParserRuleFormatException>()),
      );
    });

    test('a rule with no id is rejected', () {
      expect(
        () => ParserRule.fromJson({'pattern': 'x'}),
        throwsA(isA<ParserRuleFormatException>()),
      );
    });

    test('a rule naming an unknown default currency is rejected', () {
      expect(
        () => ParserRule.fromJson({
          'id': 'x',
          'pattern': 'x',
          'defaultCurrency': 'XYZ',
        }),
        throwsA(isA<ParserRuleFormatException>()),
      );
    });

    test('one throwing rule does not stop the others', () {
      // Rules can arrive from a remote pack, so they are untrusted input.
      final rules = [
        ParserRule(
          id: 'explodes',
          packages: const [],
          // Catastrophic backtracking is a real risk with pack-supplied
          // patterns; whatever the failure, the next rule must still run.
          pattern: RegExp(r'(?<amount>\d+)'),
          direction: TransactionDirection.debit,
          // No currency and no default, so this rule always bails out.
        ),
        ParserRule(
          id: 'works',
          packages: const [],
          pattern: RegExp(r'(?<currency>[A-Z]{3})\s*(?<amount>[\d.]+)'),
          direction: TransactionDirection.credit,
        ),
      ];
      final parsed = NotificationParser(rules).parse(note('JOD 12.000'));
      expect(parsed?.ruleId, 'works');
    });
  });

  group('package matching', () {
    test('a rule limited to packages ignores other apps', () {
      final rules = [
        ParserRule(
          id: 'one-bank',
          packages: const ['com.mybank.app'],
          pattern: RegExp(r'(?<currency>[A-Z]{3})\s*(?<amount>[\d.]+)'),
          direction: TransactionDirection.debit,
        ),
      ];
      final parser = NotificationParser(rules);

      expect(
        parser.parse(note('JOD 5.000', pkg: 'com.mybank.app')),
        isNotNull,
      );
      expect(parser.parse(note('JOD 5.000', pkg: 'com.other.app')), isNull);
    });
  });
}
