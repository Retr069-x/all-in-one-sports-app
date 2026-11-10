# SportConnect redesign

## Phase 0 audit

The Flutter prototype has three courses and eleven country fixtures. `lib/main.dart` owns the three-tab shell, country picker and saved region. `lib/screens.dart` contains course expansion, quiz and sample centre cards. `lib/data.dart` owns lessons, sports and demo records. `lib/design.dart` owns the previous theme and illustrations. One widget-test file covers rankings, country selection, filters, quizzes and progress. Android and a local browser preview already build.

Keep Flutter's Navigator, StatefulWidget state and SharedPreferences. Preserve the existing country and lesson-completion keys and the original course and lesson identifiers. No Supabase or Firebase Auth client, production database, API, sign-in or backend credentials are present in this checkout. Repository contracts will separate mock AI and local discovery from future production integrations.

The pasted attachment contains placeholders for screenshots. The existing app and the earlier Nike Training Club, Playtomic and Strava references serve as the starting point. The app keeps the SportConnect name. English is the content language for this iteration, with RTL layout and bundled Arabic and Devanagari fallbacks for later translations. Catalogue additions are introductory guides. Only the supplied mock regions can return directory results. Bookings, payments, live messaging and iOS remain outside scope.

There was no Git repository in the workspace. A local baseline commit records the existing Flutter project, and phase commits use the new `ui-redesign` branch. Local commits use the Codex author because no Git author was configured.

## File plan

| Phase | Files and work |
| --- | --- |
| 0 | `docs/redesign-notes.md` records the audit and assumptions. |
| 1 | `lib/ui/theme/`, `lib/ui/widgets/`, `assets/fonts/`, `pubspec.yaml`, `DESIGN.md` introduce design tokens, offline fonts and reusable components. |
| 2 | `lib/main.dart`, `lib/ui/strings.dart`, `lib/ui/screens/learn.dart`, `lib/data.dart` introduce the four-tab shell, an expanded catalogue and the new Learn home. |
| 3 | `lib/repositories.dart`, `lib/ui/screens/ask.dart`, `play.dart`, `profile.dart`, and the Android manifest cover mock AI and discovery, location handling, saved items and settings. |
| 4 | `lib/ui/screens/course.dart`, `onboarding.dart`, and `test/` complete learning flows and verify adaptive layouts. |

## Verification workflow

From the Flutter project directory, run `dart format lib test`, `flutter analyze`, `flutter test` and `flutter build apk --debug`. Use `flutter run` for an Android emulator or connected phone. The workspace's local Windows verification uses a temporary drive alias because a native Flutter build hook misquotes the existing workspace path with spaces.

## Phase 1 design system

Added Material 3 light and dark themes, twelve sport tokens with tested contrast, bundled variable fonts, and the shared UI components. Added `intl` for date and number formatting and `material_symbols_icons` for one consistent, tree-shaken icon set. The icon package is Apache-2.0. The unchanged Google Fonts binaries include their SIL OFL 1.1 notices. No runtime font requests are needed.

## Phase 2 shell and Learn home

Added the four destinations and applied the shared theme. Learn has region selection, local search, a featured or unfinished course, a horizontal catalogue, demo AI questions and dated sample rankings. All twelve sports have five offline lessons and a starter quiz. The original lesson IDs and progress keys still work. The demo ranking lists a sample top three per country, not a real measure of popularity.

## Phase 3 Ask AI, Play and Profile

Added injectable AI, directory and location repository interfaces. The assistant retrieves excerpts from local lessons and links each supported answer to its lesson. It can ask for clarification, decline unsupported prompts, show loading and failures, and retry. Play has separate venue and coach views, a schematic demo map, distance and sport filters, a searchable area picker and venue and coach detail pages. Fictional listings are labelled at each entry point. Missing contact, fee, opening and verification data is shown as unavailable. Directions require a verified address. Reports are stored locally.

The MIT-licensed `geolocator` plugin requests approximate foreground Android location only after the user selects Use my location. The app compares it to the eleven demo city centres locally within 150 km, then discards the coordinates. Permission denial, disabled services and lack of coverage leave manual search available. Profile includes local saved items, theme and text settings, RTL preview, language status, privacy and data-source information. [Android location package](https://pub.dev/packages/geolocator)

## Phase 4 courses and onboarding

Replaced the original combined screen with separate sport overviews, lessons, practice checklists, quizzes and results. Lessons have a source, game format, bookmark and link into the lesson assistant. First-run onboarding saves a preferred city, sport and level together, and existing progress remains readable. The assistant, directory and catalogue screens show meaningful loading, empty, failure and offline states. Offline catalogue failures fall back to the bundled lessons. Static course content is available offline, and progress and onboarding writes display local errors when applicable.

## Verification results

Each phase passed Dart formatting, Flutter analysis, its available test suite and a debug APK build. The phase test counts were 4, 7, 7, 10 and 42. The final suite covers the 24 combinations of 360×800, 412×915 and 720×1280 with light and dark, 100% and 200% text, and LTR and RTL. It opens and scrolls each tab and compares four reference images. The Android debug APK installed and opened to onboarding on the Pixel 7 emulator. Location denial is covered with an injected test provider. The reference images were generated on Windows with Flutter 3.47.9.

## Scope decisions and follow-up

- AI replies and the directory are local demos. Production AI, real venue or coach feeds, verified addresses, and server-side report delivery require the secure backend. The schematic map provides no live routing.
- The content is English. RTL preview validates mirrored layout, and Arabic and Devanagari glyphs are available locally for future translations. The translated lesson catalogues and interfaces are still future work.
- The twelve courses are introductory educational guides. The directory has one representative city per target country and no claimed business hours, fees or contact details.

## AI assistance file log

- App entry and state: `lib/main.dart`, `lib/app_state.dart`, `lib/repositories.dart`.
- Bundled content: `lib/data.dart`, `lib/course_catalog.dart`.
- Shared UI: `lib/ui/strings.dart`, `lib/ui/theme/app_theme.dart`, `lib/ui/widgets/components.dart`, `lib/ui/widgets/region_picker.dart`.
- Screens: `lib/ui/screens/learn.dart`, `ask.dart`, `play.dart`, `profile.dart`, `course.dart`, `onboarding.dart`. These replaced the legacy `lib/design.dart` and `lib/screens.dart`.
- Android, dependencies and fonts: `android/app/src/main/AndroidManifest.xml`, `pubspec.yaml`, `pubspec.lock`, and the four licensed font families and notices in `assets/fonts/`.
- Verification: `test/app_test.dart`, `test/design_test.dart`, `test/flows_test.dart`, `test/states_test.dart`, `test/layout_test.dart`, and the four screen goldens under `test/goldens/`.
- Documentation: `DESIGN.md`, `README.md` and `docs/redesign-notes.md`.
