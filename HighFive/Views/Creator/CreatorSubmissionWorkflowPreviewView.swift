import SwiftUI

struct CreatorSubmissionWorkflowPreviewView: View {
    private let checklist = [
        SubmissionChecklistItem(title: "Artwork approved", status: "Complete", systemImage: "photo.fill"),
        SubmissionChecklistItem(title: "Metadata reviewed", status: "Complete", systemImage: "text.badge.checkmark"),
        SubmissionChecklistItem(title: "Cast / credits verified", status: "In Progress", systemImage: "person.2.fill"),
        SubmissionChecklistItem(title: "Preview clip checked", status: "Needs Review", systemImage: "play.rectangle.fill"),
        SubmissionChecklistItem(title: "Submission notes added", status: "Not Started", systemImage: "note.text"),
        SubmissionChecklistItem(title: "Rights confirmation", status: "Preview Only", systemImage: "checkmark.shield.fill")
    ]

    private let readinessGates = [
        SubmissionReadinessGate(title: "Required fields", value: "8 / 12", systemImage: "checklist"),
        SubmissionReadinessGate(title: "Assets ready", value: "6 / 10", systemImage: "rectangle.stack.fill"),
        SubmissionReadinessGate(title: "Review notes", value: "2 open", systemImage: "bubble.left.and.text.bubble.right.fill"),
        SubmissionReadinessGate(title: "Blocking issues", value: "1", systemImage: "exclamationmark.octagon.fill"),
        SubmissionReadinessGate(title: "Package score", value: "68%", systemImage: "gauge.with.dots.needle.67percent")
    ]

    private let timeline = [
        SubmissionTimelineStep(title: "Draft package", status: "Current"),
        SubmissionTimelineStep(title: "Internal review", status: "Next"),
        SubmissionTimelineStep(title: "Studio review", status: "Preview"),
        SubmissionTimelineStep(title: "Marketplace-ready", status: "Preview"),
        SubmissionTimelineStep(title: "Release planning", status: "Preview")
    ]

    private let comingNext = [
        "Real submission queue",
        "Studio reviewer comments",
        "Version history",
        "Approval routing",
        "Secure delivery"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Creator Mode", "Package Builder", "Submission Workflow"])
                submissionSummary
                workflowLinksSection
                reviewChecklistSection
                readinessGatesSection
                timelineSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Submission")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Submission Workflow")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Review your package, resolve blockers, and prepare for studio submission.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No live services or external review systems are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var submissionSummary: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Submission Summary", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "paperplane.fill")
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
                                SubmissionStatusBadge(title: "Draft Review")
                                Text("Target: HighFive Studio Review")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Spacer(minLength: HFSpacing.xs)
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack {
                            Text("Completion")
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

                    Button {
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Prepare Submission")
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

    private var workflowLinksSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Links", actionTitle: nil)

            NavigationLink {
                CreatorReleaseReadinessPreviewView()
            } label: {
                HFActionTile(title: "Release Readiness", subtitle: "Review blockers before studio handoff.", systemImage: "gauge.with.dots.needle.67percent")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var reviewChecklistSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Review Checklist", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(checklist) { item in
                        SubmissionChecklistRow(item: item)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var readinessGatesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Readiness Gates", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(readinessGates) { gate in
                    SubmissionReadinessGateCard(gate: gate)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Submission Timeline", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(Array(timeline.enumerated()), id: \.element.id) { index, step in
                        SubmissionTimelineRow(
                            step: step,
                            index: index + 1,
                            isLast: index == timeline.count - 1
                        )
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            NavigationLink {
                CreatorTeamReviewPreviewView()
            } label: {
                HStack(spacing: HFSpacing.xs) {
                    Text("Open Team Review")
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
}

private struct SubmissionChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

private struct SubmissionReadinessGate: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct SubmissionTimelineStep: Identifiable {
    let id = UUID()
    let title: String
    let status: String
}

private struct SubmissionChecklistRow: View {
    let item: SubmissionChecklistItem

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: item.systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            Text(item.title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)

            Spacer(minLength: HFSpacing.xs)

            SubmissionStatusBadge(title: item.status)
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}

private struct SubmissionReadinessGateCard: View {
    let gate: SubmissionReadinessGate

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: gate.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 36, height: 36)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(gate.value)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(gate.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

private struct SubmissionTimelineRow: View {
    let step: SubmissionTimelineStep
    let index: Int
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            VStack(spacing: HFSpacing.xs) {
                Text("\(index)")
                    .font(HFTypography.micro)
                    .foregroundStyle(.black)
                    .frame(width: 28, height: 28)
                    .background(HFColors.gold)
                    .clipShape(Circle())

                if !isLast {
                    Rectangle()
                        .fill(HFColors.glassStroke)
                        .frame(width: 1, height: 22)
                }
            }

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(step.title)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textPrimary)

                Text(step.status)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SubmissionStatusBadge: View {
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
