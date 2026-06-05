import SwiftUI

struct CreatorWorkflowCommandCenterView: View {
    @StateObject private var workflowStore = HFCreatorWorkflowStore()
    @StateObject private var notificationStore = HFNotificationCenterStore()

    private let stages = [
        CreatorWorkflowStage(title: "Studio", status: "Active", systemImage: "film.stack.fill", route: .studio),
        CreatorWorkflowStage(title: "Package Builder", status: "In Progress", systemImage: "shippingbox.fill", route: .packageBuilder),
        CreatorWorkflowStage(title: "Asset Manager", status: "Needs Review", systemImage: "rectangle.stack.fill", route: .assetManager),
        CreatorWorkflowStage(title: "Submission Workflow", status: "Draft Review", systemImage: "checklist", route: .submissionWorkflow),
        CreatorWorkflowStage(title: "Team Review", status: "Internal Review", systemImage: "person.3.fill", route: .teamReview),
        CreatorWorkflowStage(title: "Version History", status: "Tracking", systemImage: "clock.arrow.circlepath", route: .versionHistory),
        CreatorWorkflowStage(title: "Team Permissions", status: "Preview Only", systemImage: "person.3.sequence.fill", route: .teamPermissions),
        CreatorWorkflowStage(title: "Launch Center", status: "Preview Planning", systemImage: "flag.checkered", route: .launchCenter),
        CreatorWorkflowStage(title: "Marketplace", status: "Coming Soon", systemImage: "storefront.fill", route: .marketplace)
    ]

    private let criticalPath = [
        CreatorCriticalPathStep(title: "Finish trailer review", status: "Needs Review"),
        CreatorCriticalPathStep(title: "Confirm credits", status: "In Progress"),
        CreatorCriticalPathStep(title: "Complete submission notes", status: "Not Started"),
        CreatorCriticalPathStep(title: "Team sign-off", status: "Pending"),
        CreatorCriticalPathStep(title: "Marketplace preview", status: "Preview Only")
    ]

    private let actions = [
        CreatorPriorityAction(title: "Continue Package Builder", subtitle: "Confirm credits and submission notes.", systemImage: "shippingbox.fill", route: .packageBuilder),
        CreatorPriorityAction(title: "Review Assets", subtitle: "Open asset health and preview materials.", systemImage: "rectangle.stack.fill", route: .assetManager),
        CreatorPriorityAction(title: "Open Submission Workflow", subtitle: "Check gates before internal review.", systemImage: "paperplane.fill", route: .submissionWorkflow),
        CreatorPriorityAction(title: "Open Team Review", subtitle: "Resolve open reviewer notes.", systemImage: "person.3.fill", route: .teamReview),
        CreatorPriorityAction(title: "Check Release Readiness", subtitle: "Preview blockers and launch path.", systemImage: "gauge.with.dots.needle.67percent", route: .releaseReadiness),
        CreatorPriorityAction(title: "Open Launch Center", subtitle: "Preview audience, access, and launch planning.", systemImage: "flag.checkered", route: .launchCenter)
    ]

    private let comingNext = [
        "Real workflow automation",
        "Team assignments",
        "Approval routing",
        "Creator notifications",
        "Marketplace launch tools"
    ]

