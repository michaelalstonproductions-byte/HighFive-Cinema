#!/usr/bin/env bash
set -u -o pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="/private/tmp/highfive-ui-03b-connect-constellation-evidence"
JSON_OUT="$OUT_DIR/connect_constellation_source_verification.json"
MD_OUT="$OUT_DIR/connect_constellation_source_verification.md"
mkdir -p "$OUT_DIR"

declare -a PASSES=()
declare -a FAILURES=()

pass() {
  PASSES+=("$1")
}

fail() {
  FAILURES+=("$1")
}

require_fixed() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -Fq -- "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_regex() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_absent_regex() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    fail "$label"
  else
    pass "$label"
  fi
}

CONNECT_FILE="HighFive/Views/Connect/ConnectHubView.swift"
ROOT_FILE="HighFive/App/HFStreamingRootView.swift"
PROFILE_FILE="HighFive/Views/Profile/ProfileView.swift"
MOVIE_FILE="HighFive/Views/MovieDetail/MovieDetailView.swift"

mode_count="$(sed -n '/enum HFConnectSpatialMode/,/}/p' "$CONNECT_FILE" | rg -c '^[[:space:]]*case ')"
if [[ "$mode_count" == "3" ]]; then
  pass "HFConnectSpatialMode has exactly three cases"
else
  fail "HFConnectSpatialMode has exactly three cases"
fi

require_fixed "enum HFConnectSpatialMode" "$CONNECT_FILE" "HFConnectSpatialMode exists"
require_fixed "case hub" "$CONNECT_FILE" "Connect hub mode exists"
require_fixed "case watchRoom" "$CONNECT_FILE" "Connect watchRoom mode exists"
require_fixed "case premiereLobby" "$CONNECT_FILE" "Connect premiereLobby mode exists"
require_fixed "init(initialMode: HFConnectSpatialMode = .hub" "$CONNECT_FILE" "Connect default mode is hub"

require_fixed "--hf-start-connect" "$ROOT_FILE" "Connect Hub launch route exists"
require_fixed "--hf-start-connect-room" "$ROOT_FILE" "Local Watch Room launch route exists"
require_fixed "--hf-start-premiere-lobby" "$ROOT_FILE" "Premiere Lobby launch route exists"
require_fixed "if arguments.contains(\"--hf-start-connect-room\") { return .watchRoom }" "$ROOT_FILE" "Connect room route selects watchRoom"
require_fixed "if arguments.contains(\"--hf-start-premiere-lobby\") { return .premiereLobby }" "$ROOT_FILE" "Premiere route selects premiereLobby"
require_fixed "ConnectHubView(initialMode: Self.connectInitialMode)" "$ROOT_FILE" "Connect route launches without tapping"

require_fixed "spatialConnectWorld" "$CONNECT_FILE" "Connect primary scene is spatialConnectWorld"
require_fixed "moviePortal(width:" "$CONNECT_FILE" "Dominant movie portal is built"
require_fixed "currentMovie.backdropAssetName ?? currentMovie.posterAssetName" "$CONNECT_FILE" "Movie portal uses selected/local artwork"
require_fixed "movie ?? HFMockData.movie(\"friendly\") ?? HFMockData.movies[0]" "$CONNECT_FILE" "Safe local movie fallback exists"
require_fixed "presenceConstellation(in:" "$CONNECT_FILE" "Viewer constellation is built"
require_fixed "presenceArcs(in:" "$CONNECT_FILE" "Restrained presence arcs are built"
require_fixed "role: \"Host\", isHost: true" "$CONNECT_FILE" "Host presence is modelled"
require_fixed "role: \"Guest\", isHost: false" "$CONNECT_FILE" "Guest presence is modelled"
require_fixed "HFColors.goldGradient" "$CONNECT_FILE" "Gold host/primary accent is present"
require_fixed "HFColors.cyanGlow" "$CONNECT_FILE" "Cyan presence accent is present"
require_fixed "Enter Local Room" "$CONNECT_FILE" "Connect primary Enter Local Room action exists"
require_fixed "Invite" "$CONNECT_FILE" "Invite action exists"
require_fixed "More" "$CONNECT_FILE" "More action exists"
require_fixed "Local Preview" "$CONNECT_FILE" "Local Preview state exists"
require_fixed "secondaryConnectContexts" "$CONNECT_FILE" "Activity and secondary contexts are below primary scene"

