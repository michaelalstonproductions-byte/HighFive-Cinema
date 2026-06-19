#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

UPGRADE="UI-01B"
BASELINE_COMMIT="b5beb99"
BASELINE_TAG="phase-ui-01a-spatial-cinema-experience-foundation"
BASELINE_PARENT_COMMIT="afb73da"
BASELINE_PARENT_TAG="phase-67-0b-staging-backend-deployment-target-smoke-test-evidence-lock"
EVIDENCE_DIR="/private/tmp/highfive-ui-01b-spatial-cinema-evidence"
JSON_OUT="$EVIDENCE_DIR/spatial_cinema_source_verification.json"
MD_OUT="$EVIDENCE_DIR/spatial_cinema_source_verification.md"

mkdir -p "$EVIDENCE_DIR"

declare -a CHECKS=()
declare -a FAILURES=()

record_pass() {
  CHECKS+=("$1")
}

record_fail() {
  FAILURES+=("$1")
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    record_pass "file present: $file"
  else
    record_fail "missing file: $file"
  fi
}

require_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    record_pass "$label"
  else
    record_fail "$label"
  fi
}

require_absent() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    record_fail "$label"
  else
    record_pass "$label"
  fi
}

require_count() {
  local file="$1"
  local pattern="$2"
  local expected="$3"
  local label="$4"
  local actual
  actual="$(rg -n -- "$pattern" "$file" | wc -l | tr -d ' ')"
  if [[ "$actual" == "$expected" ]]; then
    record_pass "$label ($actual)"
  else
    record_fail "$label expected $expected actual $actual"
  fi
}

APP_ROOT="HighFive/App/HFStreamingRootView.swift"
PRIMITIVES="HighFive/Components/HFSpatialCinemaPrimitives.swift"
HOME="HighFive/Views/Home/HomeView.swift"
DETAIL="HighFive/Views/MovieDetail/MovieDetailView.swift"
EXPECTED_FILES=(
  "$APP_ROOT"
  "$PRIMITIVES"
  "$HOME"
  "$DETAIL"
)

for file in "${EXPECTED_FILES[@]}"; do
  require_file "$file"
done

actual_head="$(git rev-parse --short HEAD)"
if [[ "$actual_head" == "$BASELINE_COMMIT" ]]; then
  record_pass "HEAD is required UI-01A baseline: $BASELINE_COMMIT"
else
  record_fail "HEAD is $actual_head, expected $BASELINE_COMMIT"
fi

if git tag --points-at HEAD | rg -qx "$BASELINE_TAG"; then
  record_pass "HEAD has required baseline tag: $BASELINE_TAG"
else
  record_fail "HEAD missing required baseline tag: $BASELINE_TAG"
fi

expected_scope="$(printf "%s\n" "${EXPECTED_FILES[@]}" | sort)"
actual_scope="$(git diff --name-only "$BASELINE_PARENT_COMMIT..$BASELINE_COMMIT" | sort)"
if [[ "$actual_scope" == "$expected_scope" ]]; then
  record_pass "UI-01A commit range changed only the four expected app files"
else
  record_fail "UI-01A changed unexpected files: $actual_scope"
fi

require_contains "$PRIMITIVES" "struct HFOpticalGlassSurface" "spatial primitive HFOpticalGlassSurface present"
require_contains "$PRIMITIVES" "struct HFDepthContourOverlay" "spatial primitive HFDepthContourOverlay present"
require_contains "$PRIMITIVES" "struct HFEnergyAction" "spatial primitive HFEnergyAction present"
require_contains "$PRIMITIVES" "case gold" "energy action gold style present"
require_contains "$PRIMITIVES" "case cyan" "energy action cyan style present"
require_contains "$PRIMITIVES" "case glass" "energy action glass style present"

