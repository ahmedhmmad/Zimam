import 'package:flutter/material.dart';

import '../../../core/money/money.dart';
import '../../../core/theme/app_category_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/net_worth.dart';

/// The currency composition, as one horizontal proportion bar.
///
/// Not a pie chart, and not coloured with the semantic ramp. Segments take
/// `AppCategoryColors` by descending share, so no currency is ever painted in
/// the gain green or the loss red — a bar where the dollar slice is red reads
/// as "the dollars are losing", which is a claim about the data that the
/// colour has no business making.
class CompositionBar extends StatelessWidget {
  const CompositionBar({
    required this.holdings,
    required this.total,
    super.key,
  });

  final List<CurrencyHolding> holdings;
  final Money total;

  static const double _height = 8;
  static const double _minSegment = 3;

  @override
  Widget build(BuildContext context) {
    final categories = context.categories;
    if (holdings.isEmpty || total.isZero) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(_height / 2),
      child: SizedBox(
        height: _height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final segments = <Widget>[];

            for (var i = 0; i < holdings.length; i++) {
              final share = holdings[i].shareOf(total).clamp(0.0, 1.0);
              // A 0.4% holding would otherwise render as a sub-pixel sliver
              // and vanish, which is exactly the money this app exists to
              // stop people forgetting about.
              final segmentWidth = (share * width).clamp(_minSegment, width);
              segments.add(
                SizedBox(
                  width: segmentWidth,
                  child: ColoredBox(color: categories.forIndex(i)),
                ),
              );
            }

            return Row(children: segments);
          },
        ),
      ),
    );
  }
}

/// The legend beneath the bar: a dot, the currency, and its share.
class CompositionLegend extends StatelessWidget {
  const CompositionLegend({
    required this.holdings,
    required this.total,
    required this.shareLabel,
    super.key,
  });

  final List<CurrencyHolding> holdings;
  final Money total;

  /// Formats a 0..1 fraction, supplied by the caller so the digit-style
  /// setting is honoured.
  final String Function(double fraction) shareLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = context.categories;

    return Column(
      children: [
        for (var i = 0; i < holdings.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categories.forIndex(i),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    holdings[i].currency.code,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  shareLabel(holdings[i].shareOf(total)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
