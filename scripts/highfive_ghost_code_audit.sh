#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="$ROOT/out/ghost-code-audit"
mkdir -p "$OUT"

echo "Running HighFive ghost code audit..."

find HighFive -name "*.swift" | sort > "$OUT/all-swift-files.txt"

grep -oE '[A-Za-z0-9_./ -]+\.swift' HighFive.xcodeproj/project.pbxproj \
  | sed 's#^##' \
  | sort -u > "$OUT/project-source-files-raw.txt" || true

python3 - <<'PY'
from pathlib import Path

all_files = [p for p in Path("HighFive").rglob("*.swift")]
pbx = Path("HighFive.xcodeproj/project.pbxproj").read_text(errors="ignore")

in_project = []
not_in_project = []

for path in all_files:
    name = path.name
    path_str = str(path)
    if name in pbx or path_str in pbx:
        in_project.append(path_str)
    else:
        not_in_project.append(path_str)

Path("out/ghost-code-audit/project-source-files.txt").write_text(
    "\n".join(sorted(in_project)) + ("\n" if in_project else "")
)
Path("out/ghost-code-audit/swift-files-not-in-project.txt").write_text(
    "\n".join(sorted(not_in_project)) + ("\n" if not_in_project else "")
)
PY

find HighFive Scripts scripts -type f 2>/dev/null \
  | grep -Ei 'copy|backup|checkpoint|old|temp|duplicate|unused|legacy|scratch|april|may|march|test|sample|demo|fake|placeholder' \
  | sort > "$OUT/suspicious-file-names.txt" || true

{
  grep -R "/Volumes/Scratch SSD/New project may 29th" HighFive.xcodeproj/project.pbxproj HighFive Scripts scripts 2>/dev/null || true
  grep -R "TheFriendly_ref.mp4 in Resources\|Paranormall_E[1-7]_ref.mp4 in Resources" HighFive.xcodeproj/project.pbxproj 2>/dev/null || true
  grep -R "com.highfive.app.unlock\|com.highfive.series.paranormall.season1" HighFive 2>/dev/null || true
  grep -R 'com.highfive.episode.paranormall.e7"' HighFive 2>/dev/null || true
  grep -R "preview_.*full\|full.*preview_" HighFive/Data HighFive/Views 2>/dev/null || true
  grep -R "HF_ALLOW_DEBUG_PAYWALL_UNLOCK\|debugUnlockedMovieIDs" HighFive 2>/dev/null || true
  legal_name='[Company Legal'$(printf ' Name]')
  support_email='[Support'$(printf ' Email]')
  mailing_address='[Company Mailing'$(printf ' Address]')
  todo_app_store='TODO App'$(printf ' Store')
  fixme_app_store='FIXME App'$(printf ' Store')
  grep -R -F \
    -e "$legal_name" \
    -e "$support_email" \
    -e "$mailing_address" \
    -e "$todo_app_store" \
    -e "$fixme_app_store" \
    HighFive Scripts scripts 2>/dev/null || true
} > "$OUT/forbidden-release-strings.txt"

python3 - <<'PY'
from pathlib import Path
import re
from collections import defaultdict

decls = defaultdict(list)
pattern = re.compile(r'^\s*(?:public|private|fileprivate|internal|final|open|@MainActor|\s)*\s*(struct|class|enum|actor|protocol)\s+([A-Za-z_][A-Za-z0-9_]*)\b')

for path in Path("HighFive").rglob("*.swift"):
    for line_no, line in enumerate(path.read_text(errors="ignore").splitlines(), 1):
        m = pattern.match(line)
        if m:
            decls[m.group(2)].append(f"{path}:{line_no}:{m.group(1)}")

dupes = {name: locs for name, locs in decls.items() if len(locs) > 1}
lines = []
for name, locs in sorted(dupes.items()):
    lines.append(name)
    lines.extend(f"  {loc}" for loc in locs)
Path("out/ghost-code-audit/duplicate-type-candidates.txt").write_text(
    "\n".join(lines) + ("\n" if lines else "")
)
PY

python3 - <<'PY'
from pathlib import Path

source_text = ""
for folder in ["HighFive", "Scripts", "scripts"]:
    p = Path(folder)
    if p.exists():
        for file in p.rglob("*"):
            if file.is_file() and file.suffix.lower() in [".swift", ".json", ".plist", ".pbxproj", ".sh"]:
                source_text += "\n" + file.read_text(errors="ignore")

resource_exts = {".png", ".jpg", ".jpeg", ".webp", ".mp4", ".mov", ".m4v", ".json", ".storekit", ".ttf", ".otf"}
candidates = []

for file in Path("HighFive").rglob("*"):
    if not file.is_file():
        continue
    if file.suffix.lower() not in resource_exts:
        continue
    base = file.stem
    if base in ["Info", "HighFive"]:
        continue
    if ".xcassets" in str(file) and file.name in {"Contents.json"}:
        continue
    if base not in source_text and file.name not in source_text:
        candidates.append(str(file))

Path("out/ghost-code-audit/unused-orphan-resource-candidates.txt").write_text(
    "\n".join(sorted(candidates)) + ("\n" if candidates else "")
)
PY

cat > "$OUT/ghost-code-summary.md" <<'EOF'
# HighFive Ghost Code Audit Summary

This report is generated automatically. It is not a deletion list.

Review:
- swift-files-not-in-project.txt
- suspicious-file-names.txt
- duplicate-type-candidates.txt
- unused-orphan-resource-candidates.txt
- forbidden-release-strings.txt

Rules:
- Do not delete active playback, StoreKit, streaming, Layer 4, onboarding, title detail, profile, legal, or release-safety files without manual verification.
- Files not in the Xcode target may still be documentation, scripts, or future-safe references.
- Duplicate type names may be intentional if nested/private or debug-only.
EOF

echo "Ghost code audit complete: $OUT"
