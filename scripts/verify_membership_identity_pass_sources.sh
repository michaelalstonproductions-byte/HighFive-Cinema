#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EVIDENCE_DIR="/private/tmp/highfive-ui-06b-membership-identity-pass-evidence"
mkdir -p "$EVIDENCE_DIR"

JSON_OUT="$EVIDENCE_DIR/membership_identity_pass_source_verification.json"
MD_OUT="$EVIDENCE_DIR/membership_identity_pass_source_verification.md"

BASELINE="23315f1"
BASELINE_PARENT="f091c17"
PROFILE="HighFive/Views/Profile/ProfileView.swift"
ROOT="HighFive/App/HFStreamingRootView.swift"

failures=()
passes=()

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    passes+=("file:$file")
  else
    failures+=("missing file:$file")
  fi
}

require_text() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    passes+=("$label")
  else
    failures+=("$label")
  fi
}

require_absent() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -q -- "$pattern" "$file"; then
    failures+=("$label")
  else
    passes+=("$label")
  fi
}

require_file "$PROFILE"
require_file "$ROOT"

required_profile_patterns=(
  "enum HFMembershipPassFacet"
  "case identity"
  "case premieres"
  "case creatorRooms"
  "case protectedPlayback"
  "case depthPeek"
  "return \"Identity\""
  "return \"Premieres\""
  "return \"Creator Rooms\""
  "return \"Protected Playback\""
  "return \"Depth \\+ Peek\""
  "var systemImage"
  "var purpose"
  "var accessibilityIdentifier"
  "var accent"
  "hf.spatial.membership.identity"
  "hf.spatial.membership.premieres"
  "hf.spatial.membership.creatorRooms"
  "hf.spatial.membership.protectedPlayback"
  "hf.spatial.membership.depthPeek"
  "HFMembershipIdentityPassView"
  "HighFive Pass"
  "Local Account Mode"
  "Local Preview Access"
  "rotation3DEffect"
  "DragGesture"
  "max\\(min\\("
  "passDrag == \\.zero"
  "accessibilityReduceMotion"
  "reduceMotion \\? 1"
  "hf.spatial.membership"
  "hf.spatial.membership.world"
  "hf.spatial.membership.pass"
  "hf.spatial.membership.passTitle"
  "hf.spatial.membership.profileIdentity"
  "hf.spatial.membership.selectedFacet"
  "hf.membership.reviewAccess"
  "hf.membership.accountPrivacy"
  "hf.membership.inspector"
  "hf.membership.backToProfile"
  "hf.route.membershipToProfile"
  "hf.membership.identityPreview"
  "hf.membership.localProfile"
  "hf.membership.premierePreview"
  "hf.membership.premiereAccess"
  "hf.membership.creatorRoomsPreview"
  "hf.membership.creatorStudioAccess"
  "hf.membership.creatorCircleAccess"
  "hf.membership.protectedPlaybackPreview"
  "hf.membership.entitlementValidation"
  "hf.membership.playbackDescriptorBoundary"
  "hf.membership.depthPeekPreview"
  "hf.membership.depthAccess"
  "hf.membership.tiltPeekAccess"
  "hf.membership.accountInspector"
  "hf.membership.membershipPreview"
  "hf.membership.storeKitMapping"
  "hf.membership.paywallReadiness"
  "hf.membership.paymentProviderNotConnected"
  "hf.membership.restoreNotActive"
  "hf.membership.privacyReadiness"
  "hf.membership.deviceSession"
  "hf.membership.deleteBoundary"
  "hf.membership.exportBoundary"
  "hf.membership.noLivePurchase"
  "hf.profile.membershipIdentityPass"
  "hf.route.profileToMembership"
)

for pattern in "${required_profile_patterns[@]}"; do
  require_text "$pattern" "$PROFILE" "profile pattern:$pattern"
done

required_root_patterns=(
  "--hf-start-membership"
  "--hf-start-membership-identity"
  "--hf-start-membership-premieres"
  "--hf-start-membership-creator-rooms"
  "--hf-start-membership-protected-playback"
  "--hf-start-membership-depth-peek"
  "shouldStartInMembership"
  "membershipInitialFacet"
  "initialMembershipFacet: Self.membershipInitialFacet"
  "startInMembership: Self.shouldStartInMembership"
)

for pattern in "${required_root_patterns[@]}"; do
  require_text "$pattern" "$ROOT" "root pattern:$pattern"
done

require_absent "QRCode|barcode|pricing-table|subscription-card|Membership HFTabItem|HFTabItem\\(value: \\.membership|case membership|selectedTab = \\.membership" "$ROOT" "no membership tab in root"
require_absent "QRCode|barcode|PKAddPassesViewController|Add to Wallet|Buy Now|Subscribe Now|Start Trial|Upgrade Now" "$PROFILE" "no wallet or purchase CTA in profile"

facet_count="$(python3 - <<'PY'
import re
from pathlib import Path
text = Path("HighFive/Views/Profile/ProfileView.swift").read_text()
m = re.search(r"enum\s+HFMembershipPassFacet[^{]*\{([\s\S]*?)\n\s*var\s+id\b", text)
if not m:
    print("0")
else:
    print(len(re.findall(r"^\s*case\s+", m.group(1), re.M)))
PY
)"
if [[ "$facet_count" == "5" ]]; then
  passes+=("exactly five membership facets")
