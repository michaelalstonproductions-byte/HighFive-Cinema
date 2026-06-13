# HighFive Real Services Implementation Roadmap

## #027.0B — Real Services Architecture Evidence Lock

- Purpose: Evidence-lock the architecture docs and verifier.
- Files likely touched: `docs/production_services/*`, verifier scripts.
- Services introduced: None.
- Tests/evidence: Doc verifier, safety scans, no app-code scan.
- Rollback plan: Revert docs/scripts only.
- User decisions required: Confirm docs-only evidence lock.

## #028.0A — Service Contract Scaffolding

- Purpose: Add service protocols and local adapter skeletons only.
- Files likely touched: new service protocol files, local adapter files, stores.
- Services introduced: None live; local contracts only.
- Tests/evidence: Build, source verifier, local adapter tests if available.
- Rollback plan: Disable new adapters and keep local `HFStreamingStore` behavior.
- User decisions required: Approve protocol names and module placement.

## #028.0B — Service Contract Evidence Lock

- Purpose: Verify contracts and local adapters.
- Files likely touched: scripts and reports only.
- Services introduced: None.
- Tests/evidence: Contract source verifier, build, safety scans.
- Rollback plan: Revert evidence scripts.
- User decisions required: Confirm contract completeness.

## #029.0A — Identity + Profile Local/Remote Readiness

- Purpose: Prepare identity/profile boundaries without committing provider credentials.
- Files likely touched: profile store, auth protocol, account placeholder UI if approved.
- Services introduced: Staging-ready AuthService interface only unless provider approved.
- Tests/evidence: Account disabled state, local fallback, privacy checklist.
- Rollback plan: Return Profile to local-only mode.
- User decisions required: Provider choice and account requirement for v1.

## #030.0A — Remote Movie Catalog Integration

- Purpose: Connect remote/staging movie catalog after provider choice.
- Files likely touched: MovieCatalogService adapter, catalog store, Home/Movie Detail.
- Services introduced: Catalog backend or CMS adapter.
- Tests/evidence: Local fallback, staging catalog smoke test, empty/error states.
- Rollback plan: Switch configuration back to local mock catalog.
- User decisions required: Catalog provider and ingestion process.

## #031.0A — Playback Source Integration

- Purpose: Connect real HLS/video source provider.
- Files likely touched: PlaybackService adapter, Movie Detail player path.
- Services introduced: Video hosting provider and playback source API.
- Tests/evidence: Staging HLS playback, entitlement denial, expired source fallback.
- Rollback plan: Player route falls back to placeholder.
- User decisions required: Video provider, DRM policy, entitlement rules.

## #032.0A — My List + Library Sync

- Purpose: Sync saved/progress state across devices.
- Files likely touched: LibraryService adapter, HFStreamingStore bridge, Library and Movie Detail.
- Services introduced: User-scoped library service.
- Tests/evidence: Save/unsave, progress sync, offline queue, conflict handling.
- Rollback plan: Local-only library mode.
- User decisions required: Account requirement and viewing-history retention.

## #033.0A — Offline Download Architecture

- Purpose: Design and implement real offline download policy carefully.
- Files likely touched: DownloadService, Downloads UI, playback/offline policy boundaries.
- Services introduced: Offline license or media availability service.
- Tests/evidence: Expiry, entitlement denial, storage failure states.
- Rollback plan: Local offline-state only.
- User decisions required: Offline rights, expiry rules, storage policy.

## #034.0A — Connect Communication Backend

- Purpose: Add curated update feed or messaging backend.
- Files likely touched: ConnectService, Connect Room UI, moderation status.
- Services introduced: Updates or communication service.
- Tests/evidence: Draft, submit, moderation pending, failure state.
- Rollback plan: Local update drafts only.
- User decisions required: Curated updates vs real messaging.

## #035.0A — Launch Campaign Backend

- Purpose: Store real campaign plans and launch milestones.
- Files likely touched: LaunchService, Launch Room UI.
- Services introduced: Campaign service.
- Tests/evidence: Milestone sync, campaign read/update, permission denial.
- Rollback plan: Local checklist mode.
- User decisions required: Campaign permissions and moderation flow.

## #036.0A — Export Package Backend

