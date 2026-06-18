# Rollback Guide

## App Rollback

- Remove runtime backend config from the staging app environment.
- Confirm the app reports Local Preview fallback.

## Server Rollback

- Return `local_preview_fallback` from entitlement validation when validation is unavailable.
- Return `descriptor_unavailable` from playback descriptor when signing is unavailable.
- Keep audit records server-side for incident review.

## Expected User Impact

Local Preview fallback remains available. No live Cloudflare playback is claimed by this scaffold.