else
  failures+=("expected exactly five membership facets, found $facet_count")
fi

tab_count="$(rg -c "HFTabItem\\(" "$ROOT")"
if [[ "$tab_count" == "5" ]]; then
  passes+=("exactly five HFTabItem entries")
else
  failures+=("expected five HFTabItem entries, found $tab_count")
fi

expected_files=$'HighFive/App/HFStreamingRootView.swift\nHighFive/Views/Profile/ProfileView.swift'
actual_files="$(git diff --name-only "$BASELINE_PARENT..$BASELINE" | sort)"
if [[ "$actual_files" == "$expected_files" ]]; then
  passes+=("UI-06A production file scope matches expected two files")
else
  failures+=("unexpected UI-06A production file scope:$actual_files")
fi

protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements'
if git diff --name-only "$BASELINE_PARENT..$BASELINE" | rg "$protected_pattern" >/tmp/hf_ui06b_protected_hits.txt; then
  failures+=("protected path hit:$(cat /tmp/hf_ui06b_protected_hits.txt)")
else
  passes+=("no protected/project/asset/plist/privacy/entitlement changes")
fi

provider_pattern='Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|PaymentSheet|STP|MetaSDK|URLSession|WebSocket|NWConnection|Network\.framework|https?://|Bearer '"[A-Za-z0-9]"'|api[_-]?key|client_''secret|access_''token|refresh_''token|private_''key|service_''role'
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n "^\+.*($provider_pattern)" >/tmp/hf_ui06b_provider_hits.txt; then
  failures+=("provider/network/URL/secret hit:$(cat /tmp/hf_ui06b_provider_hits.txt)")
else
  passes+=("no provider/network/URL/secret hits in UI-06A range")
fi

auth_pattern='import StoreKit|Product\.products|Transaction\.|purchase\(|AppStore\.sync|SKPayment|SKPaymentQueue|restorePurchases|AuthenticationServices|ASAuthorization|SignInWithApple|PaymentSheet|checkout|Add to Wallet|PKAddPassesViewController|PassKit|Buy Now|Subscribe Now|Start Trial|Upgrade Now|Delete Account Now|Export Now'
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' '*.md' | rg -n "^\+.*($auth_pattern)" >/tmp/hf_ui06b_auth_hits.txt; then
  failures+=("auth/payment/transaction hit:$(cat /tmp/hf_ui06b_auth_hits.txt)")
else
  passes+=("no auth/payment/transaction hits in UI-06A range")
fi

persistence_pattern='FileManager|writeTo|UserDefaults\.standard\.set.*(token|credential|descriptor|payment)|Keychain|SecItemAdd|SecItemUpdate'
if git diff -U0 "$BASELINE_PARENT..$BASELINE" -- '*.swift' | rg -n "^\+.*($persistence_pattern)" >/tmp/hf_ui06b_persistence_hits.txt; then
  failures+=("sensitive persistence hit:$(cat /tmp/hf_ui06b_persistence_hits.txt)")
else
  passes+=("no sensitive persistence hits in UI-06A range")
fi

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

PASS_JSON="$(mktemp)"
FAIL_JSON="$(mktemp)"
printf '%s\n' "${passes[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip("\n") for l in sys.stdin if l.rstrip("\n")]))' > "$PASS_JSON"
if (( ${#failures[@]} > 0 )); then
  printf '%s\n' "${failures[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip("\n") for l in sys.stdin if l.rstrip("\n")]))' > "$FAIL_JSON"
else
  printf '[]\n' > "$FAIL_JSON"
fi

python3 - <<PY
import json
from pathlib import Path
data = {
  "upgrade": "UI-06B",
  "status": "$status",
  "baseline": "23315f1 phase-ui-06a-membership-identity-pass",
  "baseline_parent": "f091c17 phase-ui-05b-vod-release-launch-chamber-evidence-lock",
  "production_scope": ["HighFive/App/HFStreamingRootView.swift", "HighFive/Views/Profile/ProfileView.swift"],
  "facet_count": int("$facet_count"),
  "tab_count": int("$tab_count"),
  "passes": [],
  "failures": []
}
data["passes"] = json.loads(Path("$PASS_JSON").read_text())
data["failures"] = json.loads(Path("$FAIL_JSON").read_text())
Path("$JSON_OUT").write_text(json.dumps(data, indent=2) + "\n")
PY
rm -f "$PASS_JSON" "$FAIL_JSON"

{
  echo "# Membership Identity Pass Source Verification"
  echo
  echo "- upgrade: UI-06B"
  echo "- status: $status"
  echo "- baseline: 23315f1 phase-ui-06a-membership-identity-pass"
  echo "- baseline parent: f091c17 phase-ui-05b-vod-release-launch-chamber-evidence-lock"
  echo "- production scope: HighFive/App/HFStreamingRootView.swift, HighFive/Views/Profile/ProfileView.swift"
  echo "- facet count: $facet_count"
  echo "- bottom tab count: $tab_count"
  echo
  echo "## Evidence"
  printf -- "- %s\n" "${passes[@]}"
  if (( ${#failures[@]} > 0 )); then
    echo
    echo "## Failures"
    printf -- "- %s\n" "${failures[@]}"
  fi
} > "$MD_OUT"

if [[ "$status" != "passed" ]]; then
  cat "$MD_OUT"
  exit 1
fi

echo "membership identity pass source verification passed"
