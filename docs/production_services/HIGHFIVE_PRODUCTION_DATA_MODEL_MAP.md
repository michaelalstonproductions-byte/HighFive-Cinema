# HighFive Production Data Model Map

This document maps current local app concepts to future production models. It is not implementation code.

## User

- Purpose: Account owner for viewer or creator capabilities.
- Current local source: None.
- Production fields: `id`, `accountStatus`, `emailHash`, `createdAt`, `updatedAt`, `deletedAt`.
- Relationships: Has AccountProviderIdentities, AuthSessions, Profile, LibraryItems, NotificationPreferences, SubscriptionEntitlements.
- Privacy level: High.
- Sync rules: Server authoritative, local cache only after login.
- Offline behavior: Read cached identity state; block sensitive writes while offline.
- Needed API endpoints: create session, get current user, delete account.
- Future owner service: AuthService.

## AccountProviderIdentity

- Purpose: Map Clerk, Auth0, or custom provider identity to a HighFive-owned User ID.
- Current local source: None.
- Production fields: `id`, `userId`, `provider`, `providerSubjectHash`, `emailHash`, `createdAt`, `updatedAt`, `revokedAt`.
- Relationships: Belongs to User.
- Privacy level: High.
- Sync rules: Server authoritative only.
- Offline behavior: Cached signed-in status may be displayed, but identity mapping changes require server access.
- Needed API endpoints: link provider identity, refresh provider identity, revoke provider identity.
- Future owner service: AuthService.

## AuthSession

- Purpose: Represent app-safe account session state without storing raw provider credentials.
- Current local source: Local profile preview state only.
- Production fields: `id`, `userId`, `sessionStatus`, `expiresAt`, `lastValidatedAt`, `createdAt`.
- Relationships: Belongs to User.
- Privacy level: High.
- Sync rules: Provider and server authoritative.
- Offline behavior: Read cached non-sensitive status; refresh before sensitive writes.
- Needed API endpoints: current session, refresh session, sign out.
- Future owner service: AuthService.

## AccountDeletionRequest

- Purpose: Track account deletion requests required before remote account launch.
- Current local source: None.
- Production fields: `id`, `userId`, `status`, `requestedAt`, `completedAt`, `supportReference`.
- Relationships: Belongs to User.
- Privacy level: High.
- Sync rules: Server authoritative.
- Offline behavior: Cannot create or complete while offline.
- Needed API endpoints: request deletion, get deletion status.
- Future owner service: AuthService.

## Profile

- Purpose: Display identity and app preferences.
- Current local source: `HFMockData` profile data.
- Production fields: `userId`, `displayName`, `avatarRef`, `profileType`, `preferences`, `updatedAt`.
- Relationships: Belongs to User.
- Privacy level: Medium.
- Sync rules: Server authoritative with local optimistic edits.
- Offline behavior: Show cached profile; queue profile changes only after policy approval.
- Needed API endpoints: get profile, update profile.
- Future owner service: UserProfileService.

## Movie

- Purpose: Catalog item shown on Home, Search, Library, Downloads, and Movie Detail.
- Current local source: `HFMockData.movies`, `Movie`.
- Production fields: `id`, `title`, `subtitle`, `synopsis`, `genres`, `duration`, `rating`, `posterAsset`, `backdropAsset`, `isOriginal`, `releaseStatus`, `createdAt`, `updatedAt`.
- Relationships: Has MovieAssets and PlaybackSources.
- Privacy level: Low unless personalized.
- Sync rules: Remote catalog is authoritative; local cache for display.
- Offline behavior: Cached metadata remains available.
- Needed API endpoints: list catalog, get movie, search movies, get rails.
- Future owner service: MovieCatalogService.

## MovieAsset

- Purpose: Poster, backdrop, stills, trailers, and metadata assets.
- Current local source: Asset names referenced by Movie and mock data.
- Production fields: `id`, `movieId`, `kind`, `storageRef`, `altText`, `width`, `height`, `updatedAt`.
- Relationships: Belongs to Movie.
- Privacy level: Low for public assets, high for unreleased assets.
- Sync rules: Remote authoritative.
- Offline behavior: Cache thumbnails and metadata where allowed.
- Needed API endpoints: list assets for movie.
- Future owner service: MovieCatalogService.

## PlaybackSource

- Purpose: Playable media source for Watch Now.
- Current local source: Player placeholder route.
- Production fields: `movieId`, `hlsSourceRef`, `drmPolicy`, `thumbnailRef`, `duration`, `provider`, `entitlementRequired`, `offlineAllowed`.
- Relationships: Belongs to Movie and requires entitlement rules.
- Privacy level: High.
- Sync rules: Short-lived source references from server.
- Offline behavior: Requires DownloadService policy and license state.
- Needed API endpoints: request playback source, refresh playback source.
- Future owner service: PlaybackService.

