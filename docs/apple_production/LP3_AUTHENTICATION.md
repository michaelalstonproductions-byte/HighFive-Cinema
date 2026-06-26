# LP3 Authentication

LP3 connects HighFive Cinema's existing identity runtime to real authentication boundaries while keeping a simulator-safe development identity mode.

## Implemented

- Sign in with Apple UI entry point in the Profile Account panel.
- Apple credential exchange client in the iOS app.
- Keychain-backed HighFive session storage remains the only persistent session store.
- Backend Apple exchange endpoint now requires credential material and never echoes or stores provider credentials.
- Development identity endpoint remains available for simulator and CI validation.
- Session refresh, sign-out, deletion request, and role checks use the same HighFive session contract.
- OpenAPI now advertises the identity endpoints.

## Manual Production Setup Required

1. Enable Sign in with Apple for bundle ID `com.higherkey.HighFiveCinemaClean.HighFive`.
2. Configure production backend URL through `HIGHFIVE_BACKEND_BASE_URL` or auth URL through `HIGHFIVE_AUTH_BASE_URL`.
3. Validate Apple identity tokens server-side against Apple's public keys in production infrastructure.
4. Store production session secrets only in backend secret management.
5. Keep simulator development identity enabled for local builds and disabled for public production policy when required.

## Security Boundary

The app sends Apple credential material to the configured backend exchange endpoint and stores only the returned HighFive session in Keychain. The backend scaffold validates request shape and redacts credentials from responses and audit output, but full Apple token verification requires deployed production backend configuration.

No Apple private keys, App Store Connect keys, APNs keys, provisioning profiles, session signing secrets, or production tokens are committed.
