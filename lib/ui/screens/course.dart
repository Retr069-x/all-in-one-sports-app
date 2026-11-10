import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_symbols_icons/symbols.dart';

import '../../app_state.dart';
import '../../data.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

bool _isPractice(Lesson lesson) => {
  'practice',
  'short-pass',
  'straight-hit',
  'short-rally',
}.contains(lesson.id);

String _category(Lesson lesson) {
  if (_isPractice(lesson)) return Copy.practice;
  return switch (lesson.id) {
    'equipment' => Copy.equipment,
    'aim' || 'rules' || 'runs-wickets' || 'serve-score' => Copy.rulesScoring,
    _ => Copy.basics,
  };
}

class CourseScreen extends StatelessWidget {
  const CourseScreen({
    super.key,
    required this.state,
    required this.sport,
    required this.openLesson,
  });
  final AppState state;
  final Sport sport;
  final void Function(Sport, Lesson) openLesson;

  @override
  Widget build(BuildContext context) {
    final numbers = NumberFormat.decimalPattern('en_US');
    return Scaffold(
      appBar: AppBar(title: const AppText(Copy.courseOverview)),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          final completed = state.completed(sport);
          final tone = sportTone(context, sport.id);
          return ContentList(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tone.container,
                  borderRadius: heroRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Space.x6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Space.x2,
                    children: [
                      SportBadge(id: sport.id, icon: sport.icon, shared: true),
                      AppText(
                        sport.name,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: tone.onContainer),
                      ),
                      AppText(
                        sport.format,
                        style: TextStyle(color: tone.onContainer),
                      ),
                      AppText(
                        Copy.courseInfo(numbers.format(sport.lessons.length)),
                        style: TextStyle(color: tone.onContainer),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.x4),
              Wrap(
                spacing: Space.x3,
                runSpacing: Space.x2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ProgressRing(
                    value: completed.length / sport.lessons.length,
                    label: Copy.progress,
                  ),
                  AppText(
                    Copy.completed(
                      numbers.format(completed.length),
                      numbers.format(sport.lessons.length),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.x6),
              const SectionHeader(Copy.courseLessons),
              const SizedBox(height: Space.x2),
              for (final (index, lesson) in sport.lessons.indexed)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: Space.x2),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        completed.contains(lesson.id)
                            ? Symbols.check_circle
                            : Symbols.menu_book,
                      ),
                      title: AppText(
                        Copy.numbered(numbers.format(index + 1), lesson.title),
                      ),
                      subtitle: AppText(
                        completed.contains(lesson.id)
                            ? Copy.field(_category(lesson), Copy.done)
                            : _category(lesson),
                      ),
                      minTileHeight: 48,
                      onTap: () => openLesson(sport, lesson),
                    ),
                  ),
                ),
              const SizedBox(height: Space.x3),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push<void>(
                  appRoute(context, (_) => QuizScreen(sport: sport)),
                ),
                icon: const Icon(Symbols.quiz),
                label: const AppText(Copy.quiz),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.state,
    required this.sport,
    required this.lesson,
    required this.ask,
  });
  final AppState state;
  final Sport sport;
  final Lesson lesson;
  final void Function(Sport, Lesson) ask;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final checked = <int>{};
  bool saving = false;
  String get id => '${widget.sport.id}/${widget.lesson.id}';

  Future<void> _write(Future<bool> Function() operation) async {
    setState(() => saving = true);
    final result = await operation();
    if (!mounted) return;
    setState(() => saving = false);
    if (!result) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: AppText(Copy.saveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sport = widget.sport;
    final lesson = widget.lesson;
    final state = widget.state;
    return Scaffold(
      appBar: AppBar(title: AppText(sport.name)),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) {
          final completed = state.completed(sport).contains(lesson.id);
          final saved = state.isSaved(SavedKind.lesson, id);
          final practice = _isPractice(lesson);
          return ContentList(
            children: [
              SectionHeader(
                lesson.title,
                detail: _category(lesson),
                prominent: true,
              ),
              const SizedBox(height: Space.x3),
              Wrap(
                spacing: Space.x2,
                runSpacing: Space.x2,
                children: [
                  AppText(Copy.field(Copy.gameFormat, sport.format)),
                  const DemoDataBadge(),
                ],
              ),
              const SizedBox(height: Space.x4),
              AppText(
                lesson.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: Space.x4),
              const SectionHeader(Copy.source, detail: Copy.courseSource),
              if (practice) ...[
                const SizedBox(height: Space.x6),
                const SectionHeader(
                  Copy.practiceChecklist,
                  detail: Copy.practiceIntro,
                ),
                const SizedBox(height: Space.x2),
                Card(
                  child: Column(
                    children: [
                      for (final (index, step) in Copy.practiceSteps.indexed)
                        CheckboxListTile(
                          value: checked.contains(index),
                          title: AppText(step),
                          onChanged: (value) => setState(() {
                            if (value == true) {
                              checked.add(index);
                            } else {
                              checked.remove(index);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: Space.x6),
              Wrap(
                spacing: Space.x2,
                runSpacing: Space.x2,
                children: [
                  FilledButton.icon(
                    onPressed:
                        saving ||
                            completed ||
                            (practice &&
                                checked.length != Copy.practiceSteps.length)
                        ? null
                        : () => _write(() => state.complete(sport, lesson)),
                    icon: Icon(
                      completed ? Symbols.check_circle : Symbols.check,
                    ),
                    label: AppText(completed ? Copy.done : Copy.markComplete),
                  ),
                  OutlinedButton.icon(
                    onPressed: saving
                        ? null
                        : () => _write(
                            () => state.toggleSaved(SavedKind.lesson, id),
                          ),
                    icon: Icon(
                      saved ? Symbols.bookmark_remove : Symbols.bookmark_add,
                    ),
                    label: AppText(saved ? Copy.removeSaved : Copy.save),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => widget.ask(sport, lesson),
                    icon: const Icon(Symbols.chat_bubble),
                    label: const AppText(Copy.askAboutLesson),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.sport});
  final Sport sport;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    final quiz = widget.sport.quiz;
    return Scaffold(
      appBar: AppBar(title: const AppText(Copy.quiz)),
      body: ContentList(
        children: [
          SectionHeader(
            quiz.question,
            detail: widget.sport.name,
            prominent: true,
          ),
          const SizedBox(height: Space.x4),
          for (final (index, answer) in quiz.options.indexed)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: Space.x2),
              child: Semantics(
                selected: index == selected,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => selected = index),
                  icon: Icon(
                    index == selected
                        ? Symbols.radio_button_checked
                        : Symbols.radio_button_unchecked,
                  ),
                  label: AppText(answer),
                ),
              ),
            ),
          const SizedBox(height: Space.x3),
          FilledButton(
            onPressed: selected == null
                ? null
                : () => Navigator.of(context).pushReplacement<void, void>(
                    appRoute(
                      context,
                      (_) => QuizResultsScreen(
                        sport: widget.sport,
                        correct: selected == quiz.answer,
                      ),
                    ),
                  ),
            child: const AppText(Copy.checkAnswer),
          ),
        ],
      ),
    );
  }
}

class QuizResultsScreen extends StatelessWidget {
  const QuizResultsScreen({
    super.key,
    required this.sport,
    required this.correct,
  });
  final Sport sport;
  final bool correct;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const AppText(Copy.quizResults)),
    body: ContentList(
      children: [
        SectionHeader(
          correct ? Copy.correctAnswer : Copy.revisitAnswer,
          detail: sport.name,
          prominent: true,
        ),
        const SizedBox(height: Space.x4),
        ProgressRing(value: correct ? 1 : 0, label: Copy.quizScore),
        const SizedBox(height: Space.x4),
        AppText(
          sport.quiz.explanation,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Space.x6),
        Wrap(
          spacing: Space.x2,
          runSpacing: Space.x2,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const AppText(Copy.backToCourse),
            ),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacement<void, void>(
                    appRoute(context, (_) => QuizScreen(sport: sport)),
                  ),
              child: const AppText(Copy.retry),
            ),
          ],
        ),
      ],
    ),
  );
}
