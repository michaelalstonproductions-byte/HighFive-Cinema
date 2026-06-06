import SwiftUI

struct EcosystemCommandCenterView: View {
    private var featuredMovie: Movie {
        HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["HighFive", "Command Center"])
                previewNotice
                snapshotSection
                prioritiesSection
                smartNextStepSection
                commandSection(title: "Watch", items: HFEcosystemCommandData.watchItems)
                commandSection(title: "Create", items: HFEcosystemCommandData.createItems)
                commandSection(title: "Connect", items: HFEcosystemCommandData.connectItems)
                commandSection(title: "Launch + Access", items: HFEcosystemCommandData.launchItems)
                commandSection(title: "Personalized", items: HFEcosystemCommandData.personalizedItems)
                commandSection(title: "Demo / Preview", items: HFEcosystemCommandData.demoItems)
                safetyFooter
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Command Center")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Preview mode", isProminent: true)

            Text("HighFive Command Center")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.72)

            Text("A local dashboard for the connected cinema ecosystem: watch stories, build creator packages, connect communities, preview launch readiness, and open personalized recommendations.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Watch stories. Build creator packages. Follow communities. Launch cinematic work.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var smartNextStepSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recommended Path / Smart Next Step", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Text("Start here")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)

                    Text("Follow the local demo path from viewing into creation, community, launch readiness, and access preview.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        ForEach(HFEcosystemCommandData.smartNextStepPath) { step in
                            HStack(spacing: HFSpacing.xs) {
                                Image(systemName: step.systemImage)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(HFColors.gold)

                                Text(step.title)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.82)
                            }
                            .padding(.horizontal, HFSpacing.sm)
                            .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                            .background(HFColors.gold.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                                    .stroke(HFColors.goldStroke, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                        }
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var snapshotSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Ecosystem Snapshot", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(HFEcosystemCommandData.metrics) { metric in
                    HFEcosystemMetricCard(metric: metric)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var prioritiesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Today's Priorities", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFEcosystemCommandData.priorities) { priority in
                    commandLink(for: priority.destinationType) {
                        HFEcosystemPriorityCard(priority: priority)
                    }
                    .accessibilityLabel("Open \(priority.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func commandSection(title: String, items: [HFEcosystemCommandItem]) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ForEach(items) { item in
                        commandLink(for: item.destinationType) {
                            HFEcosystemCommandCard(item: item)
                        }
                        .accessibilityLabel("Open \(item.title)")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    private var previewNotice: some View {
        HFEcosystemPreviewNotice()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var safetyFooter: some View {
        HFInsightCard(
            title: "Demo shell only",
            message: "Command Center routes are local SwiftUI previews or safe placeholders. Future backend, payment, upload, capture, playback, and protected depth systems remain disconnected.",
            systemImage: "shield.lefthalf.filled"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    @ViewBuilder
    private func commandLink<Label: View>(for destinationType: String, @ViewBuilder label: () -> Label) -> some View {
        if destinationType.hasPrefix("movie:") {
            NavigationLink(value: movie(for: destinationType)) {
                label()
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink {
                destination(for: destinationType)
            } label: {
                label()
            }
            .buttonStyle(.plain)
        }
    }

    private func movie(for destinationType: String) -> Movie {
        if destinationType == "movie:black-turnip" {
            return HFMockData.movie("black-turnip") ?? HFMockData.movies[0]
        }

        return featuredMovie
    }

    @ViewBuilder
    private func destination(for type: String) -> some View {
        switch type {
        case "home":
            Text("Home is available from the bottom tab.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(HFColors.screenBackground.ignoresSafeArea())
        case "discover":
            UnifiedDiscoveryView()
                .padding(.top, HFSpacing.lg)
                .background(HFColors.screenBackground.ignoresSafeArea())
        case "personalizedHub":
            PersonalizedHubView()
        case "myList":
            MyListView()
        case "downloads":
            DownloadsView()
        case "creatorHub":
            CreatorEntryView()
        case "creatorCommand":
            CreatorWorkflowCommandCenterView()
        case "creatorStudio":
            CreatorStudioPreviewView()
        case "creatorDashboard":
            CreatorDashboardPreviewView()
        case "creatorMarketplace":
            CreatorMarketplacePreviewView()
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
        case "teamPermissions":
            CreatorTeamPermissionsPreviewView()
        case "connectHub":
            ConnectHubView()
        case "communityDiscovery":
            CommunityDiscoveryPreviewView()
        case "socialRooms":
            SocialRoomsPreviewView()
        case "creatorCircles":
            CreatorCirclesPreviewView()
        case "watchParty":
            WatchPartyPreviewView()
        case "projectCommunity":
            ProjectCommunityPreviewView()
        case "activityFeed":
            ActivityFeedPreviewView()
        case "socialGraph":
            SocialGraphPreviewView()
        case "followSuggestions":
            FollowSuggestionsPreviewView()
        case "connectNotifications":
            ConnectNotificationsPreviewView()
        case "releaseReadiness":
            CreatorReleaseReadinessPreviewView()
        case "launchCenter":
            CreatorLaunchCenterPreviewView()
        case "accessPreview":
            CreatorAccessPreviewView()
        case "releasePresentation":
            AppReleasePresentationView()
        case "demoChecklist":
            AppDemoChecklistView()
        case "onboardingPreview":
            AppOnboardingPreviewView()
        default:
            PersonalizedHubView()
        }
    }
}
