import SwiftUI

struct CreatorReleaseReadinessPreviewView: View {
    @StateObject private var workflowStore = HFCreatorWorkflowStore()

    private let readyItems = [
        "Poster artwork approved",
        "Metadata reviewed",
        "Scene stills organized",
        "Version history active"
    ]

    private let launchPath = [
        ReleasePathItem(title: "Package builder", systemImage: "shippingbox.fill", route: .packageBuilder),
        ReleasePathItem(title: "Asset manager", systemImage: "rectangle.stack.fill", route: .assetManager),
        ReleasePathItem(title: "Submission workflow", systemImage: "paperplane.fill", route: .submissionWorkflow),
        ReleasePathItem(title: "Team review", systemImage: "person.3.fill", route: .teamReview),
        ReleasePathItem(title: "Marketplace preview", systemImage: "storefront.fill", route: .marketplace),
        ReleasePathItem(title: "Launch center", systemImage: "flag.checkered", route: .launchCenter)
    ]

    private let comingNext = [
        "Real launch checklist",
        "Release calendar",
        "Approval routing",
        "Distribution status",
        "Revenue tracking"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Creator Mode", "Command Center", "Release Readiness"])
                releaseScoreSection
                blockingItemsSection
                readyItemsSection
                launchPathSection
                previewChecklistSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Release Readiness")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Release Readiness")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Preview what needs to be done before a project is ready for launch.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Local readiness cards do not connect to launch services.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var releaseScoreSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Release Score", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                HFReadinessScoreCard(title: "Overall readiness", value: "\(Int(workflowStore.releaseReadiness.overall * 100))%", progress: workflowStore.releaseReadiness.overall)
                HFReadinessScoreCard(title: "Package", value: "\(Int(workflowStore.releaseReadiness.package * 100))%", progress: workflowStore.releaseReadiness.package, systemImage: "shippingbox.fill")
                HFReadinessScoreCard(title: "Assets", value: "\(Int(workflowStore.releaseReadiness.assets * 100))%", progress: workflowStore.releaseReadiness.assets, systemImage: "rectangle.stack.fill")
                HFReadinessScoreCard(title: "Team review", value: "\(Int(workflowStore.releaseReadiness.teamReview * 100))%", progress: workflowStore.releaseReadiness.teamReview, systemImage: "person.3.fill")
                HFReadinessScoreCard(title: "Marketplace", value: "Preview Only", progress: nil, systemImage: "storefront.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var blockingItemsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Release Blockers", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(workflowStore.releaseBlockers) { blocker in
                        HFReleaseBlockerRow(title: blocker.title, status: blocker.status, systemImage: blocker.systemImage)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var readyItemsSection: some View {
        checklistSection(title: "Ready Items", items: readyItems, isReady: true)
    }

    private func checklistSection(title: String, items: [String], isReady: Bool) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: isReady ? HFColors.goldStroke : HFColors.glassStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(items, id: \.self) { item in
                        if isReady {
                            HFBlockingItemRow(title: item, isReady: true)
                        } else {
                            HFReleaseBlockerRow(title: item, status: item == "Team sign-off pending" ? "Pending" : "Blocking")
                        }
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
                        HFActionTile(title: item.title, subtitle: "Open preview", systemImage: item.systemImage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(item.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var previewChecklistSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Preview Launch Checklist", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Text("Mock checklist only. The future launch flow will collect release calendar, approval, distribution, and marketplace signals.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: "checklist")
                            Text("Preview Launch Checklist")
                        }
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(HFSpacing.md)
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

    @ViewBuilder
    private func destination(for route: ReleasePathRoute) -> some View {
        switch route {
        case .packageBuilder:
            CreatorPackageBuilderPreviewView()
        case .assetManager:
            CreatorAssetManagerPreviewView()
        case .submissionWorkflow:
            CreatorSubmissionWorkflowPreviewView()
        case .teamReview:
            CreatorTeamReviewPreviewView()
        case .marketplace:
            CreatorMarketplacePreviewView()
        case .launchCenter:
            CreatorLaunchCenterPreviewView()
        }
    }
}

private enum ReleasePathRoute {
    case packageBuilder
    case assetManager
    case submissionWorkflow
    case teamReview
    case marketplace
    case launchCenter
}

private struct ReleasePathItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let route: ReleasePathRoute
}