require_contains "$APP_ROOT" "case home" "Home tab enum case present"
require_contains "$APP_ROOT" "case search" "Search tab enum case present"
require_contains "$APP_ROOT" "case library" "Library tab enum case present"
require_contains "$APP_ROOT" "case downloads" "Downloads tab enum case present"
require_contains "$APP_ROOT" "case profile" "Profile tab enum case present"
require_count "$APP_ROOT" "HFTabItem\\(value:" "5" "exactly five bottom tab items"
require_absent "$APP_ROOT" "case connect" "no Connect tab enum case"
require_absent "$APP_ROOT" "HFTabItem\\(value: \\.connect" "no Connect tab item"
require_absent "$APP_ROOT" "selectedTab = \\.connect" "no selectedTab assignment to Connect"
require_contains "$APP_ROOT" "--hf-start-connect\"\\) \\{ return \\.profile \\}" "old Connect launch argument routes to Profile"
require_contains "$APP_ROOT" "hf.tabs.locked" "locked tab accessibility identifier present"

require_contains "$HOME" "hf.spatial.home" "Home spatial root identifier present"
require_contains "$HOME" "hf.spatial.home.hero" "Home spatial hero identifier present"
require_contains "$HOME" "hf.spatial.home.backgroundPlane" "Home background plane identifier present"
require_contains "$HOME" "hf.spatial.home.subjectPlane" "Home subject plane identifier present"
require_contains "$HOME" "hf.spatial.home.foregroundPlane" "Home foreground plane identifier present"
require_contains "$HOME" "HFEnergyAction\\(title: \"Watch\"" "Home Watch energy action present"
require_contains "$HOME" "hf.spatial.home.watch" "Home Watch identifier present"
require_contains "$HOME" "HFEnergyAction\\(title: \"Depth\"" "Home Depth energy action present"
require_contains "$HOME" "hf.spatial.home.depth" "Home Depth identifier present"
require_contains "$HOME" "title: streamingStore\\.isSaved\\(heroMovie\\) \\? \"Saved\" : \"Save\"" "Home Save action present"
require_contains "$HOME" "hf.spatial.home.save" "Home Save identifier present"
require_count "$HOME" "HFEnergyAction\\(" "3" "Home hero has three visible energy actions"
require_contains "$HOME" "continueWatchingSection" "Home rails continue below hero"
require_contains "$HOME" "ForEach\\(streamingStore\\.premiumHomeCatalogRails\\)" "Home catalog rails below hero"
require_contains "$HOME" "@Environment\\(\\\\.accessibilityReduceMotion\\)" "Home Reduce Motion environment present"
require_contains "$HOME" "guard !reduceMotion else \\{ return \\}" "Home reduced-motion guard present"
require_contains "$HOME" "\\.accessibilityLabel\\(\"\\\\\\(heroMovie\\.title\\)" "Home hero accessibility label present"
require_absent "$HOME" "^\\s*streamingStatusPanel$" "Home readiness panel not called in primary body"
require_absent "$HOME" "^\\s*quickActions$" "Home quick action tiles not above hero"

require_contains "$DETAIL" "hf.spatial.movieDetail" "Movie Detail spatial root identifier present"
require_contains "$DETAIL" "hf.spatial.movieDetail.scene" "Movie Detail scene identifier present"
require_contains "$DETAIL" "HFDepthContourOverlay\\(color: HFColors\\.cyanGlow\\)" "Movie Detail depth contour present"
require_contains "$DETAIL" "hf.spatial.movieDetail.watch" "Movie Detail Watch identifier present"
require_contains "$DETAIL" "hf.spatial.movieDetail.depth" "Movie Detail Depth identifier present"
require_contains "$DETAIL" "contextualAction\\(title: \"Watch Together\"" "Movie Detail Watch Together secondary action present"
require_contains "$DETAIL" "contextualAction\\(title: \"Build Release\"" "Movie Detail Build Release secondary action present"
require_contains "$DETAIL" "Access & Playback Readiness" "Access and playback readiness sheet/action present"
require_contains "$DETAIL" "accessPlaybackReadinessSheet" "Movie Detail readiness sheet present"
movie_primary_body="$(
  awk '
    /struct MovieDetailView/ { in_view=1 }
    in_view && /var body: some View/ { in_body=1 }
    in_body && /private var hero/ { exit }
    in_body { print }
  ' "$DETAIL"
)"
for panel in "playbackStatusPanel" "entitlementStatusPanel" "downloadBoundaryPanel"; do
  if printf "%s\n" "$movie_primary_body" | rg -q "$panel"; then
    record_fail "Movie Detail primary body contains $panel"
  else
    record_pass "Movie Detail primary body omits $panel"
  fi
