import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_symbols_icons/symbols.dart';

import '../../app_state.dart';
import '../../data.dart';
import '../../repositories.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import 'play.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.state,
    required this.repository,
    required this.location,
    required this.changeRegion,
    required this.openCourse,
    required this.openLesson,
    required this.openVenue,
    required this.openCoach,
  });
  final AppState state;
  final DirectoryRepository repository;
  final LocationRepository location;
  final VoidCallback changeRegion;
  final ValueChanged<Sport> openCourse;
  final void Function(Sport, Lesson) openLesson;
  final ValueChanged<Venue> openVenue;
  final ValueChanged<Coach> openCoach;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Set<String> venues = {};
  Set<String> coaches = {};
  Future<DirectoryResults>? directory;

  AppState get state => widget.state;

  void retrySaved() =>
      setState(() => directory = widget.repository.saved(venues, coaches));

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Copy.useSystem,
    ThemeMode.light => Copy.lightTheme,
    ThemeMode.dark => Copy.darkTheme,
  };

  Future<void> _apply(Future<bool> result) async {
    if (!await result && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Copy.saveError)));
    }
  }

  Future<void> _appearance() async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(Copy.appearance),
        children: [
          for (final mode in ThemeMode.values)
            ListTile(
              title: Text(_themeName(mode)),
              minTileHeight: 48,
              selected: mode == state.themeMode,
              onTap: () => Navigator.pop(context, mode),
            ),
        ],
      ),
    );
    if (selected != null && mounted) await _apply(state.setTheme(selected));
  }

  void _info(String title, List<Widget> content, {bool location = false}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Space.x2,
          children: content,
        ),
        actions: [
          if (location)
            TextButton(
              onPressed: () async {
                try {
                  await widget.location.openSettings();
                } on Exception {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(Copy.locationUnavailable)),
                    );
                  }
                }
              },
              child: const Text(Copy.openSettings),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(Copy.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final numbers = NumberFormat.decimalPattern('en_US');
    final savedLessons = state.saved(SavedKind.lesson);
    final newVenues = state.saved(SavedKind.venue);
    final newCoaches = state.saved(SavedKind.coach);
    if (!setEquals(newVenues, venues) || !setEquals(newCoaches, coaches)) {
      venues = newVenues;
      coaches = newCoaches;
      directory = venues.isEmpty && coaches.isEmpty
          ? null
          : widget.repository.saved(venues, coaches);
    }
    return ContentList(
      children: [
        const SectionHeader(
          Copy.profile,
          detail: Copy.progressLocal,
          prominent: true,
        ),
        const SizedBox(height: Space.x4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.x2,
              children: [
                const SectionHeader(Copy.progress),
                ProgressRing(
                  value: state.completedCount / state.totalLessons,
                  label: Copy.progress,
                ),
                Text(
                  Copy.completed(
                    numbers.format(state.completedCount),
                    numbers.format(state.totalLessons),
                  ),
                ),
                if (state.completedCount == 0) const Text(Copy.progressEmpty),
              ],
            ),
          ),
        ),
        for (final sport in sports)
          if (state.completed(sport).isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: Space.x2),
              child: SportTile(
                id: sport.id,
                name: sport.name,
                icon: sport.icon,
                detail: Copy.completed(
                  numbers.format(state.completed(sport).length),
                  numbers.format(sport.lessons.length),
                ),
                onTap: () => widget.openCourse(sport),
              ),
            ),
        const SizedBox(height: Space.x6),
        const SectionHeader(Copy.saved),
        const SizedBox(height: Space.x3),
        if (savedLessons.isEmpty && directory == null)
          const StatusBanner(ContentState.empty, detail: Copy.savedEmpty),
        if (savedLessons.isNotEmpty) const SectionHeader(Copy.savedLessons),
        for (final sport in sports)
          for (final lesson in sport.lessons)
            if (savedLessons.contains('${sport.id}/${lesson.id}'))
              Card(
                child: ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.menu_book),
                  title: Text(lesson.title),
                  subtitle: Text(sport.name),
                  onTap: () => widget.openLesson(sport, lesson),
                ),
              ),
        if (directory != null)
          FutureBuilder<DirectoryResults>(
            future: directory,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const StatusBanner(ContentState.loading);
              }
              if (snapshot.hasError) {
                final offline = snapshot.error is OfflineFailure;
                return StatusBanner(
                  offline ? ContentState.offline : ContentState.error,
                  detail: offline ? Copy.directoryOffline : Copy.directoryError,
                  onRetry: retrySaved,
                );
              }
              final results = snapshot.requireData;
              if (results.isEmpty) {
                return const StatusBanner(
                  ContentState.empty,
                  detail: Copy.savedEmpty,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Space.x2,
                children: [
                  if (results.venues.isNotEmpty)
                    const SectionHeader(Copy.venues),
                  for (final item in results.venues)
                    VenueCard(
                      title: item.name,
                      details: venueSummary(item),
                      onTap: () => widget.openVenue(item),
                    ),
                  if (results.coaches.isNotEmpty)
                    const SectionHeader(Copy.coaches),
                  for (final item in results.coaches)
                    CoachCard(
                      title: item.name,
                      details: coachSummary(item),
                      onTap: () => widget.openCoach(item),
                    ),
                ],
              );
            },
          ),
        const SizedBox(height: Space.x6),
        const SectionHeader(Copy.settings),
        const SizedBox(height: Space.x3),
        Card(
          child: Column(
            children: [
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.location_on),
                title: const Text(Copy.selectCountry),
                subtitle: Text(
                  Copy.place(state.region.city, state.region.country),
                ),
                onTap: widget.changeRegion,
              ),
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.language),
                title: const Text(Copy.language),
                subtitle: const Text(Copy.english),
                onTap: () => _info(Copy.language, [
                  const Text(Copy.english),
                  const Text(Copy.languagesPlanned),
                ]),
              ),
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.contrast),
                title: const Text(Copy.appearance),
                subtitle: Text(_themeName(state.themeMode)),
                onTap: _appearance,
              ),
              SwitchListTile(
                title: const Text(Copy.rtlPreview),
                subtitle: const Text(Copy.rtlHelp),
                value: state.rtl,
                onChanged: (value) => _apply(state.setRtl(value)),
              ),
              SwitchListTile(
                title: const Text(Copy.largerText),
                subtitle: const Text(Copy.largerHelp),
                value: state.largeText,
                onChanged: (value) => _apply(state.setLargeText(value)),
              ),
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.my_location),
                title: const Text(Copy.locationPermission),
                onTap: () => _info(Copy.locationPermission, [
                  const Text(Copy.locationPrivacy),
                ], location: true),
              ),
              ListTile(
                minTileHeight: 48,
                leading: const Icon(Symbols.info),
                title: const Text(Copy.privacy),
                onTap: () => _info(Copy.privacy, [
                  const Text(Copy.privacyDetail),
                  const SectionHeader(
                    Copy.dataSources,
                    detail: Copy.dataSourcesDetail,
                  ),
                  const Text(Copy.askNote),
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
