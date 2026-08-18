import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/features/capture/domain/redactor.dart';

/// The redactor backs a privacy promise, so these tests are written from the
/// standpoint of "what could still leak" rather than "does it work".
void main() {
  group('digits', () {
    test('every Western digit is masked', () {
      expect(
        NotificationRedactor.redact('Debited JOD 45.500 on 12/03/2026'),
        isNot(matches(RegExp(r'\d'))),
      );
    });

    test('Arabic-Indic digits are masked too', () {
      // A phone set to Arabic renders the same alert in these, and a redactor
      // that only knew ASCII would pass the amount through untouched.
      const input = 'تم خصم ٤٥٫٥٠٠ من حسابك ٠١٢٣';
      final redacted = NotificationRedactor.redact(input);
      for (final digit in ['٠', '١', '٢', '٣', '٤', '٥']) {
        expect(redacted, isNot(contains(digit)), reason: 'leaked $digit');
      }
    });

    test('extended Arabic-Indic digits are masked', () {
      final redacted = NotificationRedactor.redact('مبلغ ۱۲۳۴');
      for (final digit in ['۱', '۲', '۳', '۴']) {
        expect(redacted, isNot(contains(digit)));
      }
    });

    test('an account number cannot be reconstructed from the mask', () {
      // Long runs collapse, so the *length* of an account number does not
      // survive either.
      final redacted = NotificationRedactor.redact('IBAN JO94CBJO0010000000000131000302');
      expect(redacted, isNot(matches(RegExp(r'\d'))));
      expect(redacted, isNot(contains('##########')));
    });
  });

  group('names', () {
    test('a name after a salutation is removed', () {
      final redacted = NotificationRedactor.redact(
        'Dear Ahmed Hammad, your account has been debited',
      );
      expect(redacted, isNot(contains('Ahmed')));
      expect(redacted, isNot(contains('Hammad')));
      expect(redacted, contains('[name]'));
    });

    test('an Arabic salutation is handled', () {
      final redacted = NotificationRedactor.redact('عزيزي أحمد حماد، تم خصم');
      expect(redacted, isNot(contains('أحمد')));
      expect(redacted, contains('[name]'));
    });

    test('the bank name and currency survive, or the sample is useless', () {
      // Over-redaction has a cost: a sample with the institution stripped out
      // cannot be turned into a rule.
      final redacted = NotificationRedactor.redact(
        'Bank al Etihad: JOD 45.500 debited at CARREFOUR',
      );
      expect(redacted, contains('Bank al Etihad'));
      expect(redacted, contains('JOD'));
      expect(redacted, contains('debited'));
    });
  });

  group('the payload the user approves', () {
    test('is exactly what would be sent', () {
      final sample = NotificationRedactor.forSample(
        packageName: 'com.bank.mobile',
        title: 'Dear Ahmed, transaction alert',
        body: 'JOD 45.500 debited. Balance JOD 1,204.750',
      );

      // Everything in the preview is in the JSON and vice versa: there is no
      // richer version hiding behind the screen.
      expect(sample.preview, contains(sample.packageName));
      expect(sample.preview, contains(sample.title));
      expect(sample.preview, contains(sample.body));

      final json = sample.toJson();
      expect(json.keys.toSet(), {'package', 'title', 'body'});
      expect(json['title'], sample.title);
      expect(json['body'], sample.body);
    });

    test('carries no digits at all', () {
      final sample = NotificationRedactor.forSample(
        packageName: 'com.bank.mobile',
        title: 'Alert 4021',
        body: 'JOD 45.500 debited from card ending 1234',
      );
      expect(sample.title, isNot(matches(RegExp(r'\d'))));
      expect(sample.body, isNot(matches(RegExp(r'\d'))));
    });

    test('keeps the package name, which identifies an app not a person', () {
      // It is the single most useful field for writing a rule, and every app
      // on the device can already see it.
      final sample = NotificationRedactor.forSample(
        packageName: 'com.bank.mobile',
        title: '',
        body: '',
      );
      expect(sample.packageName, 'com.bank.mobile');
    });
  });

  group('edge cases', () {
    test('empty input stays empty', () {
      expect(NotificationRedactor.redact(''), '');
    });

    test('text with no digits or names is unchanged in substance', () {
      final redacted = NotificationRedactor.redact('Your statement is ready');
      expect(redacted, 'Your statement is ready');
    });

    test('redaction is idempotent', () {
      // The preview may be re-rendered; running it twice must not degrade it
      // further or the user would approve one thing and send another.
      const input = 'Dear Ahmed, JOD 45.500 debited from 1234';
      final once = NotificationRedactor.redact(input);
      expect(NotificationRedactor.redact(once), once);
    });
  });
}
