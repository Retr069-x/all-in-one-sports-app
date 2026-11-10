import 'package:flutter/material.dart';

const brand = Color(0xFF4B3FD8);
const lime = Color(0xFFD7F75B);
const ink = Color(0xFF12132B);
const lightSurface = Color(0xFFF6F6FB);

abstract final class Space {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
}

const chipRadius = BorderRadius.all(Radius.circular(14));
const cardRadius = BorderRadius.all(Radius.circular(20));
const heroRadius = BorderRadius.all(Radius.circular(28));
const contentWidth = 600.0;
const motionDuration = Duration(milliseconds: 200);

const sportAccents = {
  'football': Color(0xFF2E9E5B),
  'cricket': Color(0xFFE0A21B),
  'basketball': Color(0xFFE8672A),
  'tennis': Color(0xFFB5CC18),
  'badminton': Color(0xFF7A5AF8),
  'volleyball': Color(0xFFF2557B),
  'table-tennis': Color(0xFFD8453B),
  'swimming': Color(0xFF1FA8D9),
  'squash': Color(0xFF138A8A),
  'baseball': Color(0xFF2F5DA8),
  'rugby-union': Color(0xFF8C2F39),
  'ice-hockey': Color(0xFF6FA8DC),
};

typedef SportTone = ({
  Color accent,
  Color onAccent,
  Color container,
  Color onContainer,
});

double contrastRatio(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

Color _on(Color surface) {
  if (contrastRatio(ink, surface) >= 4.5) return ink;
  if (contrastRatio(Colors.white, surface) >= 4.5) return Colors.white;
  return Colors.black;
}

class SportPalette extends ThemeExtension<SportPalette> {
  const SportPalette(this.tones);

  factory SportPalette.fromBrightness(Brightness brightness) => SportPalette({
    for (final entry in sportAccents.entries)
      entry.key: _tone(entry.value, brightness),
  });

  final Map<String, SportTone> tones;
  SportTone of(String id) => tones[id] ?? tones.values.first;

  static SportTone _tone(Color accent, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final container = Color.alphaBlend(
      accent.withValues(alpha: dark ? .30 : .16),
      dark ? ink : Colors.white,
    );
    return (
      accent: accent,
      onAccent: _on(accent),
      container: container,
      onContainer: _on(container),
    );
  }

  @override
  SportPalette copyWith({Map<String, SportTone>? tones}) =>
      SportPalette(tones ?? this.tones);

  @override
  SportPalette lerp(SportPalette? other, double t) =>
      t < .5 ? this : other ?? this;
}

const fontFallbacks = ['Noto Sans Arabic', 'Noto Sans Devanagari'];

TextStyle _type(double size, int weight, {bool heading = false}) => TextStyle(
  fontFamily: heading ? 'Plus Jakarta Sans' : 'Inter',
  fontFamilyFallback: fontFallbacks,
  fontSize: size,
  height: heading ? 1.20 : 1.42,
  fontWeight: FontWeight.values[(weight ~/ 100) - 1],
  fontVariations: [FontVariation('wght', weight.toDouble())],
  letterSpacing: heading ? -.35 : 0,
);

TextTheme _typeScale(Color color) => TextTheme(
  displayLarge: _type(52, 800, heading: true),
  displayMedium: _type(44, 800, heading: true),
  displaySmall: _type(36, 800, heading: true),
  headlineLarge: _type(32, 800, heading: true),
  headlineMedium: _type(27, 800, heading: true),
  headlineSmall: _type(23, 700, heading: true),
  titleLarge: _type(20, 800, heading: true),
  titleMedium: _type(16, 700, heading: true),
  titleSmall: _type(14, 700, heading: true),
  bodyLarge: _type(16, 400),
  bodyMedium: _type(14, 400),
  bodySmall: _type(12, 400),
  labelLarge: _type(14, 600),
  labelMedium: _type(12, 600),
  labelSmall: _type(11, 600),
).apply(bodyColor: color, displayColor: color);

ThemeData appTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final colors = ColorScheme.fromSeed(
    seedColor: brand,
    brightness: brightness,
    surface: dark ? ink : lightSurface,
    onSurface: dark ? const Color(0xFFF4F2FF) : ink,
  );
  const controlShape = RoundedRectangleBorder(borderRadius: chipRadius);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colors,
    scaffoldBackgroundColor: colors.surface,
    textTheme: _typeScale(colors.onSurface),
    extensions: [SportPalette.fromBrightness(brightness)],
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: BorderSide(color: colors.outlineVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colors.surfaceContainerLowest,
      border: const OutlineInputBorder(borderRadius: chipRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: chipRadius,
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: controlShape,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: controlShape,
      padding: const EdgeInsets.all(Space.x1),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surfaceContainerLow,
      indicatorColor: colors.secondaryContainer,
      labelTextStyle: WidgetStatePropertyAll(_type(12, 600)),
    ),
  );
}

SportTone sportTone(BuildContext context, String id) =>
    Theme.of(context).extension<SportPalette>()!.of(id);
