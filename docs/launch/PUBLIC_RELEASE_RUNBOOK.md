# HighFive Cinema Public Release Runbook

## Scope

LP16 records and validates the public release process inside the local staging backend. It does not submit the app to App Store Connect and does not release the app to customers by itself.

## Release Sequence

1. Run LP15 launch validation.
2. Confirm final legal terms and privacy notice.
3. Confirm App Store privacy answers.
4. Confirm signed archive export.
5. Upload final media and metadata to App Store Connect.
6. Submit for review outside this repository.
7. Record public release submission in the release operations endpoint.
8. After external release is confirmed, record public release cutover.
9. Monitor launch health, support queue, hotfixes, and creator onboarding.

## Local Validation

Run:

```bash
bash scripts/lp16_public_release_validation.sh
```

The script validates:

- Backend smoke suite
- iOS simulator build
- Screenshot matrix
- Launch package documents
- Public release operations smoke tests

## Manual Requirements

- App Store Connect submission
- App Store release cutover
- Final marketing URL
- Final support URL
- Final legal review
- Hosted backend monitoring
- Production telemetry

## Rollback

If a launch blocker appears:

1. Pause release rollout in App Store Connect when available.
2. Record an open hotfix in the public release endpoint.
3. Use the existing rollback plan for backend or app rollback.
4. Resolve or close the hotfix only after verification.
