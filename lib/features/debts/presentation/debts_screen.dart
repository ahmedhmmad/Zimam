import 'package:flutter/material.dart';

import '../../../core/widgets/destination_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/not_built_yet.dart';
import '../../../l10n/l10n.dart';

/// Placeholder. Phase 4 replaces the body with the multi-currency debt ledger.
class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DestinationScaffold(
      title: l10n.debtsTitle,
      child: EmptyState(
        icon: Icons.swap_horiz_outlined,
        title: l10n.debtsEmptyTitle,
        body: l10n.debtsEmptyBody,
        actionLabel: l10n.debtsEmptyAction,
        onAction: () => showNotBuiltYet(context),
      ),
    );
  }
}
