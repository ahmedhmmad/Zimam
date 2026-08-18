import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/l10n/l10n.dart';

import 'support/test_app.dart';

/// Shell-level tests: navigation, both locales, and text direction.
void main() {
  final jod = CurrencyRegistry.of('JOD');

  Finder navItem(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('starts on Wealth with all three destinations', (tester) async {
    await pumpApp(tester, homeCurrency: jod);
    final l10n = await AppL10n.delegate.load(const Locale('en'));

    expect(find.text(l10n.wealthEmptyTitle), findsOneWidget);
    expect(navItem(l10n.navWealth), findsOneWidget);
    expect(navItem(l10n.navAccounts), findsOneWidget);
    expect(navItem(l10n.navDebts), findsOneWidget);
  });

  testWidgets('navigating destinations swaps the screen', (tester) async {
    await pumpApp(tester, homeCurrency: jod);
    final l10n = await AppL10n.delegate.load(const Locale('en'));

    await tester.tap(navItem(l10n.navDebts));
    await settle(tester);
    expect(find.text(l10n.debtsEmptyTitle), findsOneWidget);

    await tester.tap(navItem(l10n.navAccounts));
    await settle(tester);
    expect(find.text(l10n.accountsEmptyTitle), findsOneWidget);
  });

  testWidgets('choosing Arabic translates the UI and flips direction', (
    tester,
  ) async {
    await pumpApp(tester, homeCurrency: jod);
    final en = await AppL10n.delegate.load(const Locale('en'));
    final ar = await AppL10n.delegate.load(const Locale('ar'));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);

    await tester.tap(find.text(en.settingsLanguageArabic));
    await settle(tester);

    expect(find.text(ar.settingsTitle), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(ar.settingsTitle))),
      TextDirection.rtl,
    );
  });

  testWidgets('a first run lands on onboarding, not on Wealth', (tester) async {
    // No home currency set: the app cannot report a figure in a currency the
    // user has not chosen, so it must ask first.
    await pumpApp(tester);
    final l10n = await AppL10n.delegate.load(const Locale('en'));

    expect(find.text(l10n.onboardingCurrencyTitle), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('every locale in the ARB set resolves without throwing', (
    tester,
  ) async {
    for (final locale in AppL10n.supportedLocales) {
      expect(AppL10n.delegate.isSupported(locale), isTrue);
      await expectLater(AppL10n.delegate.load(locale), completes);
    }
  });
}
