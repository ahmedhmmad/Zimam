import 'package:flutter/material.dart';

/// The colour schemes, transcribed from `docs/DESIGN.md`.
///
/// The design system supplies an explicit palette, so nothing here is generated
/// from a seed. Changing a colour means changing `docs/DESIGN.md` first and
/// then this file — never the other way round.
abstract final class AppColorSchemes {
  /// Retained only so a `ColorScheme.fromSeed` fallback stays possible if the
  /// palette is ever dropped. Nothing renders from it today.
  static const Color seed = Color(0xFF1B5E63);

  /// Light palette, verbatim from the `colors:` block of the design system.
  ///
  /// One deliberate deviation: the design system's `surface`/`background` token
  /// is `#f8fafa`, but the prose specifies a `#f2f4f4` canvas with `#ffffff`
  /// cards. Since the system forbids shadows and separates surfaces by fill
  /// contrast alone, `#f8fafa` behind a white card gives only 1.05:1 — cards
  /// would effectively vanish. `#f2f4f4` gives 1.10:1, which matches the dark
  /// mode's own card separation (1.11:1). The prose value wins; the token is
  /// kept below as [_lightSurfaceToken] so the discrepancy stays visible.
  static const Color _lightSurfaceToken = Color(0xFFF8FAFA);

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    primary: Color(0xFF00464A),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF1B5E63),
    onPrimaryContainer: Color(0xFF97D5DB),

    // Secondary carries "gain" in this system — see AppSemanticColors.
    secondary: Color(0xFF116C46),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFA1F4C3),
    onSecondaryContainer: Color(0xFF1B724B),

    // Tertiary carries "loss".
    tertiary: Color(0xFF810316),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFA3222A),
    onTertiaryContainer: Color(0xFFFFB9B5),

    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),

    surface: Color(0xFFF2F4F4),
    onSurface: Color(0xFF191C1D),
    onSurfaceVariant: Color(0xFF3F4849),
    surfaceDim: Color(0xFFD8DADA),
    surfaceBright: _lightSurfaceToken,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F4F4),
    surfaceContainer: Color(0xFFECEEEE),
    surfaceContainerHigh: Color(0xFFE6E8E8),
    surfaceContainerHighest: Color(0xFFE1E3E3),

    outline: Color(0xFF6F7979),
    outlineVariant: Color(0xFFBFC8C9),
    inverseSurface: Color(0xFF2E3131),
    onInverseSurface: Color(0xFFEFF1F1),
    inversePrimary: Color(0xFF93D1D6),
    surfaceTint: Color(0xFF27676C),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  /// Dark palette.
  ///
  /// DERIVED, NOT SPECIFIED. The design system defines only two dark values in
  /// prose — a `#121414` canvas and `#1c1f1f` cards. The rest is reconstructed
  /// from the `*-fixed` tokens, which expose the underlying tonal palette:
  /// `primary-fixed-dim` is tone 80, `on-primary-fixed-variant` is tone 30, and
  /// so on. Material's dark mapping then falls out — tone 80 becomes `primary`,
  /// tone 30 becomes `primaryContainer`, tone 90 becomes `onPrimaryContainer`.
  ///
  /// Have these confirmed against a real dark export before shipping.
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    primary: Color(0xFF93D1D6), // = inverse-primary / primary-fixed-dim
    onPrimary: Color(0xFF00363A),
    primaryContainer: Color(0xFF004F54), // = on-primary-fixed-variant
    onPrimaryContainer: Color(0xFFAFEDF3), // = primary-fixed

    secondary: Color(0xFF85D7A9), // = secondary-fixed-dim
    onSecondary: Color(0xFF003920),
    secondaryContainer: Color(0xFF005233), // = on-secondary-fixed-variant
    onSecondaryContainer: Color(0xFFA1F4C3), // = secondary-fixed

    tertiary: Color(0xFFFFB3B0), // = tertiary-fixed-dim
    onTertiary: Color(0xFF68000F),
    tertiaryContainer: Color(0xFF8E101E), // = on-tertiary-fixed-variant
    onTertiaryContainer: Color(0xFFFFDAD8), // = tertiary-fixed

    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),

    surface: Color(0xFF121414), // prose: deep charcoal canvas
    onSurface: Color(0xFFE1E3E3),
    onSurfaceVariant: Color(0xFFBFC8C9),
    surfaceDim: Color(0xFF121414),
    surfaceBright: Color(0xFF383A3A),
    surfaceContainerLowest: Color(0xFF0D0F0F),
    surfaceContainerLow: Color(0xFF1A1D1D),
    surfaceContainer: Color(0xFF1C1F1F), // prose: card elevation surface
    surfaceContainerHigh: Color(0xFF272A2A),
    surfaceContainerHighest: Color(0xFF313434),

    outline: Color(0xFF899393),
    outlineVariant: Color(0xFF3F4849),
    inverseSurface: Color(0xFFE1E3E3),
    onInverseSurface: Color(0xFF2E3131),
    inversePrimary: Color(0xFF00686E),
    surfaceTint: Color(0xFF93D1D6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );
}
