# HighFive Backend Runtime Configuration

## Purpose

HighFive now has a backend-capable runtime layer with local fallback. The app can read runtime configuration from environment variables, but it does not commit secrets and it does not make live backend requests in this phase.

## Environment Variables

Use placeholder values only in local notes and shell history. Do not commit real values.

```bash
HIGHFIVE_BACKEND_MODE="<local|configured|staging|unavailable>"
HIGHFIVE_BACKEND_BASE_URL="<custom-api-base-url-placeholder>"
HIGHFIVE_SUPABASE_PROJECT_URL="<supabase-project-url-placeholder>"
HIGHFIVE_SUPABASE_ANON_KEY="<supabase-anon-key-placeholder>"
```

## Simulator Runtime Example

Set runtime variables in your shell or Xcode scheme for a local test run. Keep real values out of git.

```bash
HIGHFIVE_BACKEND_MODE="configured" \
HIGHFIVE_BACKEND_BASE_URL="<custom-api-base-url-placeholder>" \
xcrun simctl launch booted com.higherkey.HighFiveCinemaClean.HighFive --hf-skip-onboarding --hf-start-home
```

## Current Behavior

- Missing configuration: app displays Local Mode and Backend Not Connected Yet.
- Complete runtime configuration: app displays Backend Configured or Staging Ready.
- Partial runtime configuration: app displays Missing Credentials.
- Unavailable runtime mode: app displays Backend Not Connected Yet.

## Still Not Connected

- No live auth.
- No live cloud sync.
- No live media downloads.
- No live payment provider.
- No live social posting.
- No live VOD publishing.
- No provider SDKs.
- No production backend verification.

## Secret Safety

- Do not create committed `.env` files.
- Do not commit real backend URLs, keys, tokens, client secrets, passwords, or service-role values.
- Keep provider credentials in local runtime configuration or a secure CI/runtime store.
- Rotate any credential that is accidentally copied into git, logs, screenshots, or issue trackers.
