import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_symbols_icons/symbols.dart';

import '../strings.dart';
import '../theme/app_theme.dart';

class AppText extends StatelessWidget {
  const AppText(this.data, {super.key, this.style});

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final layout = Directionality.of(context);
    final content = Localizations.localeOf(context).languageCode == 'en'
        ? TextDirection.ltr
        : layout;
    return Text(
      data,
      style: style,
      textDirection: content,
      textAlign: content == layout ? TextAlign.start : TextAlign.end,
    );
  }
}

PageRoute<void> appRoute(BuildContext context, WidgetBuilder buildPage) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : motionDuration;
  return PageRouteBuilder<void>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, animation, secondary) => buildPage(context),
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class ContentList extends StatelessWidget {
  const ContentList({super.key, required this.children, this.controller});

  final List<Widget> children;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: contentWidth),
      child: ListView(
        controller: controller,
        padding: const EdgeInsetsDirectional.fromSTEB(
          Space.x4,
          Space.x4,
          Space.x4,
          Space.x6,
        ),
        children: children,
      ),
    ),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.detail,
    this.prominent = false,
  });

  final String title;
  final String? detail;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.x1,
      children: [
        Semantics(
          header: true,
          child: AppText(
            title,
            style: prominent
                ? theme.textTheme.headlineLarge
                : theme.textTheme.titleLarge,
          ),
        ),
        if (detail case final value?)
          AppText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class SportBadge extends StatelessWidget {
  const SportBadge({
    super.key,
    required this.id,
    required this.icon,
    this.shared = false,
  });

  final String id;
  final IconData icon;
  final bool shared;

  @override
  Widget build(BuildContext context) {
    final tone = sportTone(context, id);
    final badge = DecoratedBox(
      decoration: BoxDecoration(color: tone.accent, borderRadius: chipRadius),
      child: SizedBox.square(
        dimension: 48,
        child: Icon(icon, color: tone.onAccent, size: 25),
      ),
    );
    return ExcludeSemantics(
      child: shared && !MediaQuery.disableAnimationsOf(context)
          ? Hero(tag: 'sport-$id', child: badge)
          : badge,
    );
  }
}

class SportTile extends StatelessWidget {
  const SportTile({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    required this.detail,
    required this.onTap,
    this.compact = false,
    this.shared = false,
  });

  final String id;
  final String name;
  final IconData icon;
  final String detail;
  final VoidCallback onTap;
  final bool compact;
  final bool shared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = sportTone(context, id);
    final badge = SportBadge(id: id, icon: icon, shared: shared);
    final labels = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Space.x1,
      children: [
        AppText(
          name,
          style: theme.textTheme.titleMedium?.copyWith(color: tone.onContainer),
        ),
        AppText(
          detail,
          style: theme.textTheme.bodySmall?.copyWith(color: tone.onContainer),
        ),
      ],
    );
    return Material(
      color: tone.container,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Space.x3),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Space.x2,
                  children: [badge, labels],
                )
              : Row(
                  spacing: Space.x3,
                  children: [
                    badge,
                    Expanded(child: labels),
                    Icon(
                      Symbols.chevron_right,
                      color: tone.onContainer,
                      textDirection: Directionality.of(context),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.detail,
    required this.action,
    required this.onTap,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String detail;
  final String action;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(color: ink, borderRadius: heroRadius),
      child: Padding(
        padding: const EdgeInsets.all(Space.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Space.x3,
          children: [
            ?trailing,
            AppText(
              eyebrow,
              style: text.labelMedium?.copyWith(color: lime, letterSpacing: 1),
            ),
            AppText(
              title,
              style: text.headlineMedium?.copyWith(color: Colors.white),
            ),
            AppText(
              detail,
              style: text.bodyMedium?.copyWith(color: Colors.white),
            ),
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: lime,
                foregroundColor: ink,
              ),
              child: AppText(action),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.label,
    this.onDark = false,
  });

  final double value;
  final String label;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = value.clamp(0.0, 1.0).toDouble();
    final percent = NumberFormat.percentPattern('en').format(amount);
    final color = onDark ? lime : theme.colorScheme.primary;
    return Semantics(
      label: label,
      value: percent,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: 64,
          child: TweenAnimationBuilder<double>(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : motionDuration,
            tween: Tween(begin: 0, end: amount),
            builder: (context, current, child) => Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: current,
                  color: color,
                  backgroundColor: onDark
                      ? Colors.white24
                      : theme.colorScheme.surfaceContainerHighest,
                  strokeWidth: 4,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(Space.x3),
                    child: FittedBox(child: child),
                  ),
                ),
              ],
            ),
            child: AppText(
              percent,
              style: theme.textTheme.labelLarge?.copyWith(
                color: onDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DemoDataBadge extends StatelessWidget {
  const DemoDataBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: chipRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.x2,
          vertical: Space.x1,
        ),
        child: AppText(
          Copy.demoData,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    );
  }
}

class SourceChip extends StatelessWidget {
  const SourceChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: const Icon(Symbols.menu_book, size: 18),
    label: AppText(label),
  );
}

enum ContentState { loading, empty, error, offline }

class StatusBanner extends StatelessWidget {
  const StatusBanner(this.state, {super.key, this.detail, this.onRetry});

  final ContentState state;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final (title, icon) = switch (state) {
      ContentState.loading => (Copy.loading, Symbols.hourglass_top),
      ContentState.empty => (Copy.empty, Symbols.inbox),
      ContentState.error => (Copy.error, Symbols.error),
      ContentState.offline => (Copy.offline, Symbols.cloud_off),
    };
    return Semantics(
      liveRegion: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Space.x2,
            children: [
              if (state == ContentState.loading)
                const LinearProgressIndicator()
              else
                Icon(icon),
              AppText(title, style: Theme.of(context).textTheme.titleMedium),
              if (detail case final value?) AppText(value),
              if (onRetry case final retry?)
                TextButton(onPressed: retry, child: const AppText(Copy.retry)),
            ],
          ),
        ),
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.label = Copy.searchSports,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Symbols.search),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: Copy.clearSearch,
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Symbols.close),
            ),
    ),
  );
}

class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.title,
    required this.details,
    required this.onTap,
  });
  final String title;
  final List<String> details;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _DirectoryCard(
    title: title,
    details: details,
    onTap: onTap,
    icon: Symbols.location_on,
  );
}

class CoachCard extends StatelessWidget {
  const CoachCard({
    super.key,
    required this.title,
    required this.details,
    required this.onTap,
  });
  final String title;
  final List<String> details;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _DirectoryCard(
    title: title,
    details: details,
    onTap: onTap,
    icon: Symbols.person,
  );
}

class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.title,
    required this.details,
    required this.onTap,
    required this.icon,
  });
  final String title;
  final List<String> details;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Space.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Space.x1,
          children: [
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [Icon(icon), const DemoDataBadge()],
            ),
            AppText(title, style: Theme.of(context).textTheme.titleMedium),
            for (final detail in details) AppText(detail),
          ],
        ),
      ),
    ),
  );
}
