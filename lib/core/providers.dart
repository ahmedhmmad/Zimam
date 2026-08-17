import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/fx_rates_dao.dart';
import 'database/settings_dao.dart';
import 'fx/fx_provider_client.dart';
import 'fx/fx_service.dart';
import 'money/currency.dart';
import 'money/money_formatter.dart';

/// The single database instance for the app's lifetime.
///
/// Overridden in tests with `AppDatabase.forTesting(NativeDatabase.memory())`,
/// which is why nothing constructs [AppDatabase] directly outside this file.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsDaoProvider = Provider<SettingsDao>(
  (ref) => SettingsDao(ref.watch(databaseProvider)),
);

final fxRatesDaoProvider = Provider<FxRatesDao>(
  (ref) => FxRatesDao(ref.watch(databaseProvider)),
);

/// The rate provider client. Separated from [fxServiceProvider] so tests can
/// swap in an offline or fake client without rebuilding the service.
final fxClientProvider = Provider<FxProviderClient>((ref) {
  final client = OpenErApiClient();
  ref.onDispose(client.close);
  return client;
});

final fxServiceProvider = Provider<FxService>(
  (ref) => FxService(
    dao: ref.watch(fxRatesDaoProvider),
    client: ref.watch(fxClientProvider),
  ),
);

/// The currency every figure in the app is reported in.
///
/// Null means onboarding has not run yet. Watched rather than read once, so
/// changing it re-renders every amount at the same moment instead of leaving
/// a mix of old and new on screen.
final homeCurrencyProvider = StreamProvider<Currency?>(
  (ref) => ref.watch(settingsDaoProvider).watchHomeCurrency(),
);

final digitStyleProvider = StreamProvider<DigitStyle>(
  (ref) => ref.watch(settingsDaoProvider).watchDigitStyle(),
);

/// A formatter already configured with the user's locale and digit style.
///
/// Screens take this rather than constructing their own, so the digit-style
/// setting cannot end up applied inconsistently across the app.
final moneyFormatterProvider = Provider.family<MoneyFormatter, String>(
  (ref, locale) => MoneyFormatter(
    locale: locale,
    digitStyle: ref.watch(digitStyleProvider).value ?? DigitStyle.western,
  ),
);
