import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../application/capture_providers.dart';

/// The prominent disclosure, shown *before* Android's permission dialog.
///
/// Play's sensitive-permission policy requires that the user be told what is
/// accessed and why, in the app's own words, before the system prompt appears
/// — and that declining is as easy as accepting. That is why this is a full
/// screen reached only from an explicit opt-in, why "Not now" sits beside
/// "Continue" with equal weight rather than as a faint link, and why the app
/// never opens the system screen on its own.
///
/// The copy is deliberately concrete. "Improves your experience" would satisfy
/// nobody; naming what is read, where it goes, and how to revoke it is both
/// what the policy asks for and what a person actually needs to decide.
class CaptureDisclosureScreen extends ConsumerWidget {
  const CaptureDisclosureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.captureTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            l10n.captureDisclosureHeading,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.lg),

          _Section(
            icon: Icons.visibility_outlined,
            heading: l10n.captureDisclosureWhatHeading,
            body: l10n.captureDisclosureWhat,
          ),
          _Section(
            icon: Icons.phone_android_outlined,
            heading: l10n.captureDisclosureWhereHeading,
            body: l10n.captureDisclosureWhere,
          ),
          _Section(
            icon: Icons.check_circle_outline,
            heading: l10n.captureDisclosureControlHeading,
            body: l10n.captureDisclosureControl,
          ),
          _Section(
            icon: Icons.settings_backup_restore,
            heading: l10n.captureDisclosureRevokeHeading,
            body: l10n.captureDisclosureRevoke,
          ),

          const SizedBox(height: AppSpacing.sm),
          // Stated explicitly because it is the assumption people make about
          // any app that reads bank alerts, and because it is a promise the
          // manifest can be checked against.
          _NoSmsNote(text: l10n.captureDisclosureNoSms),

          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () async {
              await ref.read(captureChannelProvider).openPermissionSettings();
              if (context.mounted) Navigator.of(context).pop(true);
            },
            child: Text(l10n.captureDisclosureAccept),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Equal weight, not a faint text link: a decline path that is harder
          // to find than the accept path is not a real choice.
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.captureDisclosureDecline),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.heading,
    required this.body,
  });

  final IconData icon;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heading, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSmsNote extends StatelessWidget {
  const _NoSmsNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: semantic.gainContainer,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 18, color: semantic.onGainContainer),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: semantic.onGainContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
