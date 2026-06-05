import SwiftUI

struct CreatorLaunchCenterPreviewView: View {
    @StateObject private var workflowStore = HFCreatorWorkflowStore()

    private let launchPath = [
        CreatorLaunchPathItem(title: "Package Builder", subtitle: "Continue package assembly", systemImage: "shippingbox.fill", route: .packageBuilder),
        CreatorLaunchPathItem(title: "Asset Manager", subtitle: "Review artwork and preview materials", systemImage: "rectangle.stack.fill", route: .assetManager),
        CreatorLaunchPathItem(title: "Submission Workflow", subtitle: "Resolve submission gates", systemImage: "paperplane.fill", route: .submissionWorkflow),
        CreatorLaunchPathItem(title: "Team Review", subtitle: "Handle internal notes and sign-off", systemImage: "person.3.fill", route: .teamReview),
        CreatorLaunchPathItem(title: "Version History", subtitle: "Track review rounds and package changes", systemImage: "clock.arrow.circlepath", route: .versionHistory),
        CreatorLaunchPathItem(title: "Release Readiness", subtitle: "Preview release blockers and ready items", systemImage: "gauge.with.dots.needle.67percent", route: .releaseReadiness),
        CreatorLaunchPathItem(title: "Marketplace Preview", subtitle: "Check audience-facing package signals", systemImage: "storefront.fill", route: .marketplace),
        CreatorLaunchPathItem(title: "Access Preview", subtitle: "Preview local unlock models", systemImage: "lock.shield.fill", route: .accessPreview)
    ]

    private let comingNext = [
        "Release calendar",
        "Distribution controls",
        "Audience cohorts",
        "Monetization setup",
        "Creator payouts"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Creator Mode", "Launch Center"])
                launchSummarySection
                launchChecklistSection
                launchPathSection
                audiencePreviewSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Launch Center")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Launch Center")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.76)

            Text("Prepare your package for audience, marketplace, and release readiness.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Launch planning cards are local mock data.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var launchSummarySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Launch Summary", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "flag.checkered")
                                .font(.system(size: 30, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }
                        .frame(width: 68, height: 68)

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text(workflowStore.currentProjectTitle)
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: HFSpacing.xs) {
                                HFStatusBadge(title: "Preview Planning")
                                HFStatusBadge(title: "Preview Only", isProminent: false)
                            }
                        }

                        Spacer(minLength: HFSpacing.xs)
                    }

                    HFProgressBar(title: "Release readiness", value: workflowStore.launchReadiness)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                        HFMetricCard(title: "Marketplace readiness", value: "Preview Only", systemImage: "storefront.fill")
                        HFMetricCard(title: "Audience interest", value: "\(workflowStore.audienceSaves) saves", systemImage: "bookmark.fill")
                    }

                    NavigationLink {
                        CreatorReleaseReadinessPreviewView()
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Review Launch Plan")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .black))
                        }
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Review Launch Plan")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var launchChecklistSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Launch Checklist", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(workflowStore.launchChecklist) { item in
                        launchChecklistRow(item)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var launchPathSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Launch Path", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(launchPath) { item in
                    NavigationLink {
                        destination(for: item.route)
                    } label: {
                        HFActionTile(title: item.title, subtitle: item.subtitle, systemImage: item.systemImage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(item.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var audiencePreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Audience Preview", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                HFMetricCard(title: "Saves", value: workflowStore.audienceSaves, systemImage: "bookmark.fill")
                HFMetricCard(title: "Trailer interest", value: "24.8K views", systemImage: "play.rectangle.fill")
                HFMetricCard(title: "Completion signal", value: "74%", systemImage: "chart.line.uptrend.xyaxis")
                HFMetricCard(title: "Marketplace follows", value: "\(workflowStore.marketplaceFollows)", systemImage: "person.2.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var comingNextSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Coming Next", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(comingNext, id: \.self) { item in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 22)
                            Text(item)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func launchChecklistRow(_ item: HFCreatorLaunchChecklistItem) -> some View {
        HStack(spacing: HFSpacing.md) {
            Image(systemName: item.systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 36, height: 36)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            Text(item.title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: HFSpacing.xs)

            HFStatusBadge(title: item.status, isProminent: item.status == "In Progress")
        }
        .padding(.vertical, HFSpacing.xxs)
    }

    @ViewBuilder
    private func destination(for route: CreatorLaunchRoute) -> some View {
        switch route {
        case .packageBuilder:
            CreatorPackageBuilderPreviewView()
        case .assetManager:
            CreatorAssetManagerPreviewView()
        case .submissionWorkflow:
            CreatorSubmissionWorkflowPreviewView()
        case .teamReview:
            CreatorTeamReviewPreviewView()
        case .versionHistory:
            CreatorVersionHistoryPreviewView()
        case .releaseReadiness:
            CreatorReleaseReadinessPreviewView()
        case .marketplace:
            CreatorMarketplacePreviewView()
        case .accessPreview:
            CreatorAccessPreviewView()
        }
    }
}

private enum CreatorLaunchRoute {
    case packageBuilder
    case assetManager
    case submissionWorkflow
    case teamReview
    case versionHistory
    case releaseReadiness
    case marketplace
    case accessPreview
}

private struct CreatorLaunchPathItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let route: CreatorLaunchRoute
}
