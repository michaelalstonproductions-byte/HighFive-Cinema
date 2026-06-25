import Foundation
import Combine
import CryptoKit
import AVFoundation
import ImageIO
import SQLite3

struct HFLocalViewingProfile: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var role: String
    var avatarSymbol: String
    var accentName: String
}

enum HFIdentitySessionRuntimeState: String, Hashable {
    case localActive = "Local Active"
    case switchingProfile = "Switching Profile"
    case needsLocalProfile = "Needs Local Profile"

    var statusLabel: String { rawValue }
}

struct HFIdentitySessionRuntimeSnapshot: Hashable {
    var state: HFIdentitySessionRuntimeState
    var activeProfileID: String
    var displayName: String
    var viewerRole: String
    var avatarSymbol: String
    var creatorName: String
    var creatorRole: String
    var workspaceID: String
    var workspaceTitle: String
    var workspaceScope: String
    var permissionSummary: String
    var sessionMode: String
    var reason: String
    var updatedAtLabel: String

    var statusLabel: String {
        state.statusLabel
    }

    var detail: String {
        "\(displayName) is working in \(workspaceTitle) as \(viewerRole). \(permissionSummary)"
    }

    static var empty: HFIdentitySessionRuntimeSnapshot {
        HFIdentitySessionRuntimeSnapshot(
            state: .needsLocalProfile,
            activeProfileID: "none",
            displayName: "Local Viewer",
            viewerRole: "Viewer",
            avatarSymbol: "person.crop.circle.fill",
            creatorName: "HighFive Creator",
            creatorRole: "Creator",
            workspaceID: "local-watch",
            workspaceTitle: "Watch Workspace",
            workspaceScope: "Local preview",
            permissionSummary: "Read-only local preview",
            sessionMode: "Local Session",
            reason: "Waiting for local profile",
            updatedAtLabel: "Not loaded"
        )
    }
}

struct HFSessionPermissionRecord: Identifiable, Hashable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFWorkspaceSessionRecord: Identifiable, Hashable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

enum HFPlaybackSourceStatus: Equatable {
    case playableLocal
    case sourceNotConnected
}

struct HFPlaybackSource: Equatable {
    let movieID: String
    let title: String
    let status: HFPlaybackSourceStatus
    let localURL: URL?
    let providerName: String
    let readinessLabel: String
    let limitation: String
}

enum HFCloudSyncStatus {
    case localOnly
    case cloudReady
    case cloudNotConnected
}

enum HFOfflineAssetStatus {
    case eligible
    case queued
    case localStateOnly
    case sourceRequired
    case providerNotConnected
}

struct HFOfflineAssetRecord: Identifiable, Codable, Equatable {
    let id: String
    let movieID: String
    var title: String
    var status: String
    var detail: String
    var updatedAtLabel: String
}

struct HFDownloadQueueItem: Identifiable, Codable, Equatable {
    let id: String
    let movieID: String
    var title: String
    var status: String
    var reason: String
}

enum HFCommunicationProviderStatus {
    case localAdapterActive
    case remoteProviderNotConnected
}

enum HFCommunicationUpdateStatus: String, Codable, Equatable {
    case draft = "Draft"
    case preview = "Preview"
    case ready = "Ready"
    case notSent = "Not Sent"
}

struct HFAudienceChannel: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var purpose: String
    var status: String
    var systemImage: String
}

struct HFAudienceUpdateRecord: Identifiable, Codable, Equatable {
    let id: String
    var channelID: String
    var movieID: String
    var authorProfileID: String
    var body: String
    var status: String
    var safetyLabel: String
    var updatedAtLabel: String
}

struct HFCommunicationReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

enum HFLaunchCampaignProviderStatus {
    case localAdapterActive
    case remoteProviderNotConnected
}

enum HFLaunchMilestoneStatus: String, Codable, Equatable {
    case draft = "Draft"
    case ready = "Ready"
    case localReview = "Local Review"
    case notPublished = "Not Published"
}

struct HFLaunchCampaignRecord: Identifiable, Codable, Equatable {
    let id: String
    var movieID: String
    var title: String
    var audience: String
    var status: String
    var providerStatus: String
    var updatedAtLabel: String
}

struct HFLaunchMilestoneRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFLaunchChannelRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var purpose: String
    var status: String
    var systemImage: String
}

struct HFLaunchCampaignReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

enum HFCreatorReleaseState: String, CaseIterable, Codable, Equatable {
    case draft = "Draft"
    case review = "Review"
    case scheduled = "Scheduled"
    case published = "Published"
    case archived = "Archived"
}

enum HFCreatorPublishingAssetStatus: String, CaseIterable, Codable, Equatable {
    case missing = "Missing"
    case placeholder = "Placeholder"
    case ready = "Ready"
    case needsReview = "Needs Review"
}

extension HFCreatorReleaseState {
    init(remoteRawValue: String) {
        switch remoteRawValue.lowercased() {
        case "review": self = .review
        case "scheduled": self = .scheduled
        case "published": self = .published
        case "archived": self = .archived
        default: self = .draft
        }
    }
}

extension HFCreatorPublishingAssetStatus {
    init(remoteRawValue: String) {
        switch remoteRawValue.lowercased().replacingOccurrences(of: "_", with: " ") {
        case "missing": self = .missing
        case "ready": self = .ready
        case "needs review": self = .needsReview
        default: self = .placeholder
        }
    }

    var remoteRawValue: String {
        switch self {
        case .missing: return "missing"
        case .placeholder: return "placeholder"
        case .ready: return "ready"
        case .needsReview: return "needs_review"
        }
    }
}

struct HFCreatorPublishingContent: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var description: String
    var posterAssetName: String?
    var trailerStatus: HFCreatorPublishingAssetStatus
    var creator: String
    var genre: String
    var tags: [String]
    var runtime: String
    var releaseState: HFCreatorReleaseState
    var posterStatus: HFCreatorPublishingAssetStatus
    var metadataStatus: HFCreatorPublishingAssetStatus
    var artworkStatus: HFCreatorPublishingAssetStatus
    var updatedAtLabel: String

    var readyForReview: Bool {
        [posterStatus, trailerStatus, metadataStatus, artworkStatus].allSatisfy { $0 == .ready || $0 == .needsReview }
            && releaseState != .archived
    }

    var discoveryEligible: Bool {
        releaseState == .published
    }

    var movie: Movie {
        Movie(
            id: id,
            title: title,
            subtitle: releaseState == .published ? "Creator published title" : "\(releaseState.rawValue) creator project",
            synopsis: description,
            year: "2026",
            rating: "TV-14",
            duration: runtime,
            genres: Array(Set([genre, "Creator"].filter { !$0.isEmpty } + tags)).sorted(),
            posterAssetName: posterAssetName,
            backdropAssetName: posterAssetName,
            creatorName: creator,
            isOriginal: true,
            isComingSoon: releaseState != .published,
            isDownloaded: false,
            progress: releaseState == .published ? nil : 0.12
        )
    }
}

enum HFCreatorMediaAssetKind: String, CaseIterable, Identifiable, Codable {
    case poster = "Poster"
    case trailer = "Trailer"
    case artwork = "Artwork"
    case metadata = "Metadata"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .poster: return "photo.fill.on.rectangle.fill"
        case .trailer: return "film.stack.fill"
        case .artwork: return "rectangle.stack.fill"
        case .metadata: return "text.justify.left"
        }
    }
}

struct HFCreatorMediaAssetRecord: Identifiable, Hashable {
    let id: String
    var projectID: String
    var projectTitle: String
    var kind: HFCreatorMediaAssetKind
    var status: HFCreatorPublishingAssetStatus
    var registry: String
    var lifecycle: String
    var readiness: String
    var detail: String
    var systemImage: String
}

struct HFCreatorMediaAssetRuntimeSnapshot: Hashable {
    var totalAssets: Int
    var readyAssets: Int
    var needsReviewAssets: Int
    var placeholderAssets: Int
    var missingAssets: Int
    var posterAssets: Int
    var trailerAssets: Int
    var artworkAssets: Int
    var metadataAssets: Int
    var updatedAtLabel: String

    var readinessLabel: String {
        "\(readyAssets)/\(totalAssets) Ready"
    }

    var detail: String {
        "\(posterAssets) poster, \(trailerAssets) trailer, \(artworkAssets) artwork, \(metadataAssets) metadata registry records"
    }

    static var empty: HFCreatorMediaAssetRuntimeSnapshot {
        HFCreatorMediaAssetRuntimeSnapshot(
            totalAssets: 0,
            readyAssets: 0,
            needsReviewAssets: 0,
            placeholderAssets: 0,
            missingAssets: 0,
            posterAssets: 0,
            trailerAssets: 0,
            artworkAssets: 0,
            metadataAssets: 0,
            updatedAtLabel: "No asset registry loaded"
        )
    }
}

struct HFCreatorUploadWorkflowSnapshot: Hashable {
    var projectCount: Int
    var selectedAssets: Int
    var validAssets: Int
    var manifestItems: Int
    var queueItems: Int
    var preflightPassed: Int
    var blockers: Int
    var updatedAtLabel: String

    var readinessLabel: String {
        "\(preflightPassed)/\(queueItems) Clear"
    }
}

struct HFCreatorUploadSelectionRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var assetKind: HFCreatorMediaAssetKind
    var selectionState: String
    var source: String
    var detail: String
    var systemImage: String
}

struct HFCreatorUploadValidationRecord: Identifiable, Hashable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var isBlocking: Bool
    var systemImage: String
}

struct HFCreatorUploadManifestRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var manifestID: String
    var assetCount: Int
    var packageState: String
    var detail: String
    var systemImage: String
}

struct HFCreatorUploadQueueRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var queueState: String
    var readiness: String
    var nextStep: String
    var detail: String
    var systemImage: String
}

struct HFCreatorUploadPreflightRecord: Identifiable, Hashable {
    let id: String
    var title: String
    var detail: String
    var result: String
    var isPassed: Bool
    var systemImage: String
}

struct HFCreatorProjectRuntimeSnapshot: Hashable {
    var projectCount: Int
    var manifestCount: Int
    var assetManifestCount: Int
    var validationPassed: Int
    var releasePackages: Int
    var timelineEvents: Int
    var updatedAtLabel: String

    var readinessLabel: String {
        "\(validationPassed)/\(projectCount) Valid"
    }
}

struct HFCreatorProjectManifestRecord: Identifiable, Hashable {
    let id: String
    var projectID: String
    var creatorID: String
    var contentID: String
    var version: String
    var created: String
    var modified: String
    var status: String
    var title: String
    var detail: String
    var systemImage: String
}

struct HFCreatorProjectAssetManifestRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var posterState: String
    var trailerState: String
    var artworkState: String
    var metadataState: String
    var thumbnailState: String
    var detail: String
    var systemImage: String
}

struct HFCreatorProjectValidationRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var metadataComplete: Bool
    var posterReady: Bool
    var trailerReady: Bool
    var artworkReady: Bool
    var publishingReady: Bool
    var releaseReady: Bool
    var status: String
    var detail: String
    var systemImage: String
}

struct HFCreatorProjectReleasePackageRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var releaseManifest: String
    var publishingSummary: String
    var assetSummary: String
    var runtimeSummary: String
    var creatorSummary: String
    var status: String
    var systemImage: String
}

struct HFCreatorProjectTimelineRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var event: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFCreatorMediaImportRuntimeSnapshot: Hashable {
    var sessionCount: Int
    var queueCount: Int
    var registeredAssets: Int
    var manifestUpdates: Int
    var linkedProjects: Int
    var preflightPassed: Int
    var updatedAtLabel: String

    var readinessLabel: String {
        "\(preflightPassed)/5 Clear"
    }
}

struct HFCreatorMediaImportSessionRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var sessionState: String
    var intakeScope: String
    var assetCount: Int
    var detail: String
    var systemImage: String
}

struct HFCreatorMediaImportQueueRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var assetTitle: String
    var queueState: String
    var source: String
    var detail: String
    var systemImage: String
}

struct HFCreatorMediaImportValidationRecord: Identifiable, Hashable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var isPassed: Bool
    var systemImage: String
}

struct HFCreatorMediaRegistrationRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var registry: String
    var registrationState: String
    var linkedManifest: String
    var detail: String
    var systemImage: String
}

struct HFCreatorManifestUpdateRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var manifestID: String
    var updateState: String
    var assetSummary: String
    var detail: String
    var systemImage: String
}

struct HFCreatorProjectLinkRecord: Identifiable, Hashable {
    let id: String
    var projectTitle: String
    var projectID: String
    var contentID: String
    var linkedAssets: Int
    var status: String
    var detail: String
    var systemImage: String
}

struct HFCreatorMediaImportPreflightRecord: Identifiable, Hashable {
    let id: String
    var title: String
    var detail: String
    var result: String
    var isPassed: Bool
    var systemImage: String
}

enum HFCreatorLocalImportStatus: String, Codable, Equatable, Hashable {
    case queued = "Queued"
    case importing = "Importing"
    case imported = "Imported"
    case duplicate = "Duplicate"
    case cancelled = "Cancelled"
    case failed = "Failed"
    case quarantined = "Quarantined"
}

enum HFCreatorMediaInspectionState: String, Codable, Equatable, Hashable {
    case accepted = "Accepted"
    case warning = "Warning"
    case blocked = "Blocked"
    case quarantined = "Quarantined"
}

struct HFCreatorImportedMediaAsset: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var projectID: String
    var projectTitle: String
    var kind: HFCreatorMediaAssetKind
    var originalFilename: String
    var storedRelativePath: String
    var contentType: String
    var byteCount: Int
    var checksum: String
    var status: HFCreatorLocalImportStatus
    var progress: Double
    var importedAtLabel: String
    var history: [String]

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: Int64(byteCount), countStyle: .file)
    }
}

struct HFCreatorLocalImportResult: Equatable {
    var asset: HFCreatorImportedMediaAsset
    var isDuplicate: Bool
    var message: String
}

struct HFCreatorLocalReleasePackageRecord: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var projectID: String
    var projectTitle: String
    var packageVersion: String
    var packageRelativePath: String
    var exportManifestRelativePath: String
    var checksum: String
    var manifestStatus: String
    var validationStatus: String
    var createdAtLabel: String
    var history: [String]

    var shortChecksum: String {
        String(checksum.prefix(12))
    }
}

struct HFCreatorLocalReleasePackageManifest: Codable, Equatable {
    var packageID: String
    var packageVersion: String
    var createdAtLabel: String
    var project: HFCreatorReleaseProjectManifest
    var assets: [HFCreatorReleaseAssetManifest]
    var validation: [HFCreatorReleaseValidationReport]
    var rights: HFCreatorReleaseRightsMetadata
    var creator: HFCreatorReleaseCreatorMetadata
    var relationships: [String]
}

struct HFCreatorReleaseProjectManifest: Codable, Equatable {
    var projectID: String
    var creatorID: String
    var contentID: String
    var title: String
    var description: String
    var genre: String
    var tags: [String]
    var runtime: String
    var releaseState: String
}

struct HFCreatorReleaseAssetManifest: Codable, Equatable {
    var assetID: String
    var kind: String
    var filename: String
    var relativePath: String
    var checksum: String
    var fileSizeBytes: Int
    var inspectionState: String
    var technicalSummary: String
}

struct HFCreatorReleaseValidationReport: Codable, Equatable {
    var gate: String
    var status: String
    var detail: String
    var isPassing: Bool
}

struct HFCreatorReleaseRightsMetadata: Codable, Equatable {
    var rightsState: String
    var territoryPreview: String
    var clearanceState: String
    var notes: String
}

struct HFCreatorReleaseCreatorMetadata: Codable, Equatable {
    var creatorID: String
    var creatorName: String
    var workspace: String
}

struct HFCreatorMediaInspectionRecord: Identifiable, Codable, Equatable, Hashable {
    let id: String
    var assetID: String
    var projectID: String
    var projectTitle: String
    var kind: HFCreatorMediaAssetKind
    var originalFilename: String
    var fileSizeBytes: Int
    var durationLabel: String
    var dimensionsLabel: String
    var aspectRatioLabel: String
    var frameRateLabel: String
    var videoCodec: String
    var audioCodec: String
    var audioChannelCount: Int
    var hasVideoTrack: Bool
    var hasAudioTrack: Bool
    var posterDimensionsLabel: String
    var state: HFCreatorMediaInspectionState
    var warning: String
    var blockingIssue: String
    var inspectedAtLabel: String
    var isQuarantined: Bool

    var fileSizeLabel: String {
        ByteCountFormatter.string(fromByteCount: Int64(fileSizeBytes), countStyle: .file)
    }

    var summary: String {
        "\(fileSizeLabel). \(dimensionsLabel). \(durationLabel). \(videoCodec) / \(audioCodec)."
    }
}

struct HFCreatorDraftValidationItem: Identifiable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var isComplete: Bool
    var systemImage: String
}

struct HFCreatorDraftCompareRecord: Identifiable {
    let id: String
    var field: String
    var savedValue: String
    var editorValue: String
    var state: String
    var systemImage: String
}

struct HFCreatorDraftHistoryRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFCreatorProfile: Identifiable {
    let creator: Creator
    let bio: String
    let bannerTitle: String
    let avatarSymbol: String
    let filmography: [Movie]
    let publishedTitles: [Movie]
    let scheduledTitles: [Movie]
    let archivedTitles: [Movie]
    let collections: [Category]
    let featuredProject: Movie?
    let latestRelease: Movie?

    var id: String { creator.id }
}

enum HFCMSContentType: String, CaseIterable, Identifiable {
    case movie = "Movie"
    case series = "Series"
    case episode = "Episode"
    case trailer = "Trailer"
    case collection = "Collection"
    case creator = "Creator"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .movie: return "film.stack.fill"
        case .series: return "rectangle.stack.fill"
        case .episode: return "play.square.stack.fill"
        case .trailer: return "play.rectangle.fill"
        case .collection: return "rectangle.grid.2x2.fill"
        case .creator: return "person.crop.rectangle.stack.fill"
        }
    }
}

struct HFCMSContentRecord: Identifiable {
    let id: String
    var title: String
    var type: HFCMSContentType
    var description: String
    var creatorName: String
    var genre: String
    var tags: [String]
    var runtime: String
    var rating: String
    var artworkStatus: HFCreatorPublishingAssetStatus
    var trailerStatus: HFCreatorPublishingAssetStatus
    var releaseState: HFCreatorReleaseState
    var collectionIDs: [String]
    var seriesID: String?
    var relatedTitleIDs: [String]
}

struct HFCMSCollectionRecord: Identifiable {
    let id: String
    var title: String
    var description: String
    var movieIDs: [String]
}

struct HFCMSRelationshipRecord: Identifiable {
    let id: String
    var source: String
    var target: String
    var relationship: String
    var detail: String
}

struct HFCMSStatusCount: Identifiable {
    let state: HFCreatorReleaseState
    var count: Int

    var id: String { state.rawValue }
}

struct HFLibraryActivityRecord: Identifiable {
    let id: String
    var movie: Movie
    var status: String
    var detail: String
    var progress: Double?
}

struct HFLibraryCollection: Identifiable {
    let id: String
    var title: String
    var detail: String
    var movies: [Movie]
    var systemImage: String
}

struct HFLibraryNextEpisode: Identifiable {
    let id: String
    var series: Movie
    var title: String
    var detail: String
}

struct HFLibraryIntelligenceSignal: Identifiable {
    let id: String
    var title: String
    var detail: String
    var value: String
    var systemImage: String
}

struct HFAnalyticsMetric: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var systemImage: String
}

struct HFTitleAnalyticsRecord: Identifiable {
    let id: String
    var movie: Movie
    var totalViews: Int
    var averageWatchTime: String
    var completionRate: Int
    var libraryAdds: Int
    var favorites: Int
    var sharesPlaceholder: Int
}

struct HFDiscoveryAnalyticsRecord: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var systemImage: String
}

struct HFCreatorAnalyticsRecord: Identifiable {
    let id: String
    var creatorName: String
    var publishedTitles: Int
    var views: Int
    var watchTime: String
    var followers: Int
    var growthTrend: String
    var topContent: String
}

struct HFAnalyticsInsight: Identifiable {
    let id: String
    var title: String
    var detail: String
    var value: String
    var systemImage: String
}

struct HFRevenueMetric: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var systemImage: String
}

struct HFTitleRevenueRecord: Identifiable {
    let id: String
    var movie: Movie
    var estimatedRevenue: String
    var streamingRevenue: String
    var premiumRevenue: String
    var collectionRevenue: String
    var revenuePerView: String
    var views: Int
    var watchTime: String
    var completionRate: Int
    var growthLabel: String
}

struct HFCreatorRevenueSummary: Identifiable {
    let id: String
    var creatorName: String
    var estimatedRevenue: String
    var projectedRevenue: String
    var lifetimePreview: String
    var topTitle: String
    var titleCount: Int
    var growthLabel: String
}

struct HFRevenueInsight: Identifiable {
    let id: String
    var title: String
    var detail: String
    var value: String
    var systemImage: String
}

struct HFPayoutPreviewRecord: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var state: String
    var systemImage: String
}

struct HFProductNotificationRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var category: String
    var status: String
    var timeLabel: String
    var systemImage: String
}

struct HFActivityCenterRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var value: String
    var status: String
    var systemImage: String
}

struct HFContentReviewRecord: Identifiable {
    let id: String
    var title: String
    var creatorName: String
    var status: String
    var detail: String
    var reviewState: String
    var systemImage: String
}

struct HFCreatorAdministrationRecord: Identifiable {
    let id: String
    var creatorName: String
    var creatorStatus: String
    var publishingStatus: String
    var profileStatus: String
    var verificationPreview: String
    var titleCount: Int
}

struct HFPlatformHealthRecord: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFModerationQueueRecord: Identifiable {
    let id: String
    var title: String
    var category: String
    var policyStatus: String
    var reviewState: String
    var detail: String
    var systemImage: String
}

struct HFAuditTrailRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var category: String
    var timeLabel: String
    var result: String
    var systemImage: String
}

struct HFMarketplaceCatalogRecord: Identifiable {
    let id: String
    var title: String
    var creatorName: String
    var packageType: String
    var readiness: String
    var rightsSummary: String
    var revenuePreview: String
    var distributionState: String
    var systemImage: String
}

struct HFDistributionTargetRecord: Identifiable {
    let id: String
    var title: String
    var purpose: String
    var readiness: String
    var boundary: String
    var systemImage: String
}

struct HFRightsPackageRecord: Identifiable {
    let id: String
    var title: String
    var creatorName: String
    var rightsWindow: String
    var territoryPreview: String
    var clearanceState: String
    var systemImage: String
}

struct HFReleasePackageRecord: Identifiable {
    let id: String
    var title: String
    var assets: String
    var publishingState: String
    var marketplaceState: String
    var nextStep: String
    var systemImage: String
}

struct HFLicensingPreviewRecord: Identifiable {
    let id: String
    var title: String
    var packageScope: String
    var estimatePreview: String
    var rightsState: String
    var planningNote: String
    var systemImage: String
}

struct HFDistributionReadinessRecord: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFRightsLedgerRecord: Identifiable {
    let id: String
    var title: String
    var creatorName: String
    var ledgerState: String
    var rightsWindow: String
    var territory: String
    var clearance: String
    var systemImage: String
}

struct HFRightsWindowRecord: Identifiable {
    let id: String
    var title: String
    var window: String
    var packageScope: String
    var status: String
    var detail: String
    var systemImage: String
}

struct HFTerritoryTrackingRecord: Identifiable {
    let id: String
    var title: String
    var region: String
    var availabilityPreview: String
    var packageCount: Int
    var status: String
    var systemImage: String
}

struct HFClearanceTrackingRecord: Identifiable {
    let id: String
    var title: String
    var area: String
    var state: String
    var detail: String
    var systemImage: String
}

struct HFLicensingPackageRecord: Identifiable {
    let id: String
    var title: String
    var scope: String
    var estimatePreview: String
    var readiness: String
    var nextStep: String
    var systemImage: String
}

struct HFRightsReadinessRecord: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFDealPreparationRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var readiness: String
    var source: String
    var systemImage: String
}

struct HFServiceRegistryRecord: Identifiable {
    let id: String
    var title: String
    var productArea: String
    var readiness: String
    var dependency: String
    var boundary: String
    var systemImage: String
}

struct HFDataSourceRegistryRecord: Identifiable {
    let id: String
    var title: String
    var sourceType: String
    var owner: String
    var state: String
    var detail: String
    var systemImage: String
}

struct HFSyncReadinessRecord: Identifiable {
    let id: String
    var title: String
    var localCount: String
    var readiness: String
    var detail: String
    var systemImage: String
}

struct HFAPIReadinessRecord: Identifiable {
    let id: String
    var title: String
    var shapeState: String
    var requestShape: String
    var responseShape: String
    var boundary: String
    var systemImage: String
}

struct HFEnvironmentProfileRecord: Identifiable {
    let id: String
    var title: String
    var profile: String
    var services: String
    var dataPolicy: String
    var status: String
    var systemImage: String
}

struct HFIntegrationAuditRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var result: String
    var category: String
    var systemImage: String
}

struct HFProductionConnectionRecord: Identifiable {
    let id: String
    var title: String
    var domain: String
    var readiness: String
    var handoff: String
    var boundary: String
    var systemImage: String
}

struct HFProductionFeatureFlagRecord: Identifiable {
    let id: String
    var title: String
    var scope: String
    var defaultState: String
    var rolloutNote: String
    var boundary: String
    var systemImage: String
}

struct HFProductionServiceMappingRecord: Identifiable {
    let id: String
    var title: String
    var localSystem: String
    var futureSystem: String
    var mappingState: String
    var dependency: String
    var systemImage: String
}

struct HFProductionEnvironmentSwitchRecord: Identifiable {
    let id: String
    var title: String
    var mode: String
    var availability: String
    var guardrail: String
    var notes: String
    var systemImage: String
}

struct HFProductionReadinessReportRecord: Identifiable {
    let id: String
    var title: String
    var score: String
    var state: String
    var summary: String
    var nextStep: String
    var systemImage: String
}

struct HFProductionDependencyGraphRecord: Identifiable {
    let id: String
    var title: String
    var upstream: String
    var downstream: String
    var readiness: String
    var blocker: String
    var systemImage: String
}

struct HFCreatorPublishingQueueRecord: Identifiable {
    let id: String
    var project: HFCreatorPublishingContent
    var priority: String
    var stage: String
    var nextStep: String
    var owner: String
}

struct HFCreatorPublishingReadinessItem: Identifiable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFCreatorPublishingScheduleItem: Identifiable {
    let id: String
    var title: String
    var window: String
    var status: String
    var detail: String
}

struct HFCreatorPublishingAuditRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var result: String
    var systemImage: String
}

struct HFCreatorPublishingChecklistItem: Identifiable {
    let id: String
    var title: String
    var status: String
    var detail: String
}

struct HFCreatorCollaboratorRecord: Identifiable {
    let id: String
    var name: String
    var role: String
    var permissionScope: String
    var focus: String
    var systemImage: String
}

struct HFCreatorProjectTeamRecord: Identifiable {
    let id: String
    var project: HFCreatorPublishingContent
    var owner: String
    var collaborators: [HFCreatorCollaboratorRecord]
    var status: String
    var permissionSummary: String
}

struct HFCreatorCollaborationTaskRecord: Identifiable {
    let id: String
    var title: String
    var projectTitle: String
    var assigneeRole: String
    var status: String
    var detail: String
    var systemImage: String
}

struct HFCreatorCollaborationNoteRecord: Identifiable {
    let id: String
    var title: String
    var projectTitle: String
    var authorRole: String
    var detail: String
    var noteType: String
}

struct HFCreatorCollaborationActivityRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var actorRole: String
    var timeLabel: String
    var systemImage: String
}

struct HFCreatorCollaborationTimelineRecord: Identifiable {
    let id: String
    var title: String
    var detail: String
    var stage: String
    var status: String
    var systemImage: String
}

struct HFEpisodeRecord: Identifiable, Codable, Equatable {
    let id: String
    var seriesID: String
    var seasonNumber: Int
    var episodeNumber: Int
    var title: String
    var synopsis: String
    var runtime: String
    var artworkStatus: HFCreatorPublishingAssetStatus
    var releaseState: HFCreatorReleaseState
    var progress: Double?
}

struct HFSeasonRecord: Identifiable, Codable, Equatable {
    let id: String
    var seriesID: String
    var seasonNumber: Int
    var title: String
    var episodes: [HFEpisodeRecord]
}

struct HFSeriesRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var synopsis: String
    var creatorName: String
    var genre: String
    var status: HFCreatorReleaseState
    var seasons: [HFSeasonRecord]
    var heroMovie: Movie

    var episodeCount: Int {
        seasons.reduce(0) { $0 + $1.episodes.count }
    }
}

struct HFNextEpisodeRecommendation: Identifiable {
    let id: String
    var seriesTitle: String
    var seasonNumber: Int
    var episodeNumber: Int
    var title: String
    var detail: String
    var progressLabel: String
}

struct HFEpisodeAnalyticsRecord: Identifiable {
    let id: String
    var seriesTitle: String
    var episodeTitle: String
    var views: Int
    var completionRate: Int
    var dropOffPoint: String
    var watchTime: String
}

enum HFExportDeliveryProviderStatus {
    case localAdapterActive
    case remoteProviderNotConnected
}

enum HFDeliveryPackageStatus: String, Codable, Equatable {
    case draft = "Draft"
    case localReview = "Local Review"
    case ready = "Ready"
    case notSubmitted = "Not Submitted"
}

struct HFDeliveryPackageRecord: Identifiable, Codable, Equatable {
    let id: String
    var movieID: String
    var title: String
    var ownerProfileID: String
    var summary: String
    var status: String
    var providerStatus: String
    var updatedAtLabel: String
}

struct HFDeliveryRequirementRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFDistributionHandoffRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFExportDeliveryReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

enum HFPaymentProviderStatus: String, Codable, Equatable {
    case localAdapterActive
    case remoteProviderNotConnected

    var statusLabel: String {
        switch self {
        case .localAdapterActive:
            return "Local Preview Access"
        case .remoteProviderNotConnected:
            return "Payment Provider Not Connected Yet"
        }
    }
}

enum HFEntitlementStatus: String, Codable, Equatable {
    case localPreview = "Local Preview Access"
    case included = "Included"
    case providerRequired = "Provider Required"
    case notValidated = "Not Validated"
}

struct HFAccessTierRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFEntitlementRecord: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var scope: String
    var status: String
    var detail: String
    var systemImage: String
}

struct HFPaymentReadinessRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFContentBackendSnapshot: Codable, Equatable {
    var movies: [Movie]
    var creators: [Creator]
    var series: [HFSeriesRecord]
    var collections: [Category]
    var publishingProjects: [HFCreatorPublishingContent]
    var importedMediaAssets: [HFCreatorImportedMediaAsset]
    var mediaInspectionRecords: [HFCreatorMediaInspectionRecord]
    var localReleasePackages: [HFCreatorLocalReleasePackageRecord]
    var updatedAtLabel: String

    var titleCount: Int { movies.count }
    var creatorCount: Int { creators.count }
    var episodeCount: Int { series.reduce(0) { $0 + $1.episodeCount } }
    var collectionCount: Int { collections.count }
    var draftCount: Int { publishingProjects.filter { $0.releaseState == .draft }.count }

    init(
        movies: [Movie],
        creators: [Creator],
        series: [HFSeriesRecord],
        collections: [Category],
        publishingProjects: [HFCreatorPublishingContent],
        importedMediaAssets: [HFCreatorImportedMediaAsset] = [],
        mediaInspectionRecords: [HFCreatorMediaInspectionRecord] = [],
        localReleasePackages: [HFCreatorLocalReleasePackageRecord] = [],
        updatedAtLabel: String
    ) {
        self.movies = movies
        self.creators = creators
        self.series = series
        self.collections = collections
        self.publishingProjects = publishingProjects
        self.importedMediaAssets = importedMediaAssets
        self.mediaInspectionRecords = mediaInspectionRecords
        self.localReleasePackages = localReleasePackages
        self.updatedAtLabel = updatedAtLabel
    }

    private enum CodingKeys: String, CodingKey {
        case movies
        case creators
        case series
        case collections
        case publishingProjects
        case importedMediaAssets
        case mediaInspectionRecords
        case localReleasePackages
        case updatedAtLabel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        movies = try container.decode([Movie].self, forKey: .movies)
        creators = try container.decode([Creator].self, forKey: .creators)
        series = try container.decode([HFSeriesRecord].self, forKey: .series)
        collections = try container.decode([Category].self, forKey: .collections)
        publishingProjects = try container.decode([HFCreatorPublishingContent].self, forKey: .publishingProjects)
        importedMediaAssets = try container.decodeIfPresent([HFCreatorImportedMediaAsset].self, forKey: .importedMediaAssets) ?? []
        mediaInspectionRecords = try container.decodeIfPresent([HFCreatorMediaInspectionRecord].self, forKey: .mediaInspectionRecords) ?? []
        localReleasePackages = try container.decodeIfPresent([HFCreatorLocalReleasePackageRecord].self, forKey: .localReleasePackages) ?? []
        updatedAtLabel = try container.decode(String.self, forKey: .updatedAtLabel)
    }
}

struct HFContentDatabaseHealth: Equatable {
    var schemaVersion: Int
    var storageKind: String
    var databasePath: String
    var migrationState: String
    var lastError: String?
    var recordCounts: [String: Int]
    var updatedAtLabel: String

    var totalRecords: Int {
        recordCounts.values.reduce(0, +)
    }
}

private struct HFContentDatabaseRecordEnvelope: Codable {
    var id: String
    var type: String
    var payload: Data
}

struct HFContentRepositoryMetric: Identifiable {
    let id: String
    var title: String
    var value: String
    var detail: String
    var systemImage: String
}

struct HFContentRelationshipRecord: Identifiable {
    let id: String
    var title: String
    var source: String
    var target: String
    var state: String
    var systemImage: String
}

private struct HFContentStorageLayer {
    private let defaults: UserDefaults
    private let snapshotKey = "hf.contentBackend.snapshot.v1"
    private let schemaVersion = 1
    private let sqliteTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    private var databaseURL: URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return baseURL
            .appendingPathComponent("HighFiveCinema", isDirectory: true)
            .appendingPathComponent("ContentDatabase", isDirectory: true)
            .appendingPathComponent("highfive_content.sqlite3", isDirectory: false)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSnapshot(seed: HFContentBackendSnapshot) -> HFContentBackendSnapshot {
        do {
            let database = try openDatabase()
            defer { sqlite3_close(database) }
            try ensureSchema(database)

            if let stored = try readSnapshot(database) {
                return stored
            }

            let migrated = loadLegacySnapshot() ?? seed
            try writeSnapshot(migrated, database: database, migrationState: loadLegacySnapshot() == nil ? "Seeded durable database" : "Migrated from UserDefaults snapshot")
            return migrated
        } catch {
            return loadLegacySnapshot() ?? seed
        }
    }

    func saveSnapshot(_ snapshot: HFContentBackendSnapshot) {
        do {
            let database = try openDatabase()
            defer { sqlite3_close(database) }
            try ensureSchema(database)
            try writeSnapshot(snapshot, database: database, migrationState: "Stored in durable local database")
        } catch {
            return
        }
    }

    func healthCheck() -> HFContentDatabaseHealth {
        do {
            let database = try openDatabase()
            defer { sqlite3_close(database) }
            try ensureSchema(database)
            return HFContentDatabaseHealth(
                schemaVersion: schemaVersion,
                storageKind: "SQLite",
                databasePath: databaseURL.path,
                migrationState: try metadataValue("migration_state", database: database) ?? "Ready",
                lastError: nil,
                recordCounts: try recordCounts(database),
                updatedAtLabel: try metadataValue("updated_at", database: database) ?? "No durable write yet"
            )
        } catch {
            return HFContentDatabaseHealth(
                schemaVersion: schemaVersion,
                storageKind: "SQLite",
                databasePath: databaseURL.path,
                migrationState: "Unavailable",
                lastError: String(describing: error),
                recordCounts: [:],
                updatedAtLabel: "Database health check failed"
            )
        }
    }

    func exportFixtureData(seed: HFContentBackendSnapshot) -> Data? {
        let snapshot = loadSnapshot(seed: seed)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(snapshot)
    }

    private func loadLegacySnapshot() -> HFContentBackendSnapshot? {
        guard let data = defaults.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(HFContentBackendSnapshot.self, from: data)
    }

    private func openDatabase() throws -> OpaquePointer {
        try FileManager.default.createDirectory(at: databaseURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        var database: OpaquePointer?
        guard sqlite3_open(databaseURL.path, &database) == SQLITE_OK, let database else {
            throw NSError(domain: "HFContentStorageLayer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to open content database"])
        }
        return database
    }

    private func ensureSchema(_ database: OpaquePointer) throws {
        try execute("PRAGMA journal_mode=WAL;", database: database)
        try execute("PRAGMA foreign_keys=ON;", database: database)
        try execute("""
        CREATE TABLE IF NOT EXISTS schema_info (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            version INTEGER NOT NULL,
            migrated_at TEXT NOT NULL
        );
        """, database: database)
        try execute("""
        CREATE TABLE IF NOT EXISTS content_snapshot (
            id TEXT PRIMARY KEY,
            schema_version INTEGER NOT NULL,
            payload BLOB NOT NULL,
            updated_at TEXT NOT NULL
        );
        """, database: database)
        try execute("""
        CREATE TABLE IF NOT EXISTS content_records (
            type TEXT NOT NULL,
            id TEXT NOT NULL,
            payload BLOB NOT NULL,
            updated_at TEXT NOT NULL,
            PRIMARY KEY (type, id)
        );
        """, database: database)
        try execute("""
        CREATE TABLE IF NOT EXISTS content_metadata (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
        );
        """, database: database)
        try execute(
            "INSERT OR IGNORE INTO schema_info (id, version, migrated_at) VALUES (1, ?, ?);",
            database: database,
            bindings: [.int(schemaVersion), .text(timestampLabel())]
        )
    }

    private func readSnapshot(_ database: OpaquePointer) throws -> HFContentBackendSnapshot? {
        guard let data = try queryBlob(
            "SELECT payload FROM content_snapshot WHERE id = ? LIMIT 1;",
            database: database,
            bindings: [.text("canonical")]
        ) else {
            return nil
        }
        return try JSONDecoder().decode(HFContentBackendSnapshot.self, from: data)
    }

    private func writeSnapshot(_ snapshot: HFContentBackendSnapshot, database: OpaquePointer, migrationState: String) throws {
        let timestamp = timestampLabel()
        let snapshotData = try JSONEncoder().encode(snapshot)
        let records = try makeRecordEnvelopes(from: snapshot)

        try execute("BEGIN IMMEDIATE TRANSACTION;", database: database)
        do {
            try execute(
                "INSERT OR REPLACE INTO content_snapshot (id, schema_version, payload, updated_at) VALUES (?, ?, ?, ?);",
                database: database,
                bindings: [.text("canonical"), .int(schemaVersion), .blob(snapshotData), .text(timestamp)]
            )
            try execute("DELETE FROM content_records;", database: database)
            for record in records {
                try execute(
                    "INSERT OR REPLACE INTO content_records (type, id, payload, updated_at) VALUES (?, ?, ?, ?);",
                    database: database,
                    bindings: [.text(record.type), .text(record.id), .blob(record.payload), .text(timestamp)]
                )
            }
            try setMetadata("migration_state", value: migrationState, database: database)
            try setMetadata("updated_at", value: timestamp, database: database)
            try execute(
                "UPDATE schema_info SET version = ?, migrated_at = ? WHERE id = 1;",
                database: database,
                bindings: [.int(schemaVersion), .text(timestamp)]
            )
            try execute("COMMIT TRANSACTION;", database: database)
        } catch {
            try? execute("ROLLBACK TRANSACTION;", database: database)
            throw error
        }
    }

    private func makeRecordEnvelopes(from snapshot: HFContentBackendSnapshot) throws -> [HFContentDatabaseRecordEnvelope] {
        var records: [HFContentDatabaseRecordEnvelope] = []
        let encoder = JSONEncoder()

        func append<T: Encodable>(type: String, id: String, value: T) throws {
            records.append(
                HFContentDatabaseRecordEnvelope(
                    id: id,
                    type: type,
                    payload: try encoder.encode(value)
                )
            )
        }

        try snapshot.movies.forEach { try append(type: "movie", id: $0.id, value: $0) }
        try snapshot.creators.forEach { try append(type: "creator", id: $0.id, value: $0) }
        try snapshot.series.forEach { try append(type: "series", id: $0.id, value: $0) }
        try snapshot.series.flatMap(\.seasons).forEach { try append(type: "season", id: $0.id, value: $0) }
        try snapshot.series.flatMap(\.seasons).flatMap(\.episodes).forEach { try append(type: "episode", id: $0.id, value: $0) }
        try snapshot.collections.forEach { try append(type: "collection", id: $0.id, value: $0) }
        try snapshot.importedMediaAssets.forEach { try append(type: "imported_media_asset", id: $0.id, value: $0) }
        try snapshot.mediaInspectionRecords.forEach { try append(type: "media_inspection_record", id: $0.id, value: $0) }
        try snapshot.localReleasePackages.forEach { try append(type: "local_release_package", id: $0.id, value: $0) }
        try snapshot.publishingProjects.forEach { project in
            try append(type: "publishing_project", id: project.id, value: project)
            if project.releaseState == .draft {
                try append(type: "draft", id: project.id, value: project)
            }
            try append(type: "project_manifest", id: "project-manifest-\(project.id)", value: project)
            try append(type: "asset_metadata", id: "asset-metadata-\(project.id)", value: [
                "poster": project.posterStatus.rawValue,
                "trailer": project.trailerStatus.rawValue,
                "metadata": project.metadataStatus.rawValue,
                "artwork": project.artworkStatus.rawValue
            ])
        }
        return records
    }

    private func recordCounts(_ database: OpaquePointer) throws -> [String: Int] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, "SELECT type, COUNT(*) FROM content_records GROUP BY type;", -1, &statement, nil) == SQLITE_OK, let statement else {
            throw sqliteError(database)
        }
        defer { sqlite3_finalize(statement) }

        var counts: [String: Int] = [:]
        while sqlite3_step(statement) == SQLITE_ROW {
            let type = String(cString: sqlite3_column_text(statement, 0))
            counts[type] = Int(sqlite3_column_int(statement, 1))
        }
        return counts
    }

    private func setMetadata(_ key: String, value: String, database: OpaquePointer) throws {
        try execute(
            "INSERT OR REPLACE INTO content_metadata (key, value) VALUES (?, ?);",
            database: database,
            bindings: [.text(key), .text(value)]
        )
    }

    private func metadataValue(_ key: String, database: OpaquePointer) throws -> String? {
        guard let data = try queryText(
            "SELECT value FROM content_metadata WHERE key = ? LIMIT 1;",
            database: database,
            bindings: [.text(key)]
        ) else {
            return nil
        }
        return data
    }

    private enum SQLiteBinding {
        case int(Int)
        case text(String)
        case blob(Data)
    }

    private func execute(_ sql: String, database: OpaquePointer, bindings: [SQLiteBinding] = []) throws {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw sqliteError(database)
        }
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement)
        while true {
            let result = sqlite3_step(statement)
            if result == SQLITE_DONE {
                return
            }
            if result != SQLITE_ROW {
                throw sqliteError(database)
            }
        }
    }

    private func queryBlob(_ sql: String, database: OpaquePointer, bindings: [SQLiteBinding] = []) throws -> Data? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw sqliteError(database)
        }
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement)
        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }
        guard let bytes = sqlite3_column_blob(statement, 0) else { return nil }
        return Data(bytes: bytes, count: Int(sqlite3_column_bytes(statement, 0)))
    }

    private func queryText(_ sql: String, database: OpaquePointer, bindings: [SQLiteBinding] = []) throws -> String? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw sqliteError(database)
        }
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement)
        guard sqlite3_step(statement) == SQLITE_ROW, let text = sqlite3_column_text(statement, 0) else { return nil }
        return String(cString: text)
    }

    private func bind(_ bindings: [SQLiteBinding], to statement: OpaquePointer) throws {
        for (index, binding) in bindings.enumerated() {
            let position = Int32(index + 1)
            let result: Int32
            switch binding {
            case .int(let value):
                result = sqlite3_bind_int(statement, position, Int32(value))
            case .text(let value):
                result = sqlite3_bind_text(statement, position, value, -1, sqliteTransient)
            case .blob(let data):
                result = data.withUnsafeBytes { buffer in
                    sqlite3_bind_blob(statement, position, buffer.baseAddress, Int32(data.count), sqliteTransient)
                }
            }
            guard result == SQLITE_OK else {
                throw NSError(domain: "HFContentStorageLayer", code: Int(result), userInfo: [NSLocalizedDescriptionKey: "Unable to bind SQLite value"])
            }
        }
    }

    private func sqliteError(_ database: OpaquePointer) -> NSError {
        let message = sqlite3_errmsg(database).map { String(cString: $0) } ?? "Unknown SQLite error"
        return NSError(domain: "HFContentStorageLayer", code: Int(sqlite3_errcode(database)), userInfo: [NSLocalizedDescriptionKey: message])
    }

    private func timestampLabel() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}

struct CatalogRepository {
    private let snapshot: HFContentBackendSnapshot

    init(snapshot: HFContentBackendSnapshot) {
        self.snapshot = snapshot
    }

    func fetchCatalog() -> [Movie] {
        snapshot.movies
    }

    func fetchMovie(id: String) -> Movie? {
        snapshot.movies.first { $0.id == id }
    }

    func fetchSeries() -> [HFSeriesRecord] {
        snapshot.series
    }

    func fetchCollections() -> [Category] {
        snapshot.collections
    }
}

struct CreatorRepository {
    private let snapshot: HFContentBackendSnapshot

    init(snapshot: HFContentBackendSnapshot) {
        self.snapshot = snapshot
    }

    func fetchCreators() -> [Creator] {
        snapshot.creators
    }

    func fetchCreator(id: String) -> Creator? {
        snapshot.creators.first { $0.id == id }
    }

    func fetchCreator(named name: String) -> Creator? {
        snapshot.creators.first { $0.name == name }
    }

    func fetchTitles(for creator: Creator) -> [Movie] {
        snapshot.movies.filter { $0.creatorName == creator.name || creator.featuredMovieIDs.contains($0.id) }
    }
}

struct PublishingRepository {
    private let snapshot: HFContentBackendSnapshot

    init(snapshot: HFContentBackendSnapshot) {
        self.snapshot = snapshot
    }

    func fetchProjects() -> [HFCreatorPublishingContent] {
        snapshot.publishingProjects
    }

    func fetchDrafts() -> [HFCreatorPublishingContent] {
        snapshot.publishingProjects.filter { $0.releaseState == .draft }
    }

    func fetchPublishedTitles() -> [Movie] {
        snapshot.publishingProjects
            .filter(\.discoveryEligible)
            .map(\.movie)
    }
}

struct LibraryRepository {
    private let movies: [Movie]
    private let savedIDs: Set<String>
    private let downloadedIDs: Set<String>
    private let lastViewedID: String?

    init(movies: [Movie], savedIDs: Set<String>, downloadedIDs: Set<String>, lastViewedID: String?) {
        self.movies = movies
        self.savedIDs = savedIDs
        self.downloadedIDs = downloadedIDs
        self.lastViewedID = lastViewedID
    }

    func fetchSavedTitles() -> [Movie] {
        movies.filter { savedIDs.contains($0.id) }
    }

    func fetchOfflineTitles() -> [Movie] {
        movies.filter { downloadedIDs.contains($0.id) || $0.isDownloaded }
    }

    func fetchContinueWatching() -> [Movie] {
        var ordered = movies.filter { movie in
            guard let progress = movie.progress else { return false }
            return progress > 0 && progress < 0.95
        }
        if let lastViewedID, let last = movies.first(where: { $0.id == lastViewedID }), ordered.contains(where: { $0.id == last.id }) {
            ordered.removeAll { $0.id == last.id }
            ordered.insert(last, at: 0)
        }
        return ordered
    }

    func fetchCompletedTitles() -> [Movie] {
        movies.filter { ($0.progress ?? 0) >= 0.95 }
    }
}

struct HFContentQueryEngine {
    private let catalogRepository: CatalogRepository
    private let creatorRepository: CreatorRepository
    private let publishingRepository: PublishingRepository
    private let libraryRepository: LibraryRepository

    init(
        catalogRepository: CatalogRepository,
        creatorRepository: CreatorRepository,
        publishingRepository: PublishingRepository,
        libraryRepository: LibraryRepository
    ) {
        self.catalogRepository = catalogRepository
        self.creatorRepository = creatorRepository
        self.publishingRepository = publishingRepository
        self.libraryRepository = libraryRepository
    }

    func fetchCatalog() -> [Movie] {
        uniqueMovies(catalogRepository.fetchCatalog() + publishingRepository.fetchPublishedTitles())
    }

    func fetchTitle(id: String) -> Movie? {
        catalogRepository.fetchMovie(id: id)
            ?? publishingRepository.fetchPublishedTitles().first { $0.id == id }
    }

    func searchTitles(query: String, filter: String = "All") -> [Movie] {
        let base = titles(matching: filter)
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return Array(base.prefix(8)) }

        return base
            .map { movie in (movie, titleSearchScore(for: movie, term: term)) }
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 { return lhs.0.title < rhs.0.title }
                return lhs.1 > rhs.1
            }
            .map(\.0)
    }

    func searchCreators(query: String) -> [Creator] {
        let creators = creatorRepository.fetchCreators()
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return creators }

        return creators
            .map { creator in (creator, creatorSearchScore(for: creator, term: term)) }
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 { return lhs.0.name < rhs.0.name }
                return lhs.1 > rhs.1
            }
            .map(\.0)
    }

    func titlesByCreator(_ creator: Creator) -> [Movie] {
        uniqueMovies(
            creatorRepository.fetchTitles(for: creator)
                + publishingRepository.fetchProjects()
                .filter { $0.creator == creator.name }
                .map(\.movie)
        )
    }

    func titlesByGenre(_ genre: String) -> [Movie] {
        fetchCatalog().filter { movie in
            movie.genres.contains { $0.localizedCaseInsensitiveCompare(genre) == .orderedSame }
        }
    }

    func titlesByTag(_ tag: String) -> [Movie] {
        fetchCatalog().filter { movie in
            tags(for: movie).contains { $0.localizedCaseInsensitiveContains(tag) }
        }
    }

    func lookupCollection(id: String) -> Category? {
        catalogRepository.fetchCollections().first { $0.id == id }
    }

    func fetchCollections() -> [Category] {
        catalogRepository.fetchCollections()
    }

    func lookupSeries(id: String) -> HFSeriesRecord? {
        catalogRepository.fetchSeries().first { $0.id == id }
    }

    func fetchSeries() -> [HFSeriesRecord] {
        catalogRepository.fetchSeries()
    }

    func lookupEpisode(id: String) -> HFEpisodeRecord? {
        fetchEpisodes().first { $0.id == id }
    }

    func fetchEpisodes() -> [HFEpisodeRecord] {
        catalogRepository.fetchSeries().flatMap { series in
            series.seasons.flatMap(\.episodes)
        }
    }

    func relatedContent(for movie: Movie, limit: Int = 8) -> [Movie] {
        let genreMatches = fetchCatalog().filter { candidate in
            candidate.id != movie.id &&
                !Set(candidate.genres).isDisjoint(with: Set(movie.genres))
        }
        let creatorMatches = fetchCatalog().filter { $0.id != movie.id && $0.creatorName == movie.creatorName }
        let tagMatches = fetchCatalog().filter { candidate in
            candidate.id != movie.id &&
                !Set(tags(for: candidate)).isDisjoint(with: Set(tags(for: movie)))
        }
        return Array(uniqueMovies(genreMatches + creatorMatches + tagMatches + recentlyPublished()).prefix(limit))
    }

    func recentlyPublished(limit: Int = 10) -> [Movie] {
        let published = publishingRepository.fetchPublishedTitles()
        let catalog = fetchCatalog().filter { !$0.isComingSoon }
        return Array(uniqueMovies(published + catalog.reversed()).prefix(limit))
    }

    func creatorPublishedTitles() -> [Movie] {
        publishingRepository.fetchPublishedTitles()
    }

    func libraryAwareRecommendations(anchor movie: Movie? = nil, limit: Int = 10) -> [Movie] {
        let selected = movie
            ?? libraryRepository.fetchContinueWatching().first
            ?? libraryRepository.fetchSavedTitles().first
            ?? fetchCatalog().first

        guard let selected else { return Array(fetchCatalog().prefix(limit)) }
        let recommended = relatedContent(for: selected, limit: limit)
        let savedAdjacency = libraryRepository.fetchSavedTitles().filter { $0.id != selected.id }
        let recent = recentlyPublished(limit: limit)
        return Array(uniqueMovies(recommended + savedAdjacency + recent).prefix(limit))
    }

    private func titles(matching filter: String) -> [Movie] {
        switch filter {
        case "Movies":
            return fetchCatalog().filter { !$0.duration.localizedCaseInsensitiveContains("episode") }
        case "Series":
            return fetchCatalog().filter { $0.duration.localizedCaseInsensitiveContains("episode") || $0.genres.contains("Series") }
        case "Originals":
            return fetchCatalog().filter(\.isOriginal)
        case "Creator Published":
            return creatorPublishedTitles()
        case "Downloaded":
            return libraryRepository.fetchOfflineTitles()
        default:
            return fetchCatalog()
        }
    }

    private func titleSearchScore(for movie: Movie, term: String) -> Int {
        let fields: [(String, Int)] = [
            (movie.title, 120),
            (movie.subtitle, 55),
            (movie.creatorName, 70),
            (movie.genres.joined(separator: " "), 60),
            (tags(for: movie).joined(separator: " "), 65),
            (collectionNames(for: movie).joined(separator: " "), 50),
            (movie.synopsis, 28),
            (movie.duration, 12),
            (movie.year, 8)
        ]
        return score(fields: fields, term: term)
    }

    private func creatorSearchScore(for creator: Creator, term: String) -> Int {
        let titles = titlesByCreator(creator)
        let fields: [(String, Int)] = [
            (creator.name, 140),
            (creator.role, 70),
            (titles.map(\.title).joined(separator: " "), 92),
            (titles.flatMap(\.genres).joined(separator: " "), 58)
        ]
        return score(fields: fields, term: term)
    }

    private func score(fields: [(String, Int)], term: String) -> Int {
        let normalized = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return 0 }
        return fields.reduce(0) { partial, field in
            if field.0.localizedCaseInsensitiveCompare(normalized) == .orderedSame {
                return partial + field.1 + 40
            }
            if field.0.localizedCaseInsensitiveContains(normalized) {
                return partial + field.1
            }
            return partial
        }
    }

    private func tags(for movie: Movie) -> [String] {
        publishingRepository.fetchProjects().first { $0.id == movie.id }?.tags ?? []
    }

    private func collectionNames(for movie: Movie) -> [String] {
        catalogRepository.fetchCollections()
            .filter { category in category.movies.contains { $0.id == movie.id } }
            .flatMap { [$0.title, $0.subtitle ?? ""] }
    }

    private func uniqueMovies(_ movies: [Movie]) -> [Movie] {
        var seen = Set<String>()
        return movies.filter { seen.insert($0.id).inserted }
    }
}

enum HFCatalogRuntimeState: String, Hashable {
    case idle = "Idle"
    case loading = "Loading"
    case ready = "Ready"
    case empty = "Empty"
    case stale = "Stale"
    case failed = "Failed"

    var accessibilityIdentifier: String {
        "hf.catalog.runtime.\(rawValue.lowercased())"
    }
}

enum HFCatalogRuntimeSort: String, CaseIterable, Identifiable {
    case editorial = "Editorial"
    case title = "Title"
    case creator = "Creator"
    case recentlyPublished = "Recently Published"
    case progress = "Progress"

    var id: String { rawValue }
}

struct HFCatalogRuntimeSnapshot: Hashable {
    var state: HFCatalogRuntimeState
    var totalTitles: Int
    var totalCreators: Int
    var totalCollections: Int
    var totalSeries: Int
    var totalEpisodes: Int
    var cachedPageCount: Int
    var generation: Int
    var reason: String
    var updatedAtLabel: String
    var invalidationReason: String?

    var statusLabel: String {
        switch state {
        case .ready:
            return "Catalog Ready"
        case .loading:
            return "Loading Catalog"
        case .empty:
            return "Catalog Empty"
        case .stale:
            return "Catalog Stale"
        case .failed:
            return "Catalog Needs Attention"
        case .idle:
            return "Catalog Idle"
        }
    }

    var detail: String {
        let summary = "\(totalTitles) titles, \(totalCreators) creators, \(totalCollections) collections"
        guard let invalidationReason else { return summary }
        return "\(summary). \(invalidationReason)"
    }

    static func loading(reason: String, previousCount: Int = 0, generation: Int = 0) -> HFCatalogRuntimeSnapshot {
        HFCatalogRuntimeSnapshot(
            state: .loading,
            totalTitles: previousCount,
            totalCreators: 0,
            totalCollections: 0,
            totalSeries: 0,
            totalEpisodes: 0,
            cachedPageCount: 0,
            generation: generation,
            reason: reason,
            updatedAtLabel: "Loading local catalog",
            invalidationReason: nil
        )
    }

    static func ready(
        titles: Int,
        creators: Int,
        collections: Int,
        series: Int,
        episodes: Int,
        cachedPageCount: Int,
        generation: Int,
        reason: String
    ) -> HFCatalogRuntimeSnapshot {
        HFCatalogRuntimeSnapshot(
            state: titles == 0 ? .empty : .ready,
            totalTitles: titles,
            totalCreators: creators,
            totalCollections: collections,
            totalSeries: series,
            totalEpisodes: episodes,
            cachedPageCount: cachedPageCount,
            generation: generation,
            reason: reason,
            updatedAtLabel: "Local catalog refreshed",
            invalidationReason: nil
        )
    }

    func invalidated(reason: String) -> HFCatalogRuntimeSnapshot {
        var snapshot = self
        snapshot.state = .stale
        snapshot.reason = "Invalidated"
        snapshot.updatedAtLabel = "Refresh needed"
        snapshot.invalidationReason = reason
        return snapshot
    }
}

struct HFCatalogRuntimePage: Identifiable, Hashable {
    var id: String { cacheKey }
    let cacheKey: String
    let filter: String
    let sort: HFCatalogRuntimeSort
    let page: Int
    let pageSize: Int
    let totalResults: Int
    let totalPages: Int
    let movies: [Movie]
    let generation: Int

    var hasNextPage: Bool {
        page + 1 < totalPages
    }

    var isEmpty: Bool {
        movies.isEmpty
    }
}

struct HFBackendRuntimeConfigRow: Identifiable, Codable, Equatable {
    let id: String
    var title: String
    var status: String
}

enum HFProductionCatalogBackendState: String, Hashable {
    case disabled = "Local Only"
    case fetching = "Fetching"
    case ready = "Backend Ready"
    case localFallback = "Local Fallback"
    case failed = "Backend Unavailable"
}

struct HFProductionCatalogRuntimeSnapshot: Hashable {
    var state: HFProductionCatalogBackendState
    var source: String
    var endpoint: String
    var titleCount: Int
    var creatorCount: Int
    var seriesCount: Int
    var collectionCount: Int
    var detail: String
    var lastError: String?
    var updatedAtLabel: String

    var statusLabel: String { state.rawValue }

    static func localFallback(snapshot: HFContentBackendSnapshot, reason: String) -> HFProductionCatalogRuntimeSnapshot {
        HFProductionCatalogRuntimeSnapshot(
            state: .localFallback,
            source: "Local Content Snapshot",
            endpoint: "Local repository fallback",
            titleCount: snapshot.movies.count,
            creatorCount: snapshot.creators.count,
            seriesCount: snapshot.series.count,
            collectionCount: snapshot.collections.count,
            detail: reason,
            lastError: nil,
            updatedAtLabel: "Local fallback active"
        )
    }
}

enum HFCloudCatalogSyncState: String, Hashable {
    case localCache = "Local Cache"
    case syncing = "Syncing"
    case synced = "Cloud Synced"
    case staleCache = "Stale Cache"
    case failed = "Sync Failed"

    var statusLabel: String { rawValue }
}

struct HFCloudCatalogTombstoneDTO: Codable, Hashable {
    var id: String
    var entityType: String
    var entityID: String
    var deletedAt: String
    var reason: String

    private enum CodingKeys: String, CodingKey {
        case id
        case entityType = "entity_type"
        case entityID = "entity_id"
        case deletedAt = "deleted_at"
        case reason
    }
}

struct HFCloudCatalogSyncRuntimeSnapshot: Hashable {
    var state: HFCloudCatalogSyncState
    var source: String
    var cursor: String?
    var catalogVersion: Int
    var titleCount: Int
    var creatorCount: Int
    var seriesCount: Int
    var collectionCount: Int
    var tombstoneCount: Int
    var cachePolicy: String
    var detail: String
    var lastError: String?
    var updatedAtLabel: String

    var statusLabel: String { state.statusLabel }

    static func localCache(snapshot: HFContentBackendSnapshot, cursor: String?, version: Int, reason: String) -> HFCloudCatalogSyncRuntimeSnapshot {
        HFCloudCatalogSyncRuntimeSnapshot(
            state: .localCache,
            source: "Durable Local Cache",
            cursor: cursor,
            catalogVersion: version,
            titleCount: snapshot.movies.count,
            creatorCount: snapshot.creators.count,
            seriesCount: snapshot.series.count,
            collectionCount: snapshot.collections.count,
            tombstoneCount: 0,
            cachePolicy: "stale-while-revalidate",
            detail: reason,
            lastError: nil,
            updatedAtLabel: snapshot.updatedAtLabel
        )
    }
}

struct HFCloudCatalogSyncDiagnosticRecord: Identifiable, Hashable {
    let id: String
    var title: String
    var detail: String
    var status: String
    var systemImage: String
}

struct HFProductionCatalogEndpointRow: Identifiable, Hashable {
    let id: String
    var title: String
    var path: String
    var status: String
    var systemImage: String
}

struct HFProductionCatalogBackendConfiguration {
    static let modeKey = "HF_CINEMA_BACKEND_MODE"
    static let baseURLKey = "HF_CINEMA_BACKEND_BASE_URL"

    var isRemoteEnabled: Bool
    var baseURL: URL

    init(arguments: [String] = ProcessInfo.processInfo.arguments, environment: [String: String] = ProcessInfo.processInfo.environment) {
        let requestedMode = environment[Self.modeKey]?.lowercased()
        isRemoteEnabled = requestedMode == "remote"
            || arguments.contains("--hf-production-backend-catalog")
            || arguments.contains("--hf-start-production-backend")
            || arguments.contains("--hf-start-cloud-catalog-sync")
            || arguments.contains("--hf-cloud-catalog-cache")
            || arguments.contains("--hf-cloud-catalog-delta")
            || arguments.contains("--hf-cloud-catalog-diagnostics")

        let configuredBaseURL = environment[Self.baseURLKey].flatMap(URL.init(string:))
        baseURL = configuredBaseURL ?? URL(string: "http://127.0.0.1:8787")!
    }
}

enum HFCreatorDraftSyncState: String, Hashable {
    case disabled = "Local Drafts"
    case syncing = "Syncing"
    case synced = "Remote Synced"
    case queued = "Queued Offline"
    case conflict = "Conflict"
    case failed = "Sync Failed"
}

struct HFCreatorDraftSyncRuntimeSnapshot: Hashable {
    var state: HFCreatorDraftSyncState
    var endpoint: String
    var remoteDraftCount: Int
    var queuedEditCount: Int
    var conflictCount: Int
    var revisionCount: Int
    var detail: String
    var lastError: String?
    var updatedAtLabel: String

    var statusLabel: String { state.rawValue }

    static func local(snapshot: HFContentBackendSnapshot, reason: String) -> HFCreatorDraftSyncRuntimeSnapshot {
        HFCreatorDraftSyncRuntimeSnapshot(
            state: .disabled,
            endpoint: "Local publishing repository",
            remoteDraftCount: snapshot.publishingProjects.count,
            queuedEditCount: 0,
            conflictCount: 0,
            revisionCount: 0,
            detail: reason,
            lastError: nil,
            updatedAtLabel: snapshot.updatedAtLabel
        )
    }
}

struct HFCreatorDraftSyncQueueRecord: Identifiable, Codable, Hashable {
    var id: String
    var projectID: String
    var action: String
    var result: String
    var detail: String
    var createdAt: String

    private enum CodingKeys: String, CodingKey {
        case id
        case projectID = "project_id"
        case action
        case result
        case detail
        case createdAt = "created_at"
    }
}

struct HFCreatorDraftRevisionRecord: Identifiable, Codable, Hashable {
    var id: String
    var projectID: String
    var version: Int
    var action: String
    var actorUserID: String
    var detail: String
    var createdAt: String

    private enum CodingKeys: String, CodingKey {
        case id
        case projectID = "project_id"
        case version
        case action
        case actorUserID = "actor_user_id"
        case detail
        case createdAt = "created_at"
    }
}

struct HFRemoteCreatorDraftDTO: Codable, Hashable {
    var id: String
    var ownerUserID: String?
    var creatorID: String?
    var contentID: String?
    var title: String
    var description: String
    var creator: String
    var genre: String
    var tags: [String]
    var runtime: String
    var releaseState: String
    var posterAssetName: String?
    var posterStatus: String
    var trailerStatus: String
    var metadataStatus: String
    var artworkStatus: String
    var version: Int
    var updatedAtLabel: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case ownerUserID = "owner_user_id"
        case creatorID = "creator_id"
        case contentID = "content_id"
        case title
        case description
        case creator
        case genre
        case tags
        case runtime
        case releaseState = "release_state"
        case posterAssetName = "poster_asset_name"
        case posterStatus = "poster_status"
        case trailerStatus = "trailer_status"
        case metadataStatus = "metadata_status"
        case artworkStatus = "artwork_status"
        case version
        case updatedAtLabel = "updated_at_label"
    }

    init(draft: HFCreatorPublishingContent, baseVersion: Int? = nil) {
        id = draft.id
        ownerUserID = nil
        creatorID = nil
        contentID = draft.id
        title = draft.title
        description = draft.description
        creator = draft.creator
        genre = draft.genre
        tags = draft.tags
        runtime = draft.runtime
        releaseState = draft.releaseState.rawValue.lowercased()
        posterAssetName = draft.posterAssetName
        posterStatus = draft.posterStatus.remoteRawValue
        trailerStatus = draft.trailerStatus.remoteRawValue
        metadataStatus = draft.metadataStatus.remoteRawValue
        artworkStatus = draft.artworkStatus.remoteRawValue
        version = baseVersion ?? 0
        updatedAtLabel = draft.updatedAtLabel
    }

    var publishingContent: HFCreatorPublishingContent {
        HFCreatorPublishingContent(
            id: id,
            title: title,
            description: description,
            posterAssetName: posterAssetName,
            trailerStatus: HFCreatorPublishingAssetStatus(remoteRawValue: trailerStatus),
            creator: creator,
            genre: genre,
            tags: tags,
            runtime: runtime,
            releaseState: HFCreatorReleaseState(remoteRawValue: releaseState),
            posterStatus: HFCreatorPublishingAssetStatus(remoteRawValue: posterStatus),
            metadataStatus: HFCreatorPublishingAssetStatus(remoteRawValue: metadataStatus),
            artworkStatus: HFCreatorPublishingAssetStatus(remoteRawValue: artworkStatus),
            updatedAtLabel: updatedAtLabel ?? "Remote draft synced"
        )
    }
}

struct HFRemoteCreatorDraftListResponse: Codable {
    var status: String
    var drafts: [HFRemoteCreatorDraftDTO]
    var revisionCount: Int
    var syncQueue: [HFCreatorDraftSyncQueueRecord]?

    private enum CodingKeys: String, CodingKey {
        case status
        case drafts
        case revisionCount = "revision_count"
        case syncQueue = "sync_queue"
    }
}

struct HFRemoteCreatorDraftMutationResponse: Codable {
    var status: String
    var draft: HFRemoteCreatorDraftDTO
    var revisions: [HFCreatorDraftRevisionRecord]
    var auditRecords: [HFCreatorDraftSyncQueueRecord]?

    private enum CodingKeys: String, CodingKey {
        case status
        case draft
        case revisions
        case auditRecords = "audit_records"
    }
}

struct HFRemoteCreatorDraftRevisionResponse: Codable {
    var status: String
    var projectID: String
    var version: Int
    var revisions: [HFCreatorDraftRevisionRecord]
    var auditRecords: [HFCreatorDraftSyncQueueRecord]?

    private enum CodingKeys: String, CodingKey {
        case status
        case projectID = "project_id"
        case version
        case revisions
        case auditRecords = "audit_records"
    }
}

struct HFRemoteCreatorDraftQueueResponse: Codable {
    var status: String
    var queuedEdits: [HFCreatorDraftSyncQueueRecord]
    var offlineEditsSupported: Bool
    var retrySupported: Bool
    var mergeStrategy: String

    private enum CodingKeys: String, CodingKey {
        case status
        case queuedEdits = "queued_edits"
        case offlineEditsSupported = "offline_edits_supported"
        case retrySupported = "retry_supported"
        case mergeStrategy = "merge_strategy"
    }
}

struct HFRemoteIdentitySignInResponse: Codable {
    struct Session: Codable {
        var sessionID: String

        private enum CodingKeys: String, CodingKey {
            case sessionID = "session_id"
        }
    }

    var session: Session
}

enum HFRemoteCreatorDraftAPIError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case httpStatus(Int, String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "Invalid draft sync URL for \(path)"
        case .invalidResponse:
            return "Draft sync endpoint returned a non-HTTP response"
        case .httpStatus(let status, let detail):
            return "Draft sync endpoint returned HTTP \(status): \(detail)"
        case .decodingFailed(let detail):
            return "Draft sync response could not be decoded: \(detail)"
        }
    }
}

struct HFRemoteCreatorDraftAPIClient {
    var baseURL: URL
    var session: URLSession = .shared

    func createDevelopmentSession(role: String = "creator") async throws -> String {
        let response: HFRemoteIdentitySignInResponse = try await request(
            path: "/v1/identity/dev/sign-in",
            method: "POST",
            sessionID: nil,
            body: ["role": role]
        )
        return response.session.sessionID
    }

    func listDrafts(sessionID: String) async throws -> HFRemoteCreatorDraftListResponse {
        try await request(path: "/v1/creator/drafts", method: "GET", sessionID: sessionID, body: Optional<[String: String]>.none)
    }

    func createDraft(_ draft: HFCreatorPublishingContent, sessionID: String) async throws -> HFRemoteCreatorDraftMutationResponse {
        try await request(path: "/v1/creator/drafts", method: "POST", sessionID: sessionID, body: HFRemoteCreatorDraftDTO(draft: draft))
    }

    func updateDraft(_ draft: HFCreatorPublishingContent, baseVersion: Int, sessionID: String) async throws -> HFRemoteCreatorDraftMutationResponse {
        try await request(path: "/v1/creator/drafts/\(draft.id)", method: "PATCH", sessionID: sessionID, body: HFRemoteCreatorDraftUpdatePayload(draft: draft, baseVersion: baseVersion))
    }

    func archiveDraft(id: String, baseVersion: Int, sessionID: String) async throws -> HFRemoteCreatorDraftMutationResponse {
        try await request(path: "/v1/creator/drafts/\(id)/archive", method: "POST", sessionID: sessionID, body: ["base_version": baseVersion])
    }

    func restoreDraft(id: String, baseVersion: Int, sessionID: String) async throws -> HFRemoteCreatorDraftMutationResponse {
        try await request(path: "/v1/creator/drafts/\(id)/restore", method: "POST", sessionID: sessionID, body: ["base_version": baseVersion])
    }

    func revisionHistory(id: String, sessionID: String) async throws -> HFRemoteCreatorDraftRevisionResponse {
        try await request(path: "/v1/creator/drafts/\(id)/revisions", method: "GET", sessionID: sessionID, body: Optional<[String: String]>.none)
    }

    func syncQueue(sessionID: String) async throws -> HFRemoteCreatorDraftQueueResponse {
        try await request(path: "/v1/creator/draft-sync/queue", method: "GET", sessionID: sessionID, body: Optional<[String: String]>.none)
    }

    private func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: String,
        sessionID: String?,
        body: Body?
    ) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw HFRemoteCreatorDraftAPIError.invalidURL(path)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let sessionID {
            request.setValue("HighFiveSession \(sessionID)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
        }
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HFRemoteCreatorDraftAPIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let detail = String(data: data, encoding: .utf8) ?? "No response body"
            throw HFRemoteCreatorDraftAPIError.httpStatus(httpResponse.statusCode, detail)
        }
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw HFRemoteCreatorDraftAPIError.decodingFailed(error.localizedDescription)
        }
    }
}

struct HFRemoteCreatorDraftUpdatePayload: Encodable {
    var id: String
    var title: String
    var description: String
    var creator: String
    var genre: String
    var tags: [String]
    var runtime: String
    var posterAssetName: String?
    var posterStatus: String
    var trailerStatus: String
    var metadataStatus: String
    var artworkStatus: String
    var baseVersion: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case creator
        case genre
        case tags
        case runtime
        case posterAssetName = "poster_asset_name"
        case posterStatus = "poster_status"
        case trailerStatus = "trailer_status"
        case metadataStatus = "metadata_status"
        case artworkStatus = "artwork_status"
        case baseVersion = "base_version"
    }

    init(draft: HFCreatorPublishingContent, baseVersion: Int) {
        id = draft.id
        title = draft.title
        description = draft.description
        creator = draft.creator
        genre = draft.genre
        tags = draft.tags
        runtime = draft.runtime
        posterAssetName = draft.posterAssetName
        posterStatus = draft.posterStatus.remoteRawValue
        trailerStatus = draft.trailerStatus.remoteRawValue
        metadataStatus = draft.metadataStatus.remoteRawValue
        artworkStatus = draft.artworkStatus.remoteRawValue
        self.baseVersion = baseVersion
    }
}

enum HFProductionCatalogAPIError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "Invalid catalog URL for \(path)"
        case .invalidResponse:
            return "Catalog endpoint returned a non-HTTP response"
        case .httpStatus(let status):
            return "Catalog endpoint returned HTTP \(status)"
        case .decodingFailed(let detail):
            return "Catalog response could not be decoded: \(detail)"
        }
    }
}

protocol HFProductionCatalogAPIClient {
    func fetchCatalog() async throws -> HFProductionCatalogResponse
    func fetchCatalogSync(cursor: String?) async throws -> HFProductionCatalogResponse
    func fetchCatalogDelta(cursor: String?) async throws -> HFProductionCatalogDeltaResponse
}

struct HFLocalProductionCatalogAPIClient: HFProductionCatalogAPIClient {
    var snapshot: HFContentBackendSnapshot

    func fetchCatalog() async throws -> HFProductionCatalogResponse {
        HFProductionCatalogResponse.local(snapshot: snapshot)
    }

    func fetchCatalogSync(cursor: String?) async throws -> HFProductionCatalogResponse {
        var response = HFProductionCatalogResponse.local(snapshot: snapshot)
        response.source = "local_sync_cache"
        response.syncCursor = cursor ?? "local-cache"
        response.catalogVersion = 0
        response.fullSync = true
        response.tombstones = []
        return response
    }

    func fetchCatalogDelta(cursor: String?) async throws -> HFProductionCatalogDeltaResponse {
        HFProductionCatalogDeltaResponse.local(cursor: cursor)
    }
}

struct HFRemoteProductionCatalogAPIClient: HFProductionCatalogAPIClient {
    var baseURL: URL
    var session: URLSession = .shared
    var retryCount: Int = 1

    func fetchCatalog() async throws -> HFProductionCatalogResponse {
        var lastError: Error?
        for attempt in 0...retryCount {
            do {
                let response: HFProductionCatalogResponse = try await fetch(path: "/v1/catalog")
                return response
            } catch {
                lastError = error
                if attempt == retryCount { break }
            }
        }
        throw lastError ?? HFProductionCatalogAPIError.invalidResponse
    }

    func fetchCatalogSync(cursor: String?) async throws -> HFProductionCatalogResponse {
        try await fetchWithRetry(path: "/v1/catalog/sync", cursor: cursor)
    }

    func fetchCatalogDelta(cursor: String?) async throws -> HFProductionCatalogDeltaResponse {
        try await fetchWithRetry(path: "/v1/catalog/delta", cursor: cursor)
    }

    private func fetchWithRetry<Response: Decodable>(path: String, cursor: String?) async throws -> Response {
        var lastError: Error?
        for attempt in 0...retryCount {
            do {
                let requestPath = cursor.map {
                    let encoded = $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0
                    return "\(path)?cursor=\(encoded)"
                } ?? path
                let response: Response = try await fetch(path: requestPath)
                return response
            } catch {
                lastError = error
                if attempt == retryCount { break }
            }
        }
        throw lastError ?? HFProductionCatalogAPIError.invalidResponse
    }

    private func fetch<Response: Decodable>(path: String) async throws -> Response {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw HFProductionCatalogAPIError.invalidURL(path)
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HFProductionCatalogAPIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw HFProductionCatalogAPIError.httpStatus(httpResponse.statusCode)
        }
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw HFProductionCatalogAPIError.decodingFailed(error.localizedDescription)
        }
    }
}

struct HFProductionCatalogResponse: Codable, Hashable {
    var generatedAt: String
    var source: String
    var totalTitles: Int
    var totalCreators: Int
    var totalSeries: Int
    var totalCollections: Int
    var movies: [HFProductionCatalogMovieDTO]
    var creators: [HFProductionCatalogCreatorDTO]
    var series: [HFProductionCatalogSeriesDTO]
    var collections: [HFProductionCatalogCollectionDTO]
    var catalogVersion: Int?
    var previousCursor: String?
    var syncCursor: String?
    var fullSync: Bool?
    var tombstones: [HFCloudCatalogTombstoneDTO]?

    private enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case source
        case totalTitles = "total_titles"
        case totalCreators = "total_creators"
        case totalSeries = "total_series"
        case totalCollections = "total_collections"
        case movies
        case creators
        case series
        case collections
        case catalogVersion = "catalog_version"
        case previousCursor = "previous_cursor"
        case syncCursor = "sync_cursor"
        case fullSync = "full_sync"
        case tombstones
    }

    static func local(snapshot: HFContentBackendSnapshot) -> HFProductionCatalogResponse {
        HFProductionCatalogResponse(
            generatedAt: snapshot.updatedAtLabel,
            source: "local_snapshot",
            totalTitles: snapshot.movies.count,
            totalCreators: snapshot.creators.count,
            totalSeries: snapshot.series.count,
            totalCollections: snapshot.collections.count,
            movies: snapshot.movies.map(HFProductionCatalogMovieDTO.init(movie:)),
            creators: snapshot.creators.map(HFProductionCatalogCreatorDTO.init(creator:)),
            series: snapshot.series.map(HFProductionCatalogSeriesDTO.init(series:)),
            collections: snapshot.collections.map(HFProductionCatalogCollectionDTO.init(collection:)),
            catalogVersion: 0,
            previousCursor: nil,
            syncCursor: "local-cache",
            fullSync: true,
            tombstones: []
        )
    }
}

struct HFProductionCatalogDeltaResponse: Codable, Hashable {
    var generatedAt: String
    var source: String
    var catalogVersion: Int
    var previousCursor: String?
    var syncCursor: String
    var fullSync: Bool
    var movies: [HFProductionCatalogMovieDTO]
    var creators: [HFProductionCatalogCreatorDTO]
    var series: [HFProductionCatalogSeriesDTO]
    var collections: [HFProductionCatalogCollectionDTO]
    var tombstones: [HFCloudCatalogTombstoneDTO]

    private enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case source
        case catalogVersion = "catalog_version"
        case previousCursor = "previous_cursor"
        case syncCursor = "sync_cursor"
        case fullSync = "full_sync"
        case movies
        case creators
        case series
        case collections
        case tombstones
    }

    static func local(cursor: String?) -> HFProductionCatalogDeltaResponse {
        HFProductionCatalogDeltaResponse(
            generatedAt: "Local cache",
            source: "local_snapshot",
            catalogVersion: 0,
            previousCursor: cursor,
            syncCursor: cursor ?? "local-cache",
            fullSync: false,
            movies: [],
            creators: [],
            series: [],
            collections: [],
            tombstones: []
        )
    }
}

struct HFProductionCatalogMovieDTO: Codable, Hashable {
    var id: String
    var title: String
    var subtitle: String
    var synopsis: String
    var year: String
    var rating: String
    var duration: String
    var genres: [String]
    var posterAssetName: String?
    var backdropAssetName: String?
    var creatorID: String?
    var creatorName: String
    var isOriginal: Bool
    var isComingSoon: Bool
    var isDownloaded: Bool
    var progress: Double?
    var collectionIDs: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case synopsis
        case year
        case rating
        case duration
        case genres
        case posterAssetName = "poster_asset_name"
        case backdropAssetName = "backdrop_asset_name"
        case creatorID = "creator_id"
        case creatorName = "creator_name"
        case isOriginal = "is_original"
        case isComingSoon = "is_coming_soon"
        case isDownloaded = "is_downloaded"
        case progress
        case collectionIDs = "collection_ids"
    }

    init(movie: Movie) {
        id = movie.id
        title = movie.title
        subtitle = movie.subtitle
        synopsis = movie.synopsis
        year = movie.year
        rating = movie.rating
        duration = movie.duration
        genres = movie.genres
        posterAssetName = movie.posterAssetName
        backdropAssetName = movie.backdropAssetName
        creatorID = nil
        creatorName = movie.creatorName
        isOriginal = movie.isOriginal
        isComingSoon = movie.isComingSoon
        isDownloaded = movie.isDownloaded
        progress = movie.progress
        collectionIDs = []
    }

    var movie: Movie {
        Movie(
            id: id,
            title: title,
            subtitle: subtitle,
            synopsis: synopsis,
            year: year,
            rating: rating,
            duration: duration,
            genres: genres,
            posterAssetName: posterAssetName,
            backdropAssetName: backdropAssetName,
            creatorName: creatorName,
            isOriginal: isOriginal,
            isComingSoon: isComingSoon,
            isDownloaded: isDownloaded,
            progress: progress
        )
    }
}

struct HFProductionCatalogCreatorDTO: Codable, Hashable {
    var id: String
    var name: String
    var role: String
    var avatarAssetName: String?
    var featuredMovieIDs: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case avatarAssetName = "avatar_asset_name"
        case featuredMovieIDs = "featured_movie_ids"
    }

    init(creator: Creator) {
        id = creator.id
        name = creator.name
        role = creator.role
        avatarAssetName = creator.avatarAssetName
        featuredMovieIDs = creator.featuredMovieIDs
    }

    var creator: Creator {
        Creator(id: id, name: name, role: role, avatarAssetName: avatarAssetName, featuredMovieIDs: featuredMovieIDs)
    }
}

struct HFProductionCatalogEpisodeDTO: Codable, Hashable {
    var id: String
    var seriesID: String
    var seasonNumber: Int
    var episodeNumber: Int
    var title: String
    var synopsis: String
    var runtime: String
    var releaseState: String
    var progress: Double?

    private enum CodingKeys: String, CodingKey {
        case id
        case seriesID = "series_id"
        case seasonNumber = "season_number"
        case episodeNumber = "episode_number"
        case title
        case synopsis
        case runtime
        case releaseState = "release_state"
        case progress
    }

    init(episode: HFEpisodeRecord) {
        id = episode.id
        seriesID = episode.seriesID
        seasonNumber = episode.seasonNumber
        episodeNumber = episode.episodeNumber
        title = episode.title
        synopsis = episode.synopsis
        runtime = episode.runtime
        releaseState = episode.releaseState.rawValue.lowercased()
        progress = episode.progress
    }

    var episode: HFEpisodeRecord {
        HFEpisodeRecord(
            id: id,
            seriesID: seriesID,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            title: title,
            synopsis: synopsis,
            runtime: runtime,
            artworkStatus: .ready,
            releaseState: HFCreatorReleaseState(rawValue: releaseState.capitalized) ?? .published,
            progress: progress
        )
    }
}

struct HFProductionCatalogSeasonDTO: Codable, Hashable {
    var id: String
    var seriesID: String
    var seasonNumber: Int
    var title: String
    var episodes: [HFProductionCatalogEpisodeDTO]

    private enum CodingKeys: String, CodingKey {
        case id
        case seriesID = "series_id"
        case seasonNumber = "season_number"
        case title
        case episodes
    }

    init(season: HFSeasonRecord) {
        id = season.id
        seriesID = season.seriesID
        seasonNumber = season.seasonNumber
        title = season.title
        episodes = season.episodes.map(HFProductionCatalogEpisodeDTO.init(episode:))
    }

    var season: HFSeasonRecord {
        HFSeasonRecord(id: id, seriesID: seriesID, seasonNumber: seasonNumber, title: title, episodes: episodes.map(\.episode))
    }
}

struct HFProductionCatalogSeriesDTO: Codable, Hashable {
    var id: String
    var title: String
    var synopsis: String
    var creatorID: String?
    var creatorName: String
    var genre: String
    var releaseState: String
    var heroMovieID: String
    var seasons: [HFProductionCatalogSeasonDTO]

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case synopsis
        case creatorID = "creator_id"
        case creatorName = "creator_name"
        case genre
        case releaseState = "release_state"
        case heroMovieID = "hero_movie_id"
        case seasons
    }

    init(series: HFSeriesRecord) {
        id = series.id
        title = series.title
        synopsis = series.synopsis
        creatorID = nil
        creatorName = series.creatorName
        genre = series.genre
        releaseState = series.status.rawValue.lowercased()
        heroMovieID = series.heroMovie.id
        seasons = series.seasons.map(HFProductionCatalogSeasonDTO.init(season:))
    }

    func series(using movies: [Movie]) -> HFSeriesRecord? {
        guard let hero = movies.first(where: { $0.id == heroMovieID }) ?? movies.first(where: { $0.id == id }) else {
            return nil
        }
        return HFSeriesRecord(
            id: id,
            title: title,
            synopsis: synopsis,
            creatorName: creatorName,
            genre: genre,
            status: HFCreatorReleaseState(rawValue: releaseState.capitalized) ?? .published,
            seasons: seasons.map(\.season),
            heroMovie: hero
        )
    }
}

struct HFProductionCatalogCollectionDTO: Codable, Hashable {
    var id: String
    var title: String
    var subtitle: String?
    var movieIDs: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case subtitle
        case movieIDs = "movie_ids"
    }

    init(collection: Category) {
        id = collection.id
        title = collection.title
        subtitle = collection.subtitle
        movieIDs = collection.movies.map(\.id)
    }

    func collection(using movies: [Movie]) -> Category {
        Category(id: id, title: title, subtitle: subtitle, movies: movieIDs.compactMap { movieID in movies.first { $0.id == movieID } })
    }
}

final class HFStreamingStore: ObservableObject {
    @Published private(set) var savedMovieIDs: Set<String>
    @Published private(set) var downloadedMovieIDs: Set<String>
    @Published private(set) var recentSearches: [String]
    @Published var localConnectUpdateDraft: String
    @Published private(set) var localConnectUpdates: [String]
    @Published private(set) var launchChecklistStates: [Bool]
    @Published private(set) var generatedDeliverySummary: String
    @Published private(set) var localProfiles: [HFLocalViewingProfile]
    @Published private(set) var activeProfileID: String
    @Published private(set) var lastPlayerMovieID: String?
    @Published var selectedAudienceChannelID: String
    @Published private(set) var backendRuntimeStatus: HFBackendRuntimeStatus
    @Published private(set) var authRuntimeStatus: HFAuthRuntimeStatus
    @Published private(set) var entitlementRuntimeStatus: HFEntitlementRuntimeStatus
    @Published private(set) var backendEntitlementRequestState: HFBackendRequestState = .notConfigured
    @Published private(set) var backendPlaybackDescriptorRequestState: HFBackendRequestState = .localPreviewFallbackActive
    @Published private(set) var entitlementPlaybackResult: HFEntitlementPlaybackResult?
    @Published private(set) var activeStagingPlaybackDescriptor: HFPlaybackDescriptor?
    @Published private(set) var lastPlaybackDescriptorAuditContext: HFBackendRequestAuditContext?
    @Published private(set) var creatorPublishingContents: [HFCreatorPublishingContent]
    @Published private(set) var contentSnapshot: HFContentBackendSnapshot
    @Published private(set) var catalogRuntimeSnapshot: HFCatalogRuntimeSnapshot
    @Published private(set) var identitySessionRuntime: HFIdentitySessionRuntimeSnapshot
    @Published private(set) var identityAccessRuntimeSnapshot: HFIdentityAccessRuntimeSnapshot
    @Published private(set) var productionCatalogRuntimeSnapshot: HFProductionCatalogRuntimeSnapshot
    @Published private(set) var cloudCatalogSyncRuntimeSnapshot: HFCloudCatalogSyncRuntimeSnapshot
    @Published private(set) var creatorDraftSyncRuntimeSnapshot: HFCreatorDraftSyncRuntimeSnapshot
    @Published private(set) var creatorDraftSyncQueueRecords: [HFCreatorDraftSyncQueueRecord] = []
    @Published private(set) var creatorDraftRevisionRecords: [HFCreatorDraftRevisionRecord] = []

    private let savedKey = "hf.savedMovieIDs"
    private let downloadsKey = "hf.downloadedMovieIDs"
    private let recentSearchesKey = "hf.recentSearches"
    private let connectUpdatesKey = "hf.localConnectUpdates"
    private let launchChecklistKey = "hf.launchChecklistStates"
    private let activeProfileKey = "hf.localProfile.activeID"
    private let cloudCatalogSyncCursorKey = "hf.cloudCatalog.sync.cursor"
    private let cloudCatalogVersionKey = "hf.cloudCatalog.sync.version"
    private let profileDisplayNamePrefix = "hf.localProfile.displayName."
    private let lastPlayerMovieKey = "hf.player.lastMovieID"
    private let backendConfiguration: HFBackendConfiguration
    private let backendService: HFBackendService
    private let backendGateway: HFBackendGateway
    private let authConfiguration: HFAuthConfiguration
    private let authService: HFAuthService
    private let identityKeychainStore: HFIdentityKeychainSessionStore
    private let librarySyncConfiguration: HFLibrarySyncConfiguration
    private let downloadConfiguration: HFDownloadConfiguration
    private let entitlementConfiguration: HFEntitlementConfiguration
    private let entitlementService: HFEntitlementService
    private let streamingConfiguration: HFStreamingProviderConfiguration
    private let localPreviewPlaybackResolver: HFLocalPreviewPlaybackResolver
    private let remotePlaybackDescriptorGateway: HFRemotePlaybackDescriptorGateway
    private let entitlementPlaybackAdapter: HFBackendEntitlementPlaybackAdapter
    private let contentStorage: HFContentStorageLayer
    private let productionCatalogConfiguration: HFProductionCatalogBackendConfiguration
    private var catalogRuntimePageCache: [String: HFCatalogRuntimePage] = [:]
    private var catalogRuntimeGeneration = 0
    private var creatorDraftRemoteVersions: [String: Int] = [:]
    private var lastRemotePublishingSessionID: String?

    let launchChecklistItems = [
        "Campaign headline reviewed",
        "Premiere copy reviewed",
        "Audience prompt prepared",
        "Media kit checked",
        "Release calendar reviewed"
    ]

    init(
        defaultSavedIDs: Set<String> = ["friendly", "paranormall-s1"],
        backendConfiguration: HFBackendConfiguration = HFBackendConfiguration(),
        backendService: HFBackendService? = nil,
        backendGateway: HFBackendGateway? = nil,
        authConfiguration: HFAuthConfiguration = HFAuthConfiguration(),
        authService: HFAuthService? = nil,
        librarySyncConfiguration: HFLibrarySyncConfiguration = HFLibrarySyncConfiguration(),
        downloadConfiguration: HFDownloadConfiguration = HFDownloadConfiguration(),
        entitlementConfiguration: HFEntitlementConfiguration = HFEntitlementConfiguration(),
        entitlementService: HFEntitlementService? = nil,
        streamingConfiguration: HFStreamingProviderConfiguration = HFStreamingProviderConfiguration()
    ) {
        let resolvedBackendService = backendService ?? HFBackendServiceFactory.make(configuration: backendConfiguration)
        let resolvedAuthService = authService ?? HFAuthServiceFactory.make(configuration: authConfiguration)
        let resolvedEntitlementService = entitlementService ?? HFEntitlementServiceFactory.make(configuration: entitlementConfiguration)
        self.backendConfiguration = backendConfiguration
        self.backendService = resolvedBackendService
        self.backendGateway = backendGateway ?? HFBackendGatewayFactory.make(configuration: backendConfiguration)
        self.authConfiguration = authConfiguration
        self.authService = resolvedAuthService
        self.identityKeychainStore = HFIdentityKeychainSessionStore()
        self.librarySyncConfiguration = librarySyncConfiguration
        self.downloadConfiguration = downloadConfiguration
        self.entitlementConfiguration = entitlementConfiguration
        self.entitlementService = resolvedEntitlementService
        self.streamingConfiguration = streamingConfiguration
        self.localPreviewPlaybackResolver = HFLocalPreviewPlaybackResolver(localPreviewIDs: Self.localPreviewStreamingIDs)
        self.remotePlaybackDescriptorGateway = HFRemotePlaybackDescriptorGateway(configuration: streamingConfiguration)
        self.entitlementPlaybackAdapter = HFBackendEntitlementPlaybackAdapter(
            endpointResolver: HFBackendEndpointResolver(
                backendConfiguration: backendConfiguration,
                entitlementConfiguration: entitlementConfiguration,
                streamingConfiguration: streamingConfiguration
            )
        )
        backendRuntimeStatus = resolvedBackendService.currentStatus()
        let defaults = UserDefaults.standard
        let seedProjects = Self.makeCreatorPublishingContents()
        let seedSnapshot = Self.makeInitialContentSnapshot(projects: seedProjects)
        let resolvedContentStorage = HFContentStorageLayer(defaults: defaults)
        let loadedContentSnapshot = resolvedContentStorage.loadSnapshot(seed: seedSnapshot)
        contentStorage = resolvedContentStorage
        contentSnapshot = loadedContentSnapshot
        catalogRuntimeSnapshot = .loading(reason: "Initial catalog load")
        identitySessionRuntime = .empty
        identityAccessRuntimeSnapshot = .signedOut(reason: "No secure identity session restored yet.")
        productionCatalogConfiguration = HFProductionCatalogBackendConfiguration()
        productionCatalogRuntimeSnapshot = .localFallback(snapshot: loadedContentSnapshot, reason: "Production catalog backend disabled. Local content runtime remains active.")
        let storedCloudCatalogCursor = defaults.string(forKey: cloudCatalogSyncCursorKey)
        let storedCloudCatalogVersion = defaults.integer(forKey: cloudCatalogVersionKey)
        cloudCatalogSyncRuntimeSnapshot = .localCache(
            snapshot: loadedContentSnapshot,
            cursor: storedCloudCatalogCursor,
            version: storedCloudCatalogVersion,
            reason: "Offline cache ready before cloud sync."
        )
        creatorDraftSyncRuntimeSnapshot = .local(
            snapshot: loadedContentSnapshot,
            reason: "Creator draft sync disabled until the loopback backend is enabled."
        )
        let profiles = Self.makeLocalProfiles(defaults: defaults)
        let storedActiveProfileID = defaults.string(forKey: activeProfileKey)
        let resolvedActiveProfileID = profiles.contains { $0.id == storedActiveProfileID } ? storedActiveProfileID ?? profiles[0].id : profiles[0].id
        let resolvedAuthProfile = profiles.first { $0.id == resolvedActiveProfileID } ?? profiles[0]
        localProfiles = profiles
        activeProfileID = resolvedActiveProfileID
        authRuntimeStatus = resolvedAuthService.currentStatus(localProfile: resolvedAuthProfile)
        entitlementRuntimeStatus = resolvedEntitlementService.runtimeStatus(userID: resolvedActiveProfileID, titleID: nil)
        savedMovieIDs = Self.loadProfileIDs(
            defaults: defaults,
            scopedKey: Self.scopedKey(savedKey, resolvedActiveProfileID),
            fallbackKey: savedKey,
            fallbackIDs: defaultSavedIDs
        )
        downloadedMovieIDs = Self.loadProfileIDs(
            defaults: defaults,
            scopedKey: Self.scopedKey(downloadsKey, resolvedActiveProfileID),
            fallbackKey: downloadsKey,
            fallbackIDs: Set(HFMockData.movies.filter(\.isDownloaded).map(\.id))
        )
        recentSearches = defaults.stringArray(forKey: recentSearchesKey) ?? HFMockData.searchSuggestions.prefix(3).map(\.title)
        localConnectUpdateDraft = "The Friendly watch-night prompt is ready for local review."
        localConnectUpdates = defaults.stringArray(forKey: connectUpdatesKey) ?? [
            "Draft: Invite viewers to choose who they would watch The Friendly with.",
            "Preview: Share a behind-the-scenes note before premiere week."
        ]
        creatorPublishingContents = loadedContentSnapshot.publishingProjects
        let savedLaunchStates = defaults.array(forKey: launchChecklistKey) as? [Bool]
        launchChecklistStates = savedLaunchStates?.count == launchChecklistItems.count ? savedLaunchStates ?? [] : Array(repeating: false, count: launchChecklistItems.count)
        generatedDeliverySummary = ""
        lastPlayerMovieID = defaults.string(forKey: lastPlayerMovieKey)
        selectedAudienceChannelID = "premiere-updates"
        backendEntitlementRequestState = entitlementPlaybackAdapter.runtimeState
        backendPlaybackDescriptorRequestState = entitlementPlaybackAdapter.runtimeState == .notConfigured ? .localPreviewFallbackActive : entitlementPlaybackAdapter.runtimeState
        lastPlaybackDescriptorAuditContext = .localFallback(
            movieID: continueWatchingMovie.id,
            detail: "Staging backend not configured. Local Preview fallback active."
        )
        seedLocalMediaImportIfRequested()
        seedMediaInspectionIfRequested()
        seedLocalReleasePackageIfRequested()
        refreshMediaInspectionPreflight()
        rebuildCatalogRuntime(reason: "Initial local catalog load")
        restoreIdentityAccessSessionFromKeychain(reason: "Initial secure session restore")
        rebuildIdentitySessionRuntime(reason: "Initial local session load")
        if productionCatalogConfiguration.isRemoteEnabled {
            let launchArguments = ProcessInfo.processInfo.arguments
            Task {
                await self.refreshProductionCatalogRuntime()
                await self.refreshCloudCatalogSync(full: true)
                if launchArguments.contains("--hf-cloud-catalog-delta") {
                    await self.refreshCloudCatalogDeltaSync()
                }
                if launchArguments.contains("--hf-start-creator-draft-sync")
                    || launchArguments.contains("--hf-draft-sync-queue")
                    || launchArguments.contains("--hf-draft-sync-conflict")
                    || launchArguments.contains("--hf-draft-sync-revisions") {
                    await self.refreshCreatorDraftRemoteSync()
                }
            }
        }
    }

    var backendStatus: HFBackendServiceStatus {
        backendRuntimeStatus.status
    }

    var accountRuntimeStatus: HFAuthRuntimeStatus {
        authRuntimeStatus
    }

    var accountBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "account", fallback: backendService.accountStatus())
    }

    var libraryBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "library", fallback: backendService.libraryStatus())
    }

    var downloadsBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "downloads", fallback: backendService.downloadsStatus())
    }

    var paymentBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "payments", fallback: backendService.paymentStatus())
    }

    var creatorStudioBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "creator-studio", fallback: backendService.creatorStudioStatus())
    }

    var socialKitBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "social-kit", fallback: backendService.socialKitStatus())
    }

    var vodBackendStatus: HFBackendServiceStatus {
        backendServiceStatus(id: "vod-package", fallback: backendService.vodPackageStatus())
    }

    var backendServiceStatuses: [HFBackendServiceStatus] {
        backendRuntimeStatus.services.filter { $0.id != "payments" && $0.id != "downloads" } + [
            librarySyncBackendServiceStatus,
            downloadPolicyBackendServiceStatus,
            entitlementBackendServiceStatus,
            backendEntitlementValidationServiceStatus,
            playbackDescriptorBackendServiceStatus,
            backendEntitlementAdapterServiceStatus,
            backendPlaybackDescriptorAdapterServiceStatus,
            serverSideCloudflareSigningBackendServiceStatus,
            streamingBackendServiceStatus
        ]
    }

    var librarySyncRuntimeStatus: HFLibrarySyncRuntimeStatus {
        makeLibrarySyncService().runtimeStatus(userID: activeProfileID)
    }

    var librarySyncSnapshot: HFLibrarySyncSnapshot {
        makeLocalLibrarySyncAdapter().snapshot(userID: activeProfileID)
    }

    var librarySyncBackendServiceStatus: HFBackendServiceStatus {
        let status = librarySyncRuntimeStatus
        let backendState: HFBackendConnectionState = status.state == .configured ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "library-sync",
            title: "Library Sync",
            detail: status.detail,
            state: backendState,
            statusLabel: status.statusLabel,
            systemImage: "bookmark.rectangle.stack.fill",
            accessibilityIdentifier: "hf.library.syncStatus"
        )
    }

    var entitlementBackendServiceStatus: HFBackendServiceStatus {
        let accessState = entitlementRuntimeStatus.accessState
        let backendState: HFBackendConnectionState = accessState == .entitlementConfigured ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "payments",
            title: "Entitlements / Payments",
            detail: "\(entitlementRuntimeStatus.detail) StoreKit product mapping staged; Cloudflare playback requires backend descriptor and entitlement validation.",
            state: backendState,
            statusLabel: accessState.statusLabel,
            systemImage: "creditcard.and.123",
            accessibilityIdentifier: "hf.entitlement.status"
        )
    }

    var downloadPolicyRuntimeStatus: HFDownloadRuntimeStatus {
        makeDownloadEligibilityService(
            streamingStatus: streamingProviderStatus.status,
            entitlementStatus: entitlementRuntimeStatus.accessState
        )
        .runtimeStatus(localOfflineCount: downloadedMovies.count)
    }

    var downloadPolicyBackendServiceStatus: HFBackendServiceStatus {
        let status = downloadPolicyRuntimeStatus
        let backendState: HFBackendConnectionState = status.providerStatus == .policyConfigured ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "downloads",
            title: "Downloads",
            detail: status.detail,
            state: backendState,
            statusLabel: status.statusLabel,
            systemImage: "arrow.down.circle.fill",
            accessibilityIdentifier: "hf.backendStatus.downloads"
        )
    }

    var streamingProviderStatus: HFStreamingProviderStatus {
        let descriptor = playbackDescriptor(for: continueWatchingMovie)
        return streamingProviderStatus(for: descriptor)
    }

    var streamingBackendServiceStatus: HFBackendServiceStatus {
        let providerStatus = streamingProviderStatus
        let backendState: HFBackendConnectionState = providerStatus.status == .stagingDescriptorReady ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "streaming-provider",
            title: "Streaming Provider",
            detail: providerStatus.detail,
            state: backendState,
            statusLabel: providerStatus.status.statusLabel,
            systemImage: providerStatus.systemImage,
            accessibilityIdentifier: providerStatus.accessibilityIdentifier
        )
    }

    var playbackDescriptorBackendServiceStatus: HFBackendServiceStatus {
        let contract = backendPlaybackDescriptorContract(for: continueWatchingMovie)
        let backendState: HFBackendConnectionState = contract.statusLabel == "Playback descriptor contract ready" ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "playback-descriptor",
            title: "Playback Descriptor",
            detail: "\(contract.playbackDescriptorResponse.detail). Backend playback descriptor endpoint required. No Cloudflare token in app.",
            state: backendState,
            statusLabel: contract.statusLabel,
            systemImage: "lock.rectangle.stack.fill",
            accessibilityIdentifier: "hf.backendStatus.playbackDescriptor"
        )
    }

    var backendEntitlementValidationServiceStatus: HFBackendServiceStatus {
        let contract = backendPlaybackDescriptorContract(for: continueWatchingMovie)
        let backendState: HFBackendConnectionState = contract.entitlementValidationResponse.entitlementStatus == .approved ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "entitlement-validation",
            title: "Entitlement Validation",
            detail: "Backend entitlement validation required. \(contract.entitlementValidationResponse.detail).",
            state: backendState,
            statusLabel: contract.entitlementValidationResponse.entitlementStatus.statusLabel,
            systemImage: "checkmark.shield.fill",
            accessibilityIdentifier: "hf.backendStatus.entitlementValidation"
        )
    }

    var backendEntitlementAdapterServiceStatus: HFBackendServiceStatus {
        let backendState: HFBackendConnectionState = entitlementPlaybackAdapter.canContactStagingEndpoint ? .backendConfigured : .localMode
        return HFBackendServiceStatus(
            id: "entitlement-adapter",
            title: "Entitlement Adapter",
            detail: "Validating entitlement uses runtime endpoint config only. No request payloads, response bodies, or playback references are logged.",
            state: backendState,
            statusLabel: backendEntitlementRequestState.statusLabel,
            systemImage: "shield.lefthalf.filled",
            accessibilityIdentifier: "hf.backendStatus.entitlementAdapter"
        )
    }

    var backendPlaybackDescriptorAdapterServiceStatus: HFBackendServiceStatus {
        let backendState: HFBackendConnectionState = activeStagingPlaybackDescriptor == nil ? .localMode : .backendConfigured
        return HFBackendServiceStatus(
            id: "playback-descriptor-adapter",
            title: "Playback Descriptor Adapter",
            detail: "Requesting playback descriptor follows entitlement approval and keeps the returned reference in memory only.",
            state: backendState,
            statusLabel: backendPlaybackDescriptorRequestState.statusLabel,
            systemImage: "rectangle.connected.to.line.below",
            accessibilityIdentifier: "hf.backendStatus.playbackDescriptorAdapter"
        )
    }

    var serverSideCloudflareSigningBackendServiceStatus: HFBackendServiceStatus {
        HFBackendServiceStatus(
            id: "server-side-cloudflare-signing",
            title: "Server-side Cloudflare Signing",
            detail: "Server-side Cloudflare signing required. No Cloudflare token in app.",
            state: .localMode,
            statusLabel: "Server-side Cloudflare signing required",
            systemImage: "lock.shield.fill",
            accessibilityIdentifier: "hf.backendStatus.serverSideCloudflareSigning"
        )
    }

    var backendRuntimeConfigRows: [HFBackendRuntimeConfigRow] {
        [
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.modeKey,
                title: HFBackendConfiguration.modeKey,
                status: backendConfiguration.requestedMode == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.baseURLKey,
                title: HFBackendConfiguration.baseURLKey,
                status: backendConfiguration.backendBaseURL == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.projectURLKey,
                title: HFBackendConfiguration.projectURLKey,
                status: backendConfiguration.projectURL == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFBackendConfiguration.anonKeyKey,
                title: HFBackendConfiguration.anonKeyKey,
                status: backendConfiguration.anonKey == nil ? "Not set" : "Present"
            )
        ]
    }

    var streamingRuntimeConfigRows: [HFBackendRuntimeConfigRow] {
        [
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.providerKey,
                title: HFStreamingProviderConfiguration.providerKey,
                status: streamingConfiguration.requestedProvider == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.modeKey,
                title: HFStreamingProviderConfiguration.modeKey,
                status: streamingConfiguration.requestedMode == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.descriptorBaseURLKey,
                title: HFStreamingProviderConfiguration.descriptorBaseURLKey,
                status: streamingConfiguration.descriptorBaseURL == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.cloudflareAccountIDKey,
                title: HFStreamingProviderConfiguration.cloudflareAccountIDKey,
                status: streamingConfiguration.cloudflareAccountID == nil ? "Not set" : "Present"
            ),
            HFBackendRuntimeConfigRow(
                id: HFStreamingProviderConfiguration.muxEnvironmentKey,
                title: HFStreamingProviderConfiguration.muxEnvironmentKey,
                status: streamingConfiguration.muxEnvironmentKey == nil ? "Not set" : "Present"
            )
        ]
    }

    var backendHealthSummary: HFBackendServiceStatus {
        HFBackendServiceStatus(
            id: "health",
            title: "Health Check",
            detail: healthDetail(for: backendRuntimeStatus.connectionState),
            state: backendRuntimeStatus.connectionState,
            statusLabel: healthLabel(for: backendRuntimeStatus.connectionState),
            systemImage: healthSystemImage(for: backendRuntimeStatus.connectionState),
            accessibilityIdentifier: healthAccessibilityIdentifier(for: backendRuntimeStatus.connectionState)
        )
    }

    var backendLocalFallbackNote: String {
        switch backendRuntimeStatus.connectionState {
        case .localMode, .localPreview, .backendNotConfigured:
            return "Local fallback active. Backend staging is not contacted without runtime config."
        case .missingCredentials, .credentialsMissing:
            return "Local fallback active until complete runtime config is provided."
        case .stagingUnavailable:
            return "Local fallback active because staging health is unavailable."
        default:
            return "Local fallback remains available for demos and rollback."
        }
    }

    func refreshBackendRuntimeStatus() async {
        guard backendConfiguration.hasAnyRuntimeConfig else {
            backendRuntimeStatus = backendService.currentStatus(for: .localMode)
            return
        }

        guard backendConfiguration.hasCompleteRuntimeConfig else {
            backendRuntimeStatus = backendService.currentStatus(for: .missingCredentials)
            return
        }

        backendRuntimeStatus = backendService.currentStatus(for: .backendConfigured)

        do {
            _ = try await backendGateway.health()
            backendRuntimeStatus = backendService.currentStatus(for: .stagingReachable)
        } catch {
            backendRuntimeStatus = backendService.currentStatus(for: .stagingUnavailable)
        }
    }

    var productionCatalogRuntimeStatusRows: [HFContentRepositoryMetric] {
        [
            HFContentRepositoryMetric(
                id: "production-catalog-state",
                title: "Catalog Backend",
                value: productionCatalogRuntimeSnapshot.statusLabel,
                detail: productionCatalogRuntimeSnapshot.detail,
                systemImage: productionCatalogRuntimeSnapshot.state == .ready ? "network" : "externaldrive.fill"
            ),
            HFContentRepositoryMetric(
                id: "production-catalog-titles",
                title: "Titles",
                value: "\(productionCatalogRuntimeSnapshot.titleCount)",
                detail: "\(productionCatalogRuntimeSnapshot.creatorCount) creators, \(productionCatalogRuntimeSnapshot.seriesCount) series, \(productionCatalogRuntimeSnapshot.collectionCount) collections.",
                systemImage: "film.stack.fill"
            ),
            HFContentRepositoryMetric(
                id: "production-catalog-source",
                title: "Source",
                value: productionCatalogRuntimeSnapshot.source,
                detail: productionCatalogRuntimeSnapshot.endpoint,
                systemImage: "rectangle.connected.to.line.below"
            ),
            HFContentRepositoryMetric(
                id: "production-catalog-fallback",
                title: "Local Fallback",
                value: productionCatalogRuntimeSnapshot.state == .ready ? "Available" : "Active",
                detail: productionCatalogRuntimeSnapshot.lastError ?? "Local-only mode remains available when the backend flag is absent or the loopback service is unavailable.",
                systemImage: "arrow.uturn.backward.circle.fill"
            )
        ]
    }

    var productionCatalogEndpointRows: [HFProductionCatalogEndpointRow] {
        [
            HFProductionCatalogEndpointRow(id: "health", title: "Health", path: "/health", status: "GET", systemImage: "heart.text.square.fill"),
            HFProductionCatalogEndpointRow(id: "ready", title: "Readiness", path: "/ready", status: "GET", systemImage: "checkmark.seal.fill"),
            HFProductionCatalogEndpointRow(id: "catalog", title: "Catalog", path: "/v1/catalog", status: "GET", systemImage: "film.stack.fill"),
            HFProductionCatalogEndpointRow(id: "catalog-sync", title: "Catalog Sync", path: "/v1/catalog/sync", status: "GET", systemImage: "arrow.triangle.2.circlepath"),
            HFProductionCatalogEndpointRow(id: "catalog-delta", title: "Catalog Delta", path: "/v1/catalog/delta", status: "GET", systemImage: "point.3.connected.trianglepath.dotted"),
            HFProductionCatalogEndpointRow(id: "content", title: "Content Detail", path: "/v1/content/:id", status: "GET", systemImage: "play.rectangle.fill"),
            HFProductionCatalogEndpointRow(id: "creator", title: "Creator Detail", path: "/v1/creators/:id", status: "GET", systemImage: "person.crop.rectangle.stack.fill"),
            HFProductionCatalogEndpointRow(id: "collection", title: "Collection Detail", path: "/v1/collections/:id", status: "GET", systemImage: "rectangle.grid.2x2.fill")
        ]
    }

    var cloudCatalogSyncStatusRows: [HFContentRepositoryMetric] {
        [
            HFContentRepositoryMetric(
                id: "cloud-sync-state",
                title: "Cloud Sync",
                value: cloudCatalogSyncRuntimeSnapshot.statusLabel,
                detail: cloudCatalogSyncRuntimeSnapshot.detail,
                systemImage: cloudCatalogSyncRuntimeSnapshot.state == .synced ? "checkmark.icloud.fill" : "externaldrive.fill"
            ),
            HFContentRepositoryMetric(
                id: "cloud-sync-version",
                title: "Version",
                value: "\(cloudCatalogSyncRuntimeSnapshot.catalogVersion)",
                detail: "Cursor: \(cloudCatalogSyncRuntimeSnapshot.cursor ?? "not set")",
                systemImage: "number.square.fill"
            ),
            HFContentRepositoryMetric(
                id: "cloud-sync-cache",
                title: "Offline Cache",
                value: cloudCatalogSyncRuntimeSnapshot.cachePolicy,
                detail: "\(cloudCatalogSyncRuntimeSnapshot.titleCount) titles, \(cloudCatalogSyncRuntimeSnapshot.creatorCount) creators, \(cloudCatalogSyncRuntimeSnapshot.collectionCount) collections.",
                systemImage: "internaldrive.fill"
            ),
            HFContentRepositoryMetric(
                id: "cloud-sync-tombstones",
                title: "Tombstones",
                value: "\(cloudCatalogSyncRuntimeSnapshot.tombstoneCount)",
                detail: "Deleted backend records are removed from the local catalog cache during sync.",
                systemImage: "trash.slash.fill"
            )
        ]
    }

    var cloudCatalogSyncDiagnostics: [HFCloudCatalogSyncDiagnosticRecord] {
        [
            HFCloudCatalogSyncDiagnosticRecord(
                id: "state",
                title: "Runtime State",
                detail: cloudCatalogSyncRuntimeSnapshot.detail,
                status: cloudCatalogSyncRuntimeSnapshot.statusLabel,
                systemImage: "waveform.path.ecg.rectangle.fill"
            ),
            HFCloudCatalogSyncDiagnosticRecord(
                id: "cursor",
                title: "Sync Cursor",
                detail: cloudCatalogSyncRuntimeSnapshot.cursor ?? "No cursor persisted yet.",
                status: "Version \(cloudCatalogSyncRuntimeSnapshot.catalogVersion)",
                systemImage: "arrow.left.arrow.right.square.fill"
            ),
            HFCloudCatalogSyncDiagnosticRecord(
                id: "cache",
                title: "Stale-While-Revalidate",
                detail: "Home, Search, Discovery, Library, and Movie Detail continue reading the durable cache if the backend is unavailable.",
                status: cloudCatalogSyncRuntimeSnapshot.cachePolicy,
                systemImage: "externaldrive.badge.checkmark"
            ),
            HFCloudCatalogSyncDiagnosticRecord(
                id: "error",
                title: "Last Error",
                detail: cloudCatalogSyncRuntimeSnapshot.lastError ?? "No sync error recorded.",
                status: cloudCatalogSyncRuntimeSnapshot.lastError == nil ? "Clean" : "Fallback",
                systemImage: cloudCatalogSyncRuntimeSnapshot.lastError == nil ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
            )
        ]
    }

    var creatorDraftSyncStatusRows: [HFContentRepositoryMetric] {
        [
            HFContentRepositoryMetric(
                id: "draft-sync-state",
                title: "Draft Sync",
                value: creatorDraftSyncRuntimeSnapshot.statusLabel,
                detail: creatorDraftSyncRuntimeSnapshot.detail,
                systemImage: creatorDraftSyncRuntimeSnapshot.state == .synced ? "checkmark.icloud.fill" : "externaldrive.fill"
            ),
            HFContentRepositoryMetric(
                id: "draft-sync-remote",
                title: "Remote Drafts",
                value: "\(creatorDraftSyncRuntimeSnapshot.remoteDraftCount)",
                detail: "Endpoint: \(creatorDraftSyncRuntimeSnapshot.endpoint)",
                systemImage: "doc.text.fill"
            ),
            HFContentRepositoryMetric(
                id: "draft-sync-conflicts",
                title: "Conflicts",
                value: "\(creatorDraftSyncRuntimeSnapshot.conflictCount)",
                detail: creatorDraftSyncRuntimeSnapshot.lastError ?? "No active conflict.",
                systemImage: creatorDraftSyncRuntimeSnapshot.conflictCount == 0 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
            ),
            HFContentRepositoryMetric(
                id: "draft-sync-revisions",
                title: "Revisions",
                value: "\(creatorDraftSyncRuntimeSnapshot.revisionCount)",
                detail: "\(creatorDraftSyncRuntimeSnapshot.queuedEditCount) queue audit records visible.",
                systemImage: "clock.arrow.circlepath"
            )
        ]
    }

    func refreshCreatorDraftRemoteSync() async {
        guard productionCatalogConfiguration.isRemoteEnabled else {
            creatorDraftSyncRuntimeSnapshot = .local(
                snapshot: contentSnapshot,
                reason: "Creator draft sync disabled. Use HF_CINEMA_BACKEND_MODE=remote with the loopback backend to enable P32A draft persistence."
            )
            return
        }

        creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
            state: .syncing,
            endpoint: productionCatalogConfiguration.baseURL.absoluteString,
            remoteDraftCount: creatorDraftSyncRuntimeSnapshot.remoteDraftCount,
            queuedEditCount: creatorDraftSyncQueueRecords.count,
            conflictCount: 0,
            revisionCount: creatorDraftRevisionRecords.count,
            detail: "Fetching creator drafts through the remote publishing repository.",
            lastError: nil,
            updatedAtLabel: "Syncing"
        )

        do {
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let response = try await client.listDrafts(sessionID: sessionID)
            applyRemoteDraftList(response)
        } catch {
            creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
                state: .queued,
                endpoint: "Local publishing repository",
                remoteDraftCount: creatorPublishingContents.count,
                queuedEditCount: creatorDraftSyncQueueRecords.count,
                conflictCount: 0,
                revisionCount: creatorDraftRevisionRecords.count,
                detail: "Remote draft sync unavailable. Local edits remain queued through the content snapshot.",
                lastError: error.localizedDescription,
                updatedAtLabel: contentSnapshot.updatedAtLabel
            )
        }
    }

    @discardableResult
    func createRemoteCreatorDraft(
        title: String,
        description: String,
        creator: String,
        genre: String,
        tags: [String],
        runtime: String
    ) async -> HFCreatorPublishingContent? {
        let localDraft = HFCreatorPublishingContent(
            id: "remote-draft-\(Self.slug(title))-\(creatorPublishingContents.count + 1)",
            title: title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled Remote Draft" : title,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Creator draft prepared for remote publishing persistence." : description,
            posterAssetName: nil,
            trailerStatus: .ready,
            creator: creator.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? activeViewingProfile.displayName : creator,
            genre: genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Drama" : genre,
            tags: tags.isEmpty ? ["Creator", "Draft"] : tags,
            runtime: runtime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Draft" : runtime,
            releaseState: .draft,
            posterStatus: .ready,
            metadataStatus: .ready,
            artworkStatus: .ready,
            updatedAtLabel: "Remote draft pending"
        )

        guard productionCatalogConfiguration.isRemoteEnabled else {
            let draft = createCreatorDraft(
                title: localDraft.title,
                description: localDraft.description,
                creator: localDraft.creator,
                genre: localDraft.genre,
                tags: localDraft.tags,
                runtime: localDraft.runtime
            )
            creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
                state: .queued,
                endpoint: "Local publishing repository",
                remoteDraftCount: creatorPublishingContents.count,
                queuedEditCount: creatorDraftSyncQueueRecords.count + 1,
                conflictCount: 0,
                revisionCount: creatorDraftRevisionRecords.count,
                detail: "Remote backend disabled; draft created locally and queued for later sync.",
                lastError: nil,
                updatedAtLabel: draft.updatedAtLabel
            )
            return draft
        }

        do {
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let response = try await client.createDraft(localDraft, sessionID: sessionID)
            applyRemoteDraftMutation(response)
            return response.draft.publishingContent
        } catch {
            creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
                state: .queued,
                endpoint: "Local publishing repository",
                remoteDraftCount: creatorPublishingContents.count,
                queuedEditCount: creatorDraftSyncQueueRecords.count + 1,
                conflictCount: 0,
                revisionCount: creatorDraftRevisionRecords.count,
                detail: "Create draft request failed; local repository remains authoritative until retry.",
                lastError: error.localizedDescription,
                updatedAtLabel: contentSnapshot.updatedAtLabel
            )
            return nil
        }
    }

    func updateRemoteCreatorDraft(
        id: String,
        title: String,
        description: String,
        creator: String,
        genre: String,
        tags: [String],
        runtime: String,
        posterStatus: HFCreatorPublishingAssetStatus,
        trailerStatus: HFCreatorPublishingAssetStatus,
        metadataStatus: HFCreatorPublishingAssetStatus,
        artworkStatus: HFCreatorPublishingAssetStatus
    ) async {
        guard let existing = loadCreatorDraft(id: id) else { return }
        var draft = existing
        draft.title = title
        draft.description = description
        draft.creator = creator
        draft.genre = genre
        draft.tags = tags
        draft.runtime = runtime
        draft.posterStatus = posterStatus
        draft.trailerStatus = trailerStatus
        draft.metadataStatus = metadataStatus
        draft.artworkStatus = artworkStatus

        guard productionCatalogConfiguration.isRemoteEnabled else {
            updateCreatorDraft(id: id, title: title, description: description, creator: creator, genre: genre, tags: tags, runtime: runtime, posterStatus: posterStatus, trailerStatus: trailerStatus, metadataStatus: metadataStatus, artworkStatus: artworkStatus)
            return
        }

        do {
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let response = try await client.updateDraft(draft, baseVersion: creatorDraftRemoteVersions[id] ?? 1, sessionID: sessionID)
            applyRemoteDraftMutation(response)
        } catch {
            setRemoteDraftConflict(error: error, detail: "Draft update could not be applied. Resolve the server version before saving again.")
        }
    }

    func archiveRemoteCreatorDraft(id: String) async {
        guard productionCatalogConfiguration.isRemoteEnabled else {
            archiveCreatorDraft(id: id)
            return
        }
        do {
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let response = try await client.archiveDraft(id: id, baseVersion: creatorDraftRemoteVersions[id] ?? 1, sessionID: sessionID)
            applyRemoteDraftMutation(response)
        } catch {
            setRemoteDraftConflict(error: error, detail: "Archive request needs the latest remote version.")
        }
    }

    func restoreRemoteCreatorDraft(id: String) async {
        guard productionCatalogConfiguration.isRemoteEnabled else { return }
        do {
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let response = try await client.restoreDraft(id: id, baseVersion: creatorDraftRemoteVersions[id] ?? 1, sessionID: sessionID)
            applyRemoteDraftMutation(response)
        } catch {
            setRemoteDraftConflict(error: error, detail: "Restore request needs the latest remote version.")
        }
    }

    func refreshCreatorDraftRevisionHistory(id: String? = nil) async {
        guard productionCatalogConfiguration.isRemoteEnabled else { return }
        do {
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let draftID = id ?? creatorPublishingContents.first?.id ?? "project-behind-the-vision"
            let response = try await client.revisionHistory(id: draftID, sessionID: sessionID)
            creatorDraftRevisionRecords = response.revisions
            creatorDraftSyncQueueRecords = response.auditRecords ?? creatorDraftSyncQueueRecords
            creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
                state: .synced,
                endpoint: productionCatalogConfiguration.baseURL.absoluteString,
                remoteDraftCount: creatorPublishingContents.count,
                queuedEditCount: creatorDraftSyncQueueRecords.count,
                conflictCount: 0,
                revisionCount: response.revisions.count,
                detail: "Revision history loaded from remote publishing persistence.",
                lastError: nil,
                updatedAtLabel: "Version \(response.version)"
            )
        } catch {
            setRemoteDraftConflict(error: error, detail: "Revision history could not be loaded.")
        }
    }

    func refreshCreatorDraftSyncQueue() async {
        guard productionCatalogConfiguration.isRemoteEnabled else { return }
        do {
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let response = try await client.syncQueue(sessionID: sessionID)
            creatorDraftSyncQueueRecords = response.queuedEdits
            creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
                state: .synced,
                endpoint: productionCatalogConfiguration.baseURL.absoluteString,
                remoteDraftCount: creatorPublishingContents.count,
                queuedEditCount: response.queuedEdits.count,
                conflictCount: 0,
                revisionCount: creatorDraftRevisionRecords.count,
                detail: "Sync queue loaded. Merge strategy: \(response.mergeStrategy).",
                lastError: nil,
                updatedAtLabel: "Queue ready"
            )
        } catch {
            setRemoteDraftConflict(error: error, detail: "Draft sync queue could not be loaded.")
        }
    }

    func simulateCreatorDraftRemoteConflict() async {
        guard productionCatalogConfiguration.isRemoteEnabled else {
            creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
                state: .conflict,
                endpoint: "Local publishing repository",
                remoteDraftCount: creatorPublishingContents.count,
                queuedEditCount: creatorDraftSyncQueueRecords.count,
                conflictCount: 1,
                revisionCount: creatorDraftRevisionRecords.count,
                detail: "Conflict simulation requires the loopback publishing backend.",
                lastError: "Remote backend disabled",
                updatedAtLabel: "Conflict preview"
            )
            return
        }
        do {
            if creatorPublishingContents.isEmpty {
                _ = await createRemoteCreatorDraft(
                    title: "Conflict Simulation Draft",
                    description: "A remote draft created to exercise conflict handling.",
                    creator: activeViewingProfile.displayName,
                    genre: "Drama",
                    tags: ["Conflict", "Draft"],
                    runtime: "41m"
                )
            }
            let client = HFRemoteCreatorDraftAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            let sessionID = try await remotePublishingSessionID(client: client)
            let draft = creatorPublishingContents.first ?? createCreatorDraft(title: "Conflict Simulation Draft", description: "A local fallback draft for conflict simulation.", creator: activeViewingProfile.displayName, genre: "Drama", tags: ["Conflict"], runtime: "41m")
            _ = try await client.updateDraft(draft, baseVersion: 0, sessionID: sessionID)
        } catch {
            setRemoteDraftConflict(error: error, detail: "Concurrent edit detected. Server version remains authoritative until the creator reviews the conflict.")
        }
    }

    func refreshProductionCatalogRuntime() async {
        guard productionCatalogConfiguration.isRemoteEnabled else {
            productionCatalogRuntimeSnapshot = .localFallback(
                snapshot: contentSnapshot,
                reason: "Production catalog backend disabled. Set HF_CINEMA_BACKEND_MODE=remote or use --hf-production-backend-catalog to test loopback fetch."
            )
            return
        }

        productionCatalogRuntimeSnapshot = HFProductionCatalogRuntimeSnapshot(
            state: .fetching,
            source: "Loopback Backend",
            endpoint: productionCatalogConfiguration.baseURL.absoluteString,
            titleCount: productionCatalogRuntimeSnapshot.titleCount,
            creatorCount: productionCatalogRuntimeSnapshot.creatorCount,
            seriesCount: productionCatalogRuntimeSnapshot.seriesCount,
            collectionCount: productionCatalogRuntimeSnapshot.collectionCount,
            detail: "Fetching read-only catalog from the configured P29A backend foundation.",
            lastError: nil,
            updatedAtLabel: "Fetching"
        )

        do {
            let response = try await HFRemoteProductionCatalogAPIClient(baseURL: productionCatalogConfiguration.baseURL).fetchCatalog()
            productionCatalogRuntimeSnapshot = HFProductionCatalogRuntimeSnapshot(
                state: .ready,
                source: response.source,
                endpoint: productionCatalogConfiguration.baseURL.absoluteString,
                titleCount: response.totalTitles,
                creatorCount: response.totalCreators,
                seriesCount: response.totalSeries,
                collectionCount: response.totalCollections,
                detail: "Read-only catalog fetched through URLSession and decoded into local DTOs. Local repository fallback remains intact.",
                lastError: nil,
                updatedAtLabel: response.generatedAt
            )
        } catch {
            let fallback = try? await HFLocalProductionCatalogAPIClient(snapshot: contentSnapshot).fetchCatalog()
            productionCatalogRuntimeSnapshot = HFProductionCatalogRuntimeSnapshot(
                state: .localFallback,
                source: fallback?.source ?? "Local Content Snapshot",
                endpoint: "Local repository fallback",
                titleCount: fallback?.totalTitles ?? contentSnapshot.movies.count,
                creatorCount: fallback?.totalCreators ?? contentSnapshot.creators.count,
                seriesCount: fallback?.totalSeries ?? contentSnapshot.series.count,
                collectionCount: fallback?.totalCollections ?? contentSnapshot.collections.count,
                detail: "Loopback catalog fetch failed; local content runtime remains functional.",
                lastError: error.localizedDescription,
                updatedAtLabel: "Fallback after backend request"
            )
        }
    }

    func refreshCloudCatalogSync(full: Bool = true) async {
        guard productionCatalogConfiguration.isRemoteEnabled else {
            cloudCatalogSyncRuntimeSnapshot = .localCache(
                snapshot: contentSnapshot,
                cursor: UserDefaults.standard.string(forKey: cloudCatalogSyncCursorKey),
                version: UserDefaults.standard.integer(forKey: cloudCatalogVersionKey),
                reason: "Cloud catalog sync disabled. Local durable cache remains the catalog source."
            )
            return
        }

        let storedCursor = UserDefaults.standard.string(forKey: cloudCatalogSyncCursorKey)
        cloudCatalogSyncRuntimeSnapshot = HFCloudCatalogSyncRuntimeSnapshot(
            state: .syncing,
            source: "Loopback Cloud Catalog",
            cursor: storedCursor,
            catalogVersion: cloudCatalogSyncRuntimeSnapshot.catalogVersion,
            titleCount: contentSnapshot.movies.count,
            creatorCount: contentSnapshot.creators.count,
            seriesCount: contentSnapshot.series.count,
            collectionCount: contentSnapshot.collections.count,
            tombstoneCount: cloudCatalogSyncRuntimeSnapshot.tombstoneCount,
            cachePolicy: "stale-while-revalidate",
            detail: full ? "Starting full catalog sync from the backend service." : "Starting delta catalog sync from the last cursor.",
            lastError: nil,
            updatedAtLabel: "Syncing"
        )

        do {
            let client = HFRemoteProductionCatalogAPIClient(baseURL: productionCatalogConfiguration.baseURL)
            if full {
                let response = try await client.fetchCatalogSync(cursor: storedCursor)
                applyCloudCatalogFullSync(response)
            } else {
                let response = try await client.fetchCatalogDelta(cursor: storedCursor)
                applyCloudCatalogDeltaSync(response)
            }
        } catch {
            cloudCatalogSyncRuntimeSnapshot = HFCloudCatalogSyncRuntimeSnapshot(
                state: contentSnapshot.movies.isEmpty ? .failed : .staleCache,
                source: "Durable Local Cache",
                cursor: storedCursor,
                catalogVersion: UserDefaults.standard.integer(forKey: cloudCatalogVersionKey),
                titleCount: contentSnapshot.movies.count,
                creatorCount: contentSnapshot.creators.count,
                seriesCount: contentSnapshot.series.count,
                collectionCount: contentSnapshot.collections.count,
                tombstoneCount: cloudCatalogSyncRuntimeSnapshot.tombstoneCount,
                cachePolicy: "stale-while-revalidate",
                detail: "Cloud catalog request failed; cached catalog remains available.",
                lastError: error.localizedDescription,
                updatedAtLabel: contentSnapshot.updatedAtLabel
            )
        }
    }

    func refreshCloudCatalogDeltaSync() async {
        await refreshCloudCatalogSync(full: false)
    }

    private func applyCloudCatalogFullSync(_ response: HFProductionCatalogResponse) {
        let movies = Self.uniqueMovies(response.movies.map(\.movie))
        let creators = Self.uniqueCreators(response.creators.map(\.creator))
        let series = Self.uniqueSeries(response.series.compactMap { $0.series(using: movies) })
        let collections = Self.uniqueCategories(response.collections.map { $0.collection(using: movies) })
        var nextSnapshot = contentSnapshot
        nextSnapshot.movies = movies
        nextSnapshot.creators = creators
        nextSnapshot.series = series
        nextSnapshot.collections = collections
        nextSnapshot.updatedAtLabel = "Cloud catalog sync \(response.catalogVersion ?? 0)"
        persistCloudCatalogSnapshot(
            nextSnapshot,
            source: response.source,
            cursor: response.syncCursor,
            version: response.catalogVersion ?? 0,
            tombstoneCount: response.tombstones?.count ?? 0,
            detail: "Full sync replaced catalog entities while preserving creator drafts, project manifests, media metadata, and release packages."
        )
    }

    private func applyCloudCatalogDeltaSync(_ response: HFProductionCatalogDeltaResponse) {
        var movieMap = Dictionary(uniqueKeysWithValues: contentSnapshot.movies.map { ($0.id, $0) })
        var creatorMap = Dictionary(uniqueKeysWithValues: contentSnapshot.creators.map { ($0.id, $0) })
        var seriesMap = Dictionary(uniqueKeysWithValues: contentSnapshot.series.map { ($0.id, $0) })
        var collectionMap = Dictionary(uniqueKeysWithValues: contentSnapshot.collections.map { ($0.id, $0) })

        for tombstone in response.tombstones {
            switch tombstone.entityType.lowercased() {
            case "movie", "title":
                movieMap.removeValue(forKey: tombstone.entityID)
            case "creator":
                creatorMap.removeValue(forKey: tombstone.entityID)
            case "series":
                seriesMap.removeValue(forKey: tombstone.entityID)
            case "collection":
                collectionMap.removeValue(forKey: tombstone.entityID)
            default:
                break
            }
        }

        for movie in response.movies.map(\.movie) {
            movieMap[movie.id] = movie
        }
        for creator in response.creators.map(\.creator) {
            creatorMap[creator.id] = creator
        }

        let movies = Self.uniqueMovies(Array(movieMap.values)).sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        for series in response.series.compactMap({ $0.series(using: movies) }) {
            seriesMap[series.id] = series
        }
        for collection in response.collections.map({ $0.collection(using: movies) }) {
            collectionMap[collection.id] = collection
        }

        var nextSnapshot = contentSnapshot
        nextSnapshot.movies = movies
        nextSnapshot.creators = Self.uniqueCreators(Array(creatorMap.values)).sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        nextSnapshot.series = Self.uniqueSeries(Array(seriesMap.values)).sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        nextSnapshot.collections = Self.uniqueCategories(Array(collectionMap.values)).sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        nextSnapshot.updatedAtLabel = "Cloud catalog delta \(response.catalogVersion)"
        persistCloudCatalogSnapshot(
            nextSnapshot,
            source: response.source,
            cursor: response.syncCursor,
            version: response.catalogVersion,
            tombstoneCount: response.tombstones.count,
            detail: "Delta sync applied upserts and tombstones without duplicating catalog records."
        )
    }

    private func remotePublishingSessionID(client: HFRemoteCreatorDraftAPIClient) async throws -> String {
        if let lastRemotePublishingSessionID { return lastRemotePublishingSessionID }
        let sessionID = try await client.createDevelopmentSession(role: "creator")
        lastRemotePublishingSessionID = sessionID
        return sessionID
    }

    private func applyRemoteDraftList(_ response: HFRemoteCreatorDraftListResponse) {
        for draft in response.drafts {
            upsertRemoteDraft(draft)
        }
        creatorDraftSyncQueueRecords = response.syncQueue ?? creatorDraftSyncQueueRecords
        creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
            state: .synced,
            endpoint: productionCatalogConfiguration.baseURL.absoluteString,
            remoteDraftCount: response.drafts.count,
            queuedEditCount: creatorDraftSyncQueueRecords.count,
            conflictCount: 0,
            revisionCount: response.revisionCount,
            detail: "Creator drafts synchronized through the remote PublishingRepository facade.",
            lastError: nil,
            updatedAtLabel: "Remote draft sync ready"
        )
        persistCreatorPublishingContents()
    }

    private func applyRemoteDraftMutation(_ response: HFRemoteCreatorDraftMutationResponse) {
        upsertRemoteDraft(response.draft)
        creatorDraftRevisionRecords = response.revisions
        creatorDraftSyncQueueRecords = response.auditRecords ?? creatorDraftSyncQueueRecords
        creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
            state: .synced,
            endpoint: productionCatalogConfiguration.baseURL.absoluteString,
            remoteDraftCount: creatorPublishingContents.count,
            queuedEditCount: creatorDraftSyncQueueRecords.count,
            conflictCount: 0,
            revisionCount: response.revisions.count,
            detail: "Remote draft \(response.status) and merged into the local content snapshot.",
            lastError: nil,
            updatedAtLabel: "Remote version \(response.draft.version)"
        )
        persistCreatorPublishingContents()
    }

    private func upsertRemoteDraft(_ draft: HFRemoteCreatorDraftDTO) {
        creatorDraftRemoteVersions[draft.id] = draft.version
        let content = draft.publishingContent
        if let index = creatorPublishingContents.firstIndex(where: { $0.id == content.id }) {
            creatorPublishingContents[index] = content
        } else {
            creatorPublishingContents.insert(content, at: 0)
        }
    }

    private func setRemoteDraftConflict(error: Error, detail: String) {
        creatorDraftSyncRuntimeSnapshot = HFCreatorDraftSyncRuntimeSnapshot(
            state: .conflict,
            endpoint: productionCatalogConfiguration.baseURL.absoluteString,
            remoteDraftCount: creatorPublishingContents.count,
            queuedEditCount: creatorDraftSyncQueueRecords.count,
            conflictCount: 1,
            revisionCount: creatorDraftRevisionRecords.count,
            detail: detail,
            lastError: error.localizedDescription,
            updatedAtLabel: "Conflict recorded"
        )
    }

    private func persistCloudCatalogSnapshot(
        _ snapshot: HFContentBackendSnapshot,
        source: String,
        cursor: String?,
        version: Int,
        tombstoneCount: Int,
        detail: String
    ) {
        contentSnapshot = snapshot
        creatorPublishingContents = snapshot.publishingProjects
        contentStorage.saveSnapshot(snapshot)
        if let cursor {
            UserDefaults.standard.set(cursor, forKey: cloudCatalogSyncCursorKey)
        }
        UserDefaults.standard.set(version, forKey: cloudCatalogVersionKey)
        cloudCatalogSyncRuntimeSnapshot = HFCloudCatalogSyncRuntimeSnapshot(
            state: .synced,
            source: source,
            cursor: cursor,
            catalogVersion: version,
            titleCount: snapshot.movies.count,
            creatorCount: snapshot.creators.count,
            seriesCount: snapshot.series.count,
            collectionCount: snapshot.collections.count,
            tombstoneCount: tombstoneCount,
            cachePolicy: "stale-while-revalidate",
            detail: detail,
            lastError: nil,
            updatedAtLabel: snapshot.updatedAtLabel
        )
        invalidateCatalogRuntime(reason: "Cloud catalog sync")
        refreshIdentitySessionRuntime(reason: "Cloud catalog sync")
    }

    func refreshAuthRuntimeStatus() {
        authRuntimeStatus = authService.currentStatus(localProfile: activeViewingProfile)
    }

    func refreshEntitlementRuntimeStatus(titleID: String? = nil) {
        entitlementRuntimeStatus = entitlementService.runtimeStatus(userID: activeProfileID, titleID: titleID)
    }

    private func backendServiceStatus(id: String, fallback: HFBackendServiceStatus) -> HFBackendServiceStatus {
        backendRuntimeStatus.services.first { $0.id == id } ?? fallback
    }

    private func makeLocalLibrarySyncAdapter() -> HFLocalLibrarySyncAdapter {
        HFLocalLibrarySyncAdapter(
            savedTitleIDs: savedMovieIDs,
            progressByTitleID: Dictionary(uniqueKeysWithValues: allCatalogMovies.compactMap { movie in
                guard let progress = movie.progress else { return nil }
                return (movie.id, progress)
            }),
            offlineTitleIDs: downloadedMovieIDs
        )
    }

    private func makeLibrarySyncService() -> HFLibrarySyncService {
        HFLibrarySyncServiceFactory.make(
            configuration: librarySyncConfiguration,
            backendConfiguration: backendConfiguration,
            authConfiguration: authConfiguration,
            localFallback: makeLocalLibrarySyncAdapter()
        )
    }

    private func makeDownloadEligibilityService(
        streamingStatus: HFPlaybackDescriptorStatus,
        entitlementStatus: HFProductAccessState
    ) -> HFDownloadEligibilityService {
        HFDownloadEligibilityServiceFactory.make(
            configuration: downloadConfiguration,
            streamingStatus: streamingStatus,
            entitlementStatus: entitlementStatus
        )
    }

    private func healthLabel(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "Staging Reachable"
        case .stagingUnavailable:
            return "Staging Unavailable"
        case .backendConfigured, .readyForStaging:
            return "Backend Configured"
        case .missingCredentials, .credentialsMissing:
            return "Missing Credentials"
        case .localMode, .localPreview:
            return "Local Mode"
        default:
            return "Backend Not Connected Yet"
        }
    }

    private func healthDetail(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "Health Check reached staging from runtime config. No production backend claim is made."
        case .stagingUnavailable:
            return "Health Check ran from runtime config and staging did not return a successful response."
        case .backendConfigured, .readyForStaging:
            return "Runtime config is complete. Health Check is ready to run."
        case .missingCredentials, .credentialsMissing:
            return "Health Check skipped because runtime config is incomplete."
        case .localMode, .localPreview:
            return "Health Check skipped because runtime config is missing."
        default:
            return "Health Check is not connected yet."
        }
    }

    private func healthSystemImage(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "checkmark.seal.fill"
        case .stagingUnavailable:
            return "exclamationmark.triangle.fill"
        default:
            return "server.rack"
        }
    }

    private func healthAccessibilityIdentifier(for state: HFBackendConnectionState) -> String {
        switch state {
        case .stagingReachable:
            return "hf.backend.stagingReachable"
        case .stagingUnavailable:
            return "hf.backend.stagingUnavailable"
        case .missingCredentials, .credentialsMissing:
            return "hf.backend.credentialsMissing"
        case .backendConfigured, .readyForStaging:
            return "hf.backend.configured"
        case .localMode, .localPreview:
            return "hf.backend.localMode"
        default:
            return "hf.backend.notConnected"
        }
    }

    // hf.services.accountProfile
    // hf.services.localProfileStore
    // hf.services.activeViewingProfile
    var activeViewingProfile: HFLocalViewingProfile {
        localProfiles.first { $0.id == activeProfileID } ?? localProfiles[0]
    }

    var activeCreatorProfile: HFCreatorProfile {
        if let creatorID = activeIdentityAccessSession?.creatorID,
           let authenticatedCreator = creatorProfiles.first(where: { $0.creator.id == creatorID }) {
            return authenticatedCreator
        }
        return creatorProfiles.first { profile in
            profile.creator.name.localizedCaseInsensitiveCompare(activeViewingProfile.displayName) == .orderedSame
        } ?? creatorProfiles.first ?? creatorProfile(for: Creator(id: "local-creator", name: activeViewingProfile.displayName, role: "Creator", avatarAssetName: nil, featuredMovieIDs: []))
    }

    var currentSessionRuntime: HFIdentitySessionRuntimeSnapshot {
        identitySessionRuntime
    }

    var activeIdentityAccessSession: HFIdentityAccessSession? {
        guard let session = identityAccessRuntimeSnapshot.activeSession, !session.isExpired else { return nil }
        return session
    }

    var identityAccessRoleChecks: [HFIdentityAccessRoleCheck] {
        identityAccessRuntimeSnapshot.roleChecks
    }

    var identityAccessAuditEvents: [HFIdentityAccessAuditEvent] {
        identityAccessRuntimeSnapshot.auditEvents
    }

    var sessionPermissionRecords: [HFSessionPermissionRecord] {
        [
            HFSessionPermissionRecord(
                id: "watch",
                title: "Watch",
                detail: "Browse, save, continue watching, and open local preview playback.",
                status: "Allowed",
                systemImage: "play.rectangle.fill"
            ),
            HFSessionPermissionRecord(
                id: "create",
                title: "Create",
                detail: activeIdentityAccessSession?.role == .creator || activeIdentityAccessSession?.role == .admin ? "Authenticated creator session can edit local drafts and review publishing state." : "Viewer sessions keep creator mutations locked.",
                status: activeIdentityAccessSession?.role == .creator || activeIdentityAccessSession?.role == .admin ? "Allowed" : "Denied",
                systemImage: "wand.and.stars"
            ),
            HFSessionPermissionRecord(
                id: "publish",
                title: "Publish",
                detail: "Publishing remains local review only. No external publish action is connected.",
                status: "Local Review",
                systemImage: "paperplane.circle.fill"
            ),
            HFSessionPermissionRecord(
                id: "admin",
                title: "Admin",
                detail: "Administration, moderation, rights, and revenue surfaces are read-only local planning.",
                status: "Read Only",
                systemImage: "checkmark.shield.fill"
            )
        ]
    }

    var workspaceSessionRecords: [HFWorkspaceSessionRecord] {
        [
            HFWorkspaceSessionRecord(
                id: "watch",
                title: "Watch Workspace",
                detail: "\(catalogRuntimeSnapshot.totalTitles) runtime titles available through the catalog facade.",
                status: catalogRuntimeSnapshot.statusLabel,
                systemImage: "sparkles.tv.fill"
            ),
            HFWorkspaceSessionRecord(
                id: "creator",
                title: "Creator Workspace",
                detail: "\(creatorPublishingContents.count) projects mapped to \(activeCreatorProfile.creator.name).",
                status: activeIdentityAccessSession?.role == .creator || activeIdentityAccessSession?.role == .admin ? "Authenticated" : "Locked",
                systemImage: "wand.and.stars.inverse"
            ),
            HFWorkspaceSessionRecord(
                id: "library",
                title: "Library Workspace",
                detail: "\(savedMovieIDs.count) saved titles and \(downloadedMovieIDs.count) local offline states for this profile.",
                status: "Profile Scoped",
                systemImage: "bookmark.fill"
            ),
            HFWorkspaceSessionRecord(
                id: "business",
                title: "Business Workspace",
                detail: "Revenue, rights, marketplace, and licensing records remain preview-only.",
                status: "Read Only",
                systemImage: "chart.line.uptrend.xyaxis"
            )
        ]
    }

    var mediaAssetRuntimeSnapshot: HFCreatorMediaAssetRuntimeSnapshot {
        let records = creatorMediaAssetRecords
        return HFCreatorMediaAssetRuntimeSnapshot(
            totalAssets: records.count,
            readyAssets: records.filter { $0.status == .ready }.count,
            needsReviewAssets: records.filter { $0.status == .needsReview }.count,
            placeholderAssets: records.filter { $0.status == .placeholder }.count,
            missingAssets: records.filter { $0.status == .missing }.count,
            posterAssets: records.filter { $0.kind == .poster }.count,
            trailerAssets: records.filter { $0.kind == .trailer }.count,
            artworkAssets: records.filter { $0.kind == .artwork }.count,
            metadataAssets: records.filter { $0.kind == .metadata }.count,
            updatedAtLabel: "Asset runtime resolved locally"
        )
    }

    var creatorMediaAssetRecords: [HFCreatorMediaAssetRecord] {
        creatorPublishingContents.flatMap { mediaAssetRecords(for: $0) }
    }

    var importedMediaAssets: [HFCreatorImportedMediaAsset] {
        contentSnapshot.importedMediaAssets
    }

    var importedMediaAssetCount: Int {
        importedMediaAssets.filter { $0.status == .imported || $0.status == .duplicate }.count
    }

    var mediaInspectionRecords: [HFCreatorMediaInspectionRecord] {
        contentSnapshot.mediaInspectionRecords
    }

    var mediaInspectionPreflightRecords: [HFCreatorMediaInspectionRecord] {
        mediaInspectionRecords.sorted { lhs, rhs in
            if lhs.isQuarantined != rhs.isQuarantined {
                return lhs.isQuarantined && !rhs.isQuarantined
            }
            return lhs.projectTitle < rhs.projectTitle
        }
    }

    var mediaInspectionReadinessLabel: String {
        let records = mediaInspectionRecords
        guard !records.isEmpty else { return "0/0 Inspected" }
        let accepted = records.filter { !$0.isQuarantined && $0.state != .blocked }.count
        return "\(accepted)/\(records.count) Accepted"
    }

    var posterAssetRegistry: [HFCreatorMediaAssetRecord] {
        creatorMediaAssetRecords.filter { $0.kind == .poster }
    }

    var trailerAssetRegistry: [HFCreatorMediaAssetRecord] {
        creatorMediaAssetRecords.filter { $0.kind == .trailer }
    }

    var artworkAssetRegistry: [HFCreatorMediaAssetRecord] {
        creatorMediaAssetRecords.filter { $0.kind == .artwork }
    }

    func mediaAssetRecords(for project: HFCreatorPublishingContent) -> [HFCreatorMediaAssetRecord] {
        [
            mediaAssetRecord(project: project, kind: .poster, status: project.posterStatus),
            mediaAssetRecord(project: project, kind: .trailer, status: project.trailerStatus),
            mediaAssetRecord(project: project, kind: .metadata, status: project.metadataStatus),
            mediaAssetRecord(project: project, kind: .artwork, status: project.artworkStatus)
        ]
    }

    func mediaAssetReadinessRecords(for project: HFCreatorPublishingContent) -> [HFCreatorMediaAssetRecord] {
        mediaAssetRecords(for: project)
    }

    func primaryImportProjectID() -> String? {
        creatorPublishingContents.first { $0.releaseState != .archived }?.id
    }

    func importLocalMediaData(
        projectID: String,
        kind: HFCreatorMediaAssetKind,
        filename: String,
        data: Data,
        contentType: String
    ) throws -> HFCreatorLocalImportResult {
        guard let project = creatorPublishingContents.first(where: { $0.id == projectID }) else {
            throw NSError(domain: "HFLocalMediaImport", code: 1, userInfo: [NSLocalizedDescriptionKey: "Project not found"])
        }
        guard !data.isEmpty else {
            throw NSError(domain: "HFLocalMediaImport", code: 2, userInfo: [NSLocalizedDescriptionKey: "Selected media is empty"])
        }

        let checksum = sha256Hex(for: data)
        if let duplicateIndex = contentSnapshot.importedMediaAssets.firstIndex(where: { $0.projectID == projectID && $0.kind == kind && $0.checksum == checksum }) {
            let existingAsset = contentSnapshot.importedMediaAssets[duplicateIndex]
            let existingURL = mediaRootDirectory().appendingPathComponent(existingAsset.storedRelativePath, isDirectory: false)
            if FileManager.default.fileExists(atPath: existingURL.path), existingAsset.status != .cancelled, existingAsset.status != .failed {
                contentSnapshot.importedMediaAssets[duplicateIndex].status = .duplicate
                contentSnapshot.importedMediaAssets[duplicateIndex].progress = 1.0
                contentSnapshot.importedMediaAssets[duplicateIndex].history.append("Duplicate detected at \(timestampLabel())")
                contentSnapshot.updatedAtLabel = "Duplicate local media import detected"
                persistContentSnapshot(reason: "Duplicate local media import detected")
                return HFCreatorLocalImportResult(
                    asset: contentSnapshot.importedMediaAssets[duplicateIndex],
                    isDuplicate: true,
                    message: "Duplicate local media was detected and no second file was copied."
                )
            } else {
                contentSnapshot.importedMediaAssets.remove(at: duplicateIndex)
            }
        }

        let safeFilename = sanitizedFilename(filename)
        let extensionSuffix = URL(fileURLWithPath: safeFilename).pathExtension
        let assetID = "asset-\(projectID)-\(kind.id.lowercased())-\(checksum.prefix(12))"
        let destinationDirectory = try mediaDirectory(for: projectID)
        let destinationName = extensionSuffix.isEmpty ? assetID : "\(assetID).\(extensionSuffix)"
        let destinationURL = destinationDirectory.appendingPathComponent(destinationName, isDirectory: false)
        try data.write(to: destinationURL, options: .atomic)

        let record = HFCreatorImportedMediaAsset(
            id: assetID,
            projectID: projectID,
            projectTitle: project.title,
            kind: kind,
            originalFilename: safeFilename,
            storedRelativePath: "Media/\(projectID)/\(destinationName)",
            contentType: contentType,
            byteCount: data.count,
            checksum: checksum,
            status: .imported,
            progress: 1.0,
            importedAtLabel: timestampLabel(),
            history: [
                "Import session created",
                "Copied into Application Support media directory",
                "Checksum \(checksum.prefix(12)) recorded"
            ]
        )
        contentSnapshot.importedMediaAssets.append(record)
        markProjectAssetReady(projectID: projectID, kind: kind)
        inspectImportedMediaAsset(id: record.id)
        contentSnapshot.updatedAtLabel = "Local media import persisted"
        persistContentSnapshot(reason: "Local media import persisted")
        return HFCreatorLocalImportResult(asset: record, isDuplicate: false, message: "Imported \(safeFilename) into the app sandbox.")
    }

    @discardableResult
    func inspectImportedMediaAsset(id: String) -> HFCreatorMediaInspectionRecord? {
        guard let assetIndex = contentSnapshot.importedMediaAssets.firstIndex(where: { $0.id == id }) else { return nil }
        let asset = contentSnapshot.importedMediaAssets[assetIndex]
        let fileURL = mediaRootDirectory().appendingPathComponent(asset.storedRelativePath, isDirectory: false)
        let record = makeMediaInspectionRecord(for: asset, fileURL: fileURL)

        if let recordIndex = contentSnapshot.mediaInspectionRecords.firstIndex(where: { $0.assetID == asset.id }) {
            contentSnapshot.mediaInspectionRecords[recordIndex] = record
        } else {
            contentSnapshot.mediaInspectionRecords.append(record)
        }

        if record.isQuarantined {
            contentSnapshot.importedMediaAssets[assetIndex].status = .quarantined
            contentSnapshot.importedMediaAssets[assetIndex].history.append("Inspection quarantined asset at \(timestampLabel()): \(record.blockingIssue)")
            markProjectAssetNeedsReview(projectID: asset.projectID, kind: asset.kind)
        } else if contentSnapshot.importedMediaAssets[assetIndex].status == .quarantined {
            contentSnapshot.importedMediaAssets[assetIndex].status = .imported
            contentSnapshot.importedMediaAssets[assetIndex].history.append("Inspection accepted asset at \(timestampLabel())")
            markProjectAssetReady(projectID: asset.projectID, kind: asset.kind)
        }

        contentSnapshot.updatedAtLabel = "Media inspection updated"
        persistContentSnapshot(reason: "Media inspection updated")
        return record
    }

    func refreshMediaInspectionPreflight() {
        let inspectableStatuses: Set<HFCreatorLocalImportStatus> = [.imported, .duplicate, .quarantined, .failed]
        contentSnapshot.importedMediaAssets
            .filter { inspectableStatuses.contains($0.status) }
            .forEach { _ = inspectImportedMediaAsset(id: $0.id) }
    }

    func importLocalMediaFile(
        projectID: String,
        kind: HFCreatorMediaAssetKind,
        fileURL: URL
    ) throws -> HFCreatorLocalImportResult {
        let hasAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }
        let data = try Data(contentsOf: fileURL)
        let contentType = contentTypeIdentifier(for: fileURL)
        return try importLocalMediaData(
            projectID: projectID,
            kind: kind,
            filename: fileURL.lastPathComponent,
            data: data,
            contentType: contentType
        )
    }

    func cancelImportedMediaAsset(id: String) {
        guard let index = contentSnapshot.importedMediaAssets.firstIndex(where: { $0.id == id }) else { return }
        let relativePath = contentSnapshot.importedMediaAssets[index].storedRelativePath
        try? FileManager.default.removeItem(at: mediaRootDirectory().appendingPathComponent(relativePath, isDirectory: false))
        contentSnapshot.importedMediaAssets[index].status = .cancelled
        contentSnapshot.importedMediaAssets[index].progress = 0
        contentSnapshot.importedMediaAssets[index].history.append("Cancelled at \(timestampLabel()); copied file removed")
        contentSnapshot.updatedAtLabel = "Local media import cancelled"
        persistContentSnapshot(reason: "Local media import cancelled")
    }

    func retryImportedMediaAsset(id: String) {
        guard let index = contentSnapshot.importedMediaAssets.firstIndex(where: { $0.id == id }) else { return }
        let fileURL = mediaRootDirectory().appendingPathComponent(contentSnapshot.importedMediaAssets[index].storedRelativePath, isDirectory: false)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            contentSnapshot.importedMediaAssets[index].status = .imported
            contentSnapshot.importedMediaAssets[index].progress = 1
            contentSnapshot.importedMediaAssets[index].history.append("Retry verified sandbox file at \(timestampLabel())")
            markProjectAssetReady(projectID: contentSnapshot.importedMediaAssets[index].projectID, kind: contentSnapshot.importedMediaAssets[index].kind)
            inspectImportedMediaAsset(id: id)
        } else {
            contentSnapshot.importedMediaAssets[index].status = .failed
            contentSnapshot.importedMediaAssets[index].history.append("Retry failed because sandbox file is missing at \(timestampLabel())")
        }
        contentSnapshot.updatedAtLabel = "Local media import retried"
        persistContentSnapshot(reason: "Local media import retried")
    }

    private func seedLocalMediaImportIfRequested() {
        let arguments = ProcessInfo.processInfo.arguments
        let shouldSeed = arguments.contains("--hf-media-import-seed")
            || arguments.contains("--hf-media-import-cancel-seed")
            || arguments.contains("--hf-media-import-retry-seed")
        guard shouldSeed, let projectID = primaryImportProjectID() else {
            return
        }
        let fixture = Self.mediaInspectionFixturePNGData()
        let result = try? importLocalMediaData(
            projectID: projectID,
            kind: .poster,
            filename: "highfive-import-fixture.png",
            data: fixture,
            contentType: "public.png"
        )
        if arguments.contains("--hf-media-import-cancel-seed"),
           let assetID = result?.asset.id ?? contentSnapshot.importedMediaAssets.last?.id {
            cancelImportedMediaAsset(id: assetID)
        }
        if arguments.contains("--hf-media-import-retry-seed"),
           let assetID = result?.asset.id ?? contentSnapshot.importedMediaAssets.last?.id {
            retryImportedMediaAsset(id: assetID)
        }
    }

    private func seedMediaInspectionIfRequested() {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("--hf-media-inspection-invalid-seed"),
              let projectID = primaryImportProjectID() else {
            return
        }
        _ = try? importLocalMediaData(
            projectID: projectID,
            kind: .trailer,
            filename: "invalid-trailer-preflight.mov",
            data: Data("not a playable movie".utf8),
            contentType: "com.apple.quicktime-movie"
        )
    }

    private func seedLocalReleasePackageIfRequested() {
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("--hf-package-create-seed")
                || arguments.contains("--hf-package-validation-seed")
                || arguments.contains("--hf-package-history-seed") else {
            return
        }
        if contentSnapshot.importedMediaAssets.isEmpty,
           let projectID = primaryImportProjectID() {
            _ = try? importLocalMediaData(
                projectID: projectID,
                kind: .poster,
                filename: "highfive-package-fixture.png",
                data: Self.mediaInspectionFixturePNGData(),
                contentType: "public.png"
            )
        }
        if contentSnapshot.localReleasePackages.isEmpty {
            _ = try? createLocalReleasePackage()
        }
        if arguments.contains("--hf-package-validation-seed") {
            _ = validateLatestLocalReleasePackage()
        }
    }

    var creatorUploadWorkflowSnapshot: HFCreatorUploadWorkflowSnapshot {
        let selection = creatorUploadAssetSelectionRecords
        let validation = creatorUploadValidationRecords
        let queue = creatorUploadPublishQueueRecords
        let preflight = creatorUploadPreflightRecords

        return HFCreatorUploadWorkflowSnapshot(
            projectCount: creatorPublishingContents.filter { $0.releaseState != .archived }.count,
            selectedAssets: selection.filter { $0.selectionState != "Excluded" }.count,
            validAssets: validation.filter { !$0.isBlocking }.count,
            manifestItems: creatorUploadPackageManifestRecords.reduce(0) { $0 + $1.assetCount },
            queueItems: queue.count,
            preflightPassed: preflight.filter(\.isPassed).count,
            blockers: validation.filter(\.isBlocking).count + preflight.filter { !$0.isPassed }.count,
            updatedAtLabel: "Upload preparation workflow resolved locally"
        )
    }

    var creatorUploadAssetSelectionRecords: [HFCreatorUploadSelectionRecord] {
        creatorPublishingContents
            .filter { $0.releaseState != .archived }
            .flatMap { project in
                mediaAssetRecords(for: project).map { record in
                    HFCreatorUploadSelectionRecord(
                        id: "selection-\(record.id)",
                        projectTitle: record.projectTitle,
                        assetKind: record.kind,
                        selectionState: uploadSelectionState(for: record),
                        source: uploadSelectionSource(for: record),
                        detail: uploadSelectionDetail(for: record),
                        systemImage: record.systemImage
                    )
                }
            }
    }

    var creatorUploadValidationRecords: [HFCreatorUploadValidationRecord] {
        creatorMediaAssetRecords.map { record in
            let isBlocking = record.status == .missing
            return HFCreatorUploadValidationRecord(
                id: "validation-\(record.id)",
                title: "\(record.projectTitle) \(record.kind.rawValue)",
                detail: uploadValidationDetail(for: record),
                status: isBlocking ? "Blocked" : record.readiness,
                isBlocking: isBlocking,
                systemImage: record.systemImage
            )
        }
    }

    var creatorUploadPackageManifestRecords: [HFCreatorUploadManifestRecord] {
        creatorPublishingContents
            .filter { $0.releaseState != .archived }
            .map { project in
                let assets = mediaAssetRecords(for: project)
                let blockers = assets.filter { $0.status == .missing }.count
                let packageState = blockers == 0 ? "Manifest Ready" : "Needs Asset Metadata"
                return HFCreatorUploadManifestRecord(
                    id: "manifest-\(project.id)",
                    projectTitle: project.title,
                    manifestID: "local-manifest-\(project.id)",
                    assetCount: assets.count,
                    packageState: packageState,
                    detail: "Manifest references \(assets.count) local registry records. No media bytes, file paths, or transfer destinations are included.",
                    systemImage: blockers == 0 ? "doc.badge.gearshape.fill" : "doc.badge.ellipsis"
                )
            }
    }

    var creatorUploadPublishQueueRecords: [HFCreatorUploadQueueRecord] {
        creatorPublishingQueueRecords.map { record in
            let assets = mediaAssetRecords(for: record.project)
            let blockers = assets.filter { $0.status == .missing }.count
            let needsReview = assets.filter { $0.status == .needsReview || $0.status == .placeholder }.count
            let queueState = blockers > 0 ? "Blocked" : needsReview > 0 ? "Preflight Review" : "Prepared"
            return HFCreatorUploadQueueRecord(
                id: "upload-queue-\(record.project.id)",
                projectTitle: record.project.title,
                queueState: queueState,
                readiness: record.project.readyForReview ? "Review Ready" : "Draft",
                nextStep: blockers > 0 ? "Complete missing registry metadata" : "Review local package manifest",
                detail: "Queue preview is local-only and does not send, submit, or transfer content.",
                systemImage: blockers > 0 ? "exclamationmark.triangle.fill" : "tray.and.arrow.up.fill"
            )
        }
    }

    var creatorUploadPreflightRecords: [HFCreatorUploadPreflightRecord] {
        let snapshot = mediaAssetRuntimeSnapshot
        let missing = snapshot.missingAssets
        let placeholders = snapshot.placeholderAssets
        let manifests = creatorUploadPackageManifestRecords

        return [
            HFCreatorUploadPreflightRecord(id: "asset-registry", title: "Asset Registry", detail: "\(snapshot.totalAssets) poster, trailer, artwork, and metadata records resolved through the media runtime.", result: missing == 0 ? "Clear" : "\(missing) Missing", isPassed: missing == 0, systemImage: "rectangle.stack.fill"),
            HFCreatorUploadPreflightRecord(id: "manifest", title: "Package Manifest", detail: "\(manifests.count) in-memory manifests prepared from publishing records.", result: manifests.isEmpty ? "Empty" : "Prepared", isPassed: !manifests.isEmpty, systemImage: "doc.text.magnifyingglass"),
            HFCreatorUploadPreflightRecord(id: "review", title: "Review Gate", detail: "\(creatorReadyForReviewProjects.count) projects satisfy local publishing review checks.", result: creatorReadyForReviewProjects.isEmpty ? "Needs Review" : "Ready", isPassed: !creatorReadyForReviewProjects.isEmpty, systemImage: "checkmark.seal.fill"),
            HFCreatorUploadPreflightRecord(id: "placeholder", title: "Placeholder Audit", detail: "\(placeholders) placeholder records remain visible before future upload work.", result: placeholders == 0 ? "Clear" : "Review", isPassed: true, systemImage: "photo.on.rectangle.angled"),
            HFCreatorUploadPreflightRecord(id: "network-boundary", title: "Transfer Boundary", detail: "No network session, file picker, cloud storage, or media transfer is active.", result: "Local Only", isPassed: true, systemImage: "lock.shield.fill")
        ]
    }

    var creatorProjectRuntimeSnapshot: HFCreatorProjectRuntimeSnapshot {
        let validations = creatorProjectValidationRecords

        return HFCreatorProjectRuntimeSnapshot(
            projectCount: creatorPublishingContents.count,
            manifestCount: creatorProjectManifestRecords.count,
            assetManifestCount: creatorProjectAssetManifestRecords.count,
            validationPassed: validations.filter(\.releaseReady).count,
            releasePackages: max(creatorProjectReleasePackageRecords.count, contentSnapshot.localReleasePackages.count),
            timelineEvents: creatorProjectTimelineRecords.count,
            updatedAtLabel: "Creator project runtime resolved from local repository state"
        )
    }

    var creatorProjectManifestRecords: [HFCreatorProjectManifestRecord] {
        creatorPublishingContents.map { project in
            HFCreatorProjectManifestRecord(
                id: "project-manifest-\(project.id)",
                projectID: project.id,
                creatorID: creatorID(for: project.creator),
                contentID: project.movie.id,
                version: projectVersion(for: project),
                created: "Repository snapshot",
                modified: project.updatedAtLabel,
                status: project.releaseState.rawValue,
                title: project.title,
                detail: "Canonical manifest links project, creator, content, version, status, assets, validation, and release package state.",
                systemImage: "doc.text.fill"
            )
        }
    }

    var creatorProjectAssetManifestRecords: [HFCreatorProjectAssetManifestRecord] {
        creatorPublishingContents.map { project in
            let assets = Dictionary(uniqueKeysWithValues: mediaAssetRecords(for: project).map { ($0.kind, $0) })
            return HFCreatorProjectAssetManifestRecord(
                id: "project-assets-\(project.id)",
                projectTitle: project.title,
                posterState: assets[.poster]?.readiness ?? "Missing",
                trailerState: assets[.trailer]?.readiness ?? "Missing",
                artworkState: assets[.artwork]?.readiness ?? "Missing",
                metadataState: assets[.metadata]?.readiness ?? "Missing",
                thumbnailState: project.posterStatus == .ready ? "Poster Thumbnail Ready" : "Thumbnail Placeholder",
                detail: "Asset manifest references poster, trailer, artwork, metadata, and thumbnail readiness from the media asset runtime.",
                systemImage: "rectangle.stack.fill"
            )
        }
    }

    var creatorProjectValidationRecords: [HFCreatorProjectValidationRecord] {
        creatorPublishingContents.map { project in
            let metadataComplete = !project.title.isEmpty
                && project.description.trimmingCharacters(in: .whitespacesAndNewlines).count >= 24
                && !project.creator.isEmpty
                && !project.genre.isEmpty
                && !project.tags.isEmpty
                && !project.runtime.isEmpty
                && project.metadataStatus == .ready
            let posterReady = project.posterStatus == .ready || project.posterStatus == .needsReview
            let trailerReady = project.trailerStatus == .ready || project.trailerStatus == .needsReview
            let artworkReady = project.artworkStatus == .ready || project.artworkStatus == .needsReview
            let publishingReady = project.readyForReview
            let releaseReady = metadataComplete && posterReady && trailerReady && artworkReady && publishingReady && project.releaseState != .archived
            let completeCount = [metadataComplete, posterReady, trailerReady, artworkReady, publishingReady, releaseReady].filter { $0 }.count

            return HFCreatorProjectValidationRecord(
                id: "project-validation-\(project.id)",
                projectTitle: project.title,
                metadataComplete: metadataComplete,
                posterReady: posterReady,
                trailerReady: trailerReady,
                artworkReady: artworkReady,
                publishingReady: publishingReady,
                releaseReady: releaseReady,
                status: releaseReady ? "Release Ready" : "\(completeCount)/6 Gates",
                detail: "One validation pass covers metadata, poster, trailer, artwork, publishing, and release readiness.",
                systemImage: releaseReady ? "checkmark.seal.fill" : "list.clipboard.fill"
            )
        }
    }

    var creatorProjectReleasePackageRecords: [HFCreatorProjectReleasePackageRecord] {
        creatorPublishingContents.map { project in
            let assets = mediaAssetRecords(for: project)
            let readyAssets = assets.filter { $0.status == .ready || $0.status == .needsReview }.count
            let validation = creatorProjectValidationRecords.first { $0.id == "project-validation-\(project.id)" }

            return HFCreatorProjectReleasePackageRecord(
                id: "project-release-\(project.id)",
                projectTitle: project.title,
                releaseManifest: "release-\(project.id)-\(projectVersion(for: project))",
                publishingSummary: "\(project.releaseState.rawValue) - \(project.readyForReview ? "review-ready" : "draft-ready")",
                assetSummary: "\(readyAssets)/\(assets.count) registry records ready",
                runtimeSummary: "Media Runtime -> Project Runtime -> Publishing",
                creatorSummary: "\(project.creator) / \(creatorID(for: project.creator))",
                status: validation?.releaseReady == true ? "Package Ready" : "Package Review",
                systemImage: validation?.releaseReady == true ? "shippingbox.fill" : "shippingbox"
            )
        }
    }

    var localReleasePackageHistory: [HFCreatorLocalReleasePackageRecord] {
        contentSnapshot.localReleasePackages.sorted { $0.createdAtLabel > $1.createdAtLabel }
    }

    var latestLocalReleasePackageURL: URL? {
        guard let latest = localReleasePackageHistory.first else { return nil }
        return mediaRootDirectory().appendingPathComponent(latest.exportManifestRelativePath, isDirectory: false)
    }

    var localReleasePackageReadinessLabel: String {
        guard !contentSnapshot.localReleasePackages.isEmpty else { return "No Package" }
        let valid = contentSnapshot.localReleasePackages.filter { $0.validationStatus == "Validated" }.count
        return "\(valid)/\(contentSnapshot.localReleasePackages.count) Valid"
    }

    @discardableResult
    func createLocalReleasePackage(projectID: String? = nil) throws -> HFCreatorLocalReleasePackageRecord {
        let releaseReadyIDs = Set(creatorProjectValidationRecords.filter(\.releaseReady).map { $0.id.replacingOccurrences(of: "project-validation-", with: "") })
        let selectedProject = projectID.flatMap { id in creatorPublishingContents.first { $0.id == id } }
            ?? creatorPublishingContents.first { releaseReadyIDs.contains($0.id) }
            ?? creatorReadyForReviewProjects.first
            ?? creatorPublishingContents.first { $0.releaseState != .archived }
        guard let project = selectedProject else {
            throw NSError(domain: "HFLocalReleasePackage", code: 1, userInfo: [NSLocalizedDescriptionKey: "No active creator project is available for packaging"])
        }

        refreshMediaInspectionPreflight()
        let packageVersion = projectVersion(for: project)
        let packageID = "release-package-\(project.id)-\(slugID(timestampLabel()))"
        let packageDirectory = try packageDirectory(for: packageID)
        let manifest = makeLocalReleasePackageManifest(project: project, packageID: packageID, packageVersion: packageVersion)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let files: [(String, Data)] = [
            ("release-manifest.json", try encoder.encode(manifest)),
            ("project-manifest.json", try encoder.encode(manifest.project)),
            ("asset-manifest.json", try encoder.encode(manifest.assets)),
            ("validation-report.json", try encoder.encode(manifest.validation)),
            ("rights-metadata.json", try encoder.encode(manifest.rights)),
            ("creator-metadata.json", try encoder.encode(manifest.creator))
        ]

        for (filename, data) in files {
            try data.write(to: packageDirectory.appendingPathComponent(filename, isDirectory: false), options: .atomic)
        }

        let manifestData = try encoder.encode(manifest)
        let checksum = sha256Hex(for: manifestData)
        let validationResult = validateLocalReleasePackage(at: packageDirectory.appendingPathComponent("release-manifest.json", isDirectory: false))
        let record = HFCreatorLocalReleasePackageRecord(
            id: packageID,
            projectID: project.id,
            projectTitle: project.title,
            packageVersion: packageVersion,
            packageRelativePath: "Packages/\(packageID)",
            exportManifestRelativePath: "Packages/\(packageID)/release-manifest.json",
            checksum: checksum,
            manifestStatus: validationResult ? "Manifest Valid" : "Manifest Review",
            validationStatus: validationResult ? "Validated" : "Needs Review",
            createdAtLabel: timestampLabel(),
            history: [
                "Package directory created",
                "Release manifest written",
                "Project manifest written",
                "Asset manifest written",
                "Validation report written",
                "Import-back validation \(validationResult ? "passed" : "needs review")"
            ]
        )

        contentSnapshot.localReleasePackages.removeAll { $0.id == packageID }
        contentSnapshot.localReleasePackages.insert(record, at: 0)
        contentSnapshot.updatedAtLabel = "Local release package created"
        persistContentSnapshot(reason: "Local release package created")
        return record
    }

    func validateLatestLocalReleasePackage() -> Bool {
        guard let latest = localReleasePackageHistory.first else { return false }
        let manifestURL = mediaRootDirectory().appendingPathComponent(latest.exportManifestRelativePath, isDirectory: false)
        let isValid = validateLocalReleasePackage(at: manifestURL)
        guard let index = contentSnapshot.localReleasePackages.firstIndex(where: { $0.id == latest.id }) else {
            return isValid
        }
        contentSnapshot.localReleasePackages[index].validationStatus = isValid ? "Validated" : "Needs Review"
        contentSnapshot.localReleasePackages[index].manifestStatus = isValid ? "Manifest Valid" : "Manifest Review"
        contentSnapshot.localReleasePackages[index].history.append("Import-back validation \(isValid ? "passed" : "failed") at \(timestampLabel())")
        contentSnapshot.updatedAtLabel = "Local release package validated"
        persistContentSnapshot(reason: "Local release package validated")
        return isValid
    }

    func cleanupLocalReleasePackages() {
        for package in contentSnapshot.localReleasePackages {
            try? FileManager.default.removeItem(at: mediaRootDirectory().appendingPathComponent(package.packageRelativePath, isDirectory: true))
        }
        contentSnapshot.localReleasePackages.removeAll()
        contentSnapshot.updatedAtLabel = "Local release packages cleaned"
        persistContentSnapshot(reason: "Local release packages cleaned")
    }

    var creatorProjectTimelineRecords: [HFCreatorProjectTimelineRecord] {
        creatorPublishingContents.flatMap { project in
            [
                HFCreatorProjectTimelineRecord(id: "timeline-\(project.id)-created", projectTitle: project.title, event: "Created", detail: "\(project.title) entered the local content snapshot.", status: "Logged", systemImage: "doc.badge.plus"),
                HFCreatorProjectTimelineRecord(id: "timeline-\(project.id)-edited", projectTitle: project.title, event: "Edited", detail: project.updatedAtLabel, status: "Local", systemImage: "pencil"),
                HFCreatorProjectTimelineRecord(id: "timeline-\(project.id)-validated", projectTitle: project.title, event: "Validated", detail: creatorProjectValidationRecords.first { $0.id == "project-validation-\(project.id)" }?.status ?? "Pending", status: "Runtime", systemImage: "checklist.checked"),
                HFCreatorProjectTimelineRecord(id: "timeline-\(project.id)-ready", projectTitle: project.title, event: "Ready", detail: project.readyForReview ? "Project can enter local review." : "Project remains in preparation.", status: project.readyForReview ? "Ready" : "Draft", systemImage: "checkmark.seal.fill"),
                HFCreatorProjectTimelineRecord(id: "timeline-\(project.id)-published", projectTitle: project.title, event: "Published", detail: project.discoveryEligible ? "Visible in local discovery." : "Not visible in discovery.", status: project.discoveryEligible ? "Visible" : "Not Published", systemImage: "sparkle.magnifyingglass"),
                HFCreatorProjectTimelineRecord(id: "timeline-\(project.id)-archived", projectTitle: project.title, event: "Archived", detail: project.releaseState == .archived ? "Archived in the creator library." : "Archive event not reached.", status: project.releaseState == .archived ? "Archived" : "Open", systemImage: "archivebox.fill")
            ]
        }
    }

    var creatorMediaImportRuntimeSnapshot: HFCreatorMediaImportRuntimeSnapshot {
        let preflight = creatorMediaImportPreflightRecords

        return HFCreatorMediaImportRuntimeSnapshot(
            sessionCount: creatorMediaImportSessionRecords.count,
            queueCount: creatorMediaImportQueueRecords.count,
            registeredAssets: max(importedMediaAssetCount, creatorMediaRegistrationRecords.count),
            manifestUpdates: creatorManifestUpdateRecords.count,
            linkedProjects: creatorProjectLinkRecords.count,
            preflightPassed: preflight.filter(\.isPassed).count,
            updatedAtLabel: "Media import runtime copies selected files into app sandbox storage"
        )
    }

    var creatorMediaImportSessionRecords: [HFCreatorMediaImportSessionRecord] {
        creatorPublishingContents
            .filter { $0.releaseState != .archived }
            .map { project in
                let assets = mediaAssetRecords(for: project)
                return HFCreatorMediaImportSessionRecord(
                    id: "import-session-\(project.id)",
                    projectTitle: project.title,
                    sessionState: importedMediaAssets.contains { $0.projectID == project.id && $0.status == .imported } ? "Imported" : "Ready for Selection",
                    intakeScope: "Poster, trailer, artwork, metadata, thumbnail",
                    assetCount: assets.count + 1,
                    detail: "Session accepts explicit PhotosPicker or fileImporter selections and copies approved files into the app sandbox.",
                    systemImage: "tray.and.arrow.down.fill"
                )
            }
    }

    var creatorMediaImportQueueRecords: [HFCreatorMediaImportQueueRecord] {
        creatorPublishingContents
            .filter { $0.releaseState != .archived }
            .flatMap { project in
                mediaAssetRecords(for: project).map { record in
                    HFCreatorMediaImportQueueRecord(
                        id: "import-queue-\(record.id)",
                        projectTitle: project.title,
                        assetTitle: record.kind.rawValue,
                        queueState: mediaImportQueueState(for: record),
                        source: record.registry,
                        detail: importedAsset(projectID: record.projectID, kind: record.kind)?.storedRelativePath ?? "Awaiting user-selected local media.",
                        systemImage: record.systemImage
                    )
                }
            }
    }

    var creatorMediaImportValidationRecords: [HFCreatorMediaImportValidationRecord] {
        creatorMediaImportQueueRecords.map { record in
            let isPassed = record.queueState != "Blocked"
            return HFCreatorMediaImportValidationRecord(
                id: "import-validation-\(record.id)",
                title: "\(record.projectTitle) \(record.assetTitle)",
                detail: isPassed ? "Local import state can be linked to the project manifest." : "Select or retry local media before project readiness can advance.",
                status: isPassed ? "Validated" : "Needs Import",
                isPassed: isPassed,
                systemImage: record.systemImage
            )
        }
    }

    var creatorMediaRegistrationRecords: [HFCreatorMediaRegistrationRecord] {
        creatorMediaImportQueueRecords
            .filter { $0.queueState != "Blocked" }
            .map { record in
                HFCreatorMediaRegistrationRecord(
                    id: "media-registration-\(record.id)",
                    projectTitle: record.projectTitle,
                    registry: record.source,
                    registrationState: record.queueState == "Ready" ? "Registered" : "Registered for Review",
                    linkedManifest: "project-manifest-\(slugID(record.projectTitle))",
                    detail: "Registration connects sandbox media paths and checksums to the creator project runtime.",
                    systemImage: record.systemImage
                )
            }
    }

    var creatorManifestUpdateRecords: [HFCreatorManifestUpdateRecord] {
        creatorProjectManifestRecords.map { manifest in
            let registrations = creatorMediaRegistrationRecords.filter { $0.projectTitle == manifest.title }
            return HFCreatorManifestUpdateRecord(
                id: "manifest-update-\(manifest.projectID)",
                projectTitle: manifest.title,
                manifestID: manifest.id,
                updateState: registrations.isEmpty ? "Waiting" : "Preview Updated",
                assetSummary: "\(registrations.count) registered local media records",
                detail: "Manifest update is a preview derived from project and media runtime state. No exported package is created.",
                systemImage: registrations.isEmpty ? "doc.badge.ellipsis" : "doc.badge.gearshape.fill"
            )
        }
    }

    var creatorProjectLinkRecords: [HFCreatorProjectLinkRecord] {
        creatorProjectManifestRecords.map { manifest in
            let registrations = creatorMediaRegistrationRecords.filter { $0.projectTitle == manifest.title }
            return HFCreatorProjectLinkRecord(
                id: "project-link-\(manifest.projectID)",
                projectTitle: manifest.title,
                projectID: manifest.projectID,
                contentID: manifest.contentID,
                linkedAssets: registrations.count,
                status: registrations.isEmpty ? "Unlinked" : "Linked",
                detail: "Project link connects local registration records to the canonical creator project manifest.",
                systemImage: registrations.isEmpty ? "link.badge.plus" : "link.circle.fill"
            )
        }
    }

    var creatorMediaImportPreflightRecords: [HFCreatorMediaImportPreflightRecord] {
        let sessions = creatorMediaImportSessionRecords
        let queue = creatorMediaImportQueueRecords
        let validations = creatorMediaImportValidationRecords
        let registrations = creatorMediaRegistrationRecords
        let links = creatorProjectLinkRecords

        return [
            HFCreatorMediaImportPreflightRecord(id: "sessions", title: "Import Sessions", detail: "\(sessions.count) local registration sessions prepared from active projects.", result: sessions.isEmpty ? "Empty" : "Prepared", isPassed: !sessions.isEmpty, systemImage: "tray.and.arrow.down.fill"),
            HFCreatorMediaImportPreflightRecord(id: "queue", title: "Import Queue", detail: "\(queue.count) asset registration records are queued from media runtime state.", result: queue.isEmpty ? "Empty" : "Queued", isPassed: !queue.isEmpty, systemImage: "list.bullet.rectangle.fill"),
            HFCreatorMediaImportPreflightRecord(id: "validation", title: "Asset Validation", detail: "\(validations.filter(\.isPassed).count)/\(validations.count) local registration records pass validation.", result: validations.contains { !$0.isPassed } ? "Review" : "Clear", isPassed: !validations.isEmpty, systemImage: "checkmark.shield.fill"),
            HFCreatorMediaImportPreflightRecord(id: "registration", title: "Media Registration", detail: "\(registrations.count) metadata records can link to project manifests.", result: registrations.isEmpty ? "Waiting" : "Registered", isPassed: !registrations.isEmpty, systemImage: "rectangle.stack.badge.plus"),
            HFCreatorMediaImportPreflightRecord(id: "boundary", title: "Local Boundary", detail: "Files are copied only into Application Support. No upload, backend request, cloud storage, or transcode path is active.", result: "Safe", isPassed: links.contains { $0.status == "Linked" }, systemImage: "lock.shield.fill")
        ]
    }

    private func mediaAssetRecord(
        project: HFCreatorPublishingContent,
        kind: HFCreatorMediaAssetKind,
        status: HFCreatorPublishingAssetStatus
    ) -> HFCreatorMediaAssetRecord {
        let imported = importedAsset(projectID: project.id, kind: kind)
        let resolvedStatus = imported == nil ? status : .ready
        return HFCreatorMediaAssetRecord(
            id: "\(project.id)-\(kind.id.lowercased())",
            projectID: project.id,
            projectTitle: project.title,
            kind: kind,
            status: resolvedStatus,
            registry: "\(kind.rawValue) Registry",
            lifecycle: imported == nil ? mediaAssetLifecycle(for: resolvedStatus) : "Imported into app sandbox",
            readiness: readinessStatus(for: resolvedStatus),
            detail: mediaAssetDetail(project: project, kind: kind, status: resolvedStatus, imported: imported),
            systemImage: kind.systemImage
        )
    }

    private func mediaAssetLifecycle(for status: HFCreatorPublishingAssetStatus) -> String {
        switch status {
        case .ready:
            return "Ready for local review"
        case .needsReview:
            return "Needs creator review"
        case .placeholder:
            return "Placeholder only"
        case .missing:
            return "Missing local metadata"
        }
    }

    private func mediaAssetDetail(
        project: HFCreatorPublishingContent,
        kind: HFCreatorMediaAssetKind,
        status: HFCreatorPublishingAssetStatus,
        imported: HFCreatorImportedMediaAsset? = nil
    ) -> String {
        if let imported {
            return "\(imported.originalFilename) copied to app sandbox. \(imported.displaySize). Checksum \(imported.checksum.prefix(12))."
        }
        switch kind {
        case .poster:
            return project.posterAssetName == nil ? "Poster uses local placeholder metadata until a local file is imported." : "Poster registry references bundled local artwork metadata."
        case .trailer:
            return "Trailer state is \(status.rawValue). No upload, transcode, or backend transfer is active."
        case .metadata:
            return "Metadata readiness tracks title, description, creator, genre, tags, and runtime."
        case .artwork:
            return "Artwork package state is tracked for local publishing readiness and local import records."
        }
    }

    private func importedAsset(projectID: String, kind: HFCreatorMediaAssetKind) -> HFCreatorImportedMediaAsset? {
        contentSnapshot.importedMediaAssets.first {
            $0.projectID == projectID
                && $0.kind == kind
                && ($0.status == .imported || $0.status == .duplicate)
        }
    }

    private func uploadSelectionState(for record: HFCreatorMediaAssetRecord) -> String {
        switch record.status {
        case .ready:
            return "Selected"
        case .needsReview:
            return "Selected for Review"
        case .placeholder:
            return "Placeholder"
        case .missing:
            return "Excluded"
        }
    }

    private func uploadSelectionSource(for record: HFCreatorMediaAssetRecord) -> String {
        switch record.kind {
        case .poster:
            return "Poster Registry"
        case .trailer:
            return "Trailer Registry"
        case .artwork:
            return "Artwork Registry"
        case .metadata:
            return "Metadata Registry"
        }
    }

    private func uploadSelectionDetail(for record: HFCreatorMediaAssetRecord) -> String {
        switch record.status {
        case .ready:
            return "\(record.kind.rawValue) is selected from local readiness metadata."
        case .needsReview:
            return "\(record.kind.rawValue) is included for creator review before any future transfer."
        case .placeholder:
            return "\(record.kind.rawValue) remains a visible placeholder in the local package."
        case .missing:
            return "\(record.kind.rawValue) is excluded until registry metadata exists."
        }
    }

    private func uploadValidationDetail(for record: HFCreatorMediaAssetRecord) -> String {
        switch record.status {
        case .ready:
            return "Ready for local package manifest."
        case .needsReview:
            return "Available for manifest review before future production upload work."
        case .placeholder:
            return "Allowed as placeholder metadata, but flagged for creator review."
        case .missing:
            return "Missing metadata blocks local preflight."
        }
    }

    private func creatorID(for creatorName: String) -> String {
        let slug = creatorName
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0 == " " }
            .split(separator: " ")
            .joined(separator: "-")
        return slug.isEmpty ? "creator-local" : "creator-\(slug)"
    }

    private func projectVersion(for project: HFCreatorPublishingContent) -> String {
        switch project.releaseState {
        case .draft:
            return "v0.1"
        case .review:
            return "v0.8"
        case .scheduled:
            return "v0.9"
        case .published:
            return "v1.0"
        case .archived:
            return "archived"
        }
    }

    private func mediaImportQueueState(for record: HFCreatorMediaAssetRecord) -> String {
        if importedAsset(projectID: record.projectID, kind: record.kind) != nil {
            return "Imported"
        }
        switch record.status {
        case .ready:
            return "Ready"
        case .needsReview:
            return "Review"
        case .placeholder:
            return "Placeholder"
        case .missing:
            return "Blocked"
        }
    }

    private func slugID(_ value: String) -> String {
        let slug = value
            .lowercased()
            .filter { $0.isLetter || $0.isNumber || $0 == " " }
            .split(separator: " ")
            .joined(separator: "-")
        return slug.isEmpty ? "local" : slug
    }

    func refreshIdentitySessionRuntime(reason: String = "Session refreshed") {
        rebuildIdentitySessionRuntime(reason: reason)
    }

    func signInWithDevelopmentIdentity(role: HFIdentityAccessRole = .creator) {
        let session = HFIdentityAccessSession.development(
            role: role,
            profile: activeViewingProfile,
            creatorID: creatorProfiles.first?.creator.id
        )
        identityKeychainStore.save(session)
        let event = identityAuditEvent(action: "Sign In", detail: "\(role.title) development session created and stored in Keychain.")
        identityAccessRuntimeSnapshot = .snapshot(
            state: .localDevelopment,
            session: session,
            auditEvents: trimmedIdentityEvents(appending: event),
            deletionRequestStatus: "Not Requested",
            detail: "Local development identity is active. Production Sign in with Apple requires Apple Developer capability setup."
        )
        refreshAuthRuntimeStatus()
        rebuildIdentitySessionRuntime(reason: "Development identity signed in")
    }

    func signOutIdentitySession() {
        identityKeychainStore.delete()
        let event = identityAuditEvent(action: "Sign Out", detail: "Secure identity session removed from Keychain.")
        identityAccessRuntimeSnapshot = .snapshot(
            state: .signedOut,
            session: nil,
            auditEvents: trimmedIdentityEvents(appending: event),
            deletionRequestStatus: "Not Requested",
            detail: "Signed out of the active identity session. Local profile mode remains available."
        )
        refreshAuthRuntimeStatus()
        rebuildIdentitySessionRuntime(reason: "Identity session signed out")
    }

    func refreshIdentityAccessSession() {
        guard let session = identityAccessRuntimeSnapshot.activeSession else {
            restoreIdentityAccessSessionFromKeychain(reason: "No in-memory session; checked Keychain")
            return
        }
        let refreshed = session.refreshed()
        identityKeychainStore.save(refreshed)
        let event = identityAuditEvent(action: "Refresh", detail: "Session refreshed until \(refreshed.expiresAtLabel).")
        identityAccessRuntimeSnapshot = .snapshot(
            state: refreshed.provider == "Development Identity" ? .localDevelopment : .remoteAuthenticated,
            session: refreshed,
            auditEvents: trimmedIdentityEvents(appending: event),
            deletionRequestStatus: identityAccessRuntimeSnapshot.deletionRequestStatus,
            detail: "Identity session refreshed and restored through secure storage."
        )
        rebuildIdentitySessionRuntime(reason: "Identity session refreshed")
    }

    func requestIdentityAccountDeletion() {
        guard let session = identityAccessRuntimeSnapshot.activeSession else { return }
        let event = identityAuditEvent(action: "Deletion Request", detail: "Account deletion request recorded for \(session.displayName).")
        identityAccessRuntimeSnapshot = .snapshot(
            state: .deletionRequested,
            session: session,
            auditEvents: trimmedIdentityEvents(appending: event),
            deletionRequestStatus: "Requested",
            detail: "Deletion request is recorded locally. Production fulfillment requires provider confirmation and retention policy execution."
        )
        rebuildIdentitySessionRuntime(reason: "Account deletion request recorded")
    }

    func expireIdentityAccessSessionForQA() {
        guard let session = identityAccessRuntimeSnapshot.activeSession else { return }
        let expired = session.expiredForQA()
        identityKeychainStore.save(expired)
        restoreIdentityAccessSessionFromKeychain(reason: "QA expired session recovery")
    }

    private func restoreIdentityAccessSessionFromKeychain(reason: String) {
        guard let session = identityKeychainStore.load() else {
            identityAccessRuntimeSnapshot = .signedOut(reason: reason)
            return
        }
        if session.isExpired {
            let event = identityAuditEvent(action: "Expired", detail: "Expired secure session rejected during restore.")
            identityKeychainStore.delete()
            identityAccessRuntimeSnapshot = .snapshot(
                state: .expired,
                session: nil,
                auditEvents: trimmedIdentityEvents(appending: event),
                deletionRequestStatus: "Not Requested",
                detail: "Stored session expired and was removed. Sign in again to continue."
            )
            return
        }
        let event = identityAuditEvent(action: "Restore", detail: "Secure identity session restored from Keychain.")
        identityAccessRuntimeSnapshot = .snapshot(
            state: session.provider == "Development Identity" ? .localDevelopment : .remoteAuthenticated,
            session: session,
            auditEvents: trimmedIdentityEvents(appending: event),
            deletionRequestStatus: "Not Requested",
            detail: reason
        )
    }

    private func rebuildIdentitySessionRuntime(reason: String) {
        let profile = activeViewingProfile
        let creator = activeCreatorProfile.creator
        let accessSession = activeIdentityAccessSession
        let viewerRole = accessSession?.role.title ?? profile.role
        let workspaceTitle = accessSession?.role.workspaceTitle ?? (profile.role == "Creator" ? "Creator Workspace" : "Watch Workspace")
        let workspaceScope = accessSession?.role == .creator || accessSession?.role == .admin ? "Drafts, publishing, analytics, and role-gated creator mutations" : "Streaming, library, and profile-scoped recommendations"
        let permissionSummary = accessSession == nil ? "Local profile fallback with signed-out production identity" : "\(viewerRole) permissions resolved from secure identity session"
        identitySessionRuntime = HFIdentitySessionRuntimeSnapshot(
            state: accessSession == nil ? .localActive : .localActive,
            activeProfileID: accessSession?.userID ?? profile.id,
            displayName: accessSession?.displayName ?? profile.displayName,
            viewerRole: viewerRole,
            avatarSymbol: profile.avatarSymbol,
            creatorName: creator.name,
            creatorRole: creator.role,
            workspaceID: accessSession?.workspaceID ?? (profile.role == "Creator" ? "creator-workspace" : "watch-workspace"),
            workspaceTitle: workspaceTitle,
            workspaceScope: workspaceScope,
            permissionSummary: permissionSummary,
            sessionMode: accessSession == nil ? "Local Profile Fallback" : identityAccessRuntimeSnapshot.statusLabel,
            reason: reason,
            updatedAtLabel: accessSession == nil ? "Local session resolved" : "Identity session resolved"
        )
    }

    private func identityAuditEvent(action: String, detail: String) -> HFIdentityAccessAuditEvent {
        HFIdentityAccessAuditEvent(
            id: "identity-\(UUID().uuidString.lowercased())",
            action: action,
            detail: detail,
            createdAt: Date()
        )
    }

    private func trimmedIdentityEvents(appending event: HFIdentityAccessAuditEvent) -> [HFIdentityAccessAuditEvent] {
        Array((identityAccessRuntimeSnapshot.auditEvents + [event]).suffix(8))
    }

    var profileInitials: String {
        let parts = activeViewingProfile.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
        let initials = String(parts).uppercased()
        return initials.isEmpty ? "HF" : initials
    }

    var accountMode: String {
        identitySessionRuntime.statusLabel
    }

    var cloudAccountStatus: String {
        "Cloud Account Not Connected Yet"
    }

    // hf.services.profilePrivacyState
    var profilePrivacyState: String {
        "Privacy Ready"
    }

    // MovieCatalogService
    // LocalCatalogAdapter
    // RemoteCatalogAdapterReady
    // hf.services.catalogProvider
    // hf.services.localCatalogAdapter
    // hf.services.remoteCatalogReady
    // hf.services.catalogReadiness
    // hf.services.catalogIdentity
    // hf.services.movieLookup
    private var catalogRepository: CatalogRepository {
        CatalogRepository(snapshot: contentSnapshot)
    }

    private var creatorRepository: CreatorRepository {
        CreatorRepository(snapshot: contentSnapshot)
    }

    private var publishingRepository: PublishingRepository {
        PublishingRepository(snapshot: contentSnapshot)
    }

    private var rawCatalogMovies: [Movie] {
        var seen = Set<String>()
        return (catalogRepository.fetchCatalog() + publishingRepository.fetchPublishedTitles()).filter { movie in
            seen.insert(movie.id).inserted
        }
    }

    private var libraryRepository: LibraryRepository {
        LibraryRepository(
            movies: rawCatalogMovies,
            savedIDs: savedMovieIDs,
            downloadedIDs: downloadedMovieIDs,
            lastViewedID: lastPlayerMovieID
        )
    }

    private var contentQueryEngine: HFContentQueryEngine {
        HFContentQueryEngine(
            catalogRepository: catalogRepository,
            creatorRepository: creatorRepository,
            publishingRepository: publishingRepository,
            libraryRepository: libraryRepository
        )
    }

    var allCatalogMovies: [Movie] {
        contentQueryEngine.fetchCatalog()
    }

    var persistedCollections: [Category] {
        catalogRepository.fetchCollections()
    }

    var persistedCreators: [Creator] {
        creatorRepository.fetchCreators()
    }

    func queryCatalog() -> [Movie] {
        contentQueryEngine.fetchCatalog()
    }

    func queryTitle(id: String) -> Movie? {
        contentQueryEngine.fetchTitle(id: id)
    }

    func queryTitles(search query: String, filter: String = "All") -> [Movie] {
        contentQueryEngine.searchTitles(query: query, filter: filter)
    }

    func queryCreators(search query: String) -> [Creator] {
        contentQueryEngine.searchCreators(query: query)
    }

    func queryTitles(genre: String) -> [Movie] {
        contentQueryEngine.titlesByGenre(genre)
    }

    func queryTitles(tag: String) -> [Movie] {
        contentQueryEngine.titlesByTag(tag)
    }

    func queryCollection(id: String) -> Category? {
        contentQueryEngine.lookupCollection(id: id)
    }

    func queryCollections() -> [Category] {
        contentQueryEngine.fetchCollections()
    }

    func querySeries(id: String) -> HFSeriesRecord? {
        contentQueryEngine.lookupSeries(id: id)
    }

    func querySeries() -> [HFSeriesRecord] {
        contentQueryEngine.fetchSeries()
    }

    func queryEpisode(id: String) -> HFEpisodeRecord? {
        contentQueryEngine.lookupEpisode(id: id)
    }

    func queryEpisodes() -> [HFEpisodeRecord] {
        contentQueryEngine.fetchEpisodes()
    }

    func queryRelatedContent(for movie: Movie, limit: Int = 8) -> [Movie] {
        contentQueryEngine.relatedContent(for: movie, limit: limit)
    }

    func queryRecentlyPublished(limit: Int = 10) -> [Movie] {
        contentQueryEngine.recentlyPublished(limit: limit)
    }

    func queryCreatorPublishedTitles() -> [Movie] {
        contentQueryEngine.creatorPublishedTitles()
    }

    func queryLibraryRecommendations(anchor movie: Movie? = nil, limit: Int = 10) -> [Movie] {
        contentQueryEngine.libraryAwareRecommendations(anchor: movie, limit: limit)
    }

    func loadCatalogRuntime() {
        if catalogRuntimeSnapshot.state == .idle || catalogRuntimeSnapshot.state == .empty || catalogRuntimeSnapshot.state == .failed {
            refreshCatalogRuntime(reason: "Catalog load requested")
        }
    }

    func refreshCatalogRuntime(reason: String = "Manual catalog refresh") {
        catalogRuntimeSnapshot = .loading(
            reason: reason,
            previousCount: catalogRuntimeSnapshot.totalTitles,
            generation: catalogRuntimeGeneration
        )
        rebuildCatalogRuntime(reason: reason)
    }

    func invalidateCatalogRuntime(reason: String) {
        catalogRuntimePageCache.removeAll()
        catalogRuntimeSnapshot = catalogRuntimeSnapshot.invalidated(reason: reason)
        rebuildCatalogRuntime(reason: "Invalidated: \(reason)")
    }

    func catalogRuntimePage(
        filter: String = "All",
        sort: HFCatalogRuntimeSort = .editorial,
        page: Int = 0,
        pageSize: Int = 12
    ) -> HFCatalogRuntimePage {
        let normalizedPage = max(0, page)
        let normalizedPageSize = max(1, pageSize)
        let cacheKey = catalogRuntimeCacheKey(
            filter: filter,
            sort: sort,
            page: normalizedPage,
            pageSize: normalizedPageSize
        )
        if let cached = catalogRuntimePageCache[cacheKey], cached.generation == catalogRuntimeSnapshot.generation {
            return cached
        }

        let filtered = sortedCatalogRuntimeMovies(filter: filter, sort: sort)
        let totalPages = max(1, Int(ceil(Double(filtered.count) / Double(normalizedPageSize))))
        let start = normalizedPage * normalizedPageSize
        let movies = start >= filtered.count ? [] : Array(filtered.dropFirst(start).prefix(normalizedPageSize))
        let pageRecord = HFCatalogRuntimePage(
            cacheKey: cacheKey,
            filter: filter,
            sort: sort,
            page: normalizedPage,
            pageSize: normalizedPageSize,
            totalResults: filtered.count,
            totalPages: totalPages,
            movies: movies,
            generation: catalogRuntimeSnapshot.generation
        )
        catalogRuntimePageCache[cacheKey] = pageRecord
        return pageRecord
    }

    func catalogRuntimeMovies(
        filter: String = "All",
        sort: HFCatalogRuntimeSort = .editorial,
        page: Int = 0,
        pageSize: Int = 12
    ) -> [Movie] {
        catalogRuntimePage(filter: filter, sort: sort, page: page, pageSize: pageSize).movies
    }

    func catalogRuntimeCollections(filter: String = "All", pageSize: Int = 12) -> [Category] {
        catalogRails(filter: filter).map { category in
            let page = catalogRuntimePage(filter: category.id, sort: .editorial, page: 0, pageSize: pageSize)
            guard !page.movies.isEmpty else { return category }
            return Category(id: category.id, title: category.title, subtitle: category.subtitle, movies: page.movies)
        }
    }

    private func rebuildCatalogRuntime(reason: String) {
        catalogRuntimeGeneration += 1
        catalogRuntimePageCache.removeAll()
        let titles = queryCatalog()
        catalogRuntimeSnapshot = .ready(
            titles: titles.count,
            creators: persistedCreators.count,
            collections: queryCollections().count,
            series: querySeries().count,
            episodes: queryEpisodes().count,
            cachedPageCount: 0,
            generation: catalogRuntimeGeneration,
            reason: reason
        )
    }

    private func catalogRuntimeCacheKey(
        filter: String,
        sort: HFCatalogRuntimeSort,
        page: Int,
        pageSize: Int
    ) -> String {
        "\(filter.lowercased())|\(sort.rawValue)|\(page)|\(pageSize)|\(catalogRuntimeGeneration)"
    }

    private func sortedCatalogRuntimeMovies(filter: String, sort: HFCatalogRuntimeSort) -> [Movie] {
        let filtered = catalogRuntimeFilteredMovies(filter: filter)
        switch sort {
        case .editorial:
            return filtered
        case .title:
            return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .creator:
            return filtered.sorted {
                if $0.creatorName == $1.creatorName {
                    return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
                return $0.creatorName.localizedCaseInsensitiveCompare($1.creatorName) == .orderedAscending
            }
        case .recentlyPublished:
            let recentIDs = queryRecentlyPublished(limit: max(filtered.count, 1)).map(\.id)
            return filtered.sorted { lhs, rhs in
                (recentIDs.firstIndex(of: lhs.id) ?? Int.max) < (recentIDs.firstIndex(of: rhs.id) ?? Int.max)
            }
        case .progress:
            return filtered.sorted { ($0.progress ?? 0) > ($1.progress ?? 0) }
        }
    }

    private func catalogRuntimeFilteredMovies(filter: String) -> [Movie] {
        switch filter {
        case "All":
            return queryCatalog()
        case "Movies", "Series", "Originals", "Creator Published", "Downloaded":
            return queryTitles(search: "", filter: filter)
        case "Saved":
            return libraryRepository.fetchSavedTitles()
        case "Continue Watching":
            return libraryRepository.fetchContinueWatching()
        case "Offline":
            return libraryRepository.fetchOfflineTitles()
        case "Premieres":
            return queryCatalog().filter { $0.isComingSoon || $0.genres.contains("Premiere") }
        case "Progress":
            return queryCatalog().filter { $0.progress != nil }
        default:
            if let collection = queryCollection(id: filter) {
                return collection.movies
            }
            let genreMatches = queryTitles(genre: filter)
            if !genreMatches.isEmpty { return genreMatches }
            let tagMatches = queryTitles(tag: filter)
            if !tagMatches.isEmpty { return tagMatches }
            return queryTitles(search: filter)
        }
    }

    var contentBackendRepositoryMetrics: [HFContentRepositoryMetric] {
        [
            HFContentRepositoryMetric(id: "catalog", title: "CatalogRepository", value: "\(catalogRepository.fetchCatalog().count)", detail: "Movies, series, episodes, and collections fetch through the content snapshot.", systemImage: "rectangle.stack.fill"),
            HFContentRepositoryMetric(id: "creator", title: "CreatorRepository", value: "\(creatorRepository.fetchCreators().count)", detail: "Creator profiles and title relationships fetch from canonical creators.", systemImage: "person.crop.rectangle.stack.fill"),
            HFContentRepositoryMetric(id: "publishing", title: "PublishingRepository", value: "\(publishingRepository.fetchProjects().count)", detail: "Draft, review, scheduled, published, and archived projects persist together.", systemImage: "square.stack.3d.up.fill"),
            HFContentRepositoryMetric(id: "library", title: "LibraryRepository", value: "\(libraryRepository.fetchSavedTitles().count)", detail: "Saved, offline, continue-watching, and completed shelves resolve through catalog IDs.", systemImage: "bookmark.fill")
        ]
    }

    var contentBackendRelationshipRecords: [HFContentRelationshipRecord] {
        [
            HFContentRelationshipRecord(id: "movie-creator", title: "Movie -> Creator", source: "\(allCatalogMovies.count) titles", target: "\(persistedCreators.count) creators", state: "Mapped", systemImage: "person.crop.rectangle.stack.fill"),
            HFContentRelationshipRecord(id: "series-episodes", title: "Series -> Seasons -> Episodes", source: "\(seriesRecords.count) series", target: "\(episodeRecords.count) episodes", state: "Mapped", systemImage: "play.square.stack.fill"),
            HFContentRelationshipRecord(id: "collection-titles", title: "Collection -> Titles", source: "\(persistedCollections.count) collections", target: "\(persistedCollections.flatMap(\.movies).count) title links", state: "Fetched", systemImage: "rectangle.grid.2x2.fill"),
            HFContentRelationshipRecord(id: "creator-projects", title: "Creator -> Projects", source: "\(persistedCreators.count) creators", target: "\(creatorPublishingContents.count) projects", state: "Persisted", systemImage: "wand.and.stars"),
            HFContentRelationshipRecord(id: "library-catalog", title: "Library -> Catalog", source: "\(libraryViewingHistory.count) activity rows", target: "\(allCatalogMovies.count) catalog titles", state: "Resolved", systemImage: "bookmark.square.fill")
        ]
    }

    var contentBackendPersistenceMetrics: [HFContentRepositoryMetric] {
        let databaseHealth = contentStorage.healthCheck()
        return [
            HFContentRepositoryMetric(id: "database", title: "Durable Content Database", value: databaseHealth.storageKind, detail: "Schema v\(databaseHealth.schemaVersion) stores content records with rollback-safe SQLite transactions.", systemImage: "externaldrive.fill"),
            HFContentRepositoryMetric(id: "records", title: "Database Records", value: "\(databaseHealth.totalRecords)", detail: "Movies, creators, series, seasons, episodes, collections, projects, drafts, manifests, and asset metadata are recorded by type.", systemImage: "tablecells.fill"),
            HFContentRepositoryMetric(id: "migration", title: "Migration State", value: databaseHealth.migrationState, detail: databaseHealth.lastError ?? "Legacy UserDefaults snapshots remain readable as rollback fallback.", systemImage: "arrow.triangle.2.circlepath"),
            HFContentRepositoryMetric(id: "updated", title: "Database Health", value: databaseHealth.lastError == nil ? "Healthy" : "Review", detail: databaseHealth.updatedAtLabel, systemImage: databaseHealth.lastError == nil ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
        ]
    }

    var contentDatabaseHealthRecords: [HFContentRepositoryMetric] {
        let databaseHealth = contentStorage.healthCheck()
        let sortedCounts = databaseHealth.recordCounts.sorted { $0.key < $1.key }
        return sortedCounts.map { key, value in
            HFContentRepositoryMetric(
                id: "database-\(key)",
                title: key.replacingOccurrences(of: "_", with: " ").capitalized,
                value: "\(value)",
                detail: "Stored in the durable content database at schema v\(databaseHealth.schemaVersion).",
                systemImage: "cylinder.split.1x2.fill"
            )
        }
    }

    func contentDatabaseExportFixtureData() -> Data? {
        contentStorage.exportFixtureData(seed: contentSnapshot)
    }

    var contentBackendFetchMetrics: [HFContentRepositoryMetric] {
        [
            HFContentRepositoryMetric(id: "fetch-catalog", title: "Fetch Catalog", value: "\(catalogRepository.fetchCatalog().count)", detail: "Read-only title retrieval through CatalogRepository.", systemImage: "film.stack.fill"),
            HFContentRepositoryMetric(id: "fetch-creators", title: "Fetch Creators", value: "\(creatorRepository.fetchCreators().count)", detail: "Read-only creator retrieval through CreatorRepository.", systemImage: "person.2.fill"),
            HFContentRepositoryMetric(id: "fetch-series", title: "Fetch Series", value: "\(catalogRepository.fetchSeries().count)", detail: "Read-only episodic retrieval through CatalogRepository.", systemImage: "rectangle.stack.fill"),
            HFContentRepositoryMetric(id: "fetch-collections", title: "Fetch Collections", value: "\(catalogRepository.fetchCollections().count)", detail: "Read-only collection retrieval through CatalogRepository.", systemImage: "rectangle.grid.2x2.fill")
        ]
    }

    var movieCatalogStatus: String {
        "Local Catalog Adapter Active"
    }

    var catalogProviderMode: String {
        "Remote Catalog Provider Not Connected Yet"
    }

    var originalsCatalog: [Movie] {
        queryCatalog().filter(\.isOriginal)
    }

    var creatorDraftProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .draft }
    }

    var creatorReviewProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .review }
    }

    var creatorScheduledProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .scheduled }
    }

    var creatorPublishedProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .published }
    }

    var creatorArchivedProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter { $0.releaseState == .archived }
    }

    var creatorReadyForReviewProjects: [HFCreatorPublishingContent] {
        creatorPublishingContents.filter(\.readyForReview)
    }

    var creatorPublishingQueueRecords: [HFCreatorPublishingQueueRecord] {
        let order: [HFCreatorReleaseState: Int] = [.review: 0, .draft: 1, .scheduled: 2, .published: 3, .archived: 4]
        return creatorPublishingContents
            .sorted { lhs, rhs in
                let left = order[lhs.releaseState] ?? 9
                let right = order[rhs.releaseState] ?? 9
                if left == right { return lhs.title < rhs.title }
                return left < right
            }
            .map { project in
                HFCreatorPublishingQueueRecord(
                    id: "queue-\(project.id)",
                    project: project,
                    priority: publishingPriority(for: project),
                    stage: project.releaseState.rawValue,
                    nextStep: publishingNextStep(for: project),
                    owner: project.creator
                )
            }
    }

    var creatorPublishingReadinessItems: [HFCreatorPublishingReadinessItem] {
        let activeProjects = creatorPublishingContents.filter { $0.releaseState != .archived }
        let readyProjects = activeProjects.filter(\.readyForReview).count
        let activeAssets = activeProjects.flatMap(mediaAssetRecords(for:))
        let assetReady = activeProjects.filter { project in
            mediaAssetRecords(for: project).allSatisfy { $0.status == .ready }
        }.count

        return [
            HFCreatorPublishingReadinessItem(id: "metadata", title: "Metadata readiness", detail: "\(activeAssets.filter { $0.kind == .metadata && $0.status == .ready }.count) metadata records are ready in the media asset runtime.", status: "\(activeAssets.filter { $0.kind == .metadata && $0.status == .ready }.count)/\(activeProjects.count)", systemImage: "text.justify.left"),
            HFCreatorPublishingReadinessItem(id: "poster", title: "Poster readiness", detail: "\(activeAssets.filter { $0.kind == .poster && $0.status == .ready }.count) poster registry records are ready or staged.", status: "\(activeAssets.filter { $0.kind == .poster && $0.status == .ready }.count)/\(activeProjects.count)", systemImage: "photo.fill.on.rectangle.fill"),
            HFCreatorPublishingReadinessItem(id: "trailer", title: "Trailer readiness", detail: "\(activeAssets.filter { $0.kind == .trailer && $0.status == .ready }.count) trailer registry records have local preview state.", status: "\(activeAssets.filter { $0.kind == .trailer && $0.status == .ready }.count)/\(activeProjects.count)", systemImage: "film.stack.fill"),
            HFCreatorPublishingReadinessItem(id: "assets", title: "Media asset runtime", detail: "\(assetReady) active packages have runtime asset records ready.", status: "\(assetReady)/\(activeProjects.count)", systemImage: "rectangle.stack.fill"),
            HFCreatorPublishingReadinessItem(id: "review", title: "Ready for review", detail: "\(readyProjects) packages can move into local review.", status: "\(readyProjects)", systemImage: "checkmark.seal.fill"),
            HFCreatorPublishingReadinessItem(id: "discovery", title: "Discovery connection", detail: "\(creatorPublishedProjects.count) published packages appear in local discovery.", status: "\(creatorPublishedProjects.count)", systemImage: "sparkle.magnifyingglass")
        ]
    }

    var creatorPublishingScheduleItems: [HFCreatorPublishingScheduleItem] {
        creatorPublishingContents.enumerated().map { index, project in
            HFCreatorPublishingScheduleItem(
                id: "schedule-\(project.id)",
                title: project.title,
                window: publishingWindow(for: project, index: index),
                status: project.releaseState == .published ? "Visible" : project.releaseState == .archived ? "Archived" : "Planned",
                detail: project.releaseState == .published ? "Already appears in local discovery." : "Local publishing calendar preview only."
            )
        }
    }

    var creatorPublishingAuditRecords: [HFCreatorPublishingAuditRecord] {
        [
            HFCreatorPublishingAuditRecord(id: "no-upload", title: "No upload action", detail: "Publishing remains a local lifecycle preview with no media transfer.", result: "Safe", systemImage: "lock.shield.fill"),
            HFCreatorPublishingAuditRecord(id: "no-provider", title: "No provider endpoint", detail: "No distributor, storefront, or publishing API is connected.", result: "Local", systemImage: "network.slash"),
            HFCreatorPublishingAuditRecord(id: "no-payment", title: "No payment path", detail: "No purchase, subscription, payout, or payment processor is active.", result: "Safe", systemImage: "creditcard.trianglebadge.exclamationmark"),
            HFCreatorPublishingAuditRecord(id: "discovery-gate", title: "Discovery gate", detail: "Only Published records enter local Home, Search, Discovery, Collections, and Creator Profile surfaces.", result: "\(creatorPublishedProjects.count) visible", systemImage: "checkmark.seal.fill"),
            HFCreatorPublishingAuditRecord(id: "review-gate", title: "Review gate", detail: "\(creatorReadyForReviewProjects.count) projects satisfy local readiness checks.", result: "\(creatorReadyForReviewProjects.count) ready", systemImage: "doc.text.magnifyingglass")
        ]
    }

    var creatorPublishingChecklistItems: [HFCreatorPublishingChecklistItem] {
        [
            HFCreatorPublishingChecklistItem(id: "metadata", title: "Metadata", status: readinessStatus(for: creatorPrimaryReadinessProject.metadataStatus), detail: "Title, description, creator, genre, tags, runtime, and release state."),
            HFCreatorPublishingChecklistItem(id: "poster", title: "Poster", status: readinessStatus(for: creatorPrimaryReadinessProject.posterStatus), detail: "Poster asset or safe placeholder assigned locally."),
            HFCreatorPublishingChecklistItem(id: "trailer", title: "Trailer", status: readinessStatus(for: creatorPrimaryReadinessProject.trailerStatus), detail: "Trailer preview state remains local-only."),
            HFCreatorPublishingChecklistItem(id: "artwork", title: "Artwork", status: readinessStatus(for: creatorPrimaryReadinessProject.artworkStatus), detail: "Artwork package status for local review."),
            HFCreatorPublishingChecklistItem(id: "analytics", title: "Analytics", status: analyticsTitleRecords.contains { $0.id == creatorPrimaryReadinessProject.id } ? "Linked" : "Preview", detail: "P6 analytics can inform publishing decisions."),
            HFCreatorPublishingChecklistItem(id: "audit", title: "Audit", status: "Safe", detail: "No upload, provider, network, payment, or external publish behavior.")
        ]
    }

    var creatorPrimaryReadinessProject: HFCreatorPublishingContent {
        creatorReviewProjects.first
            ?? creatorDraftProjects.first
            ?? creatorScheduledProjects.first
            ?? creatorPublishedProjects.first
            ?? creatorPublishingContents[0]
    }

    var creatorCollaborationRoster: [HFCreatorCollaboratorRecord] {
        [
            HFCreatorCollaboratorRecord(id: "owner", name: activeViewingProfile.displayName, role: "Owner", permissionScope: "All local project surfaces", focus: "Project direction, publishing readiness, and final local review", systemImage: activeViewingProfile.avatarSymbol),
            HFCreatorCollaboratorRecord(id: "director", name: "Mara Chen", role: "Director", permissionScope: "Creative notes", focus: "Scene intent, commentary, and creator profile context", systemImage: "megaphone.fill"),
            HFCreatorCollaboratorRecord(id: "producer", name: "Ari Stone", role: "Producer", permissionScope: "Schedule preview", focus: "Readiness, launch handoff, and review gates", systemImage: "checkmark.seal.fill"),
            HFCreatorCollaboratorRecord(id: "writer", name: "Nia Bell", role: "Writer", permissionScope: "Metadata notes", focus: "Synopsis, tags, captions, and story positioning", systemImage: "text.book.closed.fill"),
            HFCreatorCollaboratorRecord(id: "editor", name: "Theo Park", role: "Editor", permissionScope: "Trailer notes", focus: "Trailer preview, pacing notes, and completion checks", systemImage: "film.stack.fill"),
            HFCreatorCollaboratorRecord(id: "composer", name: "June Vale", role: "Composer", permissionScope: "Audio notes", focus: "Theme direction, cue notes, and tone references", systemImage: "music.note.list"),
            HFCreatorCollaboratorRecord(id: "marketing", name: "Sol Rivera", role: "Marketing", permissionScope: "Campaign notes", focus: "Poster, social kit, discovery copy, and launch story", systemImage: "sparkles")
        ]
    }

    var creatorProjectTeamRecords: [HFCreatorProjectTeamRecord] {
        creatorPublishingContents.enumerated().map { index, project in
            let team = collaborationTeam(for: index)
            return HFCreatorProjectTeamRecord(
                id: "team-\(project.id)",
                project: project,
                owner: project.creator,
                collaborators: team,
                status: project.releaseState == .published ? "Active" : "Local Review",
                permissionSummary: "\(team.count) local roles • owner-reviewed changes only"
            )
        }
    }

    var creatorCollaborationTasks: [HFCreatorCollaborationTaskRecord] {
        creatorPublishingContents.enumerated().flatMap { index, project in
            [
                HFCreatorCollaborationTaskRecord(
                    id: "task-\(project.id)-metadata",
                    title: "Lock metadata package",
                    projectTitle: project.title,
                    assigneeRole: "Writer",
                    status: collaborationTaskStatus(for: project.metadataStatus, fallback: "To Do"),
                    detail: "Review title, synopsis, genre, tags, runtime, and creator attribution.",
                    systemImage: "text.justify.left"
                ),
                HFCreatorCollaborationTaskRecord(
                    id: "task-\(project.id)-trailer",
                    title: "Review trailer preview",
                    projectTitle: project.title,
                    assigneeRole: index.isMultiple(of: 2) ? "Editor" : "Director",
                    status: collaborationTaskStatus(for: project.trailerStatus, fallback: "In Progress"),
                    detail: "Check local trailer status before publishing readiness.",
                    systemImage: "film.stack.fill"
                ),
                HFCreatorCollaborationTaskRecord(
                    id: "task-\(project.id)-launch",
                    title: "Prepare launch notes",
                    projectTitle: project.title,
                    assigneeRole: "Producer",
                    status: project.releaseState == .published ? "Complete" : project.releaseState == .scheduled ? "Review" : "In Progress",
                    detail: "Connect publishing queue, launch preview, and audit state.",
                    systemImage: "paperplane.circle.fill"
                ),
                HFCreatorCollaborationTaskRecord(
                    id: "task-\(project.id)-handoff",
                    title: "Confirm team handoff",
                    projectTitle: project.title,
                    assigneeRole: "Owner",
                    status: project.releaseState == .published || project.releaseState == .archived ? "Complete" : "To Do",
                    detail: "Owner checks collaborator roles and local review scope before the next production pass.",
                    systemImage: "person.crop.circle.badge.checkmark"
                )
            ]
        }
    }

    var creatorCollaborationNotes: [HFCreatorCollaborationNoteRecord] {
        let primary = creatorPrimaryReadinessProject
        return [
            HFCreatorCollaborationNoteRecord(id: "project-notes", title: "Project Notes", projectTitle: primary.title, authorRole: "Director", detail: "Tone, story promise, and creator commentary context are ready for local team review.", noteType: "Project"),
            HFCreatorCollaborationNoteRecord(id: "publishing-notes", title: "Publishing Notes", projectTitle: primary.title, authorRole: "Producer", detail: "Publishing readiness depends on metadata, poster, trailer, artwork, and local audit checks.", noteType: "Publishing"),
            HFCreatorCollaborationNoteRecord(id: "launch-notes", title: "Launch Notes", projectTitle: primary.title, authorRole: "Marketing", detail: "Discovery copy, social asset kit, and launch center preview stay local-only.", noteType: "Launch"),
            HFCreatorCollaborationNoteRecord(id: "review-notes", title: "Review Notes", projectTitle: primary.title, authorRole: "Owner", detail: "Owner review remains a local decision. No external approval workflow is active.", noteType: "Review")
        ]
    }

    var creatorCollaborationActivity: [HFCreatorCollaborationActivityRecord] {
        [
            HFCreatorCollaborationActivityRecord(id: "activity-readiness", title: "Readiness updated", detail: "\(creatorReadyForReviewProjects.count) creator projects satisfy local review checks.", actorRole: "Producer", timeLabel: "Today", systemImage: "checkmark.seal.fill"),
            HFCreatorCollaborationActivityRecord(id: "activity-analytics", title: "Analytics reviewed", detail: "\(analyticsInsights.first?.title ?? "Local insight") is informing the next publishing pass.", actorRole: "Owner", timeLabel: "Today", systemImage: "chart.bar.xaxis"),
            HFCreatorCollaborationActivityRecord(id: "activity-social", title: "Social kit noted", detail: "Campaign copy and poster direction are staged for local team review.", actorRole: "Marketing", timeLabel: "Yesterday", systemImage: "bubble.left.and.bubble.right.fill"),
            HFCreatorCollaborationActivityRecord(id: "activity-trailer", title: "Trailer note added", detail: "Editor note attached to the local trailer preview state.", actorRole: "Editor", timeLabel: "Yesterday", systemImage: "film.stack.fill")
        ]
    }

    var creatorCollaborationTimeline: [HFCreatorCollaborationTimelineRecord] {
        [
            HFCreatorCollaborationTimelineRecord(id: "timeline-create", title: "Create", detail: "Owner and director shape the local project package.", stage: "Project", status: "Active", systemImage: "wand.and.stars"),
            HFCreatorCollaborationTimelineRecord(id: "timeline-manage", title: "Manage", detail: "Producer tracks CMS, assets, and project team state.", stage: "Content", status: "Active", systemImage: "rectangle.stack.fill"),
            HFCreatorCollaborationTimelineRecord(id: "timeline-analyze", title: "Analyze", detail: "P6 analytics inform priority, readiness, and title positioning.", stage: "Analytics", status: "Linked", systemImage: "chart.line.uptrend.xyaxis"),
            HFCreatorCollaborationTimelineRecord(id: "timeline-publish", title: "Publish", detail: "P7 publishing queue remains local, audited, and discovery-gated.", stage: "Publishing", status: "Local", systemImage: "paperplane.circle.fill"),
            HFCreatorCollaborationTimelineRecord(id: "timeline-improve", title: "Improve", detail: "Team notes and activity feed drive the next creator revision.", stage: "Collaboration", status: "Preview", systemImage: "person.3.fill")
        ]
    }

    var creatorCollaborationTaskStatusCounts: [(status: String, count: Int)] {
        ["To Do", "In Progress", "Review", "Complete"].map { status in
            (status, creatorCollaborationTasks.filter { $0.status == status }.count)
        }
    }

    private func publishingPriority(for project: HFCreatorPublishingContent) -> String {
        switch project.releaseState {
        case .review:
            return project.readyForReview ? "High" : "Review"
        case .draft:
            return "Build"
        case .scheduled:
            return "Planned"
        case .published:
            return "Monitor"
        case .archived:
            return "Archive"
        }
    }

    private func publishingNextStep(for project: HFCreatorPublishingContent) -> String {
        if project.metadataStatus != .ready { return "Complete metadata" }
        if project.posterStatus != .ready { return "Finalize poster" }
        if project.trailerStatus != .ready { return "Stage trailer preview" }
        if project.artworkStatus != .ready { return "Review artwork" }
        switch project.releaseState {
        case .draft:
            return "Move to local review"
        case .review:
            return "Review readiness"
        case .scheduled:
            return "Confirm planned window"
        case .published:
            return "Measure performance"
        case .archived:
            return "Retain audit"
        }
    }

    private func publishingWindow(for project: HFCreatorPublishingContent, index: Int) -> String {
        switch project.releaseState {
        case .draft:
            return "Draft window"
        case .review:
            return "Review this week"
        case .scheduled:
            return "Planned T+\(index + 2)"
        case .published:
            return "Now visible"
        case .archived:
            return "Retained"
        }
    }

    private func readinessStatus(for status: HFCreatorPublishingAssetStatus) -> String {
        switch status {
        case .ready:
            return "Ready"
        case .needsReview:
            return "Review"
        case .placeholder:
            return "Placeholder"
        case .missing:
            return "Missing"
        }
    }

    private func collaborationTeam(for index: Int) -> [HFCreatorCollaboratorRecord] {
        let roster = creatorCollaborationRoster
        let rotatingRoles = Array(roster.dropFirst())
        let first = rotatingRoles[index % rotatingRoles.count]
        let second = rotatingRoles[(index + 2) % rotatingRoles.count]
        let third = rotatingRoles[(index + 4) % rotatingRoles.count]
        return [roster[0], first, second, third]
    }

    private func collaborationTaskStatus(for status: HFCreatorPublishingAssetStatus, fallback: String) -> String {
        switch status {
        case .ready:
            return "Complete"
        case .needsReview:
            return "Review"
        case .placeholder:
            return "In Progress"
        case .missing:
            return fallback
        }
    }

    private func makeSeriesRecord(
        movieID: String,
        seasonCount: Int,
        episodesPerSeason: [Int],
        status: HFCreatorReleaseState,
        baseProgress: Double?,
        episodeTitles: [String]
    ) -> HFSeriesRecord {
        let hero = movie(id: movieID) ?? featuredMovie
        var titleIndex = 0
        let totalEpisodes = max(1, episodesPerSeason.reduce(0, +))
        let seasons = (1...seasonCount).map { seasonNumber in
            let episodeCount = episodesPerSeason.indices.contains(seasonNumber - 1) ? episodesPerSeason[seasonNumber - 1] : 6
            let episodes = (1...episodeCount).map { episodeNumber in
                let title = episodeTitles.indices.contains(titleIndex) ? episodeTitles[titleIndex] : "Episode \(episodeNumber)"
                let absoluteIndex = titleIndex
                titleIndex += 1
                return HFEpisodeRecord(
                    id: "\(movieID)-s\(seasonNumber)-e\(episodeNumber)",
                    seriesID: movieID,
                    seasonNumber: seasonNumber,
                    episodeNumber: episodeNumber,
                    title: title,
                    synopsis: "\(hero.title) episode \(episodeNumber) expands the local series arc for creator, CMS, library, discovery, and analytics surfaces.",
                    runtime: "\(34 + (absoluteIndex * 3) % 18)m",
                    artworkStatus: hero.posterAssetName == nil ? .placeholder : .ready,
                    releaseState: status,
                    progress: episodeProgress(baseProgress: baseProgress, episodeIndex: absoluteIndex, totalEpisodes: totalEpisodes)
                )
            }
            return HFSeasonRecord(
                id: "\(movieID)-s\(seasonNumber)",
                seriesID: movieID,
                seasonNumber: seasonNumber,
                title: "Season \(seasonNumber)",
                episodes: episodes
            )
        }
        return HFSeriesRecord(
            id: movieID,
            title: hero.title,
            synopsis: hero.synopsis,
            creatorName: hero.creatorName,
            genre: hero.genres.first ?? "Series",
            status: status,
            seasons: seasons,
            heroMovie: hero
        )
    }

    private func episodeProgress(baseProgress: Double?, episodeIndex: Int, totalEpisodes: Int) -> Double? {
        guard let baseProgress else { return nil }
        let completed = Int((baseProgress * Double(totalEpisodes)).rounded(.down))
        if episodeIndex < completed { return 1.0 }
        if episodeIndex == completed {
            let fractional = (baseProgress * Double(totalEpisodes)) - Double(completed)
            return min(0.94, max(0.12, fractional))
        }
        return nil
    }

    var seriesRecords: [HFSeriesRecord] {
        let storedSeries = querySeries()
        guard storedSeries.isEmpty else { return storedSeries }
        return [
            makeSeriesRecord(
                movieID: "paranormall-s1",
                seasonCount: 1,
                episodesPerSeason: [7],
                status: .published,
                baseProgress: 0.28,
                episodeTitles: [
                    "Cold Open",
                    "The House That Answered",
                    "Basement Signal",
                    "Witness Marks",
                    "The Long Hall",
                    "Static Room",
                    "Nothing Normal"
                ]
            ),
            makeSeriesRecord(
                movieID: "black-turnip",
                seasonCount: 1,
                episodesPerSeason: [6],
                status: .scheduled,
                baseProgress: nil,
                episodeTitles: [
                    "Seed Memory",
                    "The Ledger",
                    "Smoke House",
                    "Root Work",
                    "Inheritance",
                    "Harvest"
                ]
            ),
            makeSeriesRecord(
                movieID: "old-satan",
                seasonCount: 1,
                episodesPerSeason: [5],
                status: .review,
                baseProgress: nil,
                episodeTitles: [
                    "The Return",
                    "Ash Road",
                    "Small Church",
                    "Bargain",
                    "Old Fire"
                ]
            )
        ]
    }

    var episodeRecords: [HFEpisodeRecord] {
        let storedEpisodes = queryEpisodes()
        guard storedEpisodes.isEmpty else { return storedEpisodes }
        return seriesRecords.flatMap { series in series.seasons.flatMap(\.episodes) }
    }

    var primarySeriesRecord: HFSeriesRecord {
        seriesRecords.first ?? makeSeriesRecord(
            movieID: featuredMovie.id,
            seasonCount: 1,
            episodesPerSeason: [1],
            status: .published,
            baseProgress: featuredMovie.progress,
            episodeTitles: ["Pilot"]
        )
    }

    var nextEpisodeRecommendations: [HFNextEpisodeRecommendation] {
        seriesRecords.compactMap { series in
            let episodes = series.seasons.flatMap(\.episodes)
            guard !episodes.isEmpty else { return nil }
            let next = episodes.first { ($0.progress ?? 0) < 0.95 } ?? episodes.last!
            let watched = episodes.filter { ($0.progress ?? 0) >= 0.95 }.count
            return HFNextEpisodeRecommendation(
                id: "next-\(next.id)",
                seriesTitle: series.title,
                seasonNumber: next.seasonNumber,
                episodeNumber: next.episodeNumber,
                title: next.title,
                detail: "Season \(next.seasonNumber), Episode \(next.episodeNumber) in \(series.title)",
                progressLabel: "\(watched)/\(episodes.count) complete"
            )
        }
    }

    var episodeAnalyticsRecords: [HFEpisodeAnalyticsRecord] {
        episodeRecords.map { episode in
            let seed = analyticsSeed(episode.id)
            let progress = episode.progress ?? Double((seed % 44) + 18) / 100
            return HFEpisodeAnalyticsRecord(
                id: "episode-analytics-\(episode.id)",
                seriesTitle: seriesRecords.first { $0.id == episode.seriesID }?.title ?? "Series",
                episodeTitle: episode.title,
                views: 160 + seed % 1_140,
                completionRate: min(96, max(22, Int(progress * 100) + seed % 18)),
                dropOffPoint: "Act \(2 + seed % 3)",
                watchTime: "\(18 + seed % 34)m"
            )
        }
        .sorted { lhs, rhs in
            if lhs.views == rhs.views { return lhs.completionRate > rhs.completionRate }
            return lhs.views > rhs.views
        }
    }

    var seriesDiscoveryCategory: Category {
        Category(
            id: "series-episodes",
            title: "Series & Episodes",
            subtitle: "Season-based worlds, limited series, and creator episodic paths",
            movies: seriesRecords.map(\.heroMovie)
        )
    }

    var creatorPublishedMovies: [Movie] {
        queryCreatorPublishedTitles()
    }

    var cmsContentRecords: [HFCMSContentRecord] {
        let titleRecords = allCatalogMovies.map { cmsRecord(for: $0) }
        let episodeRecords = cmsEpisodeRecords
        let trailerRecords = creatorPublishingContents.map { project in
            HFCMSContentRecord(
                id: "\(project.id)-trailer",
                title: "\(project.title) Trailer",
                type: .trailer,
                description: "Trailer management record for \(project.title).",
                creatorName: project.creator,
                genre: project.genre,
                tags: project.tags + ["Trailer"],
                runtime: "Preview",
                rating: "Unrated",
                artworkStatus: project.artworkStatus,
                trailerStatus: project.trailerStatus,
                releaseState: project.releaseState,
                collectionIDs: cmsCollectionIDs(for: project.movie),
                seriesID: nil,
                relatedTitleIDs: []
            )
        }
        let collectionRecords = cmsCollections.map { collection in
            HFCMSContentRecord(
                id: "cms-content-\(collection.id)",
                title: collection.title,
                type: .collection,
                description: collection.description,
                creatorName: "HighFive CMS",
                genre: "Collection",
                tags: ["Collection"],
                runtime: "\(collection.movieIDs.count) titles",
                rating: "Local",
                artworkStatus: .ready,
                trailerStatus: .placeholder,
                releaseState: .published,
                collectionIDs: [collection.id],
                seriesID: nil,
                relatedTitleIDs: collection.movieIDs
            )
        }
        let creatorRecords = creatorProfiles.map { profile in
            HFCMSContentRecord(
                id: "cms-creator-\(profile.id)",
                title: profile.creator.name,
                type: .creator,
                description: profile.bio,
                creatorName: profile.creator.name,
                genre: profile.creator.role,
                tags: ["Creator", "Profile"],
                runtime: "\(profile.filmography.count) titles",
                rating: "Local",
                artworkStatus: .ready,
                trailerStatus: .placeholder,
                releaseState: .published,
                collectionIDs: profile.collections.map(\.id),
                seriesID: nil,
                relatedTitleIDs: profile.filmography.map(\.id)
            )
        }
        return titleRecords + episodeRecords + trailerRecords + collectionRecords + creatorRecords
    }

    var cmsCollections: [HFCMSCollectionRecord] {
        let managedCollections = collectionSystem.map { category in
            HFCMSCollectionRecord(
                id: category.id,
                title: category.title,
                description: category.subtitle ?? "Managed local collection",
                movieIDs: category.movies.map(\.id)
            )
        }
        return managedCollections + creatorProfiles.flatMap { profile in
            profile.collections.map { category in
                HFCMSCollectionRecord(
                    id: category.id,
                    title: category.title,
                    description: category.subtitle ?? "Creator collection",
                    movieIDs: category.movies.map(\.id)
                )
            }
        }
    }

    var cmsStatusCounts: [HFCMSStatusCount] {
        HFCreatorReleaseState.allCases.map { state in
            HFCMSStatusCount(
                state: state,
                count: cmsContentRecords.filter { $0.releaseState == state && [.movie, .series, .episode, .trailer].contains($0.type) }.count
            )
        }
    }

    var cmsRelationships: [HFCMSRelationshipRecord] {
        let movieCreator = allCatalogMovies.map { movie in
            HFCMSRelationshipRecord(
                id: "creator-\(movie.id)",
                source: movie.title,
                target: movie.creatorName,
                relationship: "Movie -> Creator",
                detail: "Creator ownership and profile routing"
            )
        }
        let movieCollections = allCatalogMovies.flatMap { movie in
            cmsCollections
                .filter { $0.movieIDs.contains(movie.id) }
                .map { collection in
                    HFCMSRelationshipRecord(
                        id: "collection-\(movie.id)-\(collection.id)",
                        source: movie.title,
                        target: collection.title,
                        relationship: "Movie -> Collection",
                        detail: "Discovery and browse grouping"
                    )
                }
        }
        let seriesEpisodes = cmsEpisodeRecords.map { episode in
            HFCMSRelationshipRecord(
                id: "episode-\(episode.id)",
                source: episode.title,
                target: seriesRecords.first { $0.id == episode.seriesID }?.title ?? episode.seriesID ?? "Series",
                relationship: "Episode -> Series",
                detail: "Series structure for scalable catalog browsing"
            )
        }
        let seriesSeasons = seriesRecords.flatMap { series in
            series.seasons.map { season in
                HFCMSRelationshipRecord(
                    id: "season-\(season.id)",
                    source: season.title,
                    target: series.title,
                    relationship: "Season -> Series",
                    detail: "\(season.episodes.count) local episode records"
                )
            }
        }
        let related = allCatalogMovies.flatMap { movie in
            relatedMovies(for: movie).prefix(2).map { related in
                HFCMSRelationshipRecord(
                    id: "related-\(movie.id)-\(related.id)",
                    source: movie.title,
                    target: related.title,
                    relationship: "Movie -> Related Titles",
                    detail: "Recommendation and detail-page connection"
                )
            }
        }
        var seen = Set<String>()
        return (movieCreator + movieCollections + seriesSeasons + seriesEpisodes + related).filter { seen.insert($0.id).inserted }
    }

    var creatorProfiles: [HFCreatorProfile] {
        let publishingCreators = creatorPublishingContents.map(\.creator)
        let catalogCreators = allCatalogMovies.map(\.creatorName)
        let storedCreators = creatorRepository.fetchCreators()
        var seen = Set<String>()
        let creators = (storedCreators + (publishingCreators + catalogCreators).compactMap { name -> Creator? in
            guard seen.insert(name).inserted, !storedCreators.contains(where: { $0.name == name }) else { return nil }
            return Creator(
                id: name.lowercased().replacingOccurrences(of: " ", with: "-"),
                name: name,
                role: "Creator",
                avatarAssetName: nil,
                featuredMovieIDs: allCatalogMovies.filter { $0.creatorName == name }.map(\.id)
            )
        })
        return creators.map { creatorProfile(for: $0) }
    }

    var newThisWeekCatalog: [Movie] {
        ["friendly", "paranormall-s1", "behind-vision", "artist-development", "big-loss"].compactMap(movie(id:)) + creatorPublishedMovies
    }

    var downloadableCatalog: [Movie] {
        allCatalogMovies.filter { isDownloaded($0) || $0.isDownloaded }
    }

    var premiumHomeCatalogRails: [Category] {
        var rails = [
            Category(id: "new-this-week", title: "New This Week", subtitle: "Fresh HighFive picks", movies: newThisWeekCatalog),
            Category(id: "continue-watching", title: "Continue Watching", subtitle: "Pick up where you left off", movies: allCatalogMovies.filter { $0.progress != nil }),
            Category(id: "recommended", title: "Recommended", subtitle: "Selected for your viewing profile", movies: ["black-turnip", "sunshine", "arrival-time", "maple-street", "night-file"].compactMap(movie(id:))),
            Category(id: "only-on-highfive", title: "Only On HighFive", subtitle: "Originals and local showcase titles", movies: originalsCatalog)
        ]
        if !creatorPublishedMovies.isEmpty {
            rails.insert(
                Category(
                    id: "creator-library-published",
                    title: "Creator Published",
                    subtitle: "Titles promoted from Creator Library",
                    movies: creatorPublishedMovies
                ),
                at: 1
            )
        }
        return rails
    }

    var catalogReadinessRows: [String] {
        [
            "Local catalog - Active",
            "Shared movie identity - Active",
            "Home/Search/Movie Detail - Connected",
            "Library/Downloads - Connected",
            "Remote provider - Not Connected Yet",
            "Contracts - Ready from architecture plan"
        ]
    }

    // Playback Source Resolver
    // Local Playback Source
    // RemoteStreamingProviderReady
    // hf.services.playerService
    // hf.services.playbackSourceResolver
    // hf.services.localPlaybackSource
    // hf.services.remoteStreamingProviderReady
    // hf.services.playerReadiness
    // hf.services.continueWatchingState
    var playerProviderStatus: String {
        "Remote Streaming Provider Not Connected Yet"
    }

    var playerServiceMode: String {
        "Player Service Local Resolver"
    }

    var playerReadinessRows: [String] {
        let localStatus = playbackSource(for: continueWatchingMovie).status == .playableLocal ? "Active" : "Missing"
        return [
            "Catalog title - Active",
            "Player route - Active",
            "Player Entitlement Boundary - Local",
            "Local entitlement adapter - Active",
            "Playback source resolver - Active",
            "Local source - \(localStatus)",
            "Remote streaming provider - Not Connected Yet",
            "Remote payment provider - Not Connected Yet",
            "Store provider - Not Connected Yet",
            "Server entitlement validation - Not Connected Yet",
            "Rights checks - Not Connected Yet"
        ]
    }

    func playbackSource(for movie: Movie) -> HFPlaybackSource {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        if Self.localPreviewStreamingIDs.contains(catalogMovie.id) {
            return HFPlaybackSource(
                movieID: catalogMovie.id,
                title: catalogMovie.title,
                status: .playableLocal,
                localURL: nil,
                providerName: "HighFive Local Preview",
                readinessLabel: "Local preview streaming ready",
                limitation: "Local preview only. No streaming provider connected."
            )
        }

        return HFPlaybackSource(
            movieID: catalogMovie.id,
            title: catalogMovie.title,
            status: .sourceNotConnected,
            localURL: nil,
            providerName: "Remote Streaming Provider",
            readinessLabel: "Streaming source not connected yet",
            limitation: "Player route ready. Streaming source not connected yet."
        )
    }

    func playbackDescriptor(for movie: Movie) -> HFPlaybackDescriptor {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        if let activeStagingPlaybackDescriptor,
           activeStagingPlaybackDescriptor.movieID == catalogMovie.id {
            return HFPlaybackDescriptor(
                id: activeStagingPlaybackDescriptor.id,
                movieID: activeStagingPlaybackDescriptor.movieID,
                title: catalogMovie.title,
                status: activeStagingPlaybackDescriptor.status,
                provider: activeStagingPlaybackDescriptor.provider,
                providerAssetMapping: activeStagingPlaybackDescriptor.providerAssetMapping,
                detail: activeStagingPlaybackDescriptor.detail,
                boundary: activeStagingPlaybackDescriptor.boundary
            )
        }

        guard streamingConfiguration.hasAnyRuntimeConfig else {
            return localPreviewPlaybackResolver.descriptor(for: catalogMovie.id, title: catalogMovie.title)
        }

        return remotePlaybackDescriptorGateway.descriptor(
            for: HFPlaybackDescriptorRequest(movieID: catalogMovie.id, profileID: activeProfileID),
            title: catalogMovie.title
        )
    }

    func playbackDescriptorAccessRequest(for movie: Movie) -> HFPlaybackDescriptorAccessRequest {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let context = playbackEntitlementContext(for: catalogMovie)
        return HFPlaybackDescriptorAccessRequest(
            movieID: catalogMovie.id,
            profileID: activeProfileID,
            productIdentifier: context.productReference.productIdentifier,
            provider: streamingConfiguration.preferredProvider,
            entitlementRequirement: context.entitlementRequirement,
            backendRequirement: .required
        )
    }

    func entitlementGatedPlaybackDescriptor(for movie: Movie) -> HFPlaybackDescriptorAccessResponse {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let descriptor = playbackDescriptor(for: catalogMovie)
        let context = playbackEntitlementContext(for: catalogMovie)
        let service = HFEntitlementGatedPlaybackDescriptorService(
            streamingConfiguration: streamingConfiguration,
            entitlementConfiguration: entitlementConfiguration
        )
        return service.accessResponse(
            request: playbackDescriptorAccessRequest(for: catalogMovie),
            descriptor: descriptor,
            context: context,
            entitlementRuntimeStatus: entitlementRuntimeStatus
        )
    }

    func cloudflarePlaybackDescriptorState(for movie: Movie) -> HFCloudflarePlaybackDescriptorState {
        entitlementGatedPlaybackDescriptor(for: movie).cloudflareState
    }

    func playbackDescriptorGateStatus(for movie: Movie) -> HFPlaybackDescriptorGateStatus {
        entitlementGatedPlaybackDescriptor(for: movie).gateStatus
    }

    func backendEntitlementValidationRequest(for movie: Movie) -> HFBackendEntitlementValidationRequest {
        backendPlaybackDescriptorContract(for: movie).entitlementValidationRequest
    }

    func backendPlaybackDescriptorRequest(for movie: Movie) -> HFBackendPlaybackDescriptorRequest {
        backendPlaybackDescriptorContract(for: movie).playbackDescriptorRequest
    }

    func backendPlaybackDescriptorContract(for movie: Movie) -> HFBackendPlaybackDescriptorContract {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let context = playbackEntitlementContext(for: catalogMovie)
        let descriptor = playbackDescriptor(for: catalogMovie)
        let hasCompleteContractConfig = backendConfiguration.hasCompleteRuntimeConfig &&
            entitlementConfiguration.hasCompleteRuntimeConfig &&
            streamingConfiguration.hasCompleteRuntimeConfig
        return HFBackendPlaybackDescriptorContract.staged(
            movieID: catalogMovie.id,
            userID: activeProfileID,
            anonymousSessionID: "local-session-\(activeProfileID)",
            context: context,
            descriptorAccessRequest: playbackDescriptorAccessRequest(for: catalogMovie),
            descriptorStatus: descriptor.status,
            entitlementState: serverEntitlementValidationState(for: catalogMovie),
            hasCompleteRuntimeConfig: hasCompleteContractConfig
        )
    }

    func serverEntitlementValidationState(for movie: Movie) -> HFServerEntitlementValidationState {
        guard backendConfiguration.hasCompleteRuntimeConfig,
              entitlementConfiguration.hasCompleteRuntimeConfig else {
            return .pending
        }

        return entitlementRuntimeStatus.accessState == .accessReady || entitlementRuntimeStatus.accessState == .entitlementConfigured ? .approved : .pending
    }

    func playbackDescriptorContractStatus(for movie: Movie) -> String {
        backendPlaybackDescriptorContract(for: movie).statusLabel
    }

    var canRunStagingEntitlementPlaybackCheck: Bool {
        entitlementPlaybackAdapter.canContactStagingEndpoint
    }

    func refreshEntitlementAndPlaybackDescriptor(for movie: Movie) async {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        guard canRunStagingEntitlementPlaybackCheck else {
            let result = HFEntitlementPlaybackResult.localFallback(
                movieID: catalogMovie.id,
                detail: "Staging backend not configured. Local Preview fallback active."
            )
            entitlementPlaybackResult = result
            backendEntitlementRequestState = .notConfigured
            backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
            activeStagingPlaybackDescriptor = nil
            lastPlaybackDescriptorAuditContext = result.auditContext
            return
        }

        backendEntitlementRequestState = .validatingEntitlement
        backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
        activeStagingPlaybackDescriptor = nil

        let entitlementRequest = backendEntitlementValidationRequest(for: catalogMovie)
        let descriptorRequest = backendPlaybackDescriptorRequest(for: catalogMovie)
        let result = await entitlementPlaybackAdapter.validateAndRequestPlaybackDescriptor(
            entitlementRequest: entitlementRequest,
            descriptorRequest: descriptorRequest
        )

        entitlementPlaybackResult = result
        backendEntitlementRequestState = result.entitlementState
        backendPlaybackDescriptorRequestState = result.descriptorState
        lastPlaybackDescriptorAuditContext = result.auditContext

        if let descriptor = result.playbackDescriptor {
            activeStagingPlaybackDescriptor = HFPlaybackDescriptor(
                id: descriptor.id,
                movieID: descriptor.movieID,
                title: catalogMovie.title,
                status: descriptor.status,
                provider: descriptor.provider,
                providerAssetMapping: descriptor.providerAssetMapping,
                detail: descriptor.detail,
                boundary: descriptor.boundary
            )
        } else {
            activeStagingPlaybackDescriptor = nil
        }
    }

    func validateBackendEntitlement(for movie: Movie) async {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        guard canRunStagingEntitlementPlaybackCheck else {
            backendEntitlementRequestState = .notConfigured
            activeStagingPlaybackDescriptor = nil
            return
        }

        backendEntitlementRequestState = .validatingEntitlement
        do {
            let response = try await entitlementPlaybackAdapter.validateEntitlement(
                request: backendEntitlementValidationRequest(for: catalogMovie)
            )
            backendEntitlementRequestState = response.entitlementStatus == .approved ? .entitlementApproved : .entitlementDenied
            lastPlaybackDescriptorAuditContext = HFBackendRequestAuditContext(
                movieID: catalogMovie.id,
                endpointLabel: HFBackendPlaybackDescriptorEndpoint.entitlementValidation.statusLabel,
                state: backendEntitlementRequestState,
                detail: response.detail,
                localFallback: "Local Preview fallback active"
            )
        } catch {
            backendEntitlementRequestState = .localPreviewFallbackActive
            activeStagingPlaybackDescriptor = nil
        }
    }

    func requestBackendPlaybackDescriptor(for movie: Movie) async {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        guard canRunStagingEntitlementPlaybackCheck else {
            backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
            activeStagingPlaybackDescriptor = nil
            return
        }

        backendPlaybackDescriptorRequestState = .requestingPlaybackDescriptor
        do {
            let response = try await entitlementPlaybackAdapter.requestPlaybackDescriptor(
                request: backendPlaybackDescriptorRequest(for: catalogMovie)
            )
            switch response.error {
            case .descriptorExpired:
                backendPlaybackDescriptorRequestState = .playbackDescriptorExpired
                activeStagingPlaybackDescriptor = nil
            case .descriptorRefreshRequired:
                backendPlaybackDescriptorRequestState = .descriptorRefreshRequired
                activeStagingPlaybackDescriptor = nil
            case .entitlementDenied:
                backendPlaybackDescriptorRequestState = .entitlementDenied
                activeStagingPlaybackDescriptor = nil
            case .unavailable:
                backendPlaybackDescriptorRequestState = .playbackDescriptorUnavailable
                activeStagingPlaybackDescriptor = nil
            case .none:
                backendPlaybackDescriptorRequestState = response.playbackDescriptorStatus == .stagingDescriptorReady ? .stagingPlaybackDescriptorReady : .playbackDescriptorUnavailable
            }
            lastPlaybackDescriptorAuditContext = HFBackendRequestAuditContext(
                movieID: catalogMovie.id,
                endpointLabel: HFBackendPlaybackDescriptorEndpoint.playbackDescriptor.statusLabel,
                state: backendPlaybackDescriptorRequestState,
                detail: response.detail,
                localFallback: "Local Preview fallback active"
            )
        } catch {
            backendPlaybackDescriptorRequestState = .playbackDescriptorUnavailable
            activeStagingPlaybackDescriptor = nil
        }
    }

    func clearTransientPlaybackDescriptor() {
        activeStagingPlaybackDescriptor = nil
        entitlementPlaybackResult = nil
        backendEntitlementRequestState = entitlementPlaybackAdapter.runtimeState
        backendPlaybackDescriptorRequestState = .localPreviewFallbackActive
        lastPlaybackDescriptorAuditContext = .localFallback(
            movieID: continueWatchingMovie.id,
            detail: "Transient staging descriptor cleared. Local Preview fallback active."
        )
    }

    func streamingProviderStatus(for movie: Movie) -> HFStreamingProviderStatus {
        streamingProviderStatus(for: playbackDescriptor(for: movie))
    }

    private func streamingProviderStatus(for descriptor: HFPlaybackDescriptor) -> HFStreamingProviderStatus {
        switch descriptor.status {
        case .localPreviewReady:
            return .localPreviewReady
        case .providerDescriptorMissing:
            return HFStreamingProviderStatus(
                status: .providerDescriptorMissing,
                provider: descriptor.provider,
                title: "Streaming Provider",
                detail: "Provider Descriptor Missing. Local preview remains available while backend-mediated playback is configured.",
                systemImage: "network.slash",
                accessibilityIdentifier: "hf.streaming.providerDescriptorMissing"
            )
        case .stagingDescriptorReady:
            return HFStreamingProviderStatus(
                status: .stagingDescriptorReady,
                provider: descriptor.provider,
                title: "Streaming Provider",
                detail: "Staging Descriptor Ready. Backend-mediated playback only; no production streaming claim is made.",
                systemImage: "checkmark.seal.fill",
                accessibilityIdentifier: "hf.streaming.stagingDescriptorReady"
            )
        case .streamingProviderNotConnected:
            return HFStreamingProviderStatus(
                status: .streamingProviderNotConnected,
                provider: descriptor.provider,
                title: "Streaming Provider",
                detail: "Streaming Provider Not Connected Yet. No streaming provider connected.",
                systemImage: "play.slash.fill",
                accessibilityIdentifier: "hf.streaming.notConnected"
            )
        }
    }

    func markStartedWatching(_ movie: Movie) {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        lastPlayerMovieID = catalogMovie.id
        UserDefaults.standard.set(catalogMovie.id, forKey: lastPlayerMovieKey)
        invalidateCatalogRuntime(reason: "Continue watching changed")
    }

    // Cloud Library Service
    // Offline Asset Service
    // Download Queue
    // Download Eligibility
    // Remote Download Provider
    // Local Offline State
    // hf.services.cloudLibrary
    // hf.services.librarySync
    // hf.services.offlineAssetService
    // hf.services.downloadQueue
    // hf.services.downloadEligibility
    // hf.services.offlineProviderReady
    // hf.services.downloadReadiness
    // hf.services.cloudLibraryReadiness
    var cloudLibraryStatus: HFCloudSyncStatus {
        .cloudReady
    }

    var librarySyncMode: String {
        "Cloud Library Service local ready. Cloud sync Not Connected Yet."
    }

    var offlineAssetServiceMode: String {
        "Offline Asset Service local ready"
    }

    var offlineProviderStatus: String {
        "Remote Download Provider Not Connected Yet"
    }

    var libraryReadinessRows: [String] {
        [
            "Saved list - Local",
            "Active profile - \(activeViewingProfile.displayName)",
            "Catalog identity - Active",
            "Cloud sync - Not Connected Yet",
            "Account service - Local profile",
            "Conflict resolution - Future"
        ]
    }

    var cloudLibraryProofRows: [String] {
        [
            "Cloud Library Service - Local Ready",
            "Saved List Sync - Not Connected Yet",
            "Active profile boundary - Ready",
            "Catalog identity - Active"
        ]
    }

    var downloadReadinessRows: [String] {
        let sourceStatus = playbackSource(for: continueWatchingMovie).status == .playableLocal ? "Active" : "Source required"
        return [
            "Local offline state - Active",
            "Catalog identity - Active",
            "Player source - \(sourceStatus)",
            "Remote download provider - Not Connected Yet",
            "Background downloads - Not Connected Yet",
            "Media storage - Not Created Yet"
        ]
    }

    var downloadArchitectureProofRows: [String] {
        [
            "Offline Asset Service - Local Ready",
            "Download Queue - Local State",
            "Download Eligibility - Source aware",
            "Remote Download Provider - Not Connected Yet"
        ]
    }

    var offlineAssetRecords: [HFOfflineAssetRecord] {
        downloadedMovies.map { movie in
            let eligibility = offlineEligibility(for: movie)
            return HFOfflineAssetRecord(
                id: "offline-\(movie.id)",
                movieID: movie.id,
                title: movie.title,
                status: "Local Offline State",
                detail: eligibility.reason,
                updatedAtLabel: "Local state"
            )
        }
    }

    var downloadQueueItems: [HFDownloadQueueItem] {
        downloadedMovies.map { movie in
            let eligibility = offlineEligibility(for: movie)
            return HFDownloadQueueItem(
                id: "queue-\(movie.id)",
                movieID: movie.id,
                title: movie.title,
                status: eligibility.statusLabel,
                reason: eligibility.reason
            )
        }
    }

    func offlineEligibility(for movie: Movie) -> (status: HFOfflineAssetStatus, statusLabel: String, reason: String) {
        let source = playbackSource(for: movie)
        if source.status == .playableLocal {
            return (.eligible, "Eligible", "Local playback source is active.")
        }
        if isDownloaded(movie) {
            return (.localStateOnly, "Local Offline State", "Media source required before real download.")
        }
        return (.sourceRequired, "Source Required", "Media source required before real download.")
    }

    func downloadEligibility(for movie: Movie) -> HFDownloadEligibilityResult {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        return makeDownloadEligibilityService(
            streamingStatus: playbackDescriptor(for: catalogMovie).status,
            entitlementStatus: entitlementRuntimeStatus.accessState
        )
        .eligibility(
            titleID: catalogMovie.id,
            title: catalogMovie.title,
            isInLocalOfflineShelf: isDownloaded(catalogMovie)
        )
    }

    func queueOfflineAsset(for movie: Movie) {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        downloadedMovieIDs.insert(catalogMovie.id)
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
        invalidateCatalogRuntime(reason: "Local offline shelf changed")
    }

    func removeOfflineAsset(for movie: Movie) {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        downloadedMovieIDs.remove(catalogMovie.id)
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
        invalidateCatalogRuntime(reason: "Local offline shelf changed")
    }

    func offlineAssetRecord(for movie: Movie) -> HFOfflineAssetRecord {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        let eligibility = offlineEligibility(for: catalogMovie)
        return HFOfflineAssetRecord(
            id: "offline-\(catalogMovie.id)",
            movieID: catalogMovie.id,
            title: catalogMovie.title,
            status: isDownloaded(catalogMovie) ? "Local Offline State" : eligibility.statusLabel,
            detail: eligibility.reason,
            updatedAtLabel: "Local state"
        )
    }

    func updateDisplayName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = localProfiles.firstIndex(where: { $0.id == activeProfileID }) else { return }
        localProfiles[index].displayName = trimmed
        UserDefaults.standard.set(trimmed, forKey: profileDisplayNamePrefix + activeProfileID)
        refreshAuthRuntimeStatus()
        refreshIdentitySessionRuntime(reason: "Display name changed")
    }

    func selectProfile(_ profile: HFLocalViewingProfile) {
        guard localProfiles.contains(where: { $0.id == profile.id }) else { return }
        persist(savedMovieIDs, key: scopedSavedKey)
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
        activeProfileID = profile.id
        UserDefaults.standard.set(activeProfileID, forKey: activeProfileKey)
        savedMovieIDs = Self.loadProfileIDs(
            defaults: .standard,
            scopedKey: scopedSavedKey,
            fallbackKey: savedKey,
            fallbackIDs: Set(["friendly", "paranormall-s1"])
        )
        downloadedMovieIDs = Self.loadProfileIDs(
            defaults: .standard,
            scopedKey: scopedDownloadsKey,
            fallbackKey: downloadsKey,
            fallbackIDs: Set(HFMockData.movies.filter(\.isDownloaded).map(\.id))
        )
        refreshAuthRuntimeStatus()
        invalidateCatalogRuntime(reason: "Active profile changed")
        refreshIdentitySessionRuntime(reason: "Active profile changed")
    }

    // hf.services.unifiedStore
    // hf.services.movieCatalog
    var featuredMovie: Movie {
        movie(id: "friendly") ?? allCatalogMovies[0]
    }

    var continueWatchingMovie: Movie {
        if let lastPlayerMovieID, let movie = movie(id: lastPlayerMovieID) {
            return movie
        }
        return allCatalogMovies.first { $0.progress != nil } ?? featuredMovie
    }

    var savedMovies: [Movie] {
        libraryRepository.fetchSavedTitles()
    }

    // hf.services.downloadState
    var downloadedMovies: [Movie] {
        libraryRepository.fetchOfflineTitles()
    }

    var libraryContinueWatchingMovies: [Movie] {
        libraryRepository.fetchContinueWatching()
    }

    var libraryCompletedMovies: [Movie] {
        libraryRepository.fetchCompletedTitles()
    }

    var libraryWatchLaterMovies: [Movie] {
        savedMovies.filter { $0.progress == nil }
    }

    var libraryFavoriteMovies: [Movie] {
        savedMovies.filter { movie in
            movie.isOriginal || movie.genres.contains("Drama") || movie.genres.contains("Crime")
        }
    }

    var libraryLastViewedMovie: Movie {
        continueWatchingMovie
    }

    var libraryNextEpisode: HFLibraryNextEpisode? {
        guard let next = nextEpisodeRecommendations.first,
              let series = seriesRecords.first(where: { $0.title == next.seriesTitle }) else {
            return nil
        }
        return HFLibraryNextEpisode(
            id: next.id,
            series: series.heroMovie,
            title: "S\(next.seasonNumber) E\(next.episodeNumber): \(next.title)",
            detail: "\(next.detail) • \(next.progressLabel)"
        )
    }

    var libraryViewingHistory: [HFLibraryActivityRecord] {
        var records: [HFLibraryActivityRecord] = []
        records.append(
            HFLibraryActivityRecord(
                id: "history-last-\(libraryLastViewedMovie.id)",
                movie: libraryLastViewedMovie,
                status: "Last Viewed",
                detail: "Most recent local playback route",
                progress: libraryLastViewedMovie.progress
            )
        )
        records += libraryContinueWatchingMovies.map { movie in
            HFLibraryActivityRecord(
                id: "history-progress-\(movie.id)",
                movie: movie,
                status: "In Progress",
                detail: "\(Int((movie.progress ?? 0) * 100))% watched locally",
                progress: movie.progress
            )
        }
        records += libraryCompletedMovies.map { movie in
            HFLibraryActivityRecord(
                id: "history-complete-\(movie.id)",
                movie: movie,
                status: "Completed",
                detail: "Completed in local viewing history",
                progress: movie.progress
            )
        }
        var seen = Set<String>()
        return records.filter { seen.insert($0.id).inserted }
    }

    var libraryUserCollections: [HFLibraryCollection] {
        [
            HFLibraryCollection(id: "favorites", title: "Favorites", detail: "Pinned from saved original titles", movies: libraryFavoriteMovies, systemImage: "star.fill"),
            HFLibraryCollection(id: "watch-later", title: "Watch Later", detail: "Saved titles without progress", movies: libraryWatchLaterMovies, systemImage: "bookmark.fill"),
            HFLibraryCollection(id: "documentaries", title: "Documentaries", detail: "Documentary titles in your local library", movies: allCatalogMovies.filter { $0.genres.contains("Documentary") }, systemImage: "doc.richtext.fill"),
            HFLibraryCollection(id: "crime", title: "Crime", detail: "Crime stories saved or recommended", movies: allCatalogMovies.filter { $0.genres.contains("Crime") }, systemImage: "eye.fill"),
            HFLibraryCollection(id: "creator-collections", title: "Creator Collections", detail: "Creator-led titles connected to profiles", movies: creatorProfiles.flatMap(\.filmography).reduce(into: [Movie]()) { result, movie in
                if !result.contains(where: { $0.id == movie.id }) { result.append(movie) }
            }, systemImage: "person.crop.rectangle.stack.fill"),
            HFLibraryCollection(id: "series", title: "Series", detail: "Season and episode paths from your local library", movies: seriesRecords.map(\.heroMovie), systemImage: "play.square.stack.fill"),
            HFLibraryCollection(id: "premieres", title: "Premieres", detail: "Premiere and scheduled local titles", movies: allCatalogMovies.filter { $0.isComingSoon || $0.genres.contains("Premiere") }, systemImage: "theatermasks.fill"),
            HFLibraryCollection(id: "available-offline", title: "Available Offline", detail: "Local offline preview shelf", movies: downloadedMovies, systemImage: "arrow.down.circle.fill")
        ].filter { !$0.movies.isEmpty }
    }

    var libraryIntelligenceSignals: [HFLibraryIntelligenceSignal] {
        [
            HFLibraryIntelligenceSignal(id: "continue", title: "Continue Watching", detail: "Feeds local recommendations and home rails", value: "\(libraryContinueWatchingMovies.count)", systemImage: "play.circle.fill"),
            HFLibraryIntelligenceSignal(id: "recommendations", title: "Recommendations", detail: "Based on \(libraryLastViewedMovie.title)", value: "\(relatedMovies(for: libraryLastViewedMovie).count)", systemImage: "sparkle.magnifyingglass"),
            HFLibraryIntelligenceSignal(id: "next-episode", title: "Next Episode", detail: nextEpisodeRecommendations.first?.detail ?? "No series progress yet", value: "\(nextEpisodeRecommendations.count)", systemImage: "play.square.stack.fill"),
            HFLibraryIntelligenceSignal(id: "collections", title: "Collections", detail: "Favorites, documentaries, crime, premieres, creator collections", value: "\(libraryUserCollections.count)", systemImage: "rectangle.stack.fill"),
            HFLibraryIntelligenceSignal(id: "offline", title: "Downloads Integration", detail: "Local offline preview state only", value: "\(downloadedMovies.count)", systemImage: "arrow.down.circle.fill")
        ]
    }

    var analyticsTitleRecords: [HFTitleAnalyticsRecord] {
        allCatalogMovies
            .map(analyticsRecord)
            .sorted { lhs, rhs in
                if lhs.totalViews == rhs.totalViews {
                    return lhs.completionRate > rhs.completionRate
                }
                return lhs.totalViews > rhs.totalViews
            }
    }

    var analyticsViewerMetrics: [HFAnalyticsMetric] {
        let titleRecords = analyticsTitleRecords
        let totalViews = titleRecords.reduce(0) { $0 + $1.totalViews }
        let totalWatchMinutes = titleRecords.reduce(0) { partial, record in
            partial + analyticsMinutes(from: record.averageWatchTime) * max(1, record.totalViews / 18)
        }
        let averageCompletion = titleRecords.isEmpty ? 0 : titleRecords.reduce(0) { $0 + $1.completionRate } / titleRecords.count
        let progressCount = allCatalogMovies.filter { $0.progress != nil }.count
        let resumeRate = progressCount == 0 ? 0 : Int((Double(libraryContinueWatchingMovies.count) / Double(progressCount)) * 100)
        let dropOffCount = libraryContinueWatchingMovies.filter { movie in
            let progress = movie.progress ?? 0
            return progress >= 0.25 && progress <= 0.72
        }.count

        return [
            HFAnalyticsMetric(id: "views", title: "Views", value: "\(totalViews)", detail: "Local catalog view estimate", systemImage: "play.tv.fill"),
            HFAnalyticsMetric(id: "unique-viewers", title: "Unique Viewers", value: "\(localProfiles.count)", detail: "Local profile count", systemImage: "person.2.fill"),
            HFAnalyticsMetric(id: "watch-time", title: "Watch Time", value: "\(max(1, totalWatchMinutes / 60))h", detail: "Computed from local progress", systemImage: "clock.fill"),
            HFAnalyticsMetric(id: "completion-rate", title: "Completion Rate", value: "\(averageCompletion)%", detail: "Average local title completion", systemImage: "checkmark.circle.fill"),
            HFAnalyticsMetric(id: "resume-rate", title: "Resume Rate", value: "\(resumeRate)%", detail: "In-progress titles with resume state", systemImage: "arrow.clockwise.circle.fill"),
            HFAnalyticsMetric(id: "episodes", title: "Episodes", value: "\(episodeRecords.count)", detail: "Local episode records across \(seriesRecords.count) series", systemImage: "play.square.stack.fill"),
            HFAnalyticsMetric(id: "drop-off-points", title: "Drop-off Points", value: "\(dropOffCount)", detail: "Mid-session local drop-off markers", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
        ]
    }

    var analyticsDiscoveryRecords: [HFDiscoveryAnalyticsRecord] {
        [
            HFDiscoveryAnalyticsRecord(id: "searches", title: "Searches", value: "\(recentSearches.count)", detail: "Recent local search terms", systemImage: "magnifyingglass"),
            HFDiscoveryAnalyticsRecord(id: "search-clicks", title: "Search Clicks", value: "\(searchMovies(query: recentSearches.first ?? featuredMovie.title, filter: "All").count)", detail: "Matching local result taps proxy", systemImage: "cursorarrow.click.2"),
            HFDiscoveryAnalyticsRecord(id: "collection-opens", title: "Collection Opens", value: "\(discoveryCollections.count + libraryUserCollections.count)", detail: "Discovery and Library collection surfaces", systemImage: "rectangle.stack.fill"),
            HFDiscoveryAnalyticsRecord(id: "recommendation-clicks", title: "Recommendation Clicks", value: "\(relatedMovies(for: libraryLastViewedMovie).count)", detail: "Because-you-watched local signal", systemImage: "sparkles"),
            HFDiscoveryAnalyticsRecord(id: "trending-signals", title: "Trending Signals", value: "\(discoveryCollections.first { $0.id == "trending" }?.movies.count ?? 0)", detail: "Trending rail titles", systemImage: "chart.line.uptrend.xyaxis")
        ]
    }

    var analyticsCreatorRecords: [HFCreatorAnalyticsRecord] {
        creatorProfiles.map { profile in
            let titleIDs = Set(profile.filmography.map(\.id))
            let records = analyticsTitleRecords.filter { titleIDs.contains($0.movie.id) }
            let views = records.reduce(0) { $0 + $1.totalViews }
            let watchMinutes = records.reduce(0) { $0 + analyticsMinutes(from: $1.averageWatchTime) * max(1, $1.totalViews / 20) }
            let topContent = records.first?.movie.title ?? profile.featuredProject?.title ?? "Local slate"
            let followers = 120 + analyticsSeed(profile.id) % 880
            let growth = "+\(8 + analyticsSeed(profile.creator.name) % 34)%"
            return HFCreatorAnalyticsRecord(
                id: profile.id,
                creatorName: profile.creator.name,
                publishedTitles: profile.publishedTitles.count,
                views: views,
                watchTime: "\(max(1, watchMinutes / 60))h",
                followers: followers,
                growthTrend: growth,
                topContent: topContent
            )
        }
        .sorted { $0.views > $1.views }
    }

    var analyticsInsights: [HFAnalyticsInsight] {
        let records = analyticsTitleRecords
        let mostWatched = records.first
        let fastestGrowing = records.sorted { lhs, rhs in
            analyticsSeed(lhs.movie.id + "growth") > analyticsSeed(rhs.movie.id + "growth")
        }.first
        let mostSaved = records.sorted { $0.libraryAdds > $1.libraryAdds }.first
        let highestCompletion = records.sorted { $0.completionRate > $1.completionRate }.first

        return [
            HFAnalyticsInsight(id: "most-watched", title: "Most Watched This Week", detail: mostWatched?.movie.title ?? "Local catalog", value: "\(mostWatched?.totalViews ?? 0)", systemImage: "play.fill"),
            HFAnalyticsInsight(id: "fastest-growing", title: "Fastest Growing Title", detail: fastestGrowing?.movie.title ?? "Local catalog", value: "+\(8 + analyticsSeed(fastestGrowing?.movie.id ?? "local") % 38)%", systemImage: "chart.line.uptrend.xyaxis"),
            HFAnalyticsInsight(id: "most-saved", title: "Most Saved Title", detail: mostSaved?.movie.title ?? "Local catalog", value: "\(mostSaved?.libraryAdds ?? 0)", systemImage: "bookmark.fill"),
            HFAnalyticsInsight(id: "highest-completion", title: "Highest Completion Rate", detail: highestCompletion?.movie.title ?? "Local catalog", value: "\(highestCompletion?.completionRate ?? 0)%", systemImage: "checkmark.seal.fill")
        ]
    }

    var revenueTitleRecords: [HFTitleRevenueRecord] {
        analyticsTitleRecords
            .map(revenueRecord)
            .sorted { lhs, rhs in
                revenueCents(from: lhs.estimatedRevenue) > revenueCents(from: rhs.estimatedRevenue)
            }
    }

    var revenueDashboardMetrics: [HFRevenueMetric] {
        let records = revenueTitleRecords
        let totalCents = records.reduce(0) { $0 + revenueCents(from: $1.estimatedRevenue) }
        let streamingCents = records.reduce(0) { $0 + revenueCents(from: $1.streamingRevenue) }
        let premiumCents = records.reduce(0) { $0 + revenueCents(from: $1.premiumRevenue) }
        let collectionCents = records.reduce(0) { $0 + revenueCents(from: $1.collectionRevenue) }
        let projectedCents = Int(Double(totalCents) * 1.18)

        return [
            HFRevenueMetric(id: "estimated", title: "Estimated Revenue", value: revenueCurrencyLabel(cents: totalCents), detail: "Local estimate from views, watch time, completion, and saves", systemImage: "chart.line.uptrend.xyaxis"),
            HFRevenueMetric(id: "streaming", title: "Streaming Revenue", value: revenueCurrencyLabel(cents: streamingCents), detail: "Catalog viewing estimate", systemImage: "play.tv.fill"),
            HFRevenueMetric(id: "premium", title: "Premium Revenue", value: revenueCurrencyLabel(cents: premiumCents), detail: "Premium intent preview from completion and favorites", systemImage: "sparkles.tv.fill"),
            HFRevenueMetric(id: "collection", title: "Collection Revenue", value: revenueCurrencyLabel(cents: collectionCents), detail: "Library adds and collection activity estimate", systemImage: "rectangle.stack.fill"),
            HFRevenueMetric(id: "projected", title: "Projected", value: revenueCurrencyLabel(cents: projectedCents), detail: "Forward-looking preview only", systemImage: "clock.badge.checkmark")
        ]
    }

    var creatorRevenueSummaries: [HFCreatorRevenueSummary] {
        creatorProfiles.map { profile in
            let titleIDs = Set(profile.filmography.map(\.id))
            let records = revenueTitleRecords.filter { titleIDs.contains($0.movie.id) }
            let totalCents = records.reduce(0) { $0 + revenueCents(from: $1.estimatedRevenue) }
            let projectedCents = Int(Double(totalCents) * 1.22)
            let lifetimeCents = Int(Double(totalCents) * 2.6)
            let topTitle = records.first?.movie.title ?? profile.featuredProject?.title ?? "Local slate"
            let growth = "+\(10 + analyticsSeed(profile.id + "revenue") % 32)%"

            return HFCreatorRevenueSummary(
                id: profile.id,
                creatorName: profile.creator.name,
                estimatedRevenue: revenueCurrencyLabel(cents: totalCents),
                projectedRevenue: revenueCurrencyLabel(cents: projectedCents),
                lifetimePreview: revenueCurrencyLabel(cents: lifetimeCents),
                topTitle: topTitle,
                titleCount: records.count,
                growthLabel: growth
            )
        }
        .sorted { revenueCents(from: $0.estimatedRevenue) > revenueCents(from: $1.estimatedRevenue) }
    }

    var revenueInsights: [HFRevenueInsight] {
        let records = revenueTitleRecords
        let highest = records.first
        let fastest = records.sorted { lhs, rhs in
            analyticsSeed(lhs.movie.id + "revenue-growth") > analyticsSeed(rhs.movie.id + "revenue-growth")
        }.first
        let bestCompletion = records.sorted { $0.completionRate > $1.completionRate }.first
        let strongestCollection = records.sorted { lhs, rhs in
            revenueCents(from: lhs.collectionRevenue) > revenueCents(from: rhs.collectionRevenue)
        }.first

        return [
            HFRevenueInsight(id: "highest-earning", title: "Highest Earning Title", detail: highest?.movie.title ?? "Local catalog", value: highest?.estimatedRevenue ?? "$0", systemImage: "crown.fill"),
            HFRevenueInsight(id: "fastest-growing", title: "Fastest Growing Title", detail: fastest?.movie.title ?? "Local catalog", value: fastest?.growthLabel ?? "+0%", systemImage: "chart.line.uptrend.xyaxis"),
            HFRevenueInsight(id: "best-completion", title: "Best Completion Rate", detail: bestCompletion?.movie.title ?? "Local catalog", value: "\(bestCompletion?.completionRate ?? 0)%", systemImage: "checkmark.seal.fill"),
            HFRevenueInsight(id: "collection-lift", title: "Collection Lift", detail: strongestCollection?.movie.title ?? "Local catalog", value: strongestCollection?.collectionRevenue ?? "$0", systemImage: "bookmark.fill")
        ]
    }

    var payoutPreviewRecords: [HFPayoutPreviewRecord] {
        let totalCents = revenueTitleRecords.reduce(0) { $0 + revenueCents(from: $1.estimatedRevenue) }
        let pendingCents = Int(Double(totalCents) * 0.28)
        let projectedCents = Int(Double(totalCents) * 1.18)
        let lifetimeCents = Int(Double(totalCents) * 2.85)

        return [
            HFPayoutPreviewRecord(id: "pending", title: "Pending Preview", value: revenueCurrencyLabel(cents: pendingCents), detail: "Local creator earnings preview awaiting review", state: "Preview", systemImage: "hourglass.circle.fill"),
            HFPayoutPreviewRecord(id: "projected", title: "Projected Preview", value: revenueCurrencyLabel(cents: projectedCents), detail: "Projected from current catalog and analytics signals", state: "Projected", systemImage: "chart.bar.xaxis"),
            HFPayoutPreviewRecord(id: "lifetime", title: "Lifetime Preview", value: revenueCurrencyLabel(cents: lifetimeCents), detail: "Long-range estimate for creator business planning", state: "Lifetime", systemImage: "infinity.circle.fill")
        ]
    }

    var productNotificationRecords: [HFProductNotificationRecord] {
        let published = creatorPublishedProjects.first ?? creatorPublishingContents.first!
        let queue = creatorPublishingQueueRecords.first
        let nextEpisode = nextEpisodeRecommendations.first
        let collaboration = creatorCollaborationActivity.first
        let analytics = analyticsInsights.first
        let revenue = revenueInsights.first

        return [
            HFProductNotificationRecord(
                id: "publishing-alert",
                title: "Publishing readiness updated",
                detail: "\(queue?.project.title ?? published.title) is \(queue?.stage ?? "ready for local review").",
                category: "Publishing",
                status: "Review",
                timeLabel: "Now",
                systemImage: "paperplane.circle.fill"
            ),
            HFProductNotificationRecord(
                id: "title-published",
                title: "Title available in discovery",
                detail: "\(published.title) is eligible for local discovery and creator profile placement.",
                category: "Discovery",
                status: "Local",
                timeLabel: "Today",
                systemImage: "sparkle.magnifyingglass"
            ),
            HFProductNotificationRecord(
                id: "series-updated",
                title: "Series structure updated",
                detail: "\(primarySeriesRecord.title) now has \(primarySeriesRecord.episodeCount) local episode records.",
                category: "Series",
                status: "Updated",
                timeLabel: "Today",
                systemImage: "play.square.stack.fill"
            ),
            HFProductNotificationRecord(
                id: "episode-available",
                title: "Next episode available",
                detail: nextEpisode?.detail ?? "Continue Watching can resolve the next local episode.",
                category: "Series",
                status: "Ready",
                timeLabel: "Today",
                systemImage: "forward.frame.fill"
            ),
            HFProductNotificationRecord(
                id: "library-milestone",
                title: "Library milestone",
                detail: "\(libraryContinueWatchingMovies.count) continue-watching paths and \(libraryUserCollections.count) user collections are active locally.",
                category: "Library",
                status: "Active",
                timeLabel: "Yesterday",
                systemImage: "bookmark.fill"
            ),
            HFProductNotificationRecord(
                id: "analytics-milestone",
                title: analytics?.title ?? "Analytics milestone",
                detail: analytics?.detail ?? "Local analytics are ready for creator review.",
                category: "Analytics",
                status: analytics?.value ?? "Ready",
                timeLabel: "Yesterday",
                systemImage: "chart.bar.xaxis"
            ),
            HFProductNotificationRecord(
                id: "revenue-milestone",
                title: revenue?.title ?? "Revenue milestone",
                detail: "\(revenue?.detail ?? "Local catalog") is driving \(revenue?.value ?? "$0") in estimated revenue.",
                category: "Revenue",
                status: "Estimate",
                timeLabel: "Yesterday",
                systemImage: "dollarsign.circle.fill"
            ),
            HFProductNotificationRecord(
                id: "collaboration-update",
                title: collaboration?.title ?? "Collaboration update",
                detail: collaboration?.detail ?? "Local team activity is ready for review.",
                category: "Collaboration",
                status: collaboration?.actorRole ?? "Team",
                timeLabel: collaboration?.timeLabel ?? "Yesterday",
                systemImage: "person.3.sequence.fill"
            )
        ]
    }

    var activityCenterRecords: [HFActivityCenterRecord] {
        [
            HFActivityCenterRecord(id: "publishing", title: "Publishing Activity", detail: "Queue, readiness, audit, and local discovery eligibility", value: "\(creatorPublishingQueueRecords.count)", status: "Review", systemImage: "paperplane.circle.fill"),
            HFActivityCenterRecord(id: "creator", title: "Creator Activity", detail: "Projects, collaboration notes, tasks, and creator profile updates", value: "\(creatorCollaborationActivity.count)", status: "Active", systemImage: "wand.and.stars"),
            HFActivityCenterRecord(id: "discovery", title: "Discovery Activity", detail: "Featured, trending, creator published, and collection signals", value: "\(discoveryCollections.count)", status: "Local", systemImage: "sparkle.magnifyingglass"),
            HFActivityCenterRecord(id: "series", title: "Series Activity", detail: "Series, episode management, and next episode readiness", value: "\(episodeRecords.count)", status: "Episodes", systemImage: "play.square.stack.fill"),
            HFActivityCenterRecord(id: "collaboration", title: "Collaboration Activity", detail: "Team roles, task board movement, notes, and timeline updates", value: "\(creatorCollaborationTasks.count)", status: "Tasks", systemImage: "person.3.fill"),
            HFActivityCenterRecord(id: "revenue", title: "Revenue Activity", detail: "Estimated title revenue, creator summaries, and payout previews", value: "\(revenueTitleRecords.count)", status: "Estimate", systemImage: "dollarsign.circle.fill")
        ]
    }

    var contentReviewRecords: [HFContentReviewRecord] {
        creatorPublishingContents.map { project in
            HFContentReviewRecord(
                id: "review-\(project.id)",
                title: project.title,
                creatorName: project.creator,
                status: project.releaseState.rawValue,
                detail: "\(project.genre) • \(project.runtime) • metadata \(project.metadataStatus.rawValue)",
                reviewState: contentReviewState(for: project),
                systemImage: project.releaseState == .published ? "checkmark.seal.fill" : "doc.text.magnifyingglass"
            )
        }
    }

    var creatorAdministrationRecords: [HFCreatorAdministrationRecord] {
        creatorProfiles.map { profile in
            let projects = creatorPublishingContents.filter { $0.creator == profile.creator.name }
            let publishedCount = projects.filter { $0.releaseState == .published }.count
            let readyCount = projects.filter(\.readyForReview).count
            return HFCreatorAdministrationRecord(
                id: profile.id,
                creatorName: profile.creator.name,
                creatorStatus: publishedCount > 0 ? "Active" : "Local",
                publishingStatus: "\(readyCount) ready",
                profileStatus: profile.bio.isEmpty ? "Needs Bio" : "Profile Ready",
                verificationPreview: publishedCount > 0 ? "Verified Preview" : "Review Preview",
                titleCount: projects.count
            )
        }
    }

    var platformHealthRecords: [HFPlatformHealthRecord] {
        [
            HFPlatformHealthRecord(id: "catalog", title: "Catalog Health", value: "\(cmsContentRecords.count)", detail: "Movies, series, episodes, trailers, collections, and creators indexed locally", status: "Ready", systemImage: "rectangle.stack.fill"),
            HFPlatformHealthRecord(id: "discovery", title: "Discovery Health", value: "\(discoveryCollections.count)", detail: "Featured, trending, creator published, and recommendation rails", status: "Local", systemImage: "sparkle.magnifyingglass"),
            HFPlatformHealthRecord(id: "series", title: "Series Health", value: "\(episodeRecords.count)", detail: "Episode records and next-episode recommendations available", status: "Ready", systemImage: "play.square.stack.fill"),
            HFPlatformHealthRecord(id: "analytics", title: "Analytics Health", value: "\(analyticsTitleRecords.count)", detail: "Title, discovery, creator, episode, and revenue analytics available", status: "Computed", systemImage: "chart.bar.xaxis"),
            HFPlatformHealthRecord(id: "revenue", title: "Revenue Health", value: "\(revenueTitleRecords.count)", detail: "Revenue estimates and payout previews derived locally", status: "Preview", systemImage: "dollarsign.circle.fill"),
            HFPlatformHealthRecord(id: "notifications", title: "Notifications Health", value: "\(productNotificationRecords.count)", detail: "Local notification and activity center records", status: "Local", systemImage: "bell.badge.fill")
        ]
    }

    var moderationQueueRecords: [HFModerationQueueRecord] {
        [
            HFModerationQueueRecord(id: "flagged-copy", title: creatorPrimaryReadinessProject.title, category: "Flagged Content", policyStatus: "Needs copy review", reviewState: "Pending Review", detail: "Synopsis and poster text are staged for local policy review.", systemImage: "flag.fill"),
            HFModerationQueueRecord(id: "review-ready", title: creatorReadyForReviewProjects.first?.title ?? featuredMovie.title, category: "Review Queue", policyStatus: "Ready for local review", reviewState: "Approved Preview", detail: "Metadata, poster, trailer, and artwork readiness can be checked locally.", systemImage: "checkmark.seal.fill"),
            HFModerationQueueRecord(id: "policy-boundary", title: "Policy Status", category: "Policy Status", policyStatus: "Local policy preview", reviewState: "Preview", detail: "No external moderation service or automated enforcement is active.", systemImage: "lock.shield.fill"),
            HFModerationQueueRecord(id: "content-audit", title: "Content Audit", category: "Content Audit", policyStatus: "\(creatorPublishingAuditRecords.count) audit rows", reviewState: "Audit Trail", detail: "Publishing, discovery, series, revenue, and notification records remain inspectable.", systemImage: "list.clipboard.fill")
        ]
    }

    var operationsDashboardRecords: [HFPlatformHealthRecord] {
        [
            HFPlatformHealthRecord(id: "publishing", title: "Publishing", value: "\(creatorPublishingQueueRecords.count)", detail: "Queue, readiness, review, and audit records", status: "Review", systemImage: "paperplane.circle.fill"),
            HFPlatformHealthRecord(id: "discovery", title: "Discovery", value: "\(discoveryCollections.count)", detail: "Collections and recommendation surfaces", status: "Local", systemImage: "sparkles"),
            HFPlatformHealthRecord(id: "library", title: "Library", value: "\(libraryUserCollections.count)", detail: "Continue Watching, My List, favorites, and collections", status: "Active", systemImage: "bookmark.fill"),
            HFPlatformHealthRecord(id: "series", title: "Series", value: "\(seriesRecords.count)", detail: "Series detail pages and episode paths", status: "Ready", systemImage: "play.square.stack.fill"),
            HFPlatformHealthRecord(id: "revenue", title: "Revenue", value: "\(revenueInsights.count)", detail: "Revenue insights and creator payout previews", status: "Estimate", systemImage: "dollarsign.circle.fill"),
            HFPlatformHealthRecord(id: "notifications", title: "Notifications", value: "\(productNotificationRecords.count)", detail: "Local notifications and activity records", status: "Local", systemImage: "bell.badge.fill")
        ]
    }

    var administrationAuditTrailRecords: [HFAuditTrailRecord] {
        [
            HFAuditTrailRecord(id: "audit-publishing", title: "Publishing event", detail: "\(creatorPublishingQueueRecords.first?.project.title ?? featuredMovie.title) entered local review.", category: "Publishing", timeLabel: "Now", result: "Logged", systemImage: "paperplane.circle.fill"),
            HFAuditTrailRecord(id: "audit-discovery", title: "Discovery event", detail: "\(creatorPublishedProjects.count) published titles are discovery eligible.", category: "Discovery", timeLabel: "Today", result: "Visible", systemImage: "sparkle.magnifyingglass"),
            HFAuditTrailRecord(id: "audit-series", title: "Series event", detail: "\(primarySeriesRecord.title) has \(primarySeriesRecord.episodeCount) local episode records.", category: "Series", timeLabel: "Today", result: "Indexed", systemImage: "play.square.stack.fill"),
            HFAuditTrailRecord(id: "audit-revenue", title: "Revenue event", detail: "\(revenueInsights.first?.title ?? "Revenue insight") is available for local review.", category: "Revenue", timeLabel: "Yesterday", result: "Preview", systemImage: "dollarsign.circle.fill"),
            HFAuditTrailRecord(id: "audit-admin", title: "Administration event", detail: "Content review, creator administration, moderation, operations, and health boards are local-only.", category: "Administration", timeLabel: "Yesterday", result: "Safe", systemImage: "shield.lefthalf.filled")
        ]
    }

    var marketplaceCatalogRecords: [HFMarketplaceCatalogRecord] {
        let projects = (creatorPublishedProjects + creatorScheduledProjects + creatorReviewProjects).prefix(6)
        return projects.map { project in
            let revenue = revenueTitleRecords.first { $0.id == project.id }
            return HFMarketplaceCatalogRecord(
                id: "market-\(project.id)",
                title: project.title,
                creatorName: project.creator,
                packageType: project.genre,
                readiness: project.readyForReview ? "Package Ready" : "Package Review",
                rightsSummary: marketplaceRightsSummary(for: project),
                revenuePreview: revenue?.estimatedRevenue ?? "Preview",
                distributionState: project.releaseState == .published ? "Marketplace Preview" : "\(project.releaseState.rawValue) Preview",
                systemImage: project.releaseState == .published ? "bag.fill" : "shippingbox.fill"
            )
        }
    }

    var distributionTargetRecords: [HFDistributionTargetRecord] {
        [
            HFDistributionTargetRecord(id: "highfive-home", title: "HighFive Home", purpose: "Featured local placement for approved marketplace packages.", readiness: "\(creatorPublishedProjects.count) visible", boundary: "Local catalog only", systemImage: "house.fill"),
            HFDistributionTargetRecord(id: "creator-profile", title: "Creator Profile", purpose: "Creator-owned title shelf and filmography placement.", readiness: "\(creatorProfiles.count) creators", boundary: "Profile preview", systemImage: "person.crop.rectangle.stack.fill"),
            HFDistributionTargetRecord(id: "premiere-rail", title: "Premiere Rail", purpose: "Premiere package planning for scheduled and review titles.", readiness: "\(creatorScheduledProjects.count + creatorReviewProjects.count) planned", boundary: "Planning only", systemImage: "sparkles.tv.fill"),
            HFDistributionTargetRecord(id: "collection-worlds", title: "Collection Worlds", purpose: "Genre and collection placement from CMS relationships.", readiness: "\(cmsCollections.count) collections", boundary: "Local relationships", systemImage: "rectangle.grid.2x2.fill"),
            HFDistributionTargetRecord(id: "series-shelf", title: "Series Shelf", purpose: "Series and episode package placement.", readiness: "\(seriesRecords.count) series", boundary: "Episode preview", systemImage: "play.square.stack.fill")
        ]
    }

    var rightsPackageRecords: [HFRightsPackageRecord] {
        marketplaceCatalogRecords.map { record in
            HFRightsPackageRecord(
                id: "rights-\(record.id)",
                title: record.title,
                creatorName: record.creatorName,
                rightsWindow: record.distributionState.contains("Published") || record.distributionState.contains("Marketplace") ? "Current Preview" : "Planned Preview",
                territoryPreview: record.packageType == "Western" ? "North America Preview" : "Global Planning Preview",
                clearanceState: record.rightsSummary,
                systemImage: "checkmark.shield.fill"
            )
        }
    }

    var releasePackageRecords: [HFReleasePackageRecord] {
        creatorPublishingQueueRecords.prefix(6).map { record in
            HFReleasePackageRecord(
                id: "release-\(record.project.id)",
                title: record.project.title,
                assets: "\(readinessStatus(for: record.project.posterStatus)) poster • \(readinessStatus(for: record.project.trailerStatus)) trailer",
                publishingState: record.project.releaseState.rawValue,
                marketplaceState: record.project.readyForReview ? "Ready for packaging" : "Packaging review",
                nextStep: record.nextStep,
                systemImage: "shippingbox.and.arrow.backward.fill"
            )
        }
    }

    var licensingPreviewRecords: [HFLicensingPreviewRecord] {
        revenueTitleRecords.prefix(5).map { record in
            HFLicensingPreviewRecord(
                id: "licensing-\(record.id)",
                title: record.movie.title,
                packageScope: record.movie.genres.prefix(2).joined(separator: " + "),
                estimatePreview: record.estimatedRevenue,
                rightsState: record.completionRate >= 70 ? "Strong package" : "Review package",
                planningNote: "\(record.views) local views • \(record.completionRate)% completion",
                systemImage: "doc.badge.gearshape.fill"
            )
        }
    }

    var distributionReadinessRecords: [HFDistributionReadinessRecord] {
        let readyPackages = releasePackageRecords.filter { $0.marketplaceState == "Ready for packaging" }.count
        return [
            HFDistributionReadinessRecord(id: "catalog", title: "Marketplace Catalog", value: "\(marketplaceCatalogRecords.count)", detail: "Creator packages visible for local marketplace planning.", status: "Preview", systemImage: "bag.fill"),
            HFDistributionReadinessRecord(id: "targets", title: "Distribution Targets", value: "\(distributionTargetRecords.count)", detail: "Home, creator profile, premiere, collection, and series targets.", status: "Planning", systemImage: "point.3.connected.trianglepath.dotted"),
            HFDistributionReadinessRecord(id: "rights", title: "Rights Packages", value: "\(rightsPackageRecords.count)", detail: "Rights windows, territory preview, and clearance state.", status: "Tracked", systemImage: "checkmark.shield.fill"),
            HFDistributionReadinessRecord(id: "release", title: "Release Packages", value: "\(readyPackages)", detail: "Packages ready for marketplace review.", status: "Ready", systemImage: "shippingbox.fill"),
            HFDistributionReadinessRecord(id: "licensing", title: "Licensing Preview", value: "\(licensingPreviewRecords.count)", detail: "Planning estimates from local revenue and completion signals.", status: "Estimate", systemImage: "doc.badge.gearshape.fill")
        ]
    }

    var rightsLedgerRecords: [HFRightsLedgerRecord] {
        rightsPackageRecords.map { record in
            HFRightsLedgerRecord(
                id: "ledger-\(record.id)",
                title: record.title,
                creatorName: record.creatorName,
                ledgerState: record.clearanceState,
                rightsWindow: record.rightsWindow,
                territory: record.territoryPreview,
                clearance: record.clearanceState.contains("Cleared") ? "Clearance tracked" : "Clearance review",
                systemImage: "books.vertical.fill"
            )
        }
    }

    var rightsWindowRecords: [HFRightsWindowRecord] {
        rightsPackageRecords.enumerated().map { index, record in
            HFRightsWindowRecord(
                id: "window-\(record.id)",
                title: record.title,
                window: index == 0 ? "Current Window" : "Planning Window",
                packageScope: record.territoryPreview,
                status: record.rightsWindow,
                detail: "\(record.creatorName) rights timing remains a local planning record.",
                systemImage: "calendar.badge.clock"
            )
        }
    }

    var territoryTrackingRecords: [HFTerritoryTrackingRecord] {
        [
            HFTerritoryTrackingRecord(id: "north-america", title: "North America", region: "US + Canada Preview", availabilityPreview: "\(rightsPackageRecords.filter { $0.territoryPreview.contains("North America") || $0.territoryPreview.contains("Global") }.count) packages", packageCount: rightsPackageRecords.count, status: "Tracked", systemImage: "map.fill"),
            HFTerritoryTrackingRecord(id: "global", title: "Global Planning", region: "Worldwide Preview", availabilityPreview: "\(rightsPackageRecords.filter { $0.territoryPreview.contains("Global") }.count) packages", packageCount: rightsPackageRecords.count, status: "Planning", systemImage: "globe.americas.fill"),
            HFTerritoryTrackingRecord(id: "festival", title: "Premiere Territory", region: "Premiere Preview", availabilityPreview: "\(creatorScheduledProjects.count + creatorReviewProjects.count) planned", packageCount: creatorScheduledProjects.count + creatorReviewProjects.count, status: "Preview", systemImage: "sparkles.tv.fill")
        ]
    }

    var clearanceTrackingRecords: [HFClearanceTrackingRecord] {
        [
            HFClearanceTrackingRecord(id: "metadata", title: "Metadata Clearance", area: "Title + Synopsis", state: "\(creatorPublishingReadinessItems.first { $0.id == "metadata" }?.status ?? "Preview")", detail: "Metadata readiness is reused for local rights review.", systemImage: "text.justify.left"),
            HFClearanceTrackingRecord(id: "poster", title: "Poster Clearance", area: "Artwork", state: "\(creatorPublishingReadinessItems.first { $0.id == "poster" }?.status ?? "Preview")", detail: "Poster status stays tied to publishing readiness.", systemImage: "photo.fill.on.rectangle.fill"),
            HFClearanceTrackingRecord(id: "trailer", title: "Trailer Clearance", area: "Preview Media", state: "\(creatorPublishingReadinessItems.first { $0.id == "trailer" }?.status ?? "Preview")", detail: "Trailer state is a local package signal only.", systemImage: "film.stack.fill"),
            HFClearanceTrackingRecord(id: "rights", title: "Rights Clearance", area: "Package Rights", state: "\(rightsLedgerRecords.count) tracked", detail: "Ledger rows track windows, territory, and clearance state.", systemImage: "checkmark.shield.fill")
        ]
    }

    var licensingPackageRecords: [HFLicensingPackageRecord] {
        licensingPreviewRecords.map { record in
            HFLicensingPackageRecord(
                id: "package-\(record.id)",
                title: record.title,
                scope: record.packageScope,
                estimatePreview: record.estimatePreview,
                readiness: record.rightsState,
                nextStep: record.rightsState.contains("Strong") ? "Prepare planning packet" : "Review rights packet",
                systemImage: "doc.richtext.fill"
            )
        }
    }

    var rightsReadinessRecords: [HFRightsReadinessRecord] {
        [
            HFRightsReadinessRecord(id: "ledger", title: "Rights Ledger", value: "\(rightsLedgerRecords.count)", detail: "Title, creator, window, territory, and clearance rows.", status: "Tracked", systemImage: "books.vertical.fill"),
            HFRightsReadinessRecord(id: "windows", title: "Rights Windows", value: "\(rightsWindowRecords.count)", detail: "Current and planned window records.", status: "Planning", systemImage: "calendar.badge.clock"),
            HFRightsReadinessRecord(id: "territories", title: "Territories", value: "\(territoryTrackingRecords.count)", detail: "Region availability preview and package counts.", status: "Preview", systemImage: "map.fill"),
            HFRightsReadinessRecord(id: "clearance", title: "Clearance", value: "\(clearanceTrackingRecords.count)", detail: "Metadata, poster, trailer, and package clearance signals.", status: "Review", systemImage: "checkmark.shield.fill"),
            HFRightsReadinessRecord(id: "licensing", title: "Licensing Packages", value: "\(licensingPackageRecords.count)", detail: "Scope, estimate, readiness, and next-step planning.", status: "Prepared", systemImage: "doc.richtext.fill")
        ]
    }

    var dealPreparationRecords: [HFDealPreparationRecord] {
        [
            HFDealPreparationRecord(id: "publishing", title: "Publishing Package", detail: "\(releasePackageRecords.count) release packages can inform rights preparation.", readiness: "Local", source: "Publishing", systemImage: "shippingbox.fill"),
            HFDealPreparationRecord(id: "revenue", title: "Revenue Context", detail: "\(licensingPackageRecords.count) licensing estimates are derived from local revenue signals.", readiness: "Estimate", source: "Revenue", systemImage: "dollarsign.circle.fill"),
            HFDealPreparationRecord(id: "marketplace", title: "Marketplace Context", detail: "\(marketplaceCatalogRecords.count) catalog packages are visible for preparation.", readiness: "Preview", source: "Marketplace", systemImage: "bag.fill"),
            HFDealPreparationRecord(id: "distribution", title: "Distribution Context", detail: "\(distributionTargetRecords.count) target surfaces define planning context.", readiness: "Planning", source: "Distribution", systemImage: "point.3.connected.trianglepath.dotted")
        ]
    }

    var serviceRegistryRecords: [HFServiceRegistryRecord] {
        [
            HFServiceRegistryRecord(id: "catalog", title: "Catalog Service", productArea: "CMS", readiness: "\(cmsContentRecords.count) records", dependency: "Content models", boundary: "No remote connector", systemImage: "rectangle.stack.fill"),
            HFServiceRegistryRecord(id: "discovery", title: "Discovery Service", productArea: "Discovery", readiness: "\(discoveryCollections.count) rails", dependency: "Published catalog", boundary: "Local ranking only", systemImage: "sparkle.magnifyingglass"),
            HFServiceRegistryRecord(id: "creator", title: "Creator Service", productArea: "Creator", readiness: "\(creatorProfiles.count) profiles", dependency: "Creator profiles", boundary: "No account service", systemImage: "person.crop.rectangle.stack.fill"),
            HFServiceRegistryRecord(id: "commerce", title: "Commerce Service", productArea: "Revenue", readiness: "\(revenueTitleRecords.count) estimates", dependency: "Revenue preview", boundary: "Planning only", systemImage: "dollarsign.circle.fill"),
            HFServiceRegistryRecord(id: "rights", title: "Rights Service", productArea: "Rights", readiness: "\(rightsLedgerRecords.count) ledger rows", dependency: "Marketplace packages", boundary: "Planning only", systemImage: "checkmark.shield.fill"),
            HFServiceRegistryRecord(id: "notifications", title: "Activity Service", productArea: "Activity", readiness: "\(productNotificationRecords.count) events", dependency: "Local activity center", boundary: "No push channel", systemImage: "bell.badge.fill")
        ]
    }

    var dataSourceRegistryRecords: [HFDataSourceRegistryRecord] {
        [
            HFDataSourceRegistryRecord(id: "catalog", title: "Catalog Data Source", sourceType: "Local catalog", owner: "CMS", state: "\(cmsContentRecords.count) records", detail: "Movies, series, episodes, trailers, collections, and creators.", systemImage: "externaldrive.fill"),
            HFDataSourceRegistryRecord(id: "publishing", title: "Publishing Data Source", sourceType: "Local creator projects", owner: "Creator Studio", state: "\(creatorPublishingContents.count) projects", detail: "Draft, review, scheduled, published, and archived states.", systemImage: "square.stack.3d.up.fill"),
            HFDataSourceRegistryRecord(id: "analytics", title: "Analytics Data Source", sourceType: "Computed local metrics", owner: "Analytics", state: "\(analyticsTitleRecords.count) titles", detail: "Views, completion, discovery, creator, and revenue signals.", systemImage: "chart.bar.xaxis"),
            HFDataSourceRegistryRecord(id: "library", title: "Library Data Source", sourceType: "Local viewer activity", owner: "Library", state: "\(libraryViewingHistory.count) history rows", detail: "Continue watching, favorites, watch later, history, and collections.", systemImage: "bookmark.fill"),
            HFDataSourceRegistryRecord(id: "rights", title: "Rights Data Source", sourceType: "Local rights planning", owner: "Rights", state: "\(rightsLedgerRecords.count) ledger rows", detail: "Windows, territories, clearance, licensing, and preparation.", systemImage: "books.vertical.fill")
        ]
    }

    var syncReadinessRecords: [HFSyncReadinessRecord] {
        [
            HFSyncReadinessRecord(id: "catalog", title: "Catalog Sync Readiness", localCount: "\(cmsContentRecords.count)", readiness: "Schema ready", detail: "Content objects have local IDs, types, metadata, relationships, and status.", systemImage: "arrow.triangle.2.circlepath"),
            HFSyncReadinessRecord(id: "publishing", title: "Publishing Sync Readiness", localCount: "\(creatorPublishingContents.count)", readiness: "Lifecycle ready", detail: "Publishing state can be mapped later without changing the local workflow.", systemImage: "paperplane.circle.fill"),
            HFSyncReadinessRecord(id: "library", title: "Library Sync Readiness", localCount: "\(libraryViewingHistory.count)", readiness: "User-state ready", detail: "Viewer state remains local until a future account boundary exists.", systemImage: "person.crop.circle.badge.clock"),
            HFSyncReadinessRecord(id: "analytics", title: "Analytics Sync Readiness", localCount: "\(analyticsTitleRecords.count)", readiness: "Computed ready", detail: "Metrics can be exported later from local computed records.", systemImage: "chart.xyaxis.line"),
            HFSyncReadinessRecord(id: "rights", title: "Rights Sync Readiness", localCount: "\(rightsLedgerRecords.count)", readiness: "Planning ready", detail: "Rights rows have package, window, territory, and clearance fields.", systemImage: "checkmark.shield.fill")
        ]
    }

    var apiReadinessRecords: [HFAPIReadinessRecord] {
        [
            HFAPIReadinessRecord(id: "catalog", title: "Catalog API Readiness", shapeState: "Shape drafted", requestShape: "Content query", responseShape: "Movie, series, episode, collection", boundary: "No request sent", systemImage: "curlybraces.square.fill"),
            HFAPIReadinessRecord(id: "publishing", title: "Publishing API Readiness", shapeState: "Lifecycle mapped", requestShape: "Project package", responseShape: "Review state", boundary: "No publish action", systemImage: "doc.badge.gearshape.fill"),
            HFAPIReadinessRecord(id: "library", title: "Library API Readiness", shapeState: "State mapped", requestShape: "Viewer state", responseShape: "Saved and progress state", boundary: "No account sync", systemImage: "bookmark.square.fill"),
            HFAPIReadinessRecord(id: "analytics", title: "Analytics API Readiness", shapeState: "Metric groups mapped", requestShape: "Title activity", responseShape: "Views, completion, watch time", boundary: "No telemetry upload", systemImage: "chart.bar.doc.horizontal.fill"),
            HFAPIReadinessRecord(id: "rights", title: "Rights API Readiness", shapeState: "Package mapped", requestShape: "Rights ledger package", responseShape: "Readiness state", boundary: "No external exchange", systemImage: "checkmark.shield.fill")
        ]
    }

    var environmentProfileRecords: [HFEnvironmentProfileRecord] {
        [
            HFEnvironmentProfileRecord(id: "local", title: "Local Product Profile", profile: "Current", services: "\(serviceRegistryRecords.count) planned services", dataPolicy: "Local mock and computed state", status: "Active", systemImage: "iphone.gen3"),
            HFEnvironmentProfileRecord(id: "staging", title: "Staging Profile", profile: "Future", services: "Readiness only", dataPolicy: "Requires explicit runtime configuration later", status: "Not connected", systemImage: "testtube.2"),
            HFEnvironmentProfileRecord(id: "production", title: "Production Profile", profile: "Future", services: "Infrastructure later", dataPolicy: "Requires account, security, monitoring, and governance later", status: "Not connected", systemImage: "building.2.fill")
        ]
    }

    var integrationAuditRecords: [HFIntegrationAuditRecord] {
        [
            HFIntegrationAuditRecord(id: "no-network", title: "No network connector", detail: "P15 records service readiness without adding transport behavior.", result: "Safe", category: "Boundary", systemImage: "network.slash"),
            HFIntegrationAuditRecord(id: "no-secrets", title: "No secrets", detail: "No secrets, keys, or account identifiers are added.", result: "Clean", category: "Security", systemImage: "lock.shield.fill"),
            HFIntegrationAuditRecord(id: "no-money", title: "No money movement", detail: "Revenue, marketplace, rights, and licensing remain estimates and planning records.", result: "Preview", category: "Commerce", systemImage: "dollarsign.circle.fill"),
            HFIntegrationAuditRecord(id: "no-sync", title: "No sync job", detail: "Sync readiness is documented without background jobs or remote mutation.", result: "Local", category: "Sync", systemImage: "arrow.triangle.2.circlepath"),
            HFIntegrationAuditRecord(id: "local-first", title: "Local-first bridge", detail: "The product is prepared for future infrastructure while preserving current local flows.", result: "Ready", category: "Architecture", systemImage: "point.3.connected.trianglepath.dotted")
        ]
    }

    var productionConnectionRecords: [HFProductionConnectionRecord] {
        [
            HFProductionConnectionRecord(id: "catalog", title: "Catalog Connection", domain: "CMS", readiness: "\(cmsContentRecords.count) local records", handoff: "Catalog shape", boundary: "Planning only", systemImage: "rectangle.stack.fill"),
            HFProductionConnectionRecord(id: "publishing", title: "Publishing Connection", domain: "Creator", readiness: "\(creatorPublishingContents.count) project records", handoff: "Lifecycle state", boundary: "No publish action", systemImage: "paperplane.circle.fill"),
            HFProductionConnectionRecord(id: "library", title: "Library Connection", domain: "Viewer", readiness: "\(libraryViewingHistory.count) activity rows", handoff: "Viewer state", boundary: "Local state only", systemImage: "bookmark.square.fill"),
            HFProductionConnectionRecord(id: "analytics", title: "Analytics Connection", domain: "Insights", readiness: "\(analyticsTitleRecords.count) title signals", handoff: "Metric groups", boundary: "No telemetry move", systemImage: "chart.xyaxis.line"),
            HFProductionConnectionRecord(id: "rights", title: "Rights Connection", domain: "Licensing", readiness: "\(rightsLedgerRecords.count) ledger rows", handoff: "Rights package", boundary: "Planning only", systemImage: "checkmark.shield.fill")
        ]
    }

    var productionFeatureFlagRecords: [HFProductionFeatureFlagRecord] {
        [
            HFProductionFeatureFlagRecord(id: "creator-publishing", title: "Creator Publishing", scope: "Creator Studio", defaultState: "Local on", rolloutNote: "Gate future live handoff", boundary: "No external action", systemImage: "square.stack.3d.up.fill"),
            HFProductionFeatureFlagRecord(id: "discovery-ranking", title: "Discovery Ranking", scope: "Search", defaultState: "Local on", rolloutNote: "Compare local and future ranking modes", boundary: "Local ranking only", systemImage: "sparkle.magnifyingglass"),
            HFProductionFeatureFlagRecord(id: "library-state", title: "Library State", scope: "Library", defaultState: "Local on", rolloutNote: "Protect viewer history migration", boundary: "No user sync", systemImage: "bookmark.fill"),
            HFProductionFeatureFlagRecord(id: "rights-planning", title: "Rights Planning", scope: "Marketplace", defaultState: "Preview on", rolloutNote: "Keep licensing preparation separate", boundary: "No deal action", systemImage: "doc.richtext.fill"),
            HFProductionFeatureFlagRecord(id: "activity-center", title: "Activity Center", scope: "Notifications", defaultState: "Local on", rolloutNote: "Keep local alerts separate from future delivery", boundary: "Local alerts only", systemImage: "bell.badge.fill")
        ]
    }

    var productionServiceMappingRecords: [HFProductionServiceMappingRecord] {
        [
            HFProductionServiceMappingRecord(id: "catalog", title: "Catalog Mapping", localSystem: "CMS records", futureSystem: "Catalog runtime", mappingState: "Fields mapped", dependency: "Content IDs", systemImage: "arrow.left.arrow.right.square.fill"),
            HFProductionServiceMappingRecord(id: "creator", title: "Creator Mapping", localSystem: "Profiles + projects", futureSystem: "Creator runtime", mappingState: "Owner fields mapped", dependency: "Creator IDs", systemImage: "person.crop.rectangle.stack.fill"),
            HFProductionServiceMappingRecord(id: "library", title: "Library Mapping", localSystem: "Viewing history", futureSystem: "Viewer runtime", mappingState: "State groups mapped", dependency: "Viewer boundary", systemImage: "rectangle.stack.person.crop.fill"),
            HFProductionServiceMappingRecord(id: "analytics", title: "Analytics Mapping", localSystem: "Computed metrics", futureSystem: "Insights runtime", mappingState: "Metric names mapped", dependency: "Event taxonomy", systemImage: "chart.bar.doc.horizontal.fill"),
            HFProductionServiceMappingRecord(id: "marketplace", title: "Marketplace Mapping", localSystem: "Distribution planning", futureSystem: "Package runtime", mappingState: "Package fields mapped", dependency: "Rights readiness", systemImage: "bag.fill")
        ]
    }

    var productionEnvironmentSwitchRecords: [HFProductionEnvironmentSwitchRecord] {
        [
            HFProductionEnvironmentSwitchRecord(id: "local", title: "Local Profile", mode: "Current", availability: "Available", guardrail: "Default path", notes: "Uses local mock and computed records.", systemImage: "iphone.gen3"),
            HFProductionEnvironmentSwitchRecord(id: "preview", title: "Preview Profile", mode: "Future", availability: "Locked", guardrail: "Requires explicit enablement later", notes: "Reserved for internal review flows.", systemImage: "eye.fill"),
            HFProductionEnvironmentSwitchRecord(id: "staging", title: "Staging Profile", mode: "Future", availability: "Locked", guardrail: "Requires runtime setup later", notes: "Reserved for validation after services exist.", systemImage: "testtube.2"),
            HFProductionEnvironmentSwitchRecord(id: "production", title: "Production Profile", mode: "Future", availability: "Locked", guardrail: "Requires governance later", notes: "Reserved for real release operations.", systemImage: "building.2.fill")
        ]
    }

    var productionReadinessReportRecords: [HFProductionReadinessReportRecord] {
        [
            HFProductionReadinessReportRecord(id: "catalog", title: "Catalog Readiness", score: "\(cmsContentRecords.count)", state: "Mapped", summary: "Content types, relationships, and status fields are ready for handoff planning.", nextStep: "Validate identifiers", systemImage: "rectangle.stack.fill"),
            HFProductionReadinessReportRecord(id: "creator", title: "Creator Readiness", score: "\(creatorProfiles.count)", state: "Mapped", summary: "Profiles, publishing projects, collaboration, and revenue previews share creator context.", nextStep: "Confirm ownership model", systemImage: "person.crop.circle.fill"),
            HFProductionReadinessReportRecord(id: "viewer", title: "Viewer Readiness", score: "\(libraryViewingHistory.count)", state: "Mapped", summary: "Library, history, favorites, collections, and activity are grouped for future migration.", nextStep: "Confirm viewer boundary", systemImage: "person.2.fill"),
            HFProductionReadinessReportRecord(id: "business", title: "Business Readiness", score: "\(rightsReadinessRecords.count)", state: "Planning", summary: "Marketplace, rights, licensing, and revenue records remain planning surfaces.", nextStep: "Confirm governance", systemImage: "checkmark.shield.fill")
        ]
    }

    var productionDependencyGraphRecords: [HFProductionDependencyGraphRecord] {
        [
            HFProductionDependencyGraphRecord(id: "publishing-discovery", title: "Publishing -> Discovery", upstream: "Published content", downstream: "Discovery rails", readiness: "Linked", blocker: "None for local mode", systemImage: "point.3.connected.trianglepath.dotted"),
            HFProductionDependencyGraphRecord(id: "cms-library", title: "CMS -> Library", upstream: "Content IDs", downstream: "Viewer shelves", readiness: "Linked", blocker: "Viewer boundary later", systemImage: "rectangle.stack.person.crop.fill"),
            HFProductionDependencyGraphRecord(id: "series-analytics", title: "Series -> Analytics", upstream: "Episode records", downstream: "Episode metrics", readiness: "Linked", blocker: "Event taxonomy later", systemImage: "chart.bar.xaxis"),
            HFProductionDependencyGraphRecord(id: "marketplace-rights", title: "Marketplace -> Rights", upstream: "Release packages", downstream: "Rights ledger", readiness: "Linked", blocker: "Clearance review later", systemImage: "checkmark.shield.fill"),
            HFProductionDependencyGraphRecord(id: "revenue-licensing", title: "Revenue -> Licensing", upstream: "Revenue estimates", downstream: "Licensing preview", readiness: "Linked", blocker: "Business policy later", systemImage: "dollarsign.circle.fill")
        ]
    }

    private func contentReviewState(for project: HFCreatorPublishingContent) -> String {
        switch project.releaseState {
        case .published:
            return "Approved"
        case .review:
            return project.readyForReview ? "Pending Review" : "Needs Revision"
        case .scheduled:
            return "Approved Preview"
        case .archived:
            return "Archived"
        case .draft:
            return project.readyForReview ? "Pending Review" : "Needs Revision"
        }
    }

    private func marketplaceRightsSummary(for project: HFCreatorPublishingContent) -> String {
        if project.releaseState == .archived {
            return "Archived rights"
        }
        if project.readyForReview && project.discoveryEligible {
            return "Cleared Preview"
        }
        if project.readyForReview {
            return "Rights Review"
        }
        return "Needs Package"
    }

    private func analyticsRecord(for movie: Movie) -> HFTitleAnalyticsRecord {
        let seed = analyticsSeed(movie.id)
        let isCreatorPublished = creatorPublishedMovies.contains { $0.id == movie.id }
        let localProgress = movie.progress ?? (movie.isComingSoon ? 0 : Double(42 + seed % 45) / 100.0)
        let completion = movie.isComingSoon ? 0 : min(98, max(12, Int(localProgress * 100)))
        let runtimeMinutes = analyticsRuntimeMinutes(for: movie)
        let averageMinutes = movie.isComingSoon ? 0 : max(4, Int(Double(runtimeMinutes) * Double(completion) / 100.0))
        let recentSearchBoost = recentSearches.contains { query in
            movie.title.localizedCaseInsensitiveContains(query) || query.localizedCaseInsensitiveContains(movie.title)
        } ? 30 : 0
        let viewBase = 42 + seed % 520
        let viewBoost = (isSaved(movie) ? 54 : 0) + (isDownloaded(movie) ? 22 : 0) + (isCreatorPublished ? 86 : 0) + recentSearchBoost
        let libraryAdds = isSaved(movie) ? 18 + seed % 46 : seed % 12
        let favorites = libraryFavoriteMovies.contains { $0.id == movie.id } ? 10 + seed % 26 : seed % 6

        return HFTitleAnalyticsRecord(
            id: movie.id,
            movie: movie,
            totalViews: viewBase + viewBoost,
            averageWatchTime: "\(averageMinutes)m",
            completionRate: completion,
            libraryAdds: libraryAdds,
            favorites: favorites,
            sharesPlaceholder: seed % 18
        )
    }

    private func revenueRecord(for record: HFTitleAnalyticsRecord) -> HFTitleRevenueRecord {
        let seed = analyticsSeed(record.id + "revenue")
        let watchMinutes = analyticsMinutes(from: record.averageWatchTime)
        let streamingCents = record.totalViews * (6 + seed % 5)
        let premiumCents = max(0, record.completionRate - 35) * max(1, record.favorites) * 7
        let collectionCents = record.libraryAdds * (18 + seed % 14)
        let totalCents = streamingCents + premiumCents + collectionCents
        let perViewCents = record.totalViews == 0 ? 0 : max(1, totalCents / record.totalViews)
        let growth = "+\(8 + seed % 36)%"

        return HFTitleRevenueRecord(
            id: record.id,
            movie: record.movie,
            estimatedRevenue: revenueCurrencyLabel(cents: totalCents),
            streamingRevenue: revenueCurrencyLabel(cents: streamingCents),
            premiumRevenue: revenueCurrencyLabel(cents: premiumCents),
            collectionRevenue: revenueCurrencyLabel(cents: collectionCents),
            revenuePerView: revenueCurrencyLabel(cents: perViewCents),
            views: record.totalViews,
            watchTime: "\(max(1, watchMinutes * max(1, record.totalViews / 24) / 60))h",
            completionRate: record.completionRate,
            growthLabel: growth
        )
    }

    private func analyticsRuntimeMinutes(for movie: Movie) -> Int {
        let number = movie.duration.split(separator: " ").compactMap { Int($0) }.first
        return max(12, number ?? (movie.duration.localizedCaseInsensitiveContains("episode") ? 44 : 96))
    }

    private func analyticsMinutes(from label: String) -> Int {
        Int(label.filter(\.isNumber)) ?? 0
    }

    private func analyticsSeed(_ key: String) -> Int {
        key.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    }

    private func revenueCurrencyLabel(cents: Int) -> String {
        let dollars = max(0, cents) / 100
        let centsRemainder = max(0, cents) % 100
        return "$\(dollars).\(String(format: "%02d", centsRemainder))"
    }

    private func revenueCents(from label: String) -> Int {
        let digits = label.filter(\.isNumber)
        return Int(digits) ?? 0
    }

    // hf.services.libraryState
    func movie(id: String) -> Movie? {
        queryTitle(id: id)
    }

    func movie(for id: String) -> Movie? {
        movie(id: id)
    }

    func relatedMovies(for movie: Movie) -> [Movie] {
        queryRelatedContent(for: movie, limit: 8)
    }

    func creatorProfile(for creator: Creator) -> HFCreatorProfile {
        let publishingRecords = creatorPublishingContents.filter { $0.creator == creator.name }
        let published = publishingRecords.filter { $0.releaseState == .published }.map(\.movie)
        let scheduled = publishingRecords.filter { $0.releaseState == .scheduled }.map(\.movie)
        let archived = publishingRecords.filter { $0.releaseState == .archived }.map(\.movie)
        let catalogTitles = contentQueryEngine.titlesByCreator(creator)
        let filmography = uniqueMovies(catalogTitles + published + scheduled + archived)
        let featured = creator.featuredMovieIDs.compactMap(movie(id:)).first ?? filmography.first
        let latest = published.first ?? filmography.first
        return HFCreatorProfile(
            creator: creator,
            bio: creatorBio(for: creator),
            bannerTitle: "\(creator.name) Spotlight",
            avatarSymbol: creatorAvatarSymbol(for: creator),
            filmography: filmography,
            publishedTitles: uniqueMovies(published + catalogTitles.filter { !$0.isComingSoon }),
            scheduledTitles: uniqueMovies(scheduled + catalogTitles.filter(\.isComingSoon)),
            archivedTitles: archived,
            collections: creatorCollections(for: creator, filmography: filmography, records: publishingRecords),
            featuredProject: featured,
            latestRelease: latest
        )
    }

    func searchCreatorProfiles(query: String) -> [HFCreatorProfile] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            return Array(creatorProfiles.prefix(6))
        }
        let matchingCreatorIDs = Set(queryCreators(search: term).map(\.id))
        return creatorProfiles
            .map { profile in (profile, creatorSearchScore(for: profile, term: term)) }
            .filter { $0.1 > 0 || matchingCreatorIDs.contains($0.0.creator.id) }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.creator.name < rhs.0.creator.name
                }
                return lhs.1 > rhs.1
            }
            .map(\.0)
    }

    var discoveryCollections: [Category] {
        compactCategories([
            Category(id: "featured", title: "Featured", subtitle: "High-signal local picks for the first watch decision", movies: [featuredMovie]),
            Category(id: "trending", title: "Trending", subtitle: "Local momentum from the HighFive catalog", movies: moviesByIDs(["friendly", "paranormall-s1", "black-turnip", "big-loss", "artist-development", "bleu-velvet"])),
            Category(id: "new-releases", title: "New Releases", subtitle: "Fresh and recently staged local catalog titles", movies: queryRecentlyPublished(limit: 10)),
            Category(id: "highfive-originals", title: "HighFive Originals", subtitle: "Original films, series, creator cuts, and local premieres", movies: originalsCatalog.filter { !$0.isComingSoon }),
            seriesDiscoveryCategory,
            Category(id: "creator-published", title: "Creator Published", subtitle: "Titles promoted from the Creator Publishing Pipeline", movies: queryCreatorPublishedTitles()),
            Category(id: "award-winners", title: "Award Winners", subtitle: "Prestige-style local programming for editorial rails", movies: moviesByIDs(["friendly", "artist-development", "behind-vision", "black-turnip", "sunshine"])),
            Category(id: "premieres", title: "Premieres", subtitle: "Premiere-ready and coming-soon worlds", movies: queryTitles(genre: "Premiere") + queryCatalog().filter(\.isComingSoon))
        ])
    }

    func recommendationCollections(anchor movie: Movie? = nil) -> [Category] {
        let selected = movie ?? continueWatchingMovie
        return compactCategories([
            Category(id: "because-you-watched", title: "Because You Watched \(selected.title)", subtitle: "Genre, tone, and creator-adjacent local picks", movies: queryLibraryRecommendations(anchor: selected, limit: 10)),
            Category(id: "similar-titles", title: "Similar Titles", subtitle: selected.genres.prefix(2).joined(separator: " + "), movies: queryRelatedContent(for: selected, limit: 10)),
            Category(id: "same-creator", title: "From \(selected.creatorName)", subtitle: "More local titles from the same creator", movies: fromSameCreator(as: selected)),
            Category(id: "continue-watching", title: "Continue Watching", subtitle: "Resume local progress", movies: libraryRepository.fetchContinueWatching())
        ])
    }

    var collectionSystem: [Category] {
        compactCategories([
            collectionCategory(id: "horror", title: "Horror", genre: "Horror"),
            collectionCategory(id: "documentary", title: "Documentary", genre: "Documentary"),
            collectionCategory(id: "western", title: "Western", genre: "Western"),
            collectionCategory(id: "crime", title: "Crime", genre: "Crime"),
            collectionCategory(id: "drama", title: "Drama", genre: "Drama"),
            Category(id: "premiere-collection", title: "Premieres", subtitle: "Scheduled and coming-soon local titles", movies: queryCatalog().filter { movie in
                movie.isComingSoon || searchableTags(for: movie).contains { $0.localizedCaseInsensitiveContains("Premiere") }
            }),
            Category(id: "creator-collections", title: "Creator Collections", subtitle: "Creator-led discovery paths", movies: creatorCollectionMovies)
        ])
    }

    func searchMovies(query: String, filter: String) -> [Movie] {
        queryTitles(search: query, filter: filter)
    }

    func catalogRails(filter: String = "All") -> [Category] {
        let rails = discoveryCollections + recommendationCollections() + collectionSystem

        switch filter {
        case "Originals":
            return rails.filter { $0.id == "highfive-originals" }
        case "Creator Published":
            return rails.filter { $0.id == "creator-published" }
        case "Premieres":
            return rails.filter { $0.id == "premieres" || $0.id == "premiere-collection" }
        case "Award Winners":
            return rails.filter { $0.id == "award-winners" }
        case "Drama", "Thriller", "Mystery", "Documentary", "Horror", "Western", "Crime":
            return [collectionCategory(id: filter.lowercased(), title: "\(filter) Picks", genre: filter)]
        case "Coming Soon":
            return [Category(id: "coming-soon", title: "Coming Soon", subtitle: "Scripted originals in development", movies: queryCatalog().filter { $0.isComingSoon })]
        default:
            return rails
        }
    }

    private var creatorCollectionMovies: [Movie] {
        var seen = Set<String>()
        let creatorLed = allCatalogMovies.filter { movie in
            movie.isOriginal || !fromSameCreator(as: movie).isEmpty || !searchableTags(for: movie).isEmpty
        }
        return creatorLed.filter { seen.insert($0.id).inserted }
    }

    private var cmsEpisodeRecords: [HFCMSContentRecord] {
        episodeRecords.map { episode in
            let series = seriesRecords.first { $0.id == episode.seriesID } ?? primarySeriesRecord
            return HFCMSContentRecord(
                id: "cms-episode-\(episode.id)",
                title: episode.title,
                type: .episode,
                description: episode.synopsis,
                creatorName: series.creatorName,
                genre: series.genre,
                tags: ["Episode", "Series", "Season \(episode.seasonNumber)", "Episode \(episode.episodeNumber)"],
                runtime: episode.runtime,
                rating: series.heroMovie.rating,
                artworkStatus: episode.artworkStatus,
                trailerStatus: .placeholder,
                releaseState: episode.releaseState,
                collectionIDs: cmsCollectionIDs(for: series.heroMovie),
                seriesID: episode.seriesID,
                relatedTitleIDs: relatedMovies(for: series.heroMovie).map(\.id)
            )
        }
    }

    private func cmsRecord(for movie: Movie) -> HFCMSContentRecord {
        let project = creatorPublishingContents.first { $0.id == movie.id }
        return HFCMSContentRecord(
            id: "cms-title-\(movie.id)",
            title: movie.title,
            type: movie.duration.localizedCaseInsensitiveContains("episode") || movie.genres.contains("Series") ? .series : .movie,
            description: movie.synopsis,
            creatorName: movie.creatorName,
            genre: movie.genres.first ?? "Cinema",
            tags: searchableTags(for: movie) + movie.genres,
            runtime: movie.duration,
            rating: movie.rating,
            artworkStatus: project?.artworkStatus ?? (movie.posterAssetName == nil ? .placeholder : .ready),
            trailerStatus: project?.trailerStatus ?? (movie.isComingSoon ? .placeholder : .ready),
            releaseState: project?.releaseState ?? (movie.isComingSoon ? .scheduled : .published),
            collectionIDs: cmsCollectionIDs(for: movie),
            seriesID: movie.duration.localizedCaseInsensitiveContains("episode") || movie.genres.contains("Series") ? movie.id : nil,
            relatedTitleIDs: relatedMovies(for: movie).map(\.id)
        )
    }

    private func cmsCollectionIDs(for movie: Movie) -> [String] {
        (discoveryCollections + collectionSystem)
            .filter { category in category.movies.contains { $0.id == movie.id } }
            .map(\.id)
    }

    private func uniqueMovies(_ movies: [Movie]) -> [Movie] {
        var seen = Set<String>()
        return movies.filter { seen.insert($0.id).inserted }
    }

    private func creatorBio(for creator: Creator) -> String {
        switch creator.name {
        case "HigherKey Inc.":
            return "A HighFive studio identity for crime, drama, music, and creator-led releases built around strong local catalog momentum."
        case "HighFive Cinema":
            return "The flagship originals label behind paranormal worlds, creator cuts, and premium streaming stories inside the HighFive catalog."
        case "In The Light Productions":
            return "A production partner focused on mystery, thriller, and premiere-ready stories with a cinematic independent voice."
        default:
            return "A HighFive creator profile generated from local publishing and catalog records."
        }
    }

    private func creatorAvatarSymbol(for creator: Creator) -> String {
        switch creator.role {
        case "Studio": return "building.columns.fill"
        case "Originals": return "sparkles.tv.fill"
        case "Production Partner": return "camera.aperture"
        default: return "person.crop.rectangle.stack.fill"
        }
    }

    private func creatorCollections(for creator: Creator, filmography: [Movie], records: [HFCreatorPublishingContent]) -> [Category] {
        let commentary = filmography.filter { movie in
            movie.title.localizedCaseInsensitiveContains("Commentary")
                || searchableTags(for: movie).contains { $0.localizedCaseInsensitiveContains("Commentary") }
        }
        return compactCategories([
            Category(id: "\(creator.id)-documentaries", title: "Documentaries", subtitle: "Documentary work from \(creator.name)", movies: filmography.filter { $0.genres.contains("Documentary") }),
            Category(id: "\(creator.id)-crime", title: "Crime Stories", subtitle: "Crime and thriller titles from the creator catalog", movies: filmography.filter { movie in
                movie.genres.contains("Crime") || movie.genres.contains("Thriller")
            }),
            Category(id: "\(creator.id)-commentary", title: "Creator Commentary", subtitle: "Commentary and creator-led releases", movies: commentary),
            Category(id: "\(creator.id)-premieres", title: "Premieres", subtitle: "Scheduled and premiere-ready projects", movies: filmography.filter { movie in
                movie.isComingSoon
                    || movie.genres.contains("Premiere")
                    || records.contains { $0.id == movie.id && $0.releaseState == .scheduled }
            })
        ])
    }

    private func creatorSearchScore(for profile: HFCreatorProfile, term: String) -> Int {
        let fields: [(String, Int)] = [
            (profile.creator.name, 140),
            (profile.creator.role, 70),
            (profile.bio, 48),
            (profile.filmography.map(\.title).joined(separator: " "), 92),
            (profile.filmography.flatMap(\.genres).joined(separator: " "), 58),
            (profile.collections.map(\.title).joined(separator: " "), 52)
        ]
        return fields.reduce(0) { partial, field in
            if field.0.localizedCaseInsensitiveCompare(term) == .orderedSame {
                return partial + field.1 + 35
            }
            if field.0.localizedCaseInsensitiveContains(term) {
                return partial + field.1
            }
            return partial
        }
    }

    private func moviesByIDs(_ ids: [String]) -> [Movie] {
        ids.compactMap(movie(id:))
    }

    private func compactCategories(_ categories: [Category]) -> [Category] {
        categories.filter { !$0.movies.isEmpty }
    }

    private func collectionCategory(id: String, title: String, genre: String) -> Category {
        Category(
            id: id,
            title: title,
            subtitle: "\(genre) collection from the local catalog",
            movies: queryTitles(genre: genre)
        )
    }

    private func similarTitles(to movie: Movie) -> [Movie] {
        queryRelatedContent(for: movie, limit: 10)
    }

    private func fromSameCreator(as movie: Movie) -> [Movie] {
        queryCatalog()
            .filter { $0.id != movie.id && $0.creatorName == movie.creatorName }
            .prefix(10)
            .map { $0 }
    }

    private func searchableTags(for movie: Movie) -> [String] {
        creatorPublishingContents.first { $0.id == movie.id }?.tags ?? []
    }

    private func collectionNames(for movie: Movie) -> [String] {
        (discoveryCollections + collectionSystem)
            .filter { category in category.movies.contains { $0.id == movie.id } }
            .flatMap { [$0.title, $0.subtitle ?? ""] }
    }

    private func searchScore(for movie: Movie, term: String) -> Int {
        let normalized = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return 0 }

        let fields: [(String, Int)] = [
            (movie.title, 120),
            (movie.subtitle, 55),
            (movie.creatorName, 70),
            (movie.genres.joined(separator: " "), 60),
            (searchableTags(for: movie).joined(separator: " "), 65),
            (collectionNames(for: movie).joined(separator: " "), 50),
            (movie.synopsis, 28),
            (movie.duration, 12),
            (movie.year, 8)
        ]

        return fields.reduce(0) { partial, field in
            let value = field.0
            let weight = field.1
            if value.localizedCaseInsensitiveCompare(normalized) == .orderedSame {
                return partial + weight + 40
            }
            if value.localizedCaseInsensitiveContains(normalized) {
                return partial + weight
            }
            return partial
        }
    }

    func isSaved(_ movie: Movie) -> Bool {
        savedMovieIDs.contains(movie.id)
    }

    func toggleSaved(_ movie: Movie) {
        if savedMovieIDs.contains(movie.id) {
            savedMovieIDs.remove(movie.id)
        } else {
            savedMovieIDs.insert(movie.id)
        }
        persist(savedMovieIDs, key: scopedSavedKey)
        invalidateCatalogRuntime(reason: "Saved library changed")
    }

    func isDownloaded(_ movie: Movie) -> Bool {
        downloadedMovieIDs.contains(movie.id)
    }

    func toggleDownload(_ movie: Movie) {
        if downloadedMovieIDs.contains(movie.id) {
            removeOfflineAsset(for: movie)
        } else {
            queueOfflineAsset(for: movie)
        }
    }

    func removeAllDownloads() {
        downloadedMovieIDs.removeAll()
        persist(downloadedMovieIDs, key: scopedDownloadsKey)
        invalidateCatalogRuntime(reason: "Local offline shelf cleared")
    }

    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        recentSearches.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(6))
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func clearRecentSearches() {
        recentSearches.removeAll()
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    @discardableResult
    func createCreatorDraft(
        title: String,
        description: String,
        creator: String,
        genre: String,
        tags: [String] = [],
        runtime: String = "Draft"
    ) -> HFCreatorPublishingContent {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle = trimmedTitle.isEmpty ? "Untitled Creator Draft" : trimmedTitle
        let draft = HFCreatorPublishingContent(
            id: "draft-\(resolvedTitle.lowercased().filter { $0.isLetter || $0.isNumber }.prefix(24))-\(creatorPublishingContents.count + 1)",
            title: resolvedTitle,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Creator draft stored in the local content repository." : description,
            posterAssetName: nil,
            trailerStatus: .placeholder,
            creator: creator.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? activeViewingProfile.displayName : creator,
            genre: genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Drama" : genre,
            tags: tags,
            runtime: runtime,
            releaseState: .draft,
            posterStatus: .placeholder,
            metadataStatus: .ready,
            artworkStatus: .placeholder,
            updatedAtLabel: "Draft persisted locally"
        )
        creatorPublishingContents.insert(draft, at: 0)
        persistCreatorPublishingContents()
        return draft
    }

    func updateCreatorDraft(
        id: String,
        title: String? = nil,
        description: String? = nil,
        posterAssetName: String? = nil,
        creator: String? = nil,
        genre: String? = nil,
        tags: [String]? = nil,
        runtime: String? = nil,
        posterStatus: HFCreatorPublishingAssetStatus? = nil,
        trailerStatus: HFCreatorPublishingAssetStatus? = nil,
        metadataStatus: HFCreatorPublishingAssetStatus? = nil,
        artworkStatus: HFCreatorPublishingAssetStatus? = nil
    ) {
        guard let index = creatorPublishingContents.firstIndex(where: { $0.id == id }) else { return }
        if let title {
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { creatorPublishingContents[index].title = trimmed }
        }
        if let description {
            let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
            creatorPublishingContents[index].description = trimmed.isEmpty ? creatorPublishingContents[index].description : trimmed
        }
        if let posterAssetName { creatorPublishingContents[index].posterAssetName = posterAssetName }
        if let creator {
            let trimmed = creator.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { creatorPublishingContents[index].creator = trimmed }
        }
        if let genre {
            let trimmed = genre.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { creatorPublishingContents[index].genre = trimmed }
        }
        if let tags {
            creatorPublishingContents[index].tags = tags
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        if let runtime {
            let trimmed = runtime.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { creatorPublishingContents[index].runtime = trimmed }
        }
        if let posterStatus { creatorPublishingContents[index].posterStatus = posterStatus }
        if let trailerStatus { creatorPublishingContents[index].trailerStatus = trailerStatus }
        if let metadataStatus { creatorPublishingContents[index].metadataStatus = metadataStatus }
        if let artworkStatus { creatorPublishingContents[index].artworkStatus = artworkStatus }
        creatorPublishingContents[index].updatedAtLabel = "Draft updated locally"
        persistCreatorPublishingContents()
    }

    func loadCreatorDraft(id: String) -> HFCreatorPublishingContent? {
        publishingRepository.fetchDrafts().first { $0.id == id }
    }

    func creatorDraftValidationItems(for draft: HFCreatorPublishingContent) -> [HFCreatorDraftValidationItem] {
        let hasTitle = !draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasDescription = draft.description.trimmingCharacters(in: .whitespacesAndNewlines).count >= 24
        let hasGenre = !draft.genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasTags = !draft.tags.isEmpty
        let hasRuntime = !draft.runtime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return [
            HFCreatorDraftValidationItem(id: "metadata", title: "Draft Metadata", detail: "Title, synopsis, genre, tags, and runtime are stored in the content snapshot.", status: hasTitle && hasDescription && hasGenre && hasTags && hasRuntime ? "Ready" : "Needs detail", isComplete: hasTitle && hasDescription && hasGenre && hasTags && hasRuntime, systemImage: "text.justify.left"),
            HFCreatorDraftValidationItem(id: "poster", title: "Draft Poster Registry", detail: mediaAssetRecord(project: draft, kind: .poster, status: draft.posterStatus).detail, status: draft.posterStatus.rawValue, isComplete: draft.posterStatus == .ready || draft.posterStatus == .needsReview, systemImage: "photo.fill.on.rectangle.fill"),
            HFCreatorDraftValidationItem(id: "trailer", title: "Draft Trailer Registry", detail: mediaAssetRecord(project: draft, kind: .trailer, status: draft.trailerStatus).detail, status: draft.trailerStatus.rawValue, isComplete: draft.trailerStatus == .ready || draft.trailerStatus == .needsReview, systemImage: "film.stack.fill"),
            HFCreatorDraftValidationItem(id: "artwork", title: "Artwork Registry", detail: mediaAssetRecord(project: draft, kind: .artwork, status: draft.artworkStatus).detail, status: draft.artworkStatus.rawValue, isComplete: draft.artworkStatus == .ready || draft.artworkStatus == .needsReview, systemImage: "rectangle.stack.fill"),
            HFCreatorDraftValidationItem(id: "review", title: "Ready For Review", detail: "A draft becomes review-ready when core metadata and asset states are complete.", status: draft.readyForReview ? "Ready" : "Draft", isComplete: draft.readyForReview, systemImage: "checkmark.seal.fill")
        ]
    }

    func creatorDraftCompareRecords(
        for draft: HFCreatorPublishingContent,
        title: String,
        description: String,
        genre: String,
        tags: [String],
        runtime: String,
        posterStatus: HFCreatorPublishingAssetStatus,
        trailerStatus: HFCreatorPublishingAssetStatus,
        metadataStatus: HFCreatorPublishingAssetStatus,
        artworkStatus: HFCreatorPublishingAssetStatus
    ) -> [HFCreatorDraftCompareRecord] {
        func record(id: String, field: String, saved: String, editor: String, systemImage: String) -> HFCreatorDraftCompareRecord {
            let isChanged = saved.trimmingCharacters(in: .whitespacesAndNewlines) != editor.trimmingCharacters(in: .whitespacesAndNewlines)
            return HFCreatorDraftCompareRecord(
                id: id,
                field: field,
                savedValue: saved.isEmpty ? "Empty" : saved,
                editorValue: editor.isEmpty ? "Empty" : editor,
                state: isChanged ? "Edited" : "Saved",
                systemImage: systemImage
            )
        }

        return [
            record(id: "title", field: "Title", saved: draft.title, editor: title, systemImage: "textformat"),
            record(id: "description", field: "Description", saved: draft.description, editor: description, systemImage: "text.alignleft"),
            record(id: "genre", field: "Genre", saved: draft.genre, editor: genre, systemImage: "tag.fill"),
            record(id: "tags", field: "Tags", saved: draft.tags.joined(separator: ", "), editor: tags.joined(separator: ", "), systemImage: "number"),
            record(id: "runtime", field: "Runtime", saved: draft.runtime, editor: runtime, systemImage: "clock.fill"),
            record(id: "poster", field: "Poster", saved: draft.posterStatus.rawValue, editor: posterStatus.rawValue, systemImage: "photo.fill.on.rectangle.fill"),
            record(id: "trailer", field: "Trailer", saved: draft.trailerStatus.rawValue, editor: trailerStatus.rawValue, systemImage: "film.stack.fill"),
            record(id: "metadata", field: "Metadata", saved: draft.metadataStatus.rawValue, editor: metadataStatus.rawValue, systemImage: "list.bullet.rectangle.fill"),
            record(id: "artwork", field: "Artwork", saved: draft.artworkStatus.rawValue, editor: artworkStatus.rawValue, systemImage: "rectangle.stack.fill")
        ]
    }

    func creatorDraftHistoryRecords(for draft: HFCreatorPublishingContent) -> [HFCreatorDraftHistoryRecord] {
        [
            HFCreatorDraftHistoryRecord(id: "created", title: "Draft Created", detail: "\(draft.title) entered the creator library as a local draft.", status: "Snapshot", systemImage: "doc.badge.plus"),
            HFCreatorDraftHistoryRecord(id: "updated", title: "Last Saved", detail: draft.updatedAtLabel, status: "Stored", systemImage: "externaldrive.fill"),
            HFCreatorDraftHistoryRecord(id: "readiness", title: "Validation", detail: draft.readyForReview ? "All review gates are satisfied." : "Draft remains editable before review.", status: draft.readyForReview ? "Ready" : "Draft", systemImage: "checkmark.seal.fill")
        ]
    }

    func archiveCreatorDraft(id: String) {
        guard let index = creatorPublishingContents.firstIndex(where: { $0.id == id }) else { return }
        creatorPublishingContents[index].releaseState = .archived
        creatorPublishingContents[index].updatedAtLabel = "Archived locally"
        persistCreatorPublishingContents()
    }

    private func persistCreatorPublishingContents() {
        contentSnapshot.publishingProjects = creatorPublishingContents
        contentSnapshot.updatedAtLabel = "Creator drafts persisted locally"
        persistContentSnapshot(reason: "Publishing snapshot changed")
    }

    private func persistContentSnapshot(reason: String) {
        contentStorage.saveSnapshot(contentSnapshot)
        invalidateCatalogRuntime(reason: reason)
        refreshIdentitySessionRuntime(reason: reason)
    }

    private func markProjectAssetReady(projectID: String, kind: HFCreatorMediaAssetKind) {
        guard let index = creatorPublishingContents.firstIndex(where: { $0.id == projectID }) else { return }
        switch kind {
        case .poster:
            creatorPublishingContents[index].posterStatus = .ready
        case .trailer:
            creatorPublishingContents[index].trailerStatus = .ready
        case .artwork:
            creatorPublishingContents[index].artworkStatus = .ready
        case .metadata:
            creatorPublishingContents[index].metadataStatus = .ready
        }
        creatorPublishingContents[index].updatedAtLabel = "Local media import updated project readiness"
        contentSnapshot.publishingProjects = creatorPublishingContents
    }

    private func markProjectAssetNeedsReview(projectID: String, kind: HFCreatorMediaAssetKind) {
        guard let index = creatorPublishingContents.firstIndex(where: { $0.id == projectID }) else { return }
        switch kind {
        case .poster:
            creatorPublishingContents[index].posterStatus = .needsReview
        case .trailer:
            creatorPublishingContents[index].trailerStatus = .needsReview
        case .artwork:
            creatorPublishingContents[index].artworkStatus = .needsReview
        case .metadata:
            creatorPublishingContents[index].metadataStatus = .needsReview
        }
        creatorPublishingContents[index].updatedAtLabel = "Media inspection requires review"
        contentSnapshot.publishingProjects = creatorPublishingContents
    }

    private func makeLocalReleasePackageManifest(
        project: HFCreatorPublishingContent,
        packageID: String,
        packageVersion: String
    ) -> HFCreatorLocalReleasePackageManifest {
        let projectAssets = contentSnapshot.importedMediaAssets.filter { $0.projectID == project.id }
        let assetManifests = projectAssets.map { asset -> HFCreatorReleaseAssetManifest in
            let inspection = contentSnapshot.mediaInspectionRecords.first { $0.assetID == asset.id }
            return HFCreatorReleaseAssetManifest(
                assetID: asset.id,
                kind: asset.kind.rawValue,
                filename: asset.originalFilename,
                relativePath: asset.storedRelativePath,
                checksum: asset.checksum,
                fileSizeBytes: asset.byteCount,
                inspectionState: inspection?.state.rawValue ?? "Not Inspected",
                technicalSummary: inspection?.summary ?? "No inspection record"
            )
        }
        let validation = creatorProjectValidationRecords.first { $0.id == "project-validation-\(project.id)" }
        let quarantinedCount = contentSnapshot.mediaInspectionRecords.filter { $0.projectID == project.id && $0.isQuarantined }.count
        let validationReports = [
            HFCreatorReleaseValidationReport(gate: "Metadata", status: validation?.metadataComplete == true ? "Ready" : "Review", detail: "Title, description, creator, genre, tags, and runtime.", isPassing: validation?.metadataComplete == true),
            HFCreatorReleaseValidationReport(gate: "Poster", status: validation?.posterReady == true ? "Ready" : "Review", detail: "Poster registry and imported artwork state.", isPassing: validation?.posterReady == true),
            HFCreatorReleaseValidationReport(gate: "Trailer", status: validation?.trailerReady == true ? "Ready" : "Review", detail: "Trailer registry and imported media state.", isPassing: validation?.trailerReady == true),
            HFCreatorReleaseValidationReport(gate: "Inspection", status: quarantinedCount == 0 ? "Clear" : "Quarantine", detail: "\(quarantinedCount) quarantined imported media assets.", isPassing: quarantinedCount == 0),
            HFCreatorReleaseValidationReport(gate: "Release", status: validation?.releaseReady == true && quarantinedCount == 0 ? "Ready" : "Review", detail: "Project runtime release readiness plus media inspection status.", isPassing: validation?.releaseReady == true && quarantinedCount == 0)
        ]

        return HFCreatorLocalReleasePackageManifest(
            packageID: packageID,
            packageVersion: packageVersion,
            createdAtLabel: timestampLabel(),
            project: HFCreatorReleaseProjectManifest(
                projectID: project.id,
                creatorID: creatorID(for: project.creator),
                contentID: project.movie.id,
                title: project.title,
                description: project.description,
                genre: project.genre,
                tags: project.tags,
                runtime: project.runtime,
                releaseState: project.releaseState.rawValue
            ),
            assets: assetManifests,
            validation: validationReports,
            rights: HFCreatorReleaseRightsMetadata(
                rightsState: "Planning",
                territoryPreview: "Local territory preview",
                clearanceState: "Not legally submitted",
                notes: "Placeholder rights fields for package completeness. No contracts or licensing transaction is created."
            ),
            creator: HFCreatorReleaseCreatorMetadata(
                creatorID: creatorID(for: project.creator),
                creatorName: project.creator,
                workspace: identitySessionRuntime.workspaceTitle
            ),
            relationships: [
                "Project -> \(project.id)",
                "Creator -> \(creatorID(for: project.creator))",
                "Content -> \(project.movie.id)",
                "Collections -> \(project.tags.joined(separator: ", "))"
            ]
        )
    }

    private func validateLocalReleasePackage(at manifestURL: URL) -> Bool {
        guard let data = try? Data(contentsOf: manifestURL),
              let manifest = try? JSONDecoder().decode(HFCreatorLocalReleasePackageManifest.self, from: data) else {
            return false
        }
        return !manifest.packageID.isEmpty
            && !manifest.packageVersion.isEmpty
            && !manifest.project.projectID.isEmpty
            && !manifest.project.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !manifest.creator.creatorID.isEmpty
            && !manifest.validation.isEmpty
            && manifest.validation.contains { $0.gate == "Release" }
    }

    private func makeMediaInspectionRecord(
        for asset: HFCreatorImportedMediaAsset,
        fileURL: URL
    ) -> HFCreatorMediaInspectionRecord {
        let attributes = (try? FileManager.default.attributesOfItem(atPath: fileURL.path)) ?? [:]
        let fileSize = (attributes[.size] as? NSNumber)?.intValue ?? asset.byteCount
        var durationLabel = "No duration"
        var dimensionsLabel = "No dimensions"
        var aspectRatioLabel = "Unknown aspect"
        var frameRateLabel = "No frame rate"
        var videoCodec = "No video codec"
        var audioCodec = "No audio codec"
        var audioChannelCount = 0
        var hasVideoTrack = false
        var hasAudioTrack = false
        var posterDimensionsLabel = "No poster dimensions"
        var warning = ""
        var blockingIssue = ""

        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        if !fileExists {
            blockingIssue = "Copied sandbox file is missing. Re-import this asset."
        } else if isImageInspectionTarget(asset) {
            if let dimensions = imageDimensions(for: fileURL) {
                dimensionsLabel = "\(Int(dimensions.width)) x \(Int(dimensions.height))"
                posterDimensionsLabel = dimensionsLabel
                aspectRatioLabel = aspectRatioDescription(width: dimensions.width, height: dimensions.height)
                if dimensions.width < 1 || dimensions.height < 1 {
                    blockingIssue = "Image dimensions could not be read. Select a valid poster or artwork image."
                } else if asset.kind == .poster {
                    let ratio = dimensions.width / max(dimensions.height, 1)
                    if ratio < 0.50 || ratio > 0.85 {
                        warning = "Poster is readable, but the aspect ratio is outside the preferred vertical poster range."
                    }
                }
            } else {
                blockingIssue = "Image metadata could not be decoded. Select a readable PNG, JPEG, or HEIC image."
            }
        } else if isVideoInspectionTarget(asset) {
            let video = inspectVideoAsset(fileURL)
            durationLabel = video.durationLabel
            dimensionsLabel = video.dimensionsLabel
            aspectRatioLabel = video.aspectRatioLabel
            frameRateLabel = video.frameRateLabel
            videoCodec = video.videoCodec
            audioCodec = video.audioCodec
            audioChannelCount = video.audioChannelCount
            hasVideoTrack = video.hasVideoTrack
            hasAudioTrack = video.hasAudioTrack
            if !video.hasVideoTrack {
                blockingIssue = "No video track was found. Select a playable trailer or source video."
            } else if video.durationSeconds <= 0 {
                blockingIssue = "Video duration is unavailable. Re-import a readable media file."
            } else if !video.hasAudioTrack {
                warning = "Video is readable but no audio track was found."
            }
        } else if fileSize <= 0 {
            blockingIssue = "Metadata file is empty. Re-import a non-empty local file."
        } else {
            warning = "Metadata file is registered. No AV tracks are expected for this asset kind."
        }

        let state: HFCreatorMediaInspectionState
        if !blockingIssue.isEmpty {
            state = .quarantined
        } else if !warning.isEmpty {
            state = .warning
        } else {
            state = .accepted
        }

        return HFCreatorMediaInspectionRecord(
            id: "inspection-\(asset.id)",
            assetID: asset.id,
            projectID: asset.projectID,
            projectTitle: asset.projectTitle,
            kind: asset.kind,
            originalFilename: asset.originalFilename,
            fileSizeBytes: fileSize,
            durationLabel: durationLabel,
            dimensionsLabel: dimensionsLabel,
            aspectRatioLabel: aspectRatioLabel,
            frameRateLabel: frameRateLabel,
            videoCodec: videoCodec,
            audioCodec: audioCodec,
            audioChannelCount: audioChannelCount,
            hasVideoTrack: hasVideoTrack,
            hasAudioTrack: hasAudioTrack,
            posterDimensionsLabel: posterDimensionsLabel,
            state: state,
            warning: warning,
            blockingIssue: blockingIssue,
            inspectedAtLabel: timestampLabel(),
            isQuarantined: state == .quarantined || state == .blocked
        )
    }

    private func isImageInspectionTarget(_ asset: HFCreatorImportedMediaAsset) -> Bool {
        let extensionHint = URL(fileURLWithPath: asset.originalFilename).pathExtension.lowercased()
        return asset.kind == .poster
            || asset.kind == .artwork
            || asset.contentType.contains("image")
            || ["png", "jpg", "jpeg", "heic"].contains(extensionHint)
    }

    private func isVideoInspectionTarget(_ asset: HFCreatorImportedMediaAsset) -> Bool {
        let extensionHint = URL(fileURLWithPath: asset.originalFilename).pathExtension.lowercased()
        return asset.kind == .trailer
            || asset.contentType.contains("movie")
            || asset.contentType.contains("video")
            || ["mov", "mp4", "m4v"].contains(extensionHint)
    }

    private func imageDimensions(for url: URL) -> CGSize? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = properties[kCGImagePropertyPixelHeight] as? CGFloat else {
            return nil
        }
        return CGSize(width: width, height: height)
    }

    private func inspectVideoAsset(_ url: URL) -> (
        durationSeconds: Double,
        durationLabel: String,
        dimensionsLabel: String,
        aspectRatioLabel: String,
        frameRateLabel: String,
        videoCodec: String,
        audioCodec: String,
        audioChannelCount: Int,
        hasVideoTrack: Bool,
        hasAudioTrack: Bool
    ) {
        let avAsset = AVURLAsset(url: url)
        let durationSeconds = CMTimeGetSeconds(avAsset.duration)
        let videoTrack = avAsset.tracks(withMediaType: .video).first
        let audioTrack = avAsset.tracks(withMediaType: .audio).first
        let transformedSize = videoTrack.map { $0.naturalSize.applying($0.preferredTransform) } ?? .zero
        let width = abs(transformedSize.width)
        let height = abs(transformedSize.height)
        let frameRate = videoTrack?.nominalFrameRate ?? 0
        let channelCount = audioTrack.flatMap { track in
            track.formatDescriptions
                .map { ($0 as! CMFormatDescription) }
                .compactMap { CMAudioFormatDescriptionGetStreamBasicDescription($0)?.pointee.mChannelsPerFrame }
                .map(Int.init)
                .first
        } ?? 0

        return (
            durationSeconds: durationSeconds.isFinite ? durationSeconds : 0,
            durationLabel: durationSeconds.isFinite && durationSeconds > 0 ? String(format: "%.1fs", durationSeconds) : "No duration",
            dimensionsLabel: width > 0 && height > 0 ? "\(Int(width)) x \(Int(height))" : "No dimensions",
            aspectRatioLabel: aspectRatioDescription(width: width, height: height),
            frameRateLabel: frameRate > 0 ? String(format: "%.1f fps", frameRate) : "No frame rate",
            videoCodec: codecLabel(for: firstFormatDescription(from: videoTrack)),
            audioCodec: codecLabel(for: firstFormatDescription(from: audioTrack)),
            audioChannelCount: channelCount,
            hasVideoTrack: videoTrack != nil,
            hasAudioTrack: audioTrack != nil
        )
    }

    private func aspectRatioDescription(width: CGFloat, height: CGFloat) -> String {
        guard width > 0, height > 0 else { return "Unknown aspect" }
        return String(format: "%.2f:1", width / height)
    }

    private func firstFormatDescription(from track: AVAssetTrack?) -> CMFormatDescription? {
        guard let formatDescription = track?.formatDescriptions.first else { return nil }
        return (formatDescription as! CMFormatDescription)
    }

    private func codecLabel(for formatDescription: CMFormatDescription?) -> String {
        guard let formatDescription else { return "Unavailable" }
        return fourCharacterCodeLabel(CMFormatDescriptionGetMediaSubType(formatDescription))
    }

    private func fourCharacterCodeLabel(_ code: FourCharCode) -> String {
        let bytes = [
            UInt8((code >> 24) & 0xff),
            UInt8((code >> 16) & 0xff),
            UInt8((code >> 8) & 0xff),
            UInt8(code & 0xff)
        ]
        let label = String(bytes: bytes, encoding: .macOSRoman) ?? "\(code)"
        return label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(code)" : label
    }

    private func mediaRootDirectory() -> URL {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return baseURL.appendingPathComponent("HighFiveCinema", isDirectory: true)
    }

    private func mediaDirectory(for projectID: String) throws -> URL {
        let directory = mediaRootDirectory()
            .appendingPathComponent("Media", isDirectory: true)
            .appendingPathComponent(projectID, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func packageDirectory(for packageID: String) throws -> URL {
        let directory = mediaRootDirectory()
            .appendingPathComponent("Packages", isDirectory: true)
            .appendingPathComponent(packageID, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func sanitizedFilename(_ filename: String) -> String {
        let fallback = "highfive-local-media"
        let resolved = filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? fallback : filename
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._- "))
        let scalars = resolved.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        let sanitized = String(scalars).replacingOccurrences(of: " ", with: "-")
        return sanitized.isEmpty ? fallback : sanitized
    }

    private func contentTypeIdentifier(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "jpg", "jpeg":
            return "public.jpeg"
        case "png":
            return "public.png"
        case "heic":
            return "public.heic"
        case "mov":
            return "com.apple.quicktime-movie"
        case "mp4", "m4v":
            return "public.mpeg-4"
        default:
            return "public.data"
        }
    }

    private func sha256Hex(for data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func timestampLabel() -> String {
        ISO8601DateFormatter().string(from: Date())
    }

    // Communication Service
    // Local Communication Adapter
    // Remote Communication Provider
    // Local-to-Remote Adapter
    // Moderation Readiness
    // Local Audience Updates
    // hf.services.communication
    // hf.services.localCommunicationAdapter
    // hf.services.remoteCommunicationProviderReady
    // hf.services.communicationReadiness
    // hf.services.communicationModeration
    // hf.services.localToRemoteCommunicationAdapter
    // hf.services.audienceChannels
    var communicationServiceMode: String {
        "Local Communication Adapter Active"
    }

    var communicationProviderStatus: HFCommunicationProviderStatus {
        .remoteProviderNotConnected
    }

    var audienceChannels: [HFAudienceChannel] {
        [
            HFAudienceChannel(id: "premiere-updates", title: "Premiere Updates", purpose: "Prepare release-window notes around the featured catalog title.", status: "Local", systemImage: "sparkles.tv.fill"),
            HFAudienceChannel(id: "creator-notes", title: "Creator Notes", purpose: "Shape creator context before future delivery.", status: "Local", systemImage: "note.text"),
            HFAudienceChannel(id: "audience-prompts", title: "Audience Prompts", purpose: "Draft watch-night prompts without live replies.", status: "Preview", systemImage: "questionmark.bubble.fill"),
            HFAudienceChannel(id: "release-reminders", title: "Release Reminders", purpose: "Prepare reminder copy while remote alerts stay disconnected.", status: "Draft", systemImage: "calendar.badge.clock")
        ]
    }

    var localAudienceUpdates: [HFAudienceUpdateRecord] {
        localConnectUpdates.enumerated().map { offset, update in
            let channel = audienceChannels[offset % audienceChannels.count]
            return HFAudienceUpdateRecord(
                id: "local-update-\(offset)",
                channelID: channel.id,
                movieID: featuredMovie.id,
                authorProfileID: activeViewingProfile.id,
                body: update,
                status: offset == 0 ? HFCommunicationUpdateStatus.preview.rawValue : HFCommunicationUpdateStatus.notSent.rawValue,
                safetyLabel: "Local review",
                updatedAtLabel: "Local draft"
            )
        }
    }

    var communicationReadinessRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "local-adapter", title: "Local Communication Adapter", detail: "Audience updates remain local.", status: "Active", systemImage: "point.3.connected.trianglepath.dotted"),
            HFCommunicationReadinessRow(id: "channels", title: "Audience Channels", detail: "Premiere Updates, Creator Notes, Audience Prompts, and Release Reminders.", status: "Local", systemImage: "rectangle.stack.fill"),
            HFCommunicationReadinessRow(id: "drafts", title: "Update Drafts", detail: "Draft, Preview, Ready, and Not Sent states are local.", status: "Local", systemImage: "text.bubble.fill"),
            HFCommunicationReadinessRow(id: "moderation", title: "Moderation Readiness", detail: "Local review and safety checks are prepared.", status: "Local Review", systemImage: "checkmark.shield.fill"),
            HFCommunicationReadinessRow(id: "remote-provider", title: "Remote Communication Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFCommunicationReadinessRow(id: "remote-alerts", title: "Push Notifications", detail: "Not Connected Yet", status: "Future", systemImage: "bell.slash.fill")
        ]
    }

    var communicationModerationRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "local-review", title: "Local review", detail: "Active for local audience updates.", status: "Active", systemImage: "checkmark.circle.fill"),
            HFCommunicationReadinessRow(id: "safety-check", title: "Safety check", detail: "Prepared as a local readiness step.", status: "Local", systemImage: "shield.lefthalf.filled"),
            HFCommunicationReadinessRow(id: "remote-moderation", title: "Remote moderation provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFCommunicationReadinessRow(id: "reporting", title: "Reporting tools", detail: "Not Connected Yet", status: "Future", systemImage: "exclamationmark.bubble.fill"),
            HFCommunicationReadinessRow(id: "abuse-prevention", title: "Abuse prevention", detail: "Future service", status: "Future", systemImage: "lock.shield.fill")
        ]
    }

    var localToRemoteAdapterRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "schema", title: "Channel", detail: selectedAudienceChannelTitle, status: "Local", systemImage: "rectangle.stack.fill"),
            HFCommunicationReadinessRow(id: "catalog", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFCommunicationReadinessRow(id: "profile", title: "Author profile", detail: activeViewingProfile.displayName, status: "Local", systemImage: activeViewingProfile.avatarSymbol),
            HFCommunicationReadinessRow(id: "remote", title: "Remote Communication Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var communicationProofRows: [HFCommunicationReadinessRow] {
        [
            HFCommunicationReadinessRow(id: "local-adapter-proof", title: "Local Communication Adapter", detail: "Active", status: "Active", systemImage: "point.3.connected.trianglepath.dotted"),
            HFCommunicationReadinessRow(id: "audience-updates-proof", title: "Audience Updates", detail: "Local", status: "Local", systemImage: "text.bubble.fill"),
            HFCommunicationReadinessRow(id: "channels-proof", title: "Channels", detail: "Local", status: "Local", systemImage: "rectangle.stack.fill"),
            HFCommunicationReadinessRow(id: "remote-provider-proof", title: "Remote Communication Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFCommunicationReadinessRow(id: "remote-alerts-proof", title: "Push Notifications", detail: "Not Connected Yet", status: "Future", systemImage: "bell.slash.fill"),
            HFCommunicationReadinessRow(id: "moderation-proof", title: "Moderation Provider", detail: "Not Connected Yet", status: "Future", systemImage: "checkmark.shield.fill")
        ]
    }

    var selectedAudienceChannelTitle: String {
        audienceChannels.first { $0.id == selectedAudienceChannelID }?.title ?? audienceChannels[0].title
    }

    func addAudienceUpdate(body: String, channelID: String? = nil) {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let resolvedChannelID = channelID ?? selectedAudienceChannelID
        selectedAudienceChannelID = resolvedChannelID
        let channelTitle = audienceChannels.first { $0.id == resolvedChannelID }?.title ?? selectedAudienceChannelTitle
        localConnectUpdates.insert("Not Sent • \(channelTitle) • \(featuredMovie.title) • \(activeViewingProfile.displayName): \(trimmed)", at: 0)
        localConnectUpdateDraft = ""
        UserDefaults.standard.set(localConnectUpdates, forKey: connectUpdatesKey)
    }

    func removeAudienceUpdate(id: String) {
        guard let indexText = id.split(separator: "-").last, let index = Int(indexText), localConnectUpdates.indices.contains(index) else { return }
        localConnectUpdates.remove(at: index)
        UserDefaults.standard.set(localConnectUpdates, forKey: connectUpdatesKey)
    }

    func updateStatus(for record: HFAudienceUpdateRecord) -> String {
        record.status
    }

    // hf.services.connectUpdates
    func addLocalConnectUpdate(_ text: String) {
        addAudienceUpdate(body: text, channelID: selectedAudienceChannelID)
    }

    // Launch Campaign Service
    // Local Launch Campaign Adapter
    // Remote Campaign Provider
    // Release Calendar
    // Launch Milestones
    // Local-to-Remote Launch Adapter
    // Campaign Readiness
    // Not Published
    // hf.services.launchCampaign
    // hf.services.localLaunchCampaignAdapter
    // hf.services.remoteCampaignProviderReady
    // hf.services.launchCampaignReadiness
    // hf.services.releaseCalendar
    // hf.services.launchMilestones
    // hf.services.localToRemoteLaunchAdapter
    // hf.services.launchCommunicationBridge
    // hf.services.launchExportHandoff
    var launchCampaignServiceMode: String {
        "Local Launch Campaign Adapter Active"
    }

    var launchCampaignProviderStatus: HFLaunchCampaignProviderStatus {
        .remoteProviderNotConnected
    }

    var localLaunchCampaignAdapterStatus: String {
        "Local Launch Campaign Adapter Active"
    }

    var launchCampaignRecord: HFLaunchCampaignRecord {
        HFLaunchCampaignRecord(
            id: "launch-campaign-\(featuredMovie.id)",
            movieID: featuredMovie.id,
            title: "\(featuredMovie.title) Release Plan",
            audience: "Featured title audience",
            status: launchChecklistProgress == launchChecklistItems.count ? HFLaunchMilestoneStatus.ready.rawValue : HFLaunchMilestoneStatus.localReview.rawValue,
            providerStatus: "Remote Campaign Provider Not Connected Yet",
            updatedAtLabel: "Local campaign plan"
        )
    }

    var releaseCalendarRows: [HFLaunchMilestoneRecord] {
        [
            HFLaunchMilestoneRecord(id: "calendar-package-lock", title: "Package review", detail: "Local release package is in review.", status: "Local Review", systemImage: "checklist.checked"),
            HFLaunchMilestoneRecord(id: "calendar-premiere-copy", title: "Premiere copy", detail: "Copy is prepared locally for the featured title.", status: launchChecklistStates.indices.contains(1) && launchChecklistStates[1] ? "Ready" : "Draft", systemImage: "text.quote"),
            HFLaunchMilestoneRecord(id: "calendar-audience-prompt", title: "Audience prompt", detail: "Communication bridge can use local audience updates.", status: launchChecklistStates.indices.contains(2) && launchChecklistStates[2] ? "Ready" : "Local Review", systemImage: "text.bubble.fill"),
            HFLaunchMilestoneRecord(id: "calendar-handoff", title: "Export handoff", detail: "Delivery summary can support campaign package context.", status: generatedDeliverySummary.isEmpty ? "Local Review" : "Ready", systemImage: "shippingbox.fill")
        ]
    }

    var launchMilestoneRecords: [HFLaunchMilestoneRecord] {
        launchChecklistItems.enumerated().map { index, item in
            HFLaunchMilestoneRecord(
                id: "launch-milestone-\(index)",
                title: item,
                detail: "Structured local milestone for \(featuredMovie.title).",
                status: launchChecklistStates.indices.contains(index) && launchChecklistStates[index] ? HFLaunchMilestoneStatus.ready.rawValue : HFLaunchMilestoneStatus.notPublished.rawValue,
                systemImage: launchChecklistStates.indices.contains(index) && launchChecklistStates[index] ? "checkmark.seal.fill" : "circle.dotted"
            )
        }
    }

    var launchCampaignReadinessRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "local-review", title: "Local review", detail: "Active for launch checklist and milestones.", status: "Active", systemImage: "checkmark.circle.fill"),
            HFLaunchCampaignReadinessRow(id: "communication-adapter", title: "Communication adapter", detail: "Audience update bridge is local.", status: "Active", systemImage: "text.bubble.fill"),
            HFLaunchCampaignReadinessRow(id: "export-handoff", title: "Export handoff", detail: "Delivery summary can support launch package context.", status: "Local", systemImage: "shippingbox.fill"),
            HFLaunchCampaignReadinessRow(id: "remote-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFLaunchCampaignReadinessRow(id: "publishing-tools", title: "Publishing tools", detail: "Not Connected Yet", status: "Future", systemImage: "paperplane"),
            HFLaunchCampaignReadinessRow(id: "audience-access", title: "Audience access tools", detail: "Not Connected Yet", status: "Future", systemImage: "person.badge.key.fill"),
            HFLaunchCampaignReadinessRow(id: "campaign-measurement", title: "Campaign measurement", detail: "Not Connected Yet", status: "Future", systemImage: "chart.bar.xaxis")
        ]
    }

    var localToRemoteLaunchAdapterRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "campaign-record", title: "Campaign record", detail: launchCampaignRecord.title, status: launchCampaignRecord.status, systemImage: "flag.checkered"),
            HFLaunchCampaignReadinessRow(id: "catalog-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFLaunchCampaignReadinessRow(id: "active-profile", title: "Local profile", detail: activeViewingProfile.displayName, status: "Local", systemImage: activeViewingProfile.avatarSymbol),
            HFLaunchCampaignReadinessRow(id: "remote-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var launchCampaignProofRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "local-adapter", title: "Local Launch Campaign Adapter", detail: "Active", status: "Active", systemImage: "flag.checkered"),
            HFLaunchCampaignReadinessRow(id: "release-calendar", title: "Release Calendar", detail: "Local", status: "Local", systemImage: "calendar"),
            HFLaunchCampaignReadinessRow(id: "campaign-milestones", title: "Campaign Milestones", detail: "Local", status: "Local", systemImage: "checklist.checked"),
            HFLaunchCampaignReadinessRow(id: "communication-bridge", title: "Communication Bridge", detail: "Local", status: "Local", systemImage: "text.bubble.fill"),
            HFLaunchCampaignReadinessRow(id: "export-handoff", title: "Export Handoff", detail: "Local", status: "Local", systemImage: "shippingbox.fill"),
            HFLaunchCampaignReadinessRow(id: "remote-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFLaunchCampaignReadinessRow(id: "audience-access", title: "Publishing / Audience Access", detail: "Not Connected Yet", status: "Future", systemImage: "person.badge.key.fill")
        ]
    }

    var launchCommunicationBridgeRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "audience-updates", title: "Local Audience Updates", detail: "\(localAudienceUpdates.count) local records", status: "Local", systemImage: "text.bubble.fill"),
            HFLaunchCampaignReadinessRow(id: "channel", title: "Audience channel", detail: selectedAudienceChannelTitle, status: "Local", systemImage: "rectangle.stack.fill"),
            HFLaunchCampaignReadinessRow(id: "campaign-package", title: "Campaign package", detail: "Local communication bridge ready", status: "Local", systemImage: "arrow.triangle.2.circlepath")
        ]
    }

    var launchExportHandoffRows: [HFLaunchCampaignReadinessRow] {
        [
            HFLaunchCampaignReadinessRow(id: "delivery-summary", title: "Delivery summary", detail: generatedDeliverySummary.isEmpty ? "Ready to generate" : "Generated locally", status: generatedDeliverySummary.isEmpty ? "Local Review" : "Ready", systemImage: "doc.text.fill"),
            HFLaunchCampaignReadinessRow(id: "featured-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "rectangle.stack.fill"),
            HFLaunchCampaignReadinessRow(id: "campaign-provider", title: "Remote Campaign Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var campaignPackageSummary: String {
        "\(featuredMovie.title) campaign package is local: \(launchChecklistProgress)/\(launchChecklistItems.count) milestones reviewed, communication bridge local, export handoff local, Remote Campaign Provider Not Connected Yet."
    }

    func markLaunchMilestoneReady(id: String) {
        guard let indexText = id.split(separator: "-").last, let index = Int(indexText), launchChecklistStates.indices.contains(index) else { return }
        toggleLaunchChecklistItem(index, isComplete: true)
    }

    func resetLaunchMilestone(id: String) {
        guard let indexText = id.split(separator: "-").last, let index = Int(indexText), launchChecklistStates.indices.contains(index) else { return }
        toggleLaunchChecklistItem(index, isComplete: false)
    }

    // Export Delivery Service
    // Local Export Delivery Adapter
    // Remote Delivery Provider
    // Delivery Package
    // Delivery Requirements
    // Distribution Handoff
    // Local-to-Remote Export Adapter
    // Export Readiness
    // Not Submitted
    // hf.services.exportDelivery
    // hf.services.localExportDeliveryAdapter
    // hf.services.remoteDeliveryProviderReady
    // hf.services.exportDeliveryReadiness
    // hf.services.deliveryPackage
    // hf.services.deliveryRequirements
    // hf.services.distributionHandoff
    // hf.services.localToRemoteExportAdapter
    // hf.services.exportLaunchHandoff
    // hf.services.exportCommunicationPackage
    var exportDeliveryServiceMode: String {
        "Local Export Delivery Adapter Active"
    }

    var exportDeliveryProviderStatus: HFExportDeliveryProviderStatus {
        .remoteProviderNotConnected
    }

    var localExportDeliveryAdapterStatus: String {
        "Local Export Delivery Adapter Active"
    }

    var deliveryPackageRecord: HFDeliveryPackageRecord {
        HFDeliveryPackageRecord(
            id: "delivery-package-\(featuredMovie.id)",
            movieID: featuredMovie.id,
            title: "\(featuredMovie.title) Delivery Package",
            ownerProfileID: activeViewingProfile.id,
            summary: generatedDeliverySummary.isEmpty ? "Local delivery summary ready to generate." : generatedDeliverySummary,
            status: generatedDeliverySummary.isEmpty ? HFDeliveryPackageStatus.localReview.rawValue : HFDeliveryPackageStatus.ready.rawValue,
            providerStatus: "Remote Delivery Provider Not Connected Yet",
            updatedAtLabel: generatedDeliverySummary.isEmpty ? "Local review" : "Generated locally"
        )
    }

    var deliveryRequirementRows: [HFDeliveryRequirementRecord] {
        [
            HFDeliveryRequirementRecord(id: "poster-artwork", title: "Poster / artwork checklist", detail: "Local readiness notes only.", status: "Local", systemImage: "photo.stack.fill"),
            HFDeliveryRequirementRecord(id: "festival-synopsis", title: "Festival synopsis", detail: "Local summary copy can support review.", status: "Local", systemImage: "rosette"),
            HFDeliveryRequirementRecord(id: "platform-notes", title: "Platform notes", detail: "Provider-ready notes without live submission.", status: "Local", systemImage: "checklist.checked"),
            HFDeliveryRequirementRecord(id: "accessibility-copy", title: "Accessibility copy", detail: "Local text readiness for future packages.", status: "Local", systemImage: "textformat.alt"),
            HFDeliveryRequirementRecord(id: "final-media-asset", title: "Final media asset", detail: "Source required before delivery media exists.", status: "Not Connected Yet", systemImage: "play.slash.fill")
        ]
    }

    var distributionHandoffRows: [HFDistributionHandoffRecord] {
        [
            HFDistributionHandoffRecord(id: "launch-handoff", title: "Launch campaign handoff", detail: "Local campaign package can inform delivery notes.", status: "Local", systemImage: "flag.checkered"),
            HFDistributionHandoffRecord(id: "communication-package", title: "Communication package", detail: "Local audience updates can inform package context.", status: "Local", systemImage: "text.bubble.fill"),
            HFDistributionHandoffRecord(id: "catalog-identity", title: "Catalog identity", detail: featuredMovie.title, status: "Active", systemImage: "rectangle.stack.fill"),
            HFDistributionHandoffRecord(id: "cloud-library", title: "Cloud library boundary", detail: "Saved title state remains local.", status: "Local", systemImage: "bookmark.fill"),
            HFDistributionHandoffRecord(id: "remote-distribution", title: "Remote distribution provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var exportDeliveryReadinessRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "local-review", title: "Local review", detail: "Active for delivery package text.", status: "Active", systemImage: "checkmark.circle.fill"),
            HFExportDeliveryReadinessRow(id: "catalog-identity", title: "Catalog identity", detail: featuredMovie.title, status: "Active", systemImage: "rectangle.stack.fill"),
            HFExportDeliveryReadinessRow(id: "launch-handoff", title: "Launch campaign handoff", detail: "Local campaign adapter connected.", status: "Local", systemImage: "flag.checkered"),
            HFExportDeliveryReadinessRow(id: "communication-package", title: "Communication package", detail: "Local audience updates connected.", status: "Local", systemImage: "text.bubble.fill"),
            HFExportDeliveryReadinessRow(id: "cloud-library", title: "Cloud library boundary", detail: "Local library state can identify selected titles.", status: "Local", systemImage: "bookmark.fill"),
            HFExportDeliveryReadinessRow(id: "remote-provider", title: "Remote Delivery Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFExportDeliveryReadinessRow(id: "platform-submission", title: "Platform Submission", detail: "Not Connected Yet", status: "Future", systemImage: "paperplane"),
            HFExportDeliveryReadinessRow(id: "media-render-file-export", title: "Media Render / File Export", detail: "Not Connected Yet", status: "Future", systemImage: "shippingbox.fill")
        ]
    }

    var localToRemoteExportAdapterRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "package-record", title: "Delivery Package", detail: deliveryPackageRecord.title, status: deliveryPackageRecord.status, systemImage: "shippingbox.fill"),
            HFExportDeliveryReadinessRow(id: "catalog-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFExportDeliveryReadinessRow(id: "active-profile", title: "Local profile", detail: activeViewingProfile.displayName, status: "Local", systemImage: activeViewingProfile.avatarSymbol),
            HFExportDeliveryReadinessRow(id: "remote-provider", title: "Remote Delivery Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
        ]
    }

    var exportDeliveryProofRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "local-adapter", title: "Local Export Delivery Adapter", detail: "Active", status: "Active", systemImage: "shippingbox.fill"),
            HFExportDeliveryReadinessRow(id: "delivery-package", title: "Delivery Package", detail: "Local", status: "Local", systemImage: "doc.text.fill"),
            HFExportDeliveryReadinessRow(id: "distribution-handoff", title: "Distribution Handoff", detail: "Local", status: "Local", systemImage: "arrow.triangle.2.circlepath"),
            HFExportDeliveryReadinessRow(id: "launch-handoff", title: "Launch Campaign Handoff", detail: "Local", status: "Local", systemImage: "flag.checkered"),
            HFExportDeliveryReadinessRow(id: "remote-provider", title: "Remote Delivery Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFExportDeliveryReadinessRow(id: "platform-submission", title: "Platform Submission", detail: "Not Connected Yet", status: "Future", systemImage: "paperplane"),
            HFExportDeliveryReadinessRow(id: "media-render-file-export", title: "Media Render / File Export", detail: "Not Connected Yet", status: "Future", systemImage: "video.slash.fill")
        ]
    }

    var exportLaunchHandoffRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "campaign-package", title: "Launch campaign plan", detail: launchCampaignRecord.title, status: launchCampaignRecord.status, systemImage: "flag.checkered"),
            HFExportDeliveryReadinessRow(id: "release-calendar", title: "Release Calendar", detail: "\(releaseCalendarRows.count) local rows", status: "Local", systemImage: "calendar"),
            HFExportDeliveryReadinessRow(id: "delivery-package", title: "Delivery Package", detail: deliveryPackageRecord.status, status: "Local", systemImage: "shippingbox.fill")
        ]
    }

    var exportCommunicationPackageRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "audience-updates", title: "Local Audience Updates", detail: "\(localAudienceUpdates.count) local records", status: "Local", systemImage: "text.bubble.fill"),
            HFExportDeliveryReadinessRow(id: "channel", title: "Audience channel", detail: selectedAudienceChannelTitle, status: "Local", systemImage: "rectangle.stack.fill"),
            HFExportDeliveryReadinessRow(id: "delivery-notes", title: "Delivery notes", detail: "Audience context can inform local package notes.", status: "Local", systemImage: "note.text")
        ]
    }

    var exportCatalogContextRows: [HFExportDeliveryReadinessRow] {
        [
            HFExportDeliveryReadinessRow(id: "catalog-title", title: "Catalog title", detail: featuredMovie.title, status: "Catalog", systemImage: "film.stack.fill"),
            HFExportDeliveryReadinessRow(id: "player-source", title: "Player source boundary", detail: playbackSource(for: featuredMovie).readinessLabel, status: "Source", systemImage: "play.rectangle.fill"),
            HFExportDeliveryReadinessRow(id: "library-boundary", title: "Cloud Library boundary", detail: isSaved(featuredMovie) ? "Saved locally" : "Ready for local saved state", status: "Local", systemImage: "bookmark.fill"),
            HFExportDeliveryReadinessRow(id: "offline-boundary", title: "Offline state boundary", detail: "Offline state does not create delivery media files.", status: "Local", systemImage: "arrow.down.circle.fill")
        ]
    }

    func updateDeliveryPackageStatus(_ status: HFDeliveryPackageStatus) -> String {
        status.rawValue
    }

    // Payment + Entitlement Service
    // Local Entitlement Adapter
    // Remote Payment Provider
    // Store Provider
    // Access Tiers
    // Entitlement Readiness
    // Local Preview Only
    // No Purchase Active
    // hf.services.paymentEntitlement
    // hf.services.localEntitlementAdapter
    // hf.services.remotePaymentProviderReady
    // hf.services.storeProviderReady
    // hf.services.entitlementReadiness
    // hf.services.accessTiers
    // hf.services.localToRemotePaymentAdapter
    // hf.services.playerEntitlementBoundary
    // hf.services.libraryEntitlementBoundary
    // hf.services.downloadEntitlementBoundary
    // hf.services.exportEntitlementBoundary
    // hf.services.launchEntitlementBoundary
    var paymentEntitlementServiceMode: String {
        entitlementRuntimeStatus.statusLabel
    }

    var localEntitlementAdapterStatus: String {
        "Local Preview Access"
    }

    var paymentProviderStatus: HFPaymentProviderStatus {
        entitlementRuntimeStatus.accessState == .localPreviewAccess ? .localAdapterActive : .remoteProviderNotConnected
    }

    var storeProviderStatus: String {
        entitlementRuntimeStatus.restoreState.statusLabel
    }

    var activeProfileAccessTier: String {
        "\(activeViewingProfile.displayName) - Local Preview Access"
    }

    var accessTierRows: [HFAccessTierRecord] {
        [
            HFAccessTierRecord(id: "viewer-preview", title: "Viewer Preview", detail: "Streaming shell access is represented locally.", status: "Local Preview Access", systemImage: "person.crop.circle.fill"),
            HFAccessTierRecord(id: "highfive-originals", title: "HighFive Originals", detail: "Original title scope is organized locally.", status: "Local Preview Access", systemImage: "sparkles.tv.fill"),
            HFAccessTierRecord(id: "creator-package", title: "Creator Package", detail: "Export and launch package scope remains local.", status: "Local Preview Access", systemImage: "shippingbox.fill")
        ]
    }

    var entitlementRecords: [HFEntitlementRecord] {
        [
            HFEntitlementRecord(id: "featured-title", title: featuredMovie.title, scope: "Movie access scope", status: HFEntitlementStatus.localPreview.rawValue, detail: "No server validation. Watch Now remains available.", systemImage: "play.rectangle.fill"),
            HFEntitlementRecord(id: "library-shelf", title: "Library shelf", scope: "Saved title access", status: HFEntitlementStatus.localPreview.rawValue, detail: "Saved state uses local readiness only.", systemImage: "bookmark.fill"),
            HFEntitlementRecord(id: "offline-state", title: "Offline shelf", scope: "Downloads access", status: HFEntitlementStatus.notValidated.rawValue, detail: "Offline state is local and not provider validated.", systemImage: "arrow.down.circle.fill")
        ]
    }

    var paymentReadinessRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "local-adapter", title: "Local Entitlement Adapter", detail: "Active", status: "Local Preview Access", systemImage: "checkmark.shield.fill"),
            HFPaymentReadinessRow(id: "access-tiers", title: "Access Tiers", detail: "\(accessTierRows.count) local preview rows", status: "Local Preview Access", systemImage: "rectangle.3.group.fill"),
            HFPaymentReadinessRow(id: "profile-access", title: "Profile Access", detail: activeProfileAccessTier, status: entitlementRuntimeStatus.statusLabel, systemImage: activeViewingProfile.avatarSymbol),
            HFPaymentReadinessRow(id: "storekit-paywall-source", title: "StoreKit / Paywall Source", detail: storeKitPaywallSourceSummary, status: "Mapped", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "player-boundary", title: "Player Entitlement Boundary", detail: "Local", status: "Local", systemImage: "play.rectangle.fill"),
            HFPaymentReadinessRow(id: "library-downloads", title: "Library / Downloads Access Boundary", detail: "Local", status: "Local", systemImage: "bookmark.fill"),
            HFPaymentReadinessRow(id: "export-launch", title: "Export / Launch Package Access", detail: "Local", status: "Local", systemImage: "shippingbox.fill"),
            HFPaymentReadinessRow(id: "remote-payment", title: "Payment Provider", detail: entitlementRuntimeStatus.paymentProviderLabel, status: "Provider-ready", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store Provider", detail: entitlementRuntimeStatus.restoreState.statusLabel, status: "Provider-ready", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server Entitlement Validation", detail: entitlementRuntimeStatus.boundary.detail, status: "Required", systemImage: "lock.slash.fill")
        ]
    }

    var playbackDescriptorReadinessRows: [HFPaymentReadinessRow] {
        let response = entitlementGatedPlaybackDescriptor(for: continueWatchingMovie)
        let contract = backendPlaybackDescriptorContract(for: continueWatchingMovie)
        return [
            HFPaymentReadinessRow(
                id: "backend-entitlement-validation",
                title: "Backend entitlement validation required",
                detail: "POST \(HFBackendPlaybackDescriptorEndpoint.entitlementValidationPath) for \(contract.entitlementValidationRequest.movieID)",
                status: contract.entitlementValidationResponse.entitlementStatus.statusLabel,
                systemImage: "checkmark.shield.fill"
            ),
            HFPaymentReadinessRow(
                id: "backend-playback-contract",
                title: "Backend playback descriptor endpoint required",
                detail: contract.playbackDescriptorRequest.endpoint.detail,
                status: contract.statusLabel,
                systemImage: "server.rack"
            ),
            HFPaymentReadinessRow(
                id: "server-validation-pending",
                title: "Server entitlement validation pending",
                detail: "Contract is staged without a live backend URL.",
                status: contract.policy.backendURLPolicy,
                systemImage: "clock.badge.checkmark.fill"
            ),
            HFPaymentReadinessRow(
                id: "entitlement-gate",
                title: "Entitlement gate required",
                detail: "Playback descriptor requires entitlement before provider playback can be approved.",
                status: response.gateStatus.statusLabel,
                systemImage: "lock.shield.fill"
            ),
            HFPaymentReadinessRow(
                id: "backend-descriptor",
                title: "Backend descriptor required",
                detail: response.request.backendRequirement.detail,
                status: response.request.backendRequirement.status.statusLabel,
                systemImage: "server.rack"
            ),
            HFPaymentReadinessRow(
                id: "cloudflare-descriptor",
                title: "Cloudflare descriptor not connected",
                detail: "Cloudflare playback requires backend descriptor. No Cloudflare token in app.",
                status: response.cloudflareState.statusLabel,
                systemImage: "network.slash"
            ),
            HFPaymentReadinessRow(
                id: "staging-playback-adapter",
                title: "Staging backend not configured",
                detail: "Staging adapter builds endpoint URLs from runtime config only and keeps Local Preview fallback active when config is missing.",
                status: backendPlaybackDescriptorRequestState.statusLabel,
                systemImage: "rectangle.connected.to.line.below"
            ),
            HFPaymentReadinessRow(
                id: "server-side-cloudflare-signing",
                title: "Server-side Cloudflare signing required",
                detail: "No Cloudflare token in app. Descriptor references are memory-only and not shown.",
                status: "No Cloudflare token in app",
                systemImage: "lock.shield.fill"
            ),
            HFPaymentReadinessRow(
                id: "backend-mediated",
                title: "Playback Descriptor",
                detail: "Cloudflare signed token generated server-side",
                status: "No Cloudflare token in app",
                systemImage: "play.rectangle.on.rectangle.fill"
            )
        ]
    }

    var storeKitPaywallSourceSummary: String {
        "\(HFStoreKitPaywallCatalog.mappings.count) product IDs imported as staging metadata"
    }

    var storeKitPaywallMappings: [HFStoreKitProductMapping] {
        HFStoreKitPaywallCatalog.mappings
    }

    var storeKitAccessRules: [HFMovieAccessRule] {
        HFStoreKitAccessMapping.rules
    }

    func storeKitPaywallMapping(for movie: Movie) -> HFStoreKitProductMapping? {
        HFStoreKitPaywallCatalog.mapping(forCurrentMovieID: movie.id)
    }

    func storeKitEpisodeMappings(for movie: Movie) -> [HFStoreKitProductMapping] {
        HFStoreKitPaywallCatalog.episodeMappings(forCurrentMovieID: movie.id)
    }

    func storeKitAccessRule(for movie: Movie) -> HFMovieAccessRule {
        HFStoreKitAccessMapping.rule(forCurrentMovieID: movie.id)
    }

    func playbackEntitlementContext(for movie: Movie) -> HFPlaybackDescriptorEntitlementContext {
        HFStoreKitAccessMapping.context(forCurrentMovieID: movie.id)
    }

    var localToRemotePaymentAdapterRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "local-profile", title: "Local profile", detail: activeViewingProfile.displayName, status: "Active", systemImage: activeViewingProfile.avatarSymbol),
            HFPaymentReadinessRow(id: "access-tier-record", title: "Access tier record", detail: activeProfileAccessTier, status: "Local Preview Access", systemImage: "rectangle.3.group.fill"),
            HFPaymentReadinessRow(id: "movie-access-scope", title: "Movie access scope", detail: featuredMovie.title, status: "Local", systemImage: "film.stack.fill"),
            HFPaymentReadinessRow(id: "player-boundary", title: "Player boundary", detail: "Local entitlement readiness only", status: "Local", systemImage: "play.rectangle.fill"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store Provider", detail: "Not Connected Yet", status: "Future", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "remote-payment-provider", title: "Remote Payment Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server entitlement validation", detail: "Not Connected Yet", status: "Future", systemImage: "lock.slash.fill")
        ]
    }

    var playerEntitlementBoundaryRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "catalog-identity", title: "Catalog identity", detail: featuredMovie.title, status: "Active", systemImage: "rectangle.stack.fill"),
            HFPaymentReadinessRow(id: "player-route", title: "Player route", detail: "Active", status: "Active", systemImage: "play.rectangle.fill"),
            HFPaymentReadinessRow(id: "local-entitlement-adapter", title: "Local entitlement adapter", detail: "Active", status: "Active", systemImage: "checkmark.shield.fill"),
            HFPaymentReadinessRow(id: "remote-payment-provider", title: "Remote payment provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store provider", detail: "Not Connected Yet", status: "Future", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server entitlement validation", detail: "Not Connected Yet", status: "Future", systemImage: "lock.slash.fill")
        ]
    }

    var libraryEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "saved-titles", title: "Saved titles", detail: "\(savedMovies.count) local records", status: "Local", systemImage: "bookmark.fill"),
            HFPaymentReadinessRow(id: "access-boundary", title: "Access Boundary", detail: "Saved titles use local entitlement readiness only.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var downloadEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "offline-state", title: "Offline state", detail: "\(downloadedMovies.count) local records", status: "Local", systemImage: "arrow.down.circle.fill"),
            HFPaymentReadinessRow(id: "offline-access", title: "Offline Access Boundary", detail: "Real entitlement validation is not connected yet.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var exportEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "delivery-package", title: "Delivery package", detail: deliveryPackageRecord.title, status: "Local", systemImage: "shippingbox.fill"),
            HFPaymentReadinessRow(id: "access-boundary", title: "Delivery Access Boundary", detail: "Payment and entitlement providers are not connected yet.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var launchEntitlementRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "campaign-package", title: "Campaign package", detail: launchCampaignRecord.title, status: "Local", systemImage: "flag.checkered"),
            HFPaymentReadinessRow(id: "access-boundary", title: "Campaign Access Boundary", detail: "Payment and entitlement providers are not connected yet.", status: "Local Preview Access", systemImage: "checkmark.shield.fill")
        ]
    }

    var paymentProofRows: [HFPaymentReadinessRow] {
        [
            HFPaymentReadinessRow(id: "local-adapter", title: "Local Entitlement Adapter", detail: "Active", status: "Active", systemImage: "checkmark.shield.fill"),
            HFPaymentReadinessRow(id: "access-tiers", title: "Access Tiers", detail: "Local Preview Access", status: "Local Preview Access", systemImage: "rectangle.3.group.fill"),
            HFPaymentReadinessRow(id: "remote-payment-provider", title: "Remote Payment Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash"),
            HFPaymentReadinessRow(id: "store-provider", title: "Store Provider", detail: "Not Connected Yet", status: "Future", systemImage: "cart.badge.questionmark"),
            HFPaymentReadinessRow(id: "server-validation", title: "Server Entitlement Validation", detail: "Not Connected Yet", status: "Future", systemImage: "lock.slash.fill")
        ]
    }

    func entitlementStatus(for movie: Movie) -> HFEntitlementStatus {
        entitlementRuntimeStatus.accessState == .entitlementConfigured ? .notValidated : (movie.isComingSoon ? .providerRequired : .localPreview)
    }

    func entitlementCopy(for movie: Movie) -> String {
        let catalogMovie = self.movie(id: movie.id) ?? movie
        return "\(catalogMovie.title) uses \(entitlementRuntimeStatus.statusLabel). \(entitlementRuntimeStatus.boundary.detail)"
    }

    // hf.services.launchChecklist
    var launchChecklistProgress: Int {
        launchChecklistStates.filter { $0 }.count
    }

    func toggleLaunchChecklistItem(_ index: Int, isComplete: Bool) {
        guard launchChecklistStates.indices.contains(index) else { return }
        launchChecklistStates[index] = isComplete
        UserDefaults.standard.set(launchChecklistStates, forKey: launchChecklistKey)
    }

    // hf.services.exportSummary
    func generateDeliverySummary(for movie: Movie? = nil) {
        let selectedMovie = movie ?? featuredMovie
        generatedDeliverySummary = """
        HighFive Cinema Delivery Summary
        Title: \(selectedMovie.title)
        Watch surface: Movie Detail, Watch Now path, related titles, and My List route.
        Launch handoff: Campaign headline, premiere copy, audience prompt, media kit, and release calendar reviewed locally.
        Communication package: \(localAudienceUpdates.count) local audience updates, \(selectedAudienceChannelTitle) channel context, Remote Delivery Provider Not Connected Yet.
        Export package: Delivery Package, Delivery Requirements, Distribution Handoff, and Local-to-Remote Export Adapter are ready for text review.
        Status: \(HFDeliveryPackageStatus.notSubmitted.rawValue), local summary only.
        """
    }

    var currentFunctionalProofRows: [String] {
        [
            "\(savedMovies.count) saved titles",
            "\(downloadedMovies.count) offline-ready titles",
            "Active local profile: \(activeViewingProfile.displayName)",
            "\(localConnectUpdates.count) local updates",
            "\(launchChecklistProgress)/\(launchChecklistItems.count) launch items reviewed",
            generatedDeliverySummary.isEmpty ? "Delivery summary ready to generate" : "Delivery summary generated"
        ]
    }

    private var scopedSavedKey: String {
        Self.scopedKey(savedKey, activeProfileID)
    }

    private var scopedDownloadsKey: String {
        Self.scopedKey(downloadsKey, activeProfileID)
    }

    private func persist(_ ids: Set<String>, key: String) {
        UserDefaults.standard.set(Array(ids).sorted(), forKey: key)
    }

    private static func scopedKey(_ base: String, _ profileID: String) -> String {
        "\(base).\(profileID)"
    }

    private static let localPreviewStreamingIDs: Set<String> = [
        "friendly",
        "paranormall-s1"
    ]

    private static func loadProfileIDs(defaults: UserDefaults, scopedKey: String, fallbackKey: String, fallbackIDs: Set<String>) -> Set<String> {
        if let scoped = defaults.stringArray(forKey: scopedKey) {
            return Set(scoped)
        }
        if let fallback = defaults.stringArray(forKey: fallbackKey) {
            return Set(fallback)
        }
        return fallbackIDs
    }

    private static func uniqueMovies(_ movies: [Movie]) -> [Movie] {
        var seen = Set<String>()
        return movies.filter { seen.insert($0.id).inserted }
    }

    private static func uniqueCreators(_ creators: [Creator]) -> [Creator] {
        var seen = Set<String>()
        return creators.filter { seen.insert($0.id).inserted }
    }

    private static func uniqueSeries(_ series: [HFSeriesRecord]) -> [HFSeriesRecord] {
        var seen = Set<String>()
        return series.filter { seen.insert($0.id).inserted }
    }

    private static func uniqueCategories(_ categories: [Category]) -> [Category] {
        var seen = Set<String>()
        return categories.filter { seen.insert($0.id).inserted }
    }

    private static func slug(_ value: String) -> String {
        let filtered = value
            .lowercased()
            .map { character -> Character in
                character.isLetter || character.isNumber ? character : "-"
            }
        let collapsed = String(filtered)
            .split(separator: "-")
            .joined(separator: "-")
        return collapsed.isEmpty ? "draft" : collapsed
    }

    private static func makeInitialContentSnapshot(projects: [HFCreatorPublishingContent]) -> HFContentBackendSnapshot {
        let baseMovies = HFMockData.movies
        return HFContentBackendSnapshot(
            movies: baseMovies,
            creators: HFMockData.creators,
            series: makeInitialSeriesRecords(movies: baseMovies),
            collections: HFMockData.categories,
            publishingProjects: projects,
            updatedAtLabel: "Seeded local content backend"
        )
    }

    private static func mediaInspectionFixturePNGData() -> Data {
        Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=")
            ?? Data("HighFive PNG fixture".utf8)
    }

    private static func makeInitialSeriesRecords(movies: [Movie]) -> [HFSeriesRecord] {
        [
            makeSeedSeriesRecord(
                movieID: "paranormall-s1",
                movies: movies,
                seasonCount: 1,
                episodesPerSeason: [7],
                status: .published,
                baseProgress: 0.28,
                episodeTitles: [
                    "Cold Open",
                    "The House That Answered",
                    "Basement Signal",
                    "Witness Marks",
                    "The Long Hall",
                    "Static Room",
                    "Nothing Normal"
                ]
            ),
            makeSeedSeriesRecord(
                movieID: "black-turnip",
                movies: movies,
                seasonCount: 1,
                episodesPerSeason: [6],
                status: .scheduled,
                baseProgress: nil,
                episodeTitles: [
                    "Seed Memory",
                    "The Ledger",
                    "Smoke House",
                    "Root Work",
                    "Inheritance",
                    "Harvest"
                ]
            ),
            makeSeedSeriesRecord(
                movieID: "old-satan",
                movies: movies,
                seasonCount: 1,
                episodesPerSeason: [5],
                status: .review,
                baseProgress: nil,
                episodeTitles: [
                    "The Return",
                    "Ash Road",
                    "Small Church",
                    "Bargain",
                    "Old Fire"
                ]
            )
        ]
    }

    private static func makeSeedSeriesRecord(
        movieID: String,
        movies: [Movie],
        seasonCount: Int,
        episodesPerSeason: [Int],
        status: HFCreatorReleaseState,
        baseProgress: Double?,
        episodeTitles: [String]
    ) -> HFSeriesRecord {
        let hero = movies.first { $0.id == movieID } ?? movies[0]
        var titleIndex = 0
        let totalEpisodes = max(1, episodesPerSeason.reduce(0, +))
        let seasons = (1...seasonCount).map { seasonNumber in
            let episodeCount = episodesPerSeason.indices.contains(seasonNumber - 1) ? episodesPerSeason[seasonNumber - 1] : 6
            let episodes = (1...episodeCount).map { episodeNumber in
                let title = episodeTitles.indices.contains(titleIndex) ? episodeTitles[titleIndex] : "Episode \(episodeNumber)"
                let absoluteIndex = titleIndex
                titleIndex += 1
                return HFEpisodeRecord(
                    id: "\(movieID)-s\(seasonNumber)-e\(episodeNumber)",
                    seriesID: movieID,
                    seasonNumber: seasonNumber,
                    episodeNumber: episodeNumber,
                    title: title,
                    synopsis: "\(hero.title) episode \(episodeNumber) expands the local series arc for creator, CMS, library, discovery, and analytics surfaces.",
                    runtime: "\(34 + (absoluteIndex * 3) % 18)m",
                    artworkStatus: hero.posterAssetName == nil ? .placeholder : .ready,
                    releaseState: status,
                    progress: seedEpisodeProgress(baseProgress: baseProgress, episodeIndex: absoluteIndex, totalEpisodes: totalEpisodes)
                )
            }
            return HFSeasonRecord(
                id: "\(movieID)-s\(seasonNumber)",
                seriesID: movieID,
                seasonNumber: seasonNumber,
                title: "Season \(seasonNumber)",
                episodes: episodes
            )
        }
        return HFSeriesRecord(
            id: movieID,
            title: hero.title,
            synopsis: hero.synopsis,
            creatorName: hero.creatorName,
            genre: hero.genres.first ?? "Series",
            status: status,
            seasons: seasons,
            heroMovie: hero
        )
    }

    private static func seedEpisodeProgress(baseProgress: Double?, episodeIndex: Int, totalEpisodes: Int) -> Double? {
        guard let baseProgress else { return nil }
        let completed = Int((baseProgress * Double(totalEpisodes)).rounded(.down))
        if episodeIndex < completed { return 1.0 }
        if episodeIndex == completed {
            let fractional = (baseProgress * Double(totalEpisodes)) - Double(completed)
            return min(0.94, max(0.12, fractional))
        }
        return nil
    }

    private static func makeCreatorPublishingContents() -> [HFCreatorPublishingContent] {
        [
            HFCreatorPublishingContent(
                id: "creator-pipeline-night-file",
                title: "The Night File: Creator Cut",
                description: "A compact thriller package moving from local edit notes into metadata, poster, and trailer review.",
                posterAssetName: nil,
                trailerStatus: .placeholder,
                creator: "HighFive Cinema",
                genre: "Thriller",
                tags: ["Creator", "Pipeline", "Mystery"],
                runtime: "44m",
                releaseState: .draft,
                posterStatus: .placeholder,
                metadataStatus: .ready,
                artworkStatus: .needsReview,
                updatedAtLabel: "Draft saved locally"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-behind-vision",
                title: "Behind the Vision: Studio Notes",
                description: "A creator documentary package with metadata, poster, and trailer materials ready for local review.",
                posterAssetName: "poster_artist_development_coming_soon",
                trailerStatus: .ready,
                creator: "HighFive Cinema",
                genre: "Documentary",
                tags: ["Creator Spotlight", "Original"],
                runtime: "22m",
                releaseState: .review,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .ready,
                updatedAtLabel: "Ready for review"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-maple-street",
                title: "Maple Street: Premiere Preview",
                description: "A scheduled creator release preview for the local catalog, campaign, and collection surfaces.",
                posterAssetName: "poster_maple_street_coming_soon",
                trailerStatus: .ready,
                creator: "In The Light Productions",
                genre: "Mystery",
                tags: ["Premiere", "Collection"],
                runtime: "Limited Series",
                releaseState: .scheduled,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .ready,
                updatedAtLabel: "Scheduled preview"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-friendly-commentary",
                title: "The Friendly: Creator Commentary",
                description: "A published local creator title that now appears in Home, Search, Discovery rails, collections, and creator surfaces.",
                posterAssetName: "the_friendly",
                trailerStatus: .ready,
                creator: "HigherKey Inc.",
                genre: "Drama",
                tags: ["Commentary", "Creator", "Published"],
                runtime: "31m",
                releaseState: .published,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .ready,
                updatedAtLabel: "Published to local discovery"
            ),
            HFCreatorPublishingContent(
                id: "creator-pipeline-archive",
                title: "Artist Development: Early Assembly",
                description: "Archived creator package retained for local library history and excluded from discovery.",
                posterAssetName: "poster_artist_development_coming_soon",
                trailerStatus: .needsReview,
                creator: "HigherKey Studios",
                genre: "Documentary",
                tags: ["Archive", "Music"],
                runtime: "18m",
                releaseState: .archived,
                posterStatus: .ready,
                metadataStatus: .ready,
                artworkStatus: .needsReview,
                updatedAtLabel: "Archived locally"
            )
        ]
    }

    private static func makeLocalProfiles(defaults: UserDefaults) -> [HFLocalViewingProfile] {
        [
            HFLocalViewingProfile(
                id: "profile-michael",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-michael") ?? "Michael",
                role: "Viewer",
                avatarSymbol: "person.crop.circle.fill",
                accentName: "Gold"
            ),
            HFLocalViewingProfile(
                id: "profile-family",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-family") ?? "Family",
                role: "Family",
                avatarSymbol: "person.2.circle.fill",
                accentName: "Orange"
            ),
            HFLocalViewingProfile(
                id: "profile-creator",
                displayName: defaults.string(forKey: "hf.localProfile.displayName.profile-creator") ?? "Creator",
                role: "Creator",
                avatarSymbol: "video.circle.fill",
                accentName: "Cyan"
            )
        ]
    }
}
