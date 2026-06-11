# HighFive Phase 27A Readiness Report

## Baseline Checkpoint

Expected baseline: `phase-26-0b-functional-app-core-evidence-lock`.

Phase 26.0B evidence-locked the cinematic onboarding and functional local-first app core. Phase 27.0A does not change app code.

## Files Created

- `docs/production_services/HIGHFIVE_REAL_SERVICES_ARCHITECTURE.md`
- `docs/production_services/HIGHFIVE_SERVICE_PROVIDER_DECISION_MATRIX.md`
- `docs/production_services/HIGHFIVE_PRODUCTION_DATA_MODEL_MAP.md`
- `docs/production_services/HIGHFIVE_API_CONTRACTS_AND_ADAPTER_PLAN.md`
- `docs/production_services/HIGHFIVE_SECURITY_PRIVACY_ENTITLEMENTS_CHECKLIST.md`
- `docs/production_services/HIGHFIVE_REAL_SERVICES_IMPLEMENTATION_ROADMAP.md`
- `docs/production_services/HIGHFIVE_PHASE_27A_READINESS_REPORT.md`
- `scripts/verify_real_services_architecture_plan.sh`

## Repo Inspection Summary

The app currently uses local mock data and local state for the functional core:

- `HFMockData` supplies movie, profile, creator, and product data.
- `Movie` is the current app-facing movie model.
- `HFStreamingStore` persists saved, downloaded, and recent-search state locally.
- `HFStreamingRootView` owns the current SwiftUI shell, onboarding completion state, and QA launch routing.
- `MovieDetailView` owns the Watch Now/player path, saved toggle, and download toggle.
- `MyListView` and `DownloadsView` read the shared local store.
- `ProfileView` contains Connect local updates, Launch checklist, Export delivery summary, Presentation Mode, and Developer/QA proof routes.

Protected systems remain isolated and should not be used as service integration points without explicit scope.

## Production Services Covered

This plan covers:

- Identity / Accounts
- User Profile
- Movie Catalog / CMS
- Video Streaming / Hosting
- Playback Entitlements
- Offline Downloads
- My List / Library Sync
- Connect Updates / Communication
- Launch Campaigns
- Creator Studio Projects
- Export / Delivery Packages
- Payments / Subscriptions
- Notifications
- Analytics / Crash Reporting
- Admin / Moderation
- Security / Privacy
- Service Protocol and Provider Adapter boundaries

## Provider Decision Status

No provider is selected yet. Candidate categories are documented for identity, backend/database, video hosting, storage, communication, payments, and analytics/crash.

Do not add real SDKs or production services until provider choices and secrets strategy are confirmed.

## Security Risks

- Account and viewing history data are sensitive.
- Playback source references must be short-lived and entitlement-aware.
- Connect text requires moderation before public visibility.
- Creator projects and delivery packages may contain confidential material.
- Payment entitlement state must be validated server-side.
- Notifications and analytics require privacy review before implementation.

## Integration Blockers

- Provider choices are not confirmed.
- Secrets strategy is not approved.
- Production API contracts are not implemented.
- Staging environment is not defined.
- Privacy policy and permission strategy are not finalized.
- Real streaming/download rights are not documented.

## Recommended Next Phase

Next recommended phase:

`#027.0B — Real Services Architecture Evidence Lock`

Then:

`#028.0A — Service Contract Scaffolding`

## What Not To Do Next

- Do not add provider SDKs.
- Do not add real accounts.
- Do not add payments.
- Do not add live messaging.
- Do not add production video hosting.
- Do not add analytics.
- Do not edit protected systems.
- Do not commit credentials or provider keys.

## Final Recommendation

Evidence-lock this architecture plan first. Then create service protocol scaffolding with local adapters only, preserving the current local-first app behavior while preparing clean boundaries for future production providers.
