import 'package:flutter/material.dart';

/// Colours that carry *meaning* rather than brand.
///
/// The design system names four semantic roles — Primary, Gain, Loss and
/// Attention — but its token list only carries the first three, mapped onto
/// Material's slots: `secondary` is Gain and `tertiary` is Loss. This class
/// gives those roles their real names so a call site reads `context.semantic
/// .gain` instead of the meaningless `colorScheme.secondary`, and so the
/// mapping lives in exactly one place if the design system moves it.
///
/// `error` stays separate from `loss`: a failed save is not a currency moving
/// against you, and they must not look alike.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.gain,
    required this.loss,
    required this.alert,
    required this.neutral,
    required this.gainContainer,
    required this.onGainContainer,
    required this.lossContainer,
    required this.onLossContainer,
    required this.alertContainer,
    required this.onAlertContainer,
  });

  /// Value moved in the user's favour. Design system `secondary`.
  final Color gain;

  /// Value moved against the user. Design system `tertiary`.
  final Color loss;

  /// Needs review — a dormant account, a stale FX rate, a concentration
  /// warning. See the note on [_attentionLight] below: this one is ours.
  final Color alert;

  /// Deliberately unremarkable, for figures that are neither good nor bad.
  final Color neutral;

  /// Low-emphasis fills for chips and card tints, with their content colours.
  final Color gainContainer;
  final Color onGainContainer;
  final Color lossContainer;
  final Color onLossContainer;
  final Color alertContainer;
  final Color onAlertContainer;

  /// The Attention role, now supplied by the design system's palette specimen.
  ///
  /// `docs/DESIGN.md` named Attention as a semantic role but shipped no token,
  /// which is why the dormancy insight was rendering loss-red — reporting "not
  /// updated in 94 days" as a financial loss. The light values below are
  /// transcribed from the specimen and independently verified: 6.85:1 on white,
  /// 6.21:1 on the canvas, 11.63:1 for content on its container.
  ///
  /// Dark mode remains ours — the specimen is light-only, like the rest of the
  /// design system. Verified at 10.85:1 on the dark canvas and 7.63:1 for
  /// content on its container.
  static const Color _attentionLight = Color(0xFF7A5300);
  static const Color _attentionDark = Color(0xFFE9C170);

  static const AppSemanticColors light = AppSemanticColors(
    gain: Color(0xFF116C46), // secondary          6.45:1 on white
    loss: Color(0xFF810316), // tertiary          10.73:1 on white
    alert: _attentionLight,
    neutral: Color(0xFF3F4849), // on-surface-variant  8.97:1
    gainContainer: Color(0xFFA1F4C3),
    onGainContainer: Color(0xFF1B724B),
    // NOTE: the design system's tertiary-container is a *dark* fill (#a3222a)
    // with light content, unlike the soft secondary-container. A loss chip
    // therefore renders far louder than a gain chip in light mode. Transcribed
    // faithfully rather than silently corrected — worth raising upstream.
    lossContainer: Color(0xFFA3222A),
    onLossContainer: Color(0xFFFFB9B5),
    alertContainer: Color(0xFFFFEFD1),
    onAlertContainer: Color(0xFF422C00),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    gain: Color(0xFF85D7A9),
    loss: Color(0xFFFFB3B0),
    alert: _attentionDark,
    neutral: Color(0xFFBFC8C9),
    gainContainer: Color(0xFF005233),
    onGainContainer: Color(0xFFA1F4C3),
    lossContainer: Color(0xFF8E101E),
    onLossContainer: Color(0xFFFFDAD8),
    alertContainer: Color(0xFF3A3018),
    onAlertContainer: _attentionDark,
  );

  @override
  AppSemanticColors copyWith({
    Color? gain,
    Color? loss,
    Color? alert,
    Color? neutral,
    Color? gainContainer,
    Color? onGainContainer,
    Color? lossContainer,
    Color? onLossContainer,
    Color? alertContainer,
    Color? onAlertContainer,
  }) {
    return AppSemanticColors(
      gain: gain ?? this.gain,
      loss: loss ?? this.loss,
      alert: alert ?? this.alert,
      neutral: neutral ?? this.neutral,
      gainContainer: gainContainer ?? this.gainContainer,
      onGainContainer: onGainContainer ?? this.onGainContainer,
      lossContainer: lossContainer ?? this.lossContainer,
      onLossContainer: onLossContainer ?? this.onLossContainer,
      alertContainer: alertContainer ?? this.alertContainer,
      onAlertContainer: onAlertContainer ?? this.onAlertContainer,
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
      onGainContainer: Color.lerp(onGainContainer, other.onGainContainer, t)!,
      lossContainer: Color.lerp(lossContainer, other.lossContainer, t)!,
      onLossContainer: Color.lerp(onLossContainer, other.onLossContainer, t)!,
      alertContainer: Color.lerp(alertContainer, other.alertContainer, t)!,
      onAlertContainer: Color.lerp(
        onAlertContainer,
        other.onAlertContainer,
        t,
      )!,
    );
  }
}

extension AppSemanticColorsX on BuildContext {
  /// `context.semantic.gain` — shorter than reaching through [Theme] every time.
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
