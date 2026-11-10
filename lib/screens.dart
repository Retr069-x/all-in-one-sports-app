import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'design.dart';

Set<String> completedLessons(SharedPreferences preferences, Sport sport) {
  final stored = preferences.getStringList('completed-${sport.id}') ?? [];
  return sport.lessons
      .map((lesson) => lesson.id)
      .toSet()
      .intersection(stored.toSet());
}

class HeroPanel extends StatelessWidget {
  const HeroPanel({super.key, required this.sport, required this.onStart});

  final Sport sport;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFF3421A5), Color(0xFF6247F5)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          if (MediaQuery.textScalerOf(context).scale(30) <= 36)
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox.square(
                      dimension: (constraints.maxWidth - 174)
                          .clamp(0, 230)
                          .toDouble(),
                      child: const CustomPaint(painter: PitchArtwork()),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .17),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Eyebrow('FEATURED COURSE', color: lime),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${sport.name}\nfundamentals',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    height: 1.02,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.9,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Beginner · ${sport.lessons.length} lessons',
                  style: const TextStyle(
                    color: Color(0xFFF1ECFF),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 13),
                FilledButton.icon(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: ink,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Start with ${sport.name.toLowerCase()}'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SportShortcut extends StatelessWidget {
  const SportShortcut({super.key, required this.sport, required this.onTap});

  final Sport sport;
  final ValueChanged<Sport> onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: sport.tint,
    borderRadius: BorderRadius.circular(17),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => onTap(sport),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white.withValues(alpha: .65),
              foregroundColor: ink,
              child: Icon(sport.icon, size: 19),
            ),
            const SizedBox(height: 8),
            Text(
              sport.name,
              style: const TextStyle(
                color: ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${sport.lessons.length} lessons',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(
    this.title,
    this.subtitle, {
    super.key,
    this.prominent = false,
  });

  final String title;
  final String subtitle;
  final bool prominent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: prominent ? 34 : 21,
          height: 1.12,
          letterSpacing: prominent ? -1.25 : -.45,
          fontWeight: FontWeight.w900,
          color: ink,
        ),
      ),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: muted, fontSize: 14)),
    ],
  );
}

class SportTile extends StatelessWidget {
  const SportTile({
    super.key,
    required this.sport,
    required this.onTap,
    this.rank,
    this.subtitle,
  });

  final Sport sport;
  final ValueChanged<Sport> onTap;
  final int? rank;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 9,
        children: [
          if (rank case final position?)
            Text(
              '#$position',
              style: const TextStyle(
                fontSize: 12,
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          CircleAvatar(
            radius: 17,
            backgroundColor: sport.tint,
            foregroundColor: ink,
            child: Icon(sport.icon, size: 20),
          ),
        ],
      ),
      title: Text(
        sport.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        subtitle ?? sport.format,
        style: const TextStyle(color: muted),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: accent),
      onTap: () => onTap(sport),
    ),
  );
}

class ProgressSummary extends StatelessWidget {
  const ProgressSummary({super.key, required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: lavender,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('LESSONS COMPLETED'),
        const SizedBox(height: 8),
        Text(
          '$done / $total',
          style: const TextStyle(
            color: ink,
            fontSize: 33,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: done / total,
          semanticsLabel: '$done of $total lessons completed',
          minHeight: 7,
          borderRadius: BorderRadius.circular(4),
          backgroundColor: Colors.white,
        ),
      ],
    ),
  );
}

class SportPage extends StatefulWidget {
  const SportPage({
    super.key,
    required this.sport,
    required this.region,
    required this.preferences,
  });

  final Sport sport;
  final Region region;
  final SharedPreferences preferences;

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  late Set<String> complete = completedLessons(
    widget.preferences,
    widget.sport,
  );
  int? answer;
  bool saving = false;

  Future<void> finish(String id) async {
    if (saving || complete.contains(id)) return;
    setState(() => saving = true);
    final updated = {...complete, id};
    var saved = false;
    try {
      saved = await widget.preferences.setStringList(
        'completed-${widget.sport.id}',
        updated.toList(),
      );
    } on PlatformException {
      saved = false;
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
          if (saved) complete = updated;
        });
        if (!saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not save progress.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sport = widget.sport;
    return Scaffold(
      appBar: AppBar(title: const Text('Beginner course')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sport.tint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: SectionHeading(
                        'How to play ${sport.name.toLowerCase()}',
                        sport.format,
                        prominent: true,
                      ),
                    ),
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.white.withValues(alpha: .72),
                      foregroundColor: ink,
                      child: Icon(sport.icon, size: 27),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${complete.length} of ${sport.lessons.length} lessons complete',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: complete.length / sport.lessons.length,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const SectionHeading(
                'Course lessons',
                'Open a lesson to get started',
              ),
              const SizedBox(height: 8),
              for (final (index, lesson) in sport.lessons.indexed)
                Card(
                  child: ExpansionTile(
                    key: PageStorageKey('${sport.id}-lesson-${lesson.id}'),
                    leading: CircleAvatar(
                      radius: 17,
                      backgroundColor: lavender,
                      foregroundColor: accent,
                      child: Icon(
                        complete.contains(lesson.id)
                            ? Icons.check_circle
                            : Icons.menu_book_outlined,
                        size: 17,
                      ),
                    ),
                    title: Text(
                      '${index + 1}. ${lesson.title}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    children: [
                      Text(
                        lesson.body,
                        style: const TextStyle(color: muted, height: 1.45),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: saving || complete.contains(lesson.id)
                            ? null
                            : () => finish(lesson.id),
                        child: Text(
                          complete.contains(lesson.id)
                              ? 'Completed'
                              : 'Mark complete',
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const SectionHeading('Quick quiz', 'Check your understanding'),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        sport.quiz.question,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      for (final (index, option) in sport.quiz.options.indexed)
                        OutlinedButton(
                          onPressed: () => setState(() => answer = index),
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            backgroundColor: answer == index ? lavender : null,
                            side: BorderSide(
                              color: answer == index ? accent : outline,
                            ),
                          ),
                          child: Text(option),
                        ),
                      if (answer != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Semantics(
                            liveRegion: true,
                            child: Text(
                              answer == sport.quiz.answer
                                  ? 'Correct. ${sport.quiz.explanation}'
                                  : 'Try again. Revisit the lessons if you need a hint.',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SectionHeading(
                'Play in ${widget.region.city}',
                'Demo centres and coaches',
              ),
              const SizedBox(height: 10),
              const DemoNotice(),
              CentreSection(sport: sport, region: widget.region),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF2D6),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF705013)),
        Expanded(
          child: Text(
            'Demo data. These centres, distances and coaches are fictional.',
            style: TextStyle(color: Color(0xFF624614)),
          ),
        ),
      ],
    ),
  );
}

class CentreSection extends StatelessWidget {
  const CentreSection({super.key, required this.sport, required this.region});

  final Sport sport;
  final Region region;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(
        sport.name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      for (final centre in centresFor(sport, region))
        Card(
          child: ExpansionTile(
            key: PageStorageKey('${region.code}-${sport.id}-${centre.name}'),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: sport.tint,
              foregroundColor: ink,
              child: Icon(sport.icon, size: 19),
            ),
            title: Text(
              centre.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${centre.distanceKm} km · Sample distance',
              style: const TextStyle(color: muted),
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            children: [
              Text(
                centre.coach,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(centre.sessions),
            ],
          ),
        ),
    ],
  );
}
