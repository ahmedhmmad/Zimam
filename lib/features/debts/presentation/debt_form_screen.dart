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

/// Records a new debt, freezing the rate at the moment of confirmation.
class DebtFormScreen extends ConsumerStatefulWidget {
  const DebtFormScreen({super.key});

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
  String? _rateError;

  @override
  void dispose() {
    _counterparty.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final currency = _currency;
    if (currency == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
          principal: Money.parse(_amount.text.trim(), currency),
          homeCurrency: home,
          rateAtCreation: rate,
          createdOn: _createdOn,
          dueOn: _dueOn,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.debtAdd)),
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
              decoration: InputDecoration(labelText: l10n.debtCurrency),
              child: InkWell(
                onTap: () async {
                  final picked = await CurrencyPicker.show(
                    context,
                    selected: _currency,
                  );
                  if (picked != null) setState(() => _currency = picked);
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
                    const Icon(Icons.arrow_drop_down),
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
  });

  final String label;
  final DateTime? value;
  final String? placeholder;
  final ValueChanged<DateTime> onPick;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: InkWell(
        onTap: () async {
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
            const Icon(Icons.event),
          ],
        ),
      ),
    );
  }
}
