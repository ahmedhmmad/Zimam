import '../../../core/database/enums.dart';
import '../../../l10n/l10n.dart';

/// Translates an [AccountType] for display.
///
/// A switch rather than a map so adding a type is a compile error here until
/// it has been given a string in both languages.
String accountTypeLabel(AppL10n l10n, AccountType type) => switch (type) {
  AccountType.bank => l10n.accountTypeBank,
  AccountType.cash => l10n.accountTypeCash,
  AccountType.wallet => l10n.accountTypeWallet,
  AccountType.card => l10n.accountTypeCard,
  AccountType.investment => l10n.accountTypeInvestment,
  AccountType.other => l10n.accountTypeOther,
};
