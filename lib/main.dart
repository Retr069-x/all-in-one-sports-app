import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'data.dart';
import 'screens.dart' as legacy;
import 'ui/screens/learn.dart';
import 'ui/strings.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/components.dart';
import 'ui/widgets/region_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SportConnect(preferences: await SharedPreferences.getInstance()));
}

class SportConnect extends StatefulWidget {
  const SportConnect({super.key, required this.preferences});
  final SharedPreferences preferences;

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
      home: Home(state: state),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key, required this.state});
  final AppState state;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  String? question;

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
    if (!await state.setRegion(selected) && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Copy.saveError)));
    }
  }

  void askQuestion(Sport sport, String value) => setState(() {
    question = value;
    tab = 1;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: tab,
        children: [
          LearnScreen(
            state: state,
            openCourse: openCourse,
            changeRegion: changeRegion,
            askQuestion: askQuestion,
          ),
          ContentList(
            children: [
              const SectionHeader(Copy.ask, prominent: true),
              if (question case final value?) Text(value),
              const SizedBox(height: Space.x4),
              const StatusBanner(ContentState.offline, detail: Copy.offlineAi),
            ],
          ),
          ContentList(
            children: [
              SectionHeader(
                Copy.play,
                detail: Copy.place(state.region.city, state.region.country),
                prominent: true,
              ),
              const SizedBox(height: Space.x3),
              const StatusBanner(
                ContentState.offline,
                detail: Copy.demoDirectory,
              ),
              OutlinedButton(
                onPressed: changeRegion,
                child: const Text(Copy.selectCountry),
              ),
            ],
          ),
          _ProgressPreview(state: state, openCourse: openCourse),
        ],
      ),
    ),
    bottomNavigationBar: Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: contentWidth),
        child: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (value) => setState(() => tab = value),
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

class _ProgressPreview extends StatelessWidget {
  const _ProgressPreview({required this.state, required this.openCourse});
  final AppState state;
  final ValueChanged<Sport> openCourse;

  @override
  Widget build(BuildContext context) {
    final numbers = NumberFormat.decimalPattern('en');
    return ContentList(
      children: [
        const SectionHeader(
          Copy.profile,
          detail: Copy.progressLocal,
          prominent: true,
        ),
        const SizedBox(height: Space.x4),
        ProgressRing(
          value: state.completedCount / state.totalLessons,
          label: Copy.progress,
        ),
        const SizedBox(height: Space.x4),
        if (state.completedCount == 0)
          const StatusBanner(ContentState.empty, detail: Copy.progressEmpty),
        for (final sport in sports)
          if (state.completed(sport).isNotEmpty)
            SportTile(
              id: sport.id,
              name: sport.name,
              icon: sport.icon,
              detail: Copy.completed(
                numbers.format(state.completed(sport).length),
                numbers.format(sport.lessons.length),
              ),
              onTap: () => openCourse(sport),
            ),
      ],
    );
  }
}
