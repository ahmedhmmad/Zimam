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

Features as of Phase 4: `wealth`, `accounts`, `debts`, `settings`,
`onboarding`, `insights`. Phase 5 adds `capture`.

### Repayment cost drift

A debt freezes its rate at creation and each payment freezes its own. Those
columns are written once and never updated — they are the historical facts the
comparison rests on, and today's rate cannot recover what last March's was.

The drift splits in two, and the split is what makes the figures trustworthy:

```
  realised   = Σ payment × rate(payment day) − Σ payment × rate(creation)
  unrealised = outstanding × rate(today)     − outstanding × rate(creation)
```

Realised drift is money genuinely spent or saved because of when instalments
happened to fall; unrealised drift still moves until the debt is settled.
They sum to the total by construction, and a test asserts it across a range of
rates.

Direction decides what the arithmetic *means*. A debt growing in home-currency
terms is bad news when you owe it and good news when you are owed it, so
`DebtCost.isWorseFor` takes the direction rather than assuming one — the same
number is coloured loss or gain depending on which side the user is on.

Recording a debt or a payment **requires** a cached rate and refuses without
one. Storing either with no rate would leave it permanently unable to show
drift, and the rate for that day is unrecoverable once the day passes.

Amending a debt leaves the frozen rate alone, and locks the two fields it
depends on. The rate is a ratio for one pair on one day, so it stays correct
when the *principal* is corrected — 2,500 dollars at last March's rate is
still meaningful. It stops being meaningful the moment either end of the pair
moves: a different currency leaves the rate's base pointing at a currency the
debt no longer uses, and a different date leaves it belonging to a day it was
not observed on, which cannot be re-derived. Correcting either means recording
the debt again.

### Insight rules

Rules are plain synchronous functions over an `InsightContext` that is
assembled once and handed to all of them. They cannot reach the database,
cannot perform I/O, and cannot disagree about the numbers — which is what
makes the whole feature testable from seeded data rather than by looking at a
screen. Currency conversion happens before the engine runs, injected as
`homeValueOf`, so the rules stay pure.

Adding a rule means writing an `InsightRule` and adding it to
`InsightEngine.defaultRules`. Nothing else changes except the sealed
`InsightDetails` subtype, which the compiler then demands the card widget
handle.

Ranking is by **materiality — the share of net worth at stake**, not by a raw
amount. Rules measure quite different things, and a fraction lets "2% moved on
rates" and "2% is sitting forgotten" compete honestly; an amount would let
whichever rule happens to touch bigger numbers always win.

Dismissal is keyed on a **signature that buckets the underlying figure**, not
on the rule name. Keyed on the rule alone a card would be silenced forever;
keyed on the exact value it would return on every trivial fluctuation. So
dismissing "68% in one currency" stays dismissed at 71% and reappears at 90%.

Rules state facts and never give advice. "68% of your wealth is in one
currency" is an observation the user may not have made; "you should diversify"
is a recommendation this app is in no position to make.

### The activity/FX split

The decomposition the whole app rests on, for balances `B` and rates `R` at
each end of the period:

```
  activity = Σ (B₁ − B₀) × R₁     what you moved, at today's prices
  fx       = Σ B₀ × (R₁ − R₀)     what the market did to what you had
```

The cross term cancels, so these sum exactly to `Σ B₁R₁ − Σ B₀R₀`. That
identity is asserted in `net_worth_test.dart` rather than assumed: a split that
does not reconcile would misattribute a loss the user then acts on. Activity is
valued at *today's* rates on purpose — it answers "what is the money I moved
worth now", which is the question someone planning a transfer is asking.

An account appearing only in the closing set counts wholly as activity, never
as a market gain: recording an account you already owned must not look like the
market handed you money.

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
Home currency, digit style (see §5), scattered-balance threshold, dismissed
insight ids, locale and theme mode.

### Migration strategy

Drift `schemaVersion` starts at 1. Every schema change bumps the version and
adds a step to the `MigrationStrategy` **in the same commit as the change**.

There is deliberately no `deleteAllTables()` fallback. That idiom is standard
in server-backed apps, where wiping and re-syncing costs the user nothing; here
it would destroy the only copy of someone's financial history. `onUpgrade`
instead throws with an explanatory message, and `schema_test.dart` asserts that
it does — so a forgotten migration fails loudly in CI rather than silently on a
user's phone. Adding a column is `ALTER TABLE`; anything destructive gets a
copy-and-swap with a test asserting row counts and sample values survive.

**Timestamps are stored as UTC ISO-8601 text, not unix integers.** Drift's
integer default returns *local* `DateTime`s on read. Since rate dates are UTC
midnight and staleness is computed by comparing calendar days, that default
makes every conversion report a day staler than it is for any user west of
UTC. This was caught by a test, not by review.

**Known toolchain gap:** `dart run drift_dev schema dump` currently fails
against drift 2.34.x (`allSchemaEntities` was moved in an internal refactor),
so there are no snapshots in `drift_schemas/` yet. Nothing depends on them at
v1 — there are no migrations to verify — but this must be resolved before the
first schema bump.

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

### Digit style

Numerals are a **user preference, not a consequence of the locale**. Arabic
speakers are split: `intl` defaults the `ar` locale to Arabic-Indic digits
(`١٢٣`), while most Gulf and Levant banking apps show Western digits (`123`),
and the same person may want Arabic prose with Western figures.

- Setting: `digit_style` in `settings`, values `western` | `arabicIndic`.
- **Default is `western`**, in both locales.
- The `Money` formatter takes the style as an input rather than reading the
  ambient locale, which keeps it a pure function and directly testable. In
  practice this means constructing `NumberFormat` against `ar` for grouping and
  separators, then mapping the digit glyphs according to the setting — never
  letting the locale decide the glyphs implicitly.
