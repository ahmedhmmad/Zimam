/// A notification the listener saw, before any parsing.
///
/// Deliberately a plain value type with no Android types in it, so the parser
/// can be tested exhaustively without a device — which matters here more than
/// anywhere else in the app, because this is the one component whose input is
/// arbitrary text from third parties.
final class CapturedNotification {
  const CapturedNotification({
    required this.packageName,
    required this.postedAt,
    this.title = '',
    this.body = '',
  });

  /// The Android application that posted it, e.g. `com.bank.mobile`.
  final String packageName;

  final String title;
  final String body;
  final DateTime postedAt;

  /// Title and body together, which is what rules match against.
  ///
  /// Banks split the same sentence differently across the two fields — some
  /// put the amount in the title, some in the body — so a rule written for one
  /// layout would silently stop matching when the bank changed its formatting.
  String get text => title.isEmpty
      ? body
      : body.isEmpty
      ? title
      : '$title\n$body';

  @override
  String toString() => 'CapturedNotification($packageName, $title)';
}

/// Which way money moved.
enum TransactionDirection {
  /// Out of the account.
  debit,

  /// Into the account.
  credit;

  static TransactionDirection? decode(String? value) => switch (value) {
    'debit' => TransactionDirection.debit,
    'credit' => TransactionDirection.credit,
    _ => null,
  };
}
