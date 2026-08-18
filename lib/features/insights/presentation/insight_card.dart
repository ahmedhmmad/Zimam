import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/money_formatter.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../application/insights_providers.dart';
import '../domain/insight.dart';

/// One insight, as a dismissible card.
///
/// Every card says the same three things in the same order: the fact, the
/// amount behind it, and one thing you could do. No card ranks, scolds, or
/// recommends — "68% of your wealth is in one currency" is an observation the
/// user may not have made; "you should diversify" would be advice this app is
/// in no position to give.
class InsightCard extends ConsumerWidget {
  const InsightCard({required this.insight, super.key});

  final Insight insight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final money = ref.watch(moneyFormatterProvider(locale));

    final content = _describe(insight.details, l10n, money);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    content.title,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                // A dismissal is a small, reversible act, so it gets a small
                // control rather than a confirmation dialog.
                IconButton(
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.insightDismiss,
                  onPressed: () =>
                      ref.read(insightDismisserProvider)(insight.signature),
                ),
              ],
            ),
            Text(
              content.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton(
                onPressed: () => _act(context),
                child: Text(content.action),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Every action leads somewhere the user can actually do the thing.
  void _act(BuildContext context) {
    switch (insight.kind) {
      case InsightKind.fxDrift:
      case InsightKind.concentration:
        // Both are about composition, which lives further down this screen.
        break;
      case InsightKind.scatteredBalances:
      case InsightKind.dormancy:
        context.go(AppRoutes.accounts);
    }
  }

  _CardContent _describe(
    InsightDetails details,
    AppL10n l10n,
    MoneyFormatter money,
  ) => switch (details) {
    FxDriftDetails(:final change, :final days, :final isLoss) => _CardContent(
      title: isLoss
          ? l10n.insightFxDriftTitleLoss
          : l10n.insightFxDriftTitleGain,
      body: l10n.insightFxDriftBody(money.formatSigned(change), days),
      action: l10n.insightFxDriftAction,
    ),
    ConcentrationDetails(:final currency, :final share, :final amount) =>
      _CardContent(
        title: l10n.insightConcentrationTitle(money.formatShare(share)),
        body: l10n.insightConcentrationBody(
          money.format(amount),
          currency.code,
        ),
        action: l10n.insightConcentrationAction,
      ),
    ScatteredDetails(
      :final total,
      :final accountCount,
      :final institutionCount,
      :final threshold,
    ) =>
      _CardContent(
        title: l10n.insightScatteredTitle(accountCount, institutionCount),
        body: l10n.insightScatteredBody(
          money.format(total),
          money.format(threshold),
        ),
        action: l10n.insightScatteredAction,
      ),
    DormancyDetails(:final accountCount, :final oldestDays, :final total) =>
      _CardContent(
        title: l10n.insightDormancyTitle(accountCount, oldestDays),
        body: l10n.insightDormancyBody(money.format(total)),
        action: l10n.insightDormancyAction,
      ),
  };
}

final class _CardContent {
  const _CardContent({
    required this.title,
    required this.body,
    required this.action,
  });

  final String title;
  final String body;
  final String action;
}
