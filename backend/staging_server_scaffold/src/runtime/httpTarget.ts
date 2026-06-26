import { createServer, type Server } from "node:http";
import {
  catalogPath,
  catalogDeltaPath,
  catalogSyncPath,
  collectionDetailPath,
  contentDetailPath,
  analyticsDashboardPath,
  analyticsEventsPath,
  adminReviewAuditPath,
  adminReviewDetailPath,
  adminReviewQueuePath,
  creatorDraftDetailPath,
  creatorDraftsPath,
  creatorDraftSyncQueuePath,
  creatorWorkspacePath,
  creatorDetailPath,
  discoveryQueryPath,
  aiDiscoveryHomePath,
  aiDiscoveryMoodPath,
  aiDiscoverySearchPath,
  socialWatchFriendsPath,
  socialWatchInviteDetailPath,
  socialWatchPartiesPath,
  socialWatchPartyDetailPath,
  socialWatchSharedLibraryPath,
  socialWatchSummaryPath,
  creatorEconomyDashboardPath,
  creatorEconomyMembershipsPath,
  creatorEconomyPaidCollectionsPath,
  creatorEconomyPaidPremieresPath,
  creatorEconomyPayoutsPath,
  creatorEconomyRevenueSharesPath,
  creatorEconomyTipsPath,
  creatorAssistantMetadataPath,
  creatorAssistantPosterPath,
  creatorAssistantPublishingPath,
  creatorAssistantRightsPath,
  creatorAssistantSEOPath,
  creatorAssistantSummaryPath,
  creatorAssistantTrailerPath,
  creatorProcessingJobDetailPath,
  creatorProcessingJobsPath,
  creatorUploadAssetsPath,
  creatorUploadDetailPath,
  creatorUploadSessionsPath,
  entitlementValidationPath,
  identityAppleExchangePath,
  identityAuditPath,
  identityDataExportPath,
  identityDeleteRequestPath,
  identityDevSignInPath,
  identityMePath,
  identityRefreshPath,
  identitySignOutPath,
  notificationDeliveryAuditPath,
  notificationDetailPath,
  notificationDevicesPath,
  notificationInboxPath,
  notificationPreferencesPath,
  notificationTestPushPath,
  monetizationAuditPath,
  monetizationEntitlementsPath,
  monetizationProductsPath,
  monetizationRestorePath,
  monetizationRevokePath,
  monetizationTransactionsPath,
  openAPIPath,
  platformOperationsAuditPath,
  platformOperationsModerationDetailPath,
  platformOperationsModerationFlagsPath,
  platformOperationsModerationPath,
  platformOperationsRightsDetailPath,
  platformOperationsRightsPath,
  platformOperationsSummaryPath,
  betaAuditPath,
  betaCrashDetailPath,
  betaCrashReportsPath,
  betaEnrollPath,
  betaFeedbackDetailPath,
  betaFeedbackPath,
  betaProgramPath,
  betaStabilityPath,
  publicReleaseAuditPath,
  publicReleaseCreatorOnboardingPath,
  publicReleaseCutoverPath,
  publicReleaseHotfixDetailPath,
  publicReleaseHotfixPath,
  publicReleaseMonitorPath,
  publicReleaseSubmitPath,
  publicReleaseSummaryPath,
  playbackHLSPath,
  playbackDescriptorPath,
  readinessPath,
  securityRateLimitProbePath,
  viewerLibraryOfflinePath,
  viewerLibraryPath,
  viewerLibraryProgressPath,
  viewerLibrarySavePath
} from "../contracts.js";
import { openAPISpec } from "../catalog/openapi.js";
import { catalogDelta, catalogSummary, catalogSync, collectionDetail, contentDetail, creatorDetail } from "../routes/catalog.js";
import { discoveryQuery, discoveryReadinessSummary } from "../routes/discovery.js";
import {
  aiDiscoveryHome,
  aiDiscoveryMood,
  aiDiscoveryReadinessSummary,
  aiDiscoverySearch
} from "../routes/aiDiscovery.js";
import {
  addWatchComment,
  addWatchReaction,
  createFriend,
  createWatchParty,
  respondWatchInvite,
  sendWatchInvite,
  shareLibrary,
  socialWatchReadinessSummary,
  socialWatchSummary,
  syncWatchPlayback,
  updateVoiceRoom
} from "../routes/socialWatch.js";
import {
  createPaidCollection,
  createPaidPremiere,
  creatorEconomyDashboard,
  creatorEconomyPayouts,
  creatorEconomyReadinessSummary,
  joinCreatorMembership,
  recordCreatorTip,
  updateCreatorRevenueShare
} from "../routes/creatorEconomy.js";
import {
  creatorAssistantMetadata,
  creatorAssistantPoster,
  creatorAssistantPublishing,
  creatorAssistantReadinessSummary,
  creatorAssistantRights,
  creatorAssistantSEO,
  creatorAssistantSummary,
  creatorAssistantTrailer
} from "../routes/creatorAssistant.js";
import {
  createDevelopmentIdentitySession,
  creatorWorkspaceMutation,
  currentIdentitySession,
  exchangeAppleIdentity,
  exportIdentityData,
  identityAuditTrail,
  identityReadinessSummary,
  refreshIdentitySession,
  requestAccountDeletion,
  signOutIdentitySession
} from "../routes/identity.js";
import {
  archiveCreatorDraftRemote,
  adminApproveProject,
  adminArchiveProject,
  adminPublishProject,
  adminRejectProject,
  adminRequestRevision,
  adminReviewAuditTrail,
  adminReviewQueue,
  adminScheduleProject,
  adminUnpublishProject,
  createCreatorDraftRemote,
  creatorDraftRevisionHistory,
  creatorDraftSyncQueue,
  getCreatorDraft,
  listCreatorDrafts,
  publishingReadinessSummary,
  restoreCreatorDraftRemote,
  submitCreatorDraftForReview,
  withdrawCreatorReviewSubmission,
  updateCreatorDraftRemote
} from "../routes/publishing.js";
import { createEntitlementRoute } from "../routes/entitlements.js";
import { createPlaybackRoute } from "../routes/playback.js";
import { descriptorSignerForRequest, entitlementProviderForRequest } from "./providerFactory.js";
import {
  errorResponse,
  methodNotAllowed,
  readBoundedJsonBody,
  readBoundedBinaryBody,
  routeNotFound,
  writeJson,
  writeText
} from "./httpResponse.js";
import {
  cancelCreatorUploadSession,
  createCreatorUploadSession,
  listCreatorUploadedAssets,
  putCreatorUploadBlob,
  uploadReadinessSummary
} from "../routes/uploads.js";
import {
  createProcessingJob,
  listProcessingJobs,
  processedPlaybackManifest,
  processingReadinessSummary,
  retryProcessingJob
} from "../routes/processing.js";
import {
  saveViewerLibraryTitle,
  updateViewerOfflineState,
  updateViewerProgress,
  viewerLibraryReadinessSummary,
  viewerLibrarySnapshot
} from "../routes/library.js";
import type { RuntimeConfig } from "./runtimeConfig.js";
import { analyticsDashboard, analyticsReadinessSummary, ingestAnalyticsEvents } from "../routes/analytics.js";
import {
  markNotificationRead,
  notificationDeliveryAudit,
  notificationInbox,
  notificationPreferences,
  notificationReadinessSummary,
  registerNotificationDevice,
  sendTestNotification
} from "../routes/notifications.js";
import {
  monetizationAudit,
  monetizationEntitlements,
  monetizationProducts,
  monetizationReadinessSummary,
  recordStoreKitTransaction,
  restoreMonetizationEntitlements,
  revokeMonetizationEntitlement
} from "../routes/monetization.js";
import {
  decideModerationCase,
  expireRightsWindow,
  flagContentForModeration,
  moderationQueue,
  operationsAuditTrail,
  operationsReadinessSummary,
  operationsSummary,
  restoreRightsWindow,
  rightsLedger
} from "../routes/operations.js";
import {
  betaAuditTrail,
  betaProgramSummary,
  betaReadinessSummary,
  betaStabilityReport,
  enrollBetaTester,
  resolveBetaCrashReport,
  resolveBetaFeedback,
  submitBetaCrashReport,
  submitBetaFeedback
} from "../routes/beta.js";
import {
  onboardPublicReleaseCreator,
  publicReleaseAuditTrail,
  publicReleaseMonitor,
  publicReleaseReadinessSummary,
  publicReleaseSummary,
  recordPublicReleaseHotfix,
  releasePublicRelease,
  submitPublicRelease,
  updatePublicReleaseHotfix
} from "../routes/publicRelease.js";
import {
  applySecurityHeaders,
  enforceRateLimit,
  securityHardeningReadinessSummary
} from "./securityHardening.js";

