# SportConnect

SportConnect is the Android prototype for the All in One Sports App university project. It includes twelve offline beginner courses, lesson progress, quizzes, a local lesson assistant, and a demo venue and coach directory for eleven countries.

## Run on Android

Install Flutter and the Android SDK, then connect a phone or start an Android emulator. From this directory, run:

```powershell
flutter pub get
flutter run
```

To build the debug APK and verify the project:

```powershell
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

The APK is generated at `build/app/outputs/flutter-apk/app-debug.apk`. [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup)

## Try the prototype

1. Complete setup and open a beginner course from Learn.
2. Read or save a lesson, practise a drill and try the quiz.
3. Ask a question about the lesson and open its source.
4. Choose a demo city in Play and explore the venue or coach directory.
5. Open Profile to view progress, saved items and accessibility settings.

The AI, country rankings, venues, and coaches use local demo data. The location action matches an approximate device location to a supported city without keeping the coordinates. Course guides and progress work offline.

See [DESIGN.md](DESIGN.md) for UI tokens and [redesign notes](docs/redesign-notes.md) for phase decisions, verification and the AI assistance file log.
