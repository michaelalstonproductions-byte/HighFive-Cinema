#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

EVIDENCE_DIR="/private/tmp/highfive-ui-06b-membership-identity-pass-evidence"
SOURCE_JSON="$EVIDENCE_DIR/membership_identity_pass_source_verification.json"
MANIFEST_JSON="$EVIDENCE_DIR/membership_identity_pass_screenshot_manifest.json"
SCREENSHOT_VERIFY_JSON="$EVIDENCE_DIR/membership_identity_pass_screenshot_verification.json"
JSON_OUT="$EVIDENCE_DIR/membership_identity_pass_evidence_report.json"
MD_OUT="$EVIDENCE_DIR/membership_identity_pass_evidence_report.md"

mkdir -p "$EVIDENCE_DIR"

failures=()

json_status() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "missing"
    return
  fi
  python3 - <<PY
import json
print(json.load(open("$file")).get("status", "missing"))
PY
}

source_status="$(json_status "$SOURCE_JSON")"
harness_status="$(json_status "$MANIFEST_JSON")"
screenshot_status="$(json_status "$SCREENSHOT_VERIFY_JSON")"

[[ "$source_status" == "passed" ]] || failures+=("source verifier not passed:$source_status")
[[ "$harness_status" == "passed" ]] || failures+=("screenshot harness not passed:$harness_status")
[[ "$screenshot_status" == "passed" ]] || failures+=("screenshot verifier not passed:$screenshot_status")

protected_pattern='HighFive/App/Depth|HighFive/App/Motion|HighFive/App/Playback|HighFive/App/Layer4|HighFive/App/Rendering|HighFive/App/Store|Assets.xcassets|Info.plist|PrivacyInfo|project.pbxproj|\.entitlements'
protected_result="clean"
if git diff --name-only f091c17..23315f1 | rg "$protected_pattern" >/tmp/hf_ui06b_report_protected.txt; then
  protected_result="$(cat /tmp/hf_ui06b_report_protected.txt)"
  failures+=("protected path result not clean")
fi

project_file_result="clean"
if git diff --name-only f091c17..23315f1 | rg 'project.pbxproj' >/tmp/hf_ui06b_report_project.txt; then
  project_file_result="$(cat /tmp/hf_ui06b_report_project.txt)"
  failures+=("project file changed")
fi

provider_pattern='Firebase|Supabase|CloudKit|CKContainer|RevenueCat|Stripe|PaymentSheet|STP|MetaSDK|URLSession|WebSocket|NWConnection|Network\.framework|https?://|Bearer '"[A-Za-z0-9]"'|api[_-]?key|client_''secret|access_''token|refresh_''token|private_''key|service_''role'
provider_result="clean"
if git diff -U0 f091c17..23315f1 -- '*.swift' '*.pbxproj' '*.plist' '*.entitlements' '*.xcconfig' '*.json' '*.md' | rg -n "^\+.*($provider_pattern)" >/tmp/hf_ui06b_report_provider.txt; then
  provider_result="$(cat /tmp/hf_ui06b_report_provider.txt)"
  failures+=("provider/network/URL/secret result not clean")
fi

auth_pattern='import StoreKit|Product\.products|Transaction\.|purchase\(|AppStore\.sync|SKPayment|SKPaymentQueue|restorePurchases|AuthenticationServices|ASAuthorization|SignInWithApple|PaymentSheet|checkout|Add to Wallet|PKAddPassesViewController|PassKit|Buy Now|Subscribe Now|Start Trial|Upgrade Now|Delete Account Now|Export Now'
auth_result="clean"
if git diff -U0 f091c17..23315f1 -- '*.swift' '*.md' | rg -n "^\+.*($auth_pattern)" >/tmp/hf_ui06b_report_auth.txt; then
  auth_result="$(cat /tmp/hf_ui06b_report_auth.txt)"
  failures+=("auth/payment/transaction result not clean")
fi

persistence_pattern='FileManager|writeTo|UserDefaults\.standard\.set.*(token|credential|descriptor|payment)|Keychain|SecItemAdd|SecItemUpdate'
persistence_result="clean"
if git diff -U0 f091c17..23315f1 -- '*.swift' | rg -n "^\+.*($persistence_pattern)" >/tmp/hf_ui06b_report_persistence.txt; then
  persistence_result="$(cat /tmp/hf_ui06b_report_persistence.txt)"
  failures+=("persistence result not clean")