- Purpose: Store delivery package records and generated text summaries.
- Files likely touched: ExportPackageService, Export Room UI.
- Services introduced: Delivery package service.
- Tests/evidence: Generate summary, save package, stale summary handling.
- Rollback plan: Local generated summary only.
- User decisions required: Whether media delivery is in scope or text/package only.

## #037.0A — Provider Selection + Integration Plan

- Purpose: Lock candidate providers, integration order, ownership, risks, and rollback rules before live integrations.
- Preferred stack: Cloudflare Stream, Clerk, Supabase hybrid, RevenueCat + StoreKit, APNs, PostHog, and custom curated updates.
- Fallback stack: Mux, Auth0/custom, custom API, Stripe web where Apple rules allow, OneSignal later, Mixpanel/custom analytics, Stream/Sendbird only if real chat is approved.
- Files likely touched: production service docs and evidence scripts only.
- Services introduced: None.
- Tests/evidence: Docs verifier, protected scan, blocked implementation scan, no app-code scan.
- Rollback plan: Revert docs/scripts only.
- User decisions required: Confirm provider shortlist and decide primary vs fallback candidates.

## #038.0A — Account Provider Architecture

- Purpose: Design account identity boundaries for Clerk, Auth0, or custom auth without connecting a provider.
- Preferred stack: Clerk account provider with HighFive-owned user IDs and Supabase hybrid identity records.
- Fallback stack: Auth0 for enterprise identity needs, or custom auth only if HighFive accepts full security/support ownership.
- Files likely touched: AuthService docs, account architecture docs, privacy/security docs, data model docs, verifier scripts.
- Services introduced: None live; architecture only.
- Tests/evidence: Contract review, privacy checklist, no SDK/import/URL/secret scan.
- Rollback plan: Keep local profile mode and revert account architecture docs.
- User decisions required: Clerk vs Auth0 vs custom, account requirement for beta, Apple sign-in requirement, account deletion/export owner.

## #039.0A — Streaming Provider Integration

- Purpose: Prepare Cloudflare Stream or Mux playback-source integration behind HighFive-owned playback contracts.
- Files likely touched: PlaybackService docs/contracts first; app code only after provider approval.
- Services introduced: Staging video provider only when explicitly approved.
- Tests/evidence: HLS staging smoke test, source expiry handling, entitlement denial, local fallback.
- Rollback plan: Disable remote playback adapter and return to local player placeholder.
- User decisions required: Cloudflare Stream vs Mux, DRM policy, source URL expiry policy.

## #040.0A — Backend Service Layer

- Purpose: Establish Supabase, custom API, or hybrid backend boundaries for catalog, library, launch, delivery, and service health.
- Files likely touched: backend architecture docs, service layer contracts, environment configuration docs.
- Services introduced: None until staging provider and environment are approved.
- Tests/evidence: Adapter contract tests, no secret scan, environment-gating proof.
- Rollback plan: Keep local adapters as the default path.
- User decisions required: Supabase vs custom API vs hybrid, admin ownership, migration ownership.

## #041.0A — Authentication

- Purpose: Implement selected auth provider behind AuthService after #038 architecture approval.
- Files likely touched: AuthService adapter, Profile account state, onboarding/account gates if approved.
- Services introduced: Selected staging auth provider.
- Tests/evidence: Sign in/out, session restore, account deletion request path, local fallback, privacy review.
- Rollback plan: Disable remote auth adapter and return Profile to local-only mode.
- User decisions required: Login requirement, Apple sign-in requirement, creator/viewer account split.

## #042.0A — Payment Provider Integration

- Purpose: Lock RevenueCat + StoreKit preferred architecture, Stripe web fallback limits, entitlement records, validation policy, restore architecture, and service boundaries before payment implementation.
- Files likely touched: production service docs only.
- Services introduced: None.
- Tests/evidence: Required-term verification, protected scan, blocked implementation scan, docs credential assignment scan.
- Rollback plan: Revert docs only; local preview remains the default.
- User decisions required: RevenueCat + StoreKit implementation timing, product tiers, App Store product configuration, Apple rules review, backend validation owner.

## #042.0B — Payment Provider Architecture Evidence Lock