    private var signals: [CreatorCommandSignal] {
        [
            CreatorCommandSignal(title: "Draft packages", value: "3", systemImage: "shippingbox.fill"),
            CreatorCommandSignal(title: "Open review notes", value: "\(workflowStore.openReviewNotes)", systemImage: "text.bubble.fill"),
            CreatorCommandSignal(title: "Assets ready", value: "6 / 10", systemImage: "rectangle.stack.fill"),
            CreatorCommandSignal(title: "Team members", value: "\(workflowStore.teamMembersCount)", systemImage: "person.2.fill"),
            CreatorCommandSignal(title: "Version rounds", value: "3", systemImage: "clock.arrow.circlepath"),
            CreatorCommandSignal(title: "Launch readiness", value: "\(Int(workflowStore.launchReadiness * 100))%", systemImage: "flag.checkered"),
            CreatorCommandSignal(title: "Marketplace interest", value: "\(workflowStore.marketplaceInterest)", systemImage: "storefront.fill")
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Creator Mode", "Command Center"])
                ecosystemCommandShortcut
                commandSummarySection
                primaryActionSection
                recommendedNextSection
                releaseReadinessSection
                workflowCompletenessSection
                currentStageSection
                workflowProgressSection
                workflowHealthSection
                criticalPathSection
                jumpToStageSection
                workflowPipelineSection
                workflowSignalsSection
                nextBestActionSection
                priorityActionsSection
                recentlyUpdatedSection
                recentActivitySection
                notificationFeedSection
                comingNextSection
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
            Text("Creator Command Center")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.76)

            Text("Track every step from draft package to team review and marketplace readiness.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Local workflow cards show the future creator path.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var ecosystemCommandShortcut: some View {
        NavigationLink {
            EcosystemCommandCenterView()
        } label: {
            HFActionTile(
                title: "HighFive Command Center",
                subtitle: "Return to the full ecosystem dashboard.",
                systemImage: "command"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open HighFive Command Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var commandSummarySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Command Summary", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "command")
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
                                HFStatusBadge(title: workflowStore.selectedWorkflowStage)
                                Text("Marketplace readiness: Preview Only")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Spacer(minLength: HFSpacing.xs)
                    }

                    HFProgressBar(title: "Package completion", value: workflowStore.completionPercent)
                    HFProgressBar(title: "Review readiness", value: workflowStore.reviewReadinessPercent)

                    NavigationLink {
                        CreatorTeamReviewPreviewView()
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Continue Workflow")
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
                    .accessibilityLabel("Continue Workflow")
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var primaryActionSection: some View {
        HFFooterActionBar(title: "Release Candidate Actions") {
            NavigationLink {
                CreatorReleaseReadinessPreviewView()
            } label: {
                HFActionTile(
                    title: "Check Release Readiness",
                    subtitle: "Review blockers, ready items, and launch path.",
                    systemImage: "gauge.with.dots.needle.67percent"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Check Release Readiness")

            NavigationLink {
                CreatorPackageBuilderPreviewView()
            } label: {
                HFActionTile(
                    title: "Continue Package Builder",
                    subtitle: "Resolve credits and submission notes for the active package.",
                    systemImage: "shippingbox.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Continue Package Builder")

            NavigationLink {
                CreatorLaunchCenterPreviewView()
            } label: {
                HFActionTile(
                    title: "Open Launch Center",
                    subtitle: "Preview audience interest, access setup, and release planning.",
                    systemImage: "flag.checkered"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Launch Center")

            NavigationLink {
                CreatorAccessPreviewView()
            } label: {
                HFActionTile(
                    title: "Access Preview",
                    subtitle: "Review mock audience unlock models without payment logic.",
                    systemImage: "lock.shield.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Access Preview")
        }
    }

    private var releaseReadinessSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Release Readiness", actionTitle: nil)

            NavigationLink {
                CreatorReleaseReadinessPreviewView()
            } label: {
                HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                    VStack(alignment: .leading, spacing: HFSpacing.md) {
                        HStack(alignment: .top, spacing: HFSpacing.md) {
                            Image(systemName: "gauge.with.dots.needle.67percent")
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 60, height: 60)
                                .background(HFColors.gold.opacity(0.14))
                                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous))

                            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                                Text("72% Ready")
                                    .font(HFTypography.section)
                                    .foregroundStyle(HFColors.textPrimary)

                                Text("2 blockers, 5 open notes, and marketplace preview still pending.")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: HFSpacing.xs)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }

                        HFProgressBar(title: "Overall readiness", value: 0.72)
                    }
                    .padding(HFSpacing.md)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var recommendedNextSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recommended Next", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    CreatorPackageBuilderPreviewView()
                } label: {
                    HFActionTile(
                        title: "Finish Package Builder",
                        subtitle: "Complete credits, notes, and package details before review.",
                        systemImage: "shippingbox.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Finish Package Builder")

                NavigationLink {
                    CreatorReleaseReadinessPreviewView()
                } label: {
                    HFActionTile(
                        title: "Open Release Readiness",
                        subtitle: "Review the 72% launch path and remaining blockers.",
                        systemImage: "gauge.with.dots.needle.67percent"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Release Readiness")

                NavigationLink {
                    CreatorTeamPermissionsPreviewView()
                } label: {
                    HFActionTile(
                        title: "Review Team Permissions",
                        subtitle: "Preview local role clarity before team sign-off.",
                        systemImage: "person.3.sequence.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Review Team Permissions")

                NavigationLink {
                    ConnectHubView()
                } label: {
                    HFActionTile(
                        title: "Explore Connect Signals",
                        subtitle: "Open creator updates, rooms, and project community previews.",
                        systemImage: "person.2.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Explore Connect Signals")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var currentStageSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Current Stage", actionTitle: nil)

            NavigationLink {
                CreatorTeamReviewPreviewView()
            } label: {
                HFActionTile(
                    title: workflowStore.selectedWorkflowStage,
                    subtitle: "Current stage. Open reviewer notes, version history, and permissions from here.",
                    systemImage: "person.3.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open current stage Team Review")
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var workflowCompletenessSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Completeness", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(spacing: HFSpacing.md) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 48, height: 48)
                            .background(HFColors.gold.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                            Text("72% complete")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Team Review is the current stage. Release readiness is close, with two blockers left.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()
                    }

                    HFProgressBar(title: "Workflow completeness", value: workflowStore.completionPercent)
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var workflowProgressSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Progress", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        workflowProgressNode(
                            index: index + 1,
                            stage: stage,
                            isCurrent: stage.title == workflowStore.selectedWorkflowStage
                        )
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .scrollClipDisabled()
        }
    }

    private var workflowHealthSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Health", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                HFMetricCard(title: "Status", value: "On track", systemImage: "checkmark.seal.fill")
                HFMetricCard(title: "Blockers", value: "2", systemImage: "exclamationmark.triangle.fill")
                HFMetricCard(title: "Open notes", value: "\(workflowStore.openReviewNotes)", systemImage: "text.bubble.fill")
                HFMetricCard(title: "Recent updates", value: "3", systemImage: "sparkles")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var criticalPathSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Critical Path", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(Array(criticalPath.enumerated()), id: \.element.id) { index, step in
                    HFCriticalPathCard(index: index + 1, title: step.title, status: step.status)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var jumpToStageSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Jump to Stage", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(stages) { stage in
                    NavigationLink {
                        destination(for: stage.route)
                    } label: {
                        HFWorkflowStageRow(
                            title: stage.title,
                            status: stage.status,
                            systemImage: stage.systemImage,
                            isCurrent: stage.title == workflowStore.selectedWorkflowStage
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(stage.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var workflowPipelineSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Pipeline", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(stages) { stage in
                    NavigationLink {
                        destination(for: stage.route)
                    } label: {
                        CreatorWorkflowStageCard(
                            stage: stage,
                            isCurrent: stage.title == workflowStore.selectedWorkflowStage
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(stage.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var workflowSignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(signals) { signal in
                    HFMetricCard(title: signal.title, value: signal.value, systemImage: signal.systemImage)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var nextBestActionSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Next Best Action", actionTitle: nil)

            NavigationLink {
                CreatorPackageBuilderPreviewView()
            } label: {
                HFActionTile(
                    title: "Continue Package Builder",
                    subtitle: "Finish credits and notes before the review queue.",
                    systemImage: "shippingbox.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Continue Package Builder")
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var priorityActionsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Priority Actions", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(actions) { action in
                    NavigationLink {
                        destination(for: action.route)
                    } label: {
                        HFActionTile(title: action.title, subtitle: action.subtitle, systemImage: action.systemImage)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(action.title)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var recentlyUpdatedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recently Updated", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(Array(workflowStore.recentActivities.prefix(3))) { activity in
                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Image(systemName: activity.systemImage)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(HFColors.gold)

                            Text(activity.title)
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.78)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recent Activity", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(Array(workflowStore.recentActivities.enumerated()), id: \.element.id) { index, activity in
                        HFTimelineRow(
                            title: activity.title,
                            detail: activity.detail,
                            systemImage: activity.systemImage,
                            isLast: index == workflowStore.recentActivities.count - 1
                        )
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var notificationFeedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Notification Feed", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(spacing: HFSpacing.sm) {
                    let creatorNotifications = Array(notificationStore.creatorNotifications.prefix(4))
                    ForEach(Array(creatorNotifications.enumerated()), id: \.element.id) { index, item in
                        HFTimelineRow(
                            title: item.title,
                            detail: item.message,
                            systemImage: item.systemImage,
                            isLast: index == creatorNotifications.count - 1
                        )
                    }
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
    private func destination(for route: CreatorWorkflowRoute) -> some View {
        switch route {
        case .studio:
            CreatorStudioPreviewView()
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
        case .teamPermissions:
            CreatorTeamPermissionsPreviewView()
        case .marketplace:
            CreatorMarketplacePreviewView()
        case .releaseReadiness:
            CreatorReleaseReadinessPreviewView()
        case .launchCenter:
            CreatorLaunchCenterPreviewView()
        case .accessPreview:
            CreatorAccessPreviewView()
        }
    }

    private func workflowProgressNode(index: Int, stage: CreatorWorkflowStage, isCurrent: Bool) -> some View {
        NavigationLink {
            destination(for: stage.route)
        } label: {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Text("\(index)")
                    .font(HFTypography.micro)
                    .foregroundStyle(isCurrent ? .black : HFColors.gold)
                    .frame(width: 30, height: 30)
                    .background(isCurrent ? AnyShapeStyle(HFColors.gold) : AnyShapeStyle(HFColors.gold.opacity(0.14)))
                    .overlay(
                        Circle()
                            .stroke(HFColors.goldStroke, lineWidth: 1)
                    )
                    .clipShape(Circle())

                Text(stage.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                HFStatusBadge(title: stage.status, isProminent: isCurrent)
            }
            .frame(width: 150, alignment: .leading)
            .padding(HFSpacing.md)
            .background(isCurrent ? HFColors.gold.opacity(0.12) : HFColors.glassSurface)
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(isCurrent ? HFColors.goldStroke : HFColors.glassStroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private enum CreatorWorkflowRoute {
    case studio
    case packageBuilder
    case assetManager
    case submissionWorkflow
    case teamReview
    case versionHistory
    case teamPermissions
    case marketplace
    case releaseReadiness
    case launchCenter
    case accessPreview
}

private struct CreatorWorkflowStage: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
    let route: CreatorWorkflowRoute
}

private struct CreatorCommandSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct CreatorPriorityAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
    let route: CreatorWorkflowRoute
}

private struct CreatorCriticalPathStep: Identifiable {
    let id = UUID()
    let title: String
    let status: String
}

private struct CreatorWorkflowStageCard: View {
    let stage: CreatorWorkflowStage
    let isCurrent: Bool

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: stage.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(stage.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.xs)

                        HFStatusBadge(title: stage.status, isProminent: isCurrent)
                    }

                    Text(isCurrent ? "Current workflow stage" : "Open preview")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}
