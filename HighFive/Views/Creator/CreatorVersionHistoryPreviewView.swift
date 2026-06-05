import SwiftUI

struct CreatorVersionHistoryPreviewView: View {
    private let versions = [
        CreatorVersionItem(
            title: "v0.8 Draft Review",
            status: "Current",
            notes: "Team notes added, trailer cut flagged for review.",
            systemImage: "clock.fill"
        ),
        CreatorVersionItem(
            title: "v0.7 Asset Pass",
            status: "Reviewed",
            notes: "Poster artwork approved and scene stills organized.",
            systemImage: "rectangle.stack.fill"
        ),
        CreatorVersionItem(
            title: "v0.6 Metadata Update",
            status: "Reviewed",
            notes: "Synopsis and cast credits updated.",
            systemImage: "text.badge.checkmark"
        ),
        CreatorVersionItem(
            title: "v0.5 Preview Package",
            status: "Archived",
            notes: "First preview clip and submission notes assembled.",
            systemImage: "play.rectangle.fill"
        ),
        CreatorVersionItem(
            title: "v0.1 Initial Draft",
            status: "Archived",
            notes: "Package shell created.",
            systemImage: "shippingbox.fill"
        )
    ]

    private let changeSignals = [
        CreatorVersionSignal(title: "Open notes", value: "5", systemImage: "text.bubble.fill"),
        CreatorVersionSignal(title: "Resolved notes", value: "12", systemImage: "checkmark.seal.fill"),
        CreatorVersionSignal(title: "Assets changed", value: "4", systemImage: "rectangle.stack.fill"),
        CreatorVersionSignal(title: "Metadata edits", value: "7", systemImage: "pencil.and.list.clipboard"),
        CreatorVersionSignal(title: "Review rounds", value: "3", systemImage: "arrow.trianglehead.2.clockwise")
    ]

    private let compareItems = [
        CreatorCompareItem(title: "Artwork changes", systemImage: "photo.fill"),
        CreatorCompareItem(title: "Trailer changes", systemImage: "film.fill"),
        CreatorCompareItem(title: "Metadata changes", systemImage: "text.badge.checkmark"),
        CreatorCompareItem(title: "Review notes", systemImage: "text.bubble.fill"),
        CreatorCompareItem(title: "Submission readiness", systemImage: "checklist")
    ]

    private let comingNext = [
        "Real version history",
        "Team comments",
        "Approval snapshots",
        "File diffs",
        "Restore version"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                currentVersionSection
                releaseReadinessLink
                versionTimelineSection
                changeSummarySection
                comparePreviewSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Version History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Version History")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Track package changes, review rounds, and approval progress.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No live storage, review services, or external accounts are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var currentVersionSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Current Version", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 30, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }
                        .frame(width: 68, height: 68)

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("The Friendly — Creator Package")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("v0.8 Draft Review")
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)

                            HStack(spacing: HFSpacing.xs) {
                                CreatorVersionStatusBadge(title: "Internal Review")
                                Text("Updated: Today")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
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
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var releaseReadinessLink: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Release Check", actionTitle: nil)

            NavigationLink {
                CreatorReleaseReadinessPreviewView()
            } label: {
                HFActionTile(title: "Release Readiness", subtitle: "Compare version progress against launch blockers.", systemImage: "gauge.with.dots.needle.67percent")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var versionTimelineSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Version Timeline", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(versions) { version in
                    CreatorVersionTimelineCard(version: version)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var changeSummarySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Change Summary", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(changeSignals) { signal in
                    CreatorVersionSignalCard(signal: signal)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var comparePreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Compare Preview", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(compareItems) { item in
                    CreatorComparePreviewCard(item: item)
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
}

private struct CreatorVersionItem: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let notes: String
    let systemImage: String
}

private struct CreatorVersionSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct CreatorCompareItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
}

private struct CreatorVersionTimelineCard: View {
    let version: CreatorVersionItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: version.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 40, height: 40)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Text(version.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.xs)

                        CreatorVersionStatusBadge(title: version.status)
                    }

                    Text(version.notes)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorVersionSignalCard: View {
    let signal: CreatorVersionSignal

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

private struct CreatorComparePreviewCard: View {
    let item: CreatorCompareItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(item.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorVersionStatusBadge: View {
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
