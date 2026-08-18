import 'package:flutter/services.dart';

import '../domain/captured_notification.dart';

/// The Dart half of the notification bridge.
///
/// An interface as well as an implementation, so every screen and test above
/// it can run without a device — and so the one place that talks to Android
/// is small enough to audit in a single sitting.
abstract interface class CaptureChannel {
  /// Whether the user has granted notification access, read from the system
  /// rather than remembered.
  Future<bool> isPermissionGranted();

  /// Whether the OS currently has the service bound. Granted but unbound
  /// happens after an app update or a force-stop.
  Future<bool> isListenerConnected();

  /// Opens Android's notification-access screen.
  ///
  /// The app cannot grant this itself and does not try. The user makes the
  /// choice in Android's own UI, having already been shown what the app will
  /// read and what it will do with it.
  Future<void> openPermissionSettings();

  /// Notifications as they arrive. Empty until permission is granted.
  Stream<CapturedNotification> notifications();
}

final class PlatformCaptureChannel implements CaptureChannel {
  const PlatformCaptureChannel();

  static const MethodChannel _methods = MethodChannel('com.zimam.app/capture');
  static const EventChannel _events = EventChannel(
    'com.zimam.app/capture/events',
  );

  @override
  Future<bool> isPermissionGranted() async {
    try {
      return await _methods.invokeMethod<bool>('isPermissionGranted') ?? false;
    } on PlatformException {
      // A missing implementation means a platform that has no such concept.
      // Reporting "not granted" degrades to manual entry, which is correct.
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> isListenerConnected() async {
    try {
      return await _methods.invokeMethod<bool>('isListenerConnected') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> openPermissionSettings() async {
    try {
      await _methods.invokeMethod<void>('openPermissionSettings');
    } on PlatformException {
      // Nothing useful to do: the user is already looking at our screen and
      // can reach the setting themselves.
    } on MissingPluginException {
      // Same.
    }
  }

  @override
  Stream<CapturedNotification> notifications() =>
      _events.receiveBroadcastStream().map(_decode).where((n) => n != null).cast();

  static CapturedNotification? _decode(Object? event) {
    if (event is! Map) return null;
    final package = event['package'];
    if (package is! String || package.isEmpty) return null;

    final posted = event['postedAt'];
    return CapturedNotification(
      packageName: package,
      title: event['title'] as String? ?? '',
      body: event['body'] as String? ?? '',
      postedAt: posted is int
          ? DateTime.fromMillisecondsSinceEpoch(posted, isUtc: true)
          : DateTime.now().toUtc(),
    );
  }
}

/// A channel that is never granted and never emits.
///
/// The default in tests and on any platform without the service, so the whole
/// app above this line behaves exactly as it does for a user who declined —
/// which is the path that has to work.
final class UnavailableCaptureChannel implements CaptureChannel {
  const UnavailableCaptureChannel();

  @override
  Future<bool> isPermissionGranted() async => false;

  @override
  Future<bool> isListenerConnected() async => false;

  @override
  Future<void> openPermissionSettings() async {}

  @override
  Stream<CapturedNotification> notifications() =>
      const Stream<CapturedNotification>.empty();
}
