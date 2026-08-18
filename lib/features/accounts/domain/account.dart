import '../../../core/database/enums.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';

/// An account and its current balance.
///
/// The balance is not stored on the account row — it is the most recent
/// [BalanceSnapshot]. This type is the joined view the UI works with, so
/// screens never have to know that.
final class Account {
  const Account({
    required this.id,
    required this.name,
    required this.currency,
    required this.type,
    required this.balance,
    this.institution,
    this.colorArgb,
    this.notes,
    this.isArchived = false,
    this.lastUpdatedAt,
  });

  final String id;
  final String name;

  /// Bank or provider. Free text: the long tail of small institutions is the
  /// audience here, so there is no closed list to choose from.
  final String? institution;

  /// The account's native currency. Fixed for the account's life — money in a
  /// different currency is a different account.
  final Currency currency;

  final AccountType type;

  /// The latest observed balance, in [currency]. Zero when the account has no
  /// snapshots yet, which only happens mid-creation.
  final Money balance;

  final int? colorArgb;
  final String? notes;

  /// Archived accounts keep their history and drop out of net worth.
  final bool isArchived;

  /// When the balance was last observed. Null means never — and the dormancy
  /// insight in Phase 3 reads this.
  final DateTime? lastUpdatedAt;

  /// How long since the balance was last touched, for staleness display.
  Duration? ageFrom(DateTime now) =>
      lastUpdatedAt == null ? null : now.difference(lastUpdatedAt!);

  Account copyWith({
    String? name,
    String? institution,
    Currency? currency,
    AccountType? type,
    Money? balance,
    int? colorArgb,
    String? notes,
    bool? isArchived,
    DateTime? lastUpdatedAt,
  }) => Account(
    id: id,
    name: name ?? this.name,
    institution: institution ?? this.institution,
    currency: currency ?? this.currency,
    type: type ?? this.type,
    balance: balance ?? this.balance,
    colorArgb: colorArgb ?? this.colorArgb,
    notes: notes ?? this.notes,
    isArchived: isArchived ?? this.isArchived,
    lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
  );

  @override
  bool operator ==(Object other) => other is Account && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Account($id, $name, $balance)';
}

/// A dated observation of an account's balance.
final class BalanceSnapshot {
  const BalanceSnapshot({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.observedAt,
    required this.source,
  });

  final String id;
  final String accountId;
  final Money amount;
  final DateTime observedAt;
  final SnapshotSource source;

  @override
  String toString() => 'BalanceSnapshot($accountId, $amount, $observedAt)';
}
