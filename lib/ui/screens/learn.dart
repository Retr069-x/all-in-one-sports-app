import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../app_state.dart';
import '../../data.dart';
import '../../repositories.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import '../widgets/learn_feature_card.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({
    super.key,
    required this.state,
    required this.repository,
    required this.openCourse,
    required this.changeRegion,
    required this.askQuestion,
  });

  final AppState state;
  final LearningRepository repository;
  final ValueChanged<Sport> openCourse;
  final VoidCallback changeRegion;
  final void Function(Sport, String) askQuestion;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  final search = TextEditingController();
  late Future<List<Sport>> courses = Future.sync(widget.repository.load);
  late final entrance = AnimationController(
    vsync: this,
    duration: motionDuration,
  );
  bool entranceQueued = false;

  @override
  void didUpdateWidget(LearnScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) {
      courses = Future.sync(widget.repository.load);
    }
  }

  @override
  void dispose() {
    search.dispose();
    entrance.dispose();
    super.dispose();
  }

  void _startEntrance() {
    if (entranceQueued) return;
    entranceQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        entrance.value = 1;
      } else {
        entrance.forward();
      }
    });
  }

  Widget _reveal(Widget child, {required Key key, required double start}) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final progress = entrance.drive(
      CurveTween(curve: Interval(start, 1, curve: Curves.easeOutCubic)),
    );
    return FadeTransition(
      key: key,
      opacity: progress.drive(Tween(begin: .6, end: 1.0)),
      child: SlideTransition(
        position: progress.drive(
          Tween(begin: const Offset(0, .045), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Sport>>(
    future: courses,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const ContentList(
          children: [
            SectionHeader(Copy.learnTitle, prominent: true),
            StatusBanner(ContentState.loading),
          ],
        );
      }
      final catalogue = snapshot.data ?? sports;
      if (catalogue.isEmpty) {
        return const ContentList(
          children: [
            SectionHeader(Copy.learnTitle, prominent: true),
            StatusBanner(ContentState.empty, detail: Copy.noCourses),
          ],
        );
      }
      final offline = snapshot.error is OfflineFailure;
      return _content(
        context,
        catalogue,
        snapshot.hasError
            ? StatusBanner(
                offline ? ContentState.offline : ContentState.error,
                detail: offline ? Copy.learningOffline : Copy.catalogError,
                onRetry: () => setState(
                  () => courses = Future.sync(widget.repository.load),
                ),
              )
            : null,
      );
    },
  );

  Widget _content(BuildContext context, List<Sport> catalogue, Widget? status) {
    final state = widget.state;
    final preferred = state.inProgress ?? state.starterSport;
    final featured = catalogue.firstWhere(
      (sport) => sport.id == preferred.id,
      orElse: () => catalogue.first,
    );
    final started = state.completed(featured).length;
    final region = state.region;
    final query = search.text.trim().toLowerCase();
    if (query.isEmpty) _startEntrance();
    final numbers = NumberFormat.decimalPattern('en');
    final matches = catalogue
        .where(
          (sport) =>
              '${sport.name} ${sport.format}'.toLowerCase().contains(query),
        )
        .toList();
    final dates = DateFormat.yMMMd('en_US');
    final ranking = region.ranking
        .where((id) => catalogue.any((sport) => sport.id == id))
        .toList();
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
                  child: AppText(
                    Copy.appName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: widget.changeRegion,
              icon: const Icon(Symbols.location_on, size: 18),
              label: AppText(region.city),
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
        if (status != null) ...[status, const SizedBox(height: Space.x4)],
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
          _reveal(
            LearnFeatureCard(
              sport: featured,
              detail: started > 0
                  ? Copy.completed(
                      numbers.format(started),
                      numbers.format(featured.lessons.length),
                    )
                  : Copy.courseInfo(numbers.format(featured.lessons.length)),
              progress: started / featured.lessons.length,
              onOpen: () => widget.openCourse(featured),
            ),
            key: const ValueKey('learn-feature-entrance'),
            start: 0,
          ),
          const SizedBox(height: Space.x6),
          _reveal(
            _CourseShelf(
              catalogue: catalogue,
              numbers: numbers,
              onOpen: widget.openCourse,
            ),
            key: const ValueKey('learn-shelf-entrance'),
            start: .25,
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
                          child: AppText(question),
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
          for (final (index, id) in ranking.indexed)
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

class _CourseShelf extends StatelessWidget {
  const _CourseShelf({
    required this.catalogue,
    required this.numbers,
    required this.onOpen,
  });

  final List<Sport> catalogue;
  final NumberFormat numbers;
  final ValueChanged<Sport> onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Space.x3,
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Space.x3,
        runSpacing: Space.x1,
        children: [
          const SectionHeader(Copy.browseCourses),
          AppText(
            Copy.sportCount(catalogue.length, numbers.format(catalogue.length)),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      LayoutBuilder(
        builder: (context, constraints) {
          final largeText = MediaQuery.textScalerOf(context).scale(16) > 21;
          final width =
              (largeText
                      ? (constraints.maxWidth * .68).clamp(160.0, 236.0)
                      : (constraints.maxWidth * .43).clamp(120.0, 160.0))
                  .toDouble();
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Space.x2,
              children: [
                for (final sport in catalogue)
                  SizedBox(
                    width: width,
                    child: SportTile(
                      id: sport.id,
                      name: sport.name,
                      icon: sport.icon,
                      detail: Copy.courseInfo(
                        numbers.format(sport.lessons.length),
                      ),
                      onTap: () => onOpen(sport),
                      compact: true,
                      shared: true,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ],
  );
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
        leading: AppText(position),
        title: AppText(sport.name),
        trailing: const Icon(Symbols.chevron_right),
      ),
    );
  }
}
