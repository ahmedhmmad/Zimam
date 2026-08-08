import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../router/app_router.dart';

/// Shared frame for the three bottom-navigation destinations: a title and a
/// settings entry point, so settings is reachable from wherever the user is.
class DestinationScaffold extends StatelessWidget {
  const DestinationScaffold({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsOpenSemantic,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(child: child),
    );
  }
}
