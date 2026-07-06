# Mark of the West Asset Import

Asset search result: no local Mark of the West lookbook PDF or image package was found in the repo.

Searched for:

- `*mark*west*`
- `*lookbook*`
- `*keynote*`
- `*.pdf`
- `*queho*`

Current app behavior:

- Home hero prefers an asset named `mark_west_hero_keyart` if it exists.
- If that asset is unavailable, the app uses the procedural cinematic western backdrop.

Prepared importer stub:

- `scripts/import_mark_of_the_west_lookbook_assets.sh`

Expected future generated asset names:

- `mark_west_hero_keyart`
- `mark_west_title_poster`
- `mark_west_character_queho`
- `mark_west_world_locations`
- `mark_west_pitch_at_glance`
- `mark_west_dark_quote`

Notes:

- Do not add huge PDF/source lookbook files to the app bundle.
- Export practical PNG/JPEG images only.
- Preserve source aspect ratio.
- Keep budget/investment cards internal to packaging workspace only.