export function createStagingHttpTarget(config: RuntimeConfig): Server {
  return createServer(async (request, response) => {
    applySecurityHeaders(response);
    try {
      const path = request.url?.split("?")[0] ?? "/";
      enforceRateLimit(request, config);

      if (path === "/health") {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, healthBody(config));
        return;
      }

      if (path === readinessPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, readinessBody(config));
        return;
      }

      if (path === openAPIPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, openAPISpec());
        return;
      }

      if (path === securityRateLimitProbePath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, { status: "ok", route: "rate_limit_probe" });
        return;
      }

      if (path === catalogPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogSummary(undefined, territoryFor(request.url)));
        return;
      }

      if (path === catalogSyncPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogSync(queryValue(request.url, "cursor"), undefined, territoryFor(request.url)));
        return;
      }

      if (path === catalogDeltaPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogDelta(queryValue(request.url, "cursor")));
        return;
      }

      if (path === viewerLibraryPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, viewerLibrarySnapshot(authHeader(request.headers.authorization)));
        return;
      }

      if (path === discoveryQueryPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, discoveryQuery(request.url, authHeader(request.headers.authorization)));
        return;
      }

      if (path === aiDiscoveryHomePath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, aiDiscoveryHome(authHeader(request.headers.authorization)));
        return;
      }

      if (path === aiDiscoverySearchPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, aiDiscoverySearch(request.url, authHeader(request.headers.authorization)));
        return;
      }

      if (path === aiDiscoveryMoodPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, aiDiscoveryMood(request.url, authHeader(request.headers.authorization)));
        return;
      }

      if (path === socialWatchSummaryPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, socialWatchSummary(authHeader(request.headers.authorization)));
        return;
      }

      if (path === socialWatchFriendsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, createFriend(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === socialWatchSharedLibraryPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, shareLibrary(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === socialWatchPartiesPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, createWatchParty(authHeader(request.headers.authorization), body));
        return;
      }

      if (path.startsWith(socialWatchPartyDetailPath)) {
        const route = socialWatchPartyRoute(path);
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        if (route.action === "invite") {
          writeJson(response, 201, sendWatchInvite(authHeader(request.headers.authorization), route.id, body));
          return;
        }
        if (route.action === "playback") {
          writeJson(response, 200, syncWatchPlayback(authHeader(request.headers.authorization), route.id, body));
          return;
        }
        if (route.action === "reactions") {
          writeJson(response, 201, addWatchReaction(authHeader(request.headers.authorization), route.id, body));
          return;
        }
        if (route.action === "comments") {
          writeJson(response, 201, addWatchComment(authHeader(request.headers.authorization), route.id, body));
          return;
        }
        if (route.action === "voice-room") {
          writeJson(response, 200, updateVoiceRoom(authHeader(request.headers.authorization), route.id, body));
          return;
        }
        const result = routeNotFound();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path.startsWith(socialWatchInviteDetailPath)) {
        const route = socialWatchInviteRoute(path);
        if (route.action !== "respond") {
          const result = routeNotFound();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, respondWatchInvite(authHeader(request.headers.authorization), route.id, body));
        return;
      }

      if (path === creatorEconomyDashboardPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorEconomyDashboard(authHeader(request.headers.authorization)));
        return;
      }

      if (path === creatorEconomyPayoutsPath) {
        if (request.method === "GET") {
          writeJson(response, 200, creatorEconomyPayouts(authHeader(request.headers.authorization)));
          return;
        }
        if (request.method === "POST") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 201, creatorEconomyPayouts(authHeader(request.headers.authorization), body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path === creatorEconomyRevenueSharesPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, updateCreatorRevenueShare(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorEconomyTipsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, recordCreatorTip(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorEconomyMembershipsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, joinCreatorMembership(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorEconomyPaidCollectionsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, createPaidCollection(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorEconomyPaidPremieresPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, createPaidPremiere(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorAssistantSummaryPath) {
        if (request.method === "GET") {
          writeJson(response, 200, creatorAssistantSummary(authHeader(request.headers.authorization), {}));
          return;
        }
        if (request.method === "POST") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, creatorAssistantSummary(authHeader(request.headers.authorization), body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path === creatorAssistantMetadataPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, creatorAssistantMetadata(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorAssistantPosterPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, creatorAssistantPoster(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorAssistantTrailerPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, creatorAssistantTrailer(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorAssistantPublishingPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, creatorAssistantPublishing(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorAssistantSEOPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, creatorAssistantSEO(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === creatorAssistantRightsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, creatorAssistantRights(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === viewerLibrarySavePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, saveViewerLibraryTitle(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === viewerLibraryProgressPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, updateViewerProgress(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === viewerLibraryOfflinePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, updateViewerOfflineState(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === analyticsEventsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 202, ingestAnalyticsEvents(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === analyticsDashboardPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, analyticsDashboard(authHeader(request.headers.authorization)));
        return;
      }

      if (path === notificationDevicesPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, registerNotificationDevice(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === notificationPreferencesPath) {
        if (request.method === "GET") {
          writeJson(response, 200, notificationPreferences(authHeader(request.headers.authorization)));
          return;
        }
        if (request.method === "PATCH") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, notificationPreferences(authHeader(request.headers.authorization), body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path === notificationInboxPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, notificationInbox(authHeader(request.headers.authorization)));
        return;
      }

      if (path === notificationTestPushPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 202, sendTestNotification(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === notificationDeliveryAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, notificationDeliveryAudit(authHeader(request.headers.authorization)));
        return;
      }

      if (path.startsWith(notificationDetailPath)) {
        const route = notificationRoute(path);
        if (route.action === "read") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          writeJson(response, 200, markNotificationRead(authHeader(request.headers.authorization), route.id));
          return;
        }
        const result = routeNotFound();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path === monetizationProductsPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, monetizationProducts());
        return;
      }

      if (path === monetizationEntitlementsPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, monetizationEntitlements(authHeader(request.headers.authorization)));
        return;
      }

      if (path === monetizationTransactionsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, recordStoreKitTransaction(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === monetizationRestorePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, restoreMonetizationEntitlements(authHeader(request.headers.authorization)));
        return;
      }

      if (path === monetizationRevokePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, revokeMonetizationEntitlement(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === monetizationAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, monetizationAudit(authHeader(request.headers.authorization)));
        return;
      }

      if (path === platformOperationsSummaryPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, operationsSummary(authHeader(request.headers.authorization), territoryFor(request.url)));
        return;
      }

      if (path === platformOperationsRightsPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, rightsLedger(authHeader(request.headers.authorization), territoryFor(request.url)));
        return;
      }

      if (path === platformOperationsModerationPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, moderationQueue(authHeader(request.headers.authorization)));
        return;
      }

      if (path === platformOperationsModerationFlagsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, flagContentForModeration(authHeader(request.headers.authorization), body));
        return;
      }

      if (path.startsWith(platformOperationsModerationDetailPath)) {
        const route = platformOperationsRoute(path, platformOperationsModerationDetailPath);
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, decideModerationCase(authHeader(request.headers.authorization), route.id, route.action, body));
        return;
      }

      if (path.startsWith(platformOperationsRightsDetailPath)) {
        const route = platformOperationsRoute(path, platformOperationsRightsDetailPath);
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        if (route.action === "expire") {
          writeJson(response, 200, expireRightsWindow(authHeader(request.headers.authorization), route.id, body));
          return;
        }
        if (route.action === "restore") {
          writeJson(response, 200, restoreRightsWindow(authHeader(request.headers.authorization), route.id, body));
          return;
        }
        const result = routeNotFound();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path === platformOperationsAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, operationsAuditTrail(authHeader(request.headers.authorization)));
        return;
      }

      if (path === betaProgramPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, betaProgramSummary(authHeader(request.headers.authorization)));
        return;
      }

      if (path === betaEnrollPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, enrollBetaTester(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === betaFeedbackPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, submitBetaFeedback(authHeader(request.headers.authorization), body));
        return;
      }

      if (path.startsWith(betaFeedbackDetailPath)) {
        const route = betaRoute(path, betaFeedbackDetailPath);
        if (route.action !== "resolve") {
          const result = routeNotFound();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, resolveBetaFeedback(authHeader(request.headers.authorization), route.id, body));
        return;
      }

      if (path === betaCrashReportsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, submitBetaCrashReport(authHeader(request.headers.authorization), body));
        return;
      }

      if (path.startsWith(betaCrashDetailPath)) {
        const route = betaRoute(path, betaCrashDetailPath);
        if (route.action !== "resolve") {
          const result = routeNotFound();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, resolveBetaCrashReport(authHeader(request.headers.authorization), route.id, body));
        return;
      }

      if (path === betaStabilityPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, betaStabilityReport(authHeader(request.headers.authorization)));
        return;
      }

      if (path === betaAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, betaAuditTrail(authHeader(request.headers.authorization)));
        return;
      }

      if (path === publicReleaseSummaryPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, publicReleaseSummary(authHeader(request.headers.authorization)));
        return;
      }

      if (path === publicReleaseSubmitPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, submitPublicRelease(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === publicReleaseCutoverPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, releasePublicRelease(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === publicReleaseMonitorPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, publicReleaseMonitor(authHeader(request.headers.authorization)));
        return;
      }

      if (path === publicReleaseHotfixPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, recordPublicReleaseHotfix(authHeader(request.headers.authorization), body));
        return;
      }

      if (path.startsWith(publicReleaseHotfixDetailPath)) {
        const route = releaseRoute(path, publicReleaseHotfixDetailPath);
        if (route.action !== "update") {
          const result = routeNotFound();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, updatePublicReleaseHotfix(authHeader(request.headers.authorization), route.id, body));
        return;
      }

      if (path === publicReleaseCreatorOnboardingPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, onboardPublicReleaseCreator(authHeader(request.headers.authorization), body));
        return;
      }

      if (path === publicReleaseAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, publicReleaseAuditTrail(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityDevSignInPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, createDevelopmentIdentitySession(body));
        return;
      }

      if (path === identityAppleExchangePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 200, exchangeAppleIdentity(body));
        return;
      }

      if (path === identityRefreshPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, refreshIdentitySession(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identitySignOutPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, signOutIdentitySession(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityMePath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, currentIdentitySession(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityDataExportPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, exportIdentityData(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityDeleteRequestPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, requestAccountDeletion(authHeader(request.headers.authorization)));
        return;
      }

      if (path === identityAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, identityAuditTrail());
        return;
      }

      if (path === creatorWorkspacePath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorWorkspaceMutation(authHeader(request.headers.authorization)));
        return;
      }

      if (path === creatorDraftsPath) {
        if (request.method === "GET") {
          writeJson(response, 200, listCreatorDrafts(authHeader(request.headers.authorization)));
          return;
        }
        if (request.method === "POST") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 201, createCreatorDraftRemote(authHeader(request.headers.authorization), body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path === creatorDraftSyncQueuePath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorDraftSyncQueue(authHeader(request.headers.authorization)));
        return;
      }

      if (path === adminReviewQueuePath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, adminReviewQueue(authHeader(request.headers.authorization)));
        return;
      }

      if (path === adminReviewAuditPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, adminReviewAuditTrail(authHeader(request.headers.authorization)));
        return;
      }

      if (path === creatorUploadSessionsPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        writeJson(response, 201, createCreatorUploadSession(authHeader(request.headers.authorization), body, originFor(request, config)));
        return;
      }

      if (path === creatorUploadAssetsPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, listCreatorUploadedAssets(authHeader(request.headers.authorization)));
        return;
      }

      if (path === creatorProcessingJobsPath) {
        if (request.method === "GET") {
          writeJson(response, 200, listProcessingJobs(authHeader(request.headers.authorization)));
          return;
        }
        if (request.method === "POST") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 201, await createProcessingJob(authHeader(request.headers.authorization), body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path.startsWith(creatorProcessingJobDetailPath)) {
        const route = creatorProcessingRoute(path);
        if (route.action === "retry") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          writeJson(response, 200, await retryProcessingJob(authHeader(request.headers.authorization), route.id));
          return;
        }
        const result = routeNotFound();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path.startsWith(creatorUploadDetailPath)) {
        const uploadRoute = creatorUploadRoute(path);
        if (uploadRoute.action === "blob") {
          if (request.method !== "PUT") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const data = await readBoundedBinaryBody(request, config.uploadBodyLimitBytes);
          writeJson(response, 200, await putCreatorUploadBlob(authHeader(request.headers.authorization), uploadRoute.id, data));
          return;
        }
        if (uploadRoute.action === "cancel") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          writeJson(response, 200, await cancelCreatorUploadSession(authHeader(request.headers.authorization), uploadRoute.id));
          return;
        }
        const result = routeNotFound();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path.startsWith(creatorDraftDetailPath)) {
        const draftRoute = creatorDraftRoute(path);
        if (draftRoute.action === "submit") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, submitCreatorDraftForReview(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        if (draftRoute.action === "withdraw") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, withdrawCreatorReviewSubmission(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        if (draftRoute.action === "archive") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, archiveCreatorDraftRemote(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        if (draftRoute.action === "restore") {
          if (request.method !== "POST") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, restoreCreatorDraftRemote(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        if (draftRoute.action === "revisions") {
          if (request.method !== "GET") {
            const result = methodNotAllowed();
            writeJson(response, result.statusCode, result.body);
            return;
          }
          writeJson(response, 200, creatorDraftRevisionHistory(authHeader(request.headers.authorization), draftRoute.id));
          return;
        }
        if (request.method === "GET") {
          writeJson(response, 200, getCreatorDraft(authHeader(request.headers.authorization), draftRoute.id));
          return;
        }
        if (request.method === "PATCH") {
          const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
          writeJson(response, 200, updateCreatorDraftRemote(authHeader(request.headers.authorization), draftRoute.id, body));
          return;
        }
        const result = methodNotAllowed();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path.startsWith(adminReviewDetailPath)) {
        const reviewRoute = adminReviewRoute(path);
        if (!reviewRoute.action) {
          const result = routeNotFound();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        if (reviewRoute.action === "request-revision") {
          writeJson(response, 200, adminRequestRevision(authHeader(request.headers.authorization), reviewRoute.id, body));
          return;
        }
        if (reviewRoute.action === "approve") {
          writeJson(response, 200, adminApproveProject(authHeader(request.headers.authorization), reviewRoute.id, body));
          return;
        }
        if (reviewRoute.action === "reject") {
          writeJson(response, 200, adminRejectProject(authHeader(request.headers.authorization), reviewRoute.id, body));
          return;
        }
        if (reviewRoute.action === "schedule") {
          writeJson(response, 200, adminScheduleProject(authHeader(request.headers.authorization), reviewRoute.id, body));
          return;
        }
        if (reviewRoute.action === "publish") {
          writeJson(response, 200, adminPublishProject(authHeader(request.headers.authorization), reviewRoute.id, body));
          return;
        }
        if (reviewRoute.action === "unpublish") {
          writeJson(response, 200, adminUnpublishProject(authHeader(request.headers.authorization), reviewRoute.id, body));
          return;
        }
        if (reviewRoute.action === "archive") {
          writeJson(response, 200, adminArchiveProject(authHeader(request.headers.authorization), reviewRoute.id, body));
          return;
        }
        const result = routeNotFound();
        writeJson(response, result.statusCode, result.body);
        return;
      }

      if (path.startsWith(contentDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, contentDetail(routeID(path, contentDetailPath), undefined, authHeader(request.headers.authorization), territoryFor(request.url)));
        return;
      }

      if (path.startsWith(creatorDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorDetail(routeID(path, creatorDetailPath), undefined, authHeader(request.headers.authorization), territoryFor(request.url)));
        return;
      }

      if (path.startsWith(collectionDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, collectionDetail(routeID(path, collectionDetailPath), undefined, authHeader(request.headers.authorization), territoryFor(request.url)));
        return;
      }

      if (path === entitlementValidationPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        const route = createEntitlementRoute(entitlementProviderForRequest(request, config));
        writeJson(response, 200, await route(body));
        return;
      }

      if (path === playbackDescriptorPath) {
        if (request.method !== "POST") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const body = await readBoundedJsonBody(request, config.bodyLimitBytes);
        const route = createPlaybackRoute(descriptorSignerForRequest(request, config), originFor(request, config));
        writeJson(response, 200, await route(body));
        return;
      }

      if (path.startsWith(playbackHLSPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        const jobID = playbackHLSJobID(path);
        const result = processedPlaybackManifest(
          jobID,
          queryValue(request.url, "expires_at"),
          queryValue(request.url, "signature")
        );
        writeText(response, result.statusCode, result.body, result.contentType);
        return;
      }

      const result = routeNotFound();
      writeJson(response, result.statusCode, result.body);
    } catch (error) {
      const result = errorResponse(error);
      writeJson(response, result.statusCode, result.body);
    }
  });
}

function healthBody(config: RuntimeConfig): Record<string, string | boolean> {
  return {
    status: "ok",
    environment: config.backendEnv,
    provider_mode: config.providerMode,
    deployment_status: config.deploymentStatus,
    target_name: "highfive-staging-node-http",
    health_path: "/health",
    entitlement_path: entitlementValidationPath,
    descriptor_path: playbackDescriptorPath,
    readiness_path: readinessPath,
    catalog_path: catalogPath,
    catalog_sync_path: catalogSyncPath,
    catalog_delta_path: catalogDeltaPath,
    creator_upload_sessions_path: creatorUploadSessionsPath,
    creator_upload_assets_path: creatorUploadAssetsPath,
    creator_processing_jobs_path: creatorProcessingJobsPath,
    playback_hls_path: playbackHLSPath,
    viewer_library_path: viewerLibraryPath,
    discovery_query_path: discoveryQueryPath,
    ai_discovery_home_path: aiDiscoveryHomePath,
    ai_discovery_search_path: aiDiscoverySearchPath,
    ai_discovery_mood_path: aiDiscoveryMoodPath,
    social_watch_summary_path: socialWatchSummaryPath,
    social_watch_friends_path: socialWatchFriendsPath,
    social_watch_shared_library_path: socialWatchSharedLibraryPath,
    social_watch_parties_path: socialWatchPartiesPath,
    creator_economy_dashboard_path: creatorEconomyDashboardPath,
    creator_economy_payouts_path: creatorEconomyPayoutsPath,
    creator_economy_tips_path: creatorEconomyTipsPath,
    creator_economy_memberships_path: creatorEconomyMembershipsPath,
    creator_assistant_summary_path: creatorAssistantSummaryPath,
    creator_assistant_metadata_path: creatorAssistantMetadataPath,
    creator_assistant_publishing_path: creatorAssistantPublishingPath,
    analytics_events_path: analyticsEventsPath,
    analytics_dashboard_path: analyticsDashboardPath,
    notification_devices_path: notificationDevicesPath,
    notification_preferences_path: notificationPreferencesPath,
    notification_inbox_path: notificationInboxPath,
    notification_test_push_path: notificationTestPushPath,
    notification_delivery_audit_path: notificationDeliveryAuditPath,
    monetization_products_path: monetizationProductsPath,
    monetization_entitlements_path: monetizationEntitlementsPath,
    monetization_transactions_path: monetizationTransactionsPath,
    monetization_restore_path: monetizationRestorePath,
    platform_operations_summary_path: platformOperationsSummaryPath,
    platform_operations_rights_path: platformOperationsRightsPath,
    platform_operations_moderation_path: platformOperationsModerationPath,
    platform_operations_audit_path: platformOperationsAuditPath,
    beta_program_path: betaProgramPath,
    beta_enroll_path: betaEnrollPath,
    beta_feedback_path: betaFeedbackPath,
    beta_crash_reports_path: betaCrashReportsPath,
    beta_stability_path: betaStabilityPath,
    public_release_summary_path: publicReleaseSummaryPath,
    public_release_submit_path: publicReleaseSubmitPath,
    public_release_cutover_path: publicReleaseCutoverPath,
    public_release_monitor_path: publicReleaseMonitorPath,
    public_release_hotfix_path: publicReleaseHotfixPath,
    public_release_creator_onboarding_path: publicReleaseCreatorOnboardingPath,
    admin_review_queue_path: adminReviewQueuePath,
    credentials_required: false,
    external_network_allowed: false,
    local_preview_fallback_preserved: true
  };
}

function readinessBody(config: RuntimeConfig): Record<string, string | number | boolean> {
  const summary = catalogSummary();
  const identity = identityReadinessSummary();
  const publishing = publishingReadinessSummary();
  const uploads = uploadReadinessSummary();
  const processing = processingReadinessSummary();
  const library = viewerLibraryReadinessSummary();
  const discovery = discoveryReadinessSummary();
  const aiDiscovery = aiDiscoveryReadinessSummary();
  const socialWatch = socialWatchReadinessSummary();
  const creatorEconomy = creatorEconomyReadinessSummary();
  const creatorAssistant = creatorAssistantReadinessSummary();
  const analytics = analyticsReadinessSummary();
  const notifications = notificationReadinessSummary();
  const monetization = monetizationReadinessSummary();
  const operations = operationsReadinessSummary();
  const beta = betaReadinessSummary();
  const publicRelease = publicReleaseReadinessSummary();
  const security = securityHardeningReadinessSummary(config);
  return {
    status: "ready",
    environment: config.backendEnv,
    database_schema: "postgresql_compatible_v1",
    migrations_required: true,
    seed_data_loaded: true,
    catalog_titles: summary.total_titles,
    catalog_creators: summary.total_creators,
    catalog_series: summary.total_series,
    catalog_collections: summary.total_collections,
    catalog_sync_enabled: true,
    delta_sync_enabled: true,
    uploads_enabled: true,
    signed_upload_sessions: Boolean(uploads.signed_upload_sessions),
    local_object_storage: Boolean(uploads.local_object_storage),
    upload_checksum_validation: Boolean(uploads.checksum_validation),
    upload_poster_assets: Boolean(uploads.poster_uploads),
    upload_trailer_assets: Boolean(uploads.trailer_uploads),
    upload_source_assets: Boolean(uploads.source_uploads),
    upload_retry_supported: Boolean(uploads.retry_supported),
    upload_resume_policy: String(uploads.resume_policy),
    upload_max_size_bytes: Number(uploads.max_upload_size_bytes),
    uploaded_asset_records: Number(uploads.uploaded_assets),
    media_processing_enabled: Boolean(processing.processing_jobs_enabled),
    processing_worker_service: String(processing.worker_service),
    processing_queue_enabled: Boolean(processing.queue_enabled),
    ffprobe_inspection_contract: Boolean(processing.ffprobe_inspection_contract),
    ffmpeg_processing_contract: Boolean(processing.ffmpeg_processing_contract),
    hls_output_contract: Boolean(processing.hls_output_contract),
    processing_hls_variants: String(Array.isArray(processing.hls_variants) ? processing.hls_variants.join(",") : ""),
    processing_poster_generation: Boolean(processing.poster_generation),
    processing_thumbnail_generation: Boolean(processing.thumbnail_generation),
    processing_trailer_derivative: Boolean(processing.trailer_derivative),
    playback_descriptor_resolution: Boolean(processing.playback_descriptor_resolution),
    streaming_playback_runtime: Boolean(processing.streaming_playback_runtime),
    signed_playback_urls: Boolean(processing.signed_playback_urls),
    playback_resume_positions: Boolean(processing.playback_resume_positions),
    playback_caption_tracks: Boolean(processing.playback_caption_tracks),
    playback_audio_tracks: Boolean(processing.playback_audio_tracks),
    playback_bitrate_switching: Boolean(processing.playback_bitrate_switching),
    playback_series_autoplay: Boolean(processing.playback_series_autoplay),
    playback_next_episode: Boolean(processing.playback_next_episode),
    processing_failure_reasons: Boolean(processing.failure_reasons),
    processing_timeout_policy: String(processing.timeout_policy),
    processing_jobs: Number(processing.jobs),
    viewer_library_enabled: Boolean(library.viewer_library_enabled),
    playback_progress_enabled: Boolean(library.playback_progress),
    offline_records_enabled: Boolean(library.offline_records),
    library_conflict_policy: String(library.conflict_policy),
    discovery_service_enabled: Boolean(discovery.discovery_service_enabled),
    discovery_title_search: Boolean(discovery.title_search),
    discovery_recommendations_enabled: Boolean(discovery.recommendations),
    discovery_query_cache_enabled: Boolean(discovery.query_cache),
    discovery_analytics_hook: Boolean(discovery.analytics_hook),
    ai_discovery_enabled: Boolean(aiDiscovery.ai_discovery_enabled),
    ai_discovery_external_calls: Boolean(aiDiscovery.external_ai_calls),
    personalized_recommendations_enabled: Boolean(aiDiscovery.personalized_recommendations),
    watch_history_learning_enabled: Boolean(aiDiscovery.watch_history_learning),
    taste_profiles_enabled: Boolean(aiDiscovery.taste_profiles),
    mood_discovery_enabled: Boolean(aiDiscovery.mood_discovery),
    creator_affinity_enabled: Boolean(aiDiscovery.creator_affinity),
    genre_prediction_enabled: Boolean(aiDiscovery.genre_prediction),
    continue_watching_intelligence_enabled: Boolean(aiDiscovery.continue_watching_intelligence),
    search_ranking_improvements_enabled: Boolean(aiDiscovery.search_ranking_improvements),
    social_watch_enabled: Boolean(socialWatch.social_watch_enabled),
    social_watch_parties_enabled: Boolean(socialWatch.watch_parties),
    social_watch_invites_enabled: Boolean(socialWatch.invites),
    social_watch_friends_enabled: Boolean(socialWatch.friends),
    social_watch_shared_libraries_enabled: Boolean(socialWatch.shared_libraries),
    social_watch_synchronized_playback_enabled: Boolean(socialWatch.synchronized_playback),
    social_watch_voice_rooms_enabled: Boolean(socialWatch.voice_rooms),
    social_watch_comments_enabled: Boolean(socialWatch.comments),
    social_watch_reactions_enabled: Boolean(socialWatch.reactions),
    social_watch_transport: String(socialWatch.transport),
    creator_economy_enabled: Boolean(creatorEconomy.creator_economy_enabled),
    creator_payouts_enabled: Boolean(creatorEconomy.creator_payouts),
    creator_dashboard_enabled: Boolean(creatorEconomy.creator_dashboard),
    creator_revenue_sharing_enabled: Boolean(creatorEconomy.revenue_sharing),
    creator_tips_enabled: Boolean(creatorEconomy.tips),
    creator_memberships_enabled: Boolean(creatorEconomy.memberships),
    creator_paid_collections_enabled: Boolean(creatorEconomy.paid_collections),
    creator_paid_premieres_enabled: Boolean(creatorEconomy.paid_premieres),
    creator_economy_external_processor_calls: Boolean(creatorEconomy.external_processor_calls),
    creator_economy_ledger_records: Number(creatorEconomy.ledger_records),
    creator_assistant_enabled: Boolean(creatorAssistant.creator_assistant_enabled),
    creator_assistant_external_calls: Boolean(creatorAssistant.external_ai_calls),
    creator_assistant_metadata_generation: Boolean(creatorAssistant.metadata_generation),
    creator_assistant_poster_suggestions: Boolean(creatorAssistant.poster_suggestions),
    creator_assistant_trailer_suggestions: Boolean(creatorAssistant.trailer_suggestions),
    creator_assistant_publishing_assistant: Boolean(creatorAssistant.publishing_assistant),
    creator_assistant_seo_assistant: Boolean(creatorAssistant.seo_assistant),
    creator_assistant_rights_assistant: Boolean(creatorAssistant.rights_assistant),
    creator_assistant_deterministic_local_rules: Boolean(creatorAssistant.deterministic_local_rules),
    analytics_event_ingestion: Boolean(analytics.event_ingestion),
    analytics_batching: Boolean(analytics.batching),
    analytics_idempotency: Boolean(analytics.idempotency),
    analytics_aggregations: Boolean(analytics.aggregations),
    analytics_retention_metrics: Boolean(analytics.retention_metrics),
    analytics_watch_time_metrics: Boolean(analytics.watch_time_metrics),
    analytics_creator_title_metrics: Boolean(analytics.creator_title_metrics),
    analytics_discovery_source_attribution: Boolean(analytics.discovery_source_attribution),
    analytics_revenue_metrics: Boolean(analytics.revenue_metrics),
    analytics_events: Number(analytics.event_count),
    notifications_enabled: Boolean(notifications.notifications_enabled),
    apns_contract_ready: Boolean(notifications.apns_contract_ready),
    notification_push_contract: Boolean(notifications.push_contract),
    notification_device_registration: Boolean(notifications.device_registration),
    notification_preferences: Boolean(notifications.preferences),
    notification_inbox: Boolean(notifications.inbox),
    notification_in_app_inbox: Boolean(notifications.in_app_inbox),
    notification_deep_links: Boolean(notifications.deep_links),
    notification_delivery_audit: Boolean(notifications.delivery_audit),
    notification_read_state: Boolean(notifications.read_state),
    notification_publishing_events: Boolean(notifications.publishing_events),
    notification_creator_events: Boolean(notifications.creator_events),
    notification_series_events: Boolean(notifications.series_events),
    notification_system_events: Boolean(notifications.system_events),
    notification_permission_denied_fallback: Boolean(notifications.permission_denied_fallback),
    notification_creator_category: Array.isArray(notifications.categories) && notifications.categories.includes("creator"),
    notification_series_category: Array.isArray(notifications.categories) && notifications.categories.includes("series"),
    notification_category_count: Array.isArray(notifications.categories) ? notifications.categories.length : 0,
    notification_registered_devices: Number(notifications.registered_devices),
    notification_inbox_items: Number(notifications.inbox_items),
    external_push_attempted: Boolean(notifications.external_push_attempted),
    storekit2_products: Boolean(monetization.storekit2_products),
    storekit_purchase_recording: Boolean(monetization.purchase_recording),
    storekit_transaction_updates: Boolean(monetization.transaction_updates),
    storekit_restore_supported: Boolean(monetization.restore_supported),
    storekit_revocation_supported: Boolean(monetization.revocation_supported),
    storekit_expiration_supported: Boolean(monetization.expiration_supported),
    storekit_grace_period_supported: Boolean(monetization.grace_period_supported),
    storekit_billing_retry_supported: Boolean(monetization.billing_retry_supported),
    storekit_family_sharing_supported: Boolean(monetization.family_sharing_supported),
    subscription_management_link: Boolean(monetization.subscription_management_link),
    playback_entitlement_checks: Boolean(monetization.playback_entitlement_checks),
    download_entitlement_checks: Boolean(monetization.download_entitlement_checks),
    backend_entitlement_records: Boolean(monetization.backend_entitlement_records),
    app_store_server_api_contract: Boolean(monetization.app_store_server_api_contract),
    direct_card_collection: Boolean(monetization.direct_card_collection),
    active_entitlements: Number(monetization.active_entitlements),
    transaction_records: Number(monetization.transaction_records),
    rights_windows_enabled: Boolean(operations.rights_windows),
    territory_enforcement_enabled: Boolean(operations.territory_enforcement),
    date_window_enforcement_enabled: Boolean(operations.date_window_enforcement),
    licensing_packages_enabled: Boolean(operations.licensing_packages),
    catalog_visibility_filter_enabled: Boolean(operations.catalog_visibility_filter),
    availability_enforcement_enabled: Boolean(operations.availability_enforcement),
    moderation_queue_enabled: Boolean(operations.moderation_queue),
    takedown_supported: Boolean(operations.takedown_supported),
    operations_audit_trail: Boolean(operations.audit_trail),
    operations_admin_role_enforcement: Boolean(operations.admin_role_enforcement),
    beta_program_enabled: Boolean(beta.beta_program_enabled),
    internal_beta_ready: Boolean(beta.internal_beta_ready),
    external_beta_ready: Boolean(beta.external_beta_ready),
    creator_beta_ready: Boolean(beta.creator_beta_ready),
    beta_feedback_enabled: Boolean(beta.beta_feedback_enabled),
    beta_crash_intake_enabled: Boolean(beta.beta_crash_intake_enabled),
    beta_resolution_workflow: Boolean(beta.beta_resolution_workflow),
    beta_audit_trail: Boolean(beta.beta_audit_trail),
    stable_beta: Boolean(beta.stable_beta),
    beta_testers: Number(beta.beta_testers),
    beta_feedback_items: Number(beta.beta_feedback_items),
    beta_crash_reports: Number(beta.beta_crash_reports),
    beta_unresolved_blockers: Number(beta.unresolved_blockers),
    public_release_operations_enabled: Boolean(publicRelease.public_release_operations_enabled),
    public_release_submission_record_enabled: Boolean(publicRelease.submission_record_enabled),
    public_release_cutover_enabled: Boolean(publicRelease.release_cutover_enabled),
    public_release_monitoring_enabled: Boolean(publicRelease.release_monitoring_enabled),
    public_release_hotfix_tracking_enabled: Boolean(publicRelease.hotfix_tracking_enabled),
    public_release_launch_analytics_enabled: Boolean(publicRelease.launch_analytics_enabled),
    public_release_creator_onboarding_enabled: Boolean(publicRelease.creator_onboarding_enabled),
    public_release_audit_trail_enabled: Boolean(publicRelease.audit_trail_enabled),
    public_release_external_submission_required: Boolean(publicRelease.external_submission_required),
    public_release_external_submission_confirmed: Boolean(publicRelease.external_submission_confirmed),
    public_release_confirmed: Boolean(publicRelease.public_release_confirmed),
    public_release_open_hotfixes: Number(publicRelease.open_hotfixes),
    public_release_onboarded_creators: Number(publicRelease.onboarded_creators),
    security_headers: Boolean(security.security_headers),
    request_id_header: Boolean(security.request_id_header),
    rate_limiting: Boolean(security.rate_limiting),
    rate_limit_requests: Number(security.rate_limit_requests),
    rate_limit_window_ms: Number(security.rate_limit_window_ms),
    privacy_export: Boolean(security.privacy_export),
    account_deletion_revokes_sessions: Boolean(security.account_deletion_revokes_sessions),
    credential_redaction_contract: Boolean(security.credential_redaction_contract),
    backup_restore_runbook: Boolean(security.backup_restore_runbook),
    rollback_runbook: Boolean(security.rollback_runbook),
    auth_enabled: Boolean(identity.auth_enabled),
    sign_in_with_apple_contract: Boolean(identity.sign_in_with_apple_contract),
    development_identity_mode: Boolean(identity.development_identity_mode),
    identity_data_export: Boolean(identity.data_export),
    role_authorization: Boolean(identity.role_authorization),
    creator_draft_sync_enabled: Boolean(publishing.creator_draft_sync_enabled),
    optimistic_concurrency: Boolean(publishing.optimistic_concurrency),
    draft_role_enforcement: Boolean(publishing.role_enforcement),
    admin_review_workflow: Boolean(publishing.admin_review_queue),
    publishing_submit_for_review: Boolean(publishing.submit_for_review),
    publishing_withdraw_submission: Boolean(publishing.withdraw_submission),
    publishing_request_revision: Boolean(publishing.request_revision),
    publishing_approve: Boolean(publishing.approve),
    publishing_reject: Boolean(publishing.reject),
    publishing_schedule: Boolean(publishing.schedule),
    publishing_publish: Boolean(publishing.publish),
    publishing_unpublish: Boolean(publishing.unpublish),
    publishing_archive_reviewed_project: Boolean(publishing.archive_reviewed_project),
    publishing_processing_gate: Boolean(publishing.processing_readiness_gate),
    publishing_rights_gate: Boolean(publishing.rights_readiness_gate),
    catalog_visibility_transaction: Boolean(publishing.catalog_visibility_transaction),
    payments_enabled: true
  };
}

function adminReviewRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(adminReviewDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function socialWatchPartyRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(socialWatchPartyDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function socialWatchInviteRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(socialWatchInviteDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function platformOperationsRoute(path: string, prefix: string): { id: string; action: string | null } {
  const suffix = path.slice(prefix.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function betaRoute(path: string, prefix: string): { id: string; action: string | null } {
  const suffix = path.slice(prefix.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function releaseRoute(path: string, prefix: string): { id: string; action: string | null } {
  const suffix = path.slice(prefix.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function creatorProcessingRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(creatorProcessingJobDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function creatorDraftRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(creatorDraftDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function creatorUploadRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(creatorUploadDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function notificationRoute(path: string): { id: string; action: string | null } {
  const suffix = path.slice(notificationDetailPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return {
    id: parts[0] ?? "",
    action: parts[1] ?? null
  };
}

function routeID(path: string, prefix: string): string {
  return decodeURIComponent(path.slice(prefix.length));
}

function playbackHLSJobID(path: string): string {
  const suffix = path.slice(playbackHLSPath.length);
  const parts = suffix.split("/").filter(Boolean).map(decodeURIComponent);
  return parts[0] ?? "";
}

function authHeader(value: string | string[] | undefined): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function queryValue(rawURL: string | undefined, name: string): string | null {
  if (!rawURL) return null;
  const url = new URL(rawURL, "http://127.0.0.1");
  return url.searchParams.get(name);
}

function territoryFor(rawURL: string | undefined): string {
  return (queryValue(rawURL, "territory") ?? "US").trim().toUpperCase() || "US";
}

function originFor(request: { headers: { host?: string | string[] | undefined } }, config: RuntimeConfig): string {
  const host = authHeader(request.headers.host) ?? `${config.host}:${config.port}`;
  return `http://${host}`;
}
