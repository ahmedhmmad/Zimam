import 'package:flutter/material.dart';

import '../../../core/widgets/destination_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/not_built_yet.dart';
import '../../../l10n/l10n.dart';

/// Placeholder. Phase 2 replaces the body with the net-worth hero figure,
/// currency composition, and the activity/FX change split.
class WealthScreen extends StatelessWidget {
  const WealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DestinationScaffold(
      title: l10n.wealthTitle,
      child: EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.wealthEmptyTitle,
        body: l10n.wealthEmptyBody,
        actionLabel: l10n.wealthEmptyAction,
        onAction: () => showNotBuiltYet(context),
      ),
    );
  }
}