- Every amount in the app renders through that one formatter, so the setting
  cannot apply inconsistently across screens.

---

## 6. Theming

**`docs/DESIGN.md` is the source of truth.** It carries the palette, type ramp,
spacing and shape tokens. Changing a colour or a size means editing that file
first, then transcribing it into `lib/core/theme/`. Nothing in the theme is
generated from a seed any more.

Material 3, with the palette given explicitly in `AppColorSchemes`. Design brief
is "Quiet Precision": flat surfaces, no gradients, **no shadows at all** —
depth is communicated by tonal layering, so a card is separated from the canvas
by fill contrast alone (`#ffffff` on `#f2f4f4` in light, `#1c1f1f` on `#121414`
in dark). Pressing a surface changes its fill rather than lifting it.

Colour that carries meaning is deliberately *not* read from `ColorScheme` at
call sites. It lives in the `AppSemanticColors` extension — `gain`, `loss`,
`alert`, `neutral`, plus container pairs — reached via `context.semantic`. The
design system maps Gain onto Material's `secondary` and Loss onto `tertiary`;
that mapping is recorded in one place so a call site never has to know it, and
so `colorScheme.secondary` is never mistaken for a brand colour.

Two families, strictly divided: **IBM Plex Sans** for prose, **JetBrains Mono**
for every amount, percentage and date. Use `AppTypography.amount*` or
`asAmount()` — never a raw `TextTheme` entry — so figures stay tabular and
digits do not shift width as values update. A screen shows at most three type
sizes and exactly one hero figure.

Text scaling is honoured and clamped at 200% in `app.dart`.

### Colour is for data state, never for category

The design system's own rule — "colors are used strictly for data state" — has one
consequence that is easy to get wrong and was got wrong in the source designs:
**a set of categories must never be coloured with the semantic ramp.**

The Stitch currency-composition bar assigns `primary` to AED, `secondary` to
JOD, `tertiary` to USD and `outline` to EGP, purely by list order. Since
`secondary` is Gain and `tertiary` is Loss, that paints the user's dollar
holdings in the loss colour and their dinar holdings in the gain colour, for no
reason connected to the data. A glance at the bar reads as "the red one is
losing money".

Anything enumerating currencies, accounts or institutions therefore uses
`AppCategoryColors` via `context.categories`, never `AppSemanticColors`. The
ramp is five tonal steps of the brand teal plus a neutral `other`, ordered by
descending share, distinguished by lightness alone so it survives deuteranopia
and protanopia and can never be read as a gain or a loss.

**Five steps, not six, and that is a hard ceiling.** Requiring each step to
clear 3:1 against its surface caps luminance at 0.283, while the darkest usable
teal sits at 0.020. The whole band spans 3:1 to 15.4:1, so six single-hue steps
could be at most 1.39:1 apart from one another — indistinguishable in a bar.
Holdings past the fifth belong in `other`; `forIndex` deliberately falls through
to it rather than wrapping, since wrapping would give two currencies the same
colour in one chart.

`test/theme/palette_contrast_test.dart` asserts all of this. It is not
ceremonial: the ramp originally supplied for this role had three of seven steps
between 1.40:1 and 2.26:1 against the card, and two steps within 1.03:1 of each
other. Palettes read as fine to the eye while being measurably wrong, so the
thresholds are tested.

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
| Material You dynamic colour | **Dropped, deliberately.** A device-derived palette would override the greens and reds that carry meaning here. `docs/DESIGN.md` wins over the wallpaper. |
| Font assets | IBM Plex Sans, IBM Plex Sans Arabic and JetBrains Mono are declared in the theme but **not bundled**, so both families currently fall back to the platform default. Sizes, weights and line heights are already correct. |
| Dark palette | Derived, not specified — and **confirmed to exist nowhere upstream**. The Stitch project's Tailwind config carries only the 47 light tokens; its "dark" screens are `dark:` variants pointing back at light token names, which is why the dark app bar renders near-invisible. Our reconstruction from the `*-fixed` tonal tokens is the best available source. See `AppColorSchemes.dark`. |
| ~~"Attention" colour~~ | **Closed.** Supplied by the palette specimen and adopted: `#7a5300` with a `#ffefd1` / `#422c00` container pair. Verified at 6.85:1 on white and 11.63:1 for content on its container. Dark mode remains ours, the specimen being light-only. |
| ~~Categorical colour~~ | **Closed.** `AppCategoryColors`, five tonal teal steps plus a neutral tail — see §6. The specimen's own seven-step ramp was measured and rejected. |
| Loss container | The design system's `tertiary-container` is a dark fill with light content, unlike the soft `secondary-container`, so a loss chip renders far louder than a gain chip. Transcribed as given; worth correcting upstream. |
| Source designs contradict the written system | The generated screens use `rounded-full` 60 times (the system forbids pill buttons) and `rounded-xl` = 12px for cards (the system fixes cards at 16px), and apply `font-label-mono` to prose — mono is the most-used font class in the export, though it is specified for figures only. The written system wins; the theme follows it. |
| Theme/locale persistence | Still in memory. Home currency and digit style persist; theme and locale reset on cold start. |
| Widget tests avoid the database | Drift's stream machinery leaves timers pending after teardown, tripping the test binding's `!timersPending` assertion and wedging every later test in the file. Widget tests stub the data providers instead; the DAOs are covered separately against a real in-memory database. |
| `drift_dev schema dump` | Broken against drift 2.34.x. Resolve before the first migration. |
| `core/widgets/not_built_yet.dart` | Phase 0 scaffolding so empty-state buttons are not dead. Delete once Phases 2 and 4 provide real destinations. |
