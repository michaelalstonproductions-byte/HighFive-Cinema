# LP2 Apple Production Configuration

LP2 prepares HighFive Cinema for Apple production signing and export without committing certificates, provisioning profiles, App Store Connect keys, APNs keys, or StoreKit secrets.

## Configured In The Repository

- Production entitlements: `HighFive/Config/HighFiveProduction.entitlements`
- Privacy manifest: `HighFive/Config/PrivacyInfo.xcprivacy`
- App Store Connect export options example: `HighFive/Config/ExportOptions.AppStore.example.plist`
- Production signing example: `HighFive/Config/ProductionSigning.xcconfig.example`
- Verification script: `scripts/verify_lp2_apple_production_configuration.sh`
- Archive/export helper: `scripts/lp2_apple_production_archive.sh`

## Enabled Capabilities

- Push Notifications through `aps-environment`
- Sign in with Apple through `com.apple.developer.applesignin`
- StoreKit remains framework/runtime based and does not require a checked-in secret.
- App Store Server API credentials remain backend-only and must be injected through production secret management.

## Manual Apple Setup Required

1. Confirm bundle ID `com.higherkey.HighFiveCinemaClean.HighFive` in Apple Developer.
2. Enable Push Notifications and Sign in with Apple for that bundle ID.
3. Create or refresh App Store distribution provisioning for the bundle ID.
4. Configure APNs key material in backend secret storage.
5. Configure StoreKit products in App Store Connect.
6. Configure App Store Server API key material in backend secret storage.
7. Copy `HighFive/Config/ExportOptions.AppStore.example.plist` to an untracked production export options file only if local overrides are needed.

## Commands

Verify checked-in Apple production config:

```bash
scripts/lp2_apple_production_archive.sh verify
```

Compile an unsigned Release archive for local CI validation:

```bash
scripts/lp2_apple_production_archive.sh unsigned-archive
```

Export a signed archive after Apple signing assets are installed:

```bash
HIGHFIVE_ARCHIVE_PATH="/path/to/HighFive.xcarchive" \
HIGHFIVE_EXPORT_OPTIONS="/path/to/ExportOptions.AppStore.plist" \
scripts/lp2_apple_production_archive.sh export-signed
```

## Security Boundary

The repository must never contain:

- `.p8` App Store Connect keys
- APNs keys
- signing certificates
- provisioning profiles
- Apple account credentials
- API tokens

Runtime Apple credentials belong in CI secrets, Keychain, or backend secret storage only.
