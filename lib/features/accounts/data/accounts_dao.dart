import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/enums.dart';
import '../../../core/database/tables.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/account.dart';

part 'accounts_dao.g.dart';

/// Reads and writes accounts and their balance history.
///
/// Every read filters out soft-deleted rows; nothing outside this class needs
/// to remember that. Balances come from the latest snapshot rather than a
/// column, so the join lives here once.
@DriftAccessor(tables: [Accounts, BalanceSnapshots])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// All live accounts with their current balances, archived ones last.
  Stream<List<Account>> watchAll({bool includeArchived = true}) {
    final query = select(accounts)
      ..where((a) => a.deletedAt.isNull())
      ..orderBy([
        (a) => OrderingTerm.asc(a.isArchived),
        (a) => OrderingTerm.asc(a.currencyCode),
        (a) => OrderingTerm.asc(a.name),
      ]);
    if (!includeArchived) {
      query.where((a) => a.isArchived.equals(false));
    }

    return query.watch().asyncMap(_withBalances);
  }

  Future<List<Account>> getAll({bool includeArchived = true}) =>
      watchAll(includeArchived: includeArchived).first;

  Future<Account?> byId(String id) async {
    final row = await (select(accounts)
          ..where((a) => a.id.equals(id) & a.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    final withBalance = await _withBalances([row]);
    return withBalance.single;
  }

  /// Creates an account and records its opening balance as the first snapshot.
  ///
  /// Both writes happen in one transaction: an account with no snapshot has no
  /// balance, and a snapshot with no account violates the foreign key. Either
  /// both land or neither does.
  Future<void> create({
    required String id,
    required String name,
    required Currency currency,
    required AccountType type,
    required Money openingBalance,
    required String snapshotId,
    String? institution,
    int? colorArgb,
    String? notes,
    DateTime? observedAt,
  }) async {
    final now = DateTime.now().toUtc();
    await transaction(() async {
      await into(accounts).insert(
        AccountsCompanion.insert(
          id: id,
          name: name,
          currencyCode: currency.code,
          type: type.name,
          institution: Value(institution),
          colorArgb: Value(colorArgb),
          notes: Value(notes),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await into(balanceSnapshots).insert(
        BalanceSnapshotsCompanion.insert(
          id: snapshotId,
          accountId: id,
          amountMinor: openingBalance.minorUnits,
          currencyCode: currency.code,
          observedAt: observedAt ?? now,
          source: SnapshotSource.manual.name,
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  /// Updates the editable fields. Currency is deliberately absent: changing it
  /// would reinterpret every past snapshot's integer at a different scale.
  Future<void> updateDetails({
    required String id,
    required String name,
    String? institution,
    AccountType? type,
    int? colorArgb,
    String? notes,
  }) async {
    await (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        name: Value(name),
        institution: Value(institution),
        type: type == null ? const Value.absent() : Value(type.name),
        colorArgb: Value(colorArgb),
        notes: Value(notes),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Records a new balance observation.
  ///
  /// Append-only: correcting a balance adds a row rather than editing one, so
  /// the difference between two snapshots stays a true record of what the user
  /// actually moved.
  Future<void> recordBalance({
    required String snapshotId,
    required String accountId,
    required Money amount,
    DateTime? observedAt,
    SnapshotSource source = SnapshotSource.manual,
  }) async {
    final now = DateTime.now().toUtc();
    await into(balanceSnapshots).insert(
      BalanceSnapshotsCompanion.insert(
        id: snapshotId,
        accountId: accountId,
        amountMinor: amount.minorUnits,
        currencyCode: amount.currency.code,
        observedAt: observedAt ?? now,
        source: source.name,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> setArchived(String id, {required bool archived}) async {
    await (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Soft delete. The row and its snapshots stay on disk until the Phase 6
  /// "delete all my data" action, so a mistap is recoverable.
  Future<void> softDelete(String id) async {
    await (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        deletedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// Every snapshot for an account, newest first.
  Future<List<BalanceSnapshot>> historyFor(String accountId) async {
    final rows = await (select(balanceSnapshots)
          ..where((s) => s.accountId.equals(accountId) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.observedAt)]))
        .get();
    return rows.map(_toSnapshot).toList();
  }

  /// The balance each account held at [asOf], for the FX-drift comparison.
  ///
  /// Accounts with no snapshot on or before that date are omitted rather than
  /// reported as zero — they did not exist yet, and calling that "zero" would
  /// show a new account as a gain the user never made.
  Future<Map<String, Money>> balancesAsOf(DateTime asOf) async {
    final rows = await (select(balanceSnapshots)
          ..where((s) => s.deletedAt.isNull() &
              s.observedAt.isSmallerOrEqualValue(asOf))
          ..orderBy([(s) => OrderingTerm.asc(s.observedAt)]))
        .get();

    final latest = <String, BalanceSnapshot>{};
    for (final row in rows) {
      latest[row.accountId] = _toSnapshot(row); // ascending, so last wins
    }
    return latest.map((id, snap) => MapEntry(id, snap.amount));
  }

  Future<List<Account>> _withBalances(List<AccountRow> rows) async {
    if (rows.isEmpty) return const [];

    final snapshots = await (select(balanceSnapshots)
          ..where((s) => s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.observedAt)]))
        .get();

    final latest = <String, BalanceSnapshotRow>{};
    for (final snap in snapshots) {
      latest[snap.accountId] = snap; // ascending, so the last one wins
    }

    return rows.map((row) {
      final currency = CurrencyRegistry.tryOf(row.currencyCode);
      // A row with an unrecognised currency is corrupt. Skipping it silently
      // would hide money from the user, so fall back to a zero-decimal
      // placeholder and let it show up as obviously wrong instead.
      final resolved =
          currency ??
          Currency(
            code: row.currencyCode,
            decimalDigits: 2,
            englishName: row.currencyCode,
          );
      final snap = latest[row.id];
      return Account(
        id: row.id,
        name: row.name,
        institution: row.institution,
        currency: resolved,
        type: AccountType.decode(row.type),
        balance: snap == null
            ? Money.zero(resolved)
            : Money.fromMinorUnits(snap.amountMinor, resolved),
        colorArgb: row.colorArgb,
        notes: row.notes,
        isArchived: row.isArchived,
        lastUpdatedAt: snap?.observedAt,
      );
    }).toList();
  }

  BalanceSnapshot _toSnapshot(BalanceSnapshotRow row) {
    final currency =
        CurrencyRegistry.tryOf(row.currencyCode) ??
        Currency(
          code: row.currencyCode,
          decimalDigits: 2,
          englishName: row.currencyCode,
        );
    return BalanceSnapshot(
      id: row.id,
      accountId: row.accountId,
      amount: Money.fromMinorUnits(row.amountMinor, currency),
      observedAt: row.observedAt,
      source: SnapshotSource.decode(row.source),
    );
  }
}
