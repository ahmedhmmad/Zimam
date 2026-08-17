import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/theme/app_theme.dart';
import 'package:zimam/core/theme/app_typography.dart';

/// Guards two failures that shipped to a device before anyone noticed.
///
/// The empty-state heading and every bottom-navigation label rendered
/// near-invisible, because the text theme assigned bare [TextStyle]s with
/// `copyWith`, discarding the colour Material derives from the scheme. And the
/// nav labels came out monospaced, because JetBrains Mono had been dropped
/// into the shared `labelLarge`/`labelMedium` slots.
///
/// Both are invisible in code review and obvious on screen, which is exactly
/// the kind of thing to assert.
void main() {
  final themes = {'light': AppTheme.light(), 'dark': AppTheme.dark()};

  /// The slots `AppTypography.textTheme` actually maps.
  List<(String, TextStyle?)> mappedSlots(TextTheme t) => [
    ('displaySmall', t.displaySmall),
    ('headlineSmall', t.headlineSmall),
    ('titleLarge', t.titleLarge),
    ('titleMedium', t.titleMedium),
    ('bodyLarge', t.bodyLarge),
    ('bodyMedium', t.bodyMedium),
    ('labelLarge', t.labelLarge),
    ('labelMedium', t.labelMedium),
  ];

  group('text colour survives theming', () {
    test('every mapped slot has a colour', () {
      themes.forEach((name, theme) {
        for (final (slot, style) in mappedSlots(theme.textTheme)) {
          expect(
            style?.color,
            isNotNull,
            reason:
                '$name $slot has no colour — it will render in whatever the '
                'ancestor default happens to be, which is how the empty-state '
                'heading became invisible',
          );
        }
      });
    });

    test('the colour is readable against the surface it sits on', () {
      themes.forEach((name, theme) {
        final surface = theme.colorScheme.surface;
        for (final (slot, style) in mappedSlots(theme.textTheme)) {
          expect(
            style!.color,
            isNot(surface),
            reason: '$name $slot is the same colour as the surface',
          );
        }
      });
    });
  });

  group('monospace stays out of the shared slots', () {
    test('no standard text slot is monospaced', () {
      themes.forEach((name, theme) {
        for (final (slot, style) in mappedSlots(theme.textTheme)) {
          expect(
            style!.fontFamily,
            isNot(AppTypography.mono),
            reason:
                '$name $slot is JetBrains Mono. Widgets using standard styles '
                'would silently become monospaced; figures must go through '
                'AppTypography.amount* instead',
          );
        }
      });
    });

    test('every mapped slot uses the sans family', () {
      themes.forEach((name, theme) {
        for (final (slot, style) in mappedSlots(theme.textTheme)) {
          expect(
            style!.fontFamily,
            AppTypography.sans,
            reason: '$name $slot should be ${AppTypography.sans}',
          );
        }
      });
    });

    test('the Arabic fallback is attached to every slot', () {
      themes.forEach((name, theme) {
        for (final (slot, style) in mappedSlots(theme.textTheme)) {
          expect(
            style!.fontFamilyFallback,
            contains(AppTypography.sansArabic),
            reason: '$name $slot would drop to a system font in Arabic',
          );
        }
      });
    });
  });

  group('amount styles are monospaced and tabular', () {
    testWidgets('amount helpers return JetBrains Mono with tabular figures', (
      tester,
    ) async {
      late List<TextStyle> styles;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              styles = [
                AppTypography.amountHero(context),
                AppTypography.amountTitle(context),
                AppTypography.amountBody(context),
                AppTypography.amountSecondary(context),
              ];
              return const SizedBox();
            },
          ),
        ),
      );

      for (final style in styles) {
        expect(style.color, isNotNull, reason: 'amount style has no colour');
        expect(
          style.fontFeatures,
          contains(const FontFeature.tabularFigures()),
          reason: 'digits would shift width as values update',
        );
      }

      // The hero is sans by design (`display-hero`); the rest are mono.
      expect(styles[0].fontFamily, AppTypography.sans);
      for (final style in styles.skip(1)) {
        expect(style.fontFamily, AppTypography.mono);
      }
    });
  });
}
