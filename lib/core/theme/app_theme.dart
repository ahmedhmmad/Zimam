import 'package:flutter/material.dart';

import 'app_color_schemes.dart';
import 'app_semantic_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the light and dark [ThemeData] from `docs/DESIGN.md`.
///
/// Design brief: "Quiet Precision". Flat surfaces, tonal layering instead of
/// shadows, colour reserved for data state, and one dominant figure per screen.
///
/// The palette is explicit, so this no longer generates anything from a seed.
/// Material You dynamic colour is intentionally *not* supported: a
/// device-derived palette would override the semantic greens and reds that
/// carry meaning here.
abstract final class AppTheme {
  static ThemeData light() =>
      _build(AppColorSchemes.light, AppSemanticColors.light);

  static ThemeData dark() =>
      _build(AppColorSchemes.dark, AppSemanticColors.dark);

  static ThemeData _build(ColorScheme scheme, AppSemanticColors semantic) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = AppTypography.textTheme(base.textTheme);

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
    );

    return base.copyWith(
      extensions: [semantic],
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,

      // Tonal layering, not elevation: pressing a surface changes its fill
      // rather than lifting it. Ink stays, the shadow does not.
      splashFactory: InkSparkle.splashFactory,
      shadowColor: Colors.transparent,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onSurface, size: kIconSize),
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),

      // Cards: flat fill, no border, no shadow. In light mode this is pure
      // white on the #f2f4f4 canvas; in dark mode the lighter charcoal.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.brightness == Brightness.light
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),

      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpacing.xs,
        shape: cardShape,
      ),

      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: kIconSize),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        // Always-on labels: three destinations, and labels survive 200% text
        // scaling better than a tooltip does.
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),

      // Buttons take the card radius, not a pill.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, kMinTouchTarget),
          elevation: 0,
          shape: cardShape,
          textStyle: text.titleMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, kMinTouchTarget),
          shape: cardShape,
          textStyle: text.titleMedium,
        ),
      ),
      // "Secondary buttons are subtle grey fills with Primary Color text. No
      // borders are used." — hence a tonal button rather than an outlined one.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, kMinTouchTarget),
          backgroundColor: scheme.surfaceContainerHigh,
          foregroundColor: scheme.primary,
          side: BorderSide.none,
          shape: cardShape,
          textStyle: text.titleMedium,
        ),
      ),

      // Filled inputs with no bottom line, and a label that never disappears.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
      ),

      chipTheme: ChipThemeData(
        shape: cardShape,
        side: BorderSide.none,
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primary,
        labelStyle: text.labelLarge,
      ),

      // Used *inside* a card to separate rows, rather than splitting content
      // into more cards.
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: scheme.outlineVariant,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
