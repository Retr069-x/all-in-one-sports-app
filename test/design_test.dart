import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportconnect/ui/strings.dart';
import 'package:sportconnect/ui/theme/app_theme.dart';
import 'package:sportconnect/ui/widgets/components.dart';

void main() {
  test('all sport text colours meet AA in both themes', () {
    for (final brightness in Brightness.values) {
      final palette = SportPalette.fromBrightness(brightness);
      expect(palette.tones, hasLength(12));
      for (final tone in palette.tones.values) {
        expect(
          contrastRatio(tone.accent, tone.onAccent),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(tone.container, tone.onContainer),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });

  testWidgets('status banners distinguish their states and support retry', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: ContentList(
            children: [
              const StatusBanner(ContentState.loading),
              const StatusBanner(ContentState.empty),
              StatusBanner(ContentState.error, onRetry: () => retries++),
              const StatusBanner(ContentState.offline),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(Copy.empty), findsOneWidget);
    expect(find.text(Copy.error), findsOneWidget);
    expect(find.text(Copy.offline), findsOneWidget);
    await tester.tap(find.text(Copy.retry));
    expect(retries, 1);
  });

  testWidgets('reduced motion shows the final progress immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.dark),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: ProgressRing(value: .75, label: 'Test progress'),
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .value,
      .75,
    );
    expect(find.text('75%'), findsOneWidget);
  });
}
