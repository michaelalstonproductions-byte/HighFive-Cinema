import SwiftUI

struct PersonalizedHubView: View {
    private var featuredMovie: Movie {
        HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Discover", "For You"])
                smartSummarySection
                commandCenterSection
                recommendedNextSection
                becauseYouWatchedSection
                becauseYouCreateSection
                becauseYouConnectSection
                recommendedPathSection
                previewNotice
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("For You")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("For You")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Personalized paths across watching, creating, launching, and connecting.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. These paths are curated from local mock data.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var smartSummarySection: some View {
        HFSmartSummaryCard(signals: HFPersonalizationPreviewData.smartSignals)
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var commandCenterSection: some View {
        NavigationLink {
            EcosystemCommandCenterView()
        } label: {
            HFActionTile(
                title: "Open Command Center",
                subtitle: "See today's ecosystem path across Watch, Create, Connect, Launch, and Access.",
                systemImage: "command"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open HighFive Command Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var recommendedNextSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recommended Next", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink(value: featuredMovie) {
                    fullWidthRecommendationCard(HFPersonalizationPreviewData.recommendedNext[0])
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Continue Watching")

                NavigationLink {
                    CreatorPackageBuilderPreviewView()
                } label: {
                    fullWidthRecommendationCard(HFPersonalizationPreviewData.recommendedNext[1])
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Continue Package Builder")

                NavigationLink {
                    CreatorReleaseReadinessPreviewView()
                } label: {
                    fullWidthRecommendationCard(HFPersonalizationPreviewData.recommendedNext[2])
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Release Readiness")

                NavigationLink {
                    ConnectHubView()
                } label: {
                    fullWidthRecommendationCard(HFPersonalizationPreviewData.recommendedNext[3])
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Explore Connect")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var becauseYouWatchedSection: some View {
        recommendationRail(title: "Because You Watched") {
            ForEach(HFPersonalizationPreviewData.viewerRecommendations) { recommendation in
                personalizedLink(for: recommendation)
            }
        }
    }

    private var becauseYouCreateSection: some View {
        recommendationRail(title: "Because You Create") {
            ForEach(HFPersonalizationPreviewData.creatorRecommendations) { recommendation in
                personalizedLink(for: recommendation)
            }
        }
    }

    private var becauseYouConnectSection: some View {
        recommendationRail(title: "Because You Connect") {
            ForEach(HFPersonalizationPreviewData.connectRecommendations) { recommendation in
                personalizedLink(for: recommendation)
            }
        }
    }

    private var recommendedPathSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recommended Path", actionTitle: nil)

            HFRecommendedPathCard(path: HFPersonalizationPreviewData.recommendedPath)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(HFPersonalizationPreviewData.launchRecommendations) { recommendation in
                        personalizedLink(for: recommendation)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    private var previewNotice: some View {
        HFInsightCard(
            title: "Smart paths are local",
            message: "Recommendations are static preview cards. No accounts, services, or automated decision system is connected.",
            systemImage: "lock.shield.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func recommendationRail<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
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

    private func fullWidthRecommendationCard(_ recommendation: HFPersonalizedRecommendation) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: recommendation.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(recommendation.title)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: HFSpacing.xs)
                        HFStatusBadge(title: recommendation.accentLabel, isProminent: false)
                    }

                    Text(recommendation.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HFRecommendationReasonBadge(reason: recommendation.reason)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
        }
    }

    @ViewBuilder
    private func personalizedLink(for recommendation: HFPersonalizedRecommendation) -> some View {
        switch recommendation.destinationType {
        case "movie:friendly":
            NavigationLink(value: HFMockData.movie("friendly") ?? HFMockData.movies[0]) {
                HFRecommendationCard(recommendation: recommendation)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(recommendation.title)")
        case "movie:black-turnip":
            NavigationLink(value: HFMockData.movie("black-turnip") ?? HFMockData.movies[0]) {
                HFRecommendationCard(recommendation: recommendation)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(recommendation.title)")
        default:
            NavigationLink {
                destination(for: recommendation.destinationType)
            } label: {
                HFRecommendationCard(recommendation: recommendation)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open \(recommendation.title)")
        }
    }

    @ViewBuilder
    private func destination(for type: String) -> some View {
        switch type {
        case "packageBuilder":
            CreatorPackageBuilderPreviewView()
        case "assetManager":
            CreatorAssetManagerPreviewView()
        case "submissionWorkflow":
            CreatorSubmissionWorkflowPreviewView()
        case "teamReview":
            CreatorTeamReviewPreviewView()
        case "versionHistory":
            CreatorVersionHistoryPreviewView()
        case "releaseReadiness":
            CreatorReleaseReadinessPreviewView()
        case "launchCenter":
            CreatorLaunchCenterPreviewView()
        case "accessPreview":
            CreatorAccessPreviewView()
        case "demoChecklist":
            AppDemoChecklistView()
        case "connectHub":
            ConnectHubView()
        case "creatorProfile":
            CreatorProfilePreviewView(creator: HFConnectPreviewData.featuredCreators[0])
        case "socialRooms":
            SocialRoomsPreviewView()
        case "creatorCircles":
            CreatorCirclesPreviewView()
        case "watchParty":
            WatchPartyPreviewView()
        case "activityFeed":
            ActivityFeedPreviewView()
        default:
            UnifiedDiscoveryView()
        }
    }
}
