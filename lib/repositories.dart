import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'data.dart';
import 'ui/strings.dart';

class OfflineFailure implements Exception {
  const OfflineFailure();
}

abstract interface class LearningRepository {
  Future<List<Sport>> load();
}

class BundledLearningRepository implements LearningRepository {
  const BundledLearningRepository();
  @override
  Future<List<Sport>> load() async => sports;
}

enum AiOutcome { answer, clarification, insufficient }

class AiReply {
  const AiReply(this.outcome, this.text, {this.sources = const []});

  final AiOutcome outcome;
  final String text;
  final List<Lesson> sources;
}

abstract interface class AiRepository {
  Future<AiReply> ask(Sport sport, String question, {Lesson? context});
}

class MockAiRepository implements AiRepository {
  const MockAiRepository();

  @override
  Future<AiReply> ask(Sport sport, String question, {Lesson? context}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final words = question
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((word) => word.isNotEmpty)
        .toSet();
    if (words.any(
      {'injury', 'injured', 'pain', 'hurt', 'diagnose', 'concussion'}.contains,
    )) {
      return const AiReply(AiOutcome.insufficient, Copy.aiSafetyReply);
    }
    if (words.length < 2) {
      return const AiReply(AiOutcome.clarification, Copy.aiClarification);
    }
    final matches = <Lesson>[
      for (final (index, lesson) in sport.lessons.indexed)
        if (_matches(index, lesson, words)) lesson,
    ];
    final referringToLesson =
        words.contains('lesson') &&
        (words.contains('explain') || words.contains('summarize'));
    final source = referringToLesson && context != null
        ? context
        : matches.firstOrNull;
    if (source == null) {
      return const AiReply(AiOutcome.insufficient, Copy.aiInsufficient);
    }
    return AiReply(AiOutcome.answer, source.body, sources: [source]);
  }

  bool _matches(int index, Lesson lesson, Set<String> words) {
    final topics = switch (index) {
      0 => {'score', 'scoring', 'win', 'goal', 'points', 'point'},
      1 => {'equipment', 'gear', 'bring', 'wear', 'racket', 'kit'},
      2 => {'rules', 'rule', 'serve', 'foul'},
      3 => {'practice', 'practise', 'drill', 'training'},
      _ => {'match', 'session', 'game'},
    };
    final titles = lesson.title.toLowerCase().split(RegExp(r'[^a-z]+'));
    final ignored = {
      'a',
      'an',
      'the',
      'and',
      'of',
      'get',
      'to',
      'how',
      'what',
      'i',
      'first',
      'game',
    };
    return words.any(topics.contains) ||
        titles.any((word) => !ignored.contains(word) && words.contains(word));
  }
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.region,
    required this.sports,
    required this.distance,
    this.openingHours,
    this.address,
    this.lastChecked,
    this.source = Copy.demoDirectorySource,
  });

  final String id;
  final String name;
  final Region region;
  final List<String> sports;
  final double distance;
  final String? openingHours;
  final String? address;
  final DateTime? lastChecked;
  final String source;
}

class Coach {
  const Coach({
    required this.id,
    required this.name,
    required this.region,
    required this.sport,
    this.languages = const [],
    this.experience,
    this.feeBasis,
    this.contact,
  });

  final String id;
  final String name;
  final Region region;
  final String sport;
  final List<String> languages;
  final String? experience;
  final String? feeBasis;
  final String? contact;
}

class DirectoryResults {
  const DirectoryResults({this.venues = const [], this.coaches = const []});
  final List<Venue> venues;
  final List<Coach> coaches;
  bool get isEmpty => venues.isEmpty && coaches.isEmpty;
}

abstract interface class DirectoryRepository {
  Future<DirectoryResults> find(Region region);
  Future<DirectoryResults> saved(Set<String> venues, Set<String> coaches);
}

class MockDirectoryRepository implements DirectoryRepository {
  const MockDirectoryRepository();

  @override
  Future<DirectoryResults> find(Region region) async => _results(region);

  @override
  Future<DirectoryResults> saved(
    Set<String> venues,
    Set<String> coaches,
  ) async {
    final directories = regions.map(_results).toList();
    return DirectoryResults(
      venues: directories
          .expand((result) => result.venues)
          .where((item) => venues.contains(item.id))
          .toList(),
      coaches: directories
          .expand((result) => result.coaches)
          .where((item) => coaches.contains(item.id))
          .toList(),
    );
  }

  DirectoryResults _results(Region region) => DirectoryResults(
    venues: [
      Venue(
        id: '${region.code}-community',
        name: Copy.communityCentre(region.city),
        region: region,
        sports: [
          'football',
          'cricket',
          'basketball',
          'volleyball',
          'baseball',
          'rugby-union',
        ],
        distance: 1.4,
      ),
      Venue(
        id: '${region.code}-racket',
        name: Copy.racketCentre(region.city),
        region: region,
        sports: ['tennis', 'badminton', 'table-tennis', 'squash'],
        distance: 3.2,
      ),
      Venue(
        id: '${region.code}-aquatic',
        name: Copy.aquaticsCentre(region.city),
        region: region,
        sports: ['swimming'],
        distance: 6.8,
      ),
      Venue(
        id: '${region.code}-ice',
        name: Copy.iceRink(region.city),
        region: region,
        sports: ['ice-hockey'],
        distance: 12.4,
      ),
    ],
    coaches: [
      for (final (index, sport) in [
        'football',
        'badminton',
        'basketball',
        'swimming',
      ].indexed)
        Coach(
          id: '${region.code}-coach-$sport',
          name: Copy.sampleCoach(index + 1),
          region: region,
          sport: sport,
        ),
    ],
  );
}

enum LocationStatus { found, denied, disabled, outside, unavailable }

typedef LocationResult = ({LocationStatus status, Region? region});

abstract interface class LocationRepository {
  Future<LocationResult> locate();
  Future<void> openSettings();
}

class DeviceLocationRepository implements LocationRepository {
  const DeviceLocationRepository();

  static const _centres = {
    'PK': (24.86, 67.01),
    'US': (40.71, -74.01),
    'CA': (43.65, -79.38),
    'AU': (-33.87, 151.21),
    'GB': (51.51, -.13),
    'SA': (24.71, 46.68),
    'AE': (25.20, 55.27),
    'FR': (48.86, 2.35),
    'IN': (19.08, 72.88),
    'ES': (40.42, -3.70),
    'AR': (-34.60, -58.38),
  };

  @override
  Future<LocationResult> locate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return (status: LocationStatus.unavailable, region: null);
    }
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (status: LocationStatus.disabled, region: null);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return (status: LocationStatus.denied, region: null);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
      Region? nearest;
      var closest = 150000.0;
      for (final region in regions) {
        final (lat, lon) = _centres[region.code]!;
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lon,
        );
        if (distance < closest) {
          closest = distance;
          nearest = region;
        }
      }
      return (
        status: nearest == null ? LocationStatus.outside : LocationStatus.found,
        region: nearest,
      );
    } on Exception {
      return (status: LocationStatus.unavailable, region: null);
    }
  }

  @override
  Future<void> openSettings() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Geolocator.openAppSettings();
    }
  }
}
