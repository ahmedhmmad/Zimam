import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/database/settings_dao.dart';
import 'core/providers.dart';
import 'core/settings/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only: every screen is a single column of figures, and locking the
  // orientation keeps the hero-number layout predictable.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Language and theme are read before the first frame rather than streamed in
  // after it. Loading them asynchronously would render one frame in the
  // default language and then swap — a visible flash on every cold start that
  // reads as the setting having failed to save.
  final database = AppDatabase();
  final settings = SettingsDao(database);
  final localeCode = await settings.localeCode();
  final themeName = await settings.themeModeName();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        initialLocaleProvider.overrideWithValue(
          localeCode == null ? null : Locale(localeCode),
        ),
        initialThemeModeProvider.overrideWithValue(
          themeModeFromName(themeName),
        ),
      ],
      child: const ZimamApp(),
    ),
  );
}
