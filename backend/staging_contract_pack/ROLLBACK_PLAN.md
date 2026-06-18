# Rollback Plan

## Immediate Rollback

1. Remove or disable the iOS runtime endpoint config.
2. Keep the app without committed backend URL values.
3. Confirm the app reports `Local Preview fallback active`.
4. Confirm no descriptor request is made without complete runtime config.

## Backend Rollback

1. Return `local_preview_fallback` or `descriptor_unavailable` from staging endpoints.
2. Keep entitlement audit records server-side for incident review.
3. Disable descriptor issuance server-side.
4. Rotate server-only credentials in the staging secret store if exposure is suspected.

## User-Facing Result

The app remains usable through Local Preview. No production playback claim is made by this contract pack.
