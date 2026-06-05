import SwiftUI

struct CreatorWorkflowCommandCenterView: View {
    private let stages = [
        CreatorWorkflowStage(title: "Studio", status: "Active", systemImage: "film.stack.fill", route: .studio),
        CreatorWorkflowStage(title: "Package Builder", status: "In Progress", systemImage: "shippingbox.fill", route: .packageBuilder),
        CreatorWorkflowStage(title: "Asset Manager", status: "Needs Review", systemImage: "rectangle.stack.fill", route: .assetManager),
        CreatorWorkflowStage(title: "Submission Workflow", status: "Draft Review", systemImage: "checklist", route: .submissionWorkflow),
        CreatorWorkflowStage(title: "Team Review", status: "Internal Review", systemImage: "person.3.fill", route: .teamReview),
        CreatorWorkflowStage(title: "Version History", status: "Tracking", systemImage: "clock.arrow.circlepath", route: .versionHistory),
        CreatorWorkflowStage(title: "Team Permissions", status: "Preview Only", systemImage: "person.3.sequence.fill", route: .teamPermissions),
        CreatorWorkflowStage(title: "Marketplace", status: "Coming Soon", systemImage: "storefront.fill", route: .marketplace)
    ]

    private let signals = [
        CreatorCommandSignal(title: "Draft packages", value: "3", systemImage: "shippingbox.fill"),
        CreatorCommandSignal(title: "Open review notes", value: "5", systemImage: "text.bubble.fill"),
        CreatorCommandSignal(title: "Assets ready", value: "6 / 10", systemImage: "rectangle.stack.fill"),
        CreatorCommandSignal(title: "Team members", value: "4", systemImage: "person.2.fill"),
        CreatorCommandSignal(title: "Version rounds", value: "3", systemImage: "clock.arrow.circlepath"),
        CreatorCommandSignal(title: "Marketplace interest", value: "48", systemImage: "storefront.fill")
    ]

    private let actions = [
        CreatorPriorityAction(title: "Resolve trailer review note", subtitle: "Team Review", systemImage: "film.fill", route: .teamReview),
        CreatorPriorityAction(title: "Confirm cast credits", subtitle: "Package Builder", systemImage: "person.2.fill", route: .packageBuilder),
        CreatorPriorityAction(title: "Finish submission notes", subtitle: "Submission Workflow", systemImage: "note.text", route: .submissionWorkflow),
        CreatorPriorityAction(title: "Review team permissions", subtitle: "Team Permissions", systemImage: "checkmark.shield.fill", route: .teamPermissions),
        CreatorPriorityAction(title: "Prepare marketplace listing", subtitle: "Marketplace Preview", systemImage: "storefront.fill", route: .marketplace)
    ]

    private let comingNext = [
        "Real workflow automation",
        "Team assignments",
        "Approval routing",
        "Creator notifications",
        "Marketplace launch tools"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                commandSummarySection
                workflowPipelineSection
                workflowSignalsSection
                priorityActionsSection
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
                            Text("The Friendly — Creator Package")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: HFSpacing.xs) {
                                CreatorCommandStatusBadge(title: "Team Review")
                                Text("Marketplace readiness: Preview Only")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Spacer(minLength: HFSpacing.xs)
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack {
                            Text("Package completion")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                            Spacer()
                            Text("72%")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.gold)
                        }

                        ProgressView(value: 0.72)
                            .tint(HFColors.gold)
                            .background(HFColors.glassStroke)
                            .clipShape(Capsule())
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack {
                            Text("Review readiness")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                            Spacer()
                            Text("68%")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.gold)
                        }

                        ProgressView(value: 0.68)
                            .tint(HFColors.gold)
                            .background(HFColors.glassStroke)
                            .clipShape(Capsule())
                    }

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
                }
                .padding(HFSpacing.lg)
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
                        CreatorWorkflowStageCard(stage: stage)
                    }
                    .buttonStyle(.plain)
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
                    CreatorCommandSignalCard(signal: signal)
                }
            }
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
                        CreatorPriorityActionCard(action: action)
                    }
                    .buttonStyle(.plain)
                }
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
        }
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

private struct CreatorWorkflowStageCard: View {
    let stage: CreatorWorkflowStage

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

                        CreatorCommandStatusBadge(title: stage.status)
                    }

                    Text("Open preview")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorCommandSignalCard: View {
    let signal: CreatorCommandSignal

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: signal.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 36, height: 36)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(signal.value)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(signal.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorPriorityActionCard: View {
    let action: CreatorPriorityAction

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: action.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 40, height: 40)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(action.title)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(action.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }

                Spacer(minLength: HFSpacing.xs)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(HFColors.gold)
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorCommandStatusBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.xs)
            .padding(.vertical, 6)
            .background(HFColors.gold)
            .clipShape(Capsule())
    }
}
