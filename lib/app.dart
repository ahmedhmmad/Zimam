import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/settings/app_preferences.dart';
import 'core/theme/app_theme.dart';
import 'l10n/l10n.dart';

class ZimamApp extends ConsumerWidget {
  const ZimamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      // The launcher/recents label comes from the Android manifest; this title
      // is resolved per locale for the task switcher.
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,

      routerConfig: router,

      // Dynamic colour is not wired up yet — see docs/ARCHITECTURE.md. Both
      // modes are built from the fallback seed today.
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      locale: locale,
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,

      // Text scaling is honoured up to 200%; beyond that layouts stop being
      // usable on a phone, so the ceiling is clamped rather than left open.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 2,
        child: child!,
      ),
    );
  }
}
