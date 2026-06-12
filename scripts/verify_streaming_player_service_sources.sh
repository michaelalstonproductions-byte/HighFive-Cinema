#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-phase-31-0b-player-evidence"
JSON_REPORT="$OUT_DIR/streaming_player_service_source_verification.json"
MD_REPORT="$OUT_DIR/streaming_player_service_source_verification.md"
mkdir -p "$OUT_DIR"

passes=()
failures=()

pass() { passes+=("$1"); }
fail() { failures+=("$1"); }

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

require_term() {
  local label="$1"
  local term="$2"
  local path="${3:-HighFive}"
  if rg -Fq "$term" "$path"; then
    pass "$label"
  else
    fail "$label missing: $term"
  fi
}

require_bottom_tabs() {
  local tab_file="HighFive/App/HFStreamingRootView.swift"
  for wanted in "Home" "Search" "Library" "Downloads" "Profile"; do
    require_term "bottom tab $wanted" "title: \"$wanted\"" "$tab_file"
  done

  local blocked
  blocked=$(rg -n 'HFTabItem\(value: .*title: "(Player|Playback|Stream|Demo|Developer|QA|Rooms|Watch|Create|Connect|Launch|Export)"' "$tab_file" || true)
  if [[ -z "$blocked" ]]; then
    pass "bottom tabs contain only the allowed consumer tabs"
  else
    fail "blocked bottom tab found"
  fi
}

require_evidence_lock_safety() {
  local protected_pattern
  protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Creator|HighFive/App/UI|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|posterAssetName|backdropAssetName|mapping|asset'
  if git diff --name-only | egrep -q "$protected_pattern"; then
    fail "protected path changed during evidence lock"
  else
    pass "no protected paths changed during evidence lock"
  fi

  if git diff --name-only | egrep -q 'HighFive/App/Playback'; then
    fail "playback protected path changed during evidence lock"
  else
    pass "no playback protected path changed during evidence lock"
  fi

  local changed
  changed=$(git diff --name-only)
  local unexpected
  unexpected=$(printf '%s\n' "$changed" | rg -v '^(scripts/verify_streaming_player_service_sources\.sh|scripts/qa_streaming_player_service_screenshots\.sh|scripts/verify_streaming_player_service_screenshots\.sh|scripts/report_streaming_player_service_evidence\.sh)$' || true)
  if [[ -z "$unexpected" ]]; then
    pass "only streaming player evidence scripts changed"
  else
    fail "unexpected changed files: $unexpected"
  fi

  local b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 h1 h2
  b1="Fire""base"
  b2="Supa""base"
  b3="Mu""x"
  b4="Cloud""flare"
  b5="URL""Session"
  b6="DR""M"
  b7="Fair""Play"
  b8="Store""Kit"
  b9="pay""ment"
  b10="entitle""ment"
  b11="tok""en"
  b12="sec""ret"
  b13="api[_-]?""key"
  h1="ht""tp://"
  h2="ht""tps://"
  local blocked_pattern
  blocked_pattern="(${b1}|${b2}|${b3}|${b4}|${b5}|${h1}|${h2}|${b6}|${b7}|${b8}|${b9}|${b10}|${b11}|${b12}|${b13})"
  local blocked_diff
  blocked_diff=$(git diff -U0 -- '*.swift' | rg -n "^\\+.*${blocked_pattern}" || true)
  if [[ -z "$blocked_diff" ]]; then
    pass "no blocked streaming systems added in Swift diff"
  else
    fail "blocked streaming system diff found"
  fi
}

playback_status="placeholder-source-not-connected"
if rg -Fq "VideoPlayer(player: AVPlayer" HighFive; then
  playback_status="AVPlayer-backed local playback path present"
fi

require_term "player service marker" "hf.services.playerService"
require_term "playback source resolver marker" "hf.services.playbackSourceResolver"
require_term "local playback source marker" "hf.services.localPlaybackSource"
require_term "remote streaming provider ready marker" "hf.services.remoteStreamingProviderReady"
require_term "player readiness marker" "hf.services.playerReadiness"
require_term "continue watching state marker" "hf.services.continueWatchingState"

