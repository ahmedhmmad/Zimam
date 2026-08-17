import 'package:flutter/material.dart';

/// Type, transcribed from the `typography:` block of `docs/DESIGN.md`.
///
/// Two families, with a strict division of labour:
///
/// * **IBM Plex Sans** for all prose and labels.
/// * **JetBrains Mono** for every currency amount, percentage and date. This is
///   what makes figures align vertically down a list and stops digits shifting
///   width when a value updates.
///
/// The design system caps a screen at three distinct sizes and exactly one
/// hero number, so the ramp below is deliberately short. Anything not listed
/// here is derived by Material and should not appear in a design.
///
/// All three families are bundled under `assets/fonts/` and declared in
/// `pubspec.yaml`. Nothing is fetched at runtime — the app must render
/// correctly on a cold start with no network.
abstract final class AppTypography {
  static const String sans = 'IBM Plex Sans';
  static const String mono = 'JetBrains Mono';

  /// Arabic UI text. A separate typeface from the Latin family — IBM Plex Sans
  /// contains no Arabic glyphs whatsoever.
  static const String sansArabic = 'IBM Plex Sans Arabic';

  /// Applied to every style so a single [TextStyle] renders both scripts.
  ///
  /// Without this, Arabic text asking for `IBM Plex Sans` finds no matching
  /// glyphs and silently drops to whatever the platform provides — the Arabic
  /// UI would quietly stop using the design system's typeface. The fallback
  /// only engages for codepoints the primary family cannot render, so Latin
  /// text is unaffected. Mono carries it too: the digit-style setting can put
  /// Arabic-Indic numerals in a figure, which JetBrains Mono does not cover.
  static const List<String> _fallback = [sansArabic];

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// `display-hero-mobile` — 32/40, w600. The single dominant figure on a
  /// screen: net worth, a debt balance, a rate.
  ///
  /// The design system also defines a 40/48 `display-hero` for wider layouts.
  /// The app is portrait-only, so the mobile size is the one that ships.
  static const TextStyle displayHero = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: _fallback,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.64, // -0.02em
    fontFeatures: _tabular,
  );

  /// `headline-md` — 20/28, w500. Section and card headings.
  static const TextStyle headlineMd = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: _fallback,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w500,
  );

  /// `body-lg` — 16/24, w400. Default reading size.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: _fallback,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  /// `label-mono` — JetBrains Mono 14/20, w500. Figures inside rows, dates,
  /// percentages, and any label that sits beside a number.
  static const TextStyle labelMono = TextStyle(
    fontFamily: mono,
    fontFamilyFallback: _fallback,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );

  /// Turns any style into a figure style: monospaced, tabular, same size.
  /// Use this rather than hand-setting `fontFamily` at a call site.
  static TextStyle asAmount(TextStyle style) =>
      style.copyWith(
        fontFamily: mono,
        fontFamilyFallback: _fallback,
        fontFeatures: _tabular,
      );

  /// UI label — sans, 14/20. Navigation labels, chips, field labels.
  ///
  /// Distinct from [labelMono], which is the *figure* style at the same size.
  /// A nav destination is prose and must not be monospaced.
  static const TextStyle labelSans = TextStyle(
    fontFamily: sans,
    fontFamilyFallback: _fallback,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );

  /// The one hero figure on a screen. Sans with tabular figures, per the
  /// design system's `display-hero`.
  static TextStyle amountHero(BuildContext context) =>
      Theme.of(context).textTheme.displaySmall!;

  /// A figure heading a card or row group.
  static TextStyle amountTitle(BuildContext context) =>
      asAmount(Theme.of(context).textTheme.titleLarge!);

  /// A figure inside a list row — the design system's `label-mono`.
  static TextStyle amountBody(BuildContext context) =>
      labelMono.copyWith(color: Theme.of(context).colorScheme.onSurface);

  /// A secondary figure — the home-currency equivalent under a native amount.
  static TextStyle amountSecondary(BuildContext context) => labelMono.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  /// Maps the design ramp onto the Material slots the app actually uses.
  ///
  /// Two rules here, both learned the hard way.
  ///
  /// **Merge, never `copyWith` a bare [TextStyle].** The styles above carry no
  /// colour, so assigning one wholesale discards the colour Material derived
  /// from the scheme and the text renders in whatever the ancestor default
  /// happens to be — near-invisible on a light canvas. `merge` layers the
  /// family, size and weight over the base while its colour survives.
  ///
  /// **No monospace in these slots.** Every slot here is IBM Plex Sans.
  /// JetBrains Mono is reached only through [asAmount] and the `amount*`
  /// helpers, so a widget cannot become monospaced just by using a standard
  /// text style — which is exactly how the source designs ended up with
  /// monospaced prose.
  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.merge(displayHero),
      headlineSmall: base.headlineSmall?.merge(headlineMd),
      titleLarge: base.titleLarge?.merge(headlineMd),
      titleMedium: base.titleMedium?.merge(
        bodyLg.copyWith(fontWeight: FontWeight.w500),
      ),
      bodyLarge: base.bodyLarge?.merge(bodyLg),
      bodyMedium: base.bodyMedium?.merge(bodyLg),
      labelLarge: base.labelLarge?.merge(labelSans),
      labelMedium: base.labelMedium?.merge(
        labelSans.copyWith(fontSize: 12, height: 16 / 12),
      ),
    );
  }
}
