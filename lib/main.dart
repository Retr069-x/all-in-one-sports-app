import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'design.dart';
import 'screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SportConnect(preferences: await SharedPreferences.getInstance()));
}

class SportConnect extends StatelessWidget {
  const SportConnect({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SportConnect',
    debugShowCheckedModeBanner: false,
    theme: sportConnectTheme(),
    home: Home(preferences: preferences),
  );
}

class Home extends StatefulWidget {
  const Home({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Region region;
  int tab = 0;
  String query = '';
  Sport? nearbySport;

  @override
  void initState() {
    super.initState();
    final country = widget.preferences.getString('country');
    region = regions.firstWhere(
      (item) => item.code == country,
      orElse: () => regions.first,
    );
  }

  Future<void> openSport(Sport sport) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => SportPage(
          sport: sport,
          region: region,
          preferences: widget.preferences,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> chooseRegion() async {
    final selected = await showModalBottomSheet<Region>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: .76,
        child: Column(
          children: [
            Text(
              'Choose a country',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Each country has one demo city.'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: regions.length,
                itemBuilder: (context, index) {
                  final item = regions[index];
                  return ListTile(
                    title: Text(item.country),
                    subtitle: Text(item.city),
                    trailing: item == region ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => region = selected);
    final saved = await widget.preferences.setString('country', selected.code);
    if (mounted && !saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the selected country.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: lime,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'SportConnect',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          color: ink,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.65,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Tooltip(
                          message: 'Change country',
                          child: OutlinedButton(
                            onPressed: chooseRegion,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              side: const BorderSide(color: outline),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.place_outlined, size: 16),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    region.city,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.expand_more, size: 15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  key: PageStorageKey(tab),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  children: switch (tab) {
                    0 => discover(),
                    1 => nearby(),
                    _ => progress(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: outline)),
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: NavigationBar(
            selectedIndex: tab,
            onDestinationSelected: (index) => setState(() => tab = index),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore),
                label: 'Discover',
              ),
              NavigationDestination(
                icon: Icon(Icons.place_outlined),
                selectedIcon: Icon(Icons.place),
                label: 'Nearby',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmark_outline),
                selectedIcon: Icon(Icons.bookmark),
                label: 'Progress',
              ),
            ],
          ),
        ),
      ),
    ),
  );

  List<Widget> discover() {
    final search = query.trim().toLowerCase();
    final catalog = sports.where(
      (sport) => '${sport.name} ${sport.format}'.toLowerCase().contains(search),
    );
    return [
      const SectionHeading(
        'Explore sports',
        'Learn the basics and find a place to play.',
        prominent: true,
      ),
      const SizedBox(height: 15),
      TextFormField(
        initialValue: query,
        onChanged: (value) => setState(() => query = value),
        decoration: const InputDecoration(
          labelText: 'Search sports',
          prefixIcon: Icon(Icons.search_rounded),
        ),
      ),
      const SizedBox(height: 16),
      if (search.isEmpty) ...[
        HeroPanel(sport: sports.first, onStart: () => openSport(sports.first)),
        const SizedBox(height: 23),
        const SectionHeading('Learn a sport', 'Choose a beginner course'),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            for (final sport in sports)
              Expanded(
                child: SportShortcut(sport: sport, onTap: openSport),
              ),
          ],
        ),
        const SizedBox(height: 22),
        SectionHeading(
          'Trending in ${region.country}',
          'Sample ranking · Demo data',
        ),
        const SizedBox(height: 8),
        for (final (index, id) in region.ranking.indexed)
          SportTile(
            sport: sports.firstWhere((sport) => sport.id == id),
            onTap: openSport,
            rank: index + 1,
          ),
      ] else ...[
        const SectionHeading('Search results', 'Beginner courses'),
        const SizedBox(height: 10),
        for (final sport in catalog) SportTile(sport: sport, onTap: openSport),
        if (catalog.isEmpty) const Text('No sports match your search.'),
      ],
    ];
  }

  List<Widget> nearby() => [
    SectionHeading(
      'Find somewhere to play',
      '${region.city}, ${region.country}',
      prominent: true,
    ),
    const SizedBox(height: 15),
    Wrap(
      spacing: 7,
      runSpacing: 4,
      children: [
        for (final sport in <Sport?>[null, ...sports])
          ChoiceChip(
            label: Text(sport?.name ?? 'All sports'),
            selected: sport == nearbySport,
            selectedColor: lavender,
            backgroundColor: Colors.white,
            side: const BorderSide(color: outline),
            onSelected: (_) => setState(() => nearbySport = sport),
          ),
      ],
    ),
    const SizedBox(height: 10),
    const DemoNotice(),
    for (final sport in sports)
      if (nearbySport == null || nearbySport == sport)
        CentreSection(key: ValueKey(sport.id), sport: sport, region: region),
  ];

  List<Widget> progress() {
    final completed = {
      for (final sport in sports)
        sport: completedLessons(widget.preferences, sport).length,
    };
    final total = sports.fold(
      0,
      (count, sport) => count + sport.lessons.length,
    );
    final done = completed.values.fold(0, (count, value) => count + value);
    final started = completed.entries.where((entry) => entry.value > 0);
    return [
      const SectionHeading(
        'Your progress',
        'Saved on this device',
        prominent: true,
      ),
      const SizedBox(height: 16),
      ProgressSummary(done: done, total: total),
      const SizedBox(height: 22),
      const SectionHeading('Your courses', 'Open a course to keep learning'),
      const SizedBox(height: 10),
      if (started.isEmpty) ...[
        const Text('Complete a lesson to see your progress here.'),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: () => setState(() => tab = 0),
            child: const Text('Explore sports'),
          ),
        ),
      ],
      for (final MapEntry(key: sport, value: count) in started)
        SportTile(
          sport: sport,
          onTap: openSport,
          subtitle: '$count of ${sport.lessons.length} lessons complete',
        ),
    ];
  }
}
