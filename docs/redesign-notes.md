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
