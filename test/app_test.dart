import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportconnect/data.dart';
import 'package:sportconnect/main.dart';
import 'package:sportconnect/ui/screens/learn.dart';
import 'package:sportconnect/ui/strings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'ui-onboarded': true}));

  test('all eleven sample rankings refer to the twelve-sport catalogue', () {
    final ids = sports.map((sport) => sport.id).toSet();
    expect(ids, hasLength(12));
    expect(regions.map((region) => region.code).toSet(), hasLength(11));
    for (final region in regions) {
      expect(region.ranking.toSet(), hasLength(region.ranking.length));
      expect(ids, containsAll(region.ranking));
    }
  });

  testWidgets('completes a lesson and restores progress after reopening', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(SportConnect(preferences: preferences));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.startCourse));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1. Aim of the game'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark complete'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1 of 5 lessons complete'), findsOneWidget);
    expect(preferences.getStringList('completed-football'), ['aim']);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(SportConnect(preferences: preferences));
    await tester.tap(find.widgetWithText(NavigationDestination, Copy.profile));
    await tester.pumpAndSettle();
    expect(find.text('1 of 5 lessons complete'), findsOneWidget);
  });

  testWidgets('country selection changes both rankings and local discovery', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(SportConnect(preferences: preferences));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karachi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Canada'));
    await tester.pumpAndSettle();
    final discoverScroll = find
        .descendant(
          of: find.byType(LearnScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    final firstRank = find.widgetWithText(ListTile, '#1');
    await tester.scrollUntilVisible(firstRank, 160, scrollable: discoverScroll);
    expect(find.text('Trending in Canada'), findsOneWidget);
    expect(
      find.descendant(of: firstRank, matching: find.text('Badminton')),
      findsOneWidget,
    );
    expect(preferences.getString('country'), 'CA');

    await tester.tap(find.widgetWithText(NavigationDestination, Copy.play));
    await tester.pumpAndSettle();
    expect(find.text('Toronto, Canada'), findsOneWidget);
  });

  testWidgets('the quiz gives feedback after wrong and correct answers', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 780);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(SportConnect(preferences: preferences));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Copy.startCourse));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(Copy.quiz), 180);
    await tester.tap(find.text(Copy.quiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The heel'));
    await tester.pump();
    await tester.tap(find.text(Copy.checkAnswer));
    await tester.pumpAndSettle();
    expect(find.text(Copy.revisitAnswer), findsOneWidget);
    await tester.tap(find.text(Copy.retry));
    await tester.pumpAndSettle();
    await tester.tap(find.text('The inside'));
    await tester.pump();
    await tester.tap(find.text(Copy.checkAnswer));
    await tester.pumpAndSettle();
    expect(find.text(Copy.correctAnswer), findsOneWidget);
  });
}
