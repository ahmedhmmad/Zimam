import 'package:drift/drift.dart';

/// Columns every table carries.
///
/// Deletes are soft throughout. There is no server-side copy of any of this —
/// if a row is gone from this device it is gone from the world — so a mistap
/// on "delete account" must be recoverable. Every query filters
/// `deletedAt IS NULL`; Phase 6's "delete all my data" is what actually
/// removes rows.
mixin _Timestamps on Table {
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Where money sits: a bank, a wallet, cash under the mattress.
///
/// Deliberately holds no balance. The balance is the most recent row in
/// [BalanceSnapshots], because "what is it now" and "what was it in March"
/// are the same question asked on different dates, and the FX-drift feature
/// needs both.
@DataClassName('AccountRow')
class Accounts extends Table with _Timestamps {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Bank or provider. Free text — the long tail of small institutions is
  /// exactly the audience here, so there is no closed list to pick from.
  TextColumn get institution => text().withLength(max: 120).nullable()();

  /// ISO 4217. The account's native currency, which never changes: if money
  /// moves to a different currency it is a different account.
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  /// Serialised [AccountType].
  TextColumn get type => text()();

  /// ARGB, for the user's own colour tag. Note this is *not* the categorical
  /// ramp — that is assigned by share at render time.
  IntColumn get colorArgb => integer().nullable()();

  TextColumn get notes => text().nullable()();

  /// Archived accounts stay in history and drop out of net worth. Distinct
  /// from [deletedAt]: archiving is a normal act, deleting is a correction.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// An observation of an account's balance at a point in time.
///
/// Append-only. Correcting a balance writes a new row rather than editing an
/// old one, because the history is the feature: comparing two snapshots gives
/// the change the user caused, while re-converting one snapshot at two
/// different rates gives the change the market caused. Editing in place would
/// destroy the ability to tell those apart.
@DataClassName('BalanceSnapshotRow')
class BalanceSnapshots extends Table with _Timestamps {
  TextColumn get id => text()();

  TextColumn get accountId =>
      text().references(Accounts, #id, onDelete: KeyAction.cascade)();

  /// Minor units, scaled by [currencyCode]'s ISO 4217 exponent. Never a real
  /// number — see `lib/core/money/money.dart`.
  IntColumn get amountMinor => integer()();

  /// Denormalised from the account on purpose: an account's currency must
  /// never silently reinterpret past snapshots, so each row records the
  /// currency its own integer was scaled by.
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  DateTimeColumn get observedAt => dateTime()();

  /// Serialised [SnapshotSource] — whether the user typed this or a
  /// notification suggested it. Phase 5 needs to tell them apart.
  TextColumn get source => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// An obligation, in the currency it was actually incurred in.
@DataClassName('DebtRow')
class Debts extends Table with _Timestamps {
  TextColumn get id => text()();

  TextColumn get counterparty => text().withLength(min: 1, max: 120)();

  /// Serialised [DebtDirection].
  TextColumn get direction => text()();

  IntColumn get principalMinor => integer()();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  /// The home currency *at the time the debt was created*, not today's. If the
  /// user later changes their home currency, this debt's original cost must
  /// still mean what it meant when it was recorded.
  TextColumn get homeCurrencyCode => text().withLength(min: 3, max: 3)();

  /// The rate from [currencyCode] to [homeCurrencyCode] on [createdOn],
  /// scaled by `FxRate.scaleFactor`.
  ///
  /// Written once and never updated. This single column is the whole
  /// repayment-drift feature: without a frozen historical rate there is
  /// nothing to compare today's cost against.
  IntColumn get rateAtCreationScaled => integer()();

  DateTimeColumn get createdOn => dateTime()();
  DateTimeColumn get dueOn => dateTime().nullable()();
  DateTimeColumn get settledAt => dateTime().nullable()();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A payment against a debt, carrying its own rate for the same reason the
/// debt carries one: paying in instalments across a moving rate is precisely
/// the cost the app exists to show.
@DataClassName('DebtPaymentRow')
class DebtPayments extends Table with _Timestamps {
  TextColumn get id => text()();

  TextColumn get debtId =>
      text().references(Debts, #id, onDelete: KeyAction.cascade)();

  IntColumn get amountMinor => integer()();
  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  DateTimeColumn get paidOn => dateTime()();

  /// Rate to the debt's home currency on [paidOn], scaled. Frozen like the
  /// debt's own rate.
  IntColumn get rateAtPaymentScaled => integer()();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One exchange rate for one currency pair on one day.
///
/// The cache that makes the app work offline. Rates are stored per day rather
/// than per fetch: an FX rate is a fact about a date, and asking "what was
/// this worth in March" must return March's answer, not the newest one.
///
/// The generated row class is named `CachedFxRate` so it cannot be confused
/// with the domain type `FxRate` — the row is storage, the domain type is
/// what does the arithmetic.
@DataClassName('CachedFxRate')
class FxRates extends Table with _Timestamps {
  TextColumn get baseCode => text().withLength(min: 3, max: 3)();
  TextColumn get quoteCode => text().withLength(min: 3, max: 3)();

  /// Rate × 10^8, as an integer. A rate is a ratio, and storing it as a double
  /// would reintroduce exactly the drift that integer money is there to avoid.
  IntColumn get rateScaled => integer()();

  /// The day the rate is *for*, at UTC midnight.
  DateTimeColumn get rateDate => dateTime()();

  /// When it was retrieved. Distinct from [rateDate]: a rate for the 3rd
  /// fetched on the 5th is two days stale, and the UI says so.
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {baseCode, quoteCode, rateDate};
}

/// Key/value store for app settings. Home currency, digit style, the
/// scattered-balance threshold, dismissed insight ids.
///
/// Deliberately untyped: settings are few, read rarely, and a table per
/// setting would be worse. Callers go through `SettingsDao`, which is typed.
class Settings extends Table with _Timestamps {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
