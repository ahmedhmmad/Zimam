/// The 8dp spacing grid. Every gap, pad and inset in the app comes from here so
/// that rhythm stays consistent across screens and survives text scaling.
abstract final class AppSpacing {
  /// 4dp — only for optical nudges inside a component, never between components.
  static const double xxs = 4;

  /// 8dp — tight pairs (label above value).
  static const double xs = 8;

  /// 16dp — the default gap and the standard card padding.
  static const double sm = 16;

  /// 24dp — screen horizontal padding, gap between card groups.
  static const double md = 24;

  /// 32dp — separation between major sections.
  static const double lg = 32;

  /// 48dp — breathing room around a hero figure.
  static const double xl = 48;
}

/// Corner radii. Soft, not pill-shaped: this is an instrument, not a toy.
abstract final class AppRadius {
  static const double card = 16;
  static const double control = 12;
  static const double chip = 8;
}

/// Minimum interactive size, per the accessibility rules.
const double kMinTouchTarget = 48;
