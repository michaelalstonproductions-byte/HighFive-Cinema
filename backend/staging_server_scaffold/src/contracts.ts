export type EntitlementStatus =
  | "entitlement_approved"
  | "entitlement_denied"
  | "entitlement_pending";

export type AccessDecision = EntitlementStatus | "local_preview_fallback";

export type PlaybackDescriptorStatus =
  | "descriptor_ready"
  | "descriptor_unavailable"
  | "descriptor_expired"
  | "descriptor_refresh_required"
  | "local_preview_fallback";

export type JsonObject = Record<string, unknown>;

export type EntitlementValidationRequest = {
  user_id: string | null;
  anonymous_session_id: string | null;
  movie_id: string;
  storekit_product_id: string;
  entitlement_context: JsonObject;
  playback_provider: string;
  device_context: JsonObject;
};

export type EntitlementValidationResponse = {
  entitlement_status: EntitlementStatus;
  access_decision: AccessDecision;
  denial_reason: string | null;
  audit_id: string;
  expires_at: string | null;
  refresh_after: string | null;
};

export type PlaybackDescriptorRequest = {
  user_id: string | null;
  anonymous_session_id: string | null;
  movie_id: string;
  storekit_product_id: string;
  entitlement_context: JsonObject;
  playback_provider: string;
  device_context: JsonObject;
  audit_id: string;
};

export type PlaybackDescriptorResponse = {
  playback_descriptor_status: PlaybackDescriptorStatus;
  playback_url_or_token_reference: string | null;
  expires_at: string | null;
  refresh_after: string | null;
  denial_reason: string | null;
  audit_id: string;
  playback_format?: string | null;
  playback_source?: string | null;
  processing_job_id?: string | null;
  hls_master_object_key?: string | null;
  bitrate_variants?: JsonObject[];
  audio_tracks?: JsonObject[];
  caption_tracks?: JsonObject[];
  resume_policy?: string | null;
  next_episode?: JsonObject | null;
  player_controls?: JsonObject;
};

