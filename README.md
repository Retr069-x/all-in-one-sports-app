# SportConnect

SportConnect is the Flutter prototype for the All in One Sports App university project. The first milestone covers choosing a region, learning a sport, completing a quiz and exploring sample places to play.

The [Android debug APK](../output/android/SportConnect-debug.apk) is available in the workspace for testing on an Android phone or emulator.

## Run locally

Install the stable Flutter SDK and set up an Android emulator or connect an Android phone with USB debugging. From the `sportconnect` folder, run the following commands. [Flutter Android setup](https://docs.flutter.dev/platform-integration/android/setup)

```powershell
flutter doctor
flutter pub get
flutter devices
flutter run
```

Run `flutter analyze` and `flutter test` to check the source. This milestone was checked with Flutter 3.47.9.

To preview in a browser, run `flutter run -d edge` or `flutter run -d chrome`. To serve an existing `build/web` directory on the same computer, run `python -m http.server 8765 --bind 127.0.0.1 --directory build/web` and open [SportConnect at localhost](http://127.0.0.1:8765/). [Flutter web setup](https://docs.flutter.dev/platform-integration/web/setup)

## Try the prototype

1. Open Discover and start the football pathway, or choose cricket or badminton from the catalog.
2. Open a lesson, mark it complete and answer the quiz. Progress shows completed lessons from this device.
3. Tap the city at the top and choose another country. Each of the 11 countries has one sample city.
4. Open Nearby and expand a centre card to see the example coach information.

The rankings, centres, distances and coaches are demo records. Lessons and progress work locally. The prototype uses English and starts with Karachi selected.

The starter rules are based on official rulebooks. The practice drills are written for this prototype. [IFAB Laws of the Game](https://www.theifab.com/laws/latest/notes-on-the-laws/), [MCC Laws of Cricket](https://www.lords.org/getmedia/a4ef9f77-2a25-4f5b-a286-4601f08e6334/Laws-of-Cricket-2017-Code-4th-Edition-%282026%29_5.pdf), [BWF Laws of Badminton](https://system.bwfbadminton.com/documents/folder_1_81/Statutes/CHAPTER-4---RULES-OF-THE-GAME/SECTION%204.1-%20Laws%20of%20Badminton.pdf)

The next development milestone covers a protected AI endpoint that answers questions using reviewed lessons, followed by live venue search, an approved coach directory and regional rankings based on app activity.
