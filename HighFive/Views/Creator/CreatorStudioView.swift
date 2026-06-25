import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum HFCreatorStudioFocus: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case socialMediaKit = "Social Kit"
    case instagramConnect = "Instagram Connect"
    case vodPackage = "VOD Package"

    var id: String { rawValue }
}

enum HFSocialCampaignFocus: String, CaseIterable, Identifiable {
    case poster
    case reel
    case caption
    case story
    case platforms

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .poster: return "Poster"
        case .reel: return "Reel"
        case .caption: return "Caption"
        case .story: return "Story"
        case .platforms: return "Platforms"
        }
    }

    var systemImage: String {
        switch self {
        case .poster: return "photo.fill"
        case .reel: return "film.stack.fill"
        case .caption: return "text.quote"
        case .story: return "rectangle.portrait.fill"
        case .platforms: return "square.grid.2x2.fill"
        }
    }

    var purpose: String {
        switch self {
        case .poster: return "Cinematic key-art crop and title lockup"
        case .reel: return "Local vertical clip placeholder and trailer note"
        case .caption: return "Dominant campaign caption and local alternates"
        case .story: return "Vertical story composition and title callout"
        case .platforms: return "Spatial variants with readiness kept secondary"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .poster: return "hf.spatial.social.poster"
        case .reel: return "hf.spatial.social.reel"
        case .caption: return "hf.spatial.social.caption"
        case .story: return "hf.spatial.social.story"
        case .platforms: return "hf.spatial.social.platforms"
        }
    }
}

enum HFVODReleaseFocus: String, CaseIterable, Identifiable {
    case trailer
    case poster
    case synopsis
    case access
    case release

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .trailer: return "Trailer"
        case .poster: return "Poster"
        case .synopsis: return "Synopsis"
        case .access: return "Access"
        case .release: return "Release"
        }
    }

    var systemImage: String {
        switch self {
        case .trailer: return "film.stack.fill"
        case .poster: return "photo.fill"
        case .synopsis: return "text.alignleft"
        case .access: return "checkmark.shield.fill"
        case .release: return "sparkles.tv.fill"
        }
    }

    var purpose: String {
        switch self {
        case .trailer: return "Local trailer-pull preview and timeline note"
        case .poster: return "Cinematic key art, title lockup, and poster note"
        case .synopsis: return "Short and long copy staged locally"
        case .access: return "Pricing, entitlement, and product mapping boundary"
        case .release: return "Distribution and storefront readiness review"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .trailer: return "hf.spatial.vod.trailer"
        case .poster: return "hf.spatial.vod.poster"
        case .synopsis: return "hf.spatial.vod.synopsis"
        case .access: return "hf.spatial.vod.access"
        case .release: return "hf.spatial.vod.release"
        }
    }

    var routeIdentifier: String {
        switch self {
        case .trailer: return "hf.route.vodTrailer"
        case .poster: return "hf.route.vodPoster"
        case .synopsis: return "hf.route.vodSynopsis"
        case .access: return "hf.route.vodAccess"
        case .release: return "hf.route.vodRelease"
        }
    }
}

private enum HFSpatialCreatorTool: String, CaseIterable, Identifiable {
    case look = "Look"
    case trailer = "Trailer"
    case sound = "Sound"
    case social = "Social"
    case vod = "VOD"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .look: return "paintpalette.fill"
        case .trailer: return "film.stack.fill"
        case .sound: return "waveform"
        case .social: return "bubble.left.and.bubble.right.fill"
        case .vod: return "play.rectangle.on.rectangle.fill"
        }
    }

    var purpose: String {
        switch self {
        case .look: return "Mood, poster direction, and color treatment"
        case .trailer: return "Trailer pull, clip placeholder, and timeline note"
        case .sound: return "Music mood, sound direction, and mix notes"
        case .social: return "Local Social Kit handoff"
        case .vod: return "Local VOD package handoff"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .look: return "hf.spatial.creatorStudio.look"
        case .trailer: return "hf.spatial.creatorStudio.trailer"
        case .sound: return "hf.spatial.creatorStudio.sound"
        case .social: return "hf.spatial.creatorStudio.social"
        case .vod: return "hf.spatial.creatorStudio.vod"
        }
    }
}

private enum HFCreatorProSpotlight {
    case dashboard
    case cms
    case pipeline
    case socialAssets
    case vodPackage
    case analytics
    case publishingDashboard
    case publishingQueue
    case publishingReadiness
    case publishingAudit
    case publishingCalendar
    case collaborationDashboard
    case collaborationTeam
    case collaborationTasks
    case collaborationNotes
    case collaborationActivity
    case collaborationTimeline
    case seriesDashboard
    case seriesDetail
    case seriesEpisodes
    case seriesNextEpisode
    case seriesAnalytics
    case revenueDashboard
    case revenueTitles
    case revenueAnalytics
    case revenuePayouts
    case notificationsCenter
    case activityCenter
    case notificationPublishing
    case notificationDiscovery
    case notificationSeries
    case notificationCollaboration
    case notificationRevenue
    case administrationDashboard
    case administrationReview
    case administrationCreators
    case administrationHealth
    case administrationModeration
    case administrationOperations
    case administrationAudit
    case marketplaceDashboard
    case marketplaceCatalog
    case marketplaceTargets
    case marketplaceRights
    case marketplacePackages
    case marketplaceLicensing
    case marketplaceReadiness
    case rightsDashboard
    case rightsLedger
    case rightsWindows
    case rightsTerritories
    case rightsClearance
    case licensingPackages
    case licensingReadiness
    case dealPreparation
    case integrationDashboard
    case integrationServices
    case integrationDataSources
    case integrationSync
    case integrationAPI
    case integrationEnvironments
    case integrationAudit
    case productionBridgeDashboard
    case productionConnections
    case productionFeatureFlags
    case productionServiceMapping
    case productionEnvironmentSwitching
    case productionReadinessReports
    case productionDependencyGraph
    case productionBackendFoundation
    case productionBackendHealth
    case productionBackendCatalog
    case productionBackendFallback
    case cloudCatalogSyncDashboard
    case cloudCatalogCache
    case cloudCatalogDelta
    case cloudCatalogDiagnostics
    case realIdentityDashboard
    case realIdentitySignIn
    case realIdentitySession
    case realIdentityRoles
    case realIdentityDeletion
    case contentBackendDashboard
    case contentBackendRepositories
    case contentBackendFetch
    case contentBackendPersistence
    case contentBackendRelationships
    case draftWorkspace
    case draftEditor
    case draftValidation
    case draftCompare
    case draftHistory
    case draftSyncDashboard
    case draftSyncQueue
    case draftSyncConflict
    case draftSyncRevisions
    case uploadWorkflow
    case uploadSelection
    case uploadValidation
    case uploadManifest
    case uploadQueue
    case uploadPreflight
    case projectRuntime
    case projectManifest
    case projectAssets
    case projectValidation
    case projectReleasePackage
    case projectTimeline
    case mediaImportRuntime
    case mediaImportQueue
    case mediaImportValidation
    case mediaRegistration
    case manifestUpdates
    case projectLinking
    case mediaImportPreflight
    case mediaInspectionPreflight
    case mediaInspectionReport
    case mediaInspectionQuarantine
    case localPackageRuntime
    case localPackageCreate
    case localPackageHistory
    case localPackageValidation
    case localPackageExport

    static var launchSpotlight: HFCreatorProSpotlight {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-content-management") { return .cms }
        if arguments.contains("--hf-cms-content-types") { return .cms }
        if arguments.contains("--hf-cms-collections") { return .cms }
        if arguments.contains("--hf-cms-relationships") { return .cms }
        if arguments.contains("--hf-start-publishing") { return .publishingDashboard }
        if arguments.contains("--hf-publishing-queue") { return .publishingQueue }
        if arguments.contains("--hf-publishing-readiness") { return .publishingReadiness }
        if arguments.contains("--hf-publishing-audit") { return .publishingAudit }
        if arguments.contains("--hf-publishing-calendar") { return .publishingCalendar }
        if arguments.contains("--hf-start-collaboration") { return .collaborationDashboard }
        if arguments.contains("--hf-collaboration-team") { return .collaborationTeam }
        if arguments.contains("--hf-collaboration-tasks") { return .collaborationTasks }
        if arguments.contains("--hf-collaboration-notes") { return .collaborationNotes }
        if arguments.contains("--hf-collaboration-activity") { return .collaborationActivity }
        if arguments.contains("--hf-collaboration-timeline") { return .collaborationTimeline }
        if arguments.contains("--hf-start-series") { return .seriesDashboard }
        if arguments.contains("--hf-series-detail") { return .seriesDetail }
        if arguments.contains("--hf-series-episodes") { return .seriesEpisodes }
        if arguments.contains("--hf-series-next-episode") { return .seriesNextEpisode }
        if arguments.contains("--hf-series-analytics") { return .seriesAnalytics }
        if arguments.contains("--hf-start-revenue") { return .revenueDashboard }
        if arguments.contains("--hf-revenue-dashboard") { return .revenueDashboard }
        if arguments.contains("--hf-revenue-titles") { return .revenueTitles }
        if arguments.contains("--hf-revenue-analytics") { return .revenueAnalytics }
        if arguments.contains("--hf-revenue-payouts") { return .revenuePayouts }
        if arguments.contains("--hf-start-notifications") { return .notificationsCenter }
        if arguments.contains("--hf-notifications-center") { return .notificationsCenter }
        if arguments.contains("--hf-activity-center") { return .activityCenter }
        if arguments.contains("--hf-notifications-publishing") { return .notificationPublishing }
        if arguments.contains("--hf-notifications-discovery") { return .notificationDiscovery }
        if arguments.contains("--hf-notifications-series") { return .notificationSeries }
        if arguments.contains("--hf-notifications-collaboration") { return .notificationCollaboration }
        if arguments.contains("--hf-notifications-revenue") { return .notificationRevenue }
        if arguments.contains("--hf-start-admin") { return .administrationDashboard }
        if arguments.contains("--hf-admin-review") { return .administrationReview }
        if arguments.contains("--hf-admin-creators") { return .administrationCreators }
        if arguments.contains("--hf-admin-health") { return .administrationHealth }
        if arguments.contains("--hf-admin-moderation") { return .administrationModeration }
        if arguments.contains("--hf-admin-operations") { return .administrationOperations }
        if arguments.contains("--hf-admin-audit") { return .administrationAudit }
        if arguments.contains("--hf-start-marketplace") { return .marketplaceDashboard }
        if arguments.contains("--hf-marketplace-catalog") { return .marketplaceCatalog }
        if arguments.contains("--hf-marketplace-targets") { return .marketplaceTargets }
        if arguments.contains("--hf-marketplace-rights") { return .marketplaceRights }
        if arguments.contains("--hf-marketplace-packages") { return .marketplacePackages }
        if arguments.contains("--hf-marketplace-licensing") { return .marketplaceLicensing }
        if arguments.contains("--hf-marketplace-readiness") { return .marketplaceReadiness }
        if arguments.contains("--hf-start-rights") { return .rightsDashboard }
        if arguments.contains("--hf-rights-ledger") { return .rightsLedger }
        if arguments.contains("--hf-rights-windows") { return .rightsWindows }
        if arguments.contains("--hf-rights-territories") { return .rightsTerritories }
        if arguments.contains("--hf-rights-clearance") { return .rightsClearance }
        if arguments.contains("--hf-licensing-packages") { return .licensingPackages }
        if arguments.contains("--hf-licensing-readiness") { return .licensingReadiness }
        if arguments.contains("--hf-deal-preparation") { return .dealPreparation }
        if arguments.contains("--hf-start-integration") { return .integrationDashboard }
        if arguments.contains("--hf-integration-services") { return .integrationServices }
        if arguments.contains("--hf-integration-data-sources") { return .integrationDataSources }
        if arguments.contains("--hf-integration-sync") { return .integrationSync }
        if arguments.contains("--hf-integration-api") { return .integrationAPI }
        if arguments.contains("--hf-integration-environments") { return .integrationEnvironments }
        if arguments.contains("--hf-integration-audit") { return .integrationAudit }
        if arguments.contains("--hf-start-production-bridge") { return .productionBridgeDashboard }
        if arguments.contains("--hf-production-connections") { return .productionConnections }
        if arguments.contains("--hf-production-flags") { return .productionFeatureFlags }
        if arguments.contains("--hf-production-service-mapping") { return .productionServiceMapping }
        if arguments.contains("--hf-production-environments") { return .productionEnvironmentSwitching }
        if arguments.contains("--hf-production-readiness") { return .productionReadinessReports }
        if arguments.contains("--hf-production-dependencies") { return .productionDependencyGraph }
        if arguments.contains("--hf-start-production-backend") { return .productionBackendFoundation }
        if arguments.contains("--hf-production-backend-health") { return .productionBackendHealth }
        if arguments.contains("--hf-production-backend-catalog") { return .productionBackendCatalog }
        if arguments.contains("--hf-production-backend-fallback") { return .productionBackendFallback }
        if arguments.contains("--hf-start-cloud-catalog-sync") { return .cloudCatalogSyncDashboard }
        if arguments.contains("--hf-cloud-catalog-cache") { return .cloudCatalogCache }
        if arguments.contains("--hf-cloud-catalog-delta") { return .cloudCatalogDelta }
        if arguments.contains("--hf-cloud-catalog-diagnostics") { return .cloudCatalogDiagnostics }
        if arguments.contains("--hf-start-real-identity") { return .realIdentityDashboard }
        if arguments.contains("--hf-identity-signin") { return .realIdentitySignIn }
        if arguments.contains("--hf-identity-session") { return .realIdentitySession }
        if arguments.contains("--hf-identity-roles") { return .realIdentityRoles }
        if arguments.contains("--hf-identity-delete") { return .realIdentityDeletion }
        if arguments.contains("--hf-start-content-backend") { return .contentBackendDashboard }
        if arguments.contains("--hf-content-repositories") { return .contentBackendRepositories }
        if arguments.contains("--hf-content-fetch") { return .contentBackendFetch }
        if arguments.contains("--hf-content-persistence") { return .contentBackendPersistence }
        if arguments.contains("--hf-content-relationships") { return .contentBackendRelationships }
        if arguments.contains("--hf-start-draft-workspace") { return .draftWorkspace }
        if arguments.contains("--hf-draft-editor") { return .draftEditor }
        if arguments.contains("--hf-draft-validation") { return .draftValidation }
        if arguments.contains("--hf-draft-compare") { return .draftCompare }
        if arguments.contains("--hf-draft-history") { return .draftHistory }
        if arguments.contains("--hf-start-creator-draft-sync") { return .draftSyncDashboard }
        if arguments.contains("--hf-draft-sync-queue") { return .draftSyncQueue }
        if arguments.contains("--hf-draft-sync-conflict") { return .draftSyncConflict }
        if arguments.contains("--hf-draft-sync-revisions") { return .draftSyncRevisions }
        if arguments.contains("--hf-start-creator-upload") { return .uploadWorkflow }
        if arguments.contains("--hf-upload-selection") { return .uploadSelection }
        if arguments.contains("--hf-upload-validation") { return .uploadValidation }
        if arguments.contains("--hf-upload-manifest") { return .uploadManifest }
        if arguments.contains("--hf-upload-queue") { return .uploadQueue }
        if arguments.contains("--hf-upload-preflight") { return .uploadPreflight }
        if arguments.contains("--hf-start-project-runtime") { return .projectRuntime }
        if arguments.contains("--hf-project-manifest") { return .projectManifest }
        if arguments.contains("--hf-project-assets") { return .projectAssets }
        if arguments.contains("--hf-project-validation") { return .projectValidation }
        if arguments.contains("--hf-project-release-package") { return .projectReleasePackage }
        if arguments.contains("--hf-project-timeline") { return .projectTimeline }
        if arguments.contains("--hf-start-media-import") { return .mediaImportRuntime }
        if arguments.contains("--hf-media-import-queue") { return .mediaImportQueue }
        if arguments.contains("--hf-media-import-validation") { return .mediaImportValidation }
        if arguments.contains("--hf-media-registration") { return .mediaRegistration }
        if arguments.contains("--hf-media-manifest-updates") { return .manifestUpdates }
        if arguments.contains("--hf-media-project-linking") { return .projectLinking }
        if arguments.contains("--hf-media-import-preflight") { return .mediaImportPreflight }
        if arguments.contains("--hf-media-inspection-preflight") { return .mediaInspectionPreflight }
        if arguments.contains("--hf-media-inspection-report") { return .mediaInspectionReport }
        if arguments.contains("--hf-media-quarantine") { return .mediaInspectionQuarantine }
        if arguments.contains("--hf-start-local-package") { return .localPackageRuntime }
        if arguments.contains("--hf-package-create") { return .localPackageCreate }
        if arguments.contains("--hf-package-history") { return .localPackageHistory }
        if arguments.contains("--hf-package-validation") { return .localPackageValidation }
        if arguments.contains("--hf-package-export") { return .localPackageExport }
        if arguments.contains("--hf-start-creator-publishing") { return .pipeline }
        if arguments.contains("--hf-creator-pro-pipeline") { return .pipeline }
        if arguments.contains("--hf-creator-pro-social-assets") { return .socialAssets }
        if arguments.contains("--hf-creator-pro-vod-package") { return .vodPackage }
        if arguments.contains("--hf-creator-pro-analytics") { return .analytics }
        if arguments.contains("--hf-start-analytics") { return .analytics }
        if arguments.contains("--hf-analytics-viewers") { return .analytics }
        if arguments.contains("--hf-analytics-content") { return .analytics }
        if arguments.contains("--hf-analytics-discovery") { return .analytics }
        if arguments.contains("--hf-analytics-creators") { return .analytics }
        if arguments.contains("--hf-analytics-intelligence") { return .analytics }
        return .dashboard
    }
}

private enum HFLaunchProSpotlight {
    case dashboard
    case pipeline
    case platforms
    case campaign
    case assets
    case finalGate

    static var launchSpotlight: HFLaunchProSpotlight {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-launch-pro-pipeline") { return .pipeline }
        if arguments.contains("--hf-launch-pro-platforms") { return .platforms }
        if arguments.contains("--hf-launch-pro-campaign") { return .campaign }
        if arguments.contains("--hf-launch-pro-assets") { return .assets }
        if arguments.contains("--hf-launch-pro-final-gate") { return .finalGate }
        return .dashboard
    }
}

