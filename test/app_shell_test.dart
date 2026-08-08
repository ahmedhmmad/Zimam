import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/app.dart';
import 'package:zimam/l10n/l10n.dart';

/// Phase 0 smoke tests. UI tests are not a general requirement for this
/// project, but the shell, both locales and text direction are the whole
/// deliverable of this phase, so they get a guard.
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZimamApp()));
    await tester.pumpAndSettle();
  }

  // Destination labels repeat as app-bar titles ("Wealth" is both), so nav
  // assertions are scoped to the bar itself.
  Finder navItem(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('starts on Wealth with all three destinations', (tester) async {
    await pumpApp(tester);

    final l10n = await AppL10n.delegate.load(const Locale('en'));

    expect(find.text(l10n.wealthEmptyTitle), findsOneWidget);
    expect(navItem(l10n.navWealth), findsOneWidget);
    expect(navItem(l10n.navAccounts), findsOneWidget);
    expect(navItem(l10n.navDebts), findsOneWidget);
  });

  testWidgets('navigating destinations swaps the screen', (tester) async {
    await pumpApp(tester);

    final l10n = await AppL10n.delegate.load(const Locale('en'));

    await tester.tap(navItem(l10n.navDebts));
    await tester.pumpAndSettle();
    expect(find.text(l10n.debtsEmptyTitle), findsOneWidget);

    await tester.tap(navItem(l10n.navAccounts));
    await tester.pumpAndSettle();
    expect(find.text(l10n.accountsEmptyTitle), findsOneWidget);
  });

  testWidgets('choosing Arabic translates the UI and flips direction', (
    tester,
  ) async {
    await pumpApp(tester);

    final en = await AppL10n.delegate.load(const Locale('en'));
    final ar = await AppL10n.delegate.load(const Locale('ar'));

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.settingsLanguageArabic));
    await tester.pumpAndSettle();

    expect(find.text(ar.settingsTitle), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(ar.settingsTitle))),
      TextDirection.rtl,
    );
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
