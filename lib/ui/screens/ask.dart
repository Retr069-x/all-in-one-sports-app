import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data.dart';
import '../../repositories.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

class AskSeed {
  const AskSeed(this.sport, this.question, {this.lesson});
  final Sport sport;
  final String question;
  final Lesson? lesson;
}

class AskScreen extends StatefulWidget {
  const AskScreen({
    super.key,
    required this.repository,
    required this.openLesson,
    this.seed,
  });

  final AiRepository repository;
  final void Function(Sport, Lesson) openLesson;
  final AskSeed? seed;

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _Turn {
  _Turn(this.sport, this.question, this.context);
  final Sport sport;
  final String question;
  final Lesson? context;
  AiReply? reply;
  ContentState? failure;
}

class _AskScreenState extends State<AskScreen> {
  final draft = TextEditingController();
  final scroll = ScrollController();
  final turns = <_Turn>[];
  late Sport sport = widget.seed?.sport ?? sports.first;
  Lesson? lesson;
  _Turn? pending;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  @override
  void didUpdateWidget(AskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seed != widget.seed) _seed();
  }

  void _seed() {
    if (widget.seed case final seed?) {
      sport = seed.sport;
      lesson = seed.lesson;
      draft.text = seed.question;
    }
  }

  @override
  void dispose() {
    draft.dispose();
    scroll.dispose();
    super.dispose();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scroll.hasClients) return;
      final end = scroll.position.maxScrollExtent;
      if (MediaQuery.disableAnimationsOf(context)) {
        scroll.jumpTo(end);
      } else {
        scroll.animateTo(end, duration: motionDuration, curve: Curves.easeOut);
      }
    });
  }

  void sendDraft(String value) {
    final text = value.trim();
    if (text.isEmpty || pending != null) return;
    draft.clear();
    FocusScope.of(context).unfocus();
    send(_Turn(sport, text, lesson));
  }

  Future<void> send(_Turn turn) async {
    if (pending != null) return;
    setState(() {
      if (!turns.contains(turn)) turns.add(turn);
      turn.failure = null;
      pending = turn;
    });
    _toEnd();
    try {
      final reply = await widget.repository.ask(
        turn.sport,
        turn.question,
        context: turn.context,
      );
      if (mounted) setState(() => turn.reply = reply);
    } on OfflineFailure {
      if (mounted) setState(() => turn.failure = ContentState.offline);
    } on Exception {
      if (mounted) setState(() => turn.failure = ContentState.error);
    } finally {
      if (mounted) {
        setState(() => pending = null);
        _toEnd();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: ContentList(
          controller: scroll,
          children: [
            const SectionHeader(
              Copy.askTitle,
              detail: Copy.askIntro,
              prominent: true,
            ),
            const SizedBox(height: Space.x2),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: DemoDataBadge(),
            ),
            const SizedBox(height: Space.x4),
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x1,
              children: [
                for (final item in sports)
                  ChoiceChip(
                    label: AppText(item.name),
                    selected: item == sport,
                    onSelected: (_) => setState(() {
                      sport = item;
                      lesson = null;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: Space.x4),
            if (turns.isEmpty)
              const StatusBanner(ContentState.empty, detail: Copy.askEmpty),
            const SizedBox(height: Space.x2),
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x2,
              children: [
                for (final question in Copy.suggested)
                  OutlinedButton(
                    onPressed: pending == null
                        ? () => send(_Turn(sport, question, lesson))
                        : null,
                    child: AppText(question),
                  ),
              ],
            ),
            for (final turn in turns) ...[
              const SizedBox(height: Space.x4),
              _Message(
                title: Copy.field(Copy.you, turn.sport.name),
                text: turn.question,
              ),
              const SizedBox(height: Space.x2),
              if (turn == pending)
                const StatusBanner(ContentState.loading, detail: Copy.typing)
              else if (turn.failure case final failure?)
                StatusBanner(
                  failure,
                  detail: failure == ContentState.offline
                      ? Copy.aiOffline
                      : Copy.aiError,
                  onRetry: () => send(turn),
                )
              else if (turn.reply case final reply?)
                _Message(
                  title: switch (reply.outcome) {
                    AiOutcome.answer => Copy.lessonAnswer,
                    AiOutcome.clarification => Copy.clarification,
                    AiOutcome.insufficient => Copy.insufficient,
                  },
                  text: reply.text,
                  demo: true,
                  sources: [
                    for (final item in reply.sources)
                      SourceChip(
                        label: item.title,
                        onTap: () => widget.openLesson(turn.sport, item),
                      ),
                  ],
                ),
            ],
            const SizedBox(height: Space.x4),
            AppText(Copy.askNote, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: contentWidth),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            Space.x4,
            Space.x2,
            Space.x4,
            Space.x2,
          ),
          child: Row(
            spacing: Space.x2,
            children: [
              Expanded(
                child: TextField(
                  controller: draft,
                  decoration: const InputDecoration(
                    labelText: Copy.askPlaceholder,
                  ),
                  textInputAction: TextInputAction.send,
                  inputFormatters: [LengthLimitingTextInputFormatter(320)],
                  onSubmitted: sendDraft,
                ),
              ),
              IconButton.filled(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: pending == null ? () => sendDraft(draft.text) : null,
                tooltip: Copy.send,
                icon: const Icon(Symbols.send),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.title,
    required this.text,
    this.sources = const [],
    this.demo = false,
  });
  final String title;
  final String text;
  final bool demo;
  final List<Widget> sources;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(Space.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.x2,
        children: [
          Wrap(
            spacing: Space.x2,
            runSpacing: Space.x1,
            children: [
              AppText(title, style: Theme.of(context).textTheme.titleSmall),
              if (demo) const DemoDataBadge(),
            ],
          ),
          AppText(text),
          if (sources.isNotEmpty)
            Wrap(spacing: Space.x2, runSpacing: Space.x1, children: sources),
        ],
      ),
    ),
  );
}
