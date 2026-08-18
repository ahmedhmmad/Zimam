import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/enums.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../application/accounts_providers.dart';
import '../domain/account.dart';
import 'account_type_label.dart';
import 'currency_picker.dart';

/// Create or edit an account.
///
/// Currency is fixed after creation. Changing it would reinterpret every past
/// snapshot's stored integer at a different scale — 10.000 JOD silently
/// becoming 10.00 of something else — so editing offers no way to do it.
class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({this.accountId, super.key});

  final String? accountId;

  bool get isEditing => accountId != null;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _institution = TextEditingController();
  final _balance = TextEditingController();
  final _notes = TextEditingController();

  Currency? _currency;
  AccountType _type = AccountType.bank;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _institution.dispose();
    _balance.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _hydrate(Account account) {
    if (_loaded) return;
    _loaded = true;
    _name.text = account.name;
    _institution.text = account.institution ?? '';
    _notes.text = account.notes ?? '';
    _currency = account.currency;
    _type = account.type;
    // Balance is edited through its own action, not this form: a new balance
    // is a new observation, not a correction to the account's details.
  }

  Future<void> _save() async {
    final currency = _currency;
    if (currency == null) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final dao = ref.read(accountsDaoProvider);
    final stamp = DateTime.now().microsecondsSinceEpoch.toString();

    try {
      if (widget.isEditing) {
        await dao.updateDetails(
          id: widget.accountId!,
          name: _name.text.trim(),
          institution: _emptyToNull(_institution.text),
          type: _type,
          notes: _emptyToNull(_notes.text),
        );
      } else {
        await dao.create(
          id: 'acc_$stamp',
          snapshotId: 'snap_$stamp',
          name: _name.text.trim(),
          currency: currency,
          type: _type,
          openingBalance: Money.parse(_balance.text.trim(), currency),
          institution: _emptyToNull(_institution.text),
          notes: _emptyToNull(_notes.text),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.isEditing) {
      final account = ref.watch(accountByIdProvider(widget.accountId!)).value;
      if (account != null) _hydrate(account);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.accountEdit : l10n.accountAdd),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.accountName,
                hintText: l10n.accountNameHint,
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.validationRequired : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _institution,
              decoration: InputDecoration(
                labelText: l10n.accountInstitution,
                hintText: l10n.accountInstitutionHint,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.sm),

            _CurrencyField(
              currency: _currency,
              // Locked after creation, deliberately.
              enabled: !widget.isEditing,
              onPick: () async {
                final picked = await CurrencyPicker.show(
                  context,
                  selected: _currency,
                );
                if (picked != null) setState(() => _currency = picked);
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            _TypeField(
              value: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: AppSpacing.sm),

            if (!widget.isEditing)
              TextFormField(
                controller: _balance,
                decoration: InputDecoration(
                  labelText: l10n.accountBalance,
                  suffixText: _currency?.code,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) => _validateAmount(v, l10n),
              ),
            if (!widget.isEditing) const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _notes,
              decoration: InputDecoration(
                labelText: l10n.accountNotes,
                hintText: l10n.accountNotesHint,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),

            FilledButton(
              onPressed: _saving || _currency == null ? null : _save,
              child: Text(l10n.accountSave),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateAmount(String? value, AppL10n l10n) {
    if (value == null || value.trim().isEmpty) return l10n.validationRequired;
    final currency = _currency;
    if (currency == null) return l10n.validationRequired;
    try {
      // Parsing is the validation: it enforces the currency's decimal places,
      // so "1.005" in a two-place currency is rejected rather than rounded.
      Money.parse(value.trim(), currency);
      return null;
    } on FormatException {
      return l10n.validationAmount;
    }
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField({
    required this.currency,
    required this.enabled,
    required this.onPick,
  });

  final Currency? currency;
  final bool enabled;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.accountCurrency,
        enabled: enabled,
      ),
      child: InkWell(
        onTap: enabled ? onPick : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                currency == null
                    ? '—'
                    : '${currency!.code} · ${currency!.englishName}',
              ),
            ),
            if (enabled) const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class _TypeField extends StatelessWidget {
  const _TypeField({required this.value, required this.onChanged});

  final AccountType value;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.accountType),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final type in AccountType.values)
            ChoiceChip(
              label: Text(accountTypeLabel(l10n, type)),
              selected: type == value,
              onSelected: (_) => onChanged(type),
            ),
        ],
      ),
    );
  }
}
