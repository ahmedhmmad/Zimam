/// Enums stored as text in the database.
///
/// Stored by name rather than index so that reordering or inserting a value
/// cannot silently reinterpret existing rows — a hazard with no cloud copy to
/// repair from. [decode] falls back rather than throwing, because one
/// unrecognised value from a future version should not make a balance
/// unreadable.
library;

enum AccountType {
  bank,
  cash,
  wallet,
  card,
  investment,
  other;

  static AccountType decode(String value) => values.firstWhere(
    (t) => t.name == value,
    orElse: () => AccountType.other,
  );
}

/// Where a balance observation came from. Phase 5 needs to distinguish a
/// figure the user typed from one a notification suggested.
enum SnapshotSource {
  manual,
  notification;

  static SnapshotSource decode(String value) => values.firstWhere(
    (s) => s.name == value,
    orElse: () => SnapshotSource.manual,
  );
}

enum DebtDirection {
  /// The user owes someone.
  iOwe,

  /// Someone owes the user.
  owedToMe;

  static DebtDirection decode(String value) => values.firstWhere(
    (d) => d.name == value,
    orElse: () => DebtDirection.iOwe,
  );
}
