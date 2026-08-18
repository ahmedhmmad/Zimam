import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/enums.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../../accounts/presentation/currency_picker.dart';
import '../application/debts_providers.dart';
import '../domain/debt.dart';

/// Records a new debt, or amends an existing one.
///
/// On creation the rate is frozen at the moment of confirmation. On edit that
/// rate is left untouched and the two fields it depends on are locked.
///
/// The rate is a ratio for one currency pair on one day, so it stays correct
/// when the *principal* is corrected — 2,500 dollars at last March's rate is
/// still a meaningful figure. It stops being meaningful the moment either end
/// of the pair moves: a different currency leaves the rate's base pointing at
/// a currency the debt no longer uses, and a different date leaves it
/// belonging to a day it was not observed on, which cannot be re-derived
/// because historical rates are not cached.
class DebtFormScreen extends ConsumerStatefulWidget {
  const DebtFormScreen({this.debtId, super.key});

  final String? debtId;

  bool get isEditing => debtId != null;

  @override
  ConsumerState<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends ConsumerState<DebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _counterparty = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  Currency? _currency;
  DebtDirection _direction = DebtDirection.iOwe;
  DateTime _createdOn = DateTime.now().toUtc();
  DateTime? _dueOn;
  bool _saving = false;
  bool _loaded = false;
  String? _rateError;

  @override
  void dispose() {
    _counterparty.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _hydrate(Debt debt) {
    if (_loaded) return;
    _loaded = true;
    _counterparty.text = debt.counterparty;
    _amount.text = _plainAmount(debt.principal);
    _notes.text = debt.notes ?? '';
    _currency = debt.currency;
    _direction = debt.direction;
    _createdOn = debt.createdOn;
    _dueOn = debt.dueOn;
  }

  /// The principal as editable text, at the currency's own scale and with no
  /// grouping separators, so it parses straight back through [Money.parse].
  static String _plainAmount(Money amount) {
    final units = amount.minorUnits.abs();
    final currency = amount.currency;
    if (currency.decimalDigits == 0) return units.toString();
    final whole = units ~/ currency.minorUnitsPerMajor;
    final fraction = (units % currency.minorUnitsPerMajor)
        .toString()
        .padLeft(currency.decimalDigits, '0');
    return '$whole.$fraction';
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final currency = _currency;
    if (currency == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final principal = Money.parse(_amount.text.trim(), currency);
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();

    // Amending leaves the frozen rate alone. It is the historical fact the
    // drift comparison rests on, and today's rate is not a substitute for it.
    if (widget.isEditing) {
      setState(() => _saving = true);
      await ref
          .read(debtsDaoProvider)
          .updateDetails(
            id: widget.debtId!,
            counterparty: _counterparty.text.trim(),
            direction: _direction,
            principal: principal,
            dueOn: _dueOn,
            notes: notes,
          );
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    final home = ref.read(homeCurrencyProvider).value;
    if (home == null) return;

    final rate = await ref.read(todaysRateProvider(currency).future);
    if (rate == null) {
      // The frozen rate is the whole feature. Recording a debt without one
      // would leave it permanently unable to show drift, and today's rate
      // cannot be recovered later.
      setState(() => _rateError = l10n.debtRateUnavailable(currency.code));
      return;
    }

    setState(() {
      _saving = true;
      _rateError = null;
    });

    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    await ref
        .read(debtsDaoProvider)
        .create(
          id: 'debt_$stamp',
          counterparty: _counterparty.text.trim(),
          direction: _direction,
          principal: principal,
          homeCurrency: home,
          rateAtCreation: rate,
          createdOn: _createdOn,
          dueOn: _dueOn,
          notes: notes,
        );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locked = widget.isEditing;

    if (locked) {
      final debt = ref.watch(debtByIdProvider(widget.debtId!)).value;
      if (debt != null) _hydrate(debt);
    }

    return Scaffold(
      appBar: AppBar(title: Text(locked ? l10n.debtEdit : l10n.debtAdd)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SegmentedButton<DebtDirection>(
              segments: [
                ButtonSegment(
                  value: DebtDirection.iOwe,
                  label: Text(l10n.debtIOwe),
                ),
                ButtonSegment(
                  value: DebtDirection.owedToMe,
                  label: Text(l10n.debtOwedToMe),
                ),
              ],
              selected: {_direction},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _direction = s.first),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _counterparty,
              decoration: InputDecoration(
                labelText: l10n.debtCounterparty,
                hintText: l10n.debtCounterpartyHint,
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.debtCurrency,
                enabled: !locked,
                helperText: locked ? l10n.debtLockedAfterCreation : null,
              ),
              child: InkWell(
                // The frozen rate's base is this currency, so changing it
                // would orphan the rate.
                onTap: locked
                    ? null
                    : () async {
                        final picked = await CurrencyPicker.show(
                          context,
                          selected: _currency,
                        );
                        if (picked != null) {
                          setState(() => _currency = picked);
                        }
                      },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currency == null
                            ? '—'
                            : '${_currency!.code} · ${_currency!.englishName}',
                      ),
                    ),
                    if (!locked) const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _amount,
              decoration: InputDecoration(
                labelText: l10n.debtAmount,
                suffixText: _currency?.code,
                errorText: _rateError,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                final currency = _currency;
                if (currency == null) return l10n.validationRequired;
                try {
                  final parsed = Money.parse(v.trim(), currency);
                  return parsed.isPositive ? null : l10n.validationAmount;
                } on FormatException {
                  return l10n.validationAmount;
                }
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            _DateField(
              label: l10n.debtDateBorrowed,
              value: _createdOn,
              // Locked for the same reason as the currency: the frozen rate
              // belongs to this day and cannot be re-derived for another.
              enabled: !locked,
              helper: locked ? l10n.debtLockedAfterCreation : null,
              onPick: (d) => setState(() => _createdOn = d),
              firstDate: DateTime.utc(2000),
              lastDate: DateTime.now().toUtc(),
            ),
            const SizedBox(height: AppSpacing.sm),

            _DateField(
              label: l10n.debtDueDate,
              value: _dueOn,
              placeholder: l10n.debtDueDateNone,
              onPick: (d) => setState(() => _dueOn = d),
              firstDate: _createdOn,
              lastDate: DateTime.utc(2100),
            ),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _notes,
              decoration: InputDecoration(labelText: l10n.debtNotes),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),

            FilledButton(
              onPressed: _saving || _currency == null ? null : _save,
              child: Text(l10n.debtSave),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.firstDate,
    required this.lastDate,
    this.placeholder,
    this.enabled = true,
    this.helper,
  });

  final String label;
  final DateTime? value;
  final String? placeholder;
  final ValueChanged<DateTime> onPick;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool enabled;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        enabled: enabled,
        helperText: helper,
      ),
      child: InkWell(
        onTap: !enabled
            ? null
            : () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime.now().toUtc(),
                  firstDate: firstDate,
                  lastDate: lastDate,
                );
                if (picked != null) onPick(picked);
              },
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? (placeholder ?? '—')
                    : '${value!.day.toString().padLeft(2, '0')}/'
                          '${value!.month.toString().padLeft(2, '0')}/'
                          '${value!.year}',
              ),
            ),
            if (enabled) const Icon(Icons.event),
          ],
        ),
      ),
    );
  }
}
