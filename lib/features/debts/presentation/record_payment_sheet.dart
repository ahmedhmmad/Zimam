import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/l10n.dart';
import '../application/debts_providers.dart';
import '../domain/debt.dart';

/// Records a partial or full payment.
///
/// The rate is captured at the moment of recording and frozen with the
/// payment, so an instalment always remembers what it actually cost rather
/// than being re-valued later at whatever the rate happens to be.
class RecordPaymentSheet extends ConsumerStatefulWidget {
  const RecordPaymentSheet({required this.debt, super.key});

  final Debt debt;

  static Future<void> show(BuildContext context, {required Debt debt}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => RecordPaymentSheet(debt: debt),
      );

  @override
  ConsumerState<RecordPaymentSheet> createState() =>
      _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  final _controller = TextEditingController();
  DateTime _paidOn = DateTime.now().toUtc();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final debt = widget.debt;

    Money amount;
    try {
      amount = Money.parse(_controller.text.trim(), debt.currency);
    } on FormatException {
      setState(() => _error = l10n.validationAmount);
      return;
    }
    if (!amount.isPositive) {
      setState(() => _error = l10n.validationAmount);
      return;
    }

    final rate = await ref.read(todaysRateProvider(debt.currency).future);
    if (rate == null) {
      // Without a rate the payment could be stored but its home-currency cost
      // would be unknowable forever, since the rate for that day is gone once
      // the day passes. Better to refuse than to record something incomplete.
      setState(() => _error = l10n.debtRateUnavailable(debt.currency.code));
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    await ref
        .read(debtsDaoProvider)
        .addPayment(
          id: 'pay_$stamp',
          debtId: debt.id,
          amount: amount,
          rateAtPayment: rate,
          paidOn: _paidOn,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final debt = widget.debt;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.debtRecordPayment,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('${l10n.debtOutstanding}: '),
              MoneyText(debt.outstanding, emphasis: MoneyEmphasis.secondary),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.debtPaymentAmount,
              suffixText: debt.currency.code,
              errorText: _error,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.sm),

          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _paidOn,
                firstDate: debt.createdOn,
                lastDate: DateTime.now().toUtc(),
              );
              if (picked != null) setState(() => _paidOn = picked);
            },
            icon: const Icon(Icons.event),
            label: Text(
              '${l10n.debtPaymentDate}: '
              '${_paidOn.day.toString().padLeft(2, '0')}/'
              '${_paidOn.month.toString().padLeft(2, '0')}/${_paidOn.year}',
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.debtSave),
          ),
        ],
      ),
    );
  }
}
