# Djaber Mobile

Flutter companion app for [Djaber.ai](https://djaber.ai) — the AI agent hands a
conversation to the merchant, and their stock travels with them.

The app exists for one reason: **when the AI cannot carry a conversation, the
merchant's phone has to ring, and they have to be able to take over from the
app.** Stock management is added functionality, not a second purpose.

## Where the truth lives

| What | Where |
|---|---|
| Running brief — decisions, findings, open questions | `C:\Users\USER\Desktop\djaber-mobile-brief.md` |
| Web app, backend, and the old Flutter skeleton | `D:\Djaber_AI\djaber` |
| Design file | [Figma `3SieH2XU0UvTnTNRl991LO`](https://www.figma.com/design/3SieH2XU0UvTnTNRl991LO) |

**The web app is the source of truth.** Fields, statuses, business rules and
copy come from `src/lib/i18n.ts`; colours and type from `src/app/globals.css`;
icons from `src/components/ui/icons.tsx`. *How* things are arranged on a phone
follows Odoo — operations as verbs, not ports of web tables. Before building any
screen, read the web's equivalent page and record where the fields came from.

## Getting started

```bash
flutter pub get
flutter gen-l10n          # after touching lib/l10n/*.arb
flutter run
```

Point the app at a different backend without touching code:

```bash
flutter run --dart-define=API_BASE_URL=https://api.djaber.ai --dart-define=FLAVOR=dev
```

The default is the sslip.io host the web app uses. Moving off it is a ship
blocker for store submission — a published binary cannot be redeployed.

## Architecture

MVVM with `provider`, layered strictly bottom-up. Nothing in a lower layer knows
about a higher one, and nothing above `core/network` imports Dio.

```
lib/
├── main.dart               Bootstrap: storage → services → ApiClient → session → router
├── app/
│   ├── app.dart            MaterialApp.router, locale + RTL, lifecycle
│   ├── providers.dart      The DI tree, and the context.session shorthands
│   ├── router.dart         go_router: the graph, the auth redirect, deep links
│   └── routes.dart         Every path, in one place
├── core/
│   ├── config/             Build-time config via --dart-define
│   ├── constants/          Every backend endpoint the app uses
│   ├── error/              AppException hierarchy + Result<T>
│   ├── extensions/         .h / .w / .sp / .r  ← responsive sizing
│   ├── network/            ApiClient + auth / retry / error / logging interceptors
│   ├── services/           Connectivity, device info, push (interface only)
│   ├── storage/            Keystore for the token, prefs for everything else
│   └── utils/              Screen metrics, logger, tolerant JSON readers
├── data/
│   ├── models/             Hand-written, tolerant parsing
│   └── repositories/       Return Result<T>, never throw
├── l10n/                   EN (source) / FR / AR — ARB, generated into l10n/gen
└── presentation/
    ├── theme/              Colours, type, spacing — all from the web's tokens
    ├── viewmodels/         BaseViewModel + app-wide models
    ├── widgets/            Shared widgets
    └── screens/            (empty — nothing built yet)
```

### Responsive sizing

`Screen` is refreshed by `ScreenInitializer` inside `MaterialApp.builder`, above
every route, so the extension is a plain getter with no `BuildContext`:

```dart
SizedBox(height: 2.h)      // 2% of screen height
Container(width: 45.w)     // 45% of screen width
Padding(padding: EdgeInsets.all(4.w))
```

| Getter | Basis | Use for |
|---|---|---|
| `.h` | full screen height | proportional layout |
| `.w` | full screen width | proportional layout |
| `.sh` | height minus status + gesture bars | page bodies |
| `.r` | shorter edge | anything that must stay square |
| `.sp` | 390dp design frame, clamped 0.85–1.15 | **every font size** |
| `.dp` | absolute, −8% on small handsets | hairlines, icons, fixed values |

Declared on `num`, so `12.h` and `2.5.h` both work.

Type is deliberately not a raw percentage of width — at `3.w` a heading is 9px
on a small phone and 30px on a tablet. Use `.sp` for type and `AppSpacing` for
rhythm; reserve `.h` / `.w` for layout proportions.

### State

A view model holds screen state and calls repositories. It never imports
`material.dart` and never touches a `BuildContext`.

- **App-wide** models (`SessionViewModel`, `LocaleViewModel`) are registered in
  `AppProviders` and live for the process.
- **Screen** models are *not* — each screen creates its own with
  `ChangeNotifierProvider` so its state dies with the screen.

`BaseViewModel.run()` wraps a repository call with the loading flag, the error
slot and the disposal guard. Pass `silent: true` for a background poll so a
refresh does not flash a spinner over content the merchant is reading.

### Networking

`ApiClient` returns `Result<T>` — repositories are straight-line code and view
models handle exactly two cases. Interceptors, in order:

1. **Auth** — attaches the bearer token; reports a 401 upward so the session ends.
2. **Retry** — idempotent methods only, with backoff. A POST is never repeated:
   resending "reply to the customer" or "receive this stock" duplicates a
   real-world action.
3. **Error** — maps every `DioException` to a typed `AppException`.
4. **Logging** — debug only; never prints the `Authorization` header.

### Design system

Everything comes from `src/app/globals.css`. The rule the web states and mobile
follows: *accent is just white — confidence through contrast.* One surface
value, hairline borders, emphasis by weight and opacity, no coloured tags.

| Role | Token | Value |
|---|---|---|
| Ground | `AppColors.ink` | `#000000` |
| Surface | `AppColors.surface` | `#0A0A0A` |
| Hairline | `AppColors.rule` | white 8% |
| Urgent border | `AppColors.ruleStrong` | white 18% |
| Live / active | `AppColors.live` | `#34D399` |

Fonts are **bundled**, not fetched at runtime — a first-run font download over
Algerian mobile data means an app that opens unstyled or not at all.

| Role | Face |
|---|---|
| Headings | Syne 600/700/800 |
| Body, titles, **all numerals** | Geist 400–700 |
| Uppercase labels | JetBrains Mono 400/500/600 |
| Arabic | Changa 400–700 |

Numerals stay in Geist deliberately — Syne has no tabular figures.

## Known gaps

- **Push does not work, and cannot.** The backend sends through Expo and
  validates Expo-format tokens; Flutter cannot produce one. `PushService` is an
  interface with a logging no-op behind it, and no vendor SDK is in
  `pubspec.yaml`, because the transport question is still open. Implement one
  subclass when it is answered — nothing above that file changes.
- **No screens.** Every route renders `PlaceholderScreen`. The graph, the auth
  redirect and the deep-link path are real and testable now.
- **Forgot password has no backend.** The web ships the page but it calls
  nothing, and there is no reset route on the server.
- **No first-run language step.** The app defaults to the web's English while
  the market is Arabic-first. `LocaleViewModel.hasExplicitChoice` is what such a
  step would read.
- **Release builds are signed with debug keys.**

## Testing

```bash
flutter test
flutter analyze
```

## Android notes

- `compileSdk = 37` — pinned because flutter_secure_storage 11 requires it.
- `minSdk = 24` — Flutter's floor, covers the low-end handsets in this market.
- `kotlin.incremental=false` in `gradle.properties` works around a Windows
  file-locking failure ("Could not close incremental caches") that breaks every
  Kotlin plugin build.
- Notification delivery on Xiaomi / Oppo / Vivo / Infinix / Tecno needs autostart
  and battery-optimisation exemptions. `DeviceInfoService.needsAutostartGuidance`
  detects those handsets. **Must be tested on real hardware — an emulator will
  not catch it.**
