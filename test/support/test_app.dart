import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Riverpod 3 keeps `Override` in the misc barrel rather than the main one.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/app.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money_formatter.dart';
import 'package:zimam/core/providers.dart';
import 'package:zimam/features/accounts/application/accounts_providers.dart';
import 'package:zimam/features/accounts/domain/account.dart';
import 'package:zimam/features/debts/application/debts_providers.dart';
import 'package:zimam/features/debts/domain/debt.dart';
import 'package:zimam/features/wealth/application/wealth_providers.dart';
import 'package:zimam/features/wealth/domain/net_worth.dart';

/// Boots the real app with its data providers stubbed.
///
/// Deliberately no database. Drift's stream machinery leaves timers pending
/// when the widget tree is torn down, which trips the test binding's
/// `!timersPending` assertion and then wedges every later test in the file.
/// The DAOs already have their own tests against a real in-memory database;
/// what these widget tests are for is the router, the screens and the theme,
/// so those get the real implementations and the storage is replaced with
/// fixed values.
Future<void> pumpApp(
  WidgetTester tester, {
  Currency? homeCurrency,
  List<Account> accounts = const [],
  List<Debt> debts = const [],
  NetWorth? netWorth,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeCurrencyProvider.overrideWith((ref) => Stream.value(homeCurrency)),
        digitStyleProvider.overrideWith(
          (ref) => Stream.value(DigitStyle.western),
        ),
        accountsProvider.overrideWith((ref) => Stream.value(accounts)),
        debtsProvider.overrideWith((ref) => Stream.value(debts)),
        debtPositionProvider.overrideWith((ref) async => null),
        netWorthProvider.overrideWith((ref) async => netWorth),
        ...overrides,
      ],
      child: const ZimamApp(),
    ),
  );
  await settle(tester);
}

/// Pumps a bounded number of frames instead of `pumpAndSettle`.
///
/// Screens show a [CircularProgressIndicator] while their providers resolve,
/// and an indeterminate spinner never stops animating — so `pumpAndSettle`
/// waits out its full timeout and the test looks like a hang.
Future<void> settle(WidgetTester tester, {int frames = 24}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}
