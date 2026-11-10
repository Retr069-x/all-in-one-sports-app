import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:material_symbols_icons/symbols.dart';

import '../../app_state.dart';
import '../../data.dart';
import '../../repositories.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/components.dart';

enum DirectoryKind { venues, coaches }

enum DirectoryView { list, map }

class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.region,
    required this.repository,
    required this.location,
    required this.changeRegion,
    required this.useRegion,
    required this.openVenue,
    required this.openCoach,
  });
  final Region region;
  final DirectoryRepository repository;
  final LocationRepository location;
  final VoidCallback changeRegion;
  final ValueChanged<Region> useRegion;
  final ValueChanged<Venue> openVenue;
  final ValueChanged<Coach> openCoach;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late Future<DirectoryResults> results = widget.repository.find(widget.region);
  DirectoryKind kind = DirectoryKind.venues;
  DirectoryView view = DirectoryView.list;
  Sport? sport;
  double? distance;
  bool locating = false;
  LocationStatus? locationStatus;

  @override
  void didUpdateWidget(PlayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.region != widget.region ||
        oldWidget.repository != widget.repository) {
      results = widget.repository.find(widget.region);
      locationStatus = null;
    }
  }

  Future<void> useLocation() async {
    setState(() {
      locating = true;
      locationStatus = null;
    });
    LocationResult result;
    try {
      result = await widget.location.locate();
    } on Exception {
      result = (status: LocationStatus.unavailable, region: null);
    }
    if (!mounted) return;
    setState(() {
      locating = false;
      locationStatus = result.status;
    });
    if (result.region case final region?) widget.useRegion(region);
  }

  Future<void> sportFilter() async {
    final selected = await showDialog<(Sport?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const AppText(Copy.selectSport),
        children: [
          ListTile(
            minTileHeight: 48,
            title: const AppText(Copy.allSports),
            onTap: () => Navigator.pop(context, (null,)),
          ),
          for (final item in sports)
            ListTile(
              minTileHeight: 48,
              title: AppText(item.name),
              onTap: () => Navigator.pop(context, (item,)),
            ),
        ],
      ),
    );
    if (mounted && selected != null) setState(() => sport = selected.$1);
  }

  Future<void> distanceFilter() async {
    final numbers = NumberFormat.decimalPattern('en_US');
    final selected = await showDialog<(double?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const AppText(Copy.distance),
        children: [
          for (final item in <double?>[null, 2, 5, 10, 20])
            ListTile(
              minTileHeight: 48,
              title: AppText(
                item == null
                    ? Copy.anyDistance
                    : Copy.maxDistance(numbers.format(item)),
              ),
              onTap: () => Navigator.pop(context, (item,)),
            ),
        ],
      ),
    );
    if (mounted && selected != null) setState(() => distance = selected.$1);
  }

  void retry() =>
      setState(() => results = widget.repository.find(widget.region));

  @override
  Widget build(BuildContext context) {
    final locationMessage = switch (locationStatus) {
      LocationStatus.denied => Copy.locationDenied,
      LocationStatus.disabled => Copy.locationDisabled,
      LocationStatus.outside => Copy.locationOutside,
      LocationStatus.unavailable => Copy.locationUnavailable,
      _ => null,
    };
    return ContentList(
      children: [
        SectionHeader(
          Copy.playTitle,
          detail: Copy.place(widget.region.city, widget.region.country),
          prominent: true,
        ),
        const SizedBox(height: Space.x3),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: DemoDataBadge(),
        ),
        const SizedBox(height: Space.x3),
        Wrap(
          spacing: Space.x2,
          runSpacing: Space.x2,
          children: [
            OutlinedButton.icon(
              onPressed: widget.changeRegion,
              icon: const Icon(Symbols.search),
              label: const AppText(Copy.searchArea),
            ),
            OutlinedButton.icon(
              onPressed: locating ? null : useLocation,
              icon: const Icon(Symbols.my_location),
              label: const AppText(Copy.useLocation),
            ),
          ],
        ),
        if (locating || locationMessage != null) ...[
          const SizedBox(height: Space.x2),
          StatusBanner(
            locating ? ContentState.loading : ContentState.error,
            detail: locating ? Copy.locating : locationMessage,
          ),
        ],
        const SizedBox(height: Space.x4),
        SegmentedButton<DirectoryKind>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: DirectoryKind.venues,
              label: AppText(Copy.venues),
            ),
            ButtonSegment(
              value: DirectoryKind.coaches,
              label: AppText(Copy.coaches),
            ),
          ],
          selected: {kind},
          onSelectionChanged: (value) => setState(() => kind = value.single),
        ),
        const SizedBox(height: Space.x2),
        Wrap(
          spacing: Space.x2,
          runSpacing: Space.x2,
          children: [
            OutlinedButton.icon(
              onPressed: sportFilter,
              icon: const Icon(Symbols.tune, size: 18),
              label: AppText(sport?.name ?? Copy.allSports),
            ),
            if (kind == DirectoryKind.venues)
              OutlinedButton.icon(
                onPressed: distanceFilter,
                icon: const Icon(Symbols.route, size: 18),
                label: AppText(
                  distance == null
                      ? Copy.anyDistance
                      : Copy.maxDistance(
                          NumberFormat.decimalPattern('en_US').format(distance),
                        ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => setState(
                () => view = view == DirectoryView.list
                    ? DirectoryView.map
                    : DirectoryView.list,
              ),
              icon: Icon(
                view == DirectoryView.list ? Symbols.map : Symbols.list,
              ),
              label: AppText(view == DirectoryView.list ? Copy.map : Copy.list),
            ),
          ],
        ),
        const SizedBox(height: Space.x4),
        FutureBuilder<DirectoryResults>(
          future: results,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const StatusBanner(ContentState.loading);
            }
            if (snapshot.hasError) {
              final offline = snapshot.error is OfflineFailure;
              return StatusBanner(
                offline ? ContentState.offline : ContentState.error,
                detail: offline ? Copy.directoryOffline : Copy.directoryError,
                onRetry: retry,
              );
            }
            final directory = snapshot.requireData;
            final venues =
                directory.venues
                    .where(
                      (item) =>
                          (sport == null || item.sports.contains(sport!.id)) &&
                          (distance == null || item.distance <= distance!),
                    )
                    .toList()
                  ..sort((a, b) => a.distance.compareTo(b.distance));
            final coaches = directory.coaches
                .where((item) => sport == null || item.sport == sport!.id)
                .toList();
            if ((kind == DirectoryKind.venues && venues.isEmpty) ||
                (kind == DirectoryKind.coaches && coaches.isEmpty)) {
              return const StatusBanner(
                ContentState.empty,
                detail: Copy.noDirectory,
              );
            }
            if (view == DirectoryView.map) {
              return _DemoMap(
                pins: [
                  if (kind == DirectoryKind.venues)
                    for (final item in venues)
                      (label: item.name, open: () => widget.openVenue(item))
                  else
                    for (final item in coaches)
                      (label: item.name, open: () => widget.openCoach(item)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Space.x2,
              children: [
                if (kind == DirectoryKind.venues)
                  for (final item in venues)
                    VenueCard(
                      title: item.name,
                      details: venueSummary(item),
                      onTap: () => widget.openVenue(item),
                    )
                else
                  for (final item in coaches)
                    CoachCard(
                      title: item.name,
                      details: coachSummary(item),
                      onTap: () => widget.openCoach(item),
                    ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _sportName(String id) =>
    sports.firstWhere((sport) => sport.id == id).name;

List<String> venueSummary(Venue venue) => [
  venue.sports.map(_sportName).join(' · '),
  Copy.demoDistance(
    NumberFormat.decimalPattern('en_US').format(venue.distance),
  ),
  Copy.field(Copy.openingHours, venue.openingHours ?? Copy.notProvided),
  Copy.field(Copy.source, venue.source),
  Copy.field(
    Copy.lastChecked,
    venue.lastChecked == null
        ? Copy.notProvided
        : DateFormat.yMMMd('en_US').format(venue.lastChecked!),
  ),
];

List<String> coachSummary(Coach coach) => [
  _sportName(coach.sport),
  Copy.place(coach.region.city, coach.region.country),
  Copy.field(
    Copy.languages,
    coach.languages.isEmpty ? Copy.notProvided : coach.languages.join(', '),
  ),
  Copy.field(Copy.experience, coach.experience ?? Copy.notProvided),
  Copy.field(Copy.fee, coach.feeBasis ?? Copy.notProvided),
  Copy.field(Copy.contact, coach.contact ?? Copy.notProvided),
];

class _DemoMap extends StatelessWidget {
  const _DemoMap({required this.pins});
  final List<({String label, VoidCallback open})> pins;
  static const positions = [
    AlignmentDirectional(-.68, -.48),
    AlignmentDirectional(.48, -.37),
    AlignmentDirectional(-.23, .52),
    AlignmentDirectional(.78, .55),
  ];

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(Space.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Space.x2,
        children: [
          const SectionHeader(Copy.areaMap, detail: Copy.mapNote),
          const DemoDataBadge(),
          SizedBox(
            height: 184,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GridPaper(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  interval: 52,
                  divisions: 2,
                  subdivisions: 1,
                ),
                for (final (index, pin) in pins.take(positions.length).indexed)
                  Align(
                    alignment: positions[index],
                    child: IconButton.filledTonal(
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      tooltip: pin.label,
                      onPressed: pin.open,
                      icon: const Icon(Symbols.location_on),
                    ),
                  ),
              ],
            ),
          ),
          for (final pin in pins)
            TextButton(onPressed: pin.open, child: AppText(pin.label)),
        ],
      ),
    ),
  );
}

class ListingScreen extends StatelessWidget {
  const ListingScreen.venue({
    super.key,
    required this.state,
    required Venue venue,
  }) : _venue = venue,
       _coach = null;
  const ListingScreen.coach({
    super.key,
    required this.state,
    required Coach coach,
  }) : _coach = coach,
       _venue = null;

  final AppState state;
  final Venue? _venue;
  final Coach? _coach;
  SavedKind get kind => _venue == null ? SavedKind.coach : SavedKind.venue;
  String get id => _venue?.id ?? _coach!.id;
  String get name => _venue?.name ?? _coach!.name;

  Future<void> _report(BuildContext context) async {
    final message = await showDialog<String>(
      context: context,
      builder: (_) => const _ReportDialog(),
    );
    if (message == null || !context.mounted) return;
    final saved = await state.report(id, message);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AppText(saved ? Copy.reportSaved : Copy.saveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final venue = _venue;
    final region = venue?.region ?? _coach!.region;
    return Scaffold(
      appBar: AppBar(title: AppText(venue == null ? Copy.coach : Copy.venue)),
      body: ListenableBuilder(
        listenable: state,
        builder: (context, child) => ContentList(
          children: [
            SectionHeader(
              name,
              detail: Copy.place(region.city, region.country),
              prominent: true,
            ),
            const SizedBox(height: Space.x3),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: DemoDataBadge(),
            ),
            const SizedBox(height: Space.x3),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Space.x4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Space.x2,
                  children: [
                    for (final field
                        in venue == null
                            ? coachSummary(_coach!)
                            : venueSummary(venue))
                      AppText(field),
                    if (venue != null)
                      AppText(
                        Copy.field(
                          Copy.address,
                          venue.address ?? Copy.notProvided,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Space.x3),
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x2,
              children: [
                FilledButton.icon(
                  icon: Icon(
                    state.isSaved(kind, id)
                        ? Symbols.bookmark_remove
                        : Symbols.bookmark_add,
                  ),
                  label: AppText(
                    state.isSaved(kind, id) ? Copy.removeSaved : Copy.save,
                  ),
                  onPressed: () async {
                    if (!await state.toggleSaved(kind, id) && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: AppText(Copy.saveError)),
                      );
                    }
                  },
                ),
                if (venue != null) ...[
                  OutlinedButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const AppText(Copy.directions),
                        content: const AppText(Copy.directionsDemo),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const AppText(Copy.close),
                          ),
                        ],
                      ),
                    ),
                    child: const AppText(Copy.directions),
                  ),
                  OutlinedButton(
                    onPressed: () => _report(context),
                    child: const AppText(Copy.report),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();
  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final message = TextEditingController();
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    scrollable: true,
    title: const AppText(Copy.report),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Space.x2,
      children: [
        const AppText(Copy.reportNote),
        TextField(
          controller: message,
          maxLength: 320,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: Copy.reportPrompt),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const AppText(Copy.cancel),
      ),
      FilledButton(
        onPressed: message.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, message.text.trim()),
        child: const AppText(Copy.save),
      ),
    ],
  );
}
