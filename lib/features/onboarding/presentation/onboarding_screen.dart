import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/money/currency.dart';
import '../../../core/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';
import '../../accounts/presentation/currency_picker.dart';

/// Three steps, no more: pick a home currency, add an account, understand
/// where the data lives.
///
/// The privacy statement is last rather than first on purpose. Shown up front
/// it is a claim about an app the user has not used; shown after they have
/// typed a real balance in, it answers the question they now actually have.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  Currency? _picked;
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _commitCurrency(Currency currency) async {
    setState(() => _picked = currency);
    await ref.read(settingsDaoProvider).setHomeCurrency(currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                // Driven by the buttons: skipping the currency step would
                // leave the app with no currency to report anything in.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _CurrencyStep(
                    picked: _picked,
                    onPick: _commitCurrency,
                    onContinue: _picked == null ? null : _next,
                  ),
                  _AccountStep(onContinue: _next),
                  const _PrivacyStep(),
                ],
              ),
            ),
            _Dots(count: 3, active: _page),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.body,
    required this.children,
  });

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: theme.textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _CurrencyStep extends StatelessWidget {
  const _CurrencyStep({
    required this.picked,
    required this.onPick,
    required this.onContinue,
  });

  final Currency? picked;
  final ValueChanged<Currency> onPick;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StepScaffold(
      title: l10n.onboardingCurrencyTitle,
      body: l10n.onboardingCurrencyBody,
      children: [
        OutlinedButton(
          onPressed: () async {
            final currency = await CurrencyPicker.show(
              context,
              selected: picked,
            );
            if (currency != null) onPick(currency);
          },
          child: Text(
            picked == null
                ? l10n.accountCurrency
                : '${picked!.code} · ${picked!.englishName}',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: onContinue,
          child: Text(l10n.onboardingContinue),
        ),
      ],
    );
  }
}

class _AccountStep extends StatelessWidget {
  const _AccountStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StepScaffold(
      title: l10n.onboardingAccountTitle,
      body: l10n.onboardingAccountBody,
      children: [
        FilledButton(
          onPressed: () async {
            final added = await context.push<bool>(AppRoutes.accountForm);
            if (added ?? false) onContinue();
          },
          child: Text(l10n.accountAdd),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: onContinue,
          child: Text(l10n.onboardingSkip),
        ),
      ],
    );
  }
}

class _PrivacyStep extends ConsumerWidget {
  const _PrivacyStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _StepScaffold(
      title: l10n.onboardingPrivacyTitle,
      body: l10n.onboardingPrivacyBody,
      children: [
        FilledButton(
          onPressed: () {
            // The home currency is already saved, so the router's redirect
            // stops sending the user here.
            ref.invalidate(homeCurrencyProvider);
            context.go(AppRoutes.wealth);
          },
          child: Text(l10n.onboardingStart),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            width: i == active ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
