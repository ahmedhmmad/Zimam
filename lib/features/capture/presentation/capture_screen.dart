import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/enums.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/money_text.dart';
import '../../../l10n/l10n.dart';
import '../../accounts/application/accounts_providers.dart';
import '../../accounts/domain/account.dart';
import '../application/capture_providers.dart';
import '../data/capture_dao.dart';
import '../domain/captured_notification.dart';
import '../domain/redactor.dart';
import 'capture_disclosure_screen.dart';

/// Capture status, pending suggestions, and unrecognised samples.
///
/// Every state this screen can be in is a working state. Permission denied,
/// permission revoked mid-session, granted but unbound — each shows what is
/// true and leaves manual entry exactly as it was. Nothing here is a dead end.
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final granted = ref.watch(capturePermissionProvider).value ?? false;
    final connected = ref.watch(captureConnectedProvider).value ?? false;

    // Starts the listener while this screen is alive. Watched rather than
    // read so it is torn down with the screen.
    if (granted) ref.watch(captureListenerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.captureTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(capturePermissionProvider);
          ref.invalidate(captureConnectedProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _StatusCard(granted: granted, connected: connected),

            if (granted) ...[
              const SizedBox(height: AppSpacing.lg),
              _SuggestionsSection(),
              const SizedBox(height: AppSpacing.lg),
              _SamplesSection(),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends ConsumerWidget {
  const _StatusCard({required this.granted, required this.connected});

  final bool granted;
  final bool connected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              granted ? l10n.captureEnabledTitle : l10n.captureDisabledTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              granted ? l10n.captureEnabledBody : l10n.captureDisabledBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            // Granted but not bound. Worth saying plainly rather than showing
            // an "on" state that quietly produces nothing.
            if (granted && !connected) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.captureNotConnected,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.semantic.alert,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),
            if (!granted)
              FilledButton(
                // The disclosure always comes first. The app never opens
                // Android's permission screen directly.
                onPressed: () async {
                  await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const CaptureDisclosureScreen(),
                    ),
                  );
                  ref.invalidate(capturePermissionProvider);
                  ref.invalidate(captureConnectedProvider);
                },
                child: Text(l10n.captureTurnOn),
              )
            else
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(captureChannelProvider)
                      .openPermissionSettings();
                  ref.invalidate(capturePermissionProvider);
                },
                child: Text(l10n.captureTurnOff),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final suggestions = ref.watch(pendingSuggestionsProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.captureSuggestionsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        if (suggestions.isEmpty)
          Text(
            l10n.captureSuggestionsEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final suggestion in suggestions)
            _SuggestionCard(suggestion: suggestion),
      ],
    );
  }
}

class _SuggestionCard extends ConsumerWidget {
  const _SuggestionCard({required this.suggestion});

  final StoredSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final parsed = suggestion.parsed;
    final accounts = ref.watch(activeAccountsProvider).value ?? const [];

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.captureSuggestionFrom(suggestion.packageName),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                MoneyText(
                  parsed.signedAmount,
                  signed: true,
                  colorBySign: true,
                ),
              ],
            ),

            if (parsed.balanceAfter != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(child: Text(l10n.captureSuggestionBalance)),
                  MoneyText(parsed.balanceAfter!),
                ],
              ),
            ],

            // The original text, so the figure can be checked against what the
            // bank actually said before it is accepted.
            const SizedBox(height: AppSpacing.xs),
            Text(
              [suggestion.rawTitle, suggestion.rawBody]
                  .where((s) => s.isNotEmpty)
                  .join(' — '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(captureDaoProvider)
                        .resolve(suggestion.id, confirmed: false),
                    child: Text(l10n.captureReject),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: FilledButton(
                    // Only a reported balance can be written: it is an
                    // observation of the true figure. A transaction amount
                    // alone would have to be added to a balance the app has
                    // not seen, which is arithmetic on a guess.
                    onPressed: parsed.balanceAfter == null || accounts.isEmpty
                        ? null
                        : () => _confirm(context, ref, accounts),
                    child: Text(l10n.captureConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    List<Account> accounts,
  ) async {
    final l10n = context.l10n;
    final parsed = suggestion.parsed;

    // Only accounts in the same currency: a balance reported in dinars is not
    // an observation about a dollar account.
    final candidates = accounts
        .where((a) => a.currency == parsed.amount.currency)
        .toList();

    final account = await showModalBottomSheet<Account>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                l10n.captureChooseAccount,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            for (final account in candidates)
              ListTile(
                title: Text(account.name),
                subtitle: Text(account.currency.code),
                onTap: () => Navigator.of(sheetContext).pop(account),
              ),
          ],
        ),
      ),
    );
    if (account == null) return;

    final stamp = DateTime.now().microsecondsSinceEpoch.toString();
    await ref
        .read(accountsDaoProvider)
        .recordBalance(
          snapshotId: 'snap_$stamp',
          accountId: account.id,
          amount: parsed.balanceAfter!,
          observedAt: parsed.postedAt,
          // Recorded as notification-sourced, so a figure the user merely
          // approved is distinguishable later from one they typed.
          source: SnapshotSource.notification,
        );

    await ref
        .read(captureDaoProvider)
        .resolve(suggestion.id, confirmed: true, accountId: account.id);
  }
}

class _SamplesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final samples = ref.watch(unparsedSamplesProvider).value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.captureSamplesTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          l10n.captureSamplesBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (samples.isEmpty)
          Text(
            l10n.captureSamplesEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final sample in samples)
            Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: ListTile(
                title: Text(sample.packageName),
                subtitle: Text(
                  sample.title.isEmpty ? sample.body : sample.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: TextButton(
                  onPressed: () => _offerShare(
                    context,
                    ref,
                    id: sample.id,
                    notification: CapturedNotification(
                      packageName: sample.packageName,
                      title: sample.title,
                      body: sample.body,
                      postedAt: sample.postedAt,
                    ),
                  ),
                  child: Text(l10n.captureShare),
                ),
              ),
            ),
      ],
    );
  }

  /// Shows the exact redacted payload and asks.
  ///
  /// The payload is built before it is displayed, so what the user reads is
  /// byte-for-byte what would be sent — there is no richer version behind the
  /// screen. One item at a time, never in bulk, never in the background.
  Future<void> _offerShare(
    BuildContext context,
    WidgetRef ref, {
    required String id,
    required CapturedNotification notification,
  }) async {
    final l10n = context.l10n;
    final redacted = NotificationRedactor.forSample(
      packageName: notification.packageName,
      title: notification.title,
      body: notification.body,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.captureShareHeading),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.captureShareBody),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(
                    dialogContext,
                  ).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: SelectableText(
                  redacted.preview,
                  style: Theme.of(dialogContext).textTheme.labelLarge,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.captureShareCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.captureShareConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // There is no upload endpoint yet, and inventing one silently would be the
    // wrong way to close this loop. The sample is marked so the user is not
    // asked twice, and the honest message is shown.
    await ref.read(captureDaoProvider).markSampleShared(id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.captureShareNotAvailable)),
        );
    }
  }
}
