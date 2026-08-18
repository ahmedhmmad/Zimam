import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/fx/fx_provider_client.dart';
import '../../../core/money/money_formatter.dart';
import '../../../core/providers.dart';
import '../../../core/settings/app_preferences.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../../accounts/presentation/currency_picker.dart';

/// Money, language and appearance, plus the standing statement about where
/// data lives.
///
/// Phase 6 adds "delete all my data" here.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final home = ref.watch(homeCurrencyProvider).value;
    final digits = ref.watch(digitStyleProvider).value ?? DigitStyle.western;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          _SectionHeader(l10n.settingsMoney),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            title: Text(l10n.settingsHomeCurrency),
            subtitle: Text(
              home == null ? '—' : '${home.code} · ${home.englishName}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await CurrencyPicker.show(
                context,
                selected: home,
              );
              if (picked != null) {
                await ref.read(settingsDaoProvider).setHomeCurrency(picked);
              }
            },
          ),

          // Numerals are a separate choice from language, deliberately —
          // plenty of people read Arabic prose and expect Western figures.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(child: Text(l10n.settingsDigitStyle)),
                SegmentedButton<DigitStyle>(
                  segments: [
                    ButtonSegment(
                      value: DigitStyle.western,
                      label: Text(l10n.settingsDigitStyleWestern),
                    ),
                    ButtonSegment(
                      value: DigitStyle.arabicIndic,
                      label: Text(l10n.settingsDigitStyleArabicIndic),
                    ),
                  ],
                  selected: {digits},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      ref.read(settingsDaoProvider).setDigitStyle(s.first),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
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
                    const Divider(height: AppSpacing.lg),
                    Text(
                      l10n.settingsRatesAttribution,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Required by the provider's CC BY-SA licence. Do not
                    // remove — see OpenErApiClient.attribution.
                    Text(
                      OpenErApiClient.attribution,
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