require_fixed "hf.spatial.connect" "$CONNECT_FILE" "Connect root identifier exists"
require_fixed "hf.spatial.connect.portal" "$CONNECT_FILE" "Connect portal identifier exists"
require_fixed "hf.spatial.connect.title" "$CONNECT_FILE" "Connect title identifier exists"
require_fixed "hf.spatial.connect.constellation" "$CONNECT_FILE" "Connect constellation identifier exists"
require_fixed "hf.spatial.connect.host" "$CONNECT_FILE" "Connect host identifier exists"
require_fixed "hf.spatial.connect.presence" "$CONNECT_FILE" "Connect presence identifier exists"
require_fixed "hf.spatial.connect.enterRoom" "$CONNECT_FILE" "Connect enter-room identifier exists"
require_fixed "hf.spatial.connect.invite" "$CONNECT_FILE" "Connect invite identifier exists"
require_fixed "hf.spatial.connect.more" "$CONNECT_FILE" "Connect more identifier exists"
require_fixed "hf.spatial.connect.localPreview" "$CONNECT_FILE" "Connect Local Preview identifier exists"

require_fixed "Local Preview Room" "$CONNECT_FILE" "Local Watch Room copy exists"
require_fixed "Watching locally" "$CONNECT_FILE" "Watching locally copy exists"
require_fixed "Room presence preview" "$CONNECT_FILE" "Room presence preview copy exists"
require_fixed "Playback synchronization not connected" "$CONNECT_FILE" "Playback-sync boundary copy exists"
require_fixed "Continue Local Preview" "$CONNECT_FILE" "Continue Local Preview action exists"
require_fixed "React" "$CONNECT_FILE" "React action exists"
require_fixed "Leave" "$CONNECT_FILE" "Leave action exists"
require_fixed "hf.spatial.watchRoom" "$CONNECT_FILE" "Watch Room root identifier exists"
require_fixed "hf.spatial.watchRoom.portal" "$CONNECT_FILE" "Watch Room portal identifier exists"
require_fixed "hf.spatial.watchRoom.host" "$CONNECT_FILE" "Watch Room host identifier exists"
require_fixed "hf.spatial.watchRoom.guests" "$CONNECT_FILE" "Watch Room guests identifier exists"
require_fixed "hf.spatial.watchRoom.reactions" "$CONNECT_FILE" "Watch Room reactions identifier exists"
require_fixed "hf.spatial.watchRoom.invite" "$CONNECT_FILE" "Watch Room invite identifier exists"
require_fixed "hf.spatial.watchRoom.leave" "$CONNECT_FILE" "Watch Room leave identifier exists"
require_fixed "hf.spatial.watchRoom.localPreview" "$CONNECT_FILE" "Watch Room Local Preview identifier exists"
require_fixed "hf.spatial.watchRoom.syncNotConnected" "$CONNECT_FILE" "Watch Room sync boundary identifier exists"

require_fixed "Premiere Lobby" "$CONNECT_FILE" "Premiere Lobby copy exists"
require_fixed "Countdown preview" "$CONNECT_FILE" "Premiere countdown preview exists"
require_fixed "Enter Lobby" "$CONNECT_FILE" "Premiere Enter Lobby action exists"
require_fixed "hf.spatial.premiereLobby" "$CONNECT_FILE" "Premiere Lobby root identifier exists"
require_fixed "hf.spatial.premiereLobby.portal" "$CONNECT_FILE" "Premiere Lobby portal identifier exists"
require_fixed "hf.spatial.premiereLobby.countdown" "$CONNECT_FILE" "Premiere countdown identifier exists"
require_fixed "hf.spatial.premiereLobby.host" "$CONNECT_FILE" "Premiere host identifier exists"
require_fixed "hf.spatial.premiereLobby.guests" "$CONNECT_FILE" "Premiere guests identifier exists"
require_fixed "hf.spatial.premiereLobby.enter" "$CONNECT_FILE" "Premiere enter identifier exists"

require_fixed "hf.spatial.creatorCircle" "$CONNECT_FILE" "Creator Circle root identifier exists"
require_fixed "hf.spatial.creatorCircle.project" "$CONNECT_FILE" "Creator Circle project identifier exists"
require_fixed "hf.spatial.creatorCircle.members" "$CONNECT_FILE" "Creator Circle members identifier exists"
require_fixed "hf.spatial.creatorCircle.milestone" "$CONNECT_FILE" "Creator Circle milestone identifier exists"
require_fixed "hf.spatial.creatorCircle.openStudio" "$CONNECT_FILE" "Creator Circle Studio handoff identifier exists"

