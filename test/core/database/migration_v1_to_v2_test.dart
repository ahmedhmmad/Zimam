import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:zimam/core/database/app_database.dart';

/// The first real migration, tested the way the no-`deleteAllTables` policy
/// demands: build an actual v1 database with real rows in it, open it with the
/// current code, and assert every row is still there afterwards.
///
/// The `drift_dev schema` tooling is broken against drift 2.34, so the v1
/// schema is written out by hand here. That is not a workaround so much as the
/// point — this fixture is a frozen copy of what shipped, and it stays frozen
/// even as the live schema moves on.
void main() {
  late Directory tempDir;
  late File dbFile;

  /// The v1 schema exactly as Phase 1 shipped it. Do not update this when the
  /// live schema changes; that is what makes it a migration test.
  const v1Schema = [
    '''
    CREATE TABLE accounts (
      id TEXT NOT NULL,
      name TEXT NOT NULL,
      institution TEXT NULL,
      currency_code TEXT NOT NULL,
      type TEXT NOT NULL,
      color_argb INTEGER NULL,
      notes TEXT NULL,
      is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1)),
      created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      updated_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      deleted_at TEXT NULL,
      PRIMARY KEY (id)
    )''',
    '''
    CREATE TABLE balance_snapshots (
      id TEXT NOT NULL,
      account_id TEXT NOT NULL REFERENCES accounts (id) ON DELETE CASCADE,
      amount_minor INTEGER NOT NULL,
      currency_code TEXT NOT NULL,
      observed_at TEXT NOT NULL,
      source TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      updated_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      deleted_at TEXT NULL,
      PRIMARY KEY (id)
    )''',
    '''
    CREATE TABLE debts (
      id TEXT NOT NULL,
      counterparty TEXT NOT NULL,
      direction TEXT NOT NULL,
      principal_minor INTEGER NOT NULL,
      currency_code TEXT NOT NULL,
      home_currency_code TEXT NOT NULL,
      rate_at_creation_scaled INTEGER NOT NULL,
      created_on TEXT NOT NULL,
      due_on TEXT NULL,
      settled_at TEXT NULL,
      notes TEXT NULL,
      created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      updated_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      deleted_at TEXT NULL,
      PRIMARY KEY (id)
    )''',
    '''
    CREATE TABLE debt_payments (
      id TEXT NOT NULL,
      debt_id TEXT NOT NULL REFERENCES debts (id) ON DELETE CASCADE,
      amount_minor INTEGER NOT NULL,
      currency_code TEXT NOT NULL,
      paid_on TEXT NOT NULL,
      rate_at_payment_scaled INTEGER NOT NULL,
      notes TEXT NULL,
      created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      updated_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      deleted_at TEXT NULL,
      PRIMARY KEY (id)
    )''',
    '''
    CREATE TABLE fx_rates (
      base_code TEXT NOT NULL,
      quote_code TEXT NOT NULL,
      rate_scaled INTEGER NOT NULL,
      rate_date TEXT NOT NULL,
      fetched_at TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      updated_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      deleted_at TEXT NULL,
      PRIMARY KEY (base_code, quote_code, rate_date)
    )''',
    '''
    CREATE TABLE settings (
      key TEXT NOT NULL,
      value TEXT NOT NULL,
      created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      updated_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
      deleted_at TEXT NULL,
      PRIMARY KEY (key)
    )''',
  ];

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('zimam_migration');
    dbFile = File('${tempDir.path}/v1.sqlite');

    // A v1 database with a user's real data in it.
    final raw = sqlite3.open(dbFile.path);
    for (final statement in v1Schema) {
      raw.execute(statement);
    }

    raw.execute(
      "INSERT INTO accounts (id, name, institution, currency_code, type, "
      "created_at, updated_at) VALUES "
      "('a1', 'Bank al Etihad', 'Etihad', 'JOD', 'bank', "
      "'2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')",
    );
    raw.execute(
      "INSERT INTO balance_snapshots (id, account_id, amount_minor, "
      "currency_code, observed_at, source, created_at, updated_at) VALUES "
      "('s1', 'a1', 9120500, 'JOD', '2026-01-01T00:00:00.000Z', 'manual', "
      "'2026-01-01T00:00:00.000Z', '2026-01-01T00:00:00.000Z')",
    );
    raw.execute(
      "INSERT INTO debts (id, counterparty, direction, principal_minor, "
      "currency_code, home_currency_code, rate_at_creation_scaled, created_on, "
      "created_at, updated_at) VALUES "
      "('d1', 'Ahmad Q.', 'iOwe', 200000, 'USD', 'JOD', 70900000, "
      "'2025-03-14T00:00:00.000Z', '2025-03-14T00:00:00.000Z', "
      "'2025-03-14T00:00:00.000Z')",
    );
    raw.execute(
      "INSERT INTO fx_rates (base_code, quote_code, rate_scaled, rate_date, "
      "fetched_at, created_at, updated_at) VALUES "
      "('USD', 'JOD', 70900000, '2026-03-20T00:00:00.000Z', "
      "'2026-03-20T00:00:00.000Z', '2026-03-20T00:00:00.000Z', "
      "'2026-03-20T00:00:00.000Z')",
    );
    raw.execute(
      "INSERT INTO settings (key, value, created_at, updated_at) VALUES "
      "('home_currency', 'JOD', '2026-01-01T00:00:00.000Z', "
      "'2026-01-01T00:00:00.000Z')",
    );

    raw.execute('PRAGMA user_version = 1');
    raw.dispose();
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('a v1 database upgrades to v2', () async {
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    // Opening runs the migration.
    final version = await db
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data.values.first, 2);
  });

  test('every existing row survives the upgrade', () async {
    // The property the whole no-deleteAllTables policy exists to protect.
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    final accounts = await db.select(db.accounts).get();
    expect(accounts, hasLength(1));
    expect(accounts.single.name, 'Bank al Etihad');
    expect(accounts.single.currencyCode, 'JOD');

    final snapshots = await db.select(db.balanceSnapshots).get();
    expect(snapshots.single.amountMinor, 9120500);

    final debts = await db.select(db.debts).get();
    expect(debts.single.counterparty, 'Ahmad Q.');
    expect(
      debts.single.rateAtCreationScaled,
      70900000,
      reason: 'the frozen rate must not be disturbed by a migration',
    );
    expect(debts.single.homeCurrencyCode, 'JOD');

    final rates = await db.select(db.fxRates).get();
    expect(rates.single.rateScaled, 70900000);

    final settings = await db.select(db.settings).get();
    expect(settings.single.value, 'JOD');
  });

  test('timestamps still read back as UTC after the upgrade', () async {
    // Text storage is what keeps rate dates meaning the same thing in every
    // timezone; a migration that changed the storage format would break it.
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    final rate = (await db.select(db.fxRates).get()).single;
    expect(rate.rateDate.isUtc, isTrue);
    expect(rate.rateDate, DateTime.utc(2026, 3, 20));
  });

  test('the new tables exist and are empty', () async {
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    expect(await db.select(db.pendingSuggestions).get(), isEmpty);
    expect(await db.select(db.unparsedSamples).get(), isEmpty);
  });

  test('the upgraded database still enforces foreign keys', () async {
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(db.close);

    final pragma = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(pragma.data.values.first, 1);
  });

  test('an undefined step still fails loudly', () async {
    // The guard has to survive the arrival of a real migration: a future
    // version without a step must throw rather than quietly do nothing.
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(
      () => db.migration.onUpgrade(_FakeMigrator(), 2, 3),
      throwsStateError,
    );
  });
}

class _FakeMigrator implements Migrator {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
