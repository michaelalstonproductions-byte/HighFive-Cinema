# HighFive 1.2 Source Hygiene

The following Swift source files are used by the app but are currently untracked:

- `HighFive/Components/HFDepthUIComponents.swift`
- `HighFive/Components/HFDepthPosterFrame.swift`

They should be included in the 1.2 source checkpoint:

```bash
git add HighFive/Components/HFDepthUIComponents.swift
git add HighFive/Components/HFDepthPosterFrame.swift
```

Additional pass 3 files to add if accepted:

```bash
git add HighFive/Packaging
git add scripts/import_mark_of_the_west_lookbook_assets.sh
git add scripts/highfive_simulator_doctor.sh
git add scripts/run_highfive_simulator.sh
git add scripts/capture_highfive_simulator.sh
git add scripts/highfive_direct_typecheck.sh
git add out/highfive-1-2-depth-pass/MARK_OF_THE_WEST_ASSET_IMPORT.md
git add out/highfive-1-2-depth-pass/MARK_OF_THE_WEST_ASSET_IMPORT_PASS_3.md
git add out/highfive-1-2-depth-pass/FINAL_1_2_BIG_LEAP_PASS_3_REPORT.md
git add out/highfive-1-2-depth-pass/FINAL_1_2_BIG_LEAP_PASS_3_SIMULATOR_REPORT.md
```

No files were staged by Codex.
