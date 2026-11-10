import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportconnect/data.dart';
import 'package:sportconnect/main.dart';
import 'package:sportconnect/repositories.dart';
import 'package:sportconnect/ui/strings.dart';

class _Learning implements LearningRepository {
  final pending = Completer<List<Sport>>();
  @override
  Future<List<Sport>> load() => pending.future;
}

class _Directory implements DirectoryRepository {
  final pending = Completer<DirectoryResults>();
  @override
  Future<DirectoryResults> find(Region region) => pending.future;
  @override
  Future<DirectoryResults> saved(Set<String> venues, Set<String> coaches) =>
      pending.future;
}

void _phone(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(412, 915);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Finder _tab(String label) => find.widgetWithText(NavigationDestination, label);

void main() {
  for (final (title, learningMessage, directoryMessage, failure) in [
    ('empty', Copy.noCourses, Copy.noDirectory, null),
    (
      'offline',
      Copy.learningOffline,
      Copy.directoryOffline,
      const OfflineFailure(),
    ),
    (
      'error',
      Copy.catalogError,
      Copy.directoryError,
      Exception('Test failure'),
    ),
  ]) {
    testWidgets('Learn, Play and Profile show loading and $title states', (
      tester,
    ) async {
      _phone(tester);
      SharedPreferences.setMockInitialValues({
        'ui-onboarded': true,
        'ui-saved-venue': ['PK-community'],
      });
      final learning = _Learning();
      final directory = _Directory();
      await tester.pumpWidget(
        SportConnect(
          preferences: await SharedPreferences.getInstance(),
          learning: learning,
          directory: directory,
        ),
      );
      expect(find.text(Copy.loading), findsOneWidget);
      await tester.tap(_tab(Copy.play));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      expect(find.text(Copy.loading), findsOneWidget);
      await tester.tap(_tab(Copy.profile));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      expect(find.text(Copy.loading), findsOneWidget);

      if (failure == null) {
        learning.pending.complete([]);
        directory.pending.complete(const DirectoryResults());
      } else {
        learning.pending.completeError(failure);
        directory.pending.completeError(failure);
      }
      await tester.pumpAndSettle();
      expect(
        find.text(failure == null ? Copy.savedEmpty : directoryMessage),
        findsOneWidget,
      );
      await tester.tap(_tab(Copy.play));
      await tester.pumpAndSettle();
      expect(find.text(directoryMessage), findsOneWidget);
      await tester.tap(_tab(Copy.learn));
      await tester.pumpAndSettle();
      expect(find.text(learningMessage), findsOneWidget);
      if (failure != null) {
        expect(find.text(Copy.startCourse), findsOneWidget);
      }
    });
  }

  testWidgets('onboarding saves the starting city, sport and level together', (
    tester,
  ) async {
    _phone(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(SportConnect(preferences: prefs));
    await tester.tap(find.text(Copy.getStarted));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.place('Karachi', 'Pakistan')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Canada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.next));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Football'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Badminton'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.recreational));
    await tester.tap(find.text(Copy.startLearning));
    await tester.pumpAndSettle();
    expect(prefs.getStringList('ui-onboarding'), [
      'CA',
      'badminton',
      'recreational',
    ]);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Toronto'), findsOneWidget);
  });
}
