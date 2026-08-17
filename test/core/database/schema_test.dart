import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zimam/core/database/app_database.dart';
import 'package:zimam/core/database/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  group('schema', () {
    test('opens at version 1 and creates every table', () async {
      expect(db.schemaVersion, 1);

      // Touching each table proves it was created.
      expect(await db.select(db.accounts).get(), isEmpty);
      expect(await db.select(db.balanceSnapshots).get(), isEmpty);
      expect(await db.select(db.debts).get(), isEmpty);
      expect(await db.select(db.debtPayments).get(), isEmpty);
      expect(await db.select(db.fxRates).get(), isEmpty);
      expect(await db.select(db.settings).get(), isEmpty);
    });

    test('stores timestamps as UTC text, not local integers', () async {
      // Guards the bug this setting was introduced for: with drift's integer
      // default, a UTC-midnight rate date reads back in local time and every
      // staleness calculation is a day out west of UTC.
      final utcMidnight = DateTime.utc(2026, 3, 19);
      await db
          .into(db.fxRates)
          .insert(
            FxRatesCompanion.insert(
              baseCode: 'USD',
              quoteCode: 'JOD',
              rateScaled: 70900000,
              rateDate: utcMidnight,
              fetchedAt: utcMidnight,
            ),
          );

      final row = await db.select(db.fxRates).getSingle();
      expect(row.rateDate.isUtc, isTrue);
      expect(row.rateDate, utcMidnight);
    });
  });

  group('referential integrity', () {
    test('foreign keys are enforced, not merely declared', () async {
      // SQLite has them off by default; the schema relies on them.
      final result = await db
          .customSelect('PRAGMA foreign_keys')
          .getSingle();
      expect(result.data.values.first, 1);
    });

    test('deleting an account takes its snapshots with it', () async {
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'a1',
              name: 'Bank al Etihad',
              currencyCode: 'JOD',
              type: AccountType.bank.name,
            ),
          );
      await db
          .into(db.balanceSnapshots)
          .insert(
            BalanceSnapshotsCompanion.insert(
              id: 's1',
              accountId: 'a1',
              amountMinor: 9120500,
              currencyCode: 'JOD',
              observedAt: DateTime.utc(2026, 3, 20),
              source: SnapshotSource.manual.name,
            ),
          );

      await (db.delete(db.accounts)..where((a) => a.id.equals('a1'))).go();
      expect(await db.select(db.balanceSnapshots).get(), isEmpty);
    });

    test('a snapshot cannot reference an account that does not exist', () async {
      expect(
        () => db
            .into(db.balanceSnapshots)
            .insert(
              BalanceSnapshotsCompanion.insert(
                id: 's1',
                accountId: 'nope',
                amountMinor: 1,
                currencyCode: 'JOD',
                observedAt: DateTime.utc(2026, 3, 20),
                source: SnapshotSource.manual.name,
              ),
            ),
        throwsA(anything),
      );
    });
  });

  group('soft delete', () {
    test('rows carry timestamps and a nullable deletedAt', () async {
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'a1',
              name: 'Wise',
              currencyCode: 'USD',
              type: AccountType.wallet.name,
            ),
          );

      final row = await db.select(db.accounts).getSingle();
      expect(row.createdAt, isNotNull);
      expect(row.updatedAt, isNotNull);
      expect(
        row.deletedAt,
        isNull,
        reason: 'a new row is not deleted',
      );
      expect(row.isArchived, isFalse);
    });
  });

  group('migrations', () {
    test('there is no destructive fallback', () async {
      // If a future schema bump forgets its migration step, the app must fail
      // loudly rather than quietly wiping the only copy of the user's data.
      // This asserts the guard exists rather than a deleteAllTables() default.
      final strategy = db.migration;
      expect(
        () => strategy.onUpgrade(FakeMigrator(), 1, 2),
        throwsStateError,
      );
    });
  });
}

/// Stands in for drift's [Migrator]; the guard throws before touching it.
class FakeMigrator implements Migrator {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
