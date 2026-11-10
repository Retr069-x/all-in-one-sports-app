import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'data.dart';
import 'repositories.dart';
import 'ui/screens/ask.dart';
import 'ui/screens/course.dart';
import 'ui/screens/learn.dart';
import 'ui/screens/onboarding.dart';
import 'ui/screens/play.dart';
import 'ui/screens/profile.dart';
import 'ui/strings.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/components.dart';
import 'ui/widgets/region_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  Future<SharedPreferences> preferences = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) => FutureBuilder<SharedPreferences>(
    future: preferences,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return SportConnect(preferences: snapshot.requireData);
      }
      return MaterialApp(
        title: Copy.appName,
        theme: appTheme(Brightness.light),
        darkTheme: appTheme(Brightness.dark),
        home: Scaffold(
          body: SafeArea(
            child: ContentList(
              children: [
                const SectionHeader(Copy.appName, prominent: true),
                const SizedBox(height: Space.x4),
                StatusBanner(
                  snapshot.hasError ? ContentState.error : ContentState.loading,
                  onRetry: snapshot.hasError
                      ? () => setState(
                          () => preferences = SharedPreferences.getInstance(),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class SportConnect extends StatefulWidget {
  const SportConnect({
    super.key,
    required this.preferences,
    this.learning = const BundledLearningRepository(),
    this.ai = const MockAiRepository(),
    this.directory = const MockDirectoryRepository(),
    this.location = const DeviceLocationRepository(),
  });

  final SharedPreferences preferences;
  final LearningRepository learning;
  final AiRepository ai;
  final DirectoryRepository directory;
  final LocationRepository location;

  @override
  State<SportConnect> createState() => _SportConnectState();
}

class _SportConnectState extends State<SportConnect> {
  late final AppState state = AppState(widget.preferences);
  late final ThemeData light = appTheme(Brightness.light);
  late final ThemeData dark = appTheme(Brightness.dark);

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, child) => MaterialApp(
      title: Copy.appName,
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: state.themeMode,
      themeAnimationDuration:
          WidgetsBinding
              .instance
              .platformDispatcher
              .accessibilityFeatures
              .disableAnimations
          ? Duration.zero
          : motionDuration,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: state.largeText && media.textScaler.scale(14) < 21
              ? media.copyWith(textScaler: const TextScaler.linear(1.5))
              : media,
          child: Directionality(
            textDirection: state.rtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      home: state.needsOnboarding
          ? OnboardingScreen(state: state)
          : Home(
              state: state,
              learning: widget.learning,
              ai: widget.ai,
              directory: widget.directory,
              location: widget.location,
            ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.state,
    required this.learning,
    required this.ai,
    required this.directory,
    required this.location,
  });

  final AppState state;
  final LearningRepository learning;
  final AiRepository ai;
  final DirectoryRepository directory;
  final LocationRepository location;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  AskSeed? seed;
  AppState get state => widget.state;

  void openPage(WidgetBuilder builder) =>
      Navigator.of(context).push(appRoute(context, builder));

  void openCourse(Sport sport) => openPage(
    (_) => CourseScreen(state: state, sport: sport, openLesson: openLesson),
  );

  void openLesson(Sport sport, Lesson lesson) => openPage(
    (_) => LessonScreen(
      state: state,
      sport: sport,
      lesson: lesson,
      ask: askFromLesson,
    ),
  );

  void openVenue(Venue venue) =>
      openPage((_) => ListingScreen.venue(state: state, venue: venue));
  void openCoach(Coach coach) =>
      openPage((_) => ListingScreen.coach(state: state, coach: coach));

  Future<void> changeRegion() async {
    final selected = await showRegionPicker(context, state.region);
    if (mounted && selected != null) await setRegion(selected);
  }

  Future<void> setRegion(Region selected) async {
    if (!await state.setRegion(selected) && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: AppText(Copy.saveError)));
    }
  }

  void askQuestion(Sport sport, String value) => setState(() {
    seed = AskSeed(sport, value);
    tab = 1;
  });

  void askFromLesson(Sport sport, Lesson lesson) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() {
      seed = AskSeed(sport, Copy.explainLesson(lesson.title), lesson: lesson);
      tab = 1;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: tab,
        children: [
          HeroMode(
            enabled: tab == 0,
            child: LearnScreen(
              state: state,
              repository: widget.learning,
              openCourse: openCourse,
              changeRegion: changeRegion,
              askQuestion: askQuestion,
            ),
          ),
          AskScreen(repository: widget.ai, openLesson: openLesson, seed: seed),
          PlayScreen(
            region: state.region,
            repository: widget.directory,
            location: widget.location,
            changeRegion: changeRegion,
            useRegion: setRegion,
            openVenue: openVenue,
            openCoach: openCoach,
          ),
          ProfileScreen(
            state: state,
            repository: widget.directory,
            location: widget.location,
            changeRegion: changeRegion,
            openCourse: openCourse,
            openLesson: openLesson,
            openVenue: openVenue,
            openCoach: openCoach,
          ),
        ],
      ),
    ),
    bottomNavigationBar: Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: contentWidth),
        child: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) {
            FocusScope.of(context).unfocus();
            setState(() => tab = value);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Symbols.school),
              label: Copy.learn,
            ),
            NavigationDestination(
              icon: Icon(Symbols.chat_bubble),
              label: Copy.ask,
            ),
            NavigationDestination(
              icon: Icon(Symbols.location_on),
              label: Copy.play,
            ),
            NavigationDestination(
              icon: Icon(Symbols.person),
              label: Copy.profile,
            ),
          ],
        ),
      ),
    ),
  );
}
