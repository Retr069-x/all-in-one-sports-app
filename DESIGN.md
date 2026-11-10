# SportConnect design system

Use flat Material 3 surfaces, legible course titles and one focused action per surface. The learning home uses a dark editorial card, sport-coloured tiles, and quiet outlined sections for browsing.

| Token | Value |
| --- | --- |
| Material seed | Indigo `#4B3FD8`, separate light and dark schemes |
| Light surface / ink | `#F6F6FB` / `#12132B` |
| Highlight | Lime `#D7F75B`, reserved for primary actions and highlights on dark cards |
| Spacing | 4, 8, 12, 16, 24, 32 dp |
| Corners | 14 dp controls, 20 dp cards, 28 dp hero |
| Content / targets | 600 dp centred content, 48 dp interactive targets |
| Motion | 200 ms, disabled when the platform requests reduced motion |
| Type | Plus Jakarta Sans 700–800 for headings, Inter 400–600 for body and labels |
| Fallbacks | Noto Sans Arabic and Noto Sans Devanagari, bundled locally |

Sport accents use the requested hex values. Container colours blend each accent over white in light mode and ink in dark mode. Foreground tokens choose ink, white or black to keep the contrast ratio at or above 4.5:1. Automated tests check both foreground pairings for all twelve sports in both themes.

Use Material Symbols throughout the new UI. Racket sports share a racket symbol where the icon set has no distinct equivalent. Their visible sport names and colour tokens make each sport identifiable. Use labels and icons together for statuses. Keep directional padding and alignment in responsive layouts.

The font assets are unmodified variable fonts distributed under SIL OFL 1.1. Their notices ship beside the fonts. [Google Fonts source](https://github.com/google/fonts/tree/main/ofl), [Material Symbols package and licence](https://pub.dev/packages/material_symbols_icons/license)
