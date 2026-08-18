import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money.dart';
import 'package:zimam/features/capture/data/capture_channel.dart';
import 'package:zimam/features/capture/data/capture_dao.dart';
import 'package:zimam/features/capture/domain/captured_notification.dart';
import 'package:zimam/features/capture/domain/notification_parser.dart';
import 'package:zimam/features/capture/domain/parser_rule.dart';

/// Phase 5's done-condition, end to end: a simulated notification produces a
/// correct pending suggestion, the flow works with the permission denied, and
/// revoking it degrades gracefully to manual entry.
void main() {
  final jod = CurrencyRegistry.of('JOD');
  final at = DateTime.utc(2026, 3, 20, 14, 30);

  late AppDatabase db;
  late CaptureDao dao;
  late NotificationParser parser;

  setUpAll(() {
    final raw = File('assets/parser_rules/rules.json').readAsStringSync();
    final pack = ParserRulePack.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    parser = NotificationParser(pack.rules);
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = CaptureDao(db);
  });

  tearDown(() async => db.close());

  CapturedNotification bankAlert() => CapturedNotification(
    packageName: 'com.etihadbank.mobile',
    title: 'Transaction alert',
    body: 'Your account has been debited JOD 45.500 at CARREFOUR. '
        'Available balance JOD 1,204.750',
    postedAt: at,
  );

  /// The same wiring the app uses, without the platform channel.
  Future<void> handle(CapturedNotification notification) async {
    final stamp = notification.postedAt.microsecondsSinceEpoch.toString();
    final parsed = parser.parse(notification);
    if (parsed == null) {
      await dao.addSample(id: 'sample_$stamp', notification: notification);
      return;
    }
    await dao.addSuggestion(
      id: 'sugg_$stamp',
      parsed: parsed,
      packageName: notification.packageName,
      rawTitle: notification.title,
      rawBody: notification.body,
    );
  }

  group('a simulated notification produces a suggestion', () {
    test('with the right amount, direction and balance', () async {
      await handle(bankAlert());

      final pending = await dao.watchPending().first;
      expect(pending, hasLength(1));

      final suggestion = pending.single;
      expect(suggestion.parsed.amount, Money.parse('45.500', jod));
      expect(suggestion.parsed.direction, TransactionDirection.debit);
      expect(suggestion.parsed.balanceAfter, Money.parse('1204.750', jod));
      expect(suggestion.packageName, 'com.etihadbank.mobile');
    });

    test('keeping the original text so the figure can be checked', () async {
      await handle(bankAlert());
      final suggestion = (await dao.watchPending().first).single;

      expect(suggestion.rawTitle, 'Transaction alert');
      expect(suggestion.rawBody, contains('CARREFOUR'));
    });

    test('and nothing is written to any account', () async {
      // The whole point: a regex over a bank's prose is a guess, so it is
      // offered, never applied.
      await handle(bankAlert());
      expect(await db.select(db.balanceSnapshots).get(), isEmpty);
      expect(await db.select(db.accounts).get(), isEmpty);
    });

    test('confirming resolves it and it leaves the pending list', () async {
      await handle(bankAlert());
      final suggestion = (await dao.watchPending().first).single;

      await dao.resolve(suggestion.id, confirmed: true);
      expect(await dao.watchPending().first, isEmpty);

      // Kept rather than deleted, so the same alert is not offered twice.
      final rows = await db.select(db.pendingSuggestions).get();
      expect(rows.single.resolution, 'confirmed');
      expect(rows.single.resolvedAt, isNotNull);
    });

    test('rejecting also resolves it', () async {
      await handle(bankAlert());
      final suggestion = (await dao.watchPending().first).single;

      await dao.resolve(suggestion.id, confirmed: false);
      expect(await dao.watchPending().first, isEmpty);
      expect(
        (await db.select(db.pendingSuggestions).get()).single.resolution,
        'rejected',
      );
    });
  });

  group('unrecognised notifications', () {
    test('become samples rather than being discarded', () async {
      await handle(
        CapturedNotification(
          packageName: 'com.somebank.app',
          body: 'Your statement for March is ready to view',
          postedAt: at,
        ),
      );

      expect(await dao.watchPending().first, isEmpty);
      expect(await dao.watchSamples().first, hasLength(1));
    });

    test('retention is capped', () async {
      // Third-party text about someone's money: an unbounded log would be
      // indefensible however local it stays.
      for (var i = 0; i < CaptureDao.sampleRetentionLimit + 10; i++) {
        await dao.addSample(
          id: 'sample_$i',
          notification: CapturedNotification(
            packageName: 'com.somebank.app',
            body: 'nothing parseable here',
            postedAt: at.add(Duration(minutes: i)),
          ),
        );
      }

      final samples = await dao.watchSamples().first;
      expect(samples.length, CaptureDao.sampleRetentionLimit);
      // The newest are the ones kept.
      expect(samples.first.postedAt.isAfter(at), isTrue);
    });

    test('sharing marks the item so the user is not asked twice', () async {
      await dao.addSample(id: 's1', notification: bankAlert());
      await dao.markSampleShared('s1');

      final sample = (await dao.watchSamples().first).single;
      expect(sample.sharedAt, isNotNull);
    });
  });

  group('permission denied', () {
    test('the channel reports no access and emits nothing', () async {
      // What every non-Android platform gets, and what a user who declined
      // gets. It has to be a working state, not an error.
      const channel = UnavailableCaptureChannel();

      expect(await channel.isPermissionGranted(), isFalse);
      expect(await channel.isListenerConnected(), isFalse);
      expect(await channel.notifications().toList(), isEmpty);

      // Opening settings is a no-op rather than a crash.
      await expectLater(channel.openPermissionSettings(), completes);
    });

    test('manual entry is untouched', () async {
      // Nothing about capture being off changes the ledger.
      const channel = UnavailableCaptureChannel();
      expect(await channel.isPermissionGranted(), isFalse);

      expect(await dao.watchPending().first, isEmpty);
      expect(await dao.watchSamples().first, isEmpty);
      expect(await db.select(db.accounts).get(), isEmpty);
    });
  });

  group('permission revoked mid-session', () {
    test('the stream ending leaves existing data intact and usable', () async {
      // A user can revoke access from system settings at any time. Whatever
      // was already captured stays reviewable; nothing new arrives.
      await handle(bankAlert());
      expect(await dao.watchPending().first, hasLength(1));

      final revoked = _RevocableChannel();
      final seen = <CapturedNotification>[];
      final sub = revoked.notifications().listen(seen.add);

      revoked.revoke();
      await pumpEventQueue();
      await sub.cancel();

      expect(seen, isEmpty);
      expect(await revoked.isPermissionGranted(), isFalse);
      expect(
        await dao.watchPending().first,
        hasLength(1),
        reason: 'already-captured suggestions must survive revocation',
      );
    });

    test('captured data can be cleared on revocation', () async {
      // Holding on to captured text after being told to stop would be
      // indefensible, so there is one call that clears all of it.
      await handle(bankAlert());
      await dao.addSample(id: 's1', notification: bankAlert());

      await dao.deleteAllCaptured();

      expect(await dao.watchPending().first, isEmpty);
      expect(await dao.watchSamples().first, isEmpty);
    });
  });
}

/// A channel whose permission can be taken away while it is running.
class _RevocableChannel implements CaptureChannel {
  final _controller = StreamController<CapturedNotification>.broadcast();
  bool _granted = true;

  void revoke() {
    _granted = false;
    _controller.close();
  }

  @override
  Future<bool> isPermissionGranted() async => _granted;

  @override
  Future<bool> isListenerConnected() async => _granted;

  @override
  Future<void> openPermissionSettings() async {}

  @override
  Stream<CapturedNotification> notifications() => _controller.stream;
}
