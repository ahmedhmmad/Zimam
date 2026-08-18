import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/settings_dao.dart';

/// The second half of Phase 3's done-condition: dismissal persists.
void main() {
  late AppDatabase db;
  late SettingsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SettingsDao(db);
  });

  tearDown(() async => db.close());

  test('nothing is dismissed to begin with', () async {
    expect(await dao.dismissedInsights(), isEmpty);
  });

  test('a dismissal is readable back', () async {
    await dao.dismissInsight('concentration:AED:14');
    expect(await dao.dismissedInsights(), {'concentration:AED:14'});
  });

  test('dismissals survive a fresh accessor, as on a cold start', () async {
    await dao.dismissInsight('dormancy:2:3');
    await dao.dismissInsight('scattered:4:3');

    // A new DAO over the same database is what a relaunch looks like from the
    // data's side.
    expect(await SettingsDao(db).dismissedInsights(), {
      'dormancy:2:3',
      'scattered:4:3',
    });
  });

  test('dismissing the same signature twice does not duplicate it', () async {
    await dao.dismissInsight('fxDrift:30:2:down');
    await dao.dismissInsight('fxDrift:30:2:down');
    expect(await dao.dismissedInsights(), hasLength(1));
  });

  test('signatures containing separators round trip intact', () async {
    // Signatures embed currency codes and numbers joined by colons, so the
    // storage separator must be something that cannot appear inside one.
    const awkward = 'concentration:AED:14';
    await dao.dismissInsight(awkward);
    expect(await dao.dismissedInsights(), contains(awkward));
  });

  test('the list is capped so a long-lived install cannot grow forever',
      () async {
    for (var i = 0; i < 250; i++) {
      await dao.dismissInsight('rule:$i');
    }
    final stored = await dao.dismissedInsights();
    expect(stored.length, lessThanOrEqualTo(200));
    expect(
      stored,
      contains('rule:249'),
      reason: 'the most recent dismissals must be the ones kept',
    );
  });

  test('clearing brings every card back', () async {
    await dao.dismissInsight('dormancy:1:2');
    await dao.clearDismissedInsights();
    expect(await dao.dismissedInsights(), isEmpty);
  });

  test('watch emits the current set and then updates', () async {
    final seen = <Set<String>>[];
    final sub = dao.watchDismissedInsights().listen(seen.add);

    await pumpEventQueue();
    expect(seen.first, isEmpty);

    await dao.dismissInsight('dormancy:1:2');
    await pumpEventQueue();
    await sub.cancel();

    expect(seen.last, contains('dormancy:1:2'));
  });

  group('scattered threshold', () {
    test('is absent until set, so the default can apply', () async {
      expect(await dao.scatteredThresholdMinor(), isNull);
    });

    test('persists in minor units', () async {
      await dao.setScatteredThresholdMinor(100000); // 100.000 JOD
      expect(await dao.scatteredThresholdMinor(), 100000);
      expect(await SettingsDao(db).scatteredThresholdMinor(), 100000);
    });

    test('an unreadable value reads as unset rather than crashing', () async {
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: 'scattered_threshold_minor',
              value: 'lots',
            ),
          );
      expect(await dao.scatteredThresholdMinor(), isNull);
    });
  });
}
