import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import 'components.dart';

class LearnFeatureCard extends StatelessWidget {
  const LearnFeatureCard({
    super.key,
    required this.sport,
    required this.detail,
    required this.progress,
    required this.onOpen,
  });

  final Sport sport;
  final String detail;
  final double progress;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tone = sportTone(context, sport.id);
    final inProgress = progress > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ink,
        borderRadius: heroRadius,
        border: Border.all(color: tone.accent.withValues(alpha: .42)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.x4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showArtwork =
                constraints.maxWidth >= 248 &&
                MediaQuery.textScalerOf(context).scale(16) <= 21;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.x3,
              children: [
                Row(
                  spacing: Space.x3,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Space.x1,
                        children: [
                          AppText(
                            inProgress ? Copy.continueLearning : Copy.featured,
                            style: text.labelMedium?.copyWith(color: lime),
                          ),
                          AppText(
                            sport.name,
                            style: text.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          AppText(
                            detail,
                            style: text.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showArtwork)
                      SizedBox.square(
                        dimension: 88,
                        child: CustomPaint(
                          painter: _TrainingLines(tone.accent),
                          child: Center(
                            child: inProgress
                                ? ProgressRing(
                                    value: progress,
                                    label: Copy.progress,
                                    onDark: true,
                                  )
                                : ExcludeSemantics(
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: tone.accent,
                                      foregroundColor: tone.onAccent,
                                      child: Icon(sport.icon, size: 28),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (!showArtwork && inProgress)
                  LinearProgressIndicator(
                    value: progress,
                    color: lime,
                    backgroundColor: Colors.white24,
                    semanticsLabel: Copy.progress,
                  ),
                FilledButton.icon(
                  onPressed: onOpen,
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: ink,
                  ),
                  icon: const Icon(Symbols.play_arrow, size: 20),
                  label: AppText(
                    inProgress ? Copy.continueCourse : Copy.startCourse,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrainingLines extends CustomPainter {
  const _TrainingLines(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final stroke = Paint()
      ..color = accent.withValues(alpha: .44)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(centre, size.width * .43, stroke);
    canvas.drawCircle(centre, size.width * .36, stroke);
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-.58);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * .94,
        height: size.height * .48,
      ),
      stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrainingLines oldDelegate) =>
      accent != oldDelegate.accent;
}
