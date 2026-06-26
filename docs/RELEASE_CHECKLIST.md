# HighFive Cinema Release Checklist

## Required Local Verification

- Confirm clean git status.
- Confirm `project.pbxproj` is unchanged unless release signing requires a reviewed project edit.
- Run backend typecheck.
- Compile the staging backend to a temporary directory.
- Start the staging backend on loopback only.
- Run all backend smoke tests.
- Build the iOS app for the iOS Simulator.
- Create a local unsigned Release archive for device.
- Install and launch the app in a booted simulator.
- Capture release screenshots for the viewer, creator, admin, and platform routes.
- Run protected-path, tab, secret, network, file-write, persistence, and project-file scans.

## Required Production Configuration Before TestFlight

- Set Apple Developer Team ID and signing identities outside source control.
- Configure bundle identifiers, App Groups, associated domains, and push capabilities as required.
- Configure Sign in with Apple service ID and backend identity exchange.
- Configure APNs keys and notification environment.
- Configure StoreKit products in App Store Connect.
- Configure App Store Server API issuer/key credentials in the backend secret store.
- Configure backend deployment environment.
- Configure database, object storage, media processing workers, and CDN signing credentials.
- Configure monitoring, audit log sink, backup schedule, and rollback runbook owner.

## Release Candidate Gate

The release candidate may be tagged only when:

- The simulator build passes.
- Backend typecheck passes.
- Smoke tests pass.
- Required docs exist.
- No protected systems were unintentionally modified.
- No secrets or credentials were committed.
- Known limitations are documented.
- Manual production setup requirements are documented.

## TestFlight Gate

Do not submit to TestFlight until:

- Archive build succeeds with real signing.
- App Store Connect configuration is complete.
- A signed archive export has been produced from the release archive.
- Privacy manifests and app privacy answers are reviewed.
- Production backend staging environment is deployed and smoke-tested.
- Production secrets are stored outside git.
- Account deletion and data export are validated against the hosted backend.
