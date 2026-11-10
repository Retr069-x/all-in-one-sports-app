import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'data.dart';
import 'repositories.dart';
import 'screens.dart' as legacy;
import 'ui/screens/ask.dart';
import 'ui/screens/learn.dart';
import 'ui/screens/play.dart';
import 'ui/screens/profile.dart';
import 'ui/strings.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/components.dart';
import 'ui/widgets/region_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SportConnect(preferences: await SharedPreferences.getInstance()));
}

class SportConnect extends StatefulWidget {
  const SportConnect({
    super.key,
    required this.preferences,
    this.ai = const MockAiRepository(),
    this.directory = const MockDirectoryRepository(),
    this.location = const DeviceLocationRepository(),
  });
  final SharedPreferences preferences;
  final AiRepository ai;
  final DirectoryRepository directory;
  final LocationRepository location;

  @override
  State<SportConnect> createState() => _SportConnectState();
}

class _SportConnectState extends State<SportConnect> {
  late final AppState state = AppState(widget.preferences);

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
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: state.themeMode,
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
      home: Home(
        state: state,
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
    required this.ai,
    required this.directory,
    required this.location,
  });
  final AppState state;
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

  Future<void> openCourse(Sport sport) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => legacy.SportPage(
          sport: sport,
          region: state.region,
          preferences: state.preferences,
        ),
      ),
    );
    if (mounted) state.refresh();
  }

  Future<void> changeRegion() async {
    final selected = await showRegionPicker(context, state.region);
    if (!mounted || selected == null) return;
    await setRegion(selected);
  }

  Future<void> setRegion(Region selected) async {
    if (!await state.setRegion(selected) && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Copy.saveError)));
    }
  }

  void askQuestion(Sport sport, String value) => setState(() {
    seed = AskSeed(sport, value);
    tab = 1;
  });

  void openLesson(Sport sport, Lesson lesson) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(sport.name)),
          body: ContentList(
            children: [
              SectionHeader(
                lesson.title,
                detail: sport.format,
                prominent: true,
              ),
              const SizedBox(height: Space.x4),
              Text(lesson.body),
              const SizedBox(height: Space.x4),
              const Text(Copy.courseSource),
            ],
          ),
        ),
      ),
    );
  }

  void openVenue(Venue venue) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => ListingScreen.venue(state: state, venue: venue),
    ),
  );

  void openCoach(Coach coach) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (context) => ListingScreen.coach(state: state, coach: coach),
    ),
  );

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
