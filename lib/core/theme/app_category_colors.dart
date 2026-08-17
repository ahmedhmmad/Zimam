import 'package:flutter/material.dart';

/// Colours for *categories* — currencies, accounts, institutions.
///
/// Deliberately separate from [AppSemanticColors], and that separation is the
/// whole point. The design system's rule is that colour means data state, so
/// green means gain and red means loss and nothing else may borrow them. The
/// source designs broke this: the currency composition bar assigned
/// primary/secondary/tertiary to AED/JOD/USD by list order, which painted
/// dollar holdings in the loss red and dinar holdings in the gain green for
/// reasons unconnected to the data. A glance at the bar read as "the red one
/// is losing money".
///
/// So categories get their own ramp, and it is monochrome on purpose: tonal
/// steps of the brand teal, distinguished by lightness alone. Nothing in it
/// can be mistaken for a gain or a loss, and lightness survives both
/// deuteranopia and protanopia intact.
///
/// **Five steps, not six.** Requiring every step to clear 3:1 against its
/// surface caps luminance at 0.283; the darkest usable teal sits at 0.020.
/// That band spans 3:1 to 15.4:1, so six single-hue steps could be at most
/// 1.39:1 apart from each other — indistinguishable in practice. Five is the
/// honest maximum, and it is enough: holdings beyond the top five belong in
/// [other] anyway, and the legend carries the labels.
@immutable
class AppCategoryColors extends ThemeExtension<AppCategoryColors> {
  const AppCategoryColors({required this.steps, required this.other});

  /// Ordered darkest to lightest in light mode, and the reverse in dark mode,
  /// so the ramp always runs from most to least emphasis against its surface.
  /// Assign by descending share: the largest holding takes `steps.first`.
  final List<Color> steps;

  /// The aggregated tail of small holdings. Neutral grey, so it reads as
  /// "everything else" rather than as another category.
  final Color other;

  /// Colour for the category at [index], by descending share.
  ///
  /// Indexes past the ramp fall through to [other] rather than wrapping —
  /// wrapping would give two different currencies the same colour in one bar,
  /// which is worse than honestly lumping the tail together.
  Color forIndex(int index) =>
      index >= 0 && index < steps.length ? steps[index] : other;

  /// Light mode. Verified against the white card the bar sits on:
  /// 11.55, 7.99, 5.61, 3.89, 3.05 and 3.08 to 1.
  static const AppCategoryColors light = AppCategoryColors(
    steps: [
      Color(0xFF123F43),
      Color(0xFF19595D),
      Color(0xFF217278),
      Color(0xFF298E95),
      Color(0xFF2FA2AB),
    ],
    other: Color(0xFF8E9494),
  );

  /// Dark mode, targeted at the `#1c1f1f` card rather than the canvas, since
  /// that is what the bar is drawn on: 3.08, 4.83, 7.32, 10.60, 14.50 and
  /// 3.10 to 1. Order is inverted relative to light mode.
  static const AppCategoryColors dark = AppCategoryColors(
    steps: [
      Color(0xFF22757B),
      Color(0xFF2C98A0),
      Color(0xFF36BDC7),
      Color(0xFF90DBE1),
      Color(0xFFDDF4F6),
    ],
    other: Color(0xFF666C6C),
  );

  @override
  AppCategoryColors copyWith({List<Color>? steps, Color? other}) =>
      AppCategoryColors(steps: steps ?? this.steps, other: other ?? this.other);

  @override
  AppCategoryColors lerp(ThemeExtension<AppCategoryColors>? other, double t) {
    if (other is! AppCategoryColors) return this;
    return AppCategoryColors(
      steps: [
        for (var i = 0; i < steps.length; i++)
          Color.lerp(steps[i], other.steps[i], t)!,
      ],
      other: Color.lerp(this.other, other.other, t)!,
    );
  }
}

extension AppCategoryColorsX on BuildContext {
  /// `context.categories.forIndex(0)` — the largest holding's colour.
  AppCategoryColors get categories =>
      Theme.of(this).extension<AppCategoryColors>()!;
}
