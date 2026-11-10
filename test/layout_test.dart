import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportconnect/main.dart';
import 'package:sportconnect/ui/strings.dart';

const screenKey = ValueKey('test-frame');
const sizes = [Size(360, 800), Size(412, 915), Size(720, 1280)];
const tabs = [Copy.learn, Copy.ask, Copy.play, Copy.profile];

Future<void> frame(
  WidgetTester tester,
  Size size,
  Brightness brightness,
  double scale,
  bool rtl,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  SharedPreferences.setMockInitialValues({
    'ui-onboarded': true,
    'ui-theme': brightness.name,
    'ui-rtl': rtl,
  });
  await tester.pumpWidget(
    RepaintBoundary(
      key: screenKey,
      child: SportConnect(preferences: await SharedPreferences.getInstance()),
    ),
  );
  await tester.pumpAndSettle();
}

Finder destination(String label) =>
    find.widgetWithText(NavigationDestination, label);

void main() {
  for (final size in sizes) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        for (final rtl in [false, true]) {
          testWidgets(
            '$size ${brightness.name} scale $scale ${rtl ? 'RTL' : 'LTR'}',
            (tester) async {
              await frame(tester, size, brightness, scale, rtl);
              for (final (index, tab) in tabs.indexed) {
                await tester.tap(destination(tab));
                await tester.pumpAndSettle();
                final bar = tester.widget<NavigationBar>(
                  find.byType(NavigationBar),
                );
                expect(bar.selectedIndex, index);
                expect(
                  Directionality.of(tester.element(find.byType(NavigationBar))),
                  rtl ? TextDirection.rtl : TextDirection.ltr,
                );
                expect(tester.takeException(), isNull);
                final scrollable = find
                    .byWidgetPredicate(
                      (widget) =>
                          widget is Scrollable &&
                          widget.axisDirection == AxisDirection.down,
                    )
                    .first;
                await tester.drag(scrollable, const Offset(0, -420));
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
              }
            },
          );
        }
      }
    }
  }

  group('screen goldens', () {
    setUpAll(() async {
      final families = {
        'Plus Jakarta Sans': 'assets/fonts/PlusJakartaSans.ttf',
        'Inter': 'assets/fonts/Inter.ttf',
        'Noto Sans Arabic': 'assets/fonts/NotoSansArabic.ttf',
        'Noto Sans Devanagari': 'assets/fonts/NotoSansDevanagari.ttf',
        'packages/material_symbols_icons/MaterialSymbolsOutlined':
            'packages/material_symbols_icons/lib/fonts/MaterialSymbolsOutlined.ttf',
        'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
      };
      for (final entry in families.entries) {
        await (FontLoader(
          entry.key,
        )..addFont(rootBundle.load(entry.value))).load();
      }
    });

    for (final (name, tab, size, brightness, scale, rtl) in [
      ('learn-light', Copy.learn, sizes[0], Brightness.light, 1.0, false),
      ('ask-dark', Copy.ask, sizes[1], Brightness.dark, 1.0, false),
      ('play-rtl', Copy.play, sizes[1], Brightness.light, 1.0, true),
      ('profile-large', Copy.profile, sizes[2], Brightness.dark, 2.0, true),
    ]) {
      testWidgets('$name golden', (tester) async {
        await frame(tester, size, brightness, scale, rtl);
        await tester.tap(destination(tab));
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(screenKey),
          matchesGoldenFile('goldens/$name.png'),
        );
      });
    }
  });
}
