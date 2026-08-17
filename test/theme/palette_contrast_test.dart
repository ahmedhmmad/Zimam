import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/theme/app_category_colors.dart';
import 'package:zimam/core/theme/app_color_schemes.dart';
import 'package:zimam/core/theme/app_semantic_colors.dart';

/// Guards the accessibility floor on the palette.
///
/// This exists because it was needed. The categorical ramp the design tool
/// produced looked plausible and was described as meeting a 3:1 requirement,
/// but three of its seven steps measured between 1.40:1 and 2.26:1 and two
/// were within 1.03:1 of each other — invisible on the card and
/// indistinguishable side by side. Colours are the one part of a design that
/// reads fine to the eye while being measurably wrong, so the thresholds are
/// asserted rather than trusted.
void main() {
  double channel(double c) =>
      c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  /// WCAG 2.1 contrast ratio.
  double contrast(Color a, Color b) {
    final la = luminance(a), lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  void expectAtLeast(double actual, double required, String what) {
    expect(
      actual,
      greaterThanOrEqualTo(required),
      reason:
          '$what measured ${actual.toStringAsFixed(2)}:1, '
          'below the required ${required.toStringAsFixed(1)}:1',
    );
  }

  group('categorical ramp', () {
    // The composition bar is drawn on a card, so the card is what each step
    // has to hold up against — not the scaffold behind it.
    const lightCard = Color(0xFFFFFFFF);
    const darkCard = Color(0xFF1C1F1F);

    test('every light step clears 3:1 on the card it sits on', () {
      final ramp = AppCategoryColors.light;
      for (var i = 0; i < ramp.steps.length; i++) {
        expectAtLeast(
          contrast(ramp.steps[i], lightCard),
          3,
          'light category-${i + 1}',
        );
      }
      expectAtLeast(contrast(ramp.other, lightCard), 3, 'light category-other');
    });

    test('every dark step clears 3:1 on the card it sits on', () {
      final ramp = AppCategoryColors.dark;
      for (var i = 0; i < ramp.steps.length; i++) {
        expectAtLeast(
          contrast(ramp.steps[i], darkCard),
          3,
          'dark category-${i + 1}',
        );
      }
      expectAtLeast(contrast(ramp.other, darkCard), 3, 'dark category-other');
    });

    test('adjacent steps stay separable where segments touch', () {
      for (final (name, ramp) in [
        ('light', AppCategoryColors.light),
        ('dark', AppCategoryColors.dark),
      ]) {
        for (var i = 0; i < ramp.steps.length - 1; i++) {
          expectAtLeast(
            contrast(ramp.steps[i], ramp.steps[i + 1]),
            1.25,
            '$name category-${i + 1} against category-${i + 2}',
          );
        }
      }
    });

    test('no step is mistakable for the gain or loss colour', () {
      // Categories must never read as a data state. Lightness alone is a weak
      // test of that, but a step sitting on top of gain or loss is an outright
      // collision and must not happen.
      for (final (name, ramp, semantic) in [
        ('light', AppCategoryColors.light, AppSemanticColors.light),
        ('dark', AppCategoryColors.dark, AppSemanticColors.dark),
      ]) {
        for (final step in [...ramp.steps, ramp.other]) {
          expect(
            step,
            isNot(semantic.gain),
            reason: '$name ramp reuses the gain colour',
          );
          expect(
            step,
            isNot(semantic.loss),
            reason: '$name ramp reuses the loss colour',
          );
        }
      }
    });

    test('the ramp is monotonic, so share order reads as emphasis order', () {
      for (final (name, ramp) in [
        ('light', AppCategoryColors.light),
        ('dark', AppCategoryColors.dark),
      ]) {
        final lums = ramp.steps.map(luminance).toList();
        var rising = true, falling = true;
        for (var i = 0; i < lums.length - 1; i++) {
          if (lums[i] >= lums[i + 1]) rising = false;
          if (lums[i] <= lums[i + 1]) falling = false;
        }
        expect(
          rising || falling,
          isTrue,
          reason: '$name ramp is not ordered by lightness: $lums',
        );
      }
    });

    test('forIndex falls through to other rather than wrapping', () {
      final ramp = AppCategoryColors.light;
      expect(ramp.forIndex(0), ramp.steps.first);
      expect(ramp.forIndex(ramp.steps.length), ramp.other);
      expect(ramp.forIndex(99), ramp.other);
      expect(ramp.forIndex(-1), ramp.other);
    });
  });

  group('semantic colours', () {
    test('gain, loss and alert clear 4.5:1 as text on their surfaces', () {
      for (final (name, semantic, scheme) in [
        ('light', AppSemanticColors.light, AppColorSchemes.light),
        ('dark', AppSemanticColors.dark, AppColorSchemes.dark),
      ]) {
        final card = name == 'light'
            ? scheme.surfaceContainerLowest
            : scheme.surfaceContainer;
        for (final (role, colour) in [
          ('gain', semantic.gain),
          ('loss', semantic.loss),
          ('alert', semantic.alert),
          ('neutral', semantic.neutral),
        ]) {
          expectAtLeast(contrast(colour, card), 4.5, '$name $role on card');
          expectAtLeast(
            contrast(colour, scheme.surface),
            4.5,
            '$name $role on canvas',
          );
        }
      }
    });

    test('container pairs clear 4.5:1 for their own content', () {
      for (final (name, s) in [
        ('light', AppSemanticColors.light),
        ('dark', AppSemanticColors.dark),
      ]) {
        expectAtLeast(
          contrast(s.onGainContainer, s.gainContainer),
          4.5,
          '$name gain container',
        );
        expectAtLeast(
          contrast(s.onLossContainer, s.lossContainer),
          4.5,
          '$name loss container',
        );
        expectAtLeast(
          contrast(s.onAlertContainer, s.alertContainer),
          4.5,
          '$name alert container',
        );
      }
    });
  });
}