done
require_contains "$DETAIL" "@Environment\\(\\\\.accessibilityReduceMotion\\)" "Movie Detail Reduce Motion environment present"
require_contains "$DETAIL" "guard !reduceMotion else \\{ return \\}" "Movie Detail/player reduced-motion guard present"

require_contains "$DETAIL" "struct HFPlayerServiceSheet" "Player shell present"
require_contains "$DETAIL" "hf.spatial.player" "Player spatial identifier present"
require_contains "$DETAIL" "hf.spatial.player.tiltReveal" "Player tilt reveal identifier present"
require_contains "$DETAIL" "hf.spatial.player.localPreview" "Player Local Preview identifier present"
require_contains "$DETAIL" "Continue Local Preview" "Player Local Preview action remains available"
require_contains "$DETAIL" "Try Depth \\+ Peek" "Player Depth and Peek action remains available"
require_contains "$DETAIL" "playerReadinessSheet" "Player readiness sheet present"
require_contains "$DETAIL" "playerReadinessButton" "Player readiness button present"
require_contains "$DETAIL" "Ready in local preview" "Player primary surface uses local-preview copy"
require_contains "$DETAIL" "HighFive Player is using the local catalog preview for this title" "Player primary Local Preview copy is provider-neutral"

primary_player_slice="$(
  awk '
    /struct HFPlayerServiceSheet/ { in_player=1 }
    in_player && /var body: some View/ { in_body=1 }
    in_body && /private var providerStatusPanel/ { exit }
    in_body { print }
  ' "$DETAIL"
)"
for forbidden in "token" "descriptor-reference" "adapter" "gateway" "credential" "Bearer" "URLSession"; do
  if printf "%s\n" "$primary_player_slice" | rg -qi "$forbidden"; then
    record_fail "primary player surface contains forbidden term: $forbidden"
  else
    record_pass "primary player surface omits forbidden term: $forbidden"
  fi
done

protected_hits="$(git diff --name-only "$BASELINE_PARENT_COMMIT..$BASELINE_COMMIT" | rg 'HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements' || true)"
if [[ -z "$protected_hits" ]]; then
  record_pass "UI-01A protected/project/assets/plist/privacy/entitlement scan clean"
else
  record_fail "UI-01A protected scan hit: $protected_hits"
fi

provider_pattern='^\+.*(Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|MetaSDK|FacebookCore|TikTok|YouTube|URLSession|https?://|Bearer |api[_-]?key|client_secret|access_token|refresh_token|private_''key|service_''role)'
provider_hits="$(
  git diff -U0 "$BASELINE_PARENT_COMMIT..$BASELINE_COMMIT" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' |
    rg -n "$provider_pattern" || true
)"
if [[ -z "$provider_hits" ]]; then
  record_pass "UI-01A provider/network/secret scan clean"
else
  record_fail "UI-01A provider/network/secret scan hit"
fi

