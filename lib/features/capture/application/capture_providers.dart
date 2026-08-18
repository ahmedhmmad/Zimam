import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/capture_channel.dart';
import '../data/capture_dao.dart';
import '../data/rule_pack_repository.dart';
import '../domain/notification_parser.dart';
import '../domain/parser_rule.dart';

/// The platform bridge. Overridden with [UnavailableCaptureChannel] in tests,
/// which is also what every non-Android platform gets.
final captureChannelProvider = Provider<CaptureChannel>(
  (ref) => const PlatformCaptureChannel(),
);

final captureDaoProvider = Provider<CaptureDao>(
  (ref) => CaptureDao(ref.watch(databaseProvider)),
);

final rulePackRepositoryProvider = Provider<RulePackRepository>((ref) {
  final repo = RulePackRepository();
  ref.onDispose(repo.close);
  return repo;
});

/// The rules in force.
///
/// The bundled pack loads first so parsing works immediately and offline; an
/// update is then fetched in the background and only adopted if it claims a
/// higher version. A failed fetch is not an error — it is Tuesday.
final rulePackProvider = FutureProvider<ParserRulePack>((ref) async {
  final repo = ref.watch(rulePackRepositoryProvider);
  final bundled = await repo.loadBundled();

  final update = await repo.fetchUpdate(currentVersion: bundled.version);
  return update ?? bundled;
});

final notificationParserProvider = Provider<NotificationParser>((ref) {
  final pack = ref.watch(rulePackProvider).value ?? ParserRulePack.empty;
  return NotificationParser(pack.rules);
});

/// Whether the user has granted notification access, re-read rather than
/// remembered — it can be revoked from system settings at any time.
final capturePermissionProvider = FutureProvider<bool>(
  (ref) => ref.watch(captureChannelProvider).isPermissionGranted(),
);

/// Granted but unbound, which happens after an app update or a force-stop.
final captureConnectedProvider = FutureProvider<bool>(
  (ref) => ref.watch(captureChannelProvider).isListenerConnected(),
);

final pendingSuggestionsProvider = StreamProvider<List<StoredSuggestion>>(
  (ref) => ref.watch(captureDaoProvider).watchPending(),
);

final unparsedSamplesProvider = StreamProvider(
  (ref) => ref.watch(captureDaoProvider).watchSamples(),
);

/// Consumes the notification stream, parses, and files the result.
///
/// A match becomes a *pending suggestion*; a miss becomes an unparsed sample.
/// Neither touches an account. Keeping this in one place means there is a
/// single answer to "what happens to a notification", which is the question
/// the privacy policy has to answer honestly.
final captureListenerProvider = Provider<StreamSubscription<void>?>((ref) {
  final channel = ref.watch(captureChannelProvider);
  final dao = ref.watch(captureDaoProvider);
  final parser = ref.watch(notificationParserProvider);

  final subscription = channel.notifications().listen((notification) async {
    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    final parsed = parser.parse(notification);

    if (parsed == null) {
      // Not recognised. Kept, capped, and only ever shared one item at a time
      // if the user explicitly chooses to.
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
  });

  ref.onDispose(subscription.cancel);
  return subscription;
});
