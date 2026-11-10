import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

enum SavedKind { lesson, venue, coach }

enum PlayerLevel { beginner, recreational, returning }

class AppState extends ChangeNotifier {
  AppState(this.preferences);

  final SharedPreferences preferences;

  List<String> get _setup => preferences.getStringList('ui-onboarding') ?? [];

  bool get needsOnboarding =>
      _setup.isEmpty &&
      preferences.getBool('ui-onboarded') != true &&
      !preferences.containsKey('country') &&
      completedCount == 0;

  Sport get starterSport {
    final setup = _setup;
    return sports.firstWhere(
      (sport) => setup.length > 1 && sport.id == setup[1],
      orElse: () => sports.first,
    );
  }

  PlayerLevel? get playingLevel {
    final setup = _setup;
    return setup.length > 2
        ? PlayerLevel.values
              .where((level) => level.name == setup[2])
              .firstOrNull
        : null;
  }

  Future<bool> finishOnboarding(
    Region region,
    Sport sport,
    PlayerLevel level,
  ) => _write(
    () => preferences.setStringList('ui-onboarding', [
      region.code,
      sport.id,
      level.name,
    ]),
  );

  Region get region => regions.firstWhere(
    (item) =>
        item.code == (preferences.getString('country') ?? _setup.firstOrNull),
    orElse: () => regions.first,
  );

  ThemeMode get themeMode => switch (preferences.getString('ui-theme')) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
  bool get rtl => preferences.getBool('ui-rtl') ?? false;
  bool get largeText => preferences.getBool('ui-large-text') ?? false;

  Set<String> saved(SavedKind kind) =>
      (preferences.getStringList('ui-saved-${kind.name}') ?? []).toSet();

  bool isSaved(SavedKind kind, String id) => saved(kind).contains(id);

  Future<bool> toggleSaved(SavedKind kind, String id) => _write(() {
    final values = saved(kind);
    if (!values.remove(id)) values.add(id);
    return preferences.setStringList('ui-saved-${kind.name}', values.toList());
  });

  Future<bool> report(String listingId, String text) => _write(() {
    final reports = preferences.getStringList('ui-directory-reports') ?? [];
    return preferences.setStringList('ui-directory-reports', [
      ...reports,
      '$listingId\n$text',
    ]);
  });

  Set<String> completed(Sport sport) {
    final stored = preferences.getStringList('completed-${sport.id}') ?? [];
    return sport.lessons
        .map((lesson) => lesson.id)
        .toSet()
        .intersection(stored.toSet());
  }

  int get completedCount =>
      sports.fold(0, (total, sport) => total + completed(sport).length);
  int get totalLessons =>
      sports.fold(0, (total, sport) => total + sport.lessons.length);

  Sport? get inProgress {
    for (final sport in sports) {
      final count = completed(sport).length;
      if (count > 0 && count < sport.lessons.length) return sport;
    }
    return null;
  }

  Future<bool> setRegion(Region value) =>
      _write(() => preferences.setString('country', value.code));
  Future<bool> setTheme(ThemeMode value) =>
      _write(() => preferences.setString('ui-theme', value.name));
  Future<bool> setRtl(bool value) =>
      _write(() => preferences.setBool('ui-rtl', value));
  Future<bool> setLargeText(bool value) =>
      _write(() => preferences.setBool('ui-large-text', value));

  Future<bool> complete(Sport sport, Lesson lesson) => _write(
    () => preferences.setStringList(
      'completed-${sport.id}',
      {...completed(sport), lesson.id}.toList(),
    ),
  );

  Future<bool> _write(Future<bool> Function() action) async {
    try {
      if (!await action()) return false;
      notifyListeners();
      return true;
    } on Exception {
      return false;
    }
  }
}
