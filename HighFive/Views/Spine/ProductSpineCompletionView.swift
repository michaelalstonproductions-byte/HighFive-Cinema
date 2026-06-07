import SwiftUI

struct ProductSpineCompletionView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["HighFive", "Product Spine", "Completion"])
                spineSnapshotSection
                routeCoverageSection
                completeForNowSection
                comesLaterSection
                productSpineRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Spine Completion")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Local structure", isProminent: true)

            Text("Product Spine Completion")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Review the local HighFive spine before the final visual pass.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var spineSnapshotSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Spine Snapshot", actionTitle: nil)
            HFBreadcrumbTrail(items: ["Watch", "Create", "Connect", "Launch", "Export"])

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 230), spacing: HFSpacing.md)], spacing: HFSpacing.md) {
                ForEach(HFProductSpineCompletionData.pillars) { pillar in
                    HFProductSpinePillarCard(pillar: pillar)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var routeCoverageSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.lg) {
            HFSectionHeader(title: "Route Coverage", actionTitle: nil)

            ForEach(["Watch", "Create", "Connect", "Launch", "Export"], id: \.self) { pillar in
                routeGroup(title: pillar, items: HFProductSpineCompletionData.routes(for: pillar))
            }
        }
    }

    private func routeGroup(title: String, items: [HFProductSpineRouteItem]) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            Text(title)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.gold)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            VStack(spacing: HFSpacing.md) {
                ForEach(items) { item in
                    HFProductSpineRouteLink(item: item) {
                        HFProductSpineRouteCard(item: item, showsRouteCue: item.routeType != "static")
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var completeForNowSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "What Is Complete Enough For Now", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                HFInsightCard(title: "Product spine is navigable", message: "Watch, Create, Connect, Launch, and Export can be reviewed as a complete local product structure.", systemImage: "arrow.triangle.branch")
                HFInsightCard(title: "Local preview data explains each pillar", message: "The current routes use static SwiftUI data and local mock state only.", systemImage: "doc.text.fill")
                HFInsightCard(title: "Major routes are discoverable", message: "A reviewer can walk the key surfaces without real backend, account, payment, upload, capture, or share systems.", systemImage: "map.fill")
                HFInsightCard(title: "Real systems remain locked", message: "Anything real requires a separate scoped phase before implementation.", systemImage: "lock.shield.fill")
                HFInsightCard(title: "Visual parity is intentionally deferred", message: "Mockup matching starts after the product structure is stable and QA-ready.", systemImage: "rectangle.3.group.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var comesLaterSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "What Comes Later", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: HFSpacing.md)], spacing: HFSpacing.md) {
                ForEach([
                    ("Figma/mockup parity", "rectangle.3.group.fill"),
                    ("Pixel-level spacing", "ruler.fill"),
                    ("Typography lock", "textformat.size"),
                    ("Poster/backdrop visual treatment", "photo.fill"),
                    ("Motion/transition polish", "sparkles"),
                    ("Final brand pass", "paintpalette.fill")
                ], id: \.0) { item in
                    HFEcosystemCard(title: item.0, subtitle: "Later visual parity work after spine lock.", systemImage: item.1, status: "Later", minWidth: 220)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var productSpineRule: some View {
        HFInsightCard(
            title: "Product Spine Rule",
            message: "Finish and QA the spine before changing visual identity. Visual parity starts only after the product structure is stable.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

struct HFProductSpineRouteLink<Label: View>: View {
    let item: HFProductSpineRouteItem
    private let label: () -> Label

    init(item: HFProductSpineRouteItem, @ViewBuilder label: @escaping () -> Label) {
        self.item = item
        self.label = label
    }

    var body: some View {
        if item.routeType.hasPrefix("movie:") {
            NavigationLink(value: movie(for: item.routeType)) {
                label()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(item.title)")
        } else if item.routeType == "locked" || item.routeType == "static" {
            label()
                .accessibilityLabel(item.title)
        } else {
            NavigationLink {
                destination(for: item.routeType)
            } label: {
                label()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(item.title)")
        }
    }

    private func movie(for routeType: String) -> Movie {
        if routeType == "movie:black-turnip" {
            return HFMockData.movie("black-turnip") ?? HFMockData.movies[0]
        }

        return HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    @ViewBuilder
    private func destination(for routeType: String) -> some View {
        switch routeType {
        case "unifiedDiscovery":
            UnifiedDiscoveryView()
                .padding(.top, HFSpacing.lg)
                .background(HFColors.screenBackground.ignoresSafeArea())
        case "myList":
            MyListView()
        case "downloads":
            DownloadsView()
        case "creatorMode":
            CreatorEntryView()
        case "creatorCommand":
            CreatorWorkflowCommandCenterView()
        case "packageBuilder":
            CreatorPackageBuilderPreviewView()
        case "assetManager":
            CreatorAssetManagerPreviewView()
        case "teamReview":
            CreatorTeamReviewPreviewView()
        case "releaseReadiness":
            CreatorReleaseReadinessPreviewView()
        case "connectHub":
            ConnectHubView()
        case "socialRooms":
            SocialRoomsPreviewView()
        case "creatorCircles":
            CreatorCirclesPreviewView()
        case "activityFeed":
            ActivityFeedPreviewView()
        case "socialGraph":
            SocialGraphPreviewView()
        case "followSuggestions":
            FollowSuggestionsPreviewView()
        case "connectNotifications":
            ConnectNotificationsPreviewView()
        case "launchCenter":
            CreatorLaunchCenterPreviewView()
        case "accessPreview":
            CreatorAccessPreviewView()
        case "releasePresentation":
            AppReleasePresentationView()
        case "demoChecklist":
            AppDemoChecklistView()
        case "releaseCandidatePrep":
            ReleaseCandidatePrepView()
        default:
            Text("This local route is locked until separately scoped.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(HFColors.screenBackground.ignoresSafeArea())
        }
    }
}
