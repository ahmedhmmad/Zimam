# Zimam — Architecture

Cross-border personal wealth tracker. Android-first Flutter app, local-first,
multi-currency. This document describes the layers, the folder conventions, and
the data model that Phase 1 will build.

---

## 1. Principles

1. **Local-first is not a feature, it is the boundary.** All financial data
   lives in on-device SQLite. There is no server holding user records, no
   account, no sync. Two — and only two — outbound calls are permitted, both of
   which must degrade to a working app when they fail: FX rates, and
   notification-parser rule packs.
2. **Money is never a `double`.** A `Money` value type (integer minor units +
   ISO 4217 code) is the only representation of an amount anywhere in the app,
   including the database and the parser.
3. **Balance change and value change are different facts.** The domain layer
   must be able to answer "how much did I move?" and "how much did the exchange
   rate move?" separately. This shapes the snapshot model in §4.
4. **Pure domain.** Money math, conversion and the insight rules are plain Dart
   with no Flutter or Drift imports, so they are unit-testable and cheap to
   reason about.

---

## 2. Layers

Three layers per feature, with dependencies pointing inwards only.

```
presentation  ──▶  application  ──▶  domain
   (widgets)        (providers)     (entities, pure logic)
                         │
                         ▼
                       data
              (Drift DAOs, HTTP clients)
```

| Layer | Contains | May import |
|---|---|---|
| `domain` | Entities, value types (`Money`), pure rules | nothing but `dart:*` and `intl` |
| `data` | Drift tables/DAOs, FX HTTP client, mappers | `domain` |
| `application` | Riverpod providers, use-case orchestration | `domain`, `data` |
| `presentation` | Widgets, screens, formatting | `domain`, `application` |

Rules of thumb:

- Widgets never touch a DAO. They watch a provider.
- A Drift row class never leaves the `data` layer; DAOs return domain entities.
- Anything with an `if` in it that is about money belongs in `domain` and has a
  test.

**State**: Riverpod. Providers are declared next to the feature they serve, not
in a global registry. `Notifier`/`AsyncNotifier` for anything writable.

**Navigation**: GoRouter. A `StatefulShellRoute.indexedStack` holds the three
bottom-navigation branches so each keeps its own back stack; anything modal or
full-screen (settings, add/edit flows, the Phase 5 disclosure screen) is a
top-level route above the shell.

---

## 3. Folder layout

Feature-first. `core/` holds only what genuinely spans features.

```
lib/
  main.dart                      entry point, ProviderScope
  app.dart                       MaterialApp.router, theme + locale wiring
  core/
    router/app_router.dart       route table and AppRoutes constants
    settings/                    app-wide preferences (theme, locale, later: home currency)
    theme/                       AppTheme, AppSpacing, AppTypography, AppSemanticColors
    widgets/                     genuinely shared widgets (shell, empty state)
    money/                       [Phase 1] Money, Currency registry
    database/                    [Phase 1] Drift database, tables, migrations
    fx/                          [Phase 1] rate fetch, cache, conversion
  features/
    <feature>/
      domain/                    entities and pure logic
      data/                      DAOs, remote clients, mappers
      application/               providers
      presentation/              screens and widgets
  l10n/
    app_en.arb  app_ar.arb       source strings
    l10n.dart                    `context.l10n` extension, re-exports AppL10n
    generated/                   gen-l10n output (git-ignored)
```

Features as of Phase 0: `wealth`, `accounts`, `debts`, `settings`. Phase 3 adds
`insights`, Phase 5 adds `capture`.

---

## 4. Data model (to be built in Phase 1)

All tables carry `created_at`, `updated_at` (UTC epoch millis) and a nullable
`deleted_at` for soft delete. Every query filters `deleted_at IS NULL`.
Amounts are stored as `INTEGER` minor units plus a `TEXT` ISO 4217 code — never
a real number.

**`accounts`** — a place money sits.
`id`, `name`, `institution`, `currency_code`, `type` (bank / cash / wallet /
card / other), `color`, `notes`, `is_archived`, timestamps.
Holds no balance: the balance is the latest snapshot.

**`balance_snapshots`** — an observation of an account's balance at a time.
`id`, `account_id`, `amount_minor`, `currency_code`, `observed_at`, `source`
(manual / notification), timestamps.
This table is the reason the app can separate *balance change* from *FX drift*:
comparing two snapshots gives the change the user caused, while re-converting
the same snapshot at two different rates gives the change the market caused.
Snapshots are append-only; correcting a balance writes a new row.

