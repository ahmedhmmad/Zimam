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
  static const _dismissedInsights = 'dismissed_insights';
  static const _scatteredThreshold = 'scattered_threshold_minor';
  static const _locale = 'locale';
  static const _themeMode = 'theme_mode';

  /// The chosen UI language, or null to follow the device.
  ///
  /// Stored as a bare language code rather than a full tag: the app ships two
  /// languages and a stored `ar-EG` would fail to match the `ar` delegate,
  /// silently dropping the user back to English — which is exactly the bug
  /// this setting exists to prevent.
  Future<String?> localeCode() async {
    final raw = await _read(_locale);
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  /// Empty string means "follow the device", which is distinct from unset.
  Future<void> setLocaleCode(String? code) => _write(_locale, code ?? '');

  Stream<String?> watchLocaleCode() => _watch(
    _locale,
  ).map((raw) => (raw == null || raw.isEmpty) ? null : raw);

  /// `system` | `light` | `dark`. Defaults to following the device.
  Future<String> themeModeName() async =>
      await _read(_themeMode) ?? 'system';

  Future<void> setThemeModeName(String name) => _write(_themeMode, name);

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

  /// Signatures of insight cards the user has dismissed.
  ///
  /// Signatures rather than rule names: a card stays dismissed while the
  /// situation behind it stays roughly the same, and earns another appearance
  /// once it has materially changed. See `Insight.signature`.
  Future<Set<String>> dismissedInsights() async =>
      _decodeSignatures(await _read(_dismissedInsights));

  Stream<Set<String>> watchDismissedInsights() =>
      _watch(_dismissedInsights).map(_decodeSignatures);

  /// Signatures are newline-separated. Newline rather than comma because a
  /// signature embeds a currency code and numbers, and a separator that could
  /// ever appear inside one would silently split a key in half.
  static Set<String> _decodeSignatures(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    return raw.split('\n').where((s) => s.isNotEmpty).toSet();
  }

  Future<void> dismissInsight(String signature) async {
    final current = await dismissedInsights();
    // Capped so a long-lived install cannot accumulate an unbounded row.
    // Oldest entries fall off; the worst case is a card the user dismissed
    // months ago reappearing once.
    final updated = [...current, signature];
    final trimmed = updated.length > 200
        ? updated.sublist(updated.length - 200)
        : updated;
    await _write(_dismissedInsights, trimmed.join('\n'));
  }

  Future<void> clearDismissedInsights() => _write(_dismissedInsights, '');

  /// The balance below which a holding counts as "small", in minor units of
  /// the home currency. Null until the user sets one.
  Future<int?> scatteredThresholdMinor() async {
    final raw = await _read(_scatteredThreshold);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> setScatteredThresholdMinor(int minorUnits) =>
      _write(_scatteredThreshold, minorUnits.toString());

  Stream<int?> watchScatteredThresholdMinor() =>
      _watch(_scatteredThreshold).map((raw) => raw == null ? null : int.tryParse(raw));

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
