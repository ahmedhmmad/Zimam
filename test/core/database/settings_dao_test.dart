import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/settings_dao.dart';
import 'package:zimam/core/money/currency.dart';
import 'package:zimam/core/money/money_formatter.dart';

void main() {
  late AppDatabase db;
  late SettingsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SettingsDao(db);
  });

  tearDown(() async => db.close());

  group('home currency', () {
    test('is absent until onboarding sets it', () async {
      // Null is how the app knows onboarding has not run. Guessing from the
      // device locale would put a Jordanian salary into dollars because the
      // phone is set to English.
      expect(await dao.homeCurrency(), isNull);
    });

    test('persists and reads back', () async {
      await dao.setHomeCurrency(CurrencyRegistry.of('JOD'));
      expect(await dao.homeCurrency(), CurrencyRegistry.of('JOD'));
    });

    test('survives a new accessor over the same database', () async {
      await dao.setHomeCurrency(CurrencyRegistry.of('AED'));
      // A fresh DAO is what a cold start looks like from the data's side.
      expect(await SettingsDao(db).homeCurrency(), CurrencyRegistry.of('AED'));
    });

    test('changing it overwrites rather than accumulating rows', () async {
      await dao.setHomeCurrency(CurrencyRegistry.of('JOD'));
      await dao.setHomeCurrency(CurrencyRegistry.of('USD'));
      expect(await dao.homeCurrency(), CurrencyRegistry.of('USD'));

      final rows = await db.select(db.settings).get();
      expect(rows.where((r) => r.key == 'home_currency').length, 1);
    });

    test('watch emits the current value and then updates', () async {
      final seen = <Currency?>[];
      final sub = dao.watchHomeCurrency().listen(seen.add);

      // Let the initial emission land before writing, otherwise the write can
      // beat it and the "before" value is never observed.
      await pumpEventQueue();
      expect(seen, [isNull], reason: 'should emit the current state first');

      await dao.setHomeCurrency(CurrencyRegistry.of('EGP'));
      await pumpEventQueue();
      await sub.cancel();

      expect(seen.last, CurrencyRegistry.of('EGP'));
    });

    test('an unrecognised stored code reads as absent, not as a crash', () async {
      // A corrupt row must not make the app unopenable.
      await db
          .into(db.settings)
          .insert(SettingsCompanion.insert(key: 'home_currency', value: 'XXX'));
      expect(await dao.homeCurrency(), isNull);
    });
  });

  group('digit style', () {
    test('defaults to Western in the absence of a setting', () async {
      expect(await dao.digitStyle(), DigitStyle.western);
    });

    test('persists a choice of Arabic-Indic', () async {
      await dao.setDigitStyle(DigitStyle.arabicIndic);
      expect(await dao.digitStyle(), DigitStyle.arabicIndic);
    });

    test('falls back to Western on an unreadable value', () async {
      await db
          .into(db.settings)
          .insert(SettingsCompanion.insert(key: 'digit_style', value: 'roman'));
      expect(await dao.digitStyle(), DigitStyle.western);
    });
  });

  group('independence', () {
    test('settings do not overwrite one another', () async {
      await dao.setHomeCurrency(CurrencyRegistry.of('KWD'));
      await dao.setDigitStyle(DigitStyle.arabicIndic);

      expect(await dao.homeCurrency(), CurrencyRegistry.of('KWD'));
      expect(await dao.digitStyle(), DigitStyle.arabicIndic);
    });
  });
}