require_fixed "showingActivity" "$CONNECT_FILE" "Local activity sheet state exists"
require_fixed "showingInvite" "$CONNECT_FILE" "Local invite sheet state exists"
require_fixed "showingInspector" "$CONNECT_FILE" "Secondary inspector state exists"
require_fixed "hf.connect.activity" "$CONNECT_FILE" "Activity identifier exists"
require_fixed "hf.connect.activity.localOnly" "$CONNECT_FILE" "Activity local-only identifier exists"
require_fixed "hf.connect.inspector" "$CONNECT_FILE" "Inspector identifier exists"
require_fixed "Presence Provider Not Connected" "$CONNECT_FILE" "Presence boundary copy exists"
require_fixed "Playback Sync Not Connected" "$CONNECT_FILE" "Sync boundary copy exists"
require_fixed "Invitations Local Only" "$CONNECT_FILE" "Invitation boundary copy exists"
require_fixed "Activity Local Only" "$CONNECT_FILE" "Activity boundary copy exists"
require_fixed "No live messaging" "$CONNECT_FILE" "No live messaging boundary copy exists"
require_fixed "No remote watch-room provider" "$CONNECT_FILE" "No remote room provider boundary copy exists"
require_fixed "hf.connect.presenceNotConnected" "$CONNECT_FILE" "Presence boundary identifier exists"
require_fixed "hf.connect.syncNotConnected" "$CONNECT_FILE" "Sync boundary identifier exists"
require_fixed "hf.connect.invitesLocalOnly" "$CONNECT_FILE" "Invite boundary identifier exists"
require_fixed "hf.connect.noLiveMessaging" "$CONNECT_FILE" "No live messaging identifier exists"
require_fixed "hf.connect.noLiveRoomProvider" "$CONNECT_FILE" "No live room provider identifier exists"

require_fixed "hf.route.profileToConnect" "$PROFILE_FILE" "Profile to Connect route identifier exists"
require_fixed "ConnectHubView()" "$PROFILE_FILE" "Profile routes contextually to Connect"
require_fixed "hf.movieDetail.watchTogether" "$MOVIE_FILE" "Movie Detail Watch Together identifier exists"
require_fixed "hf.route.movieDetailToConnect" "$MOVIE_FILE" "Movie Detail to Connect route identifier exists"
require_fixed "ConnectHubView(initialMode: .watchRoom, movie: catalogMovie)" "$MOVIE_FILE" "Movie Detail routes selected title into Watch Room"
require_fixed "HFEnergyAction(title: catalogMovie.isComingSoon ? \"Preview\" : \"Watch\"" "$MOVIE_FILE" "Watch remains primary"
require_fixed "HFEnergyAction(title: \"Depth\"" "$MOVIE_FILE" "Depth remains available"

tab_count="$(rg -c 'HFTabItem\(value:' "$ROOT_FILE")"
if [[ "$tab_count" == "5" ]]; then
  pass "Exactly five HFTabItem entries"
else
  fail "Exactly five HFTabItem entries"
fi
require_fixed "HFTabItem(value: .home, title: \"Home\"" "$ROOT_FILE" "Home tab exists"
require_fixed "HFTabItem(value: .search, title: \"Search\"" "$ROOT_FILE" "Search tab exists"
require_fixed "HFTabItem(value: .library, title: \"Library\"" "$ROOT_FILE" "Library tab exists"
require_fixed "HFTabItem(value: .downloads, title: \"Downloads\"" "$ROOT_FILE" "Downloads tab exists"
require_fixed "HFTabItem(value: .profile, title: \"Profile\"" "$ROOT_FILE" "Profile tab exists"
require_absent_regex 'case connect|HFTabItem\(value: \.connect|selectedTab = \.connect' "$ROOT_FILE" "No Connect bottom tab or tab case"

