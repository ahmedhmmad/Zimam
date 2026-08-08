import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Presentation preferences: theme mode and language.
///
/// These are held in memory only for now. Phase 1 introduces the `settings`
/// table and these notifiers will read and write through it; the widget-facing
/// API here is intended not to change when that happens.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

/// `null` means "follow the device language".
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void set(Locale? locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);
