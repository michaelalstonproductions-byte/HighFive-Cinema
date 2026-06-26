# Rollback Guide

## App Rollback

- Remove runtime backend config from the staging app environment.
- Confirm the app reports Local Preview fallback.

## Server Rollback

- Return `local_preview_fallback` from entitlement validation when validation is unavailable.
- Return `descriptor_unavailable` from playback descriptor when signing is unavailable.
- Keep audit records server-side for incident review.
- For P43A security controls, lower traffic by reducing ingress before disabling
  the staging process. Do not remove audit records during rollback.
- If rate limits are misconfigured, restore `HIGHFIVE_RATE_LIMIT_REQUESTS` and
  `HIGHFIVE_RATE_LIMIT_WINDOW_MS` to defaults and restart the backend.
- If privacy export/delete behavior fails, disable external exposure of identity
  routes first, then preserve local audit records for incident review.

## Expected User Impact

Local Preview fallback remains available. No live Cloudflare playback is claimed by this scaffold.
