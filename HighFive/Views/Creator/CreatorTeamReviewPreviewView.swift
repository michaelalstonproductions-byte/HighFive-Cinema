import SwiftUI

struct CreatorTeamReviewPreviewView: View {
    private let reviewerNotes = [
        CreatorReviewNote(
            text: "Poster artwork is approved.",
            reviewer: "Creative Lead",
            status: "Resolved",
            systemImage: "checkmark.seal.fill"
        ),
        CreatorReviewNote(
            text: "Trailer cut needs a tighter opening.",
            reviewer: "Editor",
            status: "Open",
            systemImage: "film.fill"
        ),
        CreatorReviewNote(
            text: "Cast credits need final confirmation.",
            reviewer: "Producer",
            status: "In Progress",
            systemImage: "person.2.fill"
        ),
        CreatorReviewNote(
            text: "Submission notes need one final pass.",
            reviewer: "Studio Review",
            status: "Open",
            systemImage: "note.text"
        )
    ]

    private let approvalChecklist = [
        CreatorApprovalItem(title: "Artwork approved", status: "Complete", systemImage: "photo.fill"),
        CreatorApprovalItem(title: "Metadata reviewed", status: "Complete", systemImage: "text.badge.checkmark"),
        CreatorApprovalItem(title: "Preview clip reviewed", status: "Needs Review", systemImage: "play.rectangle.fill"),
        CreatorApprovalItem(title: "Rights confirmation", status: "In Progress", systemImage: "checkmark.shield.fill"),
        CreatorApprovalItem(title: "Team sign-off", status: "Not Started", systemImage: "person.3.fill")
    ]

    private let timeline = [
        CreatorReviewTimelineStep(title: "Package drafted", status: "Complete"),
        CreatorReviewTimelineStep(title: "Assets organized", status: "Complete"),
        CreatorReviewTimelineStep(title: "Submission prepared", status: "Current"),
        CreatorReviewTimelineStep(title: "Team review", status: "Current"),
        CreatorReviewTimelineStep(title: "Studio approval", status: "Preview"),
        CreatorReviewTimelineStep(title: "Release planning", status: "Preview")
    ]

    private let comingNext = [
        "Real comments",
        "Reviewer assignments",
        "Approval routing",
        "Version history",
        "Team permissions"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                reviewRoomSection
                reviewerNotesSection
                approvalChecklistSection
                reviewTimelineSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Team Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Team Review")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Collect notes, resolve blockers, and prepare your package for approval.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No live team services or external accounts are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var reviewRoomSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Review Room", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "person.3.fill")
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
                                CreatorReviewStatusBadge(title: "Internal Review")
                                Text("Approval readiness: 72%")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                            }
                        }

                        Spacer(minLength: HFSpacing.xs)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                        CreatorReviewMetric(title: "Reviewers", value: "3", systemImage: "person.2.fill")
                        CreatorReviewMetric(title: "Open notes", value: "5", systemImage: "text.bubble.fill")
                    }

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack {
                            Text("Approval readiness")
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

                    Button {
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Continue Review")
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

                    NavigationLink {
                        CreatorVersionHistoryPreviewView()
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Open Version History")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .black))
                        }
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HFColors.glassSurface)
                        .overlay(
                            Capsule()
                                .stroke(HFColors.goldStroke, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var reviewerNotesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Reviewer Notes", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(reviewerNotes) { note in
                    CreatorReviewNoteCard(note: note)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var approvalChecklistSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Approval Checklist", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(approvalChecklist) { item in
                        CreatorApprovalChecklistRow(item: item)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var reviewTimelineSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Review Timeline", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(Array(timeline.enumerated()), id: \.element.id) { index, step in
                        CreatorReviewTimelineRow(
                            step: step,
                            index: index + 1,
                            isLast: index == timeline.count - 1
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
}

private struct CreatorReviewNote: Identifiable {
    let id = UUID()
    let text: String
    let reviewer: String
    let status: String
    let systemImage: String
}

private struct CreatorApprovalItem: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

private struct CreatorReviewTimelineStep: Identifiable {
    let id = UUID()
    let title: String
    let status: String
}

private struct CreatorReviewMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 30, height: 30)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                Text(title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.sm)
        .background(HFColors.glassSurface)
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous))
    }
}

private struct CreatorReviewNoteCard: View {
    let note: CreatorReviewNote

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: note.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 40, height: 40)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(note.text)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(note.reviewer)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)

                    CreatorReviewStatusBadge(title: note.status)
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorApprovalChecklistRow: View {
    let item: CreatorApprovalItem

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

            CreatorReviewStatusBadge(title: item.status)
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}

private struct CreatorReviewTimelineRow: View {
    let step: CreatorReviewTimelineStep
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

private struct CreatorReviewStatusBadge: View {
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
