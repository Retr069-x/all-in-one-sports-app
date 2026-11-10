import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import 'components.dart';

Future<Region?> showRegionPicker(BuildContext context, Region current) =>
    showModalBottomSheet<Region>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: .82,
        child: _RegionPicker(current),
      ),
    );

class _RegionPicker extends StatefulWidget {
  const _RegionPicker(this.current);
  final Region current;
  @override
  State<_RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<_RegionPicker> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final matches = regions
        .where(
          (region) => Copy.place(
            region.city,
            region.country,
          ).toLowerCase().contains(query),
        )
        .toList();
    return ContentList(
      children: [
        const SectionHeader(Copy.selectCountry, detail: Copy.regionHelp),
        const SizedBox(height: Space.x3),
        AppSearchField(
          controller: search,
          onChanged: (_) => setState(() {}),
          label: Copy.searchArea,
        ),
        const SizedBox(height: Space.x3),
        if (matches.isEmpty)
          const StatusBanner(ContentState.empty, detail: Copy.regionHelp),
        for (final region in matches)
          ListTile(
            title: Text(region.country),
            subtitle: Text(region.city),
            minTileHeight: 48,
            selected: region == widget.current,
            trailing: region == widget.current
                ? const Icon(Symbols.check)
                : null,
            onTap: () => Navigator.pop(context, region),
          ),
      ],
    );
  }
}
