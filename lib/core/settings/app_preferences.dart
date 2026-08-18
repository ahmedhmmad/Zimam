import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// The values read from storage before the first frame.
///
/// Overridden in `main()` with what was actually loaded. Reading them
/// synchronously up front rather than streaming them in afterwards is
/// deliberate: an async read would render one frame in English and then swap
/// to Arabic, which is a visible flash on every cold start and looks like the
/// setting failed to save.
final initialLocaleProvider = Provider<Locale?>(
  (ref) => throw StateError('initialLocaleProvider must be overridden'),
);

final initialThemeModeProvider = Provider<ThemeMode>(
  (ref) => throw StateError('initialThemeModeProvider must be overridden'),
);

/// Theme mode, persisted to the `settings` table.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  Future<void> set(ThemeMode mode) async {
    // Optimistic: the UI reflects the choice immediately and the write
    // follows. A failed write would at worst lose the preference, never show
    // a control that disagrees with the screen.
    state = mode;
    await ref.read(settingsDaoProvider).setThemeModeName(mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

/// UI language. `null` means "follow the device".
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => ref.watch(initialLocaleProvider);

  Future<void> set(Locale? locale) async {
    state = locale;
    await ref
        .read(settingsDaoProvider)
        .setLocaleCode(locale?.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(
  LocaleController.new,
);

/// Parses a stored theme-mode name, falling back to following the device.
ThemeMode themeModeFromName(String name) => switch (name) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};
