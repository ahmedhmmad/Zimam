import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Temporary scaffolding for Phase 0.
///
/// The empty states are required to offer a primary action, but the flows those
/// actions open do not exist until Phases 2 and 4. Rather than render a dead
/// button, the action acknowledges the tap.
///
/// DELETE THIS FILE once every caller has a real destination.
void showNotBuiltYet(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(context.l10n.comingLater),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
