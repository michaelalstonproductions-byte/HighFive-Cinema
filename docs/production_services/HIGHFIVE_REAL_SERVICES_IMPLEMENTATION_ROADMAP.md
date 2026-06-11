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

## #037.0A — Payments / Entitlements

- Purpose: Add StoreKit or entitlement provider after decision.
- Files likely touched: PaymentEntitlementService, Profile, playback entitlement gate.
- Services introduced: Payment/entitlement system.
- Tests/evidence: Restore, entitlement refresh, expired access, privacy review.
- Rollback plan: Disable paid gates and keep free local mode in Debug.
- User decisions required: StoreKit direct vs entitlement provider.

## #038.0A — Notifications

- Purpose: Add notification preferences and delivery only after communication/launch strategy.
- Files likely touched: NotificationService, Profile preferences, Connect/Launch triggers.
- Services introduced: Notification provider and OS permission flow.
- Tests/evidence: Permission denied, preference sync, no unexpected prompts.
- Rollback plan: Disable notification registration.
- User decisions required: Notification categories and consent copy.

## #039.0A — Analytics / Crash / Privacy Review

- Purpose: Add privacy-safe telemetry after policy approval.
- Files likely touched: AnalyticsService, app diagnostics, privacy docs.
- Services introduced: Crash or analytics provider.
- Tests/evidence: Opt-out, disabled state, crash signal, no sensitive payloads.
- Rollback plan: Disable telemetry adapter.
- User decisions required: Provider, event list, privacy policy.

## #040.0A — Production Release Candidate

- Purpose: Full QA, evidence, privacy, and TestFlight readiness.
- Files likely touched: release docs, QA scripts, final app configuration.
- Services introduced: None new; hardening only.
- Tests/evidence: Build, install, launch, integration smoke tests, privacy review, rollback.
- Rollback plan: Return to last evidence-locked staging build.
- User decisions required: Release scope and launch criteria.
