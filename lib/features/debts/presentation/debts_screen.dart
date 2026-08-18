import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/enums.dart';
import '../../../core/money/money.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/destination_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/l10n.dart';
import '../application/debts_providers.dart';
import '../domain/debt.dart';
import '../domain/debt_cost.dart';

/// The debt ledger: net position, then what is owed each way.
class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final debts = ref.watch(debtsProvider);

    return DestinationScaffold(
      title: l10n.debtsTitle,
      floatingActionButton: (debts.value?.isEmpty ?? true)
          ? null
          : FloatingActionButton(
              onPressed: () => context.push(AppRoutes.debtForm),
              tooltip: l10n.debtAdd,
              child: const Icon(Icons.add),
            ),
      child: debts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (all) {
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.swap_horiz_outlined,
              title: l10n.debtsEmptyTitle,
              body: l10n.debtsEmptyBody,
              actionLabel: l10n.debtsEmptyAction,
              onAction: () => context.push(AppRoutes.debtForm),
            );
          }
          return _DebtList(debts: all);
        },
      ),
    );
  }
}

class _DebtList extends ConsumerWidget {
  const _DebtList({required this.debts});

  final List<Debt> debts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final position = ref.watch(debtPositionProvider).value;

    final owed = debts
        .where((d) => d.direction == DebtDirection.iOwe && !d.isSettled)
        .toList();
    final owing = debts
        .where((d) => d.direction == DebtDirection.owedToMe && !d.isSettled)
        .toList();
    final settled = debts.where((d) => d.isSettled).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl * 2,
      ),
      children: [
        if (position != null) ...[
          Text(
            l10n.debtNetPosition,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Signed, because which way it points is the whole headline.
          MoneyText(
            position.net,
            emphasis: MoneyEmphasis.hero,
            signed: true,
            colorBySign: true,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _PositionCard(
                  label: l10n.debtIOwe,
                  amount: position.iOwe,
                  color: context.semantic.loss,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _PositionCard(
                  label: l10n.debtOwedToMe,
                  amount: position.owedToMe,
                  color: context.semantic.gain,
                ),
              ),
            ],
          ),
          if (!position.isComplete) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.debtsExcluded(position.unconvertible),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.semantic.alert,
              ),
            ),
          ],
        ],

        if (owed.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(l10n.debtIOwe),
          for (final debt in owed) _DebtRow(debt: debt),
        ],
        if (owing.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(l10n.debtOwedToMe),
          for (final debt in owing) _DebtRow(debt: debt),
        ],
        if (settled.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(l10n.debtSettled),
          for (final debt in settled) _DebtRow(debt: debt),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: Text(label, style: Theme.of(context).textTheme.titleLarge),
  );
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final Money amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xxs),
            MoneyText(amount, color: color),
          ],
        ),
      ),
    );
  }
}

/// One debt, with its drift chip.
class _DebtRow extends ConsumerWidget {
  const _DebtRow({required this.debt});

  final Debt debt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cost = ref.watch(debtCostProvider(debt.id)).value;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        title: Text(debt.counterparty),
        subtitle: Text(
          _formatDate(debt.createdOn),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MoneyText(debt.outstanding),
            if (cost != null && cost.hasDrift)
              _DriftChip(cost: cost, direction: debt.direction),
          ],
        ),
        onTap: () => context.push('${AppRoutes.debtDetail}?id=${debt.id}'),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

/// How much the rate has moved, coloured by what that means for this side of
/// the debt — not merely by whether the number went up.
class _DriftChip extends StatelessWidget {
  const _DriftChip({required this.cost, required this.direction});

  final DebtCost cost;
  final DebtDirection direction;

  @override
  Widget build(BuildContext context) {
    final worse = cost.isWorseFor(direction);
    final semantic = context.semantic;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: worse ? semantic.lossContainer : semantic.gainContainer,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: MoneyText(
          cost.totalDrift,
          emphasis: MoneyEmphasis.secondary,
          signed: true,
          showCode: false,
          color: worse ? semantic.onLossContainer : semantic.onGainContainer,
        ),
      ),
    );
  }
}
