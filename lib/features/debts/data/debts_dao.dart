import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/enums.dart';
import '../../../core/database/tables.dart';
import '../../../core/fx/fx_rate.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../domain/debt.dart';

part 'debts_dao.g.dart';

/// Reads and writes debts and their payments.
@DriftAccessor(tables: [Debts, DebtPayments])
class DebtsDao extends DatabaseAccessor<AppDatabase> with _$DebtsDaoMixin {
  DebtsDao(super.db);

  Stream<List<Debt>> watchAll() {
    final query = select(debts)
      ..where((d) => d.deletedAt.isNull())
      ..orderBy([
        // Unsettled first, then oldest — the ones still costing something
        // belong at the top.
        (d) => OrderingTerm.asc(d.settledAt.isNotNull()),
        (d) => OrderingTerm.asc(d.createdOn),
      ]);
    return query.watch().asyncMap(_withPayments);
  }

  Future<List<Debt>> getAll() => watchAll().first;

  Future<Debt?> byId(String id) async {
    final row = await (select(debts)
          ..where((d) => d.id.equals(id) & d.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    return (await _withPayments([row])).single;
  }

  /// Records a debt, freezing the rate at creation.
  ///
  /// [rateAtCreation] is supplied by the caller rather than looked up here so
  /// that the DAO stays synchronous with respect to the network, and so the
  /// exact rate that was shown to the user at the moment they confirmed is
  /// the one that gets stored.
  Future<void> create({
    required String id,
    required String counterparty,
    required DebtDirection direction,
    required Money principal,
    required Currency homeCurrency,
    required FxRate rateAtCreation,
    required DateTime createdOn,
    DateTime? dueOn,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    await into(debts).insert(
      DebtsCompanion.insert(
        id: id,
        counterparty: counterparty,
        direction: direction.name,
        principalMinor: principal.minorUnits,
        currencyCode: principal.currency.code,
        homeCurrencyCode: homeCurrency.code,
        rateAtCreationScaled: rateAtCreation.rateScaled,
        createdOn: createdOn,
        dueOn: Value(dueOn),
        notes: Value(notes),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Records a payment with the rate on the day it was made.
  Future<void> addPayment({
    required String id,
    required String debtId,
    required Money amount,
    required FxRate rateAtPayment,
    required DateTime paidOn,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    await into(debtPayments).insert(
      DebtPaymentsCompanion.insert(
        id: id,
        debtId: debtId,
        amountMinor: amount.minorUnits,
        currencyCode: amount.currency.code,
        paidOn: paidOn,
        rateAtPaymentScaled: rateAtPayment.rateScaled,
        notes: Value(notes),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> setSettled(String id, {required bool settled}) async {
    await (update(debts)..where((d) => d.id.equals(id))).write(
      DebtsCompanion(
        settledAt: Value(settled ? DateTime.now().toUtc() : null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().toUtc();
    await (update(debts)..where((d) => d.id.equals(id))).write(
      DebtsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  Future<List<Debt>> _withPayments(List<DebtRow> rows) async {
    if (rows.isEmpty) return const [];

    final paymentRows = await (select(debtPayments)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.paidOn)]))
        .get();

    final byDebt = <String, List<DebtPaymentRow>>{};
    for (final row in paymentRows) {
      byDebt.putIfAbsent(row.debtId, () => []).add(row);
    }

    return rows.map((row) => _toDebt(row, byDebt[row.id] ?? const [])).toList();
  }

  Debt _toDebt(DebtRow row, List<DebtPaymentRow> paymentRows) {
    final currency = _resolve(row.currencyCode);
    final home = _resolve(row.homeCurrencyCode);

    FxRate rateFrom(int scaled, DateTime on) => FxRate(
      base: currency,
      quote: home,
      rateScaled: scaled,
      rateDate: on,
      fetchedAt: on,
    );

    return Debt(
      id: row.id,
      counterparty: row.counterparty,
      direction: DebtDirection.decode(row.direction),
      principal: Money.fromMinorUnits(row.principalMinor, currency),
      homeCurrency: home,
      rateAtCreation: rateFrom(row.rateAtCreationScaled, row.createdOn),
      createdOn: row.createdOn,
      dueOn: row.dueOn,
      settledAt: row.settledAt,
      notes: row.notes,
      payments: [
        for (final p in paymentRows)
          DebtPayment(
            id: p.id,
            debtId: p.debtId,
            amount: Money.fromMinorUnits(
              p.amountMinor,
              _resolve(p.currencyCode),
            ),
            paidOn: p.paidOn,
            rateAtPayment: rateFrom(p.rateAtPaymentScaled, p.paidOn),
            notes: p.notes,
          ),
      ],
    );
  }

  /// A stored code that is no longer in the registry means a corrupt row.
  /// Substituting a two-decimal placeholder keeps the debt visible and
  /// obviously wrong rather than making the whole screen fail to load.
  Currency _resolve(String code) =>
      CurrencyRegistry.tryOf(code) ??
      Currency(code: code, decimalDigits: 2, englishName: code);
}