require_term "Movie Detail Watch Now" "hf.consumer.movieDetail.watchNow"
require_term "player sheet" "hf.functional.player.sheet"
require_term "player watchNow action" "hf.functional.player.watchNow"
require_term "player close action" "hf.functional.player.close"
require_term "player source status" "hf.player.source.status"
require_term "source not connected state" "hf.player.source.notConnected"
require_term "player catalog identity" "hf.player.catalog.identity"
require_term "player surface" "hf.player.surface"
require_term "player readiness" "hf.player.readiness"
require_term "player provider status" "hf.player.provider.status"
require_term "player close button" "hf.player.closeButton"

require_term "Home continue watching player proof" "hf.player.home.continueWatching"
require_term "Home player ready proof" "hf.player.home.playerReady"
require_term "Home continue route" "hf.functional.home.continueWatchingRoute"
require_term "Library player context" "hf.player.library.context"
require_term "Downloads player context" "hf.player.downloads.context"
require_term "Watch Room player readiness" "hf.room.watch.playerReadiness"
require_term "Watch Room streaming source status" "hf.room.watch.streamingSourceStatus"
require_term "Profile player service summary" "hf.player.profile.serviceSummary"
require_term "Profile player readiness" "hf.player.profile.readiness"
require_term "Profile player proof" "hf.profile.playerServiceProof"
require_term "Demo player proof" "hf.demoTour.playerServiceProof"
require_term "Demo streaming source proof" "hf.demoTour.streamingSourceReadyProof"
require_term "catalog source connection" "hf.player.catalog.sourceConnection"
require_term "catalog movie id" "hf.player.catalog.movieID"
require_term "catalog title" "hf.player.catalog.title"

require_term "Player Service copy" "Player Service"
require_term "Playback Source Resolver copy" "Playback Source Resolver"
require_term "Local Playback Source copy" "Local Playback Source"
require_term "Remote Streaming Provider copy" "Remote Streaming Provider"
require_term "source not connected copy" "Streaming source not connected yet"
require_term "player route ready copy" "Player route ready"
require_term "not connected copy" "Not Connected Yet"

require_bottom_tabs
require_evidence_lock_safety

status="pass"
if (( ${#failures[@]} > 0 )); then
  status="fail"
fi

{
  printf '{\n'
  printf '  "upgrade": "#031.0B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "playback_evidence": "%s",\n' "$(json_escape "$playback_status")"
  printf '  "evidence_boundary": "source presence and evidence-lock safety only",\n'
  printf '  "passes": [\n'
  for i in "${!passes[@]}"; do
    comma=","
    [[ "$i" -eq $((${#passes[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${passes[$i]}")" "$comma"
  done
  printf '  ],\n'
  printf '  "failures": [\n'
  for i in "${!failures[@]}"; do
    comma=","
    [[ "$i" -eq $((${#failures[@]} - 1)) ]] && comma=""
    printf '    "%s"%s\n' "$(json_escape "${failures[$i]}")" "$comma"
  done
  printf '  ]\n'
  printf '}\n'
} > "$JSON_REPORT"

{
  printf '# Streaming Player Service Source Verification\n\n'
  printf -- '- Upgrade: #031.0B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Playback evidence: %s\n' "$playback_status"
  printf -- '- JSON: %s\n\n' "$JSON_REPORT"
  printf '## Passes\n\n'
  for item in "${passes[@]}"; do printf -- '- %s\n' "$item"; done
  printf '\n## Failures\n\n'
  if (( ${#failures[@]} == 0 )); then
    printf -- '- None\n'
  else
    for item in "${failures[@]}"; do printf -- '- %s\n' "$item"; done
  fi
  printf '\n## Evidence Boundary\n\n'
  printf 'This verifier confirms local player service markers, connected route markers, locked tabs, and evidence-lock safety boundaries. It does not verify a production streaming provider, protected rights layer, paid access layer, or offline media playback.\n'
} > "$MD_REPORT"

printf 'Streaming player service source verification: %s\n' "$status"
printf 'Markdown: %s\n' "$MD_REPORT"
if [[ "$status" != "pass" ]]; then
  exit 1
fi