**`fx_rates`** — one rate per (base, quote, day).
`base_code`, `quote_code`, `rate` (stored as a scaled integer with a fixed
exponent, not a double), `rate_date`, `fetched_at`.
Primary key `(base_code, quote_code, rate_date)`. Conversion always asks for a
date; "today" is just the most recent row, and staleness is `now - rate_date`,
surfaced in the UI rather than hidden.

**`debts`** — an obligation in its original currency.
`id`, `counterparty`, `direction` (i_owe / owed_to_me), `principal_minor`,
`currency_code`, `home_currency_code`, `rate_at_creation`, `created_on`,
`due_on`, `notes`, `settled_at`, timestamps.
`rate_at_creation` is written once and never updated — it is the historical fact
the whole repayment-drift feature rests on.

**`debt_payments`** — a partial or full repayment.
`id`, `debt_id`, `amount_minor`, `currency_code`, `paid_on`, `rate_at_payment`,
`notes`, timestamps. Each payment snapshots its own rate for the same reason.

**`settings`** — single-row key/value store: `key`, `value`, `updated_at`.
Home currency, scattered-balance threshold, dismissed insight ids, locale and
theme mode.

### Migration strategy

Drift `schemaVersion` starts at 1. Every schema change bumps the version and
adds a step to a `MigrationStrategy` that is written *at the same time as the
change* — never a `deleteAllTables()` fallback, because there is no cloud copy
of the user's data to restore from. Schema snapshots are exported to
`drift_schemas/` so `drift_dev`'s migration tests can verify every upgrade path
from v1 forward. Adding a column is `ALTER TABLE`; anything destructive gets a
copy-and-swap migration with a test that asserts row counts survive.

---

## 5. Localisation and RTL

English and Arabic are both first-class. `flutter gen-l10n` reads
`lib/l10n/*.arb` (see `l10n.yaml`); widgets read strings through
`context.l10n`. `Locale` is user-overridable in settings, defaulting to the
system language.

RTL is a layout mode, not a translation detail. Custom widgets use
direction-agnostic primitives (`EdgeInsetsDirectional`, `start`/`end`,
`Alignment*Directional`) so mirroring is automatic. The Android manifest sets
`supportsRtl`, and the launcher label is localised via `values-ar/strings.xml`.

**Open question deferred to Phase 1:** whether Arabic locale should render
amounts in Arabic-Indic digits (`١٢٣`, `intl`'s default for `ar`) or Western
digits, which most Gulf and Levant banking apps use. This affects the `Money`
formatter, so it needs a decision before that code is written.

---

## 6. Theming

Material 3. `AppTheme` builds light and dark from a fallback seed
(`#1B5E63`), with a hook for a platform-supplied `ColorScheme` that is not yet
wired (see §8). Data surfaces are flat — no gradients, no shadow — and
elevation is near zero throughout.

Colour that carries meaning is deliberately *not* in `ColorScheme`. It lives in
an `AppSemanticColors` theme extension with four roles — `gain`, `loss`,
`alert`, `neutral` — read via `context.semantic`. This makes every meaningful
colour choice explicit at the call site and keeps brand colour from
accidentally being read as "up" or "down".

Currency amounts must use `AppTypography.amount*`, which applies
`FontFeature.tabularFigures()`. Without it, digits change width as values
update and the number visibly jitters.

Text scaling is honoured and clamped at 200% in `app.dart`.

---

## 7. Testing

- `domain` is unit-tested, exhaustively for money math, conversion and the
  Phase 3 rules engine.
- Migrations are tested with `drift_dev`'s schema tooling from Phase 1 on.
- Widget tests are written only where the UI itself is the deliverable. Phase 0
  has four: navigation, both locales, and RTL flip.

---

## 8. Known gaps and deferred decisions

| Item | Status |
|---|---|
| Material You dynamic colour | Needs the `dynamic_color` package, which is not in the approved dependency list. `AppTheme.light/dark` already accept a `ColorScheme?`, so enabling it is a two-line change in `app.dart`. Awaiting approval. |
| Theme/locale persistence | Held in memory today; moves into the `settings` table in Phase 1. |
| Arabic-Indic vs Western digits | See §5. Decide before writing the `Money` formatter. |
| `core/widgets/not_built_yet.dart` | Phase 0 scaffolding so empty-state buttons are not dead. Delete once Phases 2 and 4 provide real destinations. |
