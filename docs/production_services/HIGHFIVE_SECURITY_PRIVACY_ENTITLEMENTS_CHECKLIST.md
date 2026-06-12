# HighFive Security Privacy Entitlements Checklist

## 1. Secrets Policy

- No secrets in the repo.
- Never commit tokens, provider keys, signing material, session credentials, or service credentials.
- Never paste provider keys into docs, Swift files, shell scripts, screenshots, or reports.
- Use secure build configuration, managed environment values, or a secure release process.
- Rotate any credential that is exposed during development.
- Keep local mock adapters available so production credentials are not needed for simulator demos.

## 2. Privacy Domains

| Domain | Data involved | Required review |
| --- | --- | --- |
| Account info | User identifier, email if collected, account status | Account creation, deletion, export |
| Viewing history | Movie progress, last watched, library state | Consent, retention, access controls |
| Saved list | User/movie saved state | Account scope and deletion rules |
| Downloads | Offline availability and license state | Storage, expiry, entitlement review |
| Communication | Connect updates, prompts, moderation state | Moderation, reporting, retention |
| Creator projects | Project metadata, packages, launch plans | Confidentiality and permissions |
| Payments | Entitlement state, product identifiers | Store policy and validation |
| Analytics | Event and crash context | Consent, minimization, opt-out |
| Notifications | Device permission and category preferences | OS permission and preference sync |
| Uploaded media if later added | Video, images, creator assets | Strong review before implementation |

## 3. Apple / iOS Privacy Requirements

- Review the privacy manifest before any SDK, analytics, notification, or account feature is added.
- App tracking transparency is required if tracking behavior is introduced.
- Push notification permission is required only when notifications are implemented.
- Camera, microphone, and Photos permissions are added only when real features require them.
- Sign in with Apple may be required if third-party account sign-in is offered.
- StoreKit entitlement validation is required if payments/subscriptions are added directly.
- Offline media requires clear storage, expiry, and entitlement behavior.

## 4. Account Provider Requirements

- Clerk is the preferred account provider for planning; Auth0 and custom auth are fallbacks.
- No account provider SDK, URL, key, token, or client configuration is committed during #038.
- Account provider identities must map into HighFive-owned user IDs.
- Account deletion and account data export paths must be designed before #041 authentication implementation.
- Local profile mode must remain available for simulator demos and rollback.
- Sign in with Apple requirements must be reviewed before third-party auth ships.
- Raw credentials, refresh tokens, passwords, service-role credentials, and provider secrets must never be stored in app UI state.

## 5. Backend Security

- Use authorization checks for every user-scoped resource.
- Use row-level or equivalent resource-level access rules.
- Use signed media access for protected video and delivery assets.
- Enforce entitlement checks before playback and offline access.
- Moderate user-generated text before broad audience visibility.
- Keep audit logs for account, moderation, entitlement, and admin operations.
- Add rate limits and abuse prevention before public write endpoints.
- Keep admin tooling separate from consumer UI.

## 6. Production Readiness Gates

Before adding each live system:

- Provider chosen.
- Data model approved.
- Privacy impact reviewed.
- API contract approved.
- Local fallback exists.
- Staging environment exists.
- No secrets committed.
- Tests pass.
- Rollback plan exists.
- Evidence lock planned for the phase.
