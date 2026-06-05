import SwiftUI

struct UnifiedDiscoveryView: View {
    @State private var selectedFilter = "All"

    private var showMovies: Bool {
        selectedFilter == "All" || selectedFilter == "Movies"
    }

    private var showCreators: Bool {
        selectedFilter == "All" || selectedFilter == "Creators" || selectedFilter == "Marketplace" || selectedFilter == "Launch"
    }

    private var showCommunities: Bool {
        selectedFilter == "All" || selectedFilter == "Communities" || selectedFilter == "Watch Parties"
    }

    private var filteredTrendingItems: [HFTrendingEcosystemItem] {
        guard selectedFilter != "All" else {
            return HFEcosystemPreviewData.trendingItems
        }

        return HFEcosystemPreviewData.trendingItems.filter { item in
            item.category == selectedFilter ||
            (selectedFilter == "Marketplace" && item.category == "Creators") ||
            (selectedFilter == "Watch Parties" && item.title.localizedCaseInsensitiveContains("Room"))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xl) {
            header
            discoveryFilters

            if showMovies {
                contentDiscoverySection
            }

            if showCreators {
                creatorDiscoverySection
            }

            if showCommunities {
                communityDiscoverySection
            }

            trendingSection
            previewNotice
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Discover HighFive")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Movies, creators, communities, and launch-ready projects.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var discoveryFilters: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Discovery Filters", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.xs) {
                    ForEach(HFEcosystemPreviewData.discoveryFilters, id: \.self) { filter in
                        HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                        .accessibilityLabel("Select \(filter) local discovery filter")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var contentDiscoverySection: some View {
        discoveryGrid(title: "Content Discovery") {
            NavigationLink(value: HFMockData.movie("friendly") ?? HFMockData.movies[0]) {
                discoveryCard(HFEcosystemPreviewData.contentCategories[0], status: "Watch")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open movie discovery preview")

            NavigationLink(value: HFMockData.onlyOnHighFive.movies.first ?? HFMockData.movies[0]) {
                discoveryCard(HFEcosystemPreviewData.contentCategories[1], status: "Originals")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open originals discovery preview")

            NavigationLink(value: HFMockData.movies.first(where: \.isComingSoon) ?? HFMockData.movies[0]) {
                discoveryCard(HFEcosystemPreviewData.contentCategories[2], status: "Soon")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open coming soon title preview")

            NavigationLink {
                DownloadsView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.contentCategories[3], status: "Local")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Downloads preview")

            NavigationLink {
                MyListView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.contentCategories[4], status: "Saved")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open My List preview")
        }
    }

    private var creatorDiscoverySection: some View {
        discoveryGrid(title: "Creator Discovery") {
            NavigationLink {
                CreatorStudioPreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.creatorCategories[0], status: "Preview")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Studio Preview")

            NavigationLink {
                CreatorDashboardPreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.creatorCategories[1], status: "Mock")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Dashboard Preview")

            NavigationLink {
                CreatorMarketplacePreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.creatorCategories[2], status: "Preview")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Marketplace Preview")

            NavigationLink {
                CreatorWorkflowCommandCenterView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.creatorCategories[3], status: "72%")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Command Center")

            NavigationLink {
                CreatorLaunchCenterPreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.creatorCategories[4], status: "Launch")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Launch Center")
        }
    }

    private var communityDiscoverySection: some View {
        discoveryGrid(title: "Community Discovery") {
            NavigationLink {
                ConnectHubView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.communityCategories[0], status: "Connect")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Connect Hub")

            NavigationLink {
                SocialRoomsPreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.communityCategories[1], status: "Rooms")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Social Rooms")

            NavigationLink {
                CreatorCirclesPreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.communityCategories[2], status: "Circles")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Circles")

            NavigationLink {
                WatchPartyPreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.communityCategories[3], status: "Mock")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Watch Party Preview")

            NavigationLink {
                ProjectCommunityPreviewView()
            } label: {
                discoveryCard(HFEcosystemPreviewData.communityCategories[4], status: "Project")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Project Community")
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Trending Now", actionTitle: nil)

            if filteredTrendingItems.isEmpty {
                HFEmptyState(
                    title: "No local matches",
                    message: "Switch filters to browse more movies, creators, communities, and launch previews.",
                    systemImage: "sparkles"
                )
                .padding(.horizontal, HFSpacing.screenHorizontal)
            } else {
                VStack(spacing: HFSpacing.md) {
                    ForEach(filteredTrendingItems) { item in
                        trendingCard(item)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var previewNotice: some View {
        HFInsightCard(
            title: "Unified discovery is local",
            message: "Filters, creator routes, community cards, and launch previews use local mock data only.",
            systemImage: "lock.shield.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func discoveryGrid<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    content()
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    private func discoveryCard(_ category: HFDiscoveryCategory, status: String) -> some View {
        HFEcosystemCard(
            title: category.title,
            subtitle: category.subtitle,
            systemImage: category.systemImage,
            status: status,
            minWidth: 214
        )
    }

    private func trendingCard(_ item: HFTrendingEcosystemItem) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(item.title)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: HFSpacing.xs)
                        HFStatusBadge(title: item.status, isProminent: false)
                    }

                    Text(item.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}
