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
  creatorProcessingJobDetailPath,
  creatorProcessingJobsPath,
  creatorUploadAssetsPath,
  creatorUploadDetailPath,
  creatorUploadSessionsPath,
  entitlementValidationPath,
  identityAppleExchangePath,
  identityAuditPath,
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
  playbackHLSPath,
  playbackDescriptorPath,
  readinessPath,
  viewerLibraryOfflinePath,
  viewerLibraryPath,
  viewerLibraryProgressPath,
  viewerLibrarySavePath
} from "../contracts.js";
import { openAPISpec } from "../catalog/openapi.js";
import { catalogDelta, catalogSummary, catalogSync, collectionDetail, contentDetail, creatorDetail } from "../routes/catalog.js";
import { discoveryQuery, discoveryReadinessSummary } from "../routes/discovery.js";
import {
  createDevelopmentIdentitySession,
  creatorWorkspaceMutation,
  currentIdentitySession,
  exchangeAppleIdentity,
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

export function createStagingHttpTarget(config: RuntimeConfig): Server {
  return createServer(async (request, response) => {
    try {
      const path = request.url?.split("?")[0] ?? "/";

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

      if (path === catalogPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogSummary());
        return;
      }

      if (path === catalogSyncPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, catalogSync(queryValue(request.url, "cursor")));
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
        writeJson(response, 200, operationsSummary(authHeader(request.headers.authorization)));
        return;
      }

      if (path === platformOperationsRightsPath) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, rightsLedger(authHeader(request.headers.authorization)));
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
        writeJson(response, 200, contentDetail(routeID(path, contentDetailPath), undefined, authHeader(request.headers.authorization)));
        return;
      }

      if (path.startsWith(creatorDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, creatorDetail(routeID(path, creatorDetailPath), undefined, authHeader(request.headers.authorization)));
        return;
      }

      if (path.startsWith(collectionDetailPath)) {
        if (request.method !== "GET") {
          const result = methodNotAllowed();
          writeJson(response, result.statusCode, result.body);
          return;
        }
        writeJson(response, 200, collectionDetail(routeID(path, collectionDetailPath), undefined, authHeader(request.headers.authorization)));
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
  const analytics = analyticsReadinessSummary();
  const notifications = notificationReadinessSummary();
  const monetization = monetizationReadinessSummary();
  const operations = operationsReadinessSummary();
  return {
    status: "ready",
    environment: config.backendEnv,
    database_schema: "postgresql_compatible_v1",
    migrations_required: true,
    seed_data_loaded: true,
    catalog_titles: summary.total_titles,
    catalog_creators: summary.total_creators,
    catalog_collections: summary.total_collections,
    catalog_sync_enabled: true,
    delta_sync_enabled: true,
    uploads_enabled: true,
    signed_upload_sessions: Boolean(uploads.signed_upload_sessions),
    local_object_storage: Boolean(uploads.local_object_storage),
    upload_checksum_validation: Boolean(uploads.checksum_validation),
    uploaded_asset_records: Number(uploads.uploaded_assets),
    media_processing_enabled: Boolean(processing.processing_jobs_enabled),
    ffprobe_inspection_contract: Boolean(processing.ffprobe_inspection_contract),
    ffmpeg_processing_contract: Boolean(processing.ffmpeg_processing_contract),
    hls_output_contract: Boolean(processing.hls_output_contract),
    playback_descriptor_resolution: Boolean(processing.playback_descriptor_resolution),
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
    analytics_event_ingestion: Boolean(analytics.event_ingestion),
    analytics_batching: Boolean(analytics.batching),
    analytics_idempotency: Boolean(analytics.idempotency),
    analytics_aggregations: Boolean(analytics.aggregations),
    analytics_events: Number(analytics.event_count),
    notifications_enabled: Boolean(notifications.notifications_enabled),
    apns_contract_ready: Boolean(notifications.apns_contract_ready),
    notification_device_registration: Boolean(notifications.device_registration),
    notification_preferences: Boolean(notifications.preferences),
    notification_inbox: Boolean(notifications.inbox),
    notification_deep_links: Boolean(notifications.deep_links),
    notification_delivery_audit: Boolean(notifications.delivery_audit),
    notification_registered_devices: Number(notifications.registered_devices),
    notification_inbox_items: Number(notifications.inbox_items),
    external_push_attempted: Boolean(notifications.external_push_attempted),
    storekit2_products: Boolean(monetization.storekit2_products),
    storekit_purchase_recording: Boolean(monetization.purchase_recording),
    storekit_restore_supported: Boolean(monetization.restore_supported),
    storekit_revocation_supported: Boolean(monetization.revocation_supported),
    backend_entitlement_records: Boolean(monetization.backend_entitlement_records),
    app_store_server_api_contract: Boolean(monetization.app_store_server_api_contract),
    direct_card_collection: Boolean(monetization.direct_card_collection),
    active_entitlements: Number(monetization.active_entitlements),
    transaction_records: Number(monetization.transaction_records),
    rights_windows_enabled: Boolean(operations.rights_windows),
    territory_enforcement_enabled: Boolean(operations.territory_enforcement),
    availability_enforcement_enabled: Boolean(operations.availability_enforcement),
    moderation_queue_enabled: Boolean(operations.moderation_queue),
    takedown_supported: Boolean(operations.takedown_supported),
    operations_audit_trail: Boolean(operations.audit_trail),
    operations_admin_role_enforcement: Boolean(operations.admin_role_enforcement),
    auth_enabled: Boolean(identity.auth_enabled),
    sign_in_with_apple_contract: Boolean(identity.sign_in_with_apple_contract),
    development_identity_mode: Boolean(identity.development_identity_mode),
    role_authorization: Boolean(identity.role_authorization),
    creator_draft_sync_enabled: Boolean(publishing.creator_draft_sync_enabled),
    optimistic_concurrency: Boolean(publishing.optimistic_concurrency),
    draft_role_enforcement: Boolean(publishing.role_enforcement),
    admin_review_workflow: Boolean(publishing.admin_review_queue),
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

function platformOperationsRoute(path: string, prefix: string): { id: string; action: string | null } {
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

function originFor(request: { headers: { host?: string | string[] | undefined } }, config: RuntimeConfig): string {
  const host = authHeader(request.headers.host) ?? `${config.host}:${config.port}`;
  return `http://${host}`;
}
