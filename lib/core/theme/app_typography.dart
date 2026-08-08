import 'package:flutter/material.dart';

/// Type rules for the app.
///
/// The only unusual thing here is [tabularFigures]. Currency amounts update in
/// place (a refreshed FX rate, a new snapshot); with proportional digits the
/// number visibly jitters as digit widths change. Every amount must therefore
/// be rendered with a tabular-figure style from this class, never with a raw
/// [TextTheme] entry.
abstract final class AppTypography {
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
    // Slashed zero is not requested; lining figures are the default in Roboto.
  ];

  /// Applies tabular figures and slightly tighter tracking to any style.
  /// Weight is inherited from the source style so the type hierarchy is decided
  /// in one place ([textTheme]) rather than here.
  static TextStyle asAmount(TextStyle style) {
    return style.copyWith(fontFeatures: tabularFigures, letterSpacing: -0.5);
  }

  /// The single dominant figure on a screen (net worth, debt balance).
  static TextStyle amountHero(BuildContext context) =>
      asAmount(Theme.of(context).textTheme.displaySmall!);

  /// A figure that heads a card or a row group.
  static TextStyle amountTitle(BuildContext context) =>
      asAmount(Theme.of(context).textTheme.titleLarge!);

  /// A figure inside a list row.
  static TextStyle amountBody(BuildContext context) =>
      asAmount(Theme.of(context).textTheme.bodyLarge!);

  /// A secondary figure, e.g. the home-currency equivalent under a native one.
  static TextStyle amountSecondary(BuildContext context) {
    final theme = Theme.of(context);
    return asAmount(theme.textTheme.bodyMedium!)
        .copyWith(color: theme.colorScheme.onSurfaceVariant);
  }

  /// Trims the Material default ramp to the sizes this app actually uses, and
  /// firms up the weight contrast so hierarchy reads without extra colour.
  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w400,
        height: 1.15,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(letterSpacing: 0.1),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
    );
  }
}
