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
                productSpineSection
                commandSection(title: "Watch", items: HFEcosystemCommandData.watchItems)
                commandSection(title: "Create", items: HFEcosystemCommandData.createItems)
                commandSection(title: "Connect", items: HFEcosystemCommandData.connectItems)
                commandSection(title: "Launch + Access", items: HFEcosystemCommandData.launchItems)
                commandSection(title: "Personalized", items: HFEcosystemCommandData.personalizedItems)
                commandSection(title: "Demo / Preview", items: HFEcosystemCommandData.demoItems)
                finalDemoSection
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

            Text("The local map for HighFive: watch cinematic stories, build creator packages, connect communities, prepare launch readiness, and keep future export tools disconnected.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Watch -> Create -> Connect -> Launch -> Export")
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

                    Text("Follow the product path from viewing into creation, community, launch readiness, access preview, and future share-ready export planning.")
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

    private var finalDemoSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Final Demo / QA", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    NavigationLink {
                        FinalDemoTourView()
                    } label: {
                        HFEcosystemCard(
                            title: "Final Demo Tour",
                            subtitle: "Walk Watch, Create, Connect, Launch, and Export.",
                            systemImage: "map.fill",
                            status: "Local",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        DemoReviewChecklistView()
                    } label: {
                        HFEcosystemCard(
                            title: "Demo Review Checklist",
                            subtitle: "Review the static product walkthrough checklist.",
                            systemImage: "checklist.checked",
                            status: "QA",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ReleaseCandidatePrepView()
                    } label: {
                        HFEcosystemCard(
                            title: "Release Candidate Prep",
                            subtitle: "Lock the local product spine before final QA.",
                            systemImage: "checkmark.seal.fill",
                            status: "Prep",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ProductSpineLockdownView()
                    } label: {
                        HFEcosystemCard(
                            title: "Product Spine Lockdown",
                            subtitle: "Verify each pillar is discoverable and separated.",
                            systemImage: "rectangle.connected.to.line.below",
                            status: "Local",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    private var productSpineSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Product Spine Completion", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    NavigationLink {
                        ProductSpineCompletionView()
                    } label: {
                        HFEcosystemCard(
                            title: "Product Spine Completion",
                            subtitle: "Review Watch, Create, Connect, Launch, and Export before visual parity.",
                            systemImage: "rectangle.connected.to.line.below",
                            status: "Local",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SpineRouteCoverageView()
                    } label: {
                        HFEcosystemCard(
                            title: "Route Coverage",
                            subtitle: "Confirm each pillar has a safe local review path.",
                            systemImage: "arrow.triangle.branch",
                            status: "Map",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        LockedSystemsMapView()
                    } label: {
                        HFEcosystemCard(
                            title: "Locked Systems Map",
                            subtitle: "Keep real backend, payment, capture, share, and protected systems scoped later.",
                            systemImage: "lock.shield.fill",
                            status: "Locked",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        VisualParityBacklogView()
                    } label: {
                        HFEcosystemCard(
                            title: "Visual Parity Backlog",
                            subtitle: "Track mockup matching for a later visual pass.",
                            systemImage: "rectangle.3.group.fill",
                            status: "Later",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ProductSpineGapReviewView()
                    } label: {
                        HFEcosystemCard(
                            title: "Product Spine Gap Review",
                            subtitle: "Check route gaps before visual parity.",
                            systemImage: "exclamationmark.triangle.fill",
                            status: "Hardening",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PillarHardeningCenterView()
                    } label: {
                        HFEcosystemCard(
                            title: "Pillar Hardening Center",
                            subtitle: "Strengthen each product pillar before mockup matching.",
                            systemImage: "shield.lefthalf.filled",
                            status: "Local",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PreVisualLockView()
                    } label: {
                        HFEcosystemCard(
                            title: "Pre-Visual Lock",
                            subtitle: "Confirm the spine is stable before visual polish.",
                            systemImage: "checkmark.seal.fill",
                            status: "Gate",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        RouteQualityCenterView()
                    } label: {
                        HFEcosystemCard(
                            title: "Route Quality Center",
                            subtitle: "Clean up route clarity before the mockup pass.",
                            systemImage: "arrow.triangle.branch",
                            status: "Quality",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SpineNavigationMapView()
                    } label: {
                        HFEcosystemCard(
                            title: "Spine Navigation Map",
                            subtitle: "Map reviewer movement through the local product spine.",
                            systemImage: "map.fill",
                            status: "Map",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PreMockupReadinessReviewView()
                    } label: {
                        HFEcosystemCard(
                            title: "Pre-Mockup Readiness",
                            subtitle: "Confirm route quality before visual matching.",
                            systemImage: "checkmark.circle.fill",
                            status: "Gate",
                            minWidth: 230
                        )
                    }
                    .buttonStyle(.plain)
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
            message: "Command Center routes are local SwiftUI previews or safe placeholders. Future backend, payment, upload, capture, playback, export/share, and protected depth systems remain disconnected.",
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