status="passed"
if (( ${#FAILURES[@]} > 0 )); then
  status="failed"
fi

python3 - "$JSON_OUT" "$status" "$UPGRADE" "$BASELINE_COMMIT" "$BASELINE_TAG" "$BASELINE_PARENT_COMMIT" "$BASELINE_PARENT_TAG" <<'PY'
import json
import os
import sys

out, status, upgrade, baseline_commit, baseline_tag, parent_commit, parent_tag = sys.argv[1:8]
checks = os.environ.get("CHECKS_DATA", "").split("\n") if os.environ.get("CHECKS_DATA") else []
failures = os.environ.get("FAILURES_DATA", "").split("\n") if os.environ.get("FAILURES_DATA") else []
data = {
    "upgrade": upgrade,
    "status": status,
    "baseline": {"commit": baseline_commit, "tag": baseline_tag},
    "baseline_parent": {"commit": parent_commit, "tag": parent_tag},
    "expected_files": [
        "HighFive/App/HFStreamingRootView.swift",
        "HighFive/Components/HFSpatialCinemaPrimitives.swift",
        "HighFive/Views/Home/HomeView.swift",
        "HighFive/Views/MovieDetail/MovieDetailView.swift",
    ],
    "checks": checks,
    "failures": failures,
}
with open(out, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

# Re-write JSON with arrays passed via temporary files to avoid shell quoting edge cases.
checks_file="$EVIDENCE_DIR/source_checks.txt"
failures_file="$EVIDENCE_DIR/source_failures.txt"
printf "%s\n" "${CHECKS[@]}" > "$checks_file"
if (( ${#FAILURES[@]} > 0 )); then
  printf "%s\n" "${FAILURES[@]}" > "$failures_file"
else
  : > "$failures_file"
fi
python3 - "$JSON_OUT" "$checks_file" "$failures_file" "$status" "$UPGRADE" "$BASELINE_COMMIT" "$BASELINE_TAG" "$BASELINE_PARENT_COMMIT" "$BASELINE_PARENT_TAG" <<'PY'
import json
import sys

out, checks_path, failures_path, status, upgrade, baseline_commit, baseline_tag, parent_commit, parent_tag = sys.argv[1:10]
checks = [line.rstrip("\n") for line in open(checks_path, encoding="utf-8") if line.rstrip("\n")]
failures = [line.rstrip("\n") for line in open(failures_path, encoding="utf-8") if line.rstrip("\n")]
data = {
    "upgrade": upgrade,
    "status": status,
    "baseline": {"commit": baseline_commit, "tag": baseline_tag},
    "baseline_parent": {"commit": parent_commit, "tag": parent_tag},
    "ui_01a_file_scope": [
        "HighFive/App/HFStreamingRootView.swift",
        "HighFive/Components/HFSpatialCinemaPrimitives.swift",
        "HighFive/Views/Home/HomeView.swift",
        "HighFive/Views/MovieDetail/MovieDetailView.swift",
    ],
    "five_tab_evidence": {
        "tabs": ["Home", "Search", "Library", "Downloads", "Profile"],
        "locked_identifier": "hf.tabs.locked",
        "connect_bottom_tab": False,
    },
    "spatial_primitives": ["HFOpticalGlassSurface", "HFDepthContourOverlay", "HFEnergyAction"],
    "home_identifiers": [
        "hf.spatial.home",
        "hf.spatial.home.hero",
        "hf.spatial.home.foregroundPlane",
        "hf.spatial.home.subjectPlane",
        "hf.spatial.home.backgroundPlane",
        "hf.spatial.home.watch",
        "hf.spatial.home.depth",
        "hf.spatial.home.save",
    ],
    "movie_detail_identifiers": [
        "hf.spatial.movieDetail",
        "hf.spatial.movieDetail.scene",
        "hf.spatial.movieDetail.watch",
        "hf.spatial.movieDetail.depth",
    ],
    "player_identifiers": [
        "hf.spatial.player",
        "hf.spatial.player.tiltReveal",
        "hf.spatial.player.localPreview",
    ],
    "checks": checks,
    "failures": failures,
}
with open(out, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY

{
  echo "# Spatial Cinema Source Verification"
  echo
  echo "- Upgrade: $UPGRADE"
  echo "- Status: $status"
  echo "- Baseline: $BASELINE_COMMIT / $BASELINE_TAG"
  echo "- Baseline parent: $BASELINE_PARENT_COMMIT / $BASELINE_PARENT_TAG"
  echo
  echo "## Checks"
  for check in "${CHECKS[@]}"; do
    echo "- PASS: $check"
  done
  echo
  echo "## Failures"
  if (( ${#FAILURES[@]} == 0 )); then
    echo "- None"
  else
    for failure in "${FAILURES[@]}"; do
      echo "- FAIL: $failure"
    done
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  echo "Source verification failed. See $JSON_OUT" >&2
  exit 1
fi

echo "Source verification passed: $JSON_OUT"
