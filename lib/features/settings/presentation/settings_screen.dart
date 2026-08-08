import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/settings/app_preferences.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';

/// Language and appearance, plus the standing statement about where data lives.
///
/// Phase 1 adds home currency here; Phase 6 adds "delete all my data".
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          _SectionHeader(l10n.settingsLanguage),
          _ChoiceTile(
            label: l10n.settingsLanguageSystem,
            selected: locale == null,
            onTap: () => ref.read(localeProvider.notifier).set(null),
          ),
          _ChoiceTile(
            label: l10n.settingsLanguageEnglish,
            selected: locale?.languageCode == 'en',
            onTap: () =>
                ref.read(localeProvider.notifier).set(const Locale('en')),
          ),
          _ChoiceTile(
            label: l10n.settingsLanguageArabic,
            selected: locale?.languageCode == 'ar',
            onTap: () =>
                ref.read(localeProvider.notifier).set(const Locale('ar')),
          ),

          const SizedBox(height: AppSpacing.sm),
          _SectionHeader(l10n.settingsAppearance),
          _ChoiceTile(
            label: l10n.settingsThemeSystem,
            selected: themeMode == ThemeMode.system,
            onTap: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.system),
          ),
          _ChoiceTile(
            label: l10n.settingsThemeLight,
            selected: themeMode == ThemeMode.light,
            onTap: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.light),
          ),
          _ChoiceTile(
            label: l10n.settingsThemeDark,
            selected: themeMode == ThemeMode.dark,
            onTap: () =>
                ref.read(themeModeProvider.notifier).set(ThemeMode.dark),
          ),

          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsPrivacyTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.settingsPrivacyBody,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// One option in a mutually exclusive group.
///
/// A [ListTile] rather than a radio row: it wraps cleanly at large text scales,
/// and the semantics below tell a screen reader it behaves as a radio anyway.
class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        title: Text(label),
        trailing: selected
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
