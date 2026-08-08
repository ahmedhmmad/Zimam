import 'package:flutter/material.dart';

import 'app_semantic_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData].
///
/// Aesthetic brief: a calm financial instrument. Surfaces are quiet, elevation
/// is low, and the accent colour is reserved for meaning. Anything decorative
/// is deliberately absent.
abstract final class AppTheme {
  /// Fallback seed used when the platform offers no dynamic colour, and the
  /// basis of every screenshot and store asset. A muted deep teal: legible in
  /// both modes, and not the blue/green of a spending app.
  static const Color fallbackSeed = Color(0xFF1B5E63);

  static ThemeData light({ColorScheme? dynamicScheme}) =>
      _build(_scheme(dynamicScheme, Brightness.light), AppSemanticColors.light);

  static ThemeData dark({ColorScheme? dynamicScheme}) =>
      _build(_scheme(dynamicScheme, Brightness.dark), AppSemanticColors.dark);

  static ColorScheme _scheme(ColorScheme? dynamicScheme, Brightness brightness) {
    if (dynamicScheme != null && dynamicScheme.brightness == brightness) {
      return dynamicScheme;
    }
    return ColorScheme.fromSeed(
      seedColor: fallbackSeed,
      brightness: brightness,
    );
  }

  static ThemeData _build(ColorScheme scheme, AppSemanticColors semantic) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      extensions: [semantic],
      textTheme: AppTypography.textTheme(base.textTheme),
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Data surfaces: flat fill, no gradient, no shadow. Separation comes from
      // the fill difference against the scaffold, not from elevation.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),

      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.xs,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        // Labels always visible: three destinations, no reason to hide them,
        // and always-on labels survive 200% text scale better than a tooltip.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, kMinTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, kMinTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
          borderSide: BorderSide.none,
        ),
      ),

      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant,
      ),

      // Short and purposeful; no bounce.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
