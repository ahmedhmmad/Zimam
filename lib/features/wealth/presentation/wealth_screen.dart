import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/destination_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/l10n.dart';
import '../application/wealth_providers.dart';
import '../domain/net_worth.dart';
import 'composition_bar.dart';

/// The home screen: one dominant figure, then what it is made of, then what
/// moved it.
class WealthScreen extends ConsumerWidget {
  const WealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final netWorth = ref.watch(netWorthProvider);

    return DestinationScaffold(
      title: l10n.wealthTitle,
      child: netWorth.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Message(text: error.toString()),
        data: (wealth) {
          if (wealth == null || wealth.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.wealthEmptyTitle,
              body: l10n.wealthEmptyBody,
              actionLabel: l10n.wealthEmptyAction,
              onAction: () => context.push(AppRoutes.accountForm),
            );
          }
          return _WealthBody(wealth: wealth);
        },
      ),
    );
  }
}

class _WealthBody extends ConsumerWidget {
  const _WealthBody({required this.wealth});

  final NetWorth wealth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = ref.watch(moneyFormatterProvider(locale));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(fxServiceProvider).refresh();
        ref.invalidate(netWorthProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          // ---- The one dominant figure -------------------------------------
          Text(
            l10n.netWorthLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          MoneyText(wealth.total, emphasis: MoneyEmphasis.hero),

          if (!wealth.isComplete) ...[
            const SizedBox(height: AppSpacing.xs),
            _Notice(
              icon: Icons.info_outline,
              text: l10n.accountsExcluded(wealth.accountsUnconvertible),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          if (wealth.change != null) _ChangeCard(change: wealth.change!),

          // ---- What it is made of ------------------------------------------
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.compositionTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          CompositionBar(holdings: wealth.holdings, total: wealth.total),
          const SizedBox(height: AppSpacing.sm),
          CompositionLegend(
            holdings: wealth.holdings,
            total: wealth.total,
            shareLabel: formatter.formatShare,
          ),
        ],
      ),
    );
  }
}

/// The two lines that are the whole point of the app.
class _ChangeCard extends StatelessWidget {
  const _ChangeCard({required this.change});

  final WealthChange change;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final days = DateTime.now().toUtc().difference(change.since).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Two separate rows, never summed into one number: "you spent
            // nothing and are still poorer" is the fact worth surfacing.
            _ChangeRow(
              label: l10n.changeFromActivity,
              amount: change.fromActivity,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(),
            ),
            _ChangeRow(
              label: l10n.changeFromRates,
              amount: change.fromExchangeRates,
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                l10n.changeWindow(days),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.label, required this.amount});

  final String label;
  final Money amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: AppSpacing.xs),
        MoneyText(amount, signed: true, colorBySign: true),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: semantic.alertContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: semantic.onAlertContainer),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: semantic.onAlertContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
