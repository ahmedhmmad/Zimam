import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The on-device store. Every financial record in the app lives here and
/// nowhere else.
///
/// ## Migration strategy
///
/// [schemaVersion] starts at 1 and is bumped by every schema change, with the
/// matching step added to [migration] *in the same commit as the change*.
///
/// There is deliberately no `deleteAllTables()` fallback. That idiom is
/// standard in apps backed by a server, where wiping and re-syncing costs a
/// user nothing. Here it would silently destroy the only copy of someone's
/// financial history. A migration that cannot be written is a schema change
/// that must be redesigned, not papered over.
///
/// Rules for future versions:
///
/// * Adding a nullable column, or one with a default: `m.addColumn`.
/// * Adding a table: `m.createTable`.
/// * Anything destructive — dropping a column, changing a type, tightening a
///   constraint — uses a copy-and-swap into a new table, with a test that
///   asserts row counts and a sample of values survive.
/// * Never renumber or reorder an enum; they are stored by name for exactly
///   this reason. See `enums.dart`.
///
/// Schema snapshots are exported to `drift_schemas/` so `drift_dev`'s
/// migration tooling can verify every upgrade path from v1 forward:
///
/// ```bash
/// dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas
/// ```
@DriftDatabase(
  tables: [
    Accounts,
    BalanceSnapshots,
    Debts,
    DebtPayments,
    FxRates,
    Settings,
    PendingSuggestions,
    UnparsedSamples,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For tests: an isolated in-memory database with the same schema.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  /// Store timestamps as ISO-8601 text in UTC, not as unix seconds.
  ///
  /// Drift's integer default returns *local* `DateTime`s on read, which
  /// quietly breaks this app. FX rate dates are UTC midnight by convention,
  /// and staleness is computed by comparing calendar days — so for a user west
  /// of UTC, a rate stored at midnight UTC reads back as the previous evening
  /// and every conversion reports a day staler than it is. Text storage round
  /// trips the timezone, so a date means the same thing everywhere.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Off by default in SQLite, and the schema leans on it: deleting an
      // account must take its snapshots with it rather than orphan them.
      await customStatement('PRAGMA foreign_keys = ON');
    },
    // Applied one version at a time, so upgrading from v1 to v4 runs the same
    // steps in the same order as a user who upgraded through each release.
    // A version with no step throws rather than silently doing nothing —
    // there is no cloud copy to repair from if it does.
    onUpgrade: (m, from, to) async {
      for (var version = from; version < to; version++) {
        switch (version) {
          case 1:
            await _v1ToV2(m);
          default:
            throw StateError(
              'No migration defined from schema v$version to v${version + 1}. '
              'Write one before bumping schemaVersion — there is no cloud '
              'copy of this data.',
            );
        }
      }
    },
  );

  /// Phase 5 adds notification capture: pending suggestions and unparsed
  /// samples.
  ///
  /// Purely additive — two new tables, and not a single column touched on the
  /// six that already exist. That is why this step is safe to write in one
  /// line: nothing is copied, rewritten or dropped, so there is no path by
  /// which an existing balance could be lost. A future step that is not
  /// additive gets a copy-and-swap and a test asserting row counts survive.
  Future<void> _v1ToV2(Migrator m) async {
    await m.createTable(pendingSuggestions);
    await m.createTable(unparsedSamples);
  }
}

/// Opens the database file in the app's private documents directory.
///
/// Private storage, not external: this is financial data and no other app
/// should be able to read it.
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'zimam.sqlite'));

    // Keeps SQLite's temp files inside our own sandbox rather than a
    // system-wide location.
    sqlite3.tempDirectory = directory.path;

    return NativeDatabase.createInBackground(file);
  });
}
