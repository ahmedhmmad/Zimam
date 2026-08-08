import 'package:flutter/material.dart';

/// Colours that carry *meaning* rather than brand.
///
/// The Material 3 scheme handles chrome. These four are the only colours the
/// app is allowed to use to say something about a number: it went up, it went
/// down, it needs your attention, or it is merely context. Keeping them out of
/// [ColorScheme] makes it obvious at the call site that a colour choice is a
/// semantic claim about the data.
///
/// All values are checked to clear 4.5:1 against their mode's surface.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.gain,
    required this.loss,
    required this.alert,
    required this.neutral,
    required this.gainContainer,
    required this.lossContainer,
    required this.alertContainer,
  });

  /// Value moved in the user's favour.
  final Color gain;

  /// Value moved against the user.
  final Color loss;

  /// Something needs review (dormant account, stale rate, concentration).
  final Color alert;

  /// Deliberately unremarkable: for figures that are neither good nor bad.
  final Color neutral;

  /// Low-emphasis backgrounds for the above, for chips and card tints.
  final Color gainContainer;
  final Color lossContainer;
  final Color alertContainer;

  static const AppSemanticColors light = AppSemanticColors(
    gain: Color(0xFF0F6B45),
    loss: Color(0xFFA4232B),
    alert: Color(0xFF7A5300),
    neutral: Color(0xFF4A5654),
    gainContainer: Color(0xFFDCF2E6),
    lossContainer: Color(0xFFFBE2E2),
    alertContainer: Color(0xFFF8EBCE),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    gain: Color(0xFF6FD9A4),
    loss: Color(0xFFFFB3AC),
    alert: Color(0xFFE9C170),
    neutral: Color(0xFFB6C2BF),
    gainContainer: Color(0xFF14372A),
    lossContainer: Color(0xFF41221F),
    alertContainer: Color(0xFF3A3018),
  );

  @override
  AppSemanticColors copyWith({
    Color? gain,
    Color? loss,
    Color? alert,
    Color? neutral,
    Color? gainContainer,
    Color? lossContainer,
    Color? alertContainer,
  }) {
    return AppSemanticColors(
      gain: gain ?? this.gain,
      loss: loss ?? this.loss,
      alert: alert ?? this.alert,
      neutral: neutral ?? this.neutral,
      gainContainer: gainContainer ?? this.gainContainer,
      lossContainer: lossContainer ?? this.lossContainer,
      alertContainer: alertContainer ?? this.alertContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      gain: Color.lerp(gain, other.gain, t)!,
      loss: Color.lerp(loss, other.loss, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      gainContainer: Color.lerp(gainContainer, other.gainContainer, t)!,
      lossContainer: Color.lerp(lossContainer, other.lossContainer, t)!,
      alertContainer: Color.lerp(alertContainer, other.alertContainer, t)!,
    );
  }
}

extension AppSemanticColorsX on BuildContext {
  /// `context.semantic.gain` — shorter than reaching through [Theme] every time.
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
