# P30A Real Identity & Access

This scaffold provides the first production-shaped identity boundary for HighFive Cinema.

## Local Development Mode

Run the local backend target and use the development identity endpoint:

```bash
cd backend/staging_server_scaffold
npx tsc -p tsconfig.http-target.json
HIGHFIVE_BACKEND_HOST=127.0.0.1 node /private/tmp/highfive-p30a-real-identity-access/compiled/runtime/start.js
```

Development sign-in creates local viewer, creator, or admin sessions in backend memory. The iOS app stores its active development session in Keychain and keeps the local profile fallback available.

## Production Sign In With Apple Setup

Production Apple identity is not configured in this repository. To enable it later:

1. Enable Sign in with Apple for the iOS app identifier in Apple Developer.
2. Add the required app capability and review any `project.pbxproj`, entitlements, `Info.plist`, and privacy-manifest diffs manually.
3. Implement backend validation for Apple identity assertions in the `/v1/identity/apple/exchange` route.
4. Store provider configuration in the deployment secret store, never in source control.
5. Keep simulator development identity mode enabled for local QA without production credentials.

## Authorization Contract

The local backend uses `HighFiveSession <session-id>` authorization for loopback smoke tests. Viewer sessions are denied creator workspace mutations, while creator and admin sessions are allowed.

No production credentials, private keys, provider secrets, payment credentials, uploads, or external network calls are included in P30A.
