import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/currency.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/destination_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/l10n.dart';
import '../application/accounts_providers.dart';
import '../domain/account.dart';
import 'account_type_label.dart';
import 'update_balance_sheet.dart';

/// Accounts grouped by currency.
///
/// Grouping by currency rather than by institution is the point: this app is
/// for people whose money is scattered, and what they need to see is how much
/// sits in each currency before they see which bank holds it.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final accounts = ref.watch(accountsProvider);

    return DestinationScaffold(
      title: l10n.accountsTitle,
      floatingActionButton: accounts.value?.isEmpty ?? true
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutes.accountForm),
              tooltip: l10n.accountAdd,
              child: const Icon(Icons.add),
            ),
      child: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (all) {
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.list_alt_outlined,
              title: l10n.accountsEmptyTitle,
              body: l10n.accountsEmptyBody,
              actionLabel: l10n.accountsEmptyAction,
              onAction: () => context.push(AppRoutes.accountForm),
            );
          }
          return _AccountList(accounts: all);
        },
      ),
    );
  }
}

class _AccountList extends StatelessWidget {
  const _AccountList({required this.accounts});

  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final grouped = <Currency, List<Account>>{};
    for (final account in accounts.where((a) => !a.isArchived)) {
      grouped.putIfAbsent(account.currency, () => []).add(account);
    }
    final archived = accounts.where((a) => a.isArchived).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xl * 2,
      ),
      children: [
        for (final entry in grouped.entries) ...[
          _GroupHeader(currency: entry.key, accounts: entry.value),
          const SizedBox(height: AppSpacing.xs),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < entry.value.length; i++) ...[
                  if (i > 0) const Divider(indent: AppSpacing.sm),
                  _AccountRow(account: entry.value[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (archived.isNotEmpty) ...[
          Text(
            context.l10n.accountArchived,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < archived.length; i++) ...[
                  if (i > 0) const Divider(indent: AppSpacing.sm),
                  _AccountRow(account: archived[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.currency, required this.accounts});

  final Currency currency;
  final List<Account> accounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = Money.sum(accounts.map((a) => a.balance), currency);

    return Row(
      children: [
        Expanded(
          child: Text(currency.code, style: theme.textTheme.titleLarge),
        ),
        MoneyText(
          subtotal,
          emphasis: MoneyEmphasis.secondary,
          showCode: false,
        ),
      ],
    );
  }
}

class _AccountRow extends ConsumerWidget {
  const _AccountRow({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final home = ref.watch(homeCurrencyProvider).value;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      title: Text(account.name),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              account.institution ?? accountTypeLabel(l10n, account.type),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          _Staleness(account: account),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(account.balance, showCode: false),
          if (home != null && home != account.currency)
            _HomeEquivalent(amount: account.balance, home: home),
        ],
      ),
      onTap: () => UpdateBalanceSheet.show(context, account: account),
    );
  }
}

/// The same balance in the home currency, under the native figure.
///
/// Shown only when the currencies differ — repeating an identical number would
/// be noise, and this app already asks the reader to hold two figures in mind.
class _HomeEquivalent extends ConsumerWidget {
  const _HomeEquivalent({required this.amount, required this.home});

  final Money amount;
  final Currency home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fx = ref.watch(fxServiceProvider);
    return FutureBuilder(
      future: fx.convert(amount, home),
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result == null || !result.isAvailable) {
          return Text(
            '≈ —',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '≈ ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            MoneyText(result.amount!, emphasis: MoneyEmphasis.secondary),
          ],
        );
      },
    );
  }
}

/// A quiet marker on balances that have not been touched in a while.
///
/// Uses the attention colour, never the loss colour: an out-of-date balance is
/// a housekeeping nudge, not money lost.
class _Staleness extends StatelessWidget {
  const _Staleness({required this.account});

  final Account account;

  static const _staleAfter = Duration(days: 60);

  @override
  Widget build(BuildContext context) {
    final age = account.ageFrom(DateTime.now().toUtc());
    if (age == null || age < _staleAfter) return const SizedBox.shrink();

    final semantic = context.semantic;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
      child: Text(
        context.l10n.accountLastUpdated(age.inDays),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: semantic.alert),
      ),
    );
  }
}