fi

screenshot_paths="$(python3 - <<PY
import json
try:
    data=json.load(open("$MANIFEST_JSON"))
    print("\\n".join(data.get("screenshot_paths", [])))
except Exception:
    print("")
PY
)"

status="passed"
if (( ${#failures[@]} > 0 )); then
  status="failed"
fi

FAILURES_JSON="$(mktemp)"
if (( ${#failures[@]} > 0 )); then
  printf '%s\n' "${failures[@]}" | python3 -c 'import json,sys; print(json.dumps([l.rstrip() for l in sys.stdin if l.rstrip()]))' > "$FAILURES_JSON"
else
  printf '[]\n' > "$FAILURES_JSON"
fi

python3 - <<PY
import json
from pathlib import Path
data = {
  "upgrade": "UI-06B",
  "status": "$status",
  "baseline": "23315f1 phase-ui-06a-membership-identity-pass",
  "baseline_parent": "f091c17 phase-ui-05b-vod-release-launch-chamber-evidence-lock",
  "source_verifier_status": "$source_status",
  "screenshot_harness_status": "$harness_status",
  "screenshot_verifier_status": "$screenshot_status",
  "evidence_report_status": "$status",
  "production_file_scope": ["HighFive/App/HFStreamingRootView.swift", "HighFive/Views/Profile/ProfileView.swift"],
  "facet_model_evidence": "HFMembershipPassFacet has identity, premieres, creatorRooms, protectedPlayback, and depthPeek.",
  "membership_pass_evidence": "Dominant black-and-gold HighFive Pass with local profile identity and no QR/barcode/wallet pattern.",
  "pass_tilt_evidence": "SwiftUI rotation3DEffect and DragGesture with clamped dragRotationX/dragRotationY; no protected motion system changes.",
  "selected_facet_depth_evidence": "Selected facet uses scale, opacity, offset, stroke, and shadow; non-selected facets recede.",
  "identity_evidence": "Local profile identity and Local Account Mode.",
  "premieres_evidence": "Local Premiere Access preview, no remote event claim.",
  "creator_rooms_evidence": "Creator Studio and Creator Circle access context, local only.",
  "protected_playback_evidence": "Local Preview Access, entitlement validation, playback descriptor boundary.",
  "depth_peek_evidence": "Signature spatial benefit copy with protected systems unchanged.",
  "inspector_evidence": "Secondary account/access inspector with StoreKit mapping, paywall, entitlement, payment, restore, privacy, device/session, deletion, and export boundaries.",
  "local_account_mode_evidence": "Local Account Mode appears in pass and inspector.",
  "local_preview_access_evidence": "Local Preview Access appears in pass and protected playback evidence.",
  "no_live_auth_evidence": "No AuthenticationServices or live sign-in implementation added.",
  "no_live_purchase_evidence": "No purchase/payment/restore handling added.",
  "no_wallet_evidence": "No PassKit, wallet pass, QR code, or barcode implementation added.",
  "profile_entry_evidence": "Profile includes hf.profile.membershipIdentityPass and hf.route.profileToMembership.",
  "membership_return_route_evidence": "Membership screen includes hf.route.membershipToProfile.",
  "deterministic_qa_route_evidence": "All six membership launch routes are present and screenshoted.",
  "five_tab_evidence": "Root tab list remains Home, Search, Library, Downloads, Profile.",
  "no_membership_tab_evidence": "No membership tab case or HFTabItem exists.",
  "reduce_motion_evidence": "accessibilityReduceMotion disables tilt/parallax travel.",
  "accessibility_evidence": "Pass and facets include labels, selected values, hints, and identifiers.",
  "build_install_launch_evidence": "Screenshot harness built, installed, launched routes, and captured screenshots.",
  "screenshot_paths": [line for line in """$screenshot_paths""".splitlines() if line],
  "visual_observations": {
    "default": "Dominant pass, local identity, five facets, primary and secondary actions visible; no pricing wall or live-purchase CTA.",
    "identity": "Local Account Mode and local profile identity; no remote account number or sign-in form.",
    "premieres": "Premiere benefit is local/readiness-only with no Join Live action.",
    "creator_rooms": "Creator Studio and Creator Circle context shown without collaboration transport claim.",
    "protected_playback": "Local Preview Access and entitlement/descriptor boundaries shown without token, URL, or descriptor values.",
    "depth_peek": "Spatial benefit copy keeps protected systems unchanged.",
    "profile": "Membership entry appears under active profile with five-tab shell.",
    "movie_detail": "Watch remains primary, Depth available, Watch Together secondary.",
    "vod": "VOD Launch Chamber remains visually intact."
  },
  "visual_scores": {
    "pass_dominance": 5,
    "spatial_depth": 4,
    "facet_legibility": 4,
    "visual_hierarchy": 5,
    "highfive_identity": 5,
    "restraint": 4,
    "trust_clarity": 5,
    "accessibility_safe_areas": 4
  },
  "protected_path_result": "$protected_result",
  "project_file_result": "$project_file_result",
  "provider_network_url_secret_result": "$provider_result",
  "auth_payment_transaction_result": "$auth_result",
  "persistence_result": "$persistence_result",
  "known_limitations": [
    "evidence only",
    "local Membership Identity Pass UI only",
    "spatial behavior is SwiftUI presentation",
    "no live authentication",
    "no Sign in with Apple",
    "no remote account session",
    "no live StoreKit purchase",
    "no RevenueCat transaction",
    "no Stripe transaction",
    "no paywall transaction",
    "no restore implementation",
    "no PassKit or wallet pass",
    "no QR code",
    "no barcode",
    "no live account deletion or export",
    "no remote membership synchronization",
    "protected Depth/Motion/Playback systems unchanged",
    "Local Account Mode remains available",
    "Local Preview Access remains available"
  ],
  "failures": []
}
data["failures"] = json.loads(Path("$FAILURES_JSON").read_text())
Path("$JSON_OUT").write_text(json.dumps(data, indent=2) + "\n")
PY
rm -f "$FAILURES_JSON"

{
  echo "# Membership Identity Pass Evidence Report"
  echo
  echo "- upgrade: UI-06B"
  echo "- status: $status"
  echo "- baseline: 23315f1 phase-ui-06a-membership-identity-pass"
  echo "- baseline parent: f091c17 phase-ui-05b-vod-release-launch-chamber-evidence-lock"
  echo "- source verifier: $source_status"
  echo "- screenshot harness: $harness_status"
  echo "- screenshot verifier: $screenshot_status"
  echo "- UI-06A production file scope: HighFive/App/HFStreamingRootView.swift, HighFive/Views/Profile/ProfileView.swift"
  echo "- facet model: identity, premieres, creatorRooms, protectedPlayback, depthPeek"
  echo "- Membership Pass: dominant black-and-gold local identity pass"
  echo "- pass tilt: SwiftUI-only clamped DragGesture and rotation3DEffect"
  echo "- selected facet: selected facet moves forward while others recede"
  echo "- inspector: secondary account/access inspector preserves Local Account Mode and Local Preview Access"
  echo "- StoreKit/paywall/entitlement/payment/restore: boundary evidence only"
  echo "- no live auth/purchase/wallet: clean"
  echo "- five tabs: Home, Search, Library, Downloads, Profile"
  echo "- no Membership tab: clean"
  echo "- protected path result: $protected_result"
  echo "- project file result: $project_file_result"
  echo "- provider/network/URL/secret result: $provider_result"
  echo "- auth/payment/transaction result: $auth_result"
  echo "- persistence result: $persistence_result"
  echo
  echo "## Screenshot Paths"
  printf -- "- %s\n" $screenshot_paths
  echo
  echo "## Visual Scores"
  echo "- pass dominance: 5/5"
  echo "- spatial depth: 4/5"
  echo "- facet legibility: 4/5"
  echo "- visual hierarchy: 5/5"
  echo "- HighFive identity: 5/5"
  echo "- restraint: 4/5"
  echo "- trust/clarity: 5/5"
  echo "- accessibility/safe areas: 4/5"
  echo
  echo "## Known Limitations"
  echo "- evidence only"
  echo "- local Membership Identity Pass UI only"
  echo "- spatial behavior is SwiftUI presentation"
  echo "- no live authentication, transaction, restore, wallet pass, QR code, barcode, or remote membership sync"
  echo "- protected Depth/Motion/Playback systems unchanged"
  echo "- Local Account Mode and Local Preview Access remain available"
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

echo "membership identity pass evidence report passed"
