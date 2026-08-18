import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../money/money.dart';
import '../money/money_formatter.dart';
import '../providers.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_typography.dart';

/// How prominent an amount is.
enum MoneyEmphasis { hero, title, body, secondary }

/// Renders a [Money] with the app's formatter and typography.
///
/// The single place amounts become text. Screens never call
/// [MoneyFormatter] directly, so the locale and the digit-style setting cannot
/// end up applied to some figures and not others — and every amount is
/// guaranteed to use tabular figures, which is what keeps decimal points
/// aligned down a column.
class MoneyText extends ConsumerWidget {
  const MoneyText(
    this.amount, {
    this.emphasis = MoneyEmphasis.body,
    this.showCode = true,
    this.signed = false,
    this.colorBySign = false,
    this.color,
    this.textAlign,
    super.key,
  });

  final Money amount;
  final MoneyEmphasis emphasis;
  final bool showCode;

  /// Renders an explicit `+` or a true minus sign. For changes, never totals.
  final bool signed;

  /// Colours the figure by direction — gain green, loss red.
  ///
  /// Off by default: a balance is not a gain merely by being positive, and
  /// colouring every total green would drain the meaning out of the colour.
  final bool colorBySign;

  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = ref.watch(moneyFormatterProvider(locale));

    final text = signed
        ? formatter.formatSigned(amount, showCode: showCode)
        : formatter.format(amount, showCode: showCode);

    final style = switch (emphasis) {
      MoneyEmphasis.hero => AppTypography.amountHero(context),
      MoneyEmphasis.title => AppTypography.amountTitle(context),
      MoneyEmphasis.body => AppTypography.amountBody(context),
      MoneyEmphasis.secondary => AppTypography.amountSecondary(context),
    };

    final resolved =
        color ??
        (colorBySign && !amount.isZero
            ? (amount.isNegative
                  ? context.semantic.loss
                  : context.semantic.gain)
            : null);

    return Text(
      text,
      textAlign: textAlign,
      style: resolved == null ? style : style.copyWith(color: resolved),
      // The formatter already emits locale-appropriate glyphs; forcing LTR
      // keeps the sign and the currency code from being reordered around the
      // digits when an Arabic UI renders a Western-digit amount.
      textDirection: TextDirection.ltr,
    );
  }
}
