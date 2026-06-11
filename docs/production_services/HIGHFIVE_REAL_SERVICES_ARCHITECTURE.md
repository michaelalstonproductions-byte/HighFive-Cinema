# HighFive Real Services Architecture

## 1. Executive Summary

HighFive currently has a local-first functional foundation: cinematic onboarding, movie routing, a Watch Now player path, saved and downloaded local state, local Connect updates, a local Launch checklist, a delivery summary, and Profile/Demo proof surfaces.

Production service work now needs architecture, provider decisions, API contracts, security rules, privacy review, and staged integration. The screens should not call provider SDKs or raw service clients directly. HighFive should introduce app-owned stores, service protocols, and provider adapters so local simulator behavior remains stable while staging and production services can be added safely.

This phase does not add live services, production SDKs, accounts, payment code, provider keys, or secrets. It locks the service plan before implementation begins.

## 2. Current App Foundation

| Area | Current local behavior | Future production need |
| --- | --- | --- |
| Onboarding | Cinematic intro, motion training, controls training, completion to Home | Account-aware first-run state, privacy consent, optional profile setup |
| Home and Movie Detail | Home routes toward Movie Detail through local movie data | Remote catalog, personalized rails, availability rules |
| Player path | Watch Now opens a controlled player route or honest placeholder | Real playback sources, entitlements, HLS, offline rules |
| My List | Saved state persists locally through `HFStreamingStore` | Account-scoped library sync |
| Downloads | Downloaded/offline state persists locally | Real offline media license and storage policy |
| Connect | Local update draft/list behavior | Curated updates, moderation, delivery status |
| Launch | Local release checklist/progress | Campaign records, calendar state, approvals |
| Export | Local delivery text summary and optional share summary | Delivery package records and external handoff workflow |
| Profile/Demo | Functional Core proof and presentation proof | Internal QA, admin eligibility, environment diagnostics |

## 3. Production Service Domains

| Domain | Purpose | Current local placeholder | Production service needed | Sensitive data | Risk | First phase |
| --- | --- | --- | --- | --- | --- | --- |
| Identity / Accounts | Identify users and sessions | No real login | Auth provider and account service | Account identifiers, email if collected | High | Phase 28A |
| User Profile | Store profile and preferences | Local profile mock data | Profile service | Display name, preferences | Medium | Phase 28A |
| Movie Catalog / CMS | Serve movie metadata and rails | `HFMockData` | CMS/catalog API | Low unless personalized | Medium | Phase 29A |
| Video Streaming / Hosting | Provide playable media | Player route or placeholder | Video hosting and playback source service | Viewing access, source URLs | High | Phase 30A |
| Playback Entitlements | Decide access | None | Entitlement service | Purchase/subscription state | High | Phase 30A |
| Offline Downloads | Manage offline media rights | Local downloaded flag | Download service and offline policy | Viewing history, license state | High | Phase 32A |
| My List / Library Sync | Sync saved/progress state | Local saved/downloaded IDs | Library sync service | Viewing history, saved titles | High | Phase 31A |
| Connect Updates / Communication | Publish creator/audience updates | Local draft/list | Updates service and moderation | User text, creator content | High | Phase 33A |
| Launch Campaigns | Manage release plans | Local checklist | Campaign service | Campaign plans, dates | Medium | Phase 34A |
| Creator Studio Projects | Store creator project data | Static room surfaces | Project service | Project metadata, assets | High | Phase 34A |
| Export / Delivery Packages | Track delivery summaries | Local text summary | Delivery package service | Project/package data | High | Phase 35A |
| Payments / Subscriptions | Monetize access | None | StoreKit or entitlement bridge | Payment entitlement state | High | Phase 36A |
| Notifications | Notify opted-in users | None | Notification service | Device notification preference | High | Phase 37A |
| Analytics / Crash Reporting | Improve stability and product | None | Privacy-reviewed telemetry | Usage events, crash context | High | Phase 38A |
| Admin / Moderation | Review catalog, updates, users | None | Admin console and moderation queue | Moderation history | High | Phase 33A |
| Security / Privacy | Protect data and compliance | Safety docs/verifiers | Security review, privacy policy, audit | All user and creator data | High | Phase 27B onward |

## 4. Service Boundaries

Recommended layer order:

```text
UI Screen
Feature ViewModel / Store
Service Protocol
Provider Adapter
Remote API / SDK
```

Rules:

- UI never owns secrets.
- UI never calls raw provider SDKs directly.
- All real services sit behind HighFive-owned protocols and adapters.
- Mock and local adapters remain available for simulator demos and failure-mode tests.
- Production adapters are gated behind configuration and environment selection.
- Stores map provider data into app models before it reaches screens.
- Error states must be explicit, user-safe, and testable.

## 5. Protected System Policy

The following areas remain isolated unless a later phase explicitly scopes them:

- `HighFive/App/Depth/*`
- `HighFive/App/Motion/*`
- `HighFive/App/Playback/*`
- `HighFive/App/Layer4/*`
- `HighFive/App/Rendering/*`
- `HighFive/App/Creator/*`
- `HighFive/App/Store/*`
- `HighFive/App/UI/*`
- `Assets.xcassets`
- `HighFive.xcodeproj/project.pbxproj`
- Info, privacy, entitlement, and signing files

Production services should integrate through new app-facing contracts first. Protected playback, depth, motion, rendering, creator, and store systems should only be touched when a phase explicitly authorizes the work and includes rollback proof.

## 6. Recommended Integration Order

| Phase | Scope | Notes |
| --- | --- | --- |
| Phase 27B | Service contracts + local/remote adapter skeletons | Protocols only, no live providers |
| Phase 28A | Identity + profile sync | Provider choice required |
| Phase 29A | Movie catalog remote sync | Staging catalog first |
| Phase 30A | Video hosting + playback source integration | HLS and entitlement rules |
| Phase 31A | Library/My List sync | Account-scoped saved/progress data |
| Phase 32A | Offline downloads architecture | Do not rush media storage and rights |
| Phase 33A | Connect communication backend | Moderation and safety first |
| Phase 34A | Launch campaign backend | Campaign records and approvals |
| Phase 35A | Export/delivery backend | Text/package records before media engines |
| Phase 36A | Payments/subscriptions | StoreKit or entitlement provider after decision |
| Phase 37A | Notifications | Only after communication strategy |
| Phase 38A | Analytics/crash/privacy review | Privacy-safe telemetry only |

## 7. Known Limitations

- No real backend exists yet.
- No provider has been selected.
- No provider SDKs are added.
- No secrets, provider keys, or credentials are committed.
- No real production streaming is connected unless separately proven in a later phase.
- Downloads are currently local state, not real offline media files.
- Connect updates are local-only, not backend-backed messaging.
- Export is a text/package summary path, not a real media render or delivery engine.
