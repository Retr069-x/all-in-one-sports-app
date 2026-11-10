import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app_state.dart';
import '../../data.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    required this.state,
    required this.openCourse,
    required this.changeRegion,
    required this.askQuestion,
  });

  final AppState state;
  final ValueChanged<Sport> openCourse;
  final VoidCallback changeRegion;
  final void Function(Sport, String) askQuestion;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final featured = state.inProgress ?? sports.first;
    final started = state.completed(featured).length;
    final region = state.region;
    final query = search.text.trim().toLowerCase();
    final numbers = NumberFormat.decimalPattern('en');
    final matches = sports
        .where(
          (sport) =>
              '${sport.name} ${sport.format}'.toLowerCase().contains(query),
        )
        .toList();
    final dates = DateFormat.yMMMd('en_US');
    final dateRange =
        '${dates.format(DateTime(2026, 11, 1))} – ${dates.format(DateTime(2026, 11, 7))}';

    return ContentList(
      children: [
        Wrap(
          spacing: Space.x3,
          runSpacing: Space.x1,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Space.x2,
              children: [
                const Icon(Symbols.bolt, color: brand),
                Flexible(
                  child: Text(
                    Copy.appName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: widget.changeRegion,
              icon: const Icon(Symbols.location_on, size: 18),
              label: Text(region.city),
            ),
          ],
        ),
        const SizedBox(height: Space.x4),
        const SectionHeader(
          Copy.learnTitle,
          detail: Copy.learnIntro,
          prominent: true,
        ),
        const SizedBox(height: Space.x4),
        AppSearchField(controller: search, onChanged: (_) => setState(() {})),
        const SizedBox(height: Space.x4),
        if (query.isNotEmpty) ...[
          if (matches.isEmpty)
            const StatusBanner(ContentState.empty, detail: Copy.searchEmpty),
          for (final sport in matches)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: Space.x2),
              child: SportTile(
                id: sport.id,
                name: sport.name,
                icon: sport.icon,
                detail: sport.format,
                onTap: () => widget.openCourse(sport),
                shared: true,
              ),
            ),
        ] else ...[
          CourseCard(
            eyebrow: started > 0 ? Copy.continueLearning : Copy.featured,
            title: featured.name,
            detail: started > 0
                ? Copy.completed(
                    numbers.format(started),
                    numbers.format(featured.lessons.length),
                  )
                : Copy.courseInfo(numbers.format(featured.lessons.length)),
            action: started > 0 ? Copy.continueCourse : Copy.startCourse,
            onTap: () => widget.openCourse(featured),
            trailing: started > 0
                ? ProgressRing(
                    value: started / featured.lessons.length,
                    label: Copy.progress,
                    onDark: true,
                  )
                : SportBadge(id: featured.id, icon: featured.icon),
          ),
          const SizedBox(height: Space.x6),
          const SectionHeader(Copy.browseCourses),
          const SizedBox(height: Space.x3),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.x2,
              children: [
                for (final sport in sports)
                  SizedBox(
                    width: 156,
                    child: SportTile(
                      id: sport.id,
                      name: sport.name,
                      icon: sport.icon,
                      detail: Copy.courseInfo(
                        numbers.format(sport.lessons.length),
                      ),
                      onTap: () => widget.openCourse(sport),
                      compact: true,
                      shared: true,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.x6),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Space.x2,
                children: [
                  const SectionHeader(Copy.ask, detail: Copy.askIntro),
                  const DemoDataBadge(),
                  Wrap(
                    spacing: Space.x2,
                    runSpacing: Space.x2,
                    children: [
                      for (final question in Copy.suggested.take(2))
                        OutlinedButton(
                          onPressed: () =>
                              widget.askQuestion(featured, question),
                          child: Text(question),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.x6),
          SectionHeader(
            Copy.trending(region.country),
            detail: '${Copy.rankingSource} · $dateRange',
          ),
          const SizedBox(height: Space.x2),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: DemoDataBadge(),
          ),
          const SizedBox(height: Space.x3),
          for (final (index, id) in region.ranking.indexed)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: Space.x2),
              child: _TrendingTile(
                id: id,
                position: Copy.rank(numbers.format(index + 1)),
                openCourse: widget.openCourse,
              ),
            ),
        ],
      ],
    );
  }
}

class _TrendingTile extends StatelessWidget {
  const _TrendingTile({
    required this.id,
    required this.position,
    required this.openCourse,
  });
  final String id;
  final String position;
  final ValueChanged<Sport> openCourse;

  @override
  Widget build(BuildContext context) {
    final sport = sports.firstWhere((sport) => sport.id == id);
    return Card(
      child: ListTile(
        onTap: () => openCourse(sport),
        minTileHeight: 48,
        leading: Text(position),
        title: Text(sport.name),
        trailing: const Icon(Symbols.chevron_right),
      ),
    );
  }
}
