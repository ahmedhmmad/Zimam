import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/accounts_dao.dart';
import '../domain/account.dart';

final accountsDaoProvider = Provider<AccountsDao>(
  (ref) => AccountsDao(ref.watch(databaseProvider)),
);

/// Every account, archived ones included and sorted last.
final accountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(accountsDaoProvider).watchAll(),
);

/// Accounts that count toward net worth.
final activeAccountsProvider = Provider<AsyncValue<List<Account>>>(
  (ref) => ref
      .watch(accountsProvider)
      .whenData((all) => all.where((a) => !a.isArchived).toList()),
);

/// Accounts grouped by currency, in the order the list renders them.
///
/// Grouping happens once here rather than in the widget so the Accounts screen
/// and the Wealth composition cannot disagree about which currencies exist.
final accountsByCurrencyProvider =
    Provider<AsyncValue<Map<String, List<Account>>>>((ref) {
      return ref.watch(accountsProvider).whenData((all) {
        final grouped = <String, List<Account>>{};
        for (final account in all.where((a) => !a.isArchived)) {
          grouped.putIfAbsent(account.currency.code, () => []).add(account);
        }
        return grouped;
      });
    });

final accountByIdProvider = Provider.family<AsyncValue<Account?>, String>(
  (ref, id) => ref
      .watch(accountsProvider)
      .whenData((all) => all.where((a) => a.id == id).firstOrNull),
);
