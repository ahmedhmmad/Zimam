import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/enums.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/l10n.dart';
import '../application/debts_providers.dart';
import '../domain/debt.dart';
import '../domain/debt_cost.dart';
import 'record_payment_sheet.dart';

/// One debt: what it cost when recorded, what it costs now, and why.
class DebtDetailScreen extends ConsumerWidget {
  const DebtDetailScreen({required this.debtId, super.key});

  final String debtId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final debt = ref.watch(debtByIdProvider(debtId)).value;

    if (debt == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }

    final cost = ref.watch(debtCostProvider(debtId)).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(debt.counterparty),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.debtEdit,
            onPressed: () =>
                context.push('${AppRoutes.debtForm}?id=${debt.id}'),
          ),
          IconButton(
            icon: Icon(
              debt.isSettled ? Icons.undo : Icons.check_circle_outline,
            ),
            tooltip: debt.isSettled ? l10n.debtReopen : l10n.debtMarkSettled,
            onPressed: () => ref
                .read(debtsDaoProvider)
                .setSettled(debt.id, settled: !debt.isSettled),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl * 2,
        ),
        children: [
          // The two figures side by side — the comparison is the point, so
          // they are given equal weight rather than one being subordinate.
          if (cost != null) ...[
            _CostCard(
              label: l10n.debtCostWhenBorrowed,
              amount: cost.costAtOriginalRate,
              emphasised: false,
            ),
            const SizedBox(height: AppSpacing.xs),
            _CostCard(
              label: l10n.debtCostToday,
              amount: cost.costAtTodaysRate,
              emphasised: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _DriftExplanation(cost: cost, direction: debt.direction),
          ] else
            _RateMissing(code: debt.currency.code),

          const SizedBox(height: AppSpacing.lg),
          _Summary(debt: debt, cost: cost),

          const SizedBox(height: AppSpacing.lg),
          Text(l10n.debtPaymentHistory, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          if (debt.payments.isEmpty)
            Text(
              l10n.debtPaymentNone,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < debt.payments.length; i++) ...[
                    if (i > 0) const Divider(indent: AppSpacing.sm),
                    _PaymentRow(payment: debt.payments[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: debt.isSettled
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: FilledButton.icon(
                  onPressed: () =>
                      RecordPaymentSheet.show(context, debt: debt),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.debtRecordPayment),
                ),
              ),
            ),
    );
  }
}

class _CostCard extends StatelessWidget {
  const _CostCard({
    required this.label,
    required this.amount,
    required this.emphasised,
  });

  final String label;
  final Money amount;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // Tonal difference rather than a border: today's figure sits one step
      // forward without shouting.
      color: emphasised
          ? theme.colorScheme.surfaceContainerHigh
          : theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            MoneyText(amount, emphasis: MoneyEmphasis.title),
          ],
        ),
      ),
    );
  }
}

/// The sentence that makes the two figures mean something.
class _DriftExplanation extends ConsumerWidget {
  const _DriftExplanation({required this.cost, required this.direction});

  final DebtCost cost;
  final DebtDirection direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final semantic = context.semantic;

    if (!cost.hasDrift) {
      return Text(l10n.debtDriftNone, style: theme.textTheme.bodyLarge);
    }

    final worse = cost.isWorseFor(direction);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = ref.watch(moneyFormatterProvider(locale));
    final magnitude = money.format(cost.totalDrift.abs());

    // Phrased as what it costs, not as a verdict. The app reports the
    // arithmetic; it does not tell anyone they made a bad decision.
    final sentence = cost.totalDrift.isPositive == (direction == DebtDirection.iOwe)
        ? l10n.debtDriftCostlier(magnitude)
        : l10n.debtDriftCheaper(magnitude);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(
            color: worse ? semantic.loss : semantic.gain,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sentence, style: theme.textTheme.bodyLarge),
          if (!cost.realisedDrift.isZero) ...[
            const SizedBox(height: AppSpacing.xs),
            _DriftLine(
              label: l10n.debtDriftRealised,
              amount: cost.realisedDrift,
            ),
            _DriftLine(
              label: l10n.debtDriftUnrealised,
              amount: cost.unrealisedDrift,
            ),
          ],
        ],
      ),
    );
  }
}

class _DriftLine extends StatelessWidget {
  const _DriftLine({required this.label, required this.amount});

  final String label;
  final Money amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          MoneyText(
            amount,
            emphasis: MoneyEmphasis.secondary,
            signed: true,
            showCode: false,
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.debt, required this.cost});

  final Debt debt;
  final DebtCost? cost;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            _SummaryRow(label: l10n.debtAmount, amount: debt.principal),
            const Divider(),
            _SummaryRow(label: l10n.debtPaidSoFar, amount: debt.paid),
            const Divider(),
            _SummaryRow(
              label: l10n.debtOutstanding,
              amount: debt.outstanding,
              emphasised: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.emphasised = false,
  });

  final String label;
  final Money amount;
  final bool emphasised;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        MoneyText(
          amount,
          emphasis: emphasised ? MoneyEmphasis.title : MoneyEmphasis.body,
        ),
      ],
    ),
  );
}

class _PaymentRow extends ConsumerWidget {
  const _PaymentRow({required this.payment});

  final DebtPayment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      title: Text(
        '${payment.paidOn.day.toString().padLeft(2, '0')}/'
        '${payment.paidOn.month.toString().padLeft(2, '0')}/'
        '${payment.paidOn.year}',
      ),
      // The rate is shown per payment, because that is the number that makes
      // one instalment cost more than another.
      subtitle: Text(
        l10n.debtPaymentRate(payment.rateAtPayment.asDecimalString),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MoneyText(payment.amount, showCode: false),
          MoneyText(
            payment.costInHomeCurrency,
            emphasis: MoneyEmphasis.secondary,
          ),
        ],
      ),
    );
  }
}

class _RateMissing extends StatelessWidget {
  const _RateMissing({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: semantic.alertContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Text(
        context.l10n.debtRateUnavailable(code),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: semantic.onAlertContainer),
      ),
    );
  }
}
