import 'package:flutter/material.dart';

import '../../../core/widgets/destination_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/not_built_yet.dart';
import '../../../l10n/l10n.dart';

/// Placeholder. Phase 2 replaces the body with the currency-grouped account
/// list and the add/edit/archive flows.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DestinationScaffold(
      title: l10n.accountsTitle,
      child: EmptyState(
        icon: Icons.list_alt_outlined,
        title: l10n.accountsEmptyTitle,
        body: l10n.accountsEmptyBody,
        actionLabel: l10n.accountsEmptyAction,
        onAction: () => showNotBuiltYet(context),
      ),
    );
  }
}