## LibraryItem

- Purpose: Saved/progress/downloaded state for a user and movie.
- Current local source: `HFStreamingStore` saved and downloaded identifiers.
- Production fields: `id`, `userId`, `movieId`, `saved`, `favorite`, `watchProgress`, `continueWatchingEligible`, `lastWatchedAt`, `localDownloadState`, `syncState`, `version`, `updatedAt`, `deletedAt`.
- Relationships: Joins User and Movie; references MovieCatalogService catalog identity and PaymentEntitlementService access context.
- Privacy level: High.
- Sync rules: User-scoped server authoritative with local optimistic updates.
- Offline behavior: Queue save, unsave, favorite, progress, and continue watching metadata changes and reconcile later.
- Needed API endpoints: list library, update saved state, update favorite state, update progress, fetch continue watching, resolve conflict.
- Future owner service: LibraryService.

## CloudLibrarySyncMutation

- Purpose: Metadata-only offline queue item for library sync.
- Current local source: None.
- Production fields: `id`, `userId`, `movieId`, `mutationType`, `payloadClass`, `baseVersion`, `createdAt`, `retryAfter`, `attemptCount`, `syncState`.
- Relationships: User, LibraryItem, Movie.
- Privacy level: High.
- Sync rules: Replayed only through LibraryService and BackendServiceLayer after AuthService validates account state.
- Offline behavior: Local queue only; no media files, file storage provider, backend URLs, credentials, or raw provider payloads.
- Needed API endpoints: push mutation, pull changes, resolve conflict.
- Future owner service: LibraryService and CloudLibraryProviderAdapter.

## OfflineAsset

- Purpose: Real offline media availability and license state.
- Current local source: Local downloaded flag only.
- Production fields: `userId`, `movieId`, `assetId`, `licenseState`, `expiresAt`, `sizeClass`, `lastVerifiedAt`.
- Relationships: User, Movie, PlaybackSource.
- Privacy level: High.
- Sync rules: Server validates entitlement and offline policy.
- Offline behavior: Play only when license state allows.
- Needed API endpoints: request offline license, validate offline asset, remove offline asset.
- Future owner service: DownloadService.

## CreatorProject

- Purpose: Creator-side project record.
- Current local source: Static Creator Studio room surfaces.
- Production fields: `id`, `ownerId`, `title`, `status`, `summary`, `createdAt`, `updatedAt`.
- Relationships: Has CreatorPackages, LaunchCampaigns, ExportPackages.
- Privacy level: High.
- Sync rules: Server authoritative with draft support.
- Offline behavior: Local drafts only after conflict policy.
- Needed API endpoints: list projects, get project, create project, update project.
- Future owner service: CreatorProjectService.

## CreatorPackage

- Purpose: Pitch, media kit, package prep, and launch prep data.
- Current local source: Static Creator Studio copy.
- Production fields: `id`, `projectId`, `packageType`, `headline`, `materials`, `status`, `updatedAt`.
- Relationships: Belongs to CreatorProject.
- Privacy level: High.
- Sync rules: Server authoritative.
- Offline behavior: Cached read-only package summary unless drafts are approved.
- Needed API endpoints: get package, update package.
- Future owner service: CreatorProjectService.

## ConnectUpdate

- Purpose: Creator/audience update record.
- Current local source: Local Audience Updates draft/list.
- Production fields: `id`, `creatorId`, `projectId`, `movieId`, `body`, `status`, `moderationState`, `createdAt`.
- Relationships: User/Profile, Movie or CreatorProject.
- Privacy level: High.
- Sync rules: Draft local, submitted state server authoritative after moderation.
- Offline behavior: Keep drafts local; submit only online.
- Needed API endpoints: list updates, create draft, submit update, moderation status.
- Future owner service: ConnectService.

## AudiencePrompt

- Purpose: Structured prompt for public momentum or premiere conversation.
- Current local source: Static Connect and Launch room copy.
- Production fields: `id`, `projectId`, `movieId`, `prompt`, `status`, `createdAt`, `updatedAt`.
- Relationships: ConnectUpdate, LaunchCampaign.
- Privacy level: Medium.
- Sync rules: Server authoritative once connected.
- Offline behavior: Local drafts allowed.
- Needed API endpoints: list prompts, update prompt.
- Future owner service: ConnectService.

## LaunchCampaign

