import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/money.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/l10n.dart';
import '../application/accounts_providers.dart';
import '../domain/account.dart';

/// Records a new balance for an account, and offers the other row actions.
///
/// Saving writes a *new snapshot* rather than editing the old one. That is
/// what lets the Wealth screen say how much of a change was the user moving
/// money versus the exchange rate moving — overwrite the history and the
/// distinction is gone.
class UpdateBalanceSheet extends ConsumerStatefulWidget {
  const UpdateBalanceSheet({required this.account, super.key});

  final Account account;

  static Future<void> show(BuildContext context, {required Account account}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => UpdateBalanceSheet(account: account),
      );

  @override
  ConsumerState<UpdateBalanceSheet> createState() => _UpdateBalanceSheetState();
}

class _UpdateBalanceSheetState extends ConsumerState<UpdateBalanceSheet> {
  late final _controller = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final text = _controller.text.trim();
    Money amount;
    try {
      amount = Money.parse(text, widget.account.currency);
    } on FormatException {
      setState(() => _error = l10n.validationAmount);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    await ref
        .read(accountsDaoProvider)
        .recordBalance(
          snapshotId: 'snap_$stamp',
          accountId: widget.account.id,
          amount: amount,
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = widget.account;

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
          Text(account.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          MoneyText(account.balance, emphasis: MoneyEmphasis.secondary),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.accountBalance,
              suffixText: account.currency.code,
              errorText: _error,
            ),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.md),

          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.accountUpdateBalance),
          ),
          const SizedBox(height: AppSpacing.xs),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('${AppRoutes.accountForm}?id=${account.id}');
                  },
                  child: Text(l10n.accountEdit),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(accountsDaoProvider)
                        .setArchived(
                          account.id,
                          archived: !account.isArchived,
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: Text(
                    account.isArchived
                        ? l10n.accountUnarchive
                        : l10n.accountArchive,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
