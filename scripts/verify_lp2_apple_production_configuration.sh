#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_FILE="$ROOT_DIR/HighFive.xcodeproj/project.pbxproj"
ENTITLEMENTS="$ROOT_DIR/HighFive/Config/HighFiveProduction.entitlements"
PRIVACY="$ROOT_DIR/HighFive/Config/PrivacyInfo.xcprivacy"
EXPORT_OPTIONS="$ROOT_DIR/HighFive/Config/ExportOptions.AppStore.example.plist"

require_file() {
  test -f "$1" || {
    echo "Missing required file: $1" >&2
    exit 1
  }
}

require_file "$PROJECT_FILE"
require_file "$ENTITLEMENTS"
require_file "$PRIVACY"
require_file "$EXPORT_OPTIONS"

plutil -lint "$ENTITLEMENTS" >/dev/null
plutil -lint "$PRIVACY" >/dev/null
plutil -lint "$EXPORT_OPTIONS" >/dev/null

grep -q "CODE_SIGN_ENTITLEMENTS = HighFive/Config/HighFiveProduction.entitlements;" "$PROJECT_FILE"
grep -q "HIGHFIVE_APNS_ENVIRONMENT = development;" "$PROJECT_FILE"
grep -q "HIGHFIVE_APNS_ENVIRONMENT = production;" "$PROJECT_FILE"
grep -q "Config/ExportOptions.AppStore.example.plist," "$PROJECT_FILE"
grep -q "Config/HighFiveProduction.entitlements," "$PROJECT_FILE"
grep -q "Config/ProductionSigning.xcconfig.example," "$PROJECT_FILE"
grep -q "PRODUCT_BUNDLE_IDENTIFIER = com.higherkey.HighFiveCinemaClean.HighFive;" "$PROJECT_FILE"
grep -q "DEVELOPMENT_TEAM = 4N9QF424Z8;" "$PROJECT_FILE"

/usr/libexec/PlistBuddy -c "Print :aps-environment" "$ENTITLEMENTS" >/dev/null
/usr/libexec/PlistBuddy -c "Print :com.apple.developer.applesignin:0" "$ENTITLEMENTS" | grep -q "Default"
/usr/libexec/PlistBuddy -c "Print :NSPrivacyTracking" "$PRIVACY" | grep -q "false"
/usr/libexec/PlistBuddy -c "Print :NSPrivacyAccessedAPITypes:0:NSPrivacyAccessedAPIType" "$PRIVACY" | grep -q "NSPrivacyAccessedAPICategoryUserDefaults"
/usr/libexec/PlistBuddy -c "Print :method" "$EXPORT_OPTIONS" | grep -q "app-store-connect"

bearer_fragment="Bear""er "
secret_pattern="(BEGIN .*PRIVATE KEY|${bearer_fragment}|access_[t]oken|refresh_[t]oken|client_[s]ecret|api[_-]?key\s*[=:]|password\s*=|token\s*=)"
if rg -n "$secret_pattern" \
  "$ROOT_DIR/HighFive/Config" "$ROOT_DIR/docs/apple_production" >/tmp/highfive-lp2-secret-scan.txt; then
  cat /tmp/highfive-lp2-secret-scan.txt >&2
  exit 1
fi

echo "LP2 Apple production configuration verification passed."