struct CreatorStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var selectedFocus: HFCreatorStudioFocus
    @State private var selectedTool: HFSpatialCreatorTool
    @State private var selectedSocialFocus: HFSocialCampaignFocus
    @State private var selectedVODFocus: HFVODReleaseFocus
    @State private var didSaveLocalDraft = false
    @State private var didSaveSocialCampaign = false
    @State private var didSaveVODPackage = false
    @State private var isWorktableAwake = false
    @State private var isInspectorPresented = false
    @State private var isSocialInspectorPresented = false
    @State private var isVODInspectorPresented = false
    @State private var selectedDraftID: String?
    @State private var draftTitle = ""
    @State private var draftDescription = ""
    @State private var draftGenre = ""
    @State private var draftTags = ""
    @State private var draftRuntime = ""
    @State private var draftPosterStatus: HFCreatorPublishingAssetStatus = .placeholder
    @State private var draftTrailerStatus: HFCreatorPublishingAssetStatus = .placeholder
    @State private var draftMetadataStatus: HFCreatorPublishingAssetStatus = .ready
    @State private var draftArtworkStatus: HFCreatorPublishingAssetStatus = .placeholder
    @State private var draftWorkspaceNotice = "Loaded from repository snapshot"
    @State private var selectedImportProjectID: String?
    @State private var selectedImportKind: HFCreatorMediaAssetKind = .poster
    @State private var selectedPhotoImportItem: PhotosPickerItem?
    @State private var isFileImporterPresented = false
    @State private var mediaImportNotice = "Choose a project and select local media."
    @State private var localPackageNotice = "Create a local release package from the current project runtime."
    private let proSpotlight: HFCreatorProSpotlight
    private let launchProSpotlight: HFLaunchProSpotlight

    init(
        initialFocus: HFCreatorStudioFocus = .dashboard,
        initialSocialFocus: HFSocialCampaignFocus = .poster,
        initialVODFocus: HFVODReleaseFocus = .trailer
    ) {
        _selectedFocus = State(initialValue: initialFocus)
        _selectedTool = State(initialValue: Self.tool(for: initialFocus))
        _selectedSocialFocus = State(initialValue: initialSocialFocus)
        _selectedVODFocus = State(initialValue: initialVODFocus)
        proSpotlight = HFCreatorProSpotlight.launchSpotlight
        launchProSpotlight = HFLaunchProSpotlight.launchSpotlight
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                if selectedFocus == .socialMediaKit {
                    socialCampaignAuthoringWorld
                } else if selectedFocus == .vodPackage {
                    launchProSurface
                    vodLaunchChamber
                } else {
                    creatorStudioProHero
                    spatialWorktable
                    creatorStudioActions
                    creatorStudioProSurface
                    selectedToolHandoff
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.topProtected")
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.bottomProtected")
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isInspectorPresented) {
            creatorInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isSocialInspectorPresented) {
            socialCampaignInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isVODInspectorPresented) {
            vodReleaseInspector
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            guard !reduceMotion else {
                isWorktableAwake = true
                return
            }
            withAnimation(HFSpatialMotionTokens.sceneEntranceAnimation) {
                isWorktableAwake = true
            }
        }
        .accessibilityIdentifier("hf.creatorStudio.screen")
        .accessibilityIdentifier("hf.spatial.creatorStudio")
    }

    private var navigationTitle: String {
        switch selectedFocus {
        case .socialMediaKit: return "Social Media Kit"
        case .vodPackage: return "VOD Package"
        case .dashboard, .instagramConnect: return "Creator Studio"
        }
    }

    private var usesSpatialFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    private static func tool(for focus: HFCreatorStudioFocus) -> HFSpatialCreatorTool {
        switch focus {
        case .dashboard: return .look
        case .socialMediaKit, .instagramConnect: return .social
        case .vodPackage: return .vod
        }
    }

    private var spatialWorktable: some View {
        Group {
            if usesSpatialFallbackLayout {
                VStack(spacing: HFSpacing.md) {
                    ZStack {
                        opticalBlackWorkSurface
                        spatialProjectSlab
                    }
                    .frame(height: 318)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: HFSpacing.sm) {
                            ForEach(HFSpatialCreatorTool.allCases) { tool in
                                spatialToolNode(for: tool, usesOrbitOffset: false)
                            }
                        }
                        .padding(.horizontal, HFSpacing.sm)
                    }
                    .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
                }
            } else {
                ZStack {
                    opticalBlackWorkSurface

                    HFDepthContourOverlay(color: HFColors.violet.opacity(0.72))
                        .opacity(0.34)
                        .blur(radius: min(0.3, HFSpatialMotionTokens.maximumDecorativeBlur))
                        .padding(.horizontal, -42)
                        .accessibilityHidden(true)

                    spatialProjectSlab

                    ForEach(HFSpatialCreatorTool.allCases) { tool in
                        spatialToolNode(for: tool)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: usesSpatialFallbackLayout ? 530 : 560)
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .hfSpatialSceneEntrance(isActive: isWorktableAwake, reduceMotion: reduceMotion)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio spatial worktable with project slab and five tools")
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
        .accessibilityIdentifier("hf.spatial.creatorStudio.worktable")
    }

    private var opticalBlackWorkSurface: some View {
        RoundedRectangle(cornerRadius: HFSpacing.panelRadius + 10, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        HFColors.violet.opacity(0.24),
                (reduceTransparency ? Color.black : HFColors.background.opacity(0.98)),
                Color.black
                    ],
                    center: .center,
                    startRadius: 40,
                    endRadius: 430
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.panelRadius + 10, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                HFColors.gold.opacity(0.38),
                                HFColors.violet.opacity(0.34),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: HFColors.violet.opacity(0.24), radius: 34, x: 0, y: 16)
            .accessibilityHidden(true)
    }

    private var spatialProjectSlab: some View {
        let movie = streamingStore.featuredMovie
        let slabLift: CGFloat = isWorktableAwake && !reduceMotion ? -8 : 0

        return VStack(spacing: HFSpacing.sm) {
            ZStack(alignment: .bottomLeading) {
                projectArtwork(for: movie)
                    .frame(width: 214, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                            .stroke(HFColors.gold.opacity(0.66), lineWidth: 1.2)
                    )
                    .shadow(color: HFColors.gold.opacity(0.32), radius: 24, x: 0, y: 18)
                    .shadow(color: HFColors.violet.opacity(0.32), radius: 32, x: 0, y: -8)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.86)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFCreatorStudioPill(title: didSaveLocalDraft ? "Local Draft Saved" : "Local Draft", isActive: true)
                        .accessibilityIdentifier("hf.creatorStudio.localDraft")

                    Text(movie.title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                        .accessibilityIdentifier("hf.spatial.creatorStudio.projectTitle")

                    Text("Creative worktable")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
                .padding(HFSpacing.md)
            }
            .accessibilityIdentifier("hf.spatial.creatorStudio.project")

            HStack(spacing: HFSpacing.xs) {
                HFCreatorStudioPill(title: "Provider-ready")
                    .accessibilityIdentifier("hf.creatorStudio.providerReady")
                HFCreatorStudioPill(title: "Not Connected Yet")
                    .accessibilityIdentifier("hf.creatorStudio.notConnected")
            }
        }
        .offset(y: slabLift)
        .scaleEffect(isWorktableAwake ? 1 : 0.96)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title) project slab. Local Draft. Selected tool \(selectedTool.rawValue).")
        .hfSpatialFocalHandoff(
            "hf.spatial.handoff.movieToCreator",
            "hf.spatial.handoff.creatorToSocial",
            "hf.spatial.handoff.creatorToVOD"
        )
    }

    @ViewBuilder
    private func projectArtwork(for movie: Movie) -> some View {
        if let assetName = movie.backdropAssetName ?? movie.posterAssetName,
           HFPosterAssetHealth.hasImage(named: assetName) {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            HFPosterFallback(title: movie.title)
        }
    }

    private func spatialToolNode(for tool: HFSpatialCreatorTool, usesOrbitOffset: Bool = true) -> some View {
        let isSelected = selectedTool == tool
        let base = orbitOffset(for: tool)
        let lift: CGFloat = isWorktableAwake && !reduceMotion ? 1 : 0
        let selectedPull = isSelected ? selectedOffset(for: tool) : .zero
        let orbitOffset = CGSize(
            width: base.width + selectedPull.width * lift,
            height: base.height + selectedPull.height * lift
        )
        let offset = usesOrbitOffset ? orbitOffset : .zero

        return Button(action: {
            select(tool)
        }) {
            spatialToolNodeLabel(for: tool, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .frame(minWidth: 72, minHeight: 72)
        .offset(offset)
        .hfSpatialSelectionTreatment(
            isSelected: isSelected,
            accent: HFColors.violet,
            reduceMotion: reduceMotion,
            differentiateWithoutColor: differentiateWithoutColor
        )
        .animation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation, value: selectedTool)
        .accessibilityLabel("\(tool.rawValue) tool")
        .accessibilityValue(isSelected ? "Selected" : "Available")
        .accessibilityHint(tool == .social ? "Opens the local Social Media Kit handoff." : tool == .vod ? "Opens the local VOD Package handoff." : tool.purpose)
        .accessibilityIdentifier(tool.accessibilityIdentifier)
    }

    private func spatialToolNodeLabel(for tool: HFSpatialCreatorTool, isSelected: Bool) -> some View {
        VStack(spacing: HFSpacing.xs) {
            ZStack {
                Circle()
                    .fill(isSelected ? AnyShapeStyle(HFColors.violet.opacity(0.88)) : AnyShapeStyle(Color.white.opacity(0.075)))
                Image(systemName: tool.systemImage)
                    .font(.system(size: 19, weight: .black))
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textPrimary)
            }
            .frame(width: 46, height: 46)

            Text(tool.rawValue)
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(tool.purpose)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            if isSelected || differentiateWithoutColor {
                Label(isSelected ? "Selected" : "Available", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
        }
        .frame(width: 104)
        .frame(minHeight: 100)
        .padding(HFSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .fill(isSelected ? HFColors.violet.opacity(0.26) : Color.black.opacity(0.34))
        )
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? HFColors.gold.opacity(0.58) : HFColors.glassStroke, lineWidth: 1)
        )
        .shadow(color: isSelected ? HFColors.violet.opacity(0.38) : Color.clear, radius: 18, x: 0, y: 8)
    }

    private func orbitOffset(for tool: HFSpatialCreatorTool) -> CGSize {
        switch tool {
        case .look: return CGSize(width: -112, height: -188)
        case .trailer: return CGSize(width: 112, height: -188)
        case .sound: return CGSize(width: -126, height: -2)
        case .social: return CGSize(width: 126, height: -2)
        case .vod: return CGSize(width: 0, height: 194)
        }
    }

    private func selectedOffset(for tool: HFSpatialCreatorTool) -> CGSize {
        switch tool {
        case .look: return CGSize(width: 8, height: 18)
        case .trailer: return CGSize(width: -8, height: 18)
        case .sound: return CGSize(width: 20, height: -2)
        case .social: return CGSize(width: -20, height: -2)
        case .vod: return CGSize(width: 0, height: -22)
        }
    }

    private func select(_ tool: HFSpatialCreatorTool) {
        withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
            selectedTool = tool
            switch tool {
            case .social:
                selectedFocus = .socialMediaKit
            case .vod:
                selectedFocus = .vodPackage
            case .look, .trailer, .sound:
                selectedFocus = .dashboard
            }
        }
    }

    private var creatorStudioActions: some View {
        HFSpatialActionCluster {
            HFEnergyAction(title: "Build the Release", systemImage: "checkmark.seal.fill", style: .gold) {
                didSaveLocalDraft = true
                select(.vod)
            }
            .accessibilityLabel("Build the Release as a local draft")
            .accessibilityIdentifier("hf.spatial.creatorStudio.buildRelease")

            HStack(spacing: HFSpacing.sm) {
                Button {
                    didSaveLocalDraft = true
                } label: {
                    HFCreatorStudioAction(title: didSaveLocalDraft ? "Local Draft Saved" : "Save Local Draft", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.spatial.creatorStudio.saveDraft")
                .accessibilityIdentifier("hf.creatorStudio.localDraft")

                Button {
                    isInspectorPresented = true
                } label: {
                    HFCreatorStudioAction(title: "Open Inspector", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.spatial.creatorStudio.inspector")
                .accessibilityIdentifier("hf.creatorStudio.inspector")
            }

            Button {
                dismiss()
            } label: {
                HFCreatorStudioAction(title: "Back to Streaming", systemImage: "play.tv.fill")
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("hf.spatial.creatorStudio.backToStreaming")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    @ViewBuilder
    private var selectedToolHandoff: some View {
        switch selectedTool {
        case .social:
            socialCampaignAuthoringWorld
        case .vod:
            vodLaunchChamber
        case .look:
            creativeToolSummary(title: "Look", detail: "Poster direction, color treatment, and mood notes are staged around the project slab.", systemImage: "paintpalette.fill")
        case .trailer:
            creativeToolSummary(title: "Trailer", detail: "Trailer pull and clip placeholders stay local for editorial review.", systemImage: "film.stack.fill")
        case .sound:
            creativeToolSummary(title: "Sound", detail: "Music mood, sonic direction, and mix notes remain local notes.", systemImage: "waveform")
        }
    }

    private func creativeToolSummary(title: String, detail: String, systemImage: String) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.24)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(HFColors.violet.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) tool. \(detail)")
    }

    private var socialCampaignAuthoringWorld: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.violet.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFSpatialRouteBadge(title: "Creator -> Social", accent: HFColors.violet)

                        Text("Social Media Kit")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text(streamingStore.featuredMovie.title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.74)
                            .accessibilityIdentifier("hf.spatial.social.projectTitle")

                        Text("\(selectedSocialFocus.displayName) campaign format")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .accessibilityIdentifier("hf.spatial.social.selectedFormat")
                    }

                    Spacer(minLength: HFSpacing.sm)

                    Button {
                        select(.look)
                    } label: {
                        Label("Back to Creator Studio", systemImage: "chevron.left")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                            .padding(.horizontal, HFSpacing.xs)
                            .frame(height: 34)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.spatial.social.backToStudio")
                    .accessibilityIdentifier("hf.route.socialToCreatorStudio")
                }

                ZStack {
                    socialOpticalBlackSurface
                    socialCampaignPreview
                    if usesSpatialFallbackLayout {
                        VStack {
                            Spacer()
                            socialFocusFallbackRow
                        }
                        .padding(.bottom, HFSpacing.sm)
                    } else {
                        ForEach(HFSocialCampaignFocus.allCases) { focus in
                            socialCreativeObject(focus)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: usesSpatialFallbackLayout ? 420 : 430)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Campaign preview first. Selected format \(selectedSocialFocus.displayName). Five local creative formats.")
                .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
                .accessibilityIdentifier("hf.spatial.social.world")

                HFSpatialActionCluster {
                    HFEnergyAction(title: "Review Campaign", systemImage: "checkmark.seal.fill", style: .gold) {
                        didSaveSocialCampaign = true
                        didSaveLocalDraft = true
                    }
                    .accessibilityIdentifier("hf.spatial.social.reviewCampaign")
                    .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")
                    .accessibilityIdentifier("hf.route.creatorStudioToSocial")

                    HStack(spacing: HFSpacing.sm) {
                        HFEnergyAction(title: didSaveSocialCampaign ? "Campaign Saved" : "Save Local Campaign", systemImage: "square.and.arrow.down", style: .glass) {
                            didSaveSocialCampaign = true
                            didSaveLocalDraft = true
                        }
                        .accessibilityIdentifier("hf.spatial.social.saveDraft")

                        HFEnergyAction(title: "Open Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                            isSocialInspectorPresented = true
                        }
                        .accessibilityIdentifier("hf.spatial.social.inspector")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.spatial.social")
        .hfSpatialFocalHandoff("hf.spatial.handoff.creatorToSocial")
    }

    private var socialOpticalBlackSurface: some View {
        RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        HFColors.violet.opacity(0.28),
                        reduceTransparency ? Color.black : HFColors.background.opacity(0.98),
                        Color.black
                    ],
                    center: .center,
                    startRadius: 30,
                    endRadius: 390
                )
            )
            .overlay(
                HFDepthContourOverlay(color: HFColors.violet.opacity(0.78), lineWidth: 0.8)
                    .opacity(0.34)
                    .padding(.horizontal, -30)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            .accessibilityHidden(true)
    }

    private var socialFocusFallbackRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(HFSocialCampaignFocus.allCases) { focus in
                    socialCreativeObject(focus, usesSpatialOffset: false)
                }
            }
            .padding(.horizontal, HFSpacing.sm)
        }
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private var socialCampaignPreview: some View {
        ZStack(alignment: .bottomLeading) {
            projectArtwork(for: streamingStore.featuredMovie)
                .frame(width: 214, height: 316)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.28), Color.black.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.64), lineWidth: 1.2)
                )
                .shadow(color: HFColors.violet.opacity(reduceMotion ? 0 : 0.35), radius: reduceMotion ? 0 : 30, x: 0, y: 18)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(selectedSocialFocus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.violet.opacity(0.95))
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text(streamingStore.featuredMovie.title)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)

                socialPreviewContent
            }
            .frame(maxWidth: 182, alignment: .leading)
            .padding(HFSpacing.md)
            .padding(.bottom, selectedSocialFocus == .platforms ? 58 : 0)
        }
        .scaleEffect(reduceMotion ? 1 : 1.02)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Dominant vertical campaign preview. \(selectedSocialFocus.displayName). \(selectedSocialFocus.purpose).")
        .accessibilityIdentifier("hf.spatial.social.preview")
    }

    @ViewBuilder
    private var socialPreviewContent: some View {
        Group {
            switch selectedSocialFocus {
            case .poster:
                Text("Key-art crop. Title lockup. Local composition note.")
                    .accessibilityIdentifier("hf.social.posterPreview")
            case .reel:
                Text("Vertical clip placeholder. 00:18 local trailer note.")
                    .accessibilityIdentifier("hf.social.reelPreview")
            case .caption:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tonight on HighFive: choose the scene you would replay first.")
                        .accessibilityIdentifier("hf.social.captionPreview")
                    Text("2 alternate local drafts")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.social.captionDrafts")
                }
            case .story:
                Text("Vertical story composition. Premiere callout. Local-only preview.")
                    .accessibilityIdentifier("hf.social.storyPreview")
            case .platforms:
                Text("Campaign variants staged locally. Readiness stays in the inspector.")
                    .accessibilityIdentifier("hf.social.platformPreview")
            }
        }
        .font(HFTypography.caption)
        .foregroundStyle(HFColors.textPrimary)
        .lineLimit(3)
        .minimumScaleFactor(0.74)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func socialCreativeObject(_ focus: HFSocialCampaignFocus, usesSpatialOffset: Bool = true) -> some View {
        let isSelected = selectedSocialFocus == focus
        let offset = usesSpatialOffset ? socialFocusOffset(focus, isSelected: isSelected) : .zero

        return Button {
            withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
                selectedSocialFocus = focus
            }
        } label: {
            VStack(spacing: HFSpacing.xxs) {
                Image(systemName: focus.systemImage)
                    .font(.system(size: isSelected ? 20 : 17, weight: .black))
                    .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                    .frame(width: isSelected ? 54 : 46, height: isSelected ? 54 : 46)
                    .background(isSelected ? AnyShapeStyle(LinearGradient(colors: [HFColors.violet, HFColors.gold.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.08)))
                    .clipShape(Circle())

                Text(focus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if isSelected || differentiateWithoutColor {
                    Label(isSelected ? "Selected" : "Available", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(HFTypography.micro)
                        .foregroundStyle(isSelected ? HFColors.gold : HFColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                }
            }
            .frame(width: 88, height: 88)
            .background(isSelected ? HFColors.violet.opacity(0.18) : Color.black.opacity(0.22))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? HFColors.violet.opacity(0.62) : HFColors.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .offset(offset)
        .hfSpatialSelectionTreatment(
            isSelected: isSelected,
            accent: HFColors.violet,
            reduceMotion: reduceMotion,
            differentiateWithoutColor: differentiateWithoutColor
        )
        .accessibilityLabel("\(focus.displayName), \(isSelected ? "selected" : "not selected"). \(focus.purpose)")
        .accessibilityIdentifier(focus.accessibilityIdentifier)
    }

    private func socialFocusOffset(_ focus: HFSocialCampaignFocus, isSelected: Bool) -> CGSize {
        let selectedLift: CGFloat = isSelected && !reduceMotion ? -10 : 0
        switch focus {
        case .poster: return CGSize(width: -118, height: -154 + selectedLift)
        case .reel: return CGSize(width: 118, height: -154 + selectedLift)
        case .caption: return CGSize(width: -128, height: 4 + selectedLift)
        case .story: return CGSize(width: 128, height: 4 + selectedLift)
        case .platforms: return CGSize(width: 0, height: 162 + selectedLift)
        }
    }

    private var socialCampaignInspector: some View {
        HFSpatialInspectorChrome(
            title: "Campaign Inspector",
            detail: "Local Draft, provider readiness, and platform boundaries stay secondary to the campaign preview.",
            accent: HFColors.violet
        ) {
            VStack(spacing: HFSpacing.xs) {
                HFCreatorStudioReadinessRow(title: "Local Draft", detail: didSaveSocialCampaign ? "Campaign saved locally for review." : "Campaign remains editable locally.", status: "Local", systemImage: "pencil", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.localDraft")
                HFCreatorStudioReadinessRow(title: "Provider-ready", detail: "Campaign fields are staged without provider behavior.", status: "Ready", systemImage: "checkmark.seal.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.providerReady")
                HFCreatorStudioReadinessRow(title: "Not Connected Yet", detail: "No provider account is connected for this local campaign.", status: "Boundary", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.social.notConnected")
                HFCreatorStudioReadinessRow(title: "Caption drafts", detail: "\(captionDraftCards.count) local caption drafts remain available.", status: "Local", systemImage: "text.quote", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Poster placeholder", detail: "Key-art crop remains a local composition preview.", status: "Local", systemImage: "photo.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Reel placeholder", detail: "Vertical moving-image placeholder remains local.", status: "Local", systemImage: "film.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Story placeholder", detail: "Story composition remains local-only.", status: "Local", systemImage: "rectangle.portrait.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "Instagram readiness", detail: "Poster and caption planning only.", status: "Provider-ready", systemImage: "camera.viewfinder", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.instagramReadiness")
                HFCreatorStudioReadinessRow(title: "TikTok readiness", detail: "Reel placeholder and caption planning only.", status: "Provider-ready", systemImage: "music.note", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.tiktokReadiness")
                HFCreatorStudioReadinessRow(title: "YouTube Shorts readiness", detail: "Short-form preview planning only.", status: "Provider-ready", systemImage: "play.rectangle.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.youtubeShortsReadiness")
                HFCreatorStudioReadinessRow(title: "X / Threads readiness", detail: "Prompt and copy planning only.", status: "Provider-ready", systemImage: "text.bubble.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.threadsReadiness")
                HFCreatorStudioReadinessRow(title: "No live publishing", detail: "No posting, scheduling, upload, or platform action is active.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.social.noLivePublishing")
                HFCreatorStudioReadinessRow(title: "No provider account connected", detail: "Campaign authoring remains local and provider-free.", status: "Safe", systemImage: "person.crop.circle.badge.xmark", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.social.noProviderConnection")
                HFCreatorStudioReadinessRow(title: "Campaign remains local", detail: "No export, file picker, upload, or media write is active.", status: "Local", systemImage: "lock.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.social.campaignLocalOnly")
            }
        }
        .accessibilityIdentifier("hf.social.inspector")
    }

    private var launchProSurface: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.44)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                launchProHero
                launchProSpotlightPanel

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    launchCommandDashboard
                    releaseReadinessMatrix
                    distributionPipeline
                    platformTargetsPreview
                    campaignTimeline
                    premiereSchedulingPreview
                    marketingAssetsBoard
                    trailerPosterSynopsisChecklist
                    vodPackageReview
                    pricingPreview
                    territoryPreview
                    rightsClearancePreview
                    analyticsForecastPreview
                    creatorRevenuePreview
                    launchControlRoom
                    finalReviewGate
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch and Distribution Center Pro. Local release review for \(streamingStore.featuredMovie.title).")
    }

    private var launchProHero: some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .fill(HFColors.goldGradient)
                Image(systemName: "sparkles.tv.fill")
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Launch & Distribution Center Pro")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text("Studio release command surface for local review, draft readiness, mock platform targets, and final gate planning.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: HFSpacing.xs) {
                    HFCreatorStudioPill(title: "Draft", isActive: true)
                    HFCreatorStudioPill(title: "Visual only")
                    HFCreatorStudioPill(title: "Not released")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch and Distribution Center Pro. Draft, visual only, not released.")
    }

    @ViewBuilder
    private var launchProSpotlightPanel: some View {
        switch launchProSpotlight {
        case .dashboard:
            launchProSpotlight(
                title: "Launch Command Dashboard",
                detail: "Release state, target boards, and final review stay organized as local preview signals.",
                systemImage: "rectangle.grid.2x2.fill",
                accent: HFColors.gold,
                identifier: "hf.launch.pro.dashboard"
            ) {
                HStack(spacing: HFSpacing.xs) {
                    launchProStat(title: "Release", value: "Draft")
                    launchProStat(title: "Targets", value: "Mock")
                    launchProStat(title: "Gate", value: "Review")
                }
            }
        case .pipeline:
            launchProSpotlight(
                title: "Distribution Pipeline",
                detail: "Trailer, artwork, copy, pricing note, territories, and rights checks are staged visually.",
                systemImage: "point.3.connected.trianglepath.dotted",
                accent: HFColors.cyanGlow,
                identifier: "hf.launch.pro.distributionPipeline"
            ) {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    launchProCapsule("Package", active: true, accent: HFColors.gold)
                    launchProCapsule("Targets", active: true, accent: HFColors.cyanGlow)
                    launchProCapsule("Final gate", active: false, accent: HFColors.violet)
                }
            }
        case .platforms:
            platformTargetsPreview
        case .campaign:
            campaignTimeline
        case .assets:
            marketingAssetsBoard
        case .finalGate:
            finalReviewGate
        }
    }

    private var launchCommandDashboard: some View {
        launchProModule(
            title: "Launch Command",
            detail: "Release readiness, target boards, and local final review.",
            systemImage: "rectangle.grid.2x2.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.dashboard"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Mode", value: "Draft")
                launchProStat(title: "Review", value: "Local")
            }
        }
    }

    private var releaseReadinessMatrix: some View {
        launchProModule(
            title: "Readiness Matrix",
            detail: "Local checks only.",
            systemImage: "checklist.checked",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.readinessMatrix"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                launchProCapsule("Trailer", active: true, accent: HFColors.gold)
                launchProCapsule("Poster", active: true, accent: HFColors.gold)
                launchProCapsule("Synopsis", active: true, accent: HFColors.gold)
            }
        }
    }

    private var distributionPipeline: some View {
        launchProModule(
            title: "Distribution Pipeline",
            detail: "Package, target preview, campaign board, and review gate stay local.",
            systemImage: "arrow.triangle.branch",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.distributionPipeline"
        ) {
            HStack(spacing: 6) {
                launchProStep("01")
                launchProStep("02")
                launchProStep("03")
                launchProStep("04", muted: true)
            }
        }
    }

    private var platformTargetsPreview: some View {
        launchProModule(
            title: "Platform Targets",
            detail: "Mock target cards keep storefront, VOD, premiere, and campaign visual.",
            systemImage: "square.grid.2x2.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.platformTargets"
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                launchProMiniTarget("VOD")
                launchProMiniTarget("Store")
                launchProMiniTarget("Premiere")
                launchProMiniTarget("Social")
            }
        }
    }

    private var campaignTimeline: some View {
        launchProModule(
            title: "Campaign Timeline",
            detail: "Key art, trailer tease, premiere reminder, and release review beats remain planned locally.",
            systemImage: "timeline.selection",
            accent: HFColors.violet,
            identifier: "hf.launch.pro.campaignTimeline"
        ) {
            VStack(alignment: .leading, spacing: 4) {
                launchTimelineRow("Key art", "Planned")
                launchTimelineRow("Trailer tease", "Draft")
                launchTimelineRow("Review gate", "Local")
            }
        }
    }

    private var premiereSchedulingPreview: some View {
        launchProModule(
            title: "Premiere Scheduling Preview",
            detail: "A visual premiere window keeps date planning separate from external date systems.",
            systemImage: "clock.badge.checkmark.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.premiereScheduling"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Window", value: "Fri")
                launchProStat(title: "State", value: "Planned")
            }
        }
    }

    private var marketingAssetsBoard: some View {
        launchProModule(
            title: "Marketing Assets Board",
            detail: "Poster crop, trailer card, synopsis copy, and campaign note are grouped for local review.",
            systemImage: "photo.on.rectangle.angled",
            accent: HFColors.violet,
            identifier: "hf.launch.pro.marketingAssets"
        ) {
            HStack(spacing: 6) {
                launchAssetTile("Poster", accent: HFColors.gold)
                launchAssetTile("Trailer", accent: HFColors.cyanGlow)
                launchAssetTile("Copy", accent: HFColors.violet)
            }
        }
    }

    private var trailerPosterSynopsisChecklist: some View {
        launchProModule(
            title: "Trailer / Poster / Synopsis Checklist",
            detail: "Three core release assets stay staged as review-ready visual checks.",
            systemImage: "checkmark.rectangle.stack.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.assetChecklist"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                launchCheckRow("Trailer frame")
                launchCheckRow("Poster lockup")
                launchCheckRow("Synopsis copy")
            }
        }
    }

    private var vodPackageReview: some View {
        launchProModule(
            title: "VOD Package Review",
            detail: "Trailer, poster, synopsis, access note, and release focus remain tied to the VOD chamber.",
            systemImage: "play.rectangle.on.rectangle.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.vodReview"
        ) {
            Button {
                selectedVODFocus = .release
            } label: {
                HFCreatorStudioAction(title: "Review VOD", systemImage: "play.rectangle.on.rectangle.fill")
            }
            .buttonStyle(.plain)
        }
    }

    private var pricingPreview: some View {
        launchProModule(
            title: "Pricing Preview",
            detail: "Visual pricing tiers remain draft notes without commerce behavior.",
            systemImage: "tag.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.pricingPreview"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Rent", value: "$4.99")
                launchProStat(title: "Own", value: "$14")
            }
        }
    }

    private var territoryPreview: some View {
        launchProModule(
            title: "Territory Preview",
            detail: "Market regions are visual planning chips for local review.",
            systemImage: "globe.americas.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.territoryPreview"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProCapsule("US", active: true, accent: HFColors.cyanGlow)
                launchProCapsule("CA", active: true, accent: HFColors.cyanGlow)
                launchProCapsule("UK", active: false, accent: HFColors.cyanGlow)
            }
        }
    }

    private var rightsClearancePreview: some View {
        launchProModule(
            title: "Rights & Clearance Preview",
            detail: "Clearance checkpoints are read-only visual review notes.",
            systemImage: "doc.badge.gearshape.fill",
            accent: HFColors.violet,
            identifier: "hf.launch.pro.rightsClearance"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                launchCheckRow("Music note")
                launchCheckRow("Artwork note")
                launchCheckRow("Talent note")
            }
        }
    }

    private var analyticsForecastPreview: some View {
        launchProModule(
            title: "Analytics Forecast Preview",
            detail: "Local forecast cards show interest, saves, and room energy as mock planning signals.",
            systemImage: "chart.line.uptrend.xyaxis",
            accent: HFColors.cyanGlow,
            identifier: "hf.launch.pro.analyticsForecast"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Saves", value: "\(max(18, streamingStore.savedMovieIDs.count * 8))")
                launchProStat(title: "Energy", value: "High")
            }
        }
    }

    private var creatorRevenuePreview: some View {
        launchProModule(
            title: "Creator Revenue Preview",
            detail: "Visual revenue cards stay planning-only and do not activate commerce flows.",
            systemImage: "dollarsign.circle.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.creatorRevenue"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProStat(title: "Gross", value: "Mock")
                launchProStat(title: "Share", value: "Plan")
            }
        }
    }

    private var launchControlRoom: some View {
        launchProModule(
            title: "Launch Control Room",
            detail: "Final checks, room handoff, VOD review, and campaign readiness are collected in one board.",
            systemImage: "slider.horizontal.3",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.controlRoom"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProCapsule("Room", active: true, accent: HFColors.cyanGlow)
                launchProCapsule("VOD", active: true, accent: HFColors.gold)
                launchProCapsule("Campaign", active: true, accent: HFColors.violet)
            }
        }
    }

    private var finalReviewGate: some View {
        launchProModule(
            title: "Final Review Gate",
            detail: "A locked local gate confirms draft readiness before any future release workflow.",
            systemImage: "lock.shield.fill",
            accent: HFColors.gold,
            identifier: "hf.launch.pro.finalReviewGate"
        ) {
            HStack(spacing: HFSpacing.xs) {
                launchProCapsule("Visual only", active: true, accent: HFColors.gold)
                launchProCapsule("Not released", active: false, accent: HFColors.violet)
            }
        }
    }

    private func launchProSpotlight<Content: View>(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        launchProModule(
            title: title,
            detail: detail,
            systemImage: systemImage,
            accent: accent,
            identifier: identifier,
            content: content
        )
        .background(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .fill(accent.opacity(0.06))
        )
    }

    private func launchProModule<Content: View>(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(accent == HFColors.gold ? .black : accent)
                    .frame(width: 42, height: 42)
                    .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.16)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.70)
                    Text(detail)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.70)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
        .accessibilityIdentifier(identifier)
    }

    private func launchProStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func launchProCapsule(_ title: String, active: Bool, accent: Color) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(active ? .black : HFColors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .padding(.horizontal, HFSpacing.xs)
            .frame(height: 28)
            .background(active ? AnyShapeStyle(accent == HFColors.gold ? HFColors.goldGradient : LinearGradient(colors: [accent.opacity(0.92), accent.opacity(0.58)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.07)))
            .clipShape(Capsule())
    }

    private func launchProStep(_ title: String, muted: Bool = false) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(muted ? HFColors.textSecondary : .black)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(muted ? AnyShapeStyle(Color.white.opacity(0.08)) : AnyShapeStyle(HFColors.cyanGlow.opacity(0.88)))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func launchProMiniTarget(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(HFColors.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(HFColors.cyanGlow.opacity(0.16))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(HFColors.cyanGlow.opacity(0.24), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func launchTimelineRow(_ title: String, _ state: String) -> some View {
        HStack {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
            Spacer(minLength: HFSpacing.xs)
            Text(state)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
    }

    private func launchAssetTile(_ title: String, accent: Color) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(accent.opacity(0.28))
                .frame(height: 36)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
        }
        .frame(maxWidth: .infinity)
    }

    private func launchCheckRow(_ title: String) -> some View {
        Label(title, systemImage: "checkmark.seal.fill")
            .font(HFTypography.micro)
            .foregroundStyle(HFColors.textSecondary)
            .lineLimit(1)
            .minimumScaleFactor(0.70)
    }

    private var vodLaunchChamber: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFSpatialRouteBadge(title: "Creator -> VOD", accent: HFColors.gold)

                        Text("VOD Launch Chamber")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .textCase(.uppercase)
                            .tracking(1.2)

                        Text(streamingStore.featuredMovie.title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.74)
                            .accessibilityIdentifier("hf.spatial.vod.projectTitle")

                        Text(selectedVODFocus == .release ? "Release readiness focus" : "\(selectedVODFocus.displayName) release focus")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .accessibilityIdentifier("hf.spatial.vod.selectedFocus")
                    }

                    Spacer(minLength: HFSpacing.sm)

                    Button {
                        select(.look)
                    } label: {
                        Label("Back to Creator Studio", systemImage: "chevron.left")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.70)
                            .padding(.horizontal, HFSpacing.xs)
                            .frame(height: 34)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.vod.backToStudio")
                    .accessibilityIdentifier("hf.route.vodToCreatorStudio")
                }

                ZStack {
                    vodOpticalBlackSurface
                    vodReleaseCore
                    if usesSpatialFallbackLayout {
                        VStack {
                            Spacer()
                            vodFocusFallbackRow
                        }
                        .padding(.bottom, HFSpacing.sm)
                    } else {
                        ForEach(HFVODReleaseFocus.allCases) { focus in
                            vodReleaseObject(focus)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: usesSpatialFallbackLayout ? 430 : 452)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Release core first. Selected focus \(selectedVODFocus.displayName). Five local VOD release focuses.")
                .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
                .accessibilityIdentifier("hf.spatial.vod.chamber")

                HFSpatialActionCluster {
                    HFEnergyAction(title: "Review Release", systemImage: "checkmark.seal.fill", style: .gold) {
                        didSaveVODPackage = true
                        didSaveLocalDraft = true
                    }
                    .accessibilityIdentifier("hf.vod.reviewRelease")
                    .accessibilityIdentifier("hf.creatorStudio.packageVOD")
                    .accessibilityIdentifier("hf.route.creatorStudioToVOD")

                    HStack(spacing: HFSpacing.sm) {
                        HFEnergyAction(title: didSaveVODPackage ? "Package Saved" : "Save Local Package", systemImage: "square.and.arrow.down", style: .glass) {
                            didSaveVODPackage = true
                            didSaveLocalDraft = true
                        }
                        .accessibilityIdentifier("hf.vod.saveDraft")

                        HFEnergyAction(title: "Open Inspector", systemImage: "slider.horizontal.3", style: .glass) {
                            isVODInspectorPresented = true
                        }
                        .accessibilityIdentifier("hf.vod.inspector")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.spatial.vod")
        .hfSpatialFocalHandoff("hf.spatial.handoff.creatorToVOD")
    }

    private var vodOpticalBlackSurface: some View {
        RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        HFColors.gold.opacity(0.22),
                        HFColors.violet.opacity(0.16),
                        reduceTransparency ? Color.black : HFColors.background.opacity(0.98),
                        Color.black
                    ],
                    center: .center,
                    startRadius: 24,
                    endRadius: 410
                )
            )
            .overlay(
                HFDepthContourOverlay(color: HFColors.gold.opacity(0.70), lineWidth: 0.78)
                    .opacity(0.28)
                    .padding(.horizontal, -36)
            )
            .overlay(
                Circle()
                    .trim(from: 0.08, to: 0.86)
                    .stroke(
                        LinearGradient(
                            colors: [HFColors.gold.opacity(0.62), HFColors.violet.opacity(0.28), Color.white.opacity(0.10)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 1.2, lineCap: .round)
                    )
                    .frame(width: 286, height: 286)
                    .rotationEffect(.degrees(reduceMotion ? 0 : -12))
                    .opacity(0.78)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
            .accessibilityHidden(true)
    }

    private var vodFocusFallbackRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(HFVODReleaseFocus.allCases) { focus in
                    vodReleaseObject(focus, usesSpatialOffset: false)
                }
            }
            .padding(.horizontal, HFSpacing.sm)
        }
        .accessibilityIdentifier("hf.spatial.accessibility.largeType")
    }

    private var vodReleaseCore: some View {
        ZStack(alignment: .bottomLeading) {
            projectArtwork(for: streamingStore.featuredMovie)
                .frame(width: 226, height: 318)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.24), Color.black.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(HFColors.gold.opacity(0.72), lineWidth: 1.3)
                )
                .shadow(color: HFColors.gold.opacity(reduceMotion ? 0 : 0.34), radius: reduceMotion ? 0 : 28, x: 0, y: 20)
                .shadow(color: HFColors.violet.opacity(reduceMotion ? 0 : 0.28), radius: reduceMotion ? 0 : 30, x: 0, y: -8)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(selectedVODFocus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold.opacity(0.96))
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text(streamingStore.featuredMovie.title)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)

                vodReleasePreviewContent
            }
            .frame(maxWidth: 186, alignment: .leading)
            .padding(HFSpacing.md)
            .padding(.bottom, selectedVODFocus == .release ? 46 : 0)
        }
        .scaleEffect(reduceMotion ? 1 : 1.02)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Dominant VOD release core. \(selectedVODFocus.displayName). \(selectedVODFocus.purpose).")
        .accessibilityIdentifier("hf.spatial.vod.core")
    }

    @ViewBuilder
    private var vodReleasePreviewContent: some View {
        Group {
            switch selectedVODFocus {
            case .trailer:
                Text("Trailer frame. 00:42 local pull. Timeline note staged for review.")
                    .accessibilityIdentifier("hf.vod.trailerPreview")
            case .poster:
                Text("Cinematic poster treatment. Title lockup. Local poster-readiness note.")
                    .accessibilityIdentifier("hf.vod.posterPreview")
            case .synopsis:
                VStack(alignment: .leading, spacing: 4) {
                    Text("A compact release synopsis sits inside the chamber.")
                        .accessibilityIdentifier("hf.vod.synopsisPreview")
                    Text("Short copy ready")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.shortSynopsis")
                    Text("Long copy staged locally")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.longSynopsis")
                }
            case .access:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Access boundary review. Local Preview remains available.")
                        .accessibilityIdentifier("hf.vod.accessPreview")
                    Text("Pricing boundary")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.pricingBoundary")
                    Text("Entitlement boundary")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.entitlementBoundary")
                    Text("StoreKit product mapping readiness")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.storeKitMapping")
                    Text("Local Preview fallback")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.localPreviewFallback")
                }
            case .release:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local release review. Provider readiness stays secondary.")
                        .accessibilityIdentifier("hf.vod.releasePreview")
                    Text("Distribution readiness")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.distributionReadiness")
                    Text("Storefront readiness")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.storefrontReadiness")
                    Text("Release package remains local")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .accessibilityIdentifier("hf.vod.releaseLocalOnly")
                }
            }
        }
        .font(HFTypography.caption)
        .foregroundStyle(HFColors.textPrimary)
        .lineLimit(5)
        .minimumScaleFactor(0.72)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func vodReleaseObject(_ focus: HFVODReleaseFocus, usesSpatialOffset: Bool = true) -> some View {
        let isSelected = selectedVODFocus == focus
        let offset = usesSpatialOffset ? vodFocusOffset(focus, isSelected: isSelected) : .zero

        return Button {
            withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.focusAnimation) {
                selectedVODFocus = focus
            }
        } label: {
            VStack(spacing: HFSpacing.xxs) {
                Image(systemName: focus.systemImage)
                    .font(.system(size: isSelected ? 20 : 17, weight: .black))
                    .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                    .frame(width: isSelected ? 54 : 46, height: isSelected ? 54 : 46)
                    .background(isSelected ? AnyShapeStyle(LinearGradient(colors: [HFColors.gold, HFColors.violet.opacity(0.82)], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.white.opacity(0.08)))
                    .clipShape(Circle())

                Text(focus.displayName)
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if isSelected || differentiateWithoutColor {
                    Label(isSelected ? "Selected" : "Available", systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(HFTypography.micro)
                        .foregroundStyle(isSelected ? HFColors.gold : HFColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                }
            }
            .frame(width: 92, height: 88)
            .background(isSelected ? HFColors.gold.opacity(0.16) : Color.black.opacity(0.22))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(isSelected ? HFColors.gold.opacity(0.62) : HFColors.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .offset(offset)
        .hfSpatialSelectionTreatment(
            isSelected: isSelected,
            accent: HFColors.gold,
            reduceMotion: reduceMotion,
            differentiateWithoutColor: differentiateWithoutColor
        )
        .accessibilityLabel("\(focus.displayName), \(isSelected ? "selected" : "not selected"). \(focus.purpose)")
        .accessibilityValue(isSelected ? "Selected" : "Available")
        .accessibilityIdentifier(focus.accessibilityIdentifier)
        .accessibilityIdentifier(focus.routeIdentifier)
    }

    private func vodFocusOffset(_ focus: HFVODReleaseFocus, isSelected: Bool) -> CGSize {
        let selectedLift: CGFloat = isSelected && !reduceMotion ? -10 : 0
        switch focus {
        case .trailer: return CGSize(width: -120, height: -164 + selectedLift)
        case .poster: return CGSize(width: 120, height: -164 + selectedLift)
        case .synopsis: return CGSize(width: -132, height: 6 + selectedLift)
        case .access: return CGSize(width: 132, height: 6 + selectedLift)
        case .release: return CGSize(width: 0, height: 170 + selectedLift)
        }
    }

    private var vodReleaseInspector: some View {
        HFSpatialInspectorChrome(
            title: "Release Inspector",
            detail: "Local Draft, access boundaries, and release readiness stay secondary to the launch chamber.",
            accent: HFColors.gold
        ) {
            VStack(spacing: HFSpacing.xs) {
                HFCreatorStudioReadinessRow(title: "Local Draft", detail: didSaveVODPackage ? "Release package saved locally for review." : "Release package remains editable locally.", status: "Local", systemImage: "pencil", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.localDraft")
                HFCreatorStudioReadinessRow(title: "Provider-ready", detail: "Release fields are staged without provider behavior.", status: "Ready", systemImage: "checkmark.seal.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.providerReady")
                HFCreatorStudioReadinessRow(title: "Not Connected Yet", detail: "Distribution, storefront, and entitlement providers are outside this local chamber.", status: "Boundary", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.notConnected")
                HFCreatorStudioReadinessRow(title: "Trailer readiness", detail: "Trailer frame and duration note are staged locally.", status: "Local", systemImage: "film.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.trailerReadiness")
                HFCreatorStudioReadinessRow(title: "Poster readiness", detail: "Key-art crop and title lockup are ready for local review.", status: "Local", systemImage: "photo.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.posterReadiness")
                HFCreatorStudioReadinessRow(title: "Synopsis readiness", detail: "Short and long synopsis copy remain local.", status: "Local", systemImage: "text.alignleft", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.synopsisReadiness")
                HFCreatorStudioReadinessRow(title: "Pricing boundary", detail: "Access planning is staged without transaction behavior.", status: "Boundary", systemImage: "tag.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.pricingBoundary")
                HFCreatorStudioReadinessRow(title: "Entitlement boundary", detail: "Server validation remains a future provider boundary.", status: "Boundary", systemImage: "checkmark.shield.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.entitlementBoundary")
                HFCreatorStudioReadinessRow(title: "No live VOD provider", detail: "No release provider is active in this local package.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.noLiveProvider")
                HFCreatorStudioReadinessRow(title: "No distribution provider connected", detail: "Distribution readiness is a local review state.", status: "Safe", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.noDistributionProvider")
                HFCreatorStudioReadinessRow(title: "No storefront provider connected", detail: "Storefront readiness is a local review state.", status: "Safe", systemImage: "cart.badge.questionmark", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.vod.noStorefrontProvider")
                HFCreatorStudioReadinessRow(title: "Release package remains local", detail: "No media transfer, file generation, provider session, or transaction path is active.", status: "Local", systemImage: "lock.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.vod.packageLocalOnly")
            }
        }
        .accessibilityIdentifier("hf.vod.inspector")
    }

    private func compactHandoffPanel(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        actionTitle: String,
        actionIdentifier: String,
        routeIdentifier: String,
        action: @escaping () -> Void
    ) -> some View {
        let usesGold = title == "VOD Package"

        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(usesGold ? .black : HFColors.gold)
                        .frame(width: 46, height: 46)
                        .background(usesGold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.34)))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button(action: action) {
                    HFCreatorStudioAction(title: actionTitle, systemImage: systemImage, isPrimary: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(actionIdentifier)
                .accessibilityIdentifier(routeIdentifier)

                HFCreatorStudioReadinessRow(
                    title: "No live publishing",
                    detail: title == "VOD Package" ? "No live VOD provider, storefront, payment, or delivery action is active." : "No social posting, provider account, or platform action is active.",
                    status: "Local only",
                    systemImage: "lock.shield.fill",
                    accent: accent
                )
                .accessibilityIdentifier(title == "VOD Package" ? "hf.creatorStudio.noLiveVODProvider" : "hf.creatorStudio.noLivePublishing")
            }
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title) local handoff. \(detail)")
    }

    private var creatorStudioProHero: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius + 10, strokeColor: HFColors.gold.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Creator Studio Pro",
                    detail: "Local command surface for release planning, social assets, VOD package state, commentary rooms, and creator identity.",
                    systemImage: "wand.and.stars.inverse",
                    accent: HFColors.gold
                )

                creatorIdentityCard
                creatorPublishingSummaryStrip
                creatorProSpotlightPanel
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio Pro dashboard for \(streamingStore.featuredMovie.title)")
        .accessibilityIdentifier("hf.creator.pro.dashboard")
    }

    private var creatorIdentityCard: some View {
        let session = streamingStore.currentSessionRuntime
        return HStack(alignment: .center, spacing: HFSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .fill(HFColors.goldGradient)
                Image(systemName: streamingStore.activeViewingProfile.avatarSymbol)
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(.black)
            }
            .frame(width: 78, height: 78)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(streamingStore.activeViewingProfile.displayName)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text("Creator identity card")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)

                Text("\(session.workspaceTitle) • \(session.permissionSummary)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Text("Current project: \(streamingStore.featuredMovie.title)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: HFSpacing.xs)
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Creator identity card. \(session.displayName). \(session.workspaceTitle). Current project \(streamingStore.featuredMovie.title).")
        .accessibilityIdentifier("hf.creator.pro.identityCard")
        .accessibilityIdentifier("hf.identity.session.creatorWorkspace")
    }

    @ViewBuilder
    private var creatorProSpotlightPanel: some View {
        switch proSpotlight {
        case .dashboard:
            creatorProSpotlight(
                title: "Creator Command Dashboard",
                detail: "A compact operating center for local project status, creative notes, and room handoffs.",
                systemImage: "rectangle.grid.2x2.fill",
                accent: HFColors.gold,
                identifier: "hf.creator.pro.dashboard"
            ) {
                HStack(spacing: HFSpacing.xs) {
                    creatorProStat(title: "Project", value: "Local")
                    creatorProStat(title: "Rooms", value: "3")
                    creatorProStat(title: "Ready", value: "Review")
                }
            }
        case .cms:
            contentManagementSpotlightPanel
        case .pipeline:
            creatorPublishingSpotlightPanel
        case .socialAssets:
            socialAssetKitSection
        case .vodPackage:
            vodPackageStatusSection
        case .analytics:
            analyticsPreviewSection
        case .publishingDashboard:
            creatorPublishingSystemDashboard
        case .publishingQueue:
            publishingQueueSection
        case .publishingReadiness:
            publishingReadinessSection
        case .publishingAudit:
            publishingAuditSection
        case .publishingCalendar:
            publishingCalendarSection
        case .collaborationDashboard:
            creatorCollaborationDashboard
        case .collaborationTeam:
            creatorCollaborationTeamSection
        case .collaborationTasks:
            creatorCollaborationTaskBoardSection
        case .collaborationNotes:
            creatorCollaborationNotesSection
        case .collaborationActivity:
            creatorCollaborationActivitySection
        case .collaborationTimeline:
            creatorCollaborationTimelineSection
        case .seriesDashboard:
            seriesEpisodesDashboard
        case .seriesDetail:
            seriesDetailSection
        case .seriesEpisodes:
            episodeManagementSection
        case .seriesNextEpisode:
            nextEpisodeEngineSection
        case .seriesAnalytics:
            episodeAnalyticsSection
        case .revenueDashboard:
            revenueDashboardSection
        case .revenueTitles:
            titleRevenueSection
        case .revenueAnalytics:
            revenueAnalyticsSection
        case .revenuePayouts:
            payoutPreviewSection
        case .notificationsCenter:
            notificationsCenterSection
        case .activityCenter:
            productActivityCenterSection
        case .notificationPublishing:
            notificationCategorySection("Publishing")
        case .notificationDiscovery:
            notificationCategorySection("Discovery")
        case .notificationSeries:
            notificationCategorySection("Series")
        case .notificationCollaboration:
            notificationCategorySection("Collaboration")
        case .notificationRevenue:
            notificationCategorySection("Revenue")
        case .administrationDashboard:
            administrationDashboardSection
        case .administrationReview:
            contentReviewCenterSection
        case .administrationCreators:
            creatorAdministrationSection
        case .administrationHealth:
            platformHealthSection
        case .administrationModeration:
            moderationQueueSection
        case .administrationOperations:
            operationsDashboardSection
        case .administrationAudit:
            administrationAuditTrailSection
        case .marketplaceDashboard:
            marketplaceDistributionDashboardSection
        case .marketplaceCatalog:
            marketplaceCatalogSection
        case .marketplaceTargets:
            distributionTargetsSection
        case .marketplaceRights:
            rightsPackagesSection
        case .marketplacePackages:
            releasePackagesSection
        case .marketplaceLicensing:
            licensingPreviewSection
        case .marketplaceReadiness:
            distributionReadinessSection
        case .rightsDashboard:
            rightsLicensingDashboardSection
        case .rightsLedger:
            rightsLedgerSection
        case .rightsWindows:
            rightsWindowsSection
        case .rightsTerritories:
            territoryTrackingSection
        case .rightsClearance:
            clearanceTrackingSection
        case .licensingPackages:
            licensingPackagesSection
        case .licensingReadiness:
            rightsReadinessSection
        case .dealPreparation:
            dealPreparationSection
        case .integrationDashboard:
            integrationReadinessDashboardSection
        case .integrationServices:
            serviceRegistrySection
        case .integrationDataSources:
            dataSourceRegistrySection
        case .integrationSync:
            syncReadinessSection
        case .integrationAPI:
            apiReadinessSection
        case .integrationEnvironments:
            environmentProfilesSection
        case .integrationAudit:
            integrationAuditSection
        case .productionBridgeDashboard:
            productionBridgeDashboardSection
        case .productionConnections:
            productionConnectionRegistrySection
        case .productionFeatureFlags:
            productionFeatureFlagsSection
        case .productionServiceMapping:
            productionServiceMappingSection
        case .productionEnvironmentSwitching:
            productionEnvironmentSwitchingSection
        case .productionReadinessReports:
            productionReadinessReportsSection
        case .productionDependencyGraph:
            productionDependencyGraphSection
        case .productionBackendFoundation:
            productionBackendFoundationSection
        case .productionBackendHealth:
            productionBackendHealthSection
        case .productionBackendCatalog:
            productionBackendCatalogSection
        case .productionBackendFallback:
            productionBackendFallbackSection
        case .cloudCatalogSyncDashboard:
            cloudCatalogSyncDashboardSection
        case .cloudCatalogCache:
            cloudCatalogCacheSection
        case .cloudCatalogDelta:
            cloudCatalogDeltaSection
        case .cloudCatalogDiagnostics:
            cloudCatalogDiagnosticsSection
        case .realIdentityDashboard:
            realIdentityAccessDashboardSection
        case .realIdentitySignIn:
            realIdentitySignInSection
        case .realIdentitySession:
            realIdentitySessionSection
        case .realIdentityRoles:
            realIdentityRolesSection
        case .realIdentityDeletion:
            realIdentityDeletionSection
        case .contentBackendDashboard:
            contentBackendFoundationSection
        case .contentBackendRepositories:
            contentBackendRepositoriesSection
        case .contentBackendFetch:
            contentBackendFetchSection
        case .contentBackendPersistence:
            contentBackendPersistenceSection
        case .contentBackendRelationships:
            contentBackendRelationshipsSection
        case .draftWorkspace:
            creatorDraftWorkspaceDashboard
            creatorDraftSyncDashboardSection
            creatorMediaAssetRuntimeSection
        case .draftEditor:
            creatorDraftEditorSection
        case .draftValidation:
            creatorDraftValidationSection
        case .draftCompare:
            creatorDraftCompareSection
        case .draftHistory:
            creatorDraftHistorySection
        case .draftSyncDashboard:
            creatorDraftSyncDashboardSection
        case .draftSyncQueue:
            creatorDraftSyncQueueSection
        case .draftSyncConflict:
            creatorDraftSyncConflictSection
        case .draftSyncRevisions:
            creatorDraftSyncRevisionsSection
        case .uploadWorkflow:
            creatorUploadWorkflowDashboard
        case .uploadSelection:
            creatorUploadAssetSelectionSection
        case .uploadValidation:
            creatorUploadValidationSection
        case .uploadManifest:
            creatorUploadManifestSection
        case .uploadQueue:
            creatorUploadQueueSection
        case .uploadPreflight:
            creatorUploadPreflightSection
        case .projectRuntime:
            creatorProjectRuntimeDashboard
        case .projectManifest:
            creatorProjectManifestSection
        case .projectAssets:
            creatorProjectAssetManifestSection
        case .projectValidation:
            creatorProjectValidationSection
        case .projectReleasePackage:
            creatorProjectReleasePackageSection
        case .projectTimeline:
            creatorProjectTimelineSection
        case .mediaImportRuntime:
            creatorMediaImportRuntimeDashboard
        case .mediaImportQueue:
            creatorMediaImportQueueSection
        case .mediaImportValidation:
            creatorMediaImportValidationSection
        case .mediaRegistration:
            creatorMediaRegistrationSection
        case .manifestUpdates:
            creatorManifestUpdateSection
        case .projectLinking:
            creatorProjectLinkingSection
        case .mediaImportPreflight:
            creatorMediaImportPreflightSection
        case .mediaInspectionPreflight:
            creatorMediaInspectionPreflightSection
        case .mediaInspectionReport:
            creatorMediaInspectionReportSection
        case .mediaInspectionQuarantine:
            creatorMediaInspectionQuarantineSection
        case .localPackageRuntime:
            creatorLocalPackageRuntimeSection
        case .localPackageCreate:
            creatorLocalPackageCreateSection
        case .localPackageHistory:
            creatorLocalPackageHistorySection
        case .localPackageValidation:
            creatorLocalPackageValidationSection
        case .localPackageExport:
            creatorLocalPackageExportSection
        }
    }

    private var creatorStudioProSurface: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            contentManagementSystemSection
            seriesEpisodesDashboard
            creatorPublishingPipelineSection
            creatorPublishingSystemDashboard
            revenueDashboardSection
            notificationsCenterSection
            administrationDashboardSection
            marketplaceDistributionDashboardSection
            rightsLicensingDashboardSection
            integrationReadinessDashboardSection
            productionBridgeDashboardSection
            productionBackendFoundationSection
            cloudCatalogSyncDashboardSection
            realIdentityAccessDashboardSection
            contentBackendFoundationSection
            creatorProjectRuntimeDashboard
            creatorMediaImportRuntimeDashboard
            creatorMediaInspectionPreflightSection
            creatorLocalPackageRuntimeSection
            creatorMediaAssetRuntimeSection
            creatorUploadWorkflowDashboard
            creatorDraftSyncDashboardSection
            creatorDraftWorkspaceDashboard
            creatorCollaborationDashboard

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                contentTypesSection
                collectionManagementSection
                contentStatusSection
                contentRelationshipsSection
                projectPipelineSection
                releaseReadinessSection
                socialAssetKitSection
                vodPackageStatusSection
                analyticsPreviewSection
                launchControlPreviewSection
            }

            publishingQueueSection
            publishingReadinessSection
            publishingCalendarSection
            publishingAuditSection
            seriesDetailSection
            episodeManagementSection
            nextEpisodeEngineSection
            episodeAnalyticsSection
            titleRevenueSection
            revenueAnalyticsSection
            creatorRevenueSummarySection
            payoutPreviewSection
            productActivityCenterSection
            notificationCategorySection("Publishing")
            notificationCategorySection("Series")
            notificationCategorySection("Revenue")
            contentReviewCenterSection
            creatorAdministrationSection
            platformHealthSection
            moderationQueueSection
            operationsDashboardSection
            administrationAuditTrailSection
            marketplaceCatalogSection
            distributionTargetsSection
            rightsPackagesSection
            releasePackagesSection
            licensingPreviewSection
            distributionReadinessSection
            rightsLedgerSection
            rightsWindowsSection
            territoryTrackingSection
            clearanceTrackingSection
            licensingPackagesSection
            rightsReadinessSection
            dealPreparationSection
            serviceRegistrySection
            dataSourceRegistrySection
            syncReadinessSection
            apiReadinessSection
            environmentProfilesSection
            integrationAuditSection
            productionConnectionRegistrySection
            productionFeatureFlagsSection
            productionServiceMappingSection
            productionEnvironmentSwitchingSection
            productionReadinessReportsSection
            productionDependencyGraphSection
            contentBackendRepositoriesSection
            contentBackendFetchSection
            contentBackendPersistenceSection
            contentBackendRelationshipsSection
            creatorProjectManifestSection
            creatorProjectAssetManifestSection
            creatorProjectValidationSection
            creatorProjectReleasePackageSection
            creatorProjectTimelineSection
            creatorMediaImportQueueSection
            creatorMediaImportValidationSection
            creatorMediaRegistrationSection
            creatorManifestUpdateSection
            creatorProjectLinkingSection
            creatorMediaImportPreflightSection
            creatorMediaInspectionReportSection
            creatorMediaInspectionQuarantineSection
            creatorLocalPackageCreateSection
            creatorLocalPackageHistorySection
            creatorLocalPackageValidationSection
            creatorLocalPackageExportSection
            creatorDraftEditorSection
            creatorDraftValidationSection
            creatorMediaAssetRuntimeSection
            creatorUploadAssetSelectionSection
            creatorUploadValidationSection
            creatorUploadManifestSection
            creatorUploadQueueSection
            creatorUploadPreflightSection
            creatorDraftCompareSection
            creatorDraftHistorySection
            creatorCollaborationTeamSection
            creatorCollaborationTaskBoardSection
            creatorCollaborationNotesSection
            creatorCollaborationActivitySection
            creatorCollaborationTimelineSection
            creatorPublishingLibrarySection
            commentaryGatewaySection
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var contentManagementSpotlightPanel: some View {
        creatorProSpotlight(
            title: "Content Management System",
            detail: "Movies, series, episodes, trailers, collections, creators, metadata, status, and relationships are indexed locally.",
            systemImage: "rectangle.stack.badge.person.crop.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.cms.dashboard"
        ) {
            HStack(spacing: HFSpacing.xs) {
                creatorProStat(title: "Records", value: "\(streamingStore.cmsContentRecords.count)")
                creatorProStat(title: "Collections", value: "\(streamingStore.cmsCollections.count)")
                creatorProStat(title: "Relations", value: "\(streamingStore.cmsRelationships.count)")
            }
        }
    }

    private var contentManagementSystemSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius + 6, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Content Management System",
                    detail: "A local content backbone for movies, series, episodes, trailers, collections, creators, metadata, and relationships.",
                    systemImage: "rectangle.stack.badge.person.crop.fill",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    ForEach(HFCMSContentType.allCases) { type in
                        cmsTypeTile(type)
                    }
                }
                .accessibilityIdentifier("hf.cms.contentTypes")

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Metadata Management")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Title, description, genre, tags, runtime, rating, artwork, trailer, creator, collection, series, and related-title fields are represented from local catalog records.")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(HFSpacing.sm)
                .background(Color.black.opacity(0.26))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                .accessibilityIdentifier("hf.cms.metadataManagement")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Content Management System. Local content backbone for movies, series, episodes, trailers, collections, creators, metadata, and relationships.")
        .accessibilityIdentifier("hf.cms.dashboard")
    }

    private var contentTypesSection: some View {
        creatorProSpotlight(
            title: "Content Types",
            detail: "Movies, series, episodes, trailers, collections, and creators share one local catalog model.",
            systemImage: "square.grid.3x2.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.cms.contentTypes"
        ) {
            HStack(spacing: HFSpacing.xs) {
                creatorProStat(title: "Movies", value: "\(cmsCount(.movie))")
                creatorProStat(title: "Series", value: "\(cmsCount(.series))")
                creatorProStat(title: "Episodes", value: "\(cmsCount(.episode))")
            }
        }
    }

    private var collectionManagementSection: some View {
        creatorProSpotlight(
            title: "Collection Management",
            detail: "Horror, crime, drama, documentary, western, premieres, and creator collections are managed locally.",
            systemImage: "rectangle.grid.2x2.fill",
            accent: HFColors.gold,
            identifier: "hf.cms.collectionManagement"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(streamingStore.cmsCollections.prefix(3)) { collection in
                    cmsCompactRow(title: collection.title, detail: "\(collection.movieIDs.count) titles", color: HFColors.gold)
                }
            }
        }
    }

    private var contentStatusSection: some View {
        creatorProSpotlight(
            title: "Content Status",
            detail: "Draft, review, scheduled, published, and archived states are shared with the publishing pipeline.",
            systemImage: "checkmark.seal.fill",
            accent: HFColors.violet,
            identifier: "hf.cms.statusBoard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(streamingStore.cmsStatusCounts) { status in
                    cmsCompactRow(title: status.state.rawValue, detail: "\(status.count) records", color: status.state == .published ? HFColors.gold : HFColors.violet)
                }
            }
        }
    }

    private var contentRelationshipsSection: some View {
        creatorProSpotlight(
            title: "Content Relationships",
            detail: "Movie to creator, collection, series, and related-title relationships power discovery and profiles.",
            systemImage: "point.3.connected.trianglepath.dotted",
            accent: HFColors.cyanGlow,
            identifier: "hf.cms.relationships"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(streamingStore.cmsRelationships.prefix(3)) { relationship in
                    cmsCompactRow(title: relationship.relationship, detail: "\(relationship.source) -> \(relationship.target)", color: HFColors.cyanGlow)
                }
            }
        }
    }

    private func cmsTypeTile(_ type: HFCMSContentType) -> some View {
        let count = cmsCount(type)
        return VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Image(systemName: type.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
                .accessibilityHidden(true)
            Text("\(count)")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
            Text(type.rawValue)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(HFColors.cyanGlow.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(type.rawValue), \(count) records")
    }

    private func cmsCompactRow(title: String, detail: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.70)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func cmsCount(_ type: HFCMSContentType) -> Int {
        streamingStore.cmsContentRecords.filter { $0.type == type }.count
    }

    private var creatorPublishingSummaryStrip: some View {
        HStack(spacing: HFSpacing.xs) {
            creatorProStat(title: "Drafts", value: "\(streamingStore.creatorDraftProjects.count)")
            creatorProStat(title: "Review", value: "\(streamingStore.creatorReviewProjects.count)")
            creatorProStat(title: "Published", value: "\(streamingStore.creatorPublishedProjects.count)")
            creatorProStat(title: "Archived", value: "\(streamingStore.creatorArchivedProjects.count)")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Creator publishing summary. \(streamingStore.creatorDraftProjects.count) drafts, \(streamingStore.creatorReviewProjects.count) in review, \(streamingStore.creatorPublishedProjects.count) published, \(streamingStore.creatorArchivedProjects.count) archived.")
        .accessibilityIdentifier("hf.creator.pipeline.creatorLibrary")
    }

    private var creatorPublishingSystemDashboard: some View {
        creatorProSpotlight(
            title: "Creator Publishing Dashboard",
            detail: "Analytics flows into publishing readiness, queue priority, schedule preview, and audit gates. Local lifecycle only.",
            systemImage: "paperplane.circle.fill",
            accent: HFColors.gold,
            identifier: "hf.publishing.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Queue", value: "\(streamingStore.creatorPublishingQueueRecords.count)")
                    creatorProStat(title: "Ready", value: "\(streamingStore.creatorReadyForReviewProjects.count)")
                    creatorProStat(title: "Planned", value: "\(streamingStore.creatorScheduledProjects.count)")
                    creatorProStat(title: "Visible", value: "\(streamingStore.creatorPublishedProjects.count)")
                }

                Text("Analytics -> Publishing Readiness -> Publishing Queue -> Publishing Audit")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.publishing.analyticsFlow")

                Text("No publish API, upload, provider account, payment, background job, or external service is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.publishing.localOnly")
            }
        }
    }

    private var publishingQueueSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Publishing Queue",
                    detail: "Prioritized local project lifecycle from draft to review, planned release, visible catalog, and archive retention.",
                    systemImage: "list.bullet.rectangle.portrait.fill",
                    accent: HFColors.gold
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.sm) {
                        ForEach(streamingStore.creatorPublishingQueueRecords) { record in
                            publishingQueueCard(record)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.publishing.queue")
    }

    private var publishingReadinessSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Publishing Readiness",
                    detail: "Local readiness consolidates metadata, poster, trailer, artwork, review gate, and discovery connection.",
                    systemImage: "checkmark.seal.fill",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 146), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.creatorPublishingReadinessItems) { item in
                        publishingReadinessCard(item)
                    }
                }

                publishingChecklistPanel
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.publishing.readiness")
    }

    private var publishingChecklistPanel: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Label("Publishing Checklist", systemImage: "checklist")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            ForEach(streamingStore.creatorPublishingChecklistItems) { item in
                publishingChecklistRow(item)
            }
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityIdentifier("hf.publishing.checklist")
    }

    private var publishingCalendarSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Publishing Calendar",
                    detail: "Local calendar preview only. No system calendar integration, notifications, scheduling jobs, or external event creation.",
                    systemImage: "calendar.badge.clock",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorPublishingScheduleItems) { item in
                        publishingCalendarRow(item)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.publishing.calendar")
    }

    private var publishingAuditSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Publishing Audit",
                    detail: "Read-only local safety gate for discovery eligibility, review readiness, and no-live-publishing boundaries.",
                    systemImage: "doc.text.magnifyingglass",
                    accent: HFColors.gold
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.creatorPublishingAuditRecords) { record in
                        publishingAuditCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.publishing.audit")
    }

    private var creatorCollaborationDashboard: some View {
        creatorProSpotlight(
            title: "Creator Collaboration Dashboard",
            detail: "Local team operating layer for owner review, collaborators, project tasks, notes, activity, and timeline context.",
            systemImage: "person.3.sequence.fill",
            accent: HFColors.violet,
            identifier: "hf.collaboration.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Team", value: "\(streamingStore.creatorCollaborationRoster.count)")
                    creatorProStat(title: "Projects", value: "\(streamingStore.creatorProjectTeamRecords.count)")
                    creatorProStat(title: "Tasks", value: "\(streamingStore.creatorCollaborationTasks.count)")
                    creatorProStat(title: "Notes", value: "\(streamingStore.creatorCollaborationNotes.count)")
                }

                Text("Create -> Manage -> Analyze -> Publish -> Collaborate")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.collaboration.workflow")

                Text("Team state is local preview only. No accounts, external approvals, messaging, or transfer behavior is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.collaboration.localOnly")
            }
        }
    }

    private var creatorCollaborationTeamSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Project Teams",
                    detail: "Each local creator project has an owner, collaborators, roles, and a review scope for safe team planning.",
                    systemImage: "person.3.fill",
                    accent: HFColors.violet
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.sm) {
                        ForEach(streamingStore.creatorProjectTeamRecords) { record in
                            collaborationTeamCard(record)
                        }
                    }
                    .padding(.vertical, 2)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.creatorCollaborationRoster) { collaborator in
                        collaboratorRoleCard(collaborator)
                    }
                }
                .accessibilityIdentifier("hf.collaboration.collaborators")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.collaboration.team")
    }

    private var creatorCollaborationTaskBoardSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Task Board",
                    detail: "Local production tasks move through To Do, In Progress, Review, and Complete without external workflow services.",
                    systemImage: "rectangle.3.group.fill",
                    accent: HFColors.gold
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: HFSpacing.sm) {
                        collaborationTaskColumn(status: "To Do")
                        collaborationTaskColumn(status: "In Progress")
                        collaborationTaskColumn(status: "Review")
                        collaborationTaskColumn(status: "Complete")
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.collaboration.taskBoard")
    }

    private var creatorCollaborationNotesSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Notes System",
                    detail: "Project notes, publishing notes, launch notes, and review notes stay attached to local creator workflow context.",
                    systemImage: "note.text",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.creatorCollaborationNotes) { note in
                        collaborationNoteCard(note)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.collaboration.notes")
    }

    private var creatorCollaborationActivitySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Team Activity",
                    detail: "Recent local updates show what changed across readiness, analytics, social assets, and trailer review.",
                    systemImage: "clock.badge.checkmark.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorCollaborationActivity) { activity in
                        collaborationActivityRow(activity)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.collaboration.activity")
    }

    private var creatorCollaborationTimelineSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Project Timeline",
                    detail: "A local production timeline connects create, manage, analyze, publish, and collaboration loops.",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorCollaborationTimeline) { milestone in
                        collaborationTimelineRow(milestone)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.collaboration.timeline")
    }

    private var seriesEpisodesDashboard: some View {
        creatorProSpotlight(
            title: "Series & Episodes System",
            detail: "Local episodic backbone for series, seasons, episodes, next-episode recommendations, creator profiles, discovery, library, and analytics.",
            systemImage: "play.square.stack.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.series.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Series", value: "\(streamingStore.seriesRecords.count)")
                    creatorProStat(title: "Episodes", value: "\(streamingStore.episodeRecords.count)")
                    creatorProStat(title: "Next", value: "\(streamingStore.nextEpisodeRecommendations.count)")
                    creatorProStat(title: "Analytics", value: "\(streamingStore.episodeAnalyticsRecords.count)")
                }

                Text("Series -> Seasons -> Episodes -> Next Episode -> Analytics")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.series.relationshipFlow")

                Text("Episodic data is local catalog structure only. No provider feed, remote catalog mutation, or background processing is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.series.localOnly")
            }
        }
    }

    private var seriesDetailSection: some View {
        let primary = streamingStore.primarySeriesRecord
        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Series Detail Page",
                    detail: "Series hero, season selector, episode list, continue watching, related series, and creator connection share one local model.",
                    systemImage: "rectangle.stack.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text(primary.title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text("\(primary.creatorName) • \(primary.genre) • \(primary.seasons.count) season • \(primary.episodeCount) episodes • \(primary.status.rawValue)")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                    Text(primary.synopsis)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityIdentifier("hf.series.detail.hero")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 146), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.seriesRecords) { series in
                        seriesSummaryCard(series)
                    }
                }
                .accessibilityIdentifier("hf.series.detail.relatedSeries")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.series.detail")
    }

    private var episodeManagementSection: some View {
        let primary = streamingStore.primarySeriesRecord
        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Episode Management",
                    detail: "Episode number, season number, runtime, synopsis, artwork status, and release state are managed locally in CMS.",
                    systemImage: "list.number",
                    accent: HFColors.gold
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.xs) {
                        ForEach(primary.seasons) { season in
                            seasonSelectorPill(season)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .accessibilityIdentifier("hf.series.seasonSelector")

                VStack(spacing: HFSpacing.xs) {
                    ForEach(primary.seasons.flatMap(\.episodes)) { episode in
                        episodeManagementRow(episode, seriesTitle: primary.title)
                    }
                }
                .accessibilityIdentifier("hf.series.episodeList")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.series.episodes")
    }

    private var nextEpisodeEngineSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Next Episode Engine",
                    detail: "Continue Watching now resolves the next local episode from episode progress, season order, and series structure.",
                    systemImage: "forward.frame.fill",
                    accent: HFColors.violet
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.nextEpisodeRecommendations) { recommendation in
                        nextEpisodeRecommendationCard(recommendation)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.series.nextEpisode")
    }

    private var episodeAnalyticsSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Episode Analytics",
                    detail: "Per-episode views, completion, drop-off point, and watch time are computed from local catalog signals.",
                    systemImage: "chart.line.uptrend.xyaxis",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.episodeAnalyticsRecords.prefix(8)) { record in
                        episodeAnalyticsCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.series.analytics")
    }

    private var revenueDashboardSection: some View {
        creatorProSpotlight(
            title: "Creator Revenue Dashboard",
            detail: "Local-only business layer for estimated revenue, source mix, trend, top titles, and creator planning previews.",
            systemImage: "dollarsign.circle.fill",
            accent: HFColors.gold,
            identifier: "hf.revenue.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    ForEach(streamingStore.revenueDashboardMetrics.prefix(4)) { metric in
                        creatorProStat(title: metric.title, value: metric.value)
                    }
                }

                Text("Create -> Publish -> Discover -> Analyze -> Earn")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.revenue.workflow")

                Text("Revenue is an estimate preview computed from local catalog and analytics signals. No external money movement, live settlement, or payout handling is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.revenue.previewOnly")
            }
        }
    }

    private var titleRevenueSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Title Revenue", actionTitle: "Estimate")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.revenueTitleRecords.prefix(8)) { record in
                        titleRevenueCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.revenue.titleRevenue")
    }

    private var revenueAnalyticsSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Revenue Analytics",
                    detail: "Highest earning title, fastest growing title, completion quality, and collection lift are local estimates.",
                    systemImage: "chart.line.uptrend.xyaxis",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.revenueInsights) { insight in
                        revenueInsightCard(insight)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.revenue.analytics")
    }

    private var creatorRevenueSummarySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Creator Revenue", actionTitle: "Summary")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.creatorRevenueSummaries.prefix(6)) { summary in
                        creatorRevenueSummaryCard(summary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.revenue.creatorSummary")
    }

    private var payoutPreviewSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Creator Payout Preview",
                    detail: "Pending, projected, and lifetime creator earnings are planning previews only.",
                    systemImage: "wallet.pass.fill",
                    accent: HFColors.violet
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 152), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.payoutPreviewRecords) { record in
                        payoutPreviewCard(record)
                    }
                }

                Text("Preview only. No external account connection, live settlement, funds movement, tax document, or external ledger is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.revenue.noProcessing")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.revenue.payoutPreview")
    }

    private var notificationsCenterSection: some View {
        creatorProSpotlight(
            title: "Notifications Center",
            detail: "Local notification layer for publishing alerts, discovery activity, series updates, collaboration updates, analytics milestones, and revenue milestones.",
            systemImage: "bell.badge.fill",
            accent: HFColors.gold,
            identifier: "hf.notifications.center"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Items", value: "\(streamingStore.productNotificationRecords.count)")
                    creatorProStat(title: "Activity", value: "\(streamingStore.activityCenterRecords.count)")
                    creatorProStat(title: "Series", value: "\(notificationCount(for: "Series"))")
                    creatorProStat(title: "Revenue", value: "\(notificationCount(for: "Revenue"))")
                }

                Text("Publishing -> Discovery -> Series -> Collaboration -> Revenue")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.notifications.workflow")

                Text("Local activity only. No system delivery registration, remote message service, external delivery channel, or background delivery job is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.notifications.localOnly")
            }
        }
    }

    private var productActivityCenterSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Activity Center",
                    detail: "Unified local timeline for creator work, viewer activity, publishing operations, discovery, series, collaboration, and revenue.",
                    systemImage: "waveform.path.ecg",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.activityCenterRecords) { record in
                        activityCenterCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.notifications.activityCenter")
    }

    private func notificationCategorySection(_ category: String) -> some View {
        let records = streamingStore.productNotificationRecords.filter { $0.category == category }
        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: notificationAccent(for: category).opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "\(category) Activity",
                    detail: "Read-only local \(category.lowercased()) activity surfaced inside HighFive.",
                    systemImage: notificationIcon(for: category),
                    accent: notificationAccent(for: category)
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(records) { record in
                        notificationRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.notifications.\(category.lowercased())")
    }

    private var administrationDashboardSection: some View {
        creatorProSpotlight(
            title: "Platform Administration System",
            detail: "Local governance layer for content review, creator administration, platform health, moderation queue, operations, and audit trail.",
            systemImage: "shield.checkered",
            accent: HFColors.gold,
            identifier: "hf.admin.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Review", value: "\(streamingStore.contentReviewRecords.count)")
                    creatorProStat(title: "Creators", value: "\(streamingStore.creatorAdministrationRecords.count)")
                    creatorProStat(title: "Health", value: "\(streamingStore.platformHealthRecords.count)")
                    creatorProStat(title: "Audit", value: "\(streamingStore.administrationAuditTrailRecords.count)")
                }

                Text("Govern -> Review -> Moderate -> Operate -> Audit")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.admin.workflow")

                Text("Administration is local preview only. No external review system, enforcement system, account action, or hosted workflow is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.admin.localOnly")
            }
        }
    }

    private var contentReviewCenterSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Content Review Center",
                    detail: "Pending review, approved, needs revision, and archived content are surfaced from the local publishing lifecycle.",
                    systemImage: "doc.text.magnifyingglass",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.contentReviewRecords) { record in
                        contentReviewRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.admin.reviewCenter")
    }

    private var creatorAdministrationSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Creator Administration", actionTitle: "Local")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.creatorAdministrationRecords) { record in
                        creatorAdministrationCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.admin.creatorAdministration")
    }

    private var platformHealthSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Platform Health",
                    detail: "Catalog, discovery, series, analytics, revenue, and notification health are computed from local state.",
                    systemImage: "checkmark.seal.fill",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.platformHealthRecords) { record in
                        platformHealthCard(record, identifierPrefix: "hf.admin.health")
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.admin.platformHealth")
    }

    private var moderationQueueSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Moderation Queue",
                    detail: "Flagged content, review queue, policy status, and content audit stay read-only and local.",
                    systemImage: "flag.fill",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.moderationQueueRecords) { record in
                        moderationQueueRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.admin.moderationQueue")
    }

    private var operationsDashboardSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Operations Dashboard",
                    detail: "Publishing, discovery, library, series, revenue, and notifications are visible in one local operating board.",
                    systemImage: "rectangle.3.group.fill",
                    accent: HFColors.gold
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.operationsDashboardRecords) { record in
                        platformHealthCard(record, identifierPrefix: "hf.admin.operations")
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.admin.operationsDashboard")
    }

    private var administrationAuditTrailSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Audit Trail",
                    detail: "Publishing, discovery, series, revenue, and administration events remain inspectable as local records.",
                    systemImage: "list.clipboard.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.administrationAuditTrailRecords) { record in
                        auditTrailRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.admin.auditTrail")
    }

    private var marketplaceDistributionDashboardSection: some View {
        creatorProSpotlight(
            title: "Marketplace & Distribution System",
            detail: "Local planning layer for marketplace catalog, distribution targets, rights packages, release packages, licensing preview, and readiness.",
            systemImage: "bag.badge.plus",
            accent: HFColors.gold,
            identifier: "hf.marketplace.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Catalog", value: "\(streamingStore.marketplaceCatalogRecords.count)")
                    creatorProStat(title: "Targets", value: "\(streamingStore.distributionTargetRecords.count)")
                    creatorProStat(title: "Rights", value: "\(streamingStore.rightsPackageRecords.count)")
                    creatorProStat(title: "Packages", value: "\(streamingStore.releasePackageRecords.count)")
                }

                Text("Publishing -> Revenue -> Marketplace -> Distribution")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.marketplace.workflow")

                Text("Marketplace and distribution are preview planning only. No external sales, rights exchange, delivery channel, or money movement is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.marketplace.localOnly")
            }
        }
    }

    private var marketplaceCatalogSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Marketplace Catalog",
                    detail: "Published, scheduled, and review-ready creator packages are organized for local marketplace planning.",
                    systemImage: "bag.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.marketplaceCatalogRecords) { record in
                        marketplaceCatalogRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.marketplace.catalog")
    }

    private var distributionTargetsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Distribution Targets", actionTitle: "Planning")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.distributionTargetRecords) { record in
                        distributionTargetCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.marketplace.distributionTargets")
    }

    private var rightsPackagesSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Rights Packages",
                    detail: "Rights windows, territory preview, and clearance state stay attached to each local marketplace package.",
                    systemImage: "checkmark.shield.fill",
                    accent: HFColors.violet
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.rightsPackageRecords) { record in
                        rightsPackageCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.marketplace.rightsPackages")
    }

    private var releasePackagesSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Release Packages",
                    detail: "Publishing queue items are packaged for marketplace review with poster, trailer, metadata, and next-step state.",
                    systemImage: "shippingbox.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.releasePackageRecords) { record in
                        releasePackageRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.marketplace.releasePackages")
    }

    private var licensingPreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Licensing Preview", actionTitle: "Estimate")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.licensingPreviewRecords) { record in
                        licensingPreviewCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.marketplace.licensingPreview")
    }

    private var distributionReadinessSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Distribution Readiness",
                    detail: "Marketplace, target, rights, release, and licensing readiness are computed from local product state.",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.distributionReadinessRecords) { record in
                        distributionReadinessCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.marketplace.distributionReadiness")
    }

    private var rightsLicensingDashboardSection: some View {
        creatorProSpotlight(
            title: "Rights & Licensing Operations",
            detail: "Local operating layer for rights ledger, windows, territories, clearance, licensing packages, readiness, and preparation.",
            systemImage: "checkmark.shield.fill",
            accent: HFColors.violet,
            identifier: "hf.rights.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Ledger", value: "\(streamingStore.rightsLedgerRecords.count)")
                    creatorProStat(title: "Windows", value: "\(streamingStore.rightsWindowRecords.count)")
                    creatorProStat(title: "Territories", value: "\(streamingStore.territoryTrackingRecords.count)")
                    creatorProStat(title: "Licensing", value: "\(streamingStore.licensingPackageRecords.count)")
                }

                Text("Publishing -> Revenue -> Marketplace -> Rights -> Licensing -> Distribution")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.rights.workflow")

                Text("Rights and licensing are planning records only. No approval automation, external exchange, or money movement is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.rights.localOnly")
            }
        }
    }

    private var rightsLedgerSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Rights Ledger",
                    detail: "Each marketplace package receives a local ledger row with creator, window, territory, and clearance state.",
                    systemImage: "books.vertical.fill",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.rightsLedgerRecords) { record in
                        rightsLedgerRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.rights.ledger")
    }

    private var rightsWindowsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Rights Windows", actionTitle: "Planning")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.rightsWindowRecords) { record in
                        rightsWindowCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.rights.windows")
    }

    private var territoryTrackingSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Territory Tracking",
                    detail: "Region availability, package counts, and premiere territory planning are local previews.",
                    systemImage: "map.fill",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 146), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.territoryTrackingRecords) { record in
                        territoryTrackingCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.rights.territories")
    }

    private var clearanceTrackingSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Clearance Tracking",
                    detail: "Metadata, poster, trailer, and package clearance reuse existing publishing readiness signals.",
                    systemImage: "checkmark.shield.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.clearanceTrackingRecords) { record in
                        clearanceTrackingRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.rights.clearance")
    }

    private var licensingPackagesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Licensing Packages", actionTitle: "Prepared")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.licensingPackageRecords) { record in
                        licensingPackageCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.rights.licensingPackages")
    }

    private var rightsReadinessSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Licensing Readiness",
                    detail: "Rights ledger, windows, territories, clearance, and licensing package readiness are computed locally.",
                    systemImage: "list.clipboard.fill",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.rightsReadinessRecords) { record in
                        rightsReadinessCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.rights.readiness")
    }

    private var dealPreparationSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Deal Preparation",
                    detail: "Publishing, revenue, marketplace, and distribution context is assembled for local preparation only.",
                    systemImage: "folder.badge.gearshape",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.dealPreparationRecords) { record in
                        dealPreparationRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.rights.dealPreparation")
    }

    private var integrationReadinessDashboardSection: some View {
        creatorProSpotlight(
            title: "Integration Readiness",
            detail: "Local bridge from product systems to future infrastructure: services, data sources, sync, API shapes, environments, and audit.",
            systemImage: "point.3.connected.trianglepath.dotted",
            accent: HFColors.cyanGlow,
            identifier: "hf.integration.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Services", value: "\(streamingStore.serviceRegistryRecords.count)")
                    creatorProStat(title: "Data", value: "\(streamingStore.dataSourceRegistryRecords.count)")
                    creatorProStat(title: "Sync", value: "\(streamingStore.syncReadinessRecords.count)")
                    creatorProStat(title: "Audit", value: "\(streamingStore.integrationAuditRecords.count)")
                }

                Text("Local Product Systems -> Readiness -> Infrastructure Later")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.integration.workflow")

                Text("Integration readiness is documentation and mapping only. No connector, request, sync job, secret storage, or external mutation is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.integration.localOnly")
            }
        }
    }

    private var serviceRegistrySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Service Registry",
                    detail: "Planned product services are listed by area, dependency, readiness, and local boundary.",
                    systemImage: "gearshape.2.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.serviceRegistryRecords) { record in
                        serviceRegistryRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.integration.serviceRegistry")
    }

    private var dataSourceRegistrySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Data Source Registry", actionTitle: "Local")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.dataSourceRegistryRecords) { record in
                        dataSourceRegistryCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.integration.dataSources")
    }

    private var syncReadinessSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Sync Readiness",
                    detail: "Local state groups are shaped for future sync without creating accounts, jobs, or remote mutation.",
                    systemImage: "arrow.triangle.2.circlepath",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.syncReadinessRecords) { record in
                        syncReadinessRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.integration.syncReadiness")
    }

    private var apiReadinessSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "API Readiness",
                    detail: "Future request and response shapes are named without adding transport behavior.",
                    systemImage: "curlybraces.square.fill",
                    accent: HFColors.violet
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.apiReadinessRecords) { record in
                        apiReadinessCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.integration.apiReadiness")
    }

    private var environmentProfilesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Environment Profiles", actionTitle: "Readiness")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.environmentProfileRecords) { record in
                        environmentProfileCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.integration.environmentProfiles")
    }

    private var integrationAuditSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Integration Audit",
                    detail: "Safety checks confirm the readiness layer does not connect services, move money, sync remotely, or store secrets.",
                    systemImage: "list.clipboard.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.integrationAuditRecords) { record in
                        integrationAuditRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.integration.audit")
    }

    private var productionBridgeDashboardSection: some View {
        creatorProSpotlight(
            title: "Production Infrastructure Bridge",
            detail: "Final readiness map from local product systems to future production systems: connections, flags, service mapping, environments, reports, and dependencies.",
            systemImage: "point.3.connected.trianglepath.dotted",
            accent: HFColors.gold,
            identifier: "hf.productionBridge.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Connections", value: "\(streamingStore.productionConnectionRecords.count)")
                    creatorProStat(title: "Flags", value: "\(streamingStore.productionFeatureFlagRecords.count)")
                    creatorProStat(title: "Reports", value: "\(streamingStore.productionReadinessReportRecords.count)")
                    creatorProStat(title: "Graph", value: "\(streamingStore.productionDependencyGraphRecords.count)")
                }

                Text("Local Systems -> Bridge Plan -> Production Later")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.productionBridge.workflow")

                Text("This bridge is a planning layer only. Connections, environment switching, and dependency maps remain inactive until a future service phase.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.productionBridge.localOnly")
            }
        }
    }

    private var productionConnectionRegistrySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Connection Registry",
                    detail: "Planned production connections are grouped by domain, local handoff, readiness, and boundary.",
                    systemImage: "link.circle.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.productionConnectionRecords) { record in
                        productionConnectionRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBridge.connectionRegistry")
    }

    private var productionFeatureFlagsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Feature Flags", actionTitle: "Local")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.productionFeatureFlagRecords) { record in
                        productionFeatureFlagCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBridge.featureFlags")
    }

    private var productionServiceMappingSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Service Mapping",
                    detail: "Local product systems are mapped to future production domains without activating any external runtime.",
                    systemImage: "arrow.left.arrow.right.square.fill",
                    accent: HFColors.violet
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.productionServiceMappingRecords) { record in
                        productionServiceMappingCard(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBridge.serviceMapping")
    }

    private var productionEnvironmentSwitchingSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Environment Switching", actionTitle: "Locked")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.productionEnvironmentSwitchRecords) { record in
                        productionEnvironmentSwitchCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBridge.environmentSwitching")
    }

    private var productionReadinessReportsSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Readiness Reports",
                    detail: "Production handoff reports summarize what is mapped, what remains local, and what needs future validation.",
                    systemImage: "doc.text.magnifyingglass",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.productionReadinessReportRecords) { record in
                        productionReadinessReportRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBridge.readinessReports")
    }

    private var productionDependencyGraphSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Dependency Graph",
                    detail: "Product dependencies show how publishing, discovery, CMS, library, series, analytics, marketplace, rights, and revenue connect.",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.productionDependencyGraphRecords) { record in
                        productionDependencyGraphRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBridge.dependencyGraph")
    }

    private var contentBackendFoundationSection: some View {
        creatorProSpotlight(
            title: "Real Content Backend Foundation",
            detail: "Canonical content models, local snapshot storage, repository fetches, relationships, and creator draft persistence.",
            systemImage: "externaldrive.fill",
            accent: HFColors.gold,
            identifier: "hf.contentBackend.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Movies", value: "\(streamingStore.contentSnapshot.titleCount)")
                    creatorProStat(title: "Creators", value: "\(streamingStore.contentSnapshot.creatorCount)")
                    creatorProStat(title: "Episodes", value: "\(streamingStore.contentSnapshot.episodeCount)")
                    creatorProStat(title: "Drafts", value: "\(streamingStore.contentSnapshot.draftCount)")
                }

                Text("UI -> Repository -> Local Content Storage")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.contentBackend.repositoryPath")

                Text("P17A stores canonical content locally and exposes repository fetch APIs without media ingest, money movement, sign-in, streaming infrastructure, or external calls.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.contentBackend.boundary")
            }
        }
    }

    private var contentBackendRepositoriesSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Repository Layer",
                    detail: "CatalogRepository, CreatorRepository, PublishingRepository, and LibraryRepository sit between UI and storage.",
                    systemImage: "square.stack.3d.up.fill",
                    accent: HFColors.cyanGlow
                )

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 156), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.contentBackendRepositoryMetrics) { metric in
                        contentBackendMetricCard(metric)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.contentBackend.repositories")
    }

    private var contentBackendFetchSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Read-Only Fetch", actionTitle: "Repository")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.contentBackendFetchMetrics) { metric in
                        contentBackendRailCard(metric)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.contentBackend.readOnlyFetch")
    }

    private var contentBackendPersistenceSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Content Persistence",
                    detail: "The content snapshot stores movies, creators, series, collections, and creator publishing projects locally.",
                    systemImage: "externaldrive.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.contentBackendPersistenceMetrics) { metric in
                        contentBackendMetricRow(metric)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.contentBackend.persistence")
    }

    private var contentBackendRelationshipsSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Content Relationships",
                    detail: "Movies, creators, series, collections, publishing projects, and library activity resolve through canonical IDs.",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.contentBackendRelationshipRecords) { record in
                        contentBackendRelationshipRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.contentBackend.relationships")
    }

    private var productionBackendFoundationSection: some View {
        creatorProSpotlight(
            title: "Production Backend Service Foundation",
            detail: "Read-only catalog service, OpenAPI contract, PostgreSQL-compatible schema, migration fixture, and iOS API client with local fallback.",
            systemImage: "server.rack",
            accent: HFColors.cyanGlow,
            identifier: "hf.productionBackend.foundation"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Titles", value: "\(streamingStore.productionCatalogRuntimeSnapshot.titleCount)")
                    creatorProStat(title: "Creators", value: "\(streamingStore.productionCatalogRuntimeSnapshot.creatorCount)")
                    creatorProStat(title: "Series", value: "\(streamingStore.productionCatalogRuntimeSnapshot.seriesCount)")
                    creatorProStat(title: "Collections", value: "\(streamingStore.productionCatalogRuntimeSnapshot.collectionCount)")
                }

                Text("Views -> HFStreamingStore -> API Client -> Backend Catalog -> Repository fallback")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)

                Text("P29A introduces read-only backend service behavior only. Authentication, uploads, payments, media processing, subscriptions, and publishing mutations remain out of scope.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task {
            await streamingStore.refreshProductionCatalogRuntime()
        }
    }

    private var productionBackendHealthSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Backend Health & Readiness",
                    detail: "The local service exposes health, readiness, OpenAPI, catalog, detail, creator, and collection endpoints with structured JSON responses.",
                    systemImage: "heart.text.square.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.productionCatalogEndpointRows) { row in
                        productionBackendEndpointRow(row)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBackend.health")
    }

    private var productionBackendCatalogSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Read-Only Catalog Runtime", actionTitle: streamingStore.productionCatalogRuntimeSnapshot.statusLabel)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.productionCatalogRuntimeStatusRows) { metric in
                        contentBackendRailCard(metric)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBackend.catalog")
    }

    private var productionBackendFallbackSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Local Fallback Preserved",
                    detail: "If the loopback backend is unavailable or the feature flag is absent, Home, Search, Library, Creator Studio, and Movie Detail continue to read from the local repository stack.",
                    systemImage: "arrow.uturn.backward.circle.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.productionCatalogRuntimeStatusRows) { metric in
                        contentBackendMetricRow(metric)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.productionBackend.fallback")
    }

    private var cloudCatalogSyncDashboardSection: some View {
        creatorProSpotlight(
            title: "Cloud Catalog Content Sync",
            detail: "Hybrid remote/local catalog sync with persisted cursor, content version, tombstone handling, cache invalidation, and stale-while-revalidate fallback.",
            systemImage: "arrow.triangle.2.circlepath.icloud.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.cloudCatalog.sync.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "State", value: streamingStore.cloudCatalogSyncRuntimeSnapshot.statusLabel)
                    creatorProStat(title: "Version", value: "\(streamingStore.cloudCatalogSyncRuntimeSnapshot.catalogVersion)")
                    creatorProStat(title: "Titles", value: "\(streamingStore.cloudCatalogSyncRuntimeSnapshot.titleCount)")
                    creatorProStat(title: "Tombstones", value: "\(streamingStore.cloudCatalogSyncRuntimeSnapshot.tombstoneCount)")
                }

                Text("Views -> HFStreamingStore -> Cloud Catalog Runtime -> ContentQueryEngine -> Repositories -> HFContentBackendSnapshot")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)

                Text(streamingStore.cloudCatalogSyncRuntimeSnapshot.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task {
            await streamingStore.refreshCloudCatalogSync(full: true)
        }
    }

    private var cloudCatalogCacheSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Catalog Cache", actionTitle: "SWR")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(streamingStore.cloudCatalogSyncStatusRows) { metric in
                        contentBackendRailCard(metric)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.cloudCatalog.sync.cache")
    }

    private var cloudCatalogDeltaSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Delta Sync & Tombstones",
                    detail: "Backend deltas apply upserts and removals against the durable cache while preserving creator projects, local media metadata, release packages, and user library state.",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.cloudCatalogSyncStatusRows) { metric in
                        contentBackendMetricRow(metric)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .task {
            await streamingStore.refreshCloudCatalogDeltaSync()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.cloudCatalog.sync.delta")
    }

    private var cloudCatalogDiagnosticsSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Sync Diagnostics",
                    detail: "Cursor, version, cache policy, fallback, and last-error diagnostics for the cloud catalog runtime.",
                    systemImage: "stethoscope",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.cloudCatalogSyncDiagnostics) { record in
                        contentBackendMetricRow(
                            HFContentRepositoryMetric(
                                id: record.id,
                                title: record.title,
                                value: record.status,
                                detail: record.detail,
                                systemImage: record.systemImage
                            )
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.cloudCatalog.sync.diagnostics")
    }

    private var realIdentityAccessDashboardSection: some View {
        let identity = streamingStore.identityAccessRuntimeSnapshot
        return creatorProSpotlight(
            title: "Real Identity & Access",
            detail: "Secure session storage, development sign-in, Sign in with Apple exchange contract, role authorization, session refresh, sign-out, and account deletion request path.",
            systemImage: "person.badge.shield.checkmark.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.identity.access.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "State", value: identity.statusLabel)
                    creatorProStat(title: "Role", value: identity.activeSession?.role.title ?? "Signed Out")
                    creatorProStat(title: "Checks", value: "\(identity.roleChecks.count)")
                    creatorProStat(title: "Audit", value: "\(identity.auditEvents.count)")
                }

                Text("Views -> HFStreamingStore -> Identity Runtime -> Keychain -> Backend Identity Contract")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)

                Text(identity.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var realIdentitySignInSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Sign In & Local Development Mode",
                    detail: "Simulator development identity can create viewer, creator, or admin sessions without production credentials. The Apple exchange endpoint is contract-ready for production setup.",
                    systemImage: "apple.logo",
                    accent: HFColors.cyanGlow
                )

                HStack(spacing: HFSpacing.sm) {
                    Button {
                        streamingStore.signInWithDevelopmentIdentity(role: .creator)
                    } label: {
                        Text("Creator Sign In")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.identity.access.signIn")

                    Button {
                        streamingStore.signInWithDevelopmentIdentity(role: .viewer)
                    } label: {
                        Text("Viewer Sign In")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.identity.access.viewerSignIn")
                }

                identitySessionSummary
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.identity.access.signInPanel")
        .onAppear {
            streamingStore.signInWithDevelopmentIdentity(role: .creator)
        }
    }

    private var realIdentitySessionSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Session Refresh & Restore",
                    detail: "Sessions are stored through Keychain, refreshed with finite expiration windows, and rejected when expired.",
                    systemImage: "key.radiowaves.forward.fill",
                    accent: HFColors.gold
                )

                HStack(spacing: HFSpacing.sm) {
                    Button {
                        streamingStore.refreshIdentityAccessSession()
                    } label: {
                        Text("Refresh Session")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        streamingStore.expireIdentityAccessSessionForQA()
                    } label: {
                        Text("Expire For QA")
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.white.opacity(0.10))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                identitySessionSummary
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.identity.access.session")
        .onAppear {
            if streamingStore.identityAccessRuntimeSnapshot.activeSession == nil {
                streamingStore.signInWithDevelopmentIdentity(role: .creator)
            }
            streamingStore.refreshIdentityAccessSession()
        }
    }

    private var realIdentityRolesSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Role Authorization",
                    detail: "Viewer, creator, and admin permissions resolve through the active identity session. Creator workspace mutations are denied for viewer sessions.",
                    systemImage: "person.2.badge.gearshape.fill",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.identityAccessRoleChecks) { check in
                        identityRoleCheckRow(check)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.identity.access.roles")
        .onAppear {
            if streamingStore.identityAccessRuntimeSnapshot.activeSession == nil {
                streamingStore.signInWithDevelopmentIdentity(role: .creator)
            }
        }
    }

    private var realIdentityDeletionSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Account Deletion Request",
                    detail: "The app records a deletion request path without deleting data until production identity-provider confirmation, retention policy, and backend execution are configured.",
                    systemImage: "trash.slash.fill",
                    accent: HFColors.gold
                )

                Button {
                    streamingStore.requestIdentityAccountDeletion()
                } label: {
                    Text("Record Delete Request")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                identitySessionSummary

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.identityAccessAuditEvents) { event in
                        identityAuditRow(event)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.identity.access.deleteRequest")
        .onAppear {
            if streamingStore.identityAccessRuntimeSnapshot.activeSession == nil {
                streamingStore.signInWithDevelopmentIdentity(role: .creator)
            }
            streamingStore.requestIdentityAccountDeletion()
        }
    }

    private var identitySessionSummary: some View {
        let identity = streamingStore.identityAccessRuntimeSnapshot
        return VStack(spacing: HFSpacing.xs) {
            identityRoleCheckRow(
                HFIdentityAccessRoleCheck(
                    id: "runtime-state",
                    title: "Runtime State",
                    detail: identity.detail,
                    status: identity.statusLabel,
                    systemImage: "person.badge.key.fill"
                )
            )
            if let session = identity.activeSession {
                identityRoleCheckRow(
                    HFIdentityAccessRoleCheck(
                        id: "session",
                        title: session.displayName,
                        detail: "\(session.provider) • \(session.workspaceID) • Expires \(session.expiresAtLabel)",
                        status: session.role.title,
                        systemImage: "key.fill"
                    )
                )
            }
        }
    }

    private var creatorDraftSyncDashboardSection: some View {
        creatorProSpotlight(
            title: "Creator Draft Sync",
            detail: "Draft Workspace now reads and writes through the remote PublishingRepository when the loopback backend is enabled, with local queue fallback preserved.",
            systemImage: "arrow.triangle.2.circlepath.doc.on.clipboard",
            accent: HFColors.cyanGlow,
            identifier: "hf.draftSync.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorDraftSyncStatusRows) { metric in
                        contentBackendMetricCard(metric)
                    }
                }

                Button {
                    Task { await streamingStore.refreshCreatorDraftRemoteSync() }
                } label: {
                    Label("Sync Remote Drafts", systemImage: "arrow.triangle.2.circlepath")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.draftSync.syncButton")
            }
        }
        .task {
            await streamingStore.refreshCreatorDraftRemoteSync()
        }
    }

    private var creatorDraftSyncQueueSection: some View {
        creatorProSpotlight(
            title: "Draft Sync Queue",
            detail: "Queue records show create, update, archive, restore, retry, and merge audit state from the remote publishing persistence layer.",
            systemImage: "tray.and.arrow.up.fill",
            accent: HFColors.gold,
            identifier: "hf.draftSync.queue"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                ForEach(streamingStore.creatorDraftSyncQueueRecords.prefix(8)) { record in
                    draftSyncQueueRow(record)
                }
                if streamingStore.creatorDraftSyncQueueRecords.isEmpty {
                    draftSyncEmptyRow(title: "No queue records yet", detail: streamingStore.creatorDraftSyncRuntimeSnapshot.detail, systemImage: "checkmark.seal.fill")
                }
            }
        }
        .task {
            await streamingStore.refreshCreatorDraftRemoteSync()
            await streamingStore.refreshCreatorDraftSyncQueue()
        }
    }

    private var creatorDraftSyncConflictSection: some View {
        creatorProSpotlight(
            title: "Draft Conflict Handling",
            detail: "Optimistic concurrency is visible: stale base versions produce a conflict instead of silently replacing the server draft.",
            systemImage: "exclamationmark.triangle.fill",
            accent: HFColors.violet,
            identifier: "hf.draftSync.conflict"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorDraftSyncStatusRows) { metric in
                        contentBackendMetricCard(metric)
                    }
                }
                draftSyncEmptyRow(
                    title: streamingStore.creatorDraftSyncRuntimeSnapshot.statusLabel,
                    detail: streamingStore.creatorDraftSyncRuntimeSnapshot.lastError ?? streamingStore.creatorDraftSyncRuntimeSnapshot.detail,
                    systemImage: "point.3.connected.trianglepath.dotted"
                )
                Button {
                    Task { await streamingStore.simulateCreatorDraftRemoteConflict() }
                } label: {
                    Label("Simulate Stale Edit", systemImage: "exclamationmark.triangle.fill")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.draftSync.conflictButton")
            }
        }
        .task {
            await streamingStore.refreshCreatorDraftRemoteSync()
            await streamingStore.simulateCreatorDraftRemoteConflict()
        }
    }

    private var creatorDraftSyncRevisionsSection: some View {
        creatorProSpotlight(
            title: "Draft Revision History",
            detail: "Remote draft revisions and sync audits provide the persistence trail needed for review, restore, and conflict resolution.",
            systemImage: "clock.arrow.circlepath",
            accent: HFColors.cyanGlow,
            identifier: "hf.draftSync.revisions"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                ForEach(streamingStore.creatorDraftRevisionRecords.prefix(8)) { record in
                    draftRevisionRow(record)
                }
                if streamingStore.creatorDraftRevisionRecords.isEmpty {
                    draftSyncEmptyRow(title: "No revisions loaded", detail: streamingStore.creatorDraftSyncRuntimeSnapshot.detail, systemImage: "clock.badge.questionmark.fill")
                }
            }
        }
        .task {
            await streamingStore.refreshCreatorDraftRemoteSync()
            await streamingStore.refreshCreatorDraftRevisionHistory()
        }
    }

    private var creatorDraftWorkspaceDashboard: some View {
        let draft = activeWorkspaceDraft

        return creatorProSpotlight(
            title: "Creator Draft Workspace",
            detail: "Edit durable local drafts through PublishingRepository, validate readiness, compare against the saved snapshot, and review revision context.",
            systemImage: "doc.text.magnifyingglass",
            accent: HFColors.gold,
            identifier: "hf.draftWorkspace.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(draft.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                        Text("\(draft.genre) • \(draft.runtime)")
                            .font(HFTypography.micro.weight(.bold))
                            .foregroundStyle(HFColors.gold)
                            .lineLimit(1)
                        Text(draft.updatedAtLabel)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Text(draft.releaseState.rawValue)
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, HFSpacing.sm)
                        .padding(.vertical, HFSpacing.xxs)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Validation", value: "\(streamingStore.creatorDraftValidationItems(for: editorDraftPreview).filter(\.isComplete).count)/5")
                    creatorProStat(title: "Compare", value: "\(draftCompareRecords.filter { $0.state == "Edited" }.count)")
                    creatorProStat(title: "History", value: "\(streamingStore.creatorDraftHistoryRecords(for: draft).count)")
                }

                Text(draftWorkspaceNotice)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: HFSpacing.xs) {
                    Button {
                        Task { await saveDraftWorkspace() }
                    } label: {
                        HFCreatorStudioAction(title: "Save Draft", systemImage: "externaldrive.fill", isPrimary: true)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.draftWorkspace.save")

                    Button {
                        Task { await createNewWorkspaceDraft() }
                    } label: {
                        HFCreatorStudioAction(title: "New Draft", systemImage: "doc.badge.plus")
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.draftWorkspace.create")
                }
            }
        }
        .onAppear {
            hydrateDraftWorkspaceIfNeeded()
        }
        .task {
            await streamingStore.refreshCreatorDraftRemoteSync()
            if let selectedDraftID {
                await streamingStore.refreshCreatorDraftRevisionHistory(id: selectedDraftID)
            }
        }
    }

    private var creatorDraftEditorSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.3)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Draft Editor",
                    detail: "Metadata, tags, runtime, poster state, trailer state, and artwork state save through the content snapshot.",
                    systemImage: "square.and.pencil",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.sm) {
                    draftTextField(title: "Title", text: $draftTitle, identifier: "hf.draftWorkspace.title")
                    draftTextField(title: "Genre", text: $draftGenre, identifier: "hf.draftWorkspace.genre")
                    draftTextField(title: "Runtime", text: $draftRuntime, identifier: "hf.draftWorkspace.runtime")
                    draftTextField(title: "Tags", text: $draftTags, identifier: "hf.draftWorkspace.tags")
                    draftTextField(title: "Description", text: $draftDescription, identifier: "hf.draftWorkspace.description", lineLimit: 4)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    draftAssetStatusControl(title: "Poster", selection: $draftPosterStatus, identifier: "hf.draftWorkspace.artwork")
                    draftAssetStatusControl(title: "Trailer", selection: $draftTrailerStatus, identifier: "hf.draftWorkspace.trailerState")
                    draftAssetStatusControl(title: "Metadata", selection: $draftMetadataStatus, identifier: "hf.draftWorkspace.metadata")
                    draftAssetStatusControl(title: "Artwork", selection: $draftArtworkStatus, identifier: "hf.draftWorkspace.assetPackage")
                }

                Button {
                    Task { await saveDraftWorkspace() }
                } label: {
                    HFCreatorStudioAction(title: "Save To Repository", systemImage: "externaldrive.fill", isPrimary: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.draftWorkspace.repository")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.draftWorkspace.editor")
        .onAppear {
            hydrateDraftWorkspaceIfNeeded()
        }
    }

    private var creatorMediaAssetRuntimeSection: some View {
        let snapshot = streamingStore.mediaAssetRuntimeSnapshot

        return creatorProSpotlight(
            title: "Creator Media Asset Runtime",
            detail: "Poster, trailer, artwork, and metadata registry records are tracked locally before any upload pipeline exists.",
            systemImage: "rectangle.stack.badge.play.fill",
            accent: HFColors.cyanGlow,
            identifier: "hf.mediaAsset.runtime"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 112), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Assets", value: "\(snapshot.totalAssets)")
                    creatorProStat(title: "Ready", value: "\(snapshot.readyAssets)")
                    creatorProStat(title: "Review", value: "\(snapshot.needsReviewAssets)")
                    creatorProStat(title: "Placeholder", value: "\(snapshot.placeholderAssets)")
                }
                .accessibilityIdentifier("hf.mediaAsset.runtime.summary")

                Text(snapshot.detail)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorMediaAssetRecords.prefix(6)) { record in
                        HFCreatorStudioReadinessRow(
                            title: "\(record.projectTitle) \(record.kind.rawValue)",
                            detail: record.detail,
                            status: record.readiness,
                            systemImage: record.systemImage,
                            accent: record.status == .ready ? HFColors.gold : HFColors.cyanGlow
                        )
                        .accessibilityIdentifier("hf.mediaAsset.registry.\(record.id)")
                    }
                }
            }
        }
    }

    private var creatorProjectRuntimeDashboard: some View {
        let snapshot = streamingStore.creatorProjectRuntimeSnapshot

        return creatorProSpotlight(
            title: "Creator Project Runtime",
            detail: "Canonical project orchestration for project info, assets, metadata, validation, release package, and timeline state.",
            systemImage: "square.stack.3d.up.fill",
            accent: HFColors.gold,
            identifier: "hf.projectRuntime.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Projects", value: "\(snapshot.projectCount)")
                    creatorProStat(title: "Manifests", value: "\(snapshot.manifestCount)")
                    creatorProStat(title: "Packages", value: "\(snapshot.releasePackages)")
                    creatorProStat(title: "Validation", value: snapshot.readinessLabel)
                }

                Text("Project Runtime -> Media Asset Runtime -> Identity Runtime -> Catalog Runtime")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.projectRuntime.path")

                Text("Runtime state is derived locally from the repository snapshot. No import, export, upload, cloud storage, or transfer path is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.projectRuntime.localOnly")
            }
        }
    }

    private var creatorProjectManifestSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Project Manifest",
                    detail: "Each creator project receives canonical project, creator, content, version, created, modified, and status fields.",
                    systemImage: "doc.text.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorProjectManifestRecords.prefix(6)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.title,
                            detail: "\(record.projectID) / \(record.creatorID) / \(record.contentID). \(record.detail)",
                            status: "\(record.version) - \(record.status)",
                            systemImage: record.systemImage,
                            accent: projectRuntimeAccent(for: record.status)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.projectRuntime.manifest")
    }

    private var creatorProjectAssetManifestSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Asset Manifest",
                    detail: "Poster, trailer, artwork, metadata, and thumbnail readiness are unified from the Media Asset Runtime.",
                    systemImage: "rectangle.stack.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorProjectAssetManifestRecords.prefix(6)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "Poster \(record.posterState). Trailer \(record.trailerState). Artwork \(record.artworkState). Metadata \(record.metadataState).",
                            status: record.thumbnailState,
                            systemImage: record.systemImage,
                            accent: record.thumbnailState.contains("Ready") ? HFColors.gold : HFColors.cyanGlow
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.projectRuntime.assetManifest")
    }

    private var creatorProjectValidationSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Project Validation Engine",
                    detail: "One validation pass resolves metadata, poster, trailer, artwork, publishing, and release readiness.",
                    systemImage: "checklist.checked",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorProjectValidationRecords.prefix(6)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "Metadata \(gateLabel(record.metadataComplete)), poster \(gateLabel(record.posterReady)), trailer \(gateLabel(record.trailerReady)), artwork \(gateLabel(record.artworkReady)), publishing \(gateLabel(record.publishingReady)).",
                            status: record.status,
                            systemImage: record.systemImage,
                            accent: record.releaseReady ? HFColors.gold : HFColors.cyanGlow
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.projectRuntime.validation")
    }

    private var creatorProjectReleasePackageSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Release Package",
                    detail: "Release manifest, publishing summary, asset summary, runtime summary, and creator summary are prepared without export.",
                    systemImage: "shippingbox.fill",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorProjectReleasePackageRecords.prefix(6)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "\(record.releaseManifest). \(record.assetSummary). \(record.runtimeSummary). \(record.creatorSummary).",
                            status: record.status,
                            systemImage: record.systemImage,
                            accent: record.status.contains("Ready") ? HFColors.gold : HFColors.cyanGlow
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.projectRuntime.releasePackage")
    }

    private var creatorProjectTimelineSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Project Timeline",
                    detail: "Created, edited, validated, ready, published, and archived milestones are derived from project lifecycle state.",
                    systemImage: "timeline.selection",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorProjectTimelineRecords.prefix(10)) { record in
                        HFCreatorStudioReadinessRow(
                            title: "\(record.projectTitle) - \(record.event)",
                            detail: record.detail,
                            status: record.status,
                            systemImage: record.systemImage,
                            accent: projectRuntimeAccent(for: record.status)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.projectRuntime.timeline")
    }

    private var creatorMediaImportRuntimeDashboard: some View {
        let snapshot = streamingStore.creatorMediaImportRuntimeSnapshot
        let projects = streamingStore.creatorPublishingContents.filter { $0.releaseState != .archived }

        return creatorProSpotlight(
            title: "Local Media Import Runtime",
            detail: "Import selected poster, trailer, artwork, or source files into the app sandbox, then link them to creator project manifests.",
            systemImage: "tray.and.arrow.down.fill",
            accent: HFColors.gold,
            identifier: "hf.mediaImport.runtime"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Sessions", value: "\(snapshot.sessionCount)")
                    creatorProStat(title: "Queued", value: "\(snapshot.queueCount)")
                    creatorProStat(title: "Registered", value: "\(snapshot.registeredAssets)")
                    creatorProStat(title: "Preflight", value: snapshot.readinessLabel)
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Import Target")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)

                    Picker("Project", selection: $selectedImportProjectID) {
                        ForEach(projects) { project in
                            Text(project.title).tag(Optional(project.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("hf.mediaImport.projectPicker")

                    Picker("Asset Kind", selection: $selectedImportKind) {
                        ForEach(HFCreatorMediaAssetKind.allCases) { kind in
                            Text(kind.rawValue).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("hf.mediaImport.kindPicker")

                    HStack(spacing: HFSpacing.xs) {
                        PhotosPicker(
                            selection: $selectedPhotoImportItem,
                            matching: .any(of: [.images, .videos])
                        ) {
                            Label("Photos", systemImage: "photo.on.rectangle.angled")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(HFColors.gold)
                        .accessibilityIdentifier("hf.mediaImport.photosPicker")

                        Button {
                            isFileImporterPresented = true
                        } label: {
                            Label("Files", systemImage: "folder.badge.plus")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("hf.mediaImport.fileImporter")
                    }

                    HStack(spacing: HFSpacing.xs) {
                        Button {
                            cancelLatestImport()
                        } label: {
                            Label("Cancel Last", systemImage: "xmark.circle")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("hf.mediaImport.cancel")

                        Button {
                            retryLatestImport()
                        } label: {
                            Label("Retry Last", systemImage: "arrow.clockwise.circle")
                        }
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("hf.mediaImport.retry")
                    }

                    Text(mediaImportNotice)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("hf.mediaImport.notice")
                }
                .padding(HFSpacing.sm)
                .background(HFColors.surface.opacity(0.72), in: RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                Text("Creator Project Runtime -> Media Import Runtime -> Media Asset Runtime")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.mediaImport.path")

                Text("Files are copied only into Application Support after explicit user selection. No upload, cloud storage, network request, or transcode path is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.mediaImport.localOnly")
            }
        }
        .onAppear {
            if selectedImportProjectID == nil {
                selectedImportProjectID = streamingStore.primaryImportProjectID()
            }
        }
        .onChange(of: selectedPhotoImportItem) { _, item in
            guard let item else { return }
            Task { await importPhotoPickerItem(item) }
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.image, .movie, .mpeg4Movie, .video, .png, .jpeg],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }

    private var creatorMediaImportQueueSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Import Queue",
                    detail: "Queue records are generated from project asset manifests and existing media registry states.",
                    systemImage: "list.bullet.rectangle.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorMediaImportQueueRecords.prefix(8)) { record in
                        HFCreatorStudioReadinessRow(
                            title: "\(record.projectTitle) \(record.assetTitle)",
                            detail: "\(record.source). \(record.detail)",
                            status: record.queueState,
                            systemImage: record.systemImage,
                            accent: mediaImportAccent(for: record.queueState)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaImport.queue")
    }

    private var creatorMediaImportValidationSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Asset Validation",
                    detail: "Registration validation confirms media records can link to project manifests without touching files.",
                    systemImage: "checkmark.shield.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorMediaImportValidationRecords.prefix(8)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.title,
                            detail: record.detail,
                            status: record.status,
                            systemImage: record.systemImage,
                            accent: record.isPassed ? HFColors.gold : HFColors.redAccent
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaImport.validation")
    }

    private var creatorMediaRegistrationSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Media Registration",
                    detail: "Registration connects local media metadata to canonical project manifests before real import exists.",
                    systemImage: "rectangle.stack.badge.plus",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorMediaRegistrationRecords.prefix(8)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "\(record.registry). \(record.linkedManifest). \(record.detail)",
                            status: record.registrationState,
                            systemImage: record.systemImage,
                            accent: mediaImportAccent(for: record.registrationState)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaImport.registration")
    }

    private var creatorManifestUpdateSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Manifest Update Preview",
                    detail: "Project manifests show how registered media metadata would update package state later.",
                    systemImage: "doc.badge.gearshape.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorManifestUpdateRecords.prefix(6)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "\(record.manifestID). \(record.assetSummary). \(record.detail)",
                            status: record.updateState,
                            systemImage: record.systemImage,
                            accent: mediaImportAccent(for: record.updateState)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaImport.manifestUpdates")
    }

    private var creatorProjectLinkingSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Project Linking",
                    detail: "Registration records are linked to project IDs and content IDs inside the local runtime graph.",
                    systemImage: "link.circle.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorProjectLinkRecords.prefix(6)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "\(record.projectID) -> \(record.contentID). \(record.detail)",
                            status: "\(record.linkedAssets) assets - \(record.status)",
                            systemImage: record.systemImage,
                            accent: mediaImportAccent(for: record.status)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaImport.projectLinking")
    }

    private var creatorMediaImportPreflightSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Import Preflight",
                    detail: "Preflight confirms the registration workflow remains local, linked, and free of transfer behavior.",
                    systemImage: "list.clipboard.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorMediaImportPreflightRecords) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.title,
                            detail: record.detail,
                            status: record.result,
                            systemImage: record.systemImage,
                            accent: record.isPassed ? HFColors.gold : HFColors.redAccent
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaImport.preflight")
    }

    private var creatorMediaInspectionPreflightSection: some View {
        let records = streamingStore.mediaInspectionPreflightRecords
        let accepted = records.filter { !$0.isQuarantined && $0.state != .blocked }.count
        let warnings = records.filter { $0.state == .warning }.count
        let quarantined = records.filter(\.isQuarantined).count

        return creatorProSpotlight(
            title: "Media Inspection Preflight",
            detail: "Imported local files are inspected with AVFoundation and ImageIO before packaging. Invalid files are quarantined locally.",
            systemImage: "waveform.badge.magnifyingglass",
            accent: quarantined > 0 ? HFColors.redAccent : HFColors.gold,
            identifier: "hf.mediaInspection.preflight"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Inspected", value: "\(records.count)")
                    creatorProStat(title: "Accepted", value: "\(accepted)")
                    creatorProStat(title: "Warnings", value: "\(warnings)")
                    creatorProStat(title: "Quarantine", value: "\(quarantined)")
                }

                Button {
                    streamingStore.refreshMediaInspectionPreflight()
                } label: {
                    Label("Run Local Preflight", systemImage: "checklist.checked")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("hf.mediaInspection.runPreflight")

                Text("Readiness: \(streamingStore.mediaInspectionReadinessLabel). No transcode, upload, cloud storage, or network inspection is active.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var creatorMediaInspectionReportSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Technical Inspection Report",
                    detail: "Reports persist file size, duration, dimensions, aspect ratio, frame rate, codecs, audio channels, and track presence for imported local media.",
                    systemImage: "doc.text.magnifyingglass",
                    accent: HFColors.cyanGlow
                )

                if streamingStore.mediaInspectionPreflightRecords.isEmpty {
                    HFCreatorStudioReadinessRow(
                        title: "No Imported Media",
                        detail: "Import a poster, artwork, trailer, or source file to create a technical inspection record.",
                        status: "Waiting",
                        systemImage: "tray.and.arrow.down.fill",
                        accent: HFColors.cyanGlow
                    )
                } else {
                    VStack(spacing: HFSpacing.xs) {
                        ForEach(streamingStore.mediaInspectionPreflightRecords.prefix(8)) { record in
                            HFCreatorStudioReadinessRow(
                                title: "\(record.projectTitle) - \(record.kind.rawValue)",
                                detail: "\(record.originalFilename). \(record.summary) \(record.warning.isEmpty ? record.blockingIssue : record.warning)",
                                status: record.state.rawValue,
                                systemImage: mediaInspectionSystemImage(for: record),
                                accent: mediaInspectionAccent(for: record.state)
                            )
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaInspection.report")
    }

    private var creatorMediaInspectionQuarantineSection: some View {
        let quarantined = streamingStore.mediaInspectionPreflightRecords.filter(\.isQuarantined)

        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.redAccent.opacity(0.35)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Asset Quarantine",
                    detail: "Blocking inspection failures stay local and require a new import before the project can use that asset.",
                    systemImage: "lock.trianglebadge.exclamationmark.fill",
                    accent: quarantined.isEmpty ? HFColors.gold : HFColors.redAccent
                )

                if quarantined.isEmpty {
                    HFCreatorStudioReadinessRow(
                        title: "No Quarantined Assets",
                        detail: "All inspected imported assets are usable or carry warnings only.",
                        status: "Clear",
                        systemImage: "checkmark.shield.fill",
                        accent: HFColors.gold
                    )
                } else {
                    VStack(spacing: HFSpacing.xs) {
                        ForEach(quarantined.prefix(6)) { record in
                            HFCreatorStudioReadinessRow(
                                title: "\(record.projectTitle) - \(record.originalFilename)",
                                detail: record.blockingIssue.isEmpty ? "Re-import a readable local media file." : record.blockingIssue,
                                status: "Quarantined",
                                systemImage: "exclamationmark.triangle.fill",
                                accent: HFColors.redAccent
                            )
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.mediaInspection.quarantine")
    }

    private var creatorLocalPackageRuntimeSection: some View {
        let packages = streamingStore.localReleasePackageHistory
        let latest = packages.first

        return creatorProSpotlight(
            title: "Local Packaging Runtime",
            detail: "Validated projects create deterministic local release packages with manifest, asset, validation, rights, creator, and checksum records.",
            systemImage: "shippingbox.and.arrow.backward.fill",
            accent: HFColors.gold,
            identifier: "hf.localPackage.runtime"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Packages", value: "\(packages.count)")
                    creatorProStat(title: "Readiness", value: streamingStore.localReleasePackageReadinessLabel)
                    creatorProStat(title: "Checksum", value: latest?.shortChecksum ?? "None")
                    creatorProStat(title: "Version", value: latest?.packageVersion ?? "No package")
                }

                Text(latest?.packageRelativePath ?? "No local package has been created yet.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var creatorLocalPackageCreateSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Create Local Package",
                    detail: "Writes a release package into Application Support. Source assets are referenced by manifest and are not modified.",
                    systemImage: "shippingbox.fill",
                    accent: HFColors.gold
                )

                HStack(spacing: HFSpacing.xs) {
                    Button {
                        createLocalReleasePackage()
                    } label: {
                        Label("Create Package", systemImage: "shippingbox.and.arrow.backward.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(HFColors.gold)
                    .accessibilityIdentifier("hf.localPackage.create")

                    Button {
                        streamingStore.cleanupLocalReleasePackages()
                        localPackageNotice = "Local package history and package files were cleaned from the app sandbox."
                    } label: {
                        Label("Clean Packages", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("hf.localPackage.cleanup")
                }

                Text(localPackageNotice)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.localPackage.notice")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.localPackage.createPanel")
    }

    private var creatorLocalPackageHistorySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Package History",
                    detail: "Package history persists package path, manifest path, checksum, validation status, and creation time.",
                    systemImage: "clock.arrow.circlepath",
                    accent: HFColors.cyanGlow
                )

                if streamingStore.localReleasePackageHistory.isEmpty {
                    HFCreatorStudioReadinessRow(
                        title: "No Package History",
                        detail: "Create a package to persist local package history.",
                        status: "Waiting",
                        systemImage: "shippingbox",
                        accent: HFColors.cyanGlow
                    )
                } else {
                    VStack(spacing: HFSpacing.xs) {
                        ForEach(streamingStore.localReleasePackageHistory.prefix(6)) { record in
                            HFCreatorStudioReadinessRow(
                                title: record.projectTitle,
                                detail: "\(record.exportManifestRelativePath). Checksum \(record.shortChecksum). \(record.createdAtLabel)",
                                status: record.validationStatus,
                                systemImage: "shippingbox.fill",
                                accent: record.validationStatus == "Validated" ? HFColors.gold : HFColors.cyanGlow
                            )
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.localPackage.history")
    }

    private var creatorLocalPackageValidationSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Import-Back Validation",
                    detail: "Reads the release manifest back from the package directory and validates the required schema fields.",
                    systemImage: "doc.text.magnifyingglass",
                    accent: HFColors.violet
                )

                Button {
                    let passed = streamingStore.validateLatestLocalReleasePackage()
                    localPackageNotice = passed ? "Latest package manifest imported back and validated." : "Latest package manifest needs review."
                } label: {
                    Label("Validate Latest Package", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("hf.localPackage.validate")

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.localReleasePackageHistory.prefix(3)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.id,
                            detail: record.history.suffix(3).joined(separator: " / "),
                            status: record.manifestStatus,
                            systemImage: "doc.richtext.fill",
                            accent: record.manifestStatus == "Manifest Valid" ? HFColors.gold : HFColors.cyanGlow
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.localPackage.validation")
    }

    private var creatorLocalPackageExportSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Export Package",
                    detail: "The system export surface shares the generated release manifest file. No upload, backend transfer, or distribution API is connected.",
                    systemImage: "square.and.arrow.up.fill",
                    accent: HFColors.gold
                )

                if let exportURL = streamingStore.latestLocalReleasePackageURL {
                    ShareLink(item: exportURL) {
                        Label("Export Manifest", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(HFColors.gold)
                    .accessibilityIdentifier("hf.localPackage.export")

                    Text(exportURL.lastPathComponent)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                } else {
                    HFCreatorStudioReadinessRow(
                        title: "No Export File",
                        detail: "Create a local package before opening the export surface.",
                        status: "Waiting",
                        systemImage: "square.and.arrow.up",
                        accent: HFColors.cyanGlow
                    )
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.localPackage.exportPanel")
    }

    private var creatorUploadWorkflowDashboard: some View {
        let snapshot = streamingStore.creatorUploadWorkflowSnapshot

        return creatorProSpotlight(
            title: "Creator Upload Pipeline",
            detail: "Local preparation workflow for asset selection, validation, package manifest, queue preview, and preflight checks. No transfer service is connected.",
            systemImage: "tray.and.arrow.up.fill",
            accent: HFColors.gold,
            identifier: "hf.upload.workflow.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    creatorProStat(title: "Projects", value: "\(snapshot.projectCount)")
                    creatorProStat(title: "Selected", value: "\(snapshot.selectedAssets)")
                    creatorProStat(title: "Manifest", value: "\(snapshot.manifestItems)")
                    creatorProStat(title: "Preflight", value: snapshot.readinessLabel)
                }

                Text("Media Runtime -> Publishing Repository -> Content Snapshot -> Local Queue")
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.upload.workflow.path")

                Text("This is preparation only. It creates no media transfer, cloud object, account session, payment, or background job.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.upload.workflow.localOnly")
            }
        }
    }

    private var creatorUploadAssetSelectionSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Asset Selection",
                    detail: "Poster, trailer, artwork, and metadata records are selected from the existing media asset runtime.",
                    systemImage: "checklist.checked",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorUploadAssetSelectionRecords.prefix(8)) { record in
                        HFCreatorStudioReadinessRow(
                            title: "\(record.projectTitle) \(record.assetKind.rawValue)",
                            detail: "\(record.source). \(record.detail)",
                            status: record.selectionState,
                            systemImage: record.systemImage,
                            accent: uploadAccent(for: record.selectionState)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.upload.assetSelection")
    }

    private var creatorUploadValidationSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Asset Validation",
                    detail: "Validation checks runtime metadata readiness before a local package manifest can be reviewed.",
                    systemImage: "checkmark.shield.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorUploadValidationRecords.prefix(8)) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.title,
                            detail: record.detail,
                            status: record.status,
                            systemImage: record.systemImage,
                            accent: record.isBlocking ? HFColors.redAccent : HFColors.gold
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.upload.validation")
    }

    private var creatorUploadManifestSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Package Manifest",
                    detail: "In-memory manifest preview groups each project with its local registry records and readiness state.",
                    systemImage: "doc.badge.gearshape.fill",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorUploadPackageManifestRecords) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "\(record.manifestID). \(record.detail)",
                            status: "\(record.assetCount) assets - \(record.packageState)",
                            systemImage: record.systemImage,
                            accent: record.packageState == "Manifest Ready" ? HFColors.gold : HFColors.cyanGlow
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.upload.manifest")
    }

    private var creatorUploadQueueSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Publish Queue Preview",
                    detail: "Prepared packages line up behind publishing readiness without submitting or transferring anything.",
                    systemImage: "tray.full.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorUploadPublishQueueRecords) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.projectTitle,
                            detail: "\(record.nextStep). \(record.detail)",
                            status: "\(record.queueState) - \(record.readiness)",
                            systemImage: record.systemImage,
                            accent: uploadAccent(for: record.queueState)
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.upload.publishQueue")
    }

    private var creatorUploadPreflightSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Preflight Checks",
                    detail: "Local checks confirm package readiness and preserve the no-service boundary before any future production work.",
                    systemImage: "list.clipboard.fill",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorUploadPreflightRecords) { record in
                        HFCreatorStudioReadinessRow(
                            title: record.title,
                            detail: record.detail,
                            status: record.result,
                            systemImage: record.systemImage,
                            accent: record.isPassed ? HFColors.gold : HFColors.redAccent
                        )
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.upload.preflight")
    }

    private var creatorDraftValidationSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Draft Validation",
                    detail: "Readiness is computed from the current editor state before the draft moves into local review.",
                    systemImage: "checklist.checked",
                    accent: HFColors.cyanGlow
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorDraftValidationItems(for: editorDraftPreview)) { item in
                        draftValidationRow(item)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.draftWorkspace.validation")
        .onAppear {
            hydrateDraftWorkspaceIfNeeded()
        }
    }

    private var creatorDraftCompareSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Draft Compare",
                    detail: "Editor values are compared to the saved PublishingRepository draft before saving.",
                    systemImage: "rectangle.split.2x1.fill",
                    accent: HFColors.violet
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(draftCompareRecords) { record in
                        draftCompareRow(record)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.draftWorkspace.compare")
        .onAppear {
            hydrateDraftWorkspaceIfNeeded()
        }
    }

    private var creatorDraftHistorySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Draft History",
                    detail: "Revision context is derived from the persisted draft snapshot and current validation state.",
                    systemImage: "clock.arrow.circlepath",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.creatorDraftHistoryRecords(for: activeWorkspaceDraft)) { record in
                        draftHistoryRow(record)
                    }
                }

                Button {
                    Task { await archiveDraftWorkspace() }
                } label: {
                    HFCreatorStudioAction(title: "Archive Draft", systemImage: "archivebox.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.draftWorkspace.archive")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.draftWorkspace.history")
        .onAppear {
            hydrateDraftWorkspaceIfNeeded()
        }
    }

    private var creatorPublishingPipelineSection: some View {
        let project = creatorPrimaryPublishingProject

        return HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius + 6, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Creator Publishing Pipeline",
                    detail: "Content object, metadata, poster, trailer, creator library state, and local discovery connection.",
                    systemImage: "square.stack.3d.up.fill",
                    accent: HFColors.gold
                )

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(project.title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)

                    Text("\(project.creator) • \(project.genre) • \(project.runtime) • \(project.releaseState.rawValue)")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)

                    Text(project.description)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityIdentifier("hf.creator.pipeline.contentObject")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 118), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    publishingStatusTile(title: "Poster", status: project.posterStatus.rawValue, systemImage: "photo.fill.on.rectangle.fill", identifier: "hf.creator.pipeline.posterStatus", accent: HFColors.gold)
                    publishingStatusTile(title: "Trailer", status: project.trailerStatus.rawValue, systemImage: "film.stack.fill", identifier: "hf.creator.pipeline.trailerStatus", accent: HFColors.cyanGlow)
                    publishingStatusTile(title: "Metadata", status: project.metadataStatus.rawValue, systemImage: "text.justify.left", identifier: "hf.creator.pipeline.metadataStatus", accent: HFColors.violet)
                    publishingStatusTile(title: "Artwork", status: project.artworkStatus.rawValue, systemImage: "rectangle.stack.fill", identifier: "hf.creator.pipeline.artworkStatus", accent: HFColors.gold)
                }

                HStack(alignment: .center, spacing: HFSpacing.sm) {
                    Label(project.readyForReview ? "Ready For Review" : "Needs Local Review", systemImage: project.readyForReview ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(project.readyForReview ? HFColors.gold : HFColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .accessibilityIdentifier("hf.creator.pipeline.readyForReview")

                    Spacer(minLength: HFSpacing.xs)

                    Text(project.discoveryEligible ? "Visible in local discovery" : "Creator library only")
                        .font(HFTypography.micro.weight(.semibold))
                        .foregroundStyle(project.discoveryEligible ? HFColors.cyanGlow : HFColors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .accessibilityIdentifier("hf.creator.pipeline.discoveryConnection")
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator publishing pipeline. \(project.title). \(project.releaseState.rawValue).")
        .accessibilityIdentifier("hf.creator.pipeline.dashboard")
    }

    private var creatorPublishingLibrarySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Creator Library",
                    detail: "My Projects, drafts, published titles, and archived packages stay local until a project reaches Published.",
                    systemImage: "books.vertical.fill",
                    accent: HFColors.violet
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.sm) {
                        ForEach(streamingStore.creatorPublishingContents) { project in
                            creatorPublishingProjectCard(project)
                        }
                    }
                    .padding(.vertical, 2)
                }

                HStack(spacing: HFSpacing.xs) {
                    HFCreatorStudioPill(title: "My Projects \(streamingStore.creatorPublishingContents.count)", isActive: true)
                    HFCreatorStudioPill(title: "Draft \(streamingStore.creatorDraftProjects.count)")
                    HFCreatorStudioPill(title: "Published \(streamingStore.creatorPublishedProjects.count)")
                    HFCreatorStudioPill(title: "Archived \(streamingStore.creatorArchivedProjects.count)")
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Creator library filters for my projects, drafts, published, and archived.")
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator library. My Projects, Drafts, Published, and Archived.")
        .accessibilityIdentifier("hf.creator.pipeline.creatorLibrary")
    }

    private var creatorPublishingSpotlightPanel: some View {
        let project = creatorPrimaryPublishingProject

        return creatorProSpotlight(
            title: "Creator Publishing Pipeline",
            detail: "Content ingestion, metadata, poster, trailer, creator library state, and discovery connection are staged locally.",
            systemImage: "square.stack.3d.up.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pipeline.dashboard"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(project.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                    Text("\(project.releaseState.rawValue) • \(project.creator) • \(project.genre)")
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
                .accessibilityIdentifier("hf.creator.pipeline.contentObject")

                HStack(spacing: HFSpacing.xs) {
                    creatorProStat(title: "Drafts", value: "\(streamingStore.creatorDraftProjects.count)")
                    creatorProStat(title: "Review", value: "\(streamingStore.creatorReviewProjects.count)")
                    creatorProStat(title: "Published", value: "\(streamingStore.creatorPublishedProjects.count)")
                }

                Label(project.readyForReview ? "Ready For Review" : "Needs Local Review", systemImage: "checkmark.seal.fill")
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(project.readyForReview ? HFColors.gold : HFColors.textSecondary)
                    .accessibilityIdentifier("hf.creator.pipeline.readyForReview")

                Text(project.discoveryEligible ? "Published content appears in local discovery." : "Project remains in Creator Library until Published.")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("hf.creator.pipeline.discoveryConnection")
            }
        }
    }

    private var creatorPrimaryPublishingProject: HFCreatorPublishingContent {
        streamingStore.creatorReviewProjects.first
            ?? streamingStore.creatorDraftProjects.first
            ?? streamingStore.creatorScheduledProjects.first
            ?? streamingStore.creatorPublishedProjects.first
            ?? streamingStore.creatorPublishingContents[0]
    }

    private func publishingStatusTile(title: String, status: String, systemImage: String, identifier: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(accent)
                .accessibilityHidden(true)

            Text(status)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(accent.opacity(0.26), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) status \(status).")
        .accessibilityIdentifier(identifier)
    }

    private func publishingQueueCard(_ record: HFCreatorPublishingQueueRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(spacing: HFSpacing.xs) {
                Text(record.priority)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(record.priority == "High" ? HFColors.gold : HFColors.cyanGlow)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background((record.priority == "High" ? HFColors.gold : HFColors.cyanGlow).opacity(0.14))
                    .clipShape(Capsule())
                Spacer(minLength: 0)
                Text(record.stage)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
            }

            Text(record.project.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.70)

            Text(record.nextStep)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)

            Spacer(minLength: 0)

            Text(record.owner)
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(HFColors.violet)
                .lineLimit(1)
        }
        .frame(width: 176, height: 144, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.project.title). \(record.stage). Next step \(record.nextStep).")
        .accessibilityIdentifier("hf.publishing.queue.\(record.project.id)")
    }

    private func publishingReadinessCard(_ item: HFCreatorPublishingReadinessItem) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: item.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
            Text(item.status)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
            Text(item.title)
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
            Text(item.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.publishing.readiness.\(item.id)")
    }

    private func publishingChecklistRow(_ item: HFCreatorPublishingChecklistItem) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: item.status == "Ready" || item.status == "Safe" || item.status == "Linked" ? "checkmark.circle.fill" : "circle.dotted")
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(item.status == "Missing" ? HFColors.violet : HFColors.gold)
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.055))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                Text(item.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(item.status)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.publishing.checklist.\(item.id)")
    }

    private func publishingCalendarRow(_ item: HFCreatorPublishingScheduleItem) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            VStack(spacing: 2) {
                Text(item.window.prefix(3).uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(HFColors.violet)
                Text(item.status)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
            }
            .frame(width: 54, height: 48)
            .background(HFColors.violet.opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(item.window) • \(item.detail)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.publishing.calendar.\(item.id)")
    }

    private func publishingAuditCard(_ record: HFCreatorPublishingAuditRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.gold)
            Text(record.result)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(record.title)
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
            Text(record.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.publishing.audit.\(record.id)")
    }

    private func collaborationTeamCard(_ record: HFCreatorProjectTeamRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(spacing: HFSpacing.xs) {
                Text(record.status)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.violet)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(HFColors.violet.opacity(0.14))
                    .clipShape(Capsule())
                Spacer(minLength: 0)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(HFColors.gold)
            }

            Text(record.project.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.70)

            Text("Owner: \(record.owner)")
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)

            Text(record.permissionSummary)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)

            Spacer(minLength: 0)

            Text(record.collaborators.map(\.role).joined(separator: " • "))
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(width: 196, height: 176, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.violet.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.project.title). Owner \(record.owner). \(record.permissionSummary).")
        .accessibilityIdentifier("hf.collaboration.team.\(record.project.id)")
    }

    private func collaboratorRoleCard(_ collaborator: HFCreatorCollaboratorRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: collaborator.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(collaborator.role == "Owner" ? HFColors.gold : HFColors.violet)
                .accessibilityHidden(true)
            Text(collaborator.role)
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(collaborator.name)
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
            Text(collaborator.permissionScope)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(2)
            Text(collaborator.focus)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.collaboration.collaborator.\(collaborator.id)")
    }

    private func collaborationTaskColumn(status: String) -> some View {
        let tasks = streamingStore.creatorCollaborationTasks.filter { $0.status == status }
        return VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(spacing: HFSpacing.xs) {
                Text(status)
                    .font(HFTypography.caption.weight(.black))
                    .foregroundStyle(collaborationStatusColor(status))
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                Spacer(minLength: 0)
                Text("\(tasks.count)")
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.textPrimary)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 7)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
            }

            ForEach(tasks.prefix(4)) { task in
                collaborationTaskCard(task)
            }
        }
        .frame(width: 190, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.22))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(collaborationStatusColor(status).opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.collaboration.taskBoard.\(status.replacingOccurrences(of: " ", with: "-").lowercased())")
    }

    private func collaborationTaskCard(_ task: HFCreatorCollaborationTaskRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: task.systemImage)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(collaborationStatusColor(task.status))
                    .accessibilityHidden(true)
                Text(task.assigneeRole)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
            }

            Text(task.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(task.projectTitle)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(task.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.collaboration.task.\(task.id)")
    }

    private func collaborationNoteCard(_ note: HFCreatorCollaborationNoteRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(note.noteType)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(1)
            Text(note.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
            Text("\(note.authorRole) • \(note.projectTitle)")
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(note.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.collaboration.note.\(note.id)")
    }

    private func collaborationActivityRow(_ activity: HFCreatorCollaborationActivityRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: activity.systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 34, height: 34)
                .background(HFColors.gold.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                Text("\(activity.actorRole) • \(activity.timeLabel)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                Text(activity.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.collaboration.activity.\(activity.id)")
    }

    private func collaborationTimelineRow(_ milestone: HFCreatorCollaborationTimelineRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            VStack(spacing: HFSpacing.xxs) {
                Image(systemName: milestone.systemImage)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(HFColors.violet)
                Text(milestone.status)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.60)
            }
            .frame(width: 58, height: 52)
            .background(HFColors.violet.opacity(0.13))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(milestone.title) • \(milestone.stage)")
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(milestone.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.collaboration.timeline.\(milestone.id)")
    }

    private func collaborationStatusColor(_ status: String) -> Color {
        switch status {
        case "Complete":
            return HFColors.gold
        case "Review":
            return HFColors.cyanGlow
        case "In Progress":
            return HFColors.violet
        default:
            return HFColors.textSecondary
        }
    }

    private func seriesSummaryCard(_ series: HFSeriesRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: "play.square.stack.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
                .accessibilityHidden(true)

            Text(series.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("\(series.seasons.count) season • \(series.episodeCount) episodes")
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(series.creatorName)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)

            Text(series.status.rawValue)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(series.status == .published ? HFColors.gold : HFColors.violet)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.series.card.\(series.id)")
    }

    private func seasonSelectorPill(_ season: HFSeasonRecord) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("S\(season.seasonNumber)")
                .font(HFTypography.caption.weight(.black))
                .foregroundStyle(HFColors.textPrimary)
            Text("\(season.episodes.count) episodes")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.vertical, HFSpacing.xs)
        .padding(.horizontal, HFSpacing.sm)
        .background(HFColors.gold.opacity(0.12))
        .overlay(
            Capsule()
                .stroke(HFColors.gold.opacity(0.26), lineWidth: 1)
        )
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.series.season.\(season.id)")
    }

    private func episodeManagementRow(_ episode: HFEpisodeRecord, seriesTitle: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            VStack(spacing: 2) {
                Text("S\(episode.seasonNumber)")
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text("E\(episode.episodeNumber)")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
            }
            .frame(width: 54, height: 52)
            .background(HFColors.gold.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(episode.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text("\(seriesTitle) • \(episode.runtime) • \(episode.releaseState.rawValue)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
                Text(episode.synopsis)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.series.episode.\(episode.id)")
    }

    private func nextEpisodeRecommendationCard(_ recommendation: HFNextEpisodeRecommendation) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(recommendation.progressLabel)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.violet)
                .lineLimit(1)

            Text(recommendation.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(recommendation.seriesTitle)
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)

            Text(recommendation.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.series.nextEpisode.\(recommendation.id)")
    }

    private func episodeAnalyticsCard(_ record: HFEpisodeAnalyticsRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("\(record.views)")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)

            Text(record.episodeTitle)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(record.seriesTitle)
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)

            HStack(spacing: HFSpacing.xs) {
                analyticsMiniPill("\(record.completionRate)%", "Complete", HFColors.cyanGlow)
                analyticsMiniPill(record.watchTime, "Watch", HFColors.gold)
            }

            Text("Drop-off: \(record.dropOffPoint)")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.series.analytics.\(record.id)")
    }

    private func titleRevenueCard(_ record: HFTitleRevenueRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HFPosterCard(movie: record.movie, width: 112, showTitle: false, posterOnly: true)

                Text(record.movie.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(record.estimatedRevenue)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                HStack(spacing: HFSpacing.xs) {
                    analyticsMiniPill("\(record.views)", "Views", HFColors.cyanGlow)
                    analyticsMiniPill(record.revenuePerView, "Per view", HFColors.gold)
                }

                Text("\(record.streamingRevenue) stream • \(record.premiumRevenue) premium")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                Text("\(record.collectionRevenue) collection • \(record.growthLabel) trend")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(2)
            }
            .padding(HFSpacing.sm)
            .frame(width: 152, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.movie.title), estimated revenue \(record.estimatedRevenue), \(record.views) local views.")
        .accessibilityIdentifier("hf.revenue.title.\(record.id)")
    }

    private func revenueInsightCard(_ insight: HFRevenueInsight) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: insight.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
            Text(insight.value)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(insight.title)
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
            Text(insight.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.revenue.insight.\(insight.id)")
    }

    private func creatorRevenueSummaryCard(_ summary: HFCreatorRevenueSummary) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HStack(spacing: HFSpacing.xs) {
                    Image(systemName: "person.crop.rectangle.stack.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(HFColors.violet)
                    Text(summary.growthLabel)
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                }

                Text(summary.creatorName)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(summary.topTitle)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)

                HStack(spacing: HFSpacing.xs) {
                    analyticsMiniPill(summary.estimatedRevenue, "Estimate", HFColors.gold)
                    analyticsMiniPill(summary.projectedRevenue, "Projected", HFColors.cyanGlow)
                }

                Text("\(summary.titleCount) titles • \(summary.lifetimePreview) lifetime preview")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(2)
            }
            .padding(HFSpacing.sm)
            .frame(width: 184, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.revenue.creator.\(summary.id)")
    }

    private func payoutPreviewCard(_ record: HFPayoutPreviewRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.violet)
            Text(record.value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
            Text(record.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
            Text(record.state)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.violet)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.revenue.payout.\(record.id)")
    }

    private func notificationRow(_ record: HFProductNotificationRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(notificationAccent(for: record.category))
                .frame(width: 38, height: 38)
                .background(notificationAccent(for: record.category).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(record.category)
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(notificationAccent(for: record.category))
                        .lineLimit(1)
                    Text(record.timeLabel)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                }

                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)

                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)

                Text(record.status)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.notifications.item.\(record.id)")
    }

    private func activityCenterCard(_ record: HFActivityCenterRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
            Text(record.value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
            Text(record.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
            Text(record.status)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.notifications.activity.\(record.id)")
    }

    private func notificationCount(for category: String) -> Int {
        streamingStore.productNotificationRecords.filter { $0.category == category }.count
    }

    private func notificationIcon(for category: String) -> String {
        switch category {
        case "Publishing": return "paperplane.circle.fill"
        case "Discovery": return "sparkle.magnifyingglass"
        case "Series": return "play.square.stack.fill"
        case "Collaboration": return "person.3.sequence.fill"
        case "Revenue": return "dollarsign.circle.fill"
        case "Analytics": return "chart.bar.xaxis"
        case "Library": return "bookmark.fill"
        default: return "bell.badge.fill"
        }
    }

    private func notificationAccent(for category: String) -> Color {
        switch category {
        case "Publishing", "Revenue", "Library":
            return HFColors.gold
        case "Discovery", "Series", "Analytics":
            return HFColors.cyanGlow
        case "Collaboration":
            return HFColors.violet
        default:
            return HFColors.textSecondary
        }
    }

    private func contentReviewRow(_ record: HFContentReviewRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(adminAccent(for: record.reviewState))
                .frame(width: 38, height: 38)
                .background(adminAccent(for: record.reviewState).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.reviewState)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(adminAccent(for: record.reviewState))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                Text("\(record.creatorName) • \(record.status)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.admin.review.\(record.id)")
    }

    private func creatorAdministrationCard(_ record: HFCreatorAdministrationRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: "person.crop.rectangle.stack.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.violet)
                Text(record.creatorName)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.verificationPreview)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                HStack(spacing: HFSpacing.xs) {
                    analyticsMiniPill("\(record.titleCount)", "Titles", HFColors.cyanGlow)
                    analyticsMiniPill(record.creatorStatus, "Creator", HFColors.gold)
                }
                Text("\(record.publishingStatus) • \(record.profileStatus)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }
            .padding(HFSpacing.sm)
            .frame(width: 184, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.admin.creator.\(record.id)")
    }

    private func platformHealthCard(_ record: HFPlatformHealthRecord, identifierPrefix: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
            Text(record.value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
            Text(record.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
            Text(record.status)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("\(identifierPrefix).\(record.id)")
    }

    private func moderationQueueRow(_ record: HFModerationQueueRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.violet)
                .frame(width: 38, height: 38)
                .background(HFColors.violet.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.category)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(HFColors.violet)
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.policyStatus) • \(record.reviewState)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(2)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.admin.moderation.\(record.id)")
    }

    private func auditTrailRow(_ record: HFAuditTrailRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(notificationAccent(for: record.category))
                .frame(width: 38, height: 38)
                .background(notificationAccent(for: record.category).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(record.category)
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(notificationAccent(for: record.category))
                        .lineLimit(1)
                    Text(record.timeLabel)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                }
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                Text(record.result)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.admin.audit.\(record.id)")
    }

    private func adminAccent(for state: String) -> Color {
        switch state {
        case "Approved", "Approved Preview":
            return HFColors.gold
        case "Pending Review":
            return HFColors.cyanGlow
        case "Needs Revision":
            return HFColors.violet
        default:
            return HFColors.textSecondary
        }
    }

    private func marketplaceCatalogRow(_ record: HFMarketplaceCatalogRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(marketplaceAccent(for: record.readiness))
                .frame(width: 38, height: 38)
                .background(marketplaceAccent(for: record.readiness).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.distributionState)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(marketplaceAccent(for: record.readiness))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                Text("\(record.creatorName) • \(record.packageType)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text("\(record.rightsSummary) • \(record.revenuePreview)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.marketplace.catalog.\(record.id)")
    }

    private func distributionTargetCard(_ record: HFDistributionTargetRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.cyanGlow)
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.readiness)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.purpose)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
                Text(record.boundary)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(1)
            }
            .padding(HFSpacing.sm)
            .frame(width: 184, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.marketplace.target.\(record.id)")
    }

    private func rightsPackageCard(_ record: HFRightsPackageRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.violet)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(record.creatorName)
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
            Text("\(record.rightsWindow) • \(record.territoryPreview)")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
            Text(record.clearanceState)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.violet)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.marketplace.rights.\(record.id)")
    }

    private func releasePackageRow(_ record: HFReleasePackageRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 38, height: 38)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.marketplaceState)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.publishingState) • \(record.assets)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
                Text(record.nextStep)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.marketplace.package.\(record.id)")
    }

    private func licensingPreviewCard(_ record: HFLicensingPreviewRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.estimatePreview)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.packageScope)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(1)
                Text("\(record.rightsState) • \(record.planningNote)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 188, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.marketplace.licensing.\(record.id)")
    }

    private func distributionReadinessCard(_ record: HFDistributionReadinessRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
            Text(record.value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
            Text(record.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
            Text(record.status)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.marketplace.readiness.\(record.id)")
    }

    private func marketplaceAccent(for readiness: String) -> Color {
        readiness.contains("Ready") ? HFColors.gold : HFColors.cyanGlow
    }

    private func uploadAccent(for state: String) -> Color {
        if state.contains("Blocked") || state.contains("Excluded") {
            return HFColors.redAccent
        }
        if state.contains("Prepared") || state.contains("Selected") || state.contains("Ready") {
            return HFColors.gold
        }
        return HFColors.cyanGlow
    }

    private func projectRuntimeAccent(for state: String) -> Color {
        if state.contains("Archived") || state.contains("Blocked") {
            return HFColors.redAccent
        }
        if state.contains("Ready") || state.contains("Published") || state.contains("Visible") || state.contains("Logged") {
            return HFColors.gold
        }
        return HFColors.cyanGlow
    }

    private func mediaImportAccent(for state: String) -> Color {
        if state.contains("Blocked") || state.contains("Unlinked") {
            return HFColors.redAccent
        }
        if state.contains("Ready") || state.contains("Registered") || state.contains("Linked") || state.contains("Updated") || state.contains("Imported") {
            return HFColors.gold
        }
        return HFColors.cyanGlow
    }

    private func mediaInspectionAccent(for state: HFCreatorMediaInspectionState) -> Color {
        switch state {
        case .accepted:
            return HFColors.gold
        case .warning:
            return HFColors.cyanGlow
        case .blocked, .quarantined:
            return HFColors.redAccent
        }
    }

    private func mediaInspectionSystemImage(for record: HFCreatorMediaInspectionRecord) -> String {
        if record.isQuarantined { return "exclamationmark.triangle.fill" }
        switch record.kind {
        case .poster:
            return "photo.fill.on.rectangle.fill"
        case .trailer:
            return "film.stack.fill"
        case .artwork:
            return "rectangle.stack.fill"
        case .metadata:
            return "doc.text.fill"
        }
    }

    private func createLocalReleasePackage() {
        do {
            let record = try streamingStore.createLocalReleasePackage()
            localPackageNotice = "Created \(record.projectTitle) package. Manifest \(record.manifestStatus). Checksum \(record.shortChecksum)."
        } catch {
            localPackageNotice = "Package creation failed: \(error.localizedDescription)"
        }
    }

    private func resolvedImportProjectID() -> String? {
        if let selectedImportProjectID,
           streamingStore.creatorPublishingContents.contains(where: { $0.id == selectedImportProjectID && $0.releaseState != .archived }) {
            return selectedImportProjectID
        }
        return streamingStore.primaryImportProjectID()
    }

    @MainActor
    private func importPhotoPickerItem(_ item: PhotosPickerItem) async {
        guard let projectID = resolvedImportProjectID() else {
            mediaImportNotice = "No active creator project is available for import."
            return
        }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                mediaImportNotice = "Photos selection did not provide readable media data."
                return
            }
            let contentType = item.supportedContentTypes.first?.identifier ?? "public.data"
            let extensionHint = item.supportedContentTypes.first?.preferredFilenameExtension ?? "media"
            let result = try streamingStore.importLocalMediaData(
                projectID: projectID,
                kind: selectedImportKind,
                filename: "\(selectedImportKind.rawValue.lowercased())-photos-import.\(extensionHint)",
                data: data,
                contentType: contentType
            )
            mediaImportNotice = result.message
            selectedPhotoImportItem = nil
        } catch {
            mediaImportNotice = "Photos import failed: \(error.localizedDescription)"
            selectedPhotoImportItem = nil
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        guard let projectID = resolvedImportProjectID() else {
            mediaImportNotice = "No active creator project is available for file import."
            return
        }
        do {
            guard let url = try result.get().first else {
                mediaImportNotice = "File import cancelled."
                return
            }
            let importResult = try streamingStore.importLocalMediaFile(
                projectID: projectID,
                kind: selectedImportKind,
                fileURL: url
            )
            mediaImportNotice = importResult.message
        } catch {
            mediaImportNotice = "File import failed: \(error.localizedDescription)"
        }
    }

    private func cancelLatestImport() {
        guard let asset = streamingStore.importedMediaAssets.last else {
            mediaImportNotice = "No imported asset is available to cancel."
            return
        }
        streamingStore.cancelImportedMediaAsset(id: asset.id)
        mediaImportNotice = "Cancelled \(asset.originalFilename) and removed its sandbox file."
    }

    private func retryLatestImport() {
        guard let asset = streamingStore.importedMediaAssets.last else {
            mediaImportNotice = "No imported asset is available to retry."
            return
        }
        streamingStore.retryImportedMediaAsset(id: asset.id)
        mediaImportNotice = "Retried \(asset.originalFilename)."
    }

    private func gateLabel(_ value: Bool) -> String {
        value ? "ready" : "pending"
    }

    private func rightsLedgerRow(_ record: HFRightsLedgerRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(rightsAccent(for: record.ledgerState))
                .frame(width: 38, height: 38)
                .background(rightsAccent(for: record.ledgerState).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.ledgerState)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(rightsAccent(for: record.ledgerState))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                Text("\(record.creatorName) • \(record.rightsWindow)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text("\(record.territory) • \(record.clearance)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.rights.ledger.\(record.id)")
    }

    private func rightsWindowCard(_ record: HFRightsWindowRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.violet)
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.window)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.packageScope)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
                Text("\(record.status) • \(record.detail)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 188, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.rights.window.\(record.id)")
    }

    private func territoryTrackingCard(_ record: HFTerritoryTrackingRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
            Text("\(record.packageCount)")
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
            Text(record.region)
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(2)
            Text("\(record.availabilityPreview) • \(record.status)")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.rights.territory.\(record.id)")
    }

    private func clearanceTrackingRow(_ record: HFClearanceTrackingRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 38, height: 38)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.area)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(record.state)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(1)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.rights.clearance.\(record.id)")
    }

    private func licensingPackageCard(_ record: HFLicensingPackageRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.gold)
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.estimatePreview)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.scope)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(1)
                Text("\(record.readiness) • \(record.nextStep)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 188, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.rights.licensingPackage.\(record.id)")
    }

    private func rightsReadinessCard(_ record: HFRightsReadinessRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
            Text(record.value)
                .font(.system(size: 24, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
            Text(record.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
            Text(record.status)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.rights.readiness.\(record.id)")
    }

    private func dealPreparationRow(_ record: HFDealPreparationRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(notificationAccent(for: record.source))
                .frame(width: 38, height: 38)
                .background(notificationAccent(for: record.source).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.source)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(notificationAccent(for: record.source))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                Text(record.readiness)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.rights.preparation.\(record.id)")
    }

    private func rightsAccent(for state: String) -> Color {
        state.contains("Cleared") || state.contains("tracked") ? HFColors.gold : HFColors.violet
    }

    private func serviceRegistryRow(_ record: HFServiceRegistryRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(integrationAccent(for: record.productArea))
                .frame(width: 38, height: 38)
                .background(integrationAccent(for: record.productArea).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.productArea)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(integrationAccent(for: record.productArea))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.readiness) • \(record.dependency)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(2)
                Text(record.boundary)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.integration.service.\(record.id)")
    }

    private func dataSourceRegistryCard(_ record: HFDataSourceRegistryRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: integrationAccent(for: record.owner).opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(integrationAccent(for: record.owner))
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.state)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.sourceType)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 190, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.integration.dataSource.\(record.id)")
    }

    private func syncReadinessRow(_ record: HFSyncReadinessRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 38, height: 38)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.readiness)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.localCount) local records")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(1)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.integration.sync.\(record.id)")
    }

    private func apiReadinessCard(_ record: HFAPIReadinessRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.violet)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
            Text(record.shapeState)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
            Text(record.requestShape)
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(2)
            Text("\(record.responseShape) • \(record.boundary)")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.integration.api.\(record.id)")
    }

    private func environmentProfileCard(_ record: HFEnvironmentProfileRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: environmentAccent(for: record.status).opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(environmentAccent(for: record.status))
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.profile)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.services)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
                Text("\(record.dataPolicy) • \(record.status)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 196, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.integration.environment.\(record.id)")
    }

    private func integrationAuditRow(_ record: HFIntegrationAuditRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(integrationAccent(for: record.category))
                .frame(width: 38, height: 38)
                .background(integrationAccent(for: record.category).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.category)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(integrationAccent(for: record.category))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                Text(record.result)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.integration.audit.\(record.id)")
    }

    private func productionConnectionRow(_ record: HFProductionConnectionRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(productionAccent(for: record.domain))
                .frame(width: 38, height: 38)
                .background(productionAccent(for: record.domain).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.domain)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(productionAccent(for: record.domain))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.readiness) • \(record.handoff)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(2)
                Text(record.boundary)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.productionBridge.connection.\(record.id)")
    }

    private func productionFeatureFlagCard(_ record: HFProductionFeatureFlagRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: productionAccent(for: record.scope).opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(productionAccent(for: record.scope))
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.defaultState)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.scope)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
                Text("\(record.rolloutNote) • \(record.boundary)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 190, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.productionBridge.flag.\(record.id)")
    }

    private func productionServiceMappingCard(_ record: HFProductionServiceMappingRecord) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: record.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.violet)
            Text(record.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
            Text(record.mappingState)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
            Text(record.localSystem)
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(HFColors.cyanGlow)
                .lineLimit(2)
            Text("\(record.futureSystem) • \(record.dependency)")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.productionBridge.mapping.\(record.id)")
    }

    private func productionEnvironmentSwitchCard(_ record: HFProductionEnvironmentSwitchRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: productionEnvironmentAccent(for: record.availability).opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: record.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(productionEnvironmentAccent(for: record.availability))
                Text(record.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(record.mode)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.availability)
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(1)
                Text("\(record.guardrail) • \(record.notes)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 196, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.productionBridge.environment.\(record.id)")
    }

    private func productionReadinessReportRow(_ record: HFProductionReadinessReportRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(productionAccent(for: record.title))
                .frame(width: 38, height: 38)
                .background(productionAccent(for: record.title).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.state)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(productionAccent(for: record.title))
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.score) • \(record.nextStep)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(2)
                Text(record.summary)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.productionBridge.report.\(record.id)")
    }

    private func productionDependencyGraphRow(_ record: HFProductionDependencyGraphRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
                .frame(width: 38, height: 38)
                .background(HFColors.cyanGlow.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.readiness)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(1)
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.upstream) -> \(record.downstream)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(2)
                Text(record.blocker)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.productionBridge.dependency.\(record.id)")
    }

    private func contentBackendMetricCard(_ metric: HFContentRepositoryMetric) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: metric.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(contentBackendAccent(for: metric.id))
            Text(metric.value)
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(metric.title)
                .font(HFTypography.caption.weight(.bold))
                .foregroundStyle(HFColors.gold)
                .lineLimit(2)
                .minimumScaleFactor(0.74)
            Text(metric.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.contentBackend.repository.\(metric.id)")
    }

    private func contentBackendRailCard(_ metric: HFContentRepositoryMetric) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: contentBackendAccent(for: metric.id).opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: metric.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(contentBackendAccent(for: metric.id))
                Text(metric.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(metric.value)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(metric.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            .padding(HFSpacing.sm)
            .frame(width: 176, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.contentBackend.fetch.\(metric.id)")
    }

    private func contentBackendMetricRow(_ metric: HFContentRepositoryMetric) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: metric.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(contentBackendAccent(for: metric.id))
                .frame(width: 38, height: 38)
                .background(contentBackendAccent(for: metric.id).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(metric.title)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    Text(metric.value)
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(1)
                }
                Text(metric.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.contentBackend.persistence.\(metric.id)")
    }

    private func productionBackendEndpointRow(_ row: HFProductionCatalogEndpointRow) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: row.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
                .frame(width: 38, height: 38)
                .background(HFColors.cyanGlow.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(row.title)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    Text(row.status)
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(1)
                }
                Text(row.path)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.productionBackend.endpoint.\(row.id)")
    }

    private func identityRoleCheckRow(_ row: HFIdentityAccessRoleCheck) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: row.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(row.status == "Denied" ? HFColors.violet : HFColors.cyanGlow)
                .frame(width: 38, height: 38)
                .background((row.status == "Denied" ? HFColors.violet : HFColors.cyanGlow).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(row.title)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    Text(row.status)
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(row.status == "Denied" ? HFColors.violet : HFColors.gold)
                        .lineLimit(1)
                }
                Text(row.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.identity.access.row.\(row.id)")
    }

    private func identityAuditRow(_ event: HFIdentityAccessAuditEvent) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 38, height: 38)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(event.action)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    Text(event.createdAtLabel)
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(HFColors.gold)
                        .lineLimit(1)
                }
                Text(event.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.identity.access.audit.\(event.id)")
    }

    private func contentBackendRelationshipRow(_ record: HFContentRelationshipRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(contentBackendAccent(for: record.id))
                .frame(width: 38, height: 38)
                .background(contentBackendAccent(for: record.id).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text("\(record.source) -> \(record.target)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                Text(record.state)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.contentBackend.relationship.\(record.id)")
    }

    private func contentBackendAccent(for id: String) -> Color {
        switch id {
        case let value where value.contains("creator") || value.contains("relationship"):
            return HFColors.violet
        case let value where value.contains("library") || value.contains("draft") || value.contains("snapshot"):
            return HFColors.gold
        default:
            return HFColors.cyanGlow
        }
    }

    private var activeWorkspaceDraft: HFCreatorPublishingContent {
        if let selectedDraftID, let draft = streamingStore.loadCreatorDraft(id: selectedDraftID) {
            return draft
        }
        return streamingStore.creatorDraftProjects.first
            ?? streamingStore.creatorPrimaryReadinessProject
    }

    private var draftTagList: [String] {
        draftTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var editorDraftPreview: HFCreatorPublishingContent {
        var draft = activeWorkspaceDraft
        if !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.title = draftTitle
        }
        if !draftDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.description = draftDescription
        }
        if !draftGenre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.genre = draftGenre
        }
        if !draftRuntime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            draft.runtime = draftRuntime
        }
        draft.tags = draftTagList
        draft.posterStatus = draftPosterStatus
        draft.trailerStatus = draftTrailerStatus
        draft.metadataStatus = draftMetadataStatus
        draft.artworkStatus = draftArtworkStatus
        return draft
    }

    private var draftCompareRecords: [HFCreatorDraftCompareRecord] {
        streamingStore.creatorDraftCompareRecords(
            for: activeWorkspaceDraft,
            title: draftTitle,
            description: draftDescription,
            genre: draftGenre,
            tags: draftTagList,
            runtime: draftRuntime,
            posterStatus: draftPosterStatus,
            trailerStatus: draftTrailerStatus,
            metadataStatus: draftMetadataStatus,
            artworkStatus: draftArtworkStatus
        )
    }

    private func hydrateDraftWorkspaceIfNeeded() {
        guard selectedDraftID == nil || draftTitle.isEmpty else { return }
        hydrateDraftWorkspace(from: activeWorkspaceDraft)
    }

    private func hydrateDraftWorkspace(from draft: HFCreatorPublishingContent) {
        selectedDraftID = draft.id
        draftTitle = draft.title
        draftDescription = draft.description
        draftGenre = draft.genre
        draftTags = draft.tags.joined(separator: ", ")
        draftRuntime = draft.runtime
        draftPosterStatus = draft.posterStatus
        draftTrailerStatus = draft.trailerStatus
        draftMetadataStatus = draft.metadataStatus
        draftArtworkStatus = draft.artworkStatus
        draftWorkspaceNotice = "Loaded \(draft.title) from repository snapshot"
    }

    private func saveDraftWorkspace() async {
        if let selectedDraftID, streamingStore.loadCreatorDraft(id: selectedDraftID) != nil {
            await streamingStore.updateRemoteCreatorDraft(
                id: selectedDraftID,
                title: draftTitle,
                description: draftDescription,
                creator: streamingStore.activeViewingProfile.displayName,
                genre: draftGenre,
                tags: draftTagList,
                runtime: draftRuntime,
                posterStatus: draftPosterStatus,
                trailerStatus: draftTrailerStatus,
                metadataStatus: draftMetadataStatus,
                artworkStatus: draftArtworkStatus
            )
            if let saved = streamingStore.loadCreatorDraft(id: selectedDraftID) {
                hydrateDraftWorkspace(from: saved)
            }
        } else {
            let created = await streamingStore.createRemoteCreatorDraft(
                title: draftTitle,
                description: draftDescription,
                creator: streamingStore.activeViewingProfile.displayName,
                genre: draftGenre,
                tags: draftTagList,
                runtime: draftRuntime
            )
            if let created {
                hydrateDraftWorkspace(from: created)
            }
        }
        didSaveLocalDraft = true
        draftWorkspaceNotice = streamingStore.creatorDraftSyncRuntimeSnapshot.state == .synced ? "Draft saved through remote PublishingRepository" : "Draft saved to content snapshot"
    }

    private func createNewWorkspaceDraft() async {
        let created = await streamingStore.createRemoteCreatorDraft(
            title: "Untitled Creator Draft",
            description: "New creator draft staged in the local content repository.",
            creator: streamingStore.activeViewingProfile.displayName,
            genre: "Drama",
            tags: ["Draft", "Creator"],
            runtime: "Draft"
        )
        if let created {
            hydrateDraftWorkspace(from: created)
        }
        draftWorkspaceNotice = streamingStore.creatorDraftSyncRuntimeSnapshot.state == .synced ? "New draft created through remote PublishingRepository" : "New draft created in content snapshot"
    }

    private func archiveDraftWorkspace() async {
        guard let selectedDraftID else { return }
        await streamingStore.archiveRemoteCreatorDraft(id: selectedDraftID)
        if let nextDraft = streamingStore.creatorDraftProjects.first {
            hydrateDraftWorkspace(from: nextDraft)
        } else {
            await createNewWorkspaceDraft()
        }
        draftWorkspaceNotice = streamingStore.creatorDraftSyncRuntimeSnapshot.state == .synced ? "Draft archived through remote PublishingRepository" : "Draft archived locally"
    }

    private func draftTextField(title: String, text: Binding<String>, identifier: String, lineLimit: Int = 1) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Text(title)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.gold)
            TextField(title, text: text, axis: lineLimit > 1 ? .vertical : .horizontal)
                .font(HFTypography.caption.weight(.semibold))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(lineLimit)
                .textInputAutocapitalization(.words)
                .padding(HFSpacing.sm)
                .background(Color.black.opacity(0.28))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                .accessibilityIdentifier(identifier)
        }
    }

    private func draftAssetStatusControl(title: String, selection: Binding<HFCreatorPublishingAssetStatus>, identifier: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(title)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(HFColors.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.xs) {
                    ForEach(HFCreatorPublishingAssetStatus.allCases, id: \.self) { status in
                        Button {
                            selection.wrappedValue = status
                        } label: {
                            HFCreatorStudioPill(title: status.rawValue, isActive: selection.wrappedValue == status)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(identifier)
    }

    private func draftValidationRow(_ item: HFCreatorDraftValidationItem) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: item.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(item.isComplete ? HFColors.gold : HFColors.cyanGlow)
                .frame(width: 38, height: 38)
                .background((item.isComplete ? HFColors.gold : HFColors.cyanGlow).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(item.status)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(item.isComplete ? HFColors.gold : HFColors.cyanGlow)
                    .lineLimit(1)
                Text(item.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.draftWorkspace.validation.\(item.id)")
    }

    private func draftCompareRow(_ record: HFCreatorDraftCompareRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(record.state == "Edited" ? HFColors.violet : HFColors.gold)
                .frame(width: 38, height: 38)
                .background((record.state == "Edited" ? HFColors.violet : HFColors.gold).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(record.field)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer(minLength: 0)
                    Text(record.state)
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(record.state == "Edited" ? HFColors.violet : HFColors.gold)
                }
                Text("Saved: \(record.savedValue)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                Text("Editor: \(record.editorValue)")
                    .font(HFTypography.micro.weight(.semibold))
                    .foregroundStyle(HFColors.cyanGlow)
                    .lineLimit(2)
            }
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.draftWorkspace.compare.\(record.id)")
    }

    private func draftHistoryRow(_ record: HFCreatorDraftHistoryRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 38, height: 38)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(record.status)
                    .font(HFTypography.micro.weight(.black))
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.draftWorkspace.history.\(record.id)")
    }

    private func draftSyncQueueRow(_ record: HFCreatorDraftSyncQueueRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.cyanGlow)
                .frame(width: 38, height: 38)
                .background(HFColors.cyanGlow.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(record.action.capitalized)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer(minLength: 0)
                    Text(record.result.capitalized)
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(HFColors.gold)
                }
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
                Text(record.createdAt)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(HFColors.textSecondary.opacity(0.82))
                    .lineLimit(1)
            }
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.draftSync.queue.\(record.id)")
    }

    private func draftRevisionRow(_ record: HFCreatorDraftRevisionRecord) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 38, height: 38)
                .background(HFColors.gold.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: HFSpacing.xs) {
                    Text(record.action.capitalized)
                        .font(HFTypography.caption.weight(.bold))
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer(minLength: 0)
                    Text("v\(record.version)")
                        .font(HFTypography.micro.weight(.black))
                        .foregroundStyle(HFColors.gold)
                }
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
                Text(record.createdAt)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(HFColors.textSecondary.opacity(0.82))
                    .lineLimit(1)
            }
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.draftSync.revision.\(record.id)")
    }

    private func draftSyncEmptyRow(title: String, detail: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.violet)
                .frame(width: 38, height: 38)
                .background(HFColors.violet.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(3)
            }
            Spacer(minLength: 0)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func integrationAccent(for category: String) -> Color {
        switch category {
        case "CMS", "Catalog", "Architecture", "Sync":
            return HFColors.cyanGlow
        case "Revenue", "Commerce", "Security":
            return HFColors.gold
        case "Rights", "Creator":
            return HFColors.violet
        default:
            return HFColors.textSecondary
        }
    }

    private func productionAccent(for category: String) -> Color {
        switch category {
        case "CMS", "Catalog", "Viewer", "Library", "Search", "Notifications":
            return HFColors.cyanGlow
        case "Creator", "Creator Studio", "Marketplace", "Rights", "Licensing":
            return HFColors.violet
        case "Revenue", "Insights", "Analytics":
            return HFColors.gold
        default:
            return HFColors.textSecondary
        }
    }

    private func productionEnvironmentAccent(for availability: String) -> Color {
        availability == "Available" ? HFColors.gold : HFColors.textSecondary
    }

    private func environmentAccent(for status: String) -> Color {
        status == "Active" ? HFColors.gold : HFColors.cyanGlow
    }

    private func creatorPublishingProjectCard(_ project: HFCreatorPublishingContent) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: project.releaseState == .published ? "checkmark.seal.fill" : "doc.text.image.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(project.releaseState == .published ? HFColors.gold : HFColors.cyanGlow)
                Text(project.releaseState.rawValue)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(project.releaseState == .published ? HFColors.gold : HFColors.textSecondary)
                    .lineLimit(1)
            }

            Text(project.title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(project.updatedAtLabel)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            Spacer(minLength: 0)

            Text(project.discoveryEligible ? "Discovery connected" : "Library only")
                .font(HFTypography.micro.weight(.semibold))
                .foregroundStyle(project.discoveryEligible ? HFColors.cyanGlow : HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(width: 168, height: 146, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(project.releaseState == .published ? HFColors.gold.opacity(0.34) : HFColors.violet.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.title). \(project.releaseState.rawValue). \(project.updatedAtLabel).")
        .accessibilityIdentifier(accessibilityIdentifier(for: project.releaseState))
    }

    private func accessibilityIdentifier(for state: HFCreatorReleaseState) -> String {
        switch state {
        case .draft:
            return "hf.creator.pipeline.drafts"
        case .review:
            return "hf.creator.pipeline.review"
        case .scheduled:
            return "hf.creator.pipeline.scheduled"
        case .published:
            return "hf.creator.pipeline.published"
        case .archived:
            return "hf.creator.pipeline.archived"
        }
    }

    private var projectPipelineSection: some View {
        creatorProSpotlight(
            title: "Project Pipeline",
            detail: "Look, trailer, sound, campaign, and VOD steps stay staged as local review states.",
            systemImage: "point.3.connected.trianglepath.dotted",
            accent: HFColors.violet,
            identifier: "hf.creator.pro.projectPipeline"
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HFCreatorStudioPill(title: "Look", isActive: selectedTool == .look)
                HFCreatorStudioPill(title: "Trailer", isActive: selectedTool == .trailer)
                HFCreatorStudioPill(title: "Social", isActive: selectedTool == .social)
            }
        }
    }

    private var releaseReadinessSection: some View {
        creatorProSpotlight(
            title: "Release Readiness",
            detail: didSaveLocalDraft ? "Local draft is marked for review." : "Local draft is ready to review before launch planning.",
            systemImage: "checkmark.seal.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pro.releaseReadiness"
        ) {
            Button {
                didSaveLocalDraft = true
            } label: {
                HFCreatorStudioAction(title: didSaveLocalDraft ? "Draft Ready" : "Mark Ready", systemImage: "checkmark.seal.fill", isPrimary: true)
            }
            .buttonStyle(.plain)
        }
    }

    private var socialAssetKitSection: some View {
        creatorProSpotlight(
            title: "Social Asset Kit",
            detail: "Poster note, caption draft, vertical reel note, and story copy stay local.",
            systemImage: "bubble.left.and.bubble.right.fill",
            accent: HFColors.violet,
            identifier: "hf.creator.pro.socialAssetKit"
        ) {
            Button {
                select(.social)
            } label: {
                HFCreatorStudioAction(title: "Review Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .buttonStyle(.plain)
        }
    }

    private var vodPackageStatusSection: some View {
        creatorProSpotlight(
            title: "VOD Package Status",
            detail: "Trailer, poster, synopsis, access notes, and release copy are grouped for local review.",
            systemImage: "play.rectangle.on.rectangle.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pro.vodPackage"
        ) {
            Button {
                select(.vod)
            } label: {
                HFCreatorStudioAction(title: "Review VOD Package", systemImage: "play.rectangle.on.rectangle.fill")
            }
            .buttonStyle(.plain)
        }
    }

    private var analyticsPreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            creatorProSpotlight(
                title: "Performance Overview",
                detail: "Local analytics computed from catalog, viewing progress, searches, saves, publishing state, and creator profiles.",
                systemImage: "chart.bar.xaxis",
                accent: HFColors.cyanGlow,
                identifier: "hf.analytics.dashboard"
            ) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: HFSpacing.xs)], spacing: HFSpacing.xs) {
                    ForEach(streamingStore.analyticsViewerMetrics.prefix(4)) { metric in
                        creatorProStat(title: metric.title, value: metric.value)
                    }
                }
            }

            analyticsMetricGrid
            topTitleAnalyticsSection
            discoverySourcesSection
            creatorAnalyticsSection
            analyticsIntelligenceSection
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.creator.pro.analyticsPreview")
    }

    private var analyticsMetricGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
            ForEach(streamingStore.analyticsViewerMetrics) { metric in
                analyticsMetricCard(metric)
            }
        }
        .accessibilityIdentifier("hf.analytics.viewer")
    }

    private var topTitleAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Top Titles", actionTitle: "Content")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(streamingStore.analyticsTitleRecords.prefix(6)) { record in
                        titleAnalyticsCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityIdentifier("hf.analytics.content")
        .accessibilityIdentifier("hf.analytics.topTitles")
    }

    private var discoverySourcesSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Label("Discovery Sources", systemImage: "sparkle.magnifyingglass")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                ForEach(streamingStore.analyticsDiscoveryRecords) { record in
                    discoveryAnalyticsRow(record)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityIdentifier("hf.analytics.discovery")
        .accessibilityIdentifier("hf.analytics.discoverySources")
    }

    private var creatorAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Recent Growth", actionTitle: "Creators")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(streamingStore.analyticsCreatorRecords.prefix(6)) { record in
                        creatorAnalyticsCard(record)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityIdentifier("hf.analytics.creator")
        .accessibilityIdentifier("hf.analytics.recentGrowth")
        .accessibilityIdentifier("hf.analytics.audienceEngagement")
    }

    private var analyticsIntelligenceSection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Label("Analytics Intelligence", systemImage: "lightbulb.max.fill")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(streamingStore.analyticsInsights) { insight in
                        analyticsInsightCard(insight)
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityIdentifier("hf.analytics.intelligence")
        .accessibilityIdentifier("hf.analytics.insights")
    }

    private var launchControlPreviewSection: some View {
        creatorProSpotlight(
            title: "Launch Control Preview",
            detail: "A local launch review surface keeps release, campaign, and room steps visible.",
            systemImage: "sparkles.tv.fill",
            accent: HFColors.gold,
            identifier: "hf.creator.pro.launchControl"
        ) {
            HStack(spacing: HFSpacing.xs) {
                HFCreatorStudioPill(title: "Review", isActive: true)
                HFCreatorStudioPill(title: "Local")
            }
        }
    }

    private var commentaryGatewaySection: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.34)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 50, height: 50)
                    .background(HFColors.cyanGlow)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Commentary Room Gateway")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Creator notes, watch-party context, and commentary entry stay local to this project.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Commentary room gateway. Creator notes and watch party context stay local.")
        .accessibilityIdentifier("hf.creator.pro.commentaryGateway")
    }

    private func creatorProSpotlight<Content: View>(
        title: String,
        detail: String,
        systemImage: String,
        accent: Color,
        identifier: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(accent == HFColors.gold ? .black : accent)
                    .frame(width: 42, height: 42)
                    .background(accent == HFColors.gold ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(accent.opacity(0.16)))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text(detail)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(detail)")
        .accessibilityIdentifier(identifier)
    }

    private func creatorProStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.black.opacity(0.24))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }

    private func analyticsMetricCard(_ metric: HFAnalyticsMetric) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.cyanGlow.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: metric.systemImage)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(HFColors.cyanGlow)
                Text(metric.value)
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                Text(metric.title)
                    .font(HFTypography.micro.weight(.bold))
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                Text(metric.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(2)
            }
            .padding(HFSpacing.sm)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(metric.title), \(metric.value). \(metric.detail)")
        .accessibilityIdentifier("hf.analytics.viewer.\(metric.id)")
    }

    private func titleAnalyticsCard(_ record: HFTitleAnalyticsRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.gold.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HFPosterCard(movie: record.movie, width: 112, showTitle: false, posterOnly: true)
                Text(record.movie.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)

                HStack(spacing: HFSpacing.xs) {
                    analyticsMiniPill("\(record.totalViews)", "Views", HFColors.gold)
                    analyticsMiniPill("\(record.completionRate)%", "Complete", HFColors.cyanGlow)
                }

                Text("\(record.averageWatchTime) avg • \(record.libraryAdds) adds • \(record.favorites) favorites")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(2)
                Text("\(record.sharesPlaceholder) local share placeholders")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.violet)
                    .lineLimit(1)
            }
            .padding(HFSpacing.sm)
            .frame(width: 146, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.movie.title), \(record.totalViews) views, \(record.completionRate) percent completion.")
        .accessibilityIdentifier("hf.analytics.title.\(record.id)")
    }

    private func discoveryAnalyticsRow(_ record: HFDiscoveryAnalyticsRecord) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: record.systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 34, height: 34)
                .background(HFColors.gold.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xxs, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(record.title)
                    .font(HFTypography.caption.weight(.bold))
                    .foregroundStyle(HFColors.textPrimary)
                Text(record.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(record.value)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.analytics.discovery.\(record.id)")
    }

    private func creatorAnalyticsCard(_ record: HFCreatorAnalyticsRecord) -> some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.violet.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HStack(spacing: HFSpacing.xs) {
                    Image(systemName: "person.crop.rectangle.stack.fill")
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(HFColors.violet)
                    Text(record.growthTrend)
                        .font(HFTypography.micro.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                }
                Text(record.creatorName)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
                Text(record.topContent)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                HStack(spacing: HFSpacing.xs) {
                    analyticsMiniPill("\(record.views)", "Views", HFColors.cyanGlow)
                    analyticsMiniPill(record.watchTime, "Watch", HFColors.gold)
                }
                Text("\(record.publishedTitles) published • \(record.followers) local followers")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(2)
            }
            .padding(HFSpacing.sm)
            .frame(width: 176, alignment: .topLeading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.analytics.creator.\(record.id)")
    }

    private func analyticsInsightCard(_ insight: HFAnalyticsInsight) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: insight.systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.violet)
            Text(insight.value)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
            Text(insight.title)
                .font(HFTypography.micro.weight(.bold))
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
            Text(insight.detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("hf.analytics.insight.\(insight.id)")
    }

    private func analyticsMiniPill(_ value: String, _ title: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(HFTypography.micro.weight(.black))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.70)
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 5)
        .padding(.horizontal, 6)
        .background(color.opacity(0.13))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var creatorInspector: some View {
        HFSpatialInspectorChrome(
            title: "Creative Inspector",
            detail: "Local status, provider boundaries, and package notes stay secondary to the film worktable.",
            accent: HFColors.gold
        ) {
            VStack(spacing: HFSpacing.xs) {
                HFCreatorStudioReadinessRow(title: "Local Draft", detail: didSaveLocalDraft ? "Saved in local preview state." : "Available for this project.", status: "Local", systemImage: "pencil", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.creatorStudio.localDraft")
                HFCreatorStudioReadinessRow(title: "Provider-ready", detail: "Creator package fields are staged without live provider behavior.", status: "Ready", systemImage: "checkmark.seal.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.creatorStudio.providerReady")
                HFCreatorStudioReadinessRow(title: "Not Connected Yet", detail: "External platform, storefront, and entitlement systems are outside this local preview.", status: "Boundary", systemImage: "network.slash", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.creatorStudio.notConnected")
                HFCreatorStudioReadinessRow(title: "Creative assets", detail: "Poster placeholder, trailer placeholder, synopsis, and sound notes are local.", status: "5 items", systemImage: "rectangle.stack.fill", accent: HFColors.violet)
                HFCreatorStudioReadinessRow(title: "No live publishing", detail: "No upload, social posting, provider session, or platform action is active.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.violet)
                    .accessibilityIdentifier("hf.creatorStudio.noLivePublishing")
                HFCreatorStudioReadinessRow(title: "No live VOD provider", detail: "No storefront, distribution, entitlement, or payment action is active.", status: "Safe", systemImage: "lock.shield.fill", accent: HFColors.gold)
                    .accessibilityIdentifier("hf.creatorStudio.noLiveVODProvider")
            }
        }
        .accessibilityIdentifier("hf.creatorStudio.inspector")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 54, height: 54)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Creator Studio")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text("Build the Release, Prepare the Social Kit, and Package the VOD for local review.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var focusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(HFCreatorStudioFocus.allCases) { focus in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFocus = focus
                        }
                    } label: {
                        Text(focus.rawValue)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(selectedFocus == focus ? .black : HFColors.textPrimary)
                            .padding(.horizontal, HFSpacing.md)
                            .frame(height: 36)
                            .background(selectedFocus == focus ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.10)))
                            .overlay(Capsule().stroke(selectedFocus == focus ? Color.clear : HFColors.glassStroke, lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var backendReadinessSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                sectionLead(
                    title: "Backend Readiness",
                    detail: "Local Draft actions stay available while Creator, Social, and VOD providers remain Not Connected Yet.",
                    systemImage: "server.rack",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.xs) {
                    HFCreatorStudioReadinessRow(
                        title: "Creator Studio Backend",
                        detail: streamingStore.creatorStudioBackendStatus.statusLabel,
                        status: streamingStore.creatorStudioBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.creatorStudioBackendStatus.systemImage,
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.backendStatus")

                    HFCreatorStudioReadinessRow(
                        title: "Social Media Backend",
                        detail: streamingStore.socialKitBackendStatus.statusLabel,
                        status: streamingStore.socialKitBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.socialKitBackendStatus.systemImage,
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.creatorStudio.socialBackendStatus")

                    HFCreatorStudioReadinessRow(
                        title: "VOD Backend",
                        detail: streamingStore.vodBackendStatus.statusLabel,
                        status: streamingStore.vodBackendStatus.isConfigured ? "Configured" : "Not Connected Yet",
                        systemImage: streamingStore.vodBackendStatus.systemImage,
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.vodBackendStatus")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio backend readiness \(streamingStore.backendStatus.statusLabel)")
    }

    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Current Project", actionTitle: "Tonight on HighFive")

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "film.stack.fill")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 48, height: 48)
                            .background(HFColors.gold.opacity(0.13))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("\(streamingStore.featuredMovie.title) Creator Slate")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Current project, local project status, and creator profile context stay inside this app.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFCreatorStudioMetric(title: "Current project", detail: streamingStore.featuredMovie.title, systemImage: "sparkles.tv.fill", isActive: true)
                        HFCreatorStudioMetric(title: "Local project status", detail: "Local Draft", systemImage: "pencil")
                        HFCreatorStudioMetric(title: "Creator profile", detail: streamingStore.activeViewingProfile.displayName, systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                        HFCreatorStudioMetric(title: "Provider boundary", detail: "Not Connected Yet", systemImage: "network.slash")
                    }

                    VStack(spacing: HFSpacing.sm) {
                        Button {
                            didSaveLocalDraft = true
                        } label: {
                            HFCreatorStudioAction(title: "Build the Release", systemImage: "checkmark.seal.fill", isPrimary: true)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.creatorStudio.primaryAction")
                        .accessibilityIdentifier("hf.creatorStudio.buildTheRelease")

                        Button {
                            selectedFocus = .socialMediaKit
                        } label: {
                            HFCreatorStudioAction(title: "Prepare the Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")

                        Button {
                            selectedFocus = .vodPackage
                        } label: {
                            HFCreatorStudioAction(title: "Package the VOD", systemImage: "play.rectangle.on.rectangle.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.creatorStudio.packageVOD")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Studio Dashboard, local project status, creator profile context")
        .accessibilityIdentifier("hf.creatorStudio.dashboard")
        .accessibilityIdentifier("hf.creatorStudio.currentProject")
        .accessibilityIdentifier("hf.creatorStudio.workspaceModules")
    }

    private var toolControlStrip: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Tool Control Strip", actionTitle: "Provider-ready")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    toolControlCard(title: "Project Slate", detail: "Current Project", systemImage: "film.stack.fill", identifier: "hf.creatorStudio.projectSlate", focus: .dashboard)
                    toolControlCard(title: "Asset Board", detail: "Poster + clip placeholders", systemImage: "photo.on.rectangle.angled", identifier: "hf.creatorStudio.assetBoard", focus: .dashboard)
                    toolControlCard(title: "Caption Lab", detail: "Caption Drafts", systemImage: "text.quote", identifier: "hf.creatorStudio.captionLab", focus: .socialMediaKit)
                    toolControlCard(title: "Social Media Kit", detail: "Review Social Kit", systemImage: "bubble.left.and.bubble.right.fill", identifier: "hf.creatorStudio.socialMediaKit", focus: .socialMediaKit)
                    toolControlCard(title: "Instagram Connect", detail: "Not Connected Yet", systemImage: "camera.viewfinder", identifier: "hf.creatorStudio.instagramConnect", focus: .instagramConnect)
                    toolControlCard(title: "VOD Package", detail: "Preview VOD Package", systemImage: "shippingbox.fill", identifier: "hf.creatorStudio.vodPackage", focus: .vodPackage)
                    toolControlCard(title: "Release Checklist", detail: "Build the Release", systemImage: "checklist.checked", identifier: "hf.creatorStudio.releaseChecklist", focus: .vodPackage)
                    toolControlCard(title: "Provider Readiness", detail: "Not Connected Yet", systemImage: "network.slash", identifier: "hf.creatorStudio.providerReadiness", focus: .instagramConnect)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityIdentifier("hf.creatorStudio.toolControlStrip")
    }

    private func toolControlCard(title: String, detail: String, systemImage: String, identifier: String, focus: HFCreatorStudioFocus) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFocus = focus
            }
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(selectedFocus == focus ? .black : HFColors.gold)
                    .frame(width: 36, height: 36)
                    .background(selectedFocus == focus ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                    .clipShape(Circle())

                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)

                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
            .frame(width: 136, height: 132, alignment: .topLeading)
            .padding(HFSpacing.sm)
            .background(selectedFocus == focus ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.065))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(selectedFocus == focus ? HFColors.gold.opacity(0.42) : HFColors.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private var socialMediaKitSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Social Media Kit", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.orange.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "Social Media Kit",
                        detail: "Build local captions, poster notes, and platform readiness before any account is connected.",
                        systemImage: "bubble.left.and.bubble.right.fill",
                        accent: Color.orange
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }

                    Button {
                        selectedFocus = .socialMediaKit
                    } label: {
                        HFCreatorStudioAction(title: "Prepare the Social Kit", systemImage: "bubble.left.and.bubble.right.fill", isPrimary: selectedFocus == .socialMediaKit)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Caption Drafts")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.socialCaptionDrafts")

                        ForEach(captionDraftCards) { draft in
                            HFCreatorStudioReadinessRow(title: draft.title, detail: draft.detail, status: "Local Draft", systemImage: "text.quote", accent: Color.orange)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFCreatorStudioMetric(title: "Poster", detail: "Placeholder", systemImage: "photo.fill")
                        HFCreatorStudioMetric(title: "Clip", detail: "Placeholder", systemImage: "play.rectangle.fill")
                        HFCreatorStudioMetric(title: "Trailer pull", detail: "Local Draft", systemImage: "film.fill")
                        HFCreatorStudioMetric(title: "Caption set", detail: "Local Draft", systemImage: "text.bubble.fill")
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Platform readiness")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.socialPlatformReadiness")

                        ForEach(socialPlatformRows) { platform in
                            HFCreatorStudioReadinessRow(title: platform.title, detail: platform.detail, status: "Not Connected Yet", systemImage: "network.slash", accent: Color.orange)
                        }
                    }

                    instagramConnectMiniCard

                    HFCreatorStudioReadinessRow(
                        title: "No live publishing",
                        detail: "Local planning only. No account connection, posting, sharing, or provider SDK is active.",
                        status: "Safe Boundary",
                        systemImage: "lock.shield.fill",
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.creatorStudio.noLivePublishing")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Social Media Kit, Local Draft, Provider-ready, Not Connected Yet, local-only release boundary")
        .accessibilityIdentifier("hf.creatorStudio.socialMediaKit")
        .accessibilityIdentifier("hf.creatorStudio.prepareSocialKit")
    }

    private var instagramConnectMiniCard: some View {
        Button {
            selectedFocus = .instagramConnect
        } label: {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [HFColors.gold, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Instagram Connect")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Local Social Draft is ready to preview while Instagram stays Not Connected Yet.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
            .background(Color.white.opacity(0.065))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(Color.orange.opacity(0.26), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("hf.creatorStudio.instagramConnect")
    }

    private var instagramConnectSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Instagram Connect", actionTitle: "Provider-ready")

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.orange.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "Instagram Connect",
                        detail: "Preview a Local Social Draft and provider readiness before any account, backend, or permissions are connected.",
                        systemImage: "camera.viewfinder",
                        accent: Color.orange
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Social Draft", isActive: true)
                            .accessibilityIdentifier("hf.instagramConnect.localDraft")
                        HFCreatorStudioPill(title: "Provider-ready")
                            .accessibilityIdentifier("hf.instagramConnect.providerReady")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                            .accessibilityIdentifier("hf.instagramConnect.notConnected")
                    }
                    .accessibilityIdentifier("hf.instagramConnect.status")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Account Readiness")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.instagramConnect.accountReadiness")

                        HFCreatorStudioReadinessRow(title: "Instagram account", detail: "Not Connected Yet", status: "Waiting", systemImage: "person.crop.circle.badge.questionmark", accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.notConnected")
                        HFCreatorStudioReadinessRow(title: "Creator identity", detail: "Local profile only", status: "Local Draft", systemImage: streamingStore.activeViewingProfile.avatarSymbol, accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.creatorIdentity")
                        HFCreatorStudioReadinessRow(title: "Permission review", detail: "Required later", status: "Waiting", systemImage: "checkmark.shield.fill", accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.permissionStatus")
                        HFCreatorStudioReadinessRow(title: "Backend vault", detail: "Required later", status: "Boundary", systemImage: "lock.shield.fill", accent: Color.orange)
                            .accessibilityIdentifier("hf.instagramConnect.backendRequired")
                    }

                    instagramDraftPreview

                    VStack(spacing: HFSpacing.sm) {
                        Button {
                            didSaveLocalDraft = true
                        } label: {
                            HFCreatorStudioAction(title: "Save Local Draft", systemImage: "square.and.arrow.down", isPrimary: true)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.instagramConnect.saveLocalDraft")

                        Button {
                            didSaveLocalDraft = true
                        } label: {
                            HFCreatorStudioAction(title: "Copy Local Caption", systemImage: "doc.on.doc")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.instagramConnect.copyLocalCaption")

                        Button {
                            selectedFocus = .socialMediaKit
                        } label: {
                            HFCreatorStudioAction(title: "Preview Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("hf.instagramConnect.previewSocialKit")
                    }

                    HFCreatorStudioReadinessRow(
                        title: "No live Instagram provider",
                        detail: "No live posting, no account session, and no OAuth credentials are active in this app.",
                        status: "Provider-ready only",
                        systemImage: "lock.shield.fill",
                        accent: Color.orange
                    )
                    .accessibilityIdentifier("hf.instagramConnect.noLiveProvider")
                    .accessibilityIdentifier("hf.instagramConnect.noLivePosting")
                    .accessibilityIdentifier("hf.instagramConnect.noOAuthTokens")
                    .accessibilityIdentifier("hf.instagramConnect.localOnlyBoundary")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Instagram Connect, Provider-ready, Not Connected Yet, Local Social Draft")
        .accessibilityIdentifier("hf.instagramConnect.screen")
        .accessibilityIdentifier("hf.creatorStudio.instagramConnect")
    }

    private var instagramDraftPreview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Post Draft Preview")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .accessibilityIdentifier("hf.instagramConnect.postDraftPreview")

            HStack(alignment: .top, spacing: HFSpacing.sm) {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Caption draft")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                    Text("Tonight on HighFive: choose the scene you would replay first.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("hf.instagramConnect.captionDraft")
                    Text("#HighFiveCinema #TheFriendly #LocalSocialDraft")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .accessibilityIdentifier("hf.instagramConnect.hashtagDraft")
                }

                Spacer(minLength: HFSpacing.sm)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                HFCreatorStudioMetric(title: "Poster placeholder", detail: "Local", systemImage: "photo.fill")
                    .accessibilityIdentifier("hf.instagramConnect.posterPlaceholder")
                HFCreatorStudioMetric(title: "Clip placeholder", detail: "Local", systemImage: "play.rectangle.fill")
                    .accessibilityIdentifier("hf.instagramConnect.clipPlaceholder")
                HFCreatorStudioMetric(title: "Alt text draft", detail: "Local", systemImage: "text.alignleft")
                    .accessibilityIdentifier("hf.instagramConnect.altTextDraft")
                HFCreatorStudioMetric(title: "Call-to-watch", detail: "HighFive", systemImage: "play.tv.fill")
            }
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(Color.orange.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }

    private var vodPackageSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "VOD Package", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    sectionLead(
                        title: "VOD Package",
                        detail: "Prepare trailer, poster, synopsis, and provider-readiness before distribution is connected.",
                        systemImage: "shippingbox.fill",
                        accent: HFColors.gold
                    )

                    HStack(spacing: HFSpacing.xs) {
                        HFCreatorStudioPill(title: "Local Draft", isActive: true)
                        HFCreatorStudioPill(title: "Provider-ready")
                        HFCreatorStudioPill(title: "Not Connected Yet")
                    }

                    Button {
                        selectedFocus = .vodPackage
                    } label: {
                        HFCreatorStudioAction(title: "Package the VOD", systemImage: "play.rectangle.on.rectangle.fill", isPrimary: selectedFocus == .vodPackage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("hf.creatorStudio.packageVOD")

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("VOD release checklist")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.vodChecklist")

                        ForEach(vodChecklistRows) { item in
                            HFCreatorStudioReadinessRow(title: item.title, detail: item.detail, status: item.status, systemImage: item.systemImage, accent: HFColors.gold)
                        }
                    }

                    packagePreviewCard
                    vodEntitlementBoundary

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Provider status")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .accessibilityIdentifier("hf.creatorStudio.vodProviderStatus")

                        HFCreatorStudioReadinessRow(title: "Distribution provider", detail: "Distribution provider — Not Connected Yet", status: "Provider-ready", systemImage: "network.slash", accent: HFColors.gold)
                        HFCreatorStudioReadinessRow(title: "Storefront provider", detail: "Storefront provider — Not Connected Yet", status: "Provider-ready", systemImage: "cart.badge.questionmark", accent: HFColors.gold)
                        HFCreatorStudioReadinessRow(title: "Payment / entitlement provider", detail: "Payment Provider Not Connected Yet", status: "Provider-ready", systemImage: "checkmark.shield.fill", accent: HFColors.gold)
                            .accessibilityIdentifier("hf.entitlement.status")
                    }
                    .accessibilityIdentifier("hf.creatorStudio.vodProviderStatus")

                    HFCreatorStudioReadinessRow(
                        title: "No live VOD provider",
                        detail: "No live VOD release, payments, media delivery, or file export is active.",
                        status: "Safe Boundary",
                        systemImage: "lock.shield.fill",
                        accent: HFColors.gold
                    )
                    .accessibilityIdentifier("hf.creatorStudio.noLiveVODProvider")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("VOD Package, VOD release checklist, provider status Not Connected Yet")
        .accessibilityIdentifier("hf.creatorStudio.vodPackage")
        .accessibilityIdentifier("hf.creatorStudio.releasePrep")
        .accessibilityIdentifier("hf.creatorStudio.packageVOD")
    }

    private var vodEntitlementBoundary: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Pricing / entitlement boundary")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .accessibilityIdentifier("hf.creatorStudio.vodPricingBoundary")

            HFCreatorStudioReadinessRow(
                title: "Local Draft",
                detail: "VOD pricing remains a local planning boundary.",
                status: "Local Draft",
                systemImage: "pencil",
                accent: HFColors.gold
            )

            HFCreatorStudioReadinessRow(
                title: "Provider-ready",
                detail: "Pricing and entitlement records are staged without a live payment provider.",
                status: "Provider-ready",
                systemImage: "checkmark.shield.fill",
                accent: HFColors.gold
            )
            .accessibilityIdentifier("hf.creatorStudio.vodEntitlementBoundary")

            HFCreatorStudioReadinessRow(
                title: "Payment Provider Not Connected Yet",
                detail: "Server Entitlement Validation Required before paid VOD access.",
                status: "Boundary",
                systemImage: "creditcard.and.123",
                accent: HFColors.gold
            )
            .accessibilityIdentifier("hf.entitlement.status")

            HFCreatorStudioReadinessRow(
                title: "No live VOD provider",
                detail: "No live VOD provider. No payment activation, media delivery, or distributor handoff is active.",
                status: "Safe Boundary",
                systemImage: "lock.shield.fill",
                accent: HFColors.gold
            )
            .accessibilityIdentifier("hf.creatorStudio.noLiveVODProvider")
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityIdentifier("hf.creatorStudio.vodEntitlementBoundary")
    }

    private var localDraftActions: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Local Draft", actionTitle: nil)

            VStack(spacing: HFSpacing.sm) {
                Button {
                    selectedFocus = .socialMediaKit
                } label: {
                    HFCreatorStudioAction(title: "Review Social Kit", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.reviewSocialKit")

                Button {
                    selectedFocus = .instagramConnect
                } label: {
                    HFCreatorStudioAction(title: "Preview Instagram Draft", systemImage: "camera.viewfinder")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.previewInstagramDraft")

                Button {
                    selectedFocus = .vodPackage
                } label: {
                    HFCreatorStudioAction(title: "Preview VOD Package", systemImage: "play.rectangle.on.rectangle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.previewVODPackage")

                Button {
                    didSaveLocalDraft = true
                } label: {
                    HFCreatorStudioAction(title: didSaveLocalDraft ? "Local Draft Saved" : "Save Local Draft", systemImage: "square.and.arrow.down", isPrimary: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.localDraft")
                .accessibilityIdentifier("hf.creatorStudio.saveLocalDraft")

                Button {
                    dismiss()
                } label: {
                    HFCreatorStudioAction(title: "Back to Profile", systemImage: "person.crop.circle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.creatorStudio.backToProfile")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var packagePreviewCard: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Package preview")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)

            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: "play.rectangle.on.rectangle.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(streamingStore.featuredMovie.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Synopsis, poster placeholder, trailer placeholder, release mood, and Local Draft status are grouped for review.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
    }

    private var captionDraftCards: [HFCreatorStudioDraftCard] {
        [
            HFCreatorStudioDraftCard(title: "Premiere", detail: "Tonight on HighFive: choose the scene you would replay first."),
            HFCreatorStudioDraftCard(title: "Behind the Shot", detail: "Move the frame and peek into the moment."),
            HFCreatorStudioDraftCard(title: "Creator Note", detail: "Poster, mood, and trailer direction are ready for review.")
        ]
    }

    private var socialPlatformRows: [HFCreatorStudioDraftCard] {
        [
            HFCreatorStudioDraftCard(title: "Instagram - Not Connected Yet", detail: "Poster drop - Provider-ready"),
            HFCreatorStudioDraftCard(title: "TikTok - Not Connected Yet", detail: "Trailer clip - Provider-ready"),
            HFCreatorStudioDraftCard(title: "YouTube Shorts - Not Connected Yet", detail: "Short caption - Provider-ready"),
            HFCreatorStudioDraftCard(title: "X / Threads - Not Connected Yet", detail: "Creator prompt - Provider-ready")
        ]
    }

    private var vodChecklistRows: [HFCreatorStudioChecklistRow] {
        [
            HFCreatorStudioChecklistRow(title: "Trailer readiness", detail: "Trailer placeholder is staged for review.", status: "Local Draft", systemImage: "film.fill"),
            HFCreatorStudioChecklistRow(title: "Poster readiness", detail: "Poster placeholder is ready for notes.", status: "Placeholder", systemImage: "photo.fill"),
            HFCreatorStudioChecklistRow(title: "Synopsis readiness", detail: "Synopsis copy stays editable locally.", status: "Local Draft", systemImage: "text.alignleft"),
            HFCreatorStudioChecklistRow(title: "Metadata readiness", detail: "Title, genre, and release mood are grouped.", status: "Local Draft", systemImage: "tag.fill"),
            HFCreatorStudioChecklistRow(title: "Pricing / entitlement boundary", detail: "No payment flow is active.", status: "Boundary", systemImage: "checkmark.shield.fill"),
            HFCreatorStudioChecklistRow(title: "Distribution provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "network.slash"),
            HFCreatorStudioChecklistRow(title: "Storefront provider", detail: "Not Connected Yet", status: "Provider-ready", systemImage: "cart.badge.questionmark")
        ]
    }

    private func sectionLead(title: String, detail: String, systemImage: String, accent: Color) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 48, height: 48)
                .background(accent.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(title)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text(detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct HFCreatorStudioPill: View {
    let title: String
    var isActive = false

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(isActive ? .black : HFColors.gold)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.xs)
            .frame(height: 24)
            .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.10)))
            .overlay(Capsule().stroke(isActive ? Color.clear : HFColors.gold.opacity(0.24), lineWidth: 1))
            .clipShape(Capsule())
    }
}

private struct HFCreatorStudioDraftCard: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

private struct HFCreatorStudioChecklistRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFCreatorStudioMetric: View {
    let title: String
    let detail: String
    let systemImage: String
    var isActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(isActive ? .black : HFColors.gold)
                .frame(width: 30, height: 30)
                .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 102, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFCreatorStudioReadinessRow: View {
    let title: String
    let detail: String
    let status: String
    let systemImage: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(accent)
                .frame(width: 32, height: 32)
                .background(accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(accent.opacity(0.10))
                .overlay(Capsule().stroke(accent.opacity(0.26), lineWidth: 1))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFCreatorStudioAction: View {
    let title: String
    let systemImage: String
    var isPrimary = false

    var body: some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
        }
        .font(HFTypography.smallAction)
        .foregroundStyle(isPrimary ? .black : HFColors.textPrimary)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .padding(.horizontal, HFSpacing.md)
        .background(isPrimary ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
        .overlay(Capsule().stroke(isPrimary ? Color.clear : HFColors.glassStroke, lineWidth: 1))
        .clipShape(Capsule())
    }
}
