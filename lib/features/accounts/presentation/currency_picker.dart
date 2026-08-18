import 'package:flutter/material.dart';

import '../../../core/money/currency.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n.dart';

/// Searchable currency picker.
///
/// A searchable sheet rather than a chip row: there are 160-odd ISO 4217
/// currencies and this app's whole audience is people holding unusual
/// combinations of them, so a curated shortlist would fail exactly the users
/// it exists for. Frequently-picked codes surface first, everything else is
/// one search away.
class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({this.selected, super.key});

  final Currency? selected;

  static Future<Currency?> show(
    BuildContext context, {
    Currency? selected,
  }) => showModalBottomSheet<Currency>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CurrencyPicker(selected: selected),
  );

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  final _controller = TextEditingController();
  var _query = '';

  /// Shown above the full list. Chosen for this app's audience — Gulf and
  /// Levant currencies alongside the majors people are paid in.
  static const _common = [
    'JOD', 'AED', 'SAR', 'EGP', 'KWD', 'QAR', 'BHD', 'OMR',
    'USD', 'EUR', 'GBP', 'TRY',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Currency> get _results {
    final query = _query.trim().toUpperCase();
    if (query.isEmpty) {
      final common = _common
          .map(CurrencyRegistry.tryOf)
          .whereType<Currency>()
          .toList();
      final rest = CurrencyRegistry.all
          .where((c) => !_common.contains(c.code))
          .toList();
      return [...common, ...rest];
    }
    return CurrencyRegistry.all
        .where(
          (c) =>
              c.code.contains(query) ||
              c.englishName.toUpperCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final results = _results;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: TextField(
              controller: _controller,
              autofocus: false,
              decoration: InputDecoration(
                hintText: l10n.currencySearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final currency = results[index];
                final selected = currency == widget.selected;
                return ListTile(
                  title: Text(currency.code),
                  subtitle: Text(currency.englishName),
                  trailing: selected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  selected: selected,
                  onTap: () => Navigator.of(context).pop(currency),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
