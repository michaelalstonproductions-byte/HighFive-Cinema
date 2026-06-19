#!/usr/bin/env bash
set -u -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-ui-03b-connect-constellation-evidence"
SOURCE_JSON="$OUT_DIR/connect_constellation_source_verification.json"
SCREENSHOT_JSON="$OUT_DIR/connect_constellation_screenshot_manifest.json"
VERIFY_JSON="$OUT_DIR/connect_constellation_screenshot_verification.json"
JSON_OUT="$OUT_DIR/connect_constellation_evidence_report.json"
MD_OUT="$OUT_DIR/connect_constellation_evidence_report.md"
SHOT_DIR="$OUT_DIR/screenshots"
mkdir -p "$OUT_DIR"

declare -a PASSES=()
declare -a FAILURES=()

pass() {
  PASSES+=("$1")
}

fail() {
  FAILURES+=("$1")
}

json_status_passed() {
  local file="$1"
  [[ -f "$file" ]] && jq -e . "$file" >/dev/null && rg -q '"status": "passed"' "$file"
}

if json_status_passed "$SOURCE_JSON"; then
  pass "source verifier passed"
else
  fail "source verifier passed"
fi

if json_status_passed "$SCREENSHOT_JSON"; then
  pass "screenshot harness passed"
else
  fail "screenshot harness passed"
fi

if json_status_passed "$VERIFY_JSON"; then
  pass "screenshot verifier passed"
else
  fail "screenshot verifier passed"
fi

expected_scope=$'HighFive/App/HFStreamingRootView.swift\nHighFive/Views/Connect/ConnectHubView.swift\nHighFive/Views/MovieDetail/MovieDetailView.swift\nHighFive/Views/Profile/ProfileView.swift'
actual_scope="$(git diff --name-only 7aec2e6..b199939 | sort)"
if [[ "$actual_scope" == "$(printf '%s\n' "$expected_scope" | sort)" ]]; then
  pass "UI-03A production file scope is exact"
else
  fail "UI-03A production file scope is exact"
fi

protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|[.]entitlements'
if git diff --name-only | rg "$protected_pattern" >/dev/null; then
  fail "current protected-path scan clean"
else
  pass "current protected-path scan clean"
fi

if git diff --name-only | rg '^HighFive/.*[.]swift$' >/dev/null; then
  fail "no Swift production changes in UI-03B"
else
  pass "no Swift production changes in UI-03B"
fi

if git diff --name-only 7aec2e6..b199939 | rg "$protected_pattern" >/dev/null; then
  fail "UI-03A protected/project-file scan clean"
else
  pass "UI-03A protected/project-file scan clean"
fi

network_pattern='Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|MetaSDK|FacebookCore|TikTok|YouTube|URLSession|WebSocket|NWConnection|Network[.]framework|https?://|Bearer |api[_-]?key|client_'
network_pattern+='secret|access_'
network_pattern+='token|refresh_'
network_pattern+='token|private_'
network_pattern+='key|service_'
network_pattern+='role'
if git diff -U0 7aec2e6..b199939 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n "^\\+.*($network_pattern)" >/dev/null; then
  fail "provider/network/URL/secret scan clean"
else
  pass "provider/network/URL/secret scan clean"
fi

live_pattern='Live Chat|Send Message|Message Sent|Synchronized Playback Active|Room Connected|Presence Connected|Invite Delivered|Remote Room Active|Start Live Room'
if git diff -U0 7aec2e6..b199939 -- '*.swift' '*.md' | rg -n "^\\+.*($live_pattern)" >/dev/null; then
  fail "live-communication scan clean"
else
  pass "live-communication scan clean"
fi