export const entitlementValidationPath = "/entitlements/validate";
export const playbackDescriptorPath = "/playback/descriptor";
export const playbackHLSPath = "/v1/playback/hls/";
export const readinessPath = "/ready";
export const openAPIPath = "/openapi.json";
export const catalogPath = "/v1/catalog";
export const catalogSyncPath = "/v1/catalog/sync";
export const catalogDeltaPath = "/v1/catalog/delta";
export const contentDetailPath = "/v1/content/";
export const creatorDetailPath = "/v1/creators/";
export const collectionDetailPath = "/v1/collections/";
export const discoveryQueryPath = "/v1/discovery/query";
export const aiDiscoveryHomePath = "/v2/discovery/home";
export const aiDiscoverySearchPath = "/v2/discovery/search";
export const aiDiscoveryMoodPath = "/v2/discovery/mood";
export const socialWatchSummaryPath = "/v2/social-watch/summary";
export const socialWatchFriendsPath = "/v2/social-watch/friends";
export const socialWatchSharedLibraryPath = "/v2/social-watch/shared-library";
export const socialWatchPartiesPath = "/v2/social-watch/parties";
export const socialWatchPartyDetailPath = "/v2/social-watch/parties/";
export const socialWatchInviteDetailPath = "/v2/social-watch/invites/";
export const creatorEconomyDashboardPath = "/v2/creator-economy/dashboard";
export const creatorEconomyPayoutsPath = "/v2/creator-economy/payouts";
export const creatorEconomyRevenueSharesPath = "/v2/creator-economy/revenue-shares";
export const creatorEconomyTipsPath = "/v2/creator-economy/tips";
export const creatorEconomyMembershipsPath = "/v2/creator-economy/memberships";
export const creatorEconomyPaidCollectionsPath = "/v2/creator-economy/paid-collections";
export const creatorEconomyPaidPremieresPath = "/v2/creator-economy/paid-premieres";
export const creatorAssistantSummaryPath = "/v2/creator-assistant/summary";
export const creatorAssistantMetadataPath = "/v2/creator-assistant/metadata";
export const creatorAssistantPosterPath = "/v2/creator-assistant/poster";
export const creatorAssistantTrailerPath = "/v2/creator-assistant/trailer";
export const creatorAssistantPublishingPath = "/v2/creator-assistant/publishing";
export const creatorAssistantSEOPath = "/v2/creator-assistant/seo";
export const creatorAssistantRightsPath = "/v2/creator-assistant/rights";
export const studioCollaborationSummaryPath = "/v2/studio-collaboration/summary";
export const studioCollaborationCompaniesPath = "/v2/studio-collaboration/companies";
export const studioCollaborationWorkspacesPath = "/v2/studio-collaboration/workspaces";
export const studioCollaborationProjectsPath = "/v2/studio-collaboration/projects";
export const studioCollaborationProjectDetailPath = "/v2/studio-collaboration/projects/";
export const livePremiereSummaryPath = "/v2/live-premieres/summary";
export const livePremiereEventsPath = "/v2/live-premieres/events";
export const livePremiereEventDetailPath = "/v2/live-premieres/events/";
export const deviceExpansionSummaryPath = "/v2/device-expansion/summary";
export const deviceExpansionProfilesPath = "/v2/device-expansion/profiles";
export const deviceExpansionProfileDetailPath = "/v2/device-expansion/profiles/";
export const deviceExpansionAirPlaySessionsPath = "/v2/device-expansion/airplay/sessions";
export const deviceExpansionHandoffPath = "/v2/device-expansion/handoff";
export const enterpriseStudioSummaryPath = "/v2/enterprise-studio/summary";
export const enterpriseStudioAnalyticsPath = "/v2/enterprise-studio/analytics";
export const enterpriseStudioBulkPublishingPath = "/v2/enterprise-studio/bulk-publishing";
export const enterpriseStudioRightsReportPath = "/v2/enterprise-studio/rights-report";
export const enterpriseStudioDistributionReportPath = "/v2/enterprise-studio/distribution-report";
export const performanceScaleSummaryPath = "/v2/performance-scale/summary";
export const performanceScaleWarmCachePath = "/v2/performance-scale/cache/warm";
export const performanceScaleLargeCatalogPath = "/v2/performance-scale/catalog/large-page";
export const performanceScaleSearchIndexPath = "/v2/performance-scale/search-index";
export const performanceScaleSyncTuningPath = "/v2/performance-scale/sync-tuning";
export const cinemaTwoSummaryPath = "/v2/highfive-cinema-2/summary";
export const cinemaTwoPolishAuditPath = "/v2/highfive-cinema-2/polish-audit";
export const cinemaTwoAccessibilityPath = "/v2/highfive-cinema-2/accessibility";
export const cinemaTwoMarketingAssetsPath = "/v2/highfive-cinema-2/marketing-assets";
export const cinemaTwoReleaseChecklistPath = "/v2/highfive-cinema-2/release-checklist";
export const v3PersonalizationHomePath = "/v3/personalization/home";
export const v3PersonalizationTasteGraphPath = "/v3/personalization/taste-graph";
export const v3PersonalizationMoodEnginePath = "/v3/personalization/mood-engine";
export const v3PersonalizationAdaptiveDiscoveryPath = "/v3/personalization/adaptive-discovery";
export const v3SearchQueryPath = "/v3/search/query";
export const v3SearchSemanticPath = "/v3/search/semantic";
export const v3SearchVisualSimilarityPath = "/v3/search/visual-similarity";
export const v3SearchCreatorSimilarityPath = "/v3/search/creator-similarity";
export const v3SearchVoicePath = "/v3/search/voice";
export const v3SearchRecommendationPath = "/v3/search/recommendations";
export const v3CreatorCopilotSummaryPath = "/v3/creator-copilot/summary";
export const v3CreatorCopilotGenerationPlanPath = "/v3/creator-copilot/generation-plan";
export const v3CreatorCopilotAudiencePath = "/v3/creator-copilot/audience";
export const v3CreatorCopilotReleaseTimingPath = "/v3/creator-copilot/release-timing";
export const v3CreatorCopilotPublishingPath = "/v3/creator-copilot/publishing";
export const v3CreatorCRMSummaryPath = "/v3/creator-crm/summary";
export const v3CreatorCRMInboxPath = "/v3/creator-crm/inbox";
export const v3CreatorCRMContractsPath = "/v3/creator-crm/contracts";
export const v3CreatorCRMTasksPath = "/v3/creator-crm/tasks";
export const v3CreatorCRMMilestonesPath = "/v3/creator-crm/milestones";
export const v3CreatorCRMTeamsPath = "/v3/creator-crm/teams";
export const v3CreatorCRMDeliverablesPath = "/v3/creator-crm/deliverables";
export const v3ProductionSummaryPath = "/v3/production-management/summary";
export const v3ProductionFilmsPath = "/v3/production-management/films";
export const v3ProductionSeriesPath = "/v3/production-management/series";
export const v3ProductionProjectsPath = "/v3/production-management/projects";
export const v3ProductionSchedulePath = "/v3/production-management/schedule";
export const v3ProductionBudgetsPath = "/v3/production-management/budgets";
export const v3ProductionCrewPath = "/v3/production-management/crew";
export const v3ProductionAssetsPath = "/v3/production-management/assets";
export const v3EnterpriseStudiosSummaryPath = "/v3/enterprise-studios/summary";
export const v3EnterpriseStudiosOrganizationsPath = "/v3/enterprise-studios/organizations";
export const v3EnterpriseStudiosAccountsPath = "/v3/enterprise-studios/accounts";
export const v3EnterpriseStudiosWorkspacesPath = "/v3/enterprise-studios/workspaces";
export const v3EnterpriseStudiosPermissionsPath = "/v3/enterprise-studios/permissions";
export const v3EnterpriseStudiosDepartmentsPath = "/v3/enterprise-studios/departments";
export const v3EnterpriseStudiosSharedLibrariesPath = "/v3/enterprise-studios/shared-libraries";
export const v3MarketplaceSummaryPath = "/v3/marketplace/summary";
export const v3MarketplaceLicensesPath = "/v3/marketplace/licenses";
export const v3MarketplaceDistributionPath = "/v3/marketplace/distribution";
export const v3MarketplaceCreatorServicesPath = "/v3/marketplace/creator-services";
export const v3MarketplaceProductionServicesPath = "/v3/marketplace/production-services";
export const v3MarketplaceMusicPath = "/v3/marketplace/music";
export const v3MarketplaceStockFootagePath = "/v3/marketplace/stock-footage";
export const v3GlobalDistributionSummaryPath = "/v3/global-distribution/summary";
export const v3GlobalDistributionLocalizationPath = "/v3/global-distribution/localization";
export const v3GlobalDistributionSubtitlesPath = "/v3/global-distribution/subtitles";
export const v3GlobalDistributionRegionalPublishingPath = "/v3/global-distribution/regional-publishing";
export const v3GlobalDistributionTerritoriesPath = "/v3/global-distribution/territories";
export const v3GlobalDistributionLanguagesPath = "/v3/global-distribution/languages";
export const v3AIOperationsSummaryPath = "/v3/ai-operations/summary";
export const v3AIOperationsModerationPath = "/v3/ai-operations/moderation";
export const v3AIOperationsQualityControlPath = "/v3/ai-operations/quality-control";
export const v3AIOperationsCatalogOptimizationPath = "/v3/ai-operations/catalog-optimization";
export const v3AIOperationsRightsValidationPath = "/v3/ai-operations/rights-validation";
export const v3AIOperationsReleaseOptimizationPath = "/v3/ai-operations/release-optimization";
export const identityDevSignInPath = "/v1/identity/dev/sign-in";
export const identityAppleExchangePath = "/v1/identity/apple/exchange";
export const identityRefreshPath = "/v1/identity/session/refresh";
export const identitySignOutPath = "/v1/identity/sign-out";
export const identityMePath = "/v1/identity/me";
export const identityDataExportPath = "/v1/identity/data-export";
export const identityDeleteRequestPath = "/v1/identity/delete-request";
export const identityAuditPath = "/v1/identity/audit";
export const securityRateLimitProbePath = "/v1/security/rate-limit-probe";
export const creatorWorkspacePath = "/v1/creator/workspace";
export const creatorDraftsPath = "/v1/creator/drafts";
export const creatorDraftDetailPath = "/v1/creator/drafts/";
export const creatorDraftSyncQueuePath = "/v1/creator/draft-sync/queue";
export const adminReviewQueuePath = "/v1/admin/review/queue";
export const adminReviewDetailPath = "/v1/admin/review/";
export const adminReviewAuditPath = "/v1/admin/review/audit";
export const creatorUploadSessionsPath = "/v1/creator/uploads/sessions";
export const creatorUploadDetailPath = "/v1/creator/uploads/";
export const creatorUploadAssetsPath = "/v1/creator/uploads/assets";
export const creatorProcessingJobsPath = "/v1/creator/processing/jobs";
export const creatorProcessingJobDetailPath = "/v1/creator/processing/jobs/";
export const viewerLibraryPath = "/v1/viewer/library";
export const viewerLibrarySavePath = "/v1/viewer/library/save";
export const viewerLibraryProgressPath = "/v1/viewer/library/progress";
export const viewerLibraryOfflinePath = "/v1/viewer/library/offline";
export const analyticsEventsPath = "/v1/analytics/events";
export const analyticsDashboardPath = "/v1/analytics/dashboard";
export const notificationDevicesPath = "/v1/notifications/devices";
export const notificationPreferencesPath = "/v1/notifications/preferences";
export const notificationInboxPath = "/v1/notifications/inbox";
export const notificationDetailPath = "/v1/notifications/";
export const notificationTestPushPath = "/v1/notifications/test-push";
export const notificationDeliveryAuditPath = "/v1/notifications/delivery-audit";
export const monetizationProductsPath = "/v1/monetization/products";
export const monetizationEntitlementsPath = "/v1/monetization/entitlements";
export const monetizationTransactionsPath = "/v1/monetization/transactions";
export const monetizationRestorePath = "/v1/monetization/restore";
export const monetizationRevokePath = "/v1/monetization/revoke";
export const monetizationAuditPath = "/v1/monetization/audit";
export const platformOperationsSummaryPath = "/v1/admin/operations/summary";
export const platformOperationsRightsPath = "/v1/admin/operations/rights";
export const platformOperationsModerationPath = "/v1/admin/operations/moderation";
export const platformOperationsModerationFlagsPath = "/v1/admin/operations/moderation/flags";
export const platformOperationsModerationDetailPath = "/v1/admin/operations/moderation/";
export const platformOperationsRightsDetailPath = "/v1/admin/operations/rights/";
export const platformOperationsAuditPath = "/v1/admin/operations/audit";
export const betaProgramPath = "/v1/beta/program";
export const betaEnrollPath = "/v1/beta/enroll";
export const betaFeedbackPath = "/v1/beta/feedback";
export const betaFeedbackDetailPath = "/v1/beta/feedback/";
export const betaCrashReportsPath = "/v1/beta/crashes";
export const betaCrashDetailPath = "/v1/beta/crashes/";
export const betaStabilityPath = "/v1/beta/stability";
export const betaAuditPath = "/v1/beta/audit";
export const publicReleaseSummaryPath = "/v1/release/public/summary";
export const publicReleaseSubmitPath = "/v1/release/public/submit";
export const publicReleaseCutoverPath = "/v1/release/public/cutover";
export const publicReleaseMonitorPath = "/v1/release/public/monitor";
export const publicReleaseHotfixPath = "/v1/release/public/hotfixes";
export const publicReleaseHotfixDetailPath = "/v1/release/public/hotfixes/";
export const publicReleaseCreatorOnboardingPath = "/v1/release/public/creator-onboarding";
export const publicReleaseAuditPath = "/v1/release/public/audit";

export const contractStates = [
  "entitlement_approved",
  "entitlement_denied",
  "entitlement_pending",
  "descriptor_ready",
  "descriptor_unavailable",
  "descriptor_expired",
  "descriptor_refresh_required",
  "local_preview_fallback"
] as const;

export function isRecord(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function isEntitlementValidationRequest(value: unknown): value is EntitlementValidationRequest {
  if (!isRecord(value)) return false;
  return hasNullableString(value.user_id) &&
    hasNullableString(value.anonymous_session_id) &&
    typeof value.movie_id === "string" &&
    typeof value.storekit_product_id === "string" &&
    isRecord(value.entitlement_context) &&
    typeof value.playback_provider === "string" &&
    isRecord(value.device_context);
}

export function isPlaybackDescriptorRequest(value: unknown): value is PlaybackDescriptorRequest {
  if (!isRecord(value)) return false;
  return isEntitlementValidationRequest(value) && typeof (value as JsonObject).audit_id === "string";
}

function hasNullableString(value: unknown): value is string | null {
  return value === null || typeof value === "string";
}
