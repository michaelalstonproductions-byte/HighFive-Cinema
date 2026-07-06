#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC="${1:-Marketing/The_Mark_of_the_West_Keynote_Editable_Text_Photos.pdf}"
OUT_DIR="HighFive/App/UI/Assets.xcassets"

cat <<EOF
HighFive Mark of the West lookbook importer stub

Expected source PDF:
  $SRC

Expected output asset names:
  mark_west_hero_keyart
  mark_west_title_poster
  mark_west_character_queho
  mark_west_world_locations
  mark_west_pitch_at_glance
  mark_west_dark_quote

Target asset catalog:
  $OUT_DIR

This script is intentionally a stub until the real lookbook PDF is present.
When available, render selected pages to optimized PNG/JPEG files at app-safe sizes
and add them as image sets in the asset catalog. Do not bundle the PDF itself.
EOF

if [ ! -f "$SRC" ]; then
  echo
  echo "PDF not found. Place the lookbook at the path above or pass it as the first argument."
  exit 0
fi

echo
echo "TODO: render selected PDF pages with sips/poppler and write optimized image sets."
