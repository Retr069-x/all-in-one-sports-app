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
        child: ContentList(
          children: [
            const SectionHeader(Copy.selectCountry, detail: Copy.regionHelp),
            const SizedBox(height: Space.x3),
            for (final region in regions)
              ListTile(
                title: Text(region.country),
                subtitle: Text(region.city),
                minTileHeight: 48,
                selected: region == current,
                trailing: region == current ? const Icon(Symbols.check) : null,
                onTap: () => Navigator.pop(context, region),
              ),
          ],
        ),
      ),
    );
