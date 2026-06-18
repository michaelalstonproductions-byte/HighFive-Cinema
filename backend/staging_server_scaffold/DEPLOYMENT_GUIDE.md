# Staging Deployment Guide

This scaffold is prepared for a future staging deployment. No deployment is run in #065.0A.

## Implemented Paths

- `POST /entitlements/validate`
- `POST /playback/descriptor`

## Before Deployment

- Replace placeholder StoreKit and RevenueCat provider classes with server-owned validation.
- Replace placeholder Cloudflare signer with server-owned signing.
- Configure server-only credentials in the staging secret store.
- Confirm product mapping in `src/productMapping.ts`.
- Confirm audit sink behavior in `src/audit.ts`.
- Confirm the app runtime config is supplied outside the repo.

## Intentionally Not Run

- No package installation.
- No lockfile generation.
- No hosting deployment.
- No provider SDK integration in the iOS app.

## Runtime Result Without Config

The iOS app remains on Local Preview fallback.
