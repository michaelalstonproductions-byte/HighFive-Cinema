# Instagram Connect Backend Plan

## Current state

Instagram Connect should remain `Not Connected Yet` until OAuth, backend callback, token storage, and review requirements are approved.

## Product flow

```text
Creator Studio → Social Media Kit → Instagram Connect → Provider-ready status
```

## Backend flow later

```text
App requests connection status
Backend creates OAuth URL
User completes Meta authorization
Backend callback stores provider identity/token securely
App sees Instagram Connected status
Creator can preview post plan
Publishing remains blocked until explicit phase approval
```

## Required backend records

- social_platform_status
- provider_identities
- provider_tokens, server-side only, not in client schema
- social_posts
- audit_events

## Forbidden client behavior now

- Sign in with Instagram
- Authorize Meta
- Store OAuth token in app code
- Post to Instagram
- Upload media
- Connect account CTA that implies live auth

## Safe UI labels now

- Instagram — Not Connected Yet
- Provider-ready
- Awaiting backend provider
- Local Draft
- No live publishing
