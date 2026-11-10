import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportconnect/data.dart';
import 'package:sportconnect/main.dart';
import 'package:sportconnect/repositories.dart';
import 'package:sportconnect/ui/screens/ask.dart';
import 'package:sportconnect/ui/strings.dart';

class _ControlledAi implements AiRepository {
  final requests = <Completer<AiReply>>[];

  @override
  Future<AiReply> ask(Sport sport, String question, {Lesson? context}) {
    final request = Completer<AiReply>();
    requests.add(request);
    return request.future;
  }
}

class _DeniedLocation implements LocationRepository {
  @override
  Future<LocationResult> locate() async =>
      (status: LocationStatus.denied, region: null);

  @override
  Future<void> openSettings() async {}
}

Finder _destination(String label) =>
    find.widgetWithText(NavigationDestination, label);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'demo answers are sourced and can decline unsupported questions',
    () async {
      const repository = MockAiRepository();
      final football = sports.first;
      final answer = await repository.ask(football, Copy.questionEquipment);
      expect(answer.outcome, AiOutcome.answer);
      expect(answer.sources.single.id, 'equipment');
      expect(answer.text, answer.sources.single.body);
      expect(
        (await repository.ask(football, 'Hello')).outcome,
        AiOutcome.clarification,
      );
      expect(
        (await repository.ask(football, 'Who won the 1998 final?')).outcome,
        AiOutcome.insufficient,
      );
    },
  );

  testWidgets(
    'Ask AI covers empty, loading, offline, retry and lesson sources',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(412, 915);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final ai = _ControlledAi();
      await tester.pumpWidget(
        SportConnect(
          preferences: await SharedPreferences.getInstance(),
          ai: ai,
        ),
      );
      await tester.tap(_destination(Copy.ask));
      await tester.pumpAndSettle();
      expect(find.text(Copy.askEmpty), findsOneWidget);

      await tester.enterText(find.byType(TextField), Copy.questionEquipment);
      await tester.tap(find.byTooltip(Copy.send));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));
      expect(ai.requests, hasLength(1));
      final chatScroll = find
          .descendant(
            of: find.byType(AskScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text(Copy.typing),
        160,
        scrollable: chatScroll,
      );
      expect(find.text(Copy.typing), findsOneWidget);
      ai.requests.single.completeError(const OfflineFailure());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(Copy.retry),
        100,
        scrollable: chatScroll,
      );
      expect(find.text(Copy.aiOffline), findsOneWidget);
      await tester.tap(find.text(Copy.retry));
      await tester.pump();
      final lesson = sports.first.lessons[1];
      ai.requests.last.complete(
        AiReply(AiOutcome.answer, lesson.body, sources: [lesson]),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(OutlinedButton, lesson.title),
        100,
        scrollable: chatScroll,
      );
      await tester.tap(find.widgetWithText(OutlinedButton, lesson.title));
      await tester.pumpAndSettle();
      expect(find.text(Copy.courseSource), findsOneWidget);
    },
  );

  testWidgets(
    'Play falls back to area search and Profile keeps a saved venue',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(412, 915);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        SportConnect(preferences: preferences, location: _DeniedLocation()),
      );
      await tester.tap(_destination(Copy.play));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Copy.useLocation));
      await tester.pumpAndSettle();
      expect(find.text(Copy.locationDenied), findsOneWidget);
      await tester.tap(find.text(Copy.searchArea));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Toronto');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Canada'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Copy.communityCentre('Toronto')));
      await tester.pumpAndSettle();
      expect(
        find.text(Copy.field(Copy.address, Copy.notProvided)),
        findsOneWidget,
      );
      await tester.tap(find.text(Copy.save));
      await tester.pumpAndSettle();
      expect(preferences.getStringList('ui-saved-venue'), ['CA-community']);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(_destination(Copy.profile));
      await tester.pumpAndSettle();
      expect(find.text(Copy.communityCentre('Toronto')), findsOneWidget);
    },
  );
}
