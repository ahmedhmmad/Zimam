import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/captured_notification.dart';
import '../domain/notification_parser.dart';

part 'capture_dao.g.dart';

/// A suggestion as stored, joined back into domain types.
final class StoredSuggestion {
  const StoredSuggestion({
    required this.id,
    required this.parsed,
    required this.packageName,
    required this.rawTitle,
    required this.rawBody,
  });

  final String id;
  final ParsedNotification parsed;
  final String packageName;

  /// Kept so the user can see what a figure was derived from before accepting
  /// it — a number with no provenance is one you cannot check.
  final String rawTitle;
  final String rawBody;
}

@DriftAccessor(tables: [PendingSuggestions, UnparsedSamples])
class CaptureDao extends DatabaseAccessor<AppDatabase> with _$CaptureDaoMixin {
  CaptureDao(super.db);

  /// How many unmatched samples to keep.
  ///
  /// Capped because this is third-party text about someone's money. Keeping an
  /// unbounded log of it would be indefensible however local it stays, and a
  /// handful is as diagnostic as a thousand.
  static const int sampleRetentionLimit = 50;

  Stream<List<StoredSuggestion>> watchPending() {
    final query = select(pendingSuggestions)
      ..where((s) => s.resolvedAt.isNull() & s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.desc(s.postedAt)]);
    return query.watch().map((rows) => rows.map(_toSuggestion).toList());
  }

  Future<void> addSuggestion({
    required String id,
    required ParsedNotification parsed,
    required String packageName,
    required String rawTitle,
    required String rawBody,
  }) async {
    final now = DateTime.now().toUtc();
    await into(pendingSuggestions).insert(
      PendingSuggestionsCompanion.insert(
        id: id,
        ruleId: parsed.ruleId,
        packageName: packageName,
        amountMinor: parsed.amount.minorUnits,
        currencyCode: parsed.amount.currency.code,
        direction: parsed.direction.name,
        balanceMinor: Value(parsed.balanceAfter?.minorUnits),
        merchant: Value(parsed.merchant),
        postedAt: parsed.postedAt,
        rawTitle: Value(rawTitle),
        rawBody: Value(rawBody),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Marks a suggestion resolved. Kept rather than deleted so the same
  /// notification is not offered twice.
  Future<void> resolve(
    String id, {
    required bool confirmed,
    String? accountId,
  }) async {
    final now = DateTime.now().toUtc();
    await (update(pendingSuggestions)..where((s) => s.id.equals(id))).write(
      PendingSuggestionsCompanion(
        resolvedAt: Value(now),
        resolution: Value(confirmed ? 'confirmed' : 'rejected'),
        accountId: Value(accountId),
        updatedAt: Value(now),
      ),
    );
  }

  Stream<List<UnparsedSampleRow>> watchSamples() {
    final query = select(unparsedSamples)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.desc(s.postedAt)]);
    return query.watch();
  }

  Future<void> addSample({
    required String id,
    required CapturedNotification notification,
  }) async {
    final now = DateTime.now().toUtc();
    await into(unparsedSamples).insert(
      UnparsedSamplesCompanion.insert(
        id: id,
        packageName: notification.packageName,
        title: Value(notification.title),
        body: Value(notification.body),
        postedAt: notification.postedAt,
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _trimSamples();
  }

  Future<void> markSampleShared(String id) async {
    final now = DateTime.now().toUtc();
    await (update(unparsedSamples)..where((s) => s.id.equals(id))).write(
      UnparsedSamplesCompanion(
        sharedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteSample(String id) async {
    await (delete(unparsedSamples)..where((s) => s.id.equals(id))).go();
  }

  /// Removes everything captured. Called by Phase 6's delete-all path, and
  /// whenever the user revokes notification access — holding on to captured
  /// text after being told to stop would be indefensible.
  Future<void> deleteAllCaptured() async {
    await delete(pendingSuggestions).go();
    await delete(unparsedSamples).go();
  }

  Future<void> _trimSamples() async {
    final rows = await (select(unparsedSamples)
          ..orderBy([(s) => OrderingTerm.desc(s.postedAt)]))
        .get();
    if (rows.length <= sampleRetentionLimit) return;

    for (final row in rows.skip(sampleRetentionLimit)) {
      await (delete(unparsedSamples)..where((s) => s.id.equals(row.id))).go();
    }
  }

  StoredSuggestion _toSuggestion(PendingSuggestionRow row) {
    final currency =
        CurrencyRegistry.tryOf(row.currencyCode) ??
        Currency(code: row.currencyCode, decimalDigits: 2, englishName: row.currencyCode);

    return StoredSuggestion(
      id: row.id,
      packageName: row.packageName,
      rawTitle: row.rawTitle,
      rawBody: row.rawBody,
      parsed: ParsedNotification(
        ruleId: row.ruleId,
        amount: Money.fromMinorUnits(row.amountMinor, currency),
        direction:
            TransactionDirection.decode(row.direction) ??
            TransactionDirection.debit,
        postedAt: row.postedAt,
        balanceAfter: row.balanceMinor == null
            ? null
            : Money.fromMinorUnits(row.balanceMinor!, currency),
        merchant: row.merchant,
      ),
    );
  }
}
