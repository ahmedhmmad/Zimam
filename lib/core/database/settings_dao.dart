import 'package:drift/drift.dart';

import '../money/currency.dart';
import '../money/money_formatter.dart';
import 'app_database.dart';
import 'tables.dart';

part 'settings_dao.g.dart';

/// Typed access to the untyped [Settings] key/value table.
///
/// The table is deliberately schemaless so that adding a preference needs no
/// migration, but nothing outside this class touches raw keys — every setting
/// gets a named getter and setter here, so a typo is a compile error rather
/// than a silently missing value.
@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  static const _homeCurrency = 'home_currency';
  static const _digitStyle = 'digit_style';

  /// The currency every balance is reported in — the app's central premise.
  ///
  /// Null until onboarding sets it, which is how the app knows onboarding has
  /// not happened. There is no default: guessing from the device locale would
  /// put an expat's Jordanian salary into US dollars because their phone is
  /// set to English.
  Future<Currency?> homeCurrency() async {
    final code = await _read(_homeCurrency);
    return code == null ? null : CurrencyRegistry.tryOf(code);
  }

  Future<void> setHomeCurrency(Currency currency) =>
      _write(_homeCurrency, currency.code);

  /// Watches the home currency so the UI re-renders every amount when it
  /// changes, rather than showing a mix of old and new until a reload.
  Stream<Currency?> watchHomeCurrency() => _watch(
    _homeCurrency,
  ).map((code) => code == null ? null : CurrencyRegistry.tryOf(code));

  /// Western by default, in both languages. See `docs/ARCHITECTURE.md` §5.
  Future<DigitStyle> digitStyle() async {
    final value = await _read(_digitStyle);
    return DigitStyle.values.firstWhere(
      (s) => s.name == value,
      orElse: () => DigitStyle.western,
    );
  }

  Future<void> setDigitStyle(DigitStyle style) =>
      _write(_digitStyle, style.name);

  Stream<DigitStyle> watchDigitStyle() => _watch(_digitStyle).map(
    (value) => DigitStyle.values.firstWhere(
      (s) => s.name == value,
      orElse: () => DigitStyle.western,
    ),
  );

  Future<String?> _read(String key) async {
    final row = await (select(
      settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Stream<String?> _watch(String key) => (select(
    settings,
  )..where((s) => s.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  Future<void> _write(String key, String value) async {
    final now = DateTime.now();
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(
        key: key,
        value: value,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
