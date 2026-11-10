import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:material_symbols_icons/symbols.dart';

import '../../app_state.dart';
import '../../data.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';
import '../widgets/region_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state});
  final AppState state;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

String playerLevelName(PlayerLevel value) => switch (value) {
  PlayerLevel.beginner => Copy.beginner,
  PlayerLevel.recreational => Copy.recreational,
  PlayerLevel.returning => Copy.returningPlayer,
};

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;
  late Region region = widget.state.region;
  Sport sport = sports.first;
  PlayerLevel level = PlayerLevel.beginner;
  bool saving = false;
  bool error = false;

  Future<void> finish() async {
    setState(() {
      saving = true;
      error = false;
    });
    final success = await widget.state.finishOnboarding(region, sport, level);
    if (!mounted) return;
    setState(() {
      saving = false;
      error = !success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final numbers = NumberFormat.decimalPattern('en_US');
    return Scaffold(
      body: SafeArea(
        child: ContentList(
          children: [
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Symbols.bolt, size: 28),
                AppText(
                  Copy.appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: Space.x6),
            AppText(
              Copy.stepNumber(numbers.format(step + 1), numbers.format(3)),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: Space.x3),
            if (step == 0) ...[
              const SectionHeader(
                Copy.welcomeTitle,
                detail: Copy.welcomeDetail,
                prominent: true,
              ),
              const SizedBox(height: Space.x6),
              CourseCard(
                eyebrow: Copy.beginner,
                title: Copy.welcomeCardTitle,
                detail: Copy.welcomeCardDetail,
                action: Copy.getStarted,
                onTap: () => setState(() => step = 1),
              ),
            ] else if (step == 1) ...[
              const SectionHeader(
                Copy.selectCountry,
                detail: Copy.regionHelp,
                prominent: true,
              ),
              const SizedBox(height: Space.x4),
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: DemoDataBadge(),
              ),
              const SizedBox(height: Space.x4),
              OutlinedButton.icon(
                onPressed: () async {
                  final selected = await showRegionPicker(context, region);
                  if (mounted && selected != null) {
                    setState(() => region = selected);
                  }
                },
                icon: const Icon(Symbols.location_on),
                label: AppText(Copy.place(region.city, region.country)),
              ),
              const SizedBox(height: Space.x4),
              FilledButton(
                onPressed: () => setState(() => step = 2),
                child: const AppText(Copy.next),
              ),
            ] else ...[
              const SectionHeader(
                Copy.firstSport,
                detail: Copy.firstSportDetail,
                prominent: true,
              ),
              const SizedBox(height: Space.x4),
              OutlinedButton.icon(
                icon: Icon(sport.icon),
                label: AppText(sport.name),
                onPressed: () async {
                  final picked = await showDialog<Sport>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const AppText(Copy.selectSport),
                      children: [
                        for (final item in sports)
                          ListTile(
                            minTileHeight: 48,
                            title: AppText(item.name),
                            selected: item == sport,
                            onTap: () => Navigator.pop(context, item),
                          ),
                      ],
                    ),
                  );
                  if (mounted && picked != null) setState(() => sport = picked);
                },
              ),
              const SizedBox(height: Space.x4),
              const SectionHeader(Copy.playLevel),
              const SizedBox(height: Space.x2),
              Wrap(
                spacing: Space.x2,
                runSpacing: Space.x2,
                children: [
                  for (final item in PlayerLevel.values)
                    ChoiceChip(
                      label: AppText(playerLevelName(item)),
                      selected: item == level,
                      onSelected: (_) => setState(() => level = item),
                    ),
                ],
              ),
              const SizedBox(height: Space.x4),
              if (saving) const StatusBanner(ContentState.loading),
              if (error)
                const StatusBanner(ContentState.error, detail: Copy.saveError),
              FilledButton(
                onPressed: saving ? null : finish,
                child: const AppText(Copy.startLearning),
              ),
            ],
            if (step > 0) ...[
              const SizedBox(height: Space.x2),
              TextButton(
                onPressed: saving ? null : () => setState(() => step--),
                child: const AppText(Copy.back),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
