// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_dao.dart';

// ignore_for_file: type=lint
mixin _$CaptureDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $PendingSuggestionsTable get pendingSuggestions =>
      attachedDatabase.pendingSuggestions;
  $UnparsedSamplesTable get unparsedSamples => attachedDatabase.unparsedSamples;
  CaptureDaoManager get managers => CaptureDaoManager(this);
}

class CaptureDaoManager {
  final _$CaptureDaoMixin _db;
  CaptureDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$PendingSuggestionsTableTableManager get pendingSuggestions =>
      $$PendingSuggestionsTableTableManager(
        _db.attachedDatabase,
        _db.pendingSuggestions,
      );
  $$UnparsedSamplesTableTableManager get unparsedSamples =>
      $$UnparsedSamplesTableTableManager(
        _db.attachedDatabase,
        _db.unparsedSamples,
      );
}
