# Mark of the West Asset Import - Pass 3

Asset search result: no accessible Mark of the West lookbook PDF or optimized image package was found.

Searched locations/patterns:

- `/mnt/data/The_Mark_of_the_West_Keynote_Editable_Text_Photos.pdf`
- repo root and subfolders
- `*Mark*West*.pdf`
- `*The_Mark_of_the_West*.pdf`
- `*mark*west*`
- `*lookbook*`
- `*keynote*`
- `*.pdf`

Current app behavior:

- Home hero checks for `mark_west_hero_keyart`.
- If that asset is unavailable, Home uses the procedural premium western backdrop.
- No missing asset name is hard-required at runtime.

Prepared importer:

- `scripts/import_mark_of_the_west_lookbook_assets.sh`

Planned future app-safe asset names:

- `mark_west_hero_keyart`
- `mark_west_title_poster`
- `mark_west_dark_title`
- `mark_west_quote_truth_buried`
- `mark_west_pitch_at_glance`
- `mark_west_queho_character`
- `mark_west_world_locations`
- `mark_west_color_palette`
- `mark_west_trail_of_unity`

Rules for future import:

- Do not bundle the lookbook PDF directly.
- Render selected pages to optimized PNG/JPEG images.
- Keep hero/key art around 1600 px wide max.
- Keep title/poster art around 1200 px max.
- Keep thumbnails around 800 px max.
- Keep budget/investment cards internal to Packaging only.
