# Zimam — زِمام

A cross-border personal wealth tracker for people whose money is spread across
several countries, banks, wallets and currencies.

Not a budgeting app. Zimam answers three questions that budgeting apps do not:

1. **What am I actually worth, in one currency?** Every balance is shown in a
   single home currency, and the app separates *how much you moved* from *how
   much the exchange rate moved*.
2. **What have I forgotten about?** Small, dormant and scattered balances are
   surfaced as a headline feature, not buried.
3. **What will this debt really cost me?** Every debt stores its original
   currency and the FX rate on the day it was created, so repayment cost drift
   is visible.

## Privacy

All financial data stays on the device, in local SQLite. There is no account,
no sync, and no server holding your records. The only network calls the app is
permitted to make are foreign-exchange rates and notification-parser rule
packs, and both must work offline from cache.

## Status

Early development, built in phases.

| Phase | Scope | State |
|---|---|---|
| 0 | Foundation: theme, routing, ar/en localisation, navigation shell | done |
| 1 | `Money` value type, currency registry, Drift schema, FX service | next |
| 2 | Accounts and the Wealth screen | |
| 3 | Insight engine (FX drift, concentration, scattered balances, dormancy) | |
| 4 | Multi-currency debt ledger | |
| 5 | Android notification capture and parser engine | |
| 6 | Google Play release readiness | |

## Getting started

Requires Flutter 3.44+ on the stable channel (Dart 3.12+).

```bash
flutter pub get && flutter run
```

Localisations are generated from `lib/l10n/*.arb` into `lib/l10n/generated/`,
which is git-ignored; `flutter pub get` regenerates them, or run `flutter
gen-l10n` directly.

```bash
flutter analyze && flutter test
```

## Documentation

- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — layers, folder conventions,
  data model and open decisions.
