import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/settings_dao.dart';
import 'package:zimam/core/settings/app_preferences.dart';

/// Language and theme used to live in memory, so choosing Arabic lasted until
/// the app was closed and every cold start reverted to English. These assert
/// they now survive a restart.
void main() {
  late AppDatabase db;
  late SettingsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SettingsDao(db);
  });

  tearDown(() async => db.close());

  group('language', () {
    test('is unset to begin with, meaning follow the device', () async {
      expect(await dao.localeCode(), isNull);
    });

    test('a chosen language survives a fresh accessor', () async {
      await dao.setLocaleCode('ar');
      // A new DAO over the same database is what a relaunch looks like.
      expect(await SettingsDao(db).localeCode(), 'ar');
    });

    test('switching back to the device language clears it', () async {
      await dao.setLocaleCode('ar');
      await dao.setLocaleCode(null);
      expect(await dao.localeCode(), isNull);
    });

    test('stores a bare language code, not a full tag', () async {
      // A stored `ar-EG` would fail to match the `ar` delegate and drop the
      // user silently back to English — the original bug in another form.
      await dao.setLocaleCode(const Locale('ar').languageCode);
      expect(await dao.localeCode(), 'ar');
      expect(await dao.localeCode(), isNot(contains('-')));
    });

    test('watch reflects a change', () async {
      final seen = <String?>[];
      final sub = dao.watchLocaleCode().listen(seen.add);

      await pumpEventQueue();
      expect(seen.first, isNull);

      await dao.setLocaleCode('ar');
      await pumpEventQueue();
      await sub.cancel();

      expect(seen.last, 'ar');
    });
  });

  group('theme mode', () {
    test('defaults to following the device', () async {
      expect(await dao.themeModeName(), 'system');
      expect(themeModeFromName(await dao.themeModeName()), ThemeMode.system);
    });

    test('a chosen mode survives a fresh accessor', () async {
      await dao.setThemeModeName(ThemeMode.dark.name);
      expect(await SettingsDao(db).themeModeName(), 'dark');
      expect(
        themeModeFromName(await SettingsDao(db).themeModeName()),
        ThemeMode.dark,
      );
    });

    test('every mode round trips through its name', () async {
      for (final mode in ThemeMode.values) {
        await dao.setThemeModeName(mode.name);
        expect(themeModeFromName(await dao.themeModeName()), mode);
      }
    });

    test('an unreadable value falls back rather than crashing', () async {
      await dao.setThemeModeName('neon');
      expect(themeModeFromName(await dao.themeModeName()), ThemeMode.system);
    });
  });

  group('independence', () {
    test('language and theme do not overwrite one another', () async {
      await dao.setLocaleCode('ar');
      await dao.setThemeModeName('dark');

      expect(await dao.localeCode(), 'ar');
      expect(await dao.themeModeName(), 'dark');
    });

    test('neither disturbs the home currency', () async {
      await dao.setLocaleCode('ar');
      await dao.setThemeModeName('dark');
      expect(await dao.homeCurrency(), isNull);
    });
  });
}
