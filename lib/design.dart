import 'dart:math' as math;

import 'package:flutter/material.dart';

const ink = Color(0xFF19162B);
const muted = Color(0xFF625E76);
const accent = Color(0xFF5239D7);
const lavender = Color(0xFFEDE8FF);
const lime = Color(0xFFE1FF78);
const pageColor = Color(0xFFF7F6FB);
const outline = Color(0xFFE6E2F0);

ThemeData sportConnectTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: accent,
    primary: accent,
    surface: Colors.white,
    onSurface: ink,
  ),
  scaffoldBackgroundColor: pageColor,
  cardTheme: CardThemeData(
    margin: const EdgeInsets.only(bottom: 8),
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: outline),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: pageColor,
    scrolledUnderElevation: 0,
    foregroundColor: ink,
  ),
  navigationBarTheme: NavigationBarThemeData(
    height: 68,
    backgroundColor: Colors.white,
    indicatorColor: lavender,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        color: states.contains(WidgetState.selected) ? accent : muted,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    ),
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    shape: RoundedRectangleBorder(),
    collapsedShape: RoundedRectangleBorder(),
    iconColor: accent,
    collapsedIconColor: muted,
  ),
  inputDecorationTheme: InputDecorationThemeData(
    filled: true,
    fillColor: Colors.white,
    prefixIconColor: accent,
    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: outline),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: accent,
    linearTrackColor: lavender,
  ),
);

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.label, {super.key, this.color = accent});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: color,
      fontSize: 11,
      letterSpacing: 1.4,
      fontWeight: FontWeight.w800,
    ),
  );
}

class PitchArtwork extends CustomPainter {
  const PitchArtwork();

  Offset polar(Offset centre, double radius, double angle) =>
      centre + Offset(math.cos(angle), math.sin(angle)) * radius;

  Path polygon(Iterable<Offset> points) =>
      Path()..addPolygon(points.toList(), true);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 230, size.height / 230);
    const centre = Offset(126, 111);

    final orbit = Paint()
      ..color = const Color(0x407FE5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-.48);
    for (final width in [170.0, 204.0, 230.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: width, height: width * .62),
        orbit,
      );
    }
    canvas.restore();

    final lines = Paint()
      ..color = const Color(0xB0DFFF77)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(21, 153), const Offset(54, 137), lines);
    canvas.drawLine(const Offset(27, 176), const Offset(67, 155), lines);
    canvas.drawLine(const Offset(163, 33), const Offset(183, 23), lines);
    canvas.drawCircle(const Offset(199, 61), 3, lines);
    canvas.drawCircle(const Offset(48, 66), 2, lines);

    const radius = 62.0;
    final disc = Rect.fromCircle(center: centre, radius: radius);
    canvas.drawShadow(
      Path()..addOval(disc),
      const Color(0xFF161041),
      16,
      false,
    );
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.44, -.55),
          radius: 1.05,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1EEFF), Color(0xFF9584DF)],
          stops: [0, .56, 1],
        ).createShader(disc),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(disc));
    const angle = -1.78;
    const turn = math.pi * 2 / 5;
    final panel = Paint()..color = const Color(0xFF291C67);
    final seam = Paint()
      ..color = const Color(0x8862559B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final core = List.generate(5, (i) => polar(centre, 23, angle + i * turn));
    for (var i = 0; i < 5; i++) {
      final a = angle + i * turn;
      final edge = polar(centre, 55, a);
      canvas.drawLine(core[i], edge, seam);
      canvas.drawPath(
        polygon([
          edge,
          polar(centre, 60, a - .29),
          polar(centre, 75, a - .27),
          polar(centre, 75, a + .24),
          polar(centre, 60, a + .29),
        ]),
        panel,
      );
    }
    canvas.drawPath(polygon(core), panel);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(PitchArtwork oldDelegate) => false;
}
