/// Spacing and shape tokens, transcribed from `docs/DESIGN.md`.
///
/// The design system's `spacing:` block gives base 8, gutter 16,
/// screen-padding 24, section-gap 32 and touch-target-min 48. The names below
/// are the app's own; the values are the design system's.
abstract final class AppSpacing {
  /// 4dp — only for optical nudges inside a component, never between them.
  static const double xxs = 4;

  /// 8dp — the grid base. Tight pairs, such as a label above its value.
  static const double xs = 8;

  /// 16dp — design system `gutter`, and the standard internal card padding.
  static const double sm = 16;

  /// 24dp — design system `screen-padding`. Mandatory on every screen edge.
  static const double md = 24;

  /// 32dp — design system `section-gap`. Between cards and major sections.
  static const double lg = 32;

  /// 48dp — breathing room around a hero figure.
  static const double xl = 48;
}

/// Corner radii.
///
/// The design system is explicit and slightly unusual here: buttons take the
/// same 16px radius as cards rather than Material's pill shape, and only inputs
/// step down to 12px. Chips stay at 16px.
abstract final class AppRadius {
  /// 16px — cards, containers, buttons and chips.
  static const double card = 16;

  /// 16px, aliased for call sites that read better as a control radius.
  static const double control = card;

  /// 12px — inputs only, to differentiate them from structural containers.
  static const double input = 12;
}

/// Design system `touch-target-min`: every interactive element reserves at
/// least this, even when its visual asset is smaller.
const double kMinTouchTarget = 48;

/// Design system: icons sit in a 24dp box with a 1.5–2px stroke, never
/// hairline, so they hold their weight next to the monospaced figures.
const double kIconSize = 24;