- Purpose: Evidence-lock the payment provider architecture and source scans.
- Files likely touched: verifier and report scripts only.
- Services introduced: None.
- Tests/evidence: Architecture source verifier, protected scan, blocked implementation scan, docs credential assignment scan.
- Rollback plan: Revert evidence scripts only.
- User decisions required: Confirm architecture completeness before live payment work.

## #043.0A — Cloud Library Sync

- Purpose: Sync saved titles, progress, and profile-scoped library state across devices.
- Files likely touched: LibraryService adapter, HFStreamingStore bridge, Library, Movie Detail.
- Services introduced: User-scoped library backend.
- Tests/evidence: Save/unsave, progress sync, conflict handling, offline queue, privacy review.
- Rollback plan: Switch configuration back to local-only library mode.
- User decisions required: Account requirement, viewing-history retention, cross-device sync scope.

## #044.0A — Real Downloads

- Purpose: Implement real offline media availability, storage, and license/entitlement policy.
- Files likely touched: DownloadService, Downloads UI, playback/offline policy boundaries.
- Services introduced: Offline availability and license service after provider approval.
- Tests/evidence: Expiry, entitlement denial, storage failure, deletion, airplane-mode checks.
- Rollback plan: Disable remote download adapter and return to local offline-state preview.
- User decisions required: Offline rights, expiry rules, storage limits, DRM/offline policy.

## #045.0A — Communication Backend

- Purpose: Connect Custom, Stream, or Sendbird communication backend behind ConnectService.
- Files likely touched: ConnectService adapter, Connect Room UI, moderation status.
- Services introduced: Selected communication provider in staging.
- Tests/evidence: Draft, send/submit, moderation pending, block/report path, provider outage fallback.
- Rollback plan: Return to local update drafts only.
- User decisions required: Custom vs Stream vs Sendbird, chat vs curated updates, moderation owner.

## #046.0A — Launch Campaign Backend

- Purpose: Store real campaign plans, launch milestones, and release calendar state.
- Files likely touched: LaunchService adapter, Launch Room UI.
- Services introduced: Campaign backend using selected backend service layer.
- Tests/evidence: Milestone sync, campaign read/update, permission denial, stale data handling.
- Rollback plan: Return to local checklist mode.
- User decisions required: Campaign permissions, approval flow, public/private campaign state.

## #047.0A — Delivery Backend

- Purpose: Store delivery package records and handoff status using selected backend/storage approach.
- Files likely touched: ExportPackageService adapter, Export Room UI.
- Services introduced: Delivery package backend.
- Tests/evidence: Save package, generate summary, stale summary handling, permission denial.
- Rollback plan: Return to local generated summary only.
- User decisions required: Text/package only vs media delivery, retention policy, handoff owners.

## #048.0A — Production Hardening

- Purpose: Harden security, privacy, observability, fallback behavior, and release configuration.
- Files likely touched: privacy docs, security checklist, environment configuration, QA scripts.
- Services introduced: APNs/OneSignal and PostHog/Mixpanel/custom analytics only if already approved.
- Tests/evidence: Privacy review, opt-out, notification permission denial, crash/analytics disabled mode, rollback drill.
- Rollback plan: Disable notification and analytics adapters; return to last evidence-locked staging build.
- User decisions required: APNs vs OneSignal, PostHog vs Mixpanel vs custom, privacy policy approval.

## #049.0A — Beta Readiness

- Purpose: Validate TestFlight readiness for the selected service stack.
- Files likely touched: release docs, QA scripts, beta checklist, known-issues docs.
- Services introduced: None new; readiness validation only.
- Tests/evidence: Full install/launch flow, staging service smoke test, privacy strings, support process.
- Rollback plan: Hold beta and return to previous evidence-locked build.
- User decisions required: Beta scope, tester cohort, support owner, known limitation acceptance.

## #050.0A — Production Launch Candidate

- Purpose: Final production launch candidate with selected providers, rollback plan, privacy approval, and evidence lock.
- Files likely touched: release docs, final QA scripts, production configuration docs.
- Services introduced: None new; final hardening and verification only.
- Tests/evidence: Full QA matrix, integration smoke tests, provider dashboard checks, privacy review, rollback proof.
- Rollback plan: Revert to last beta-ready evidence lock and disable production service flags.
- User decisions required: Launch scope, go/no-go approval, production monitoring owner.