- Purpose: Release campaign plan.
- Current local source: Local Release Checklist.
- Production fields: `id`, `projectId`, `movieId`, `headline`, `releaseDate`, `status`, `ownerId`, `updatedAt`.
- Relationships: Has LaunchMilestones and AudiencePrompts.
- Privacy level: High.
- Sync rules: Server authoritative with local checklist cache.
- Offline behavior: Display cached plan; queue local draft changes only after policy.
- Needed API endpoints: get campaign, update campaign, list campaigns.
- Future owner service: LaunchService.

## LaunchMilestone

- Purpose: Checklist/progress item for launch readiness.
- Current local source: Local Release Checklist toggle state.
- Production fields: `id`, `campaignId`, `title`, `completed`, `completedAt`, `ownerId`, `updatedAt`.
- Relationships: Belongs to LaunchCampaign.
- Privacy level: Medium.
- Sync rules: Server authoritative with optimistic local toggles.
- Offline behavior: Queue toggle changes.
- Needed API endpoints: list milestones, update milestone.
- Future owner service: LaunchService.

## ExportPackage

- Purpose: Delivery package record for festival/platform handoff.
- Current local source: Generate Delivery Summary text.
- Production fields: `id`, `projectId`, `movieId`, `summary`, `materials`, `checklist`, `status`, `updatedAt`.
- Relationships: CreatorProject, Movie, DeliverySummary.
- Privacy level: High.
- Sync rules: Server authoritative.
- Offline behavior: Cached read-only summary; local drafts require conflict rules.
- Needed API endpoints: get package, generate package summary, update package.
- Future owner service: ExportPackageService.

## DeliverySummary

- Purpose: Text summary generated from a delivery package.
- Current local source: Local generated summary and optional Share Summary.
- Production fields: `id`, `exportPackageId`, `generatedText`, `generatedAt`, `createdBy`, `version`.
- Relationships: Belongs to ExportPackage.
- Privacy level: High.
- Sync rules: Generated server-side or locally with stored version metadata.
- Offline behavior: Show cached summary and mark stale if source changes.
- Needed API endpoints: generate summary, list summaries, get summary.
- Future owner service: ExportPackageService.

## SubscriptionEntitlement

- Purpose: Access rights for premium catalog and playback.
- Current local source: None.
- Production fields: `id`, `userId`, `entitlementKey`, `entitlementState`, `source`, `startsAt`, `expiresAt`, `lastValidatedAt`, `validationStatus`, `revokedAt`, `environment`, `updatedAt`.
- Relationships: User, EntitlementRecord, PlaybackSource, OfflineAsset.
- Privacy level: High.
- Sync rules: Server authoritative after payment validation.
- Offline behavior: Cached entitlement with expiry.
- Needed API endpoints: get entitlements, refresh entitlement, validate server entitlements.
- Future owner service: PaymentEntitlementService.

## EntitlementRecord

- Purpose: Server-authoritative access record created after payment provider validation.
- Current local source: None.
- Production fields: `id`, `userId`, `entitlementKey`, `source`, `state`, `startsAt`, `expiresAt`, `lastValidatedAt`, `validationStatus`, `revokedAt`, `refundReference`, `environment`, `updatedAt`.
- Relationships: User, SubscriptionEntitlement, LibraryItem, PlaybackSource, OfflineAsset.
- Privacy level: High.
- Sync rules: BackendServiceLayer is authoritative; device state is validation-required until server validation succeeds.
- Offline behavior: Cached access can be used only within approved expiry/grace policy; refund, revocation, or expired state denies production paid access.
- Needed API endpoints: list entitlement records, validate entitlement, handle refund/revocation, refresh expiry.
- Future owner service: PaymentEntitlementService and BackendServiceLayer.

## NotificationPreference

- Purpose: User opt-in state and notification categories.
- Current local source: None.
- Production fields: `userId`, `category`, `enabled`, `deviceState`, `updatedAt`.
- Relationships: User.
- Privacy level: High.
- Sync rules: Server authoritative after device permission state is known.
- Offline behavior: Cache preference; permission changes require OS callback.
- Needed API endpoints: get preferences, update preference.
- Future owner service: NotificationService.

## AuditEvent

- Purpose: Security, moderation, and support audit trail.
- Current local source: Evidence scripts and local reports only.
- Production fields: `id`, `actorId`, `action`, `resourceType`, `resourceId`, `createdAt`, `metadataClass`.
- Relationships: User/Profile, moderated resources.
- Privacy level: High.
- Sync rules: Server append-only.
- Offline behavior: Do not queue sensitive audit data on device without review.
- Needed API endpoints: internal admin read only.
- Future owner service: Admin/Moderation service.