require_fixed "@Environment(\\.accessibilityReduceMotion) private var reduceMotion" "$CONNECT_FILE" "Reduce Motion environment is used"
require_fixed "reduceMotion ? 1" "$CONNECT_FILE" "Static/reduced motion scale fallback exists"
require_fixed "reduceMotion ? 0" "$CONNECT_FILE" "Reduced motion glow fallback exists"
require_fixed "accessibilityLabel(\"\\(roomTitle), \\(currentMovie.title), room presence preview\")" "$CONNECT_FILE" "Portal scene accessibility label exists"
require_fixed "accessibilityLabel(\"\\(name), \\(role)\")" "$CONNECT_FILE" "Host and guest roles are labelled"
require_fixed "accessibilityLabel(\"Viewer constellation, host and three guests\")" "$CONNECT_FILE" "Constellation accessibility label exists"
require_fixed ".frame(height: 50)" "HighFive/Components/HFSpatialCinemaPrimitives.swift" "Energy actions have usable target height"
require_absent_regex 'repeatForever|TimelineView|Canvas|particle|Particle' "$CONNECT_FILE" "No unbounded orbit, timeline, or particle effect in Connect"

expected_scope=$'HighFive/App/HFStreamingRootView.swift\nHighFive/Views/Connect/ConnectHubView.swift\nHighFive/Views/MovieDetail/MovieDetailView.swift\nHighFive/Views/Profile/ProfileView.swift'
actual_scope="$(git diff --name-only 7aec2e6..b199939 | sort)"
if [[ "$actual_scope" == "$(printf '%s\n' "$expected_scope" | sort)" ]]; then
  pass "UI-03A production file scope is exactly four expected files"
else
  fail "UI-03A production file scope is exactly four expected files"
fi

protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|[.]entitlements'
if git diff --name-only 7aec2e6..b199939 | rg "$protected_pattern" >/dev/null; then
  fail "UI-03A protected/project-file scan is clean"
else
  pass "UI-03A protected/project-file scan is clean"
fi

network_pattern='Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|MetaSDK|FacebookCore|TikTok|YouTube|URLSession|WebSocket|NWConnection|Network[.]framework|https?://|Bearer |api[_-]?key|client_'
network_pattern+='secret|access_'
network_pattern+='token|refresh_'
network_pattern+='token|private_'
network_pattern+='key|service_'
network_pattern+='role'
if git diff -U0 7aec2e6..b199939 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n "^\\+.*($network_pattern)" >/dev/null; then
  fail "UI-03A provider/network/URL/secret scan is clean"
else
  pass "UI-03A provider/network/URL/secret scan is clean"
fi

live_pattern='Live Chat|Send Message|Message Sent|Synchronized Playback Active|Room Connected|Presence Connected|Invite Delivered|Remote Room Active|Start Live Room'
if git diff -U0 7aec2e6..b199939 -- '*.swift' '*.md' | rg -n "^\\+.*($live_pattern)" >/dev/null; then
  fail "UI-03A live-communication scan is clean"
else
  pass "UI-03A live-communication scan is clean"
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
  printf '  "checks_passed": %d,\n' "${#PASSES[@]}"
  printf '  "checks_failed": %d,\n' "${#FAILURES[@]}"
  printf '  "production_scope": [\n'
  printf '    "HighFive/App/HFStreamingRootView.swift",\n'
  printf '    "HighFive/Views/Connect/ConnectHubView.swift",\n'
  printf '    "HighFive/Views/MovieDetail/MovieDetailView.swift",\n'
  printf '    "HighFive/Views/Profile/ProfileView.swift"\n'
  printf '  ],\n'
  printf '  "failures": ['
  if (( ${#FAILURES[@]} > 0 )); then
    printf '"see markdown report"'
  fi
  printf ']\n'
  printf '}\n'
} > "$JSON_OUT"

{
  printf '# Connect Constellation Source Verification\n\n'
  printf -- '- Upgrade: UI-03B\n'
  printf -- '- Status: %s\n' "$status"
  printf -- '- Baseline: b199939 / phase-ui-03a-connect-constellation-watch-room\n'
  printf -- '- Baseline parent: 7aec2e6 / phase-ui-02b-creator-studio-spatial-worktable-evidence-lock\n'
  printf -- '- Checks passed: %d\n' "${#PASSES[@]}"
  printf -- '- Checks failed: %d\n\n' "${#FAILURES[@]}"
  printf '## Passed Checks\n'
  for item in "${PASSES[@]}"; do
    printf -- '- %s\n' "$item"
  done
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