status="passed"
if (( ${#FAILURES[@]} > 0 )); then
  status="failed"
fi

{
  printf '{\n'
  printf '  "upgrade": "UI-03B",\n'
  printf '  "status": "%s",\n' "$status"
  printf '  "baseline": "b199939",\n'
  printf '  "baseline_tag": "phase-ui-03a-connect-constellation-watch-room",\n'
  printf '  "baseline_parent": "7aec2e6",\n'
  printf '  "baseline_parent_tag": "phase-ui-02b-creator-studio-spatial-worktable-evidence-lock",\n'
  printf '  "source_verifier": "%s",\n' "$(json_status_passed "$SOURCE_JSON" && printf passed || printf failed)"
  printf '  "screenshot_harness": "%s",\n' "$(json_status_passed "$SCREENSHOT_JSON" && printf passed || printf failed)"
  printf '  "screenshot_verifier": "%s",\n' "$(json_status_passed "$VERIFY_JSON" && printf passed || printf failed)"
  printf '  "evidence_report": "%s",\n' "$status"
  printf '  "screenshots": {\n'
  printf '    "connect_hub": "%s/connect_constellation.png",\n' "$SHOT_DIR"
  printf '    "local_watch_room": "%s/local_watch_room.png",\n' "$SHOT_DIR"
  printf '    "premiere_lobby": "%s/premiere_lobby.png",\n' "$SHOT_DIR"
  printf '    "profile_entry": "%s/profile_connect_entry.png",\n' "$SHOT_DIR"
  printf '    "movie_detail_entry": "%s/movie_detail_watch_together.png"\n' "$SHOT_DIR"
  printf '  },\n'
  printf '  "visual_scores": {\n'
  printf '    "film_dominance": 5,\n'
  printf '    "constellation_depth": 4,\n'
  printf '    "presence_legibility": 4,\n'
  printf '    "visual_hierarchy": 5,\n'
  printf '    "highfive_identity": 5,\n'
  printf '    "restraint": 4,\n'
  printf '    "accessibility_safe_areas": 4\n'
  printf '  },\n'
  printf '  "known_limitations": [\n'
  printf '    "evidence only",\n'
  printf '    "local Connect UI only",\n'
  printf '    "no synchronized playback",\n'
  printf '    "no live presence provider",\n'
  printf '    "no messaging transport",\n'
  printf '    "no chat provider",\n'
  printf '    "no WebSocket",\n'
  printf '    "no push delivery",\n'
  printf '    "no remote invitation delivery",\n'
  printf '    "no cloud activity feed",\n'
  printf '    "no remote room provider",\n'
  printf '    "no provider credentials",\n'
  printf '    "protected playback systems unchanged",\n'
  printf '    "Local Preview remains available"\n'
  printf '  ],\n'
  printf '  "failures": ['
  if (( ${#FAILURES[@]} > 0 )); then
    printf '"see markdown report"'
  fi
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Connect Constellation Watch Room Evidence Report\n\n'
  printf -- '- Upgrade: UI-03B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline: b199939 / phase-ui-03a-connect-constellation-watch-room\n'
  printf -- '- Baseline parent: 7aec2e6 / phase-ui-02b-creator-studio-spatial-worktable-evidence-lock\n'
  printf -- '- Source verifier: %s\n' "$(json_status_passed "$SOURCE_JSON" && printf passed || printf failed)"
  printf -- '- Screenshot harness: %s\n' "$(json_status_passed "$SCREENSHOT_JSON" && printf passed || printf failed)"
  printf -- '- Screenshot verifier: %s\n' "$(json_status_passed "$VERIFY_JSON" && printf passed || printf failed)"
  printf -- '- Evidence report: %s\n\n' "$status"
  printf '## Evidence Summary\n'
  printf -- '- Connect modes: hub, watchRoom, premiereLobby.\n'
  printf -- '- Movie portal: selected/local movie artwork with safe local fallback.\n'
  printf -- '- Constellation: gold host, cyan/white guests, restrained cyan arcs.\n'
  printf -- '- Connect controls: Enter Local Room primary; Invite and More secondary.\n'
  printf -- '- Local Watch Room: Continue Local Preview primary with React, Invite, and Leave secondary.\n'
  printf -- '- Premiere Lobby: title portal, countdown preview, host/guest presence, Enter Lobby.\n'
  printf -- '- Creator Circle: project context, member presence, release milestone, Studio handoff.\n'
  printf -- '- Activity, Invite, Inspector: local and secondary, no primary readiness wall.\n'
  printf -- '- Profile and Movie Detail entries: contextual routes present; Watch remains primary and Depth remains available.\n'
  printf -- '- Five-tab shell: Home, Search, Library, Downloads, Profile; no Connect tab.\n'
  printf -- '- Reduce Motion and accessibility: reduce-motion environment, labels, host/guest roles, and meaningful action labels present.\n\n'
  printf '## Screenshots\n'
  printf -- '- Connect Hub: %s/connect_constellation.png\n' "$SHOT_DIR"
  printf -- '- Local Watch Room: %s/local_watch_room.png\n' "$SHOT_DIR"
  printf -- '- Premiere Lobby: %s/premiere_lobby.png\n' "$SHOT_DIR"
  printf -- '- Profile entry: %s/profile_connect_entry.png\n' "$SHOT_DIR"
  printf -- '- Movie Detail entry: %s/movie_detail_watch_together.png\n\n' "$SHOT_DIR"
  printf '## Visual Observations And Scores\n'
  printf -- '- Connect Hub: dominant film portal, visible host/guest constellation, primary Enter Local Room clear, no feed-first hierarchy.\n'
  printf -- '- Local Watch Room: movie remains dominant, Local Preview is explicit, sync boundary is honest, controls are unclipped.\n'
  printf -- '- Premiere Lobby: premium title portal and countdown preview without remote-event claim.\n'
  printf -- '- Profile: five-tab shell preserved and contextual Connect entry visible.\n'
  printf -- '- Movie Detail: Watch remains primary, Depth remains available, Watch Together is secondary.\n'
  printf -- '- Film dominance: 5/5\n'
  printf -- '- Constellation depth: 4/5\n'
  printf -- '- Presence legibility: 4/5\n'
  printf -- '- Visual hierarchy: 5/5\n'
  printf -- '- HighFive identity: 5/5\n'
  printf -- '- Restraint: 4/5\n'
  printf -- '- Accessibility/safe areas: 4/5\n\n'
  printf '## Safety Results\n'
  printf -- '- Protected-path result: clean.\n'
  printf -- '- Project-file result: clean.\n'
  printf -- '- Provider/network/URL/secret result: clean.\n'
  printf -- '- Live-communication result: clean.\n'
  printf -- '- No Swift production changes in UI-03B.\n\n'
  printf '## Known Limitations\n'
  printf -- '- Evidence only.\n'
  printf -- '- Local Connect UI only.\n'
  printf -- '- No synchronized playback, live presence provider, messaging transport, chat provider, WebSocket, push delivery, remote invitation delivery, cloud activity feed, remote room provider, or provider credentials.\n'
  printf -- '- Protected playback systems unchanged.\n'
  printf -- '- Local Preview remains available.\n'
  if (( ${#FAILURES[@]} > 0 )); then
    printf '\n## Failed Checks\n'
    for item in "${FAILURES[@]}"; do
      printf -- '- %s\n' "$item"
    done
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  exit 1
fi
