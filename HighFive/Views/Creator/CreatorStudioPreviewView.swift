import SwiftUI

struct CreatorStudioPreviewView: View {
    private let previewTools = ["Poster", "Trailer", "Depth Preview", "Metadata"]
    private let checklist = ["Artwork", "Synopsis", "Cast / Credits", "Preview Clip", "Submission Notes"]
    private let comingNext = ["Uploads", "Asset manager", "Team review", "Creator analytics"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                commandCenterLink
                activeDraftCard
                toolSection
                checklistSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Studio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Studio")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.82)

            Text("Package your work, prepare previews, and organize your slate.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var commandCenterLink: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Link", actionTitle: nil)

            NavigationLink {
                CreatorWorkflowCommandCenterView()
            } label: {
                HFActionTile(title: "Command Center", subtitle: "Track package health, release readiness, and next actions.", systemImage: "command")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var activeDraftCard: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Active Draft", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "shippingbox.fill")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                        }
                        .frame(width: 60, height: 60)

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("The Friendly — Creator Package")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: HFSpacing.xs) {
                                statusPill("Draft")
                                Text("68%")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.gold)
                            }
                        }

                        Spacer()
                    }

                    ProgressView(value: 0.68)
                        .tint(HFColors.gold)
                        .background(HFColors.glassStroke)
                        .clipShape(Capsule())

                    NavigationLink {
                        CreatorPackageBuilderPreviewView()
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Continue Package")
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
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var toolSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Preview Tools", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(previewTools, id: \.self) { tool in
                    StudioMiniCard(title: tool, systemImage: icon(for: tool))
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Package Checklist", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(checklist, id: \.self) { item in
                        checklistRow(item)
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

    private func checklistRow(_ title: String) -> some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 24)

            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)

            Spacer()
        }
        .padding(.vertical, HFSpacing.xxs)
    }

    private func statusPill(_ title: String) -> some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(.black)
            .padding(.horizontal, HFSpacing.xs)
            .padding(.vertical, 6)
            .background(HFColors.gold)
            .clipShape(Capsule())
    }

    private func icon(for tool: String) -> String {
        switch tool {
        case "Poster":
            return "photo.fill"
        case "Trailer":
            return "play.rectangle.fill"
        case "Depth Preview":
            return "square.stack.3d.up.fill"
        default:
            return "text.badge.checkmark"
        }
    }
}

private struct StudioMiniCard: View {
    let title: String
    let systemImage: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
