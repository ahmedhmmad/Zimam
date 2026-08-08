import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart' show AppL10n;

/// `context.l10n.navWealth` — the single way widgets reach translated strings.
///
/// The generated `AppL10n.of` is nullable because a caller could sit above the
/// [Localizations] widget. In this app it never can: the delegates are
/// installed on [MaterialApp] itself, above the router. Asserting that here
/// once is better than a null check at every call site.
extension AppL10nContext on BuildContext {
  AppL10n get l10n {
    final localizations = AppL10n.of(this);
    assert(localizations != null, 'No AppL10n found above this BuildContext.');
    return localizations!;
  }
}
