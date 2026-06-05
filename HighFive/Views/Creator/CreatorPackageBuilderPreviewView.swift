import SwiftUI

struct CreatorPackageBuilderPreviewView: View {
    private let packageSteps = [
        PackageStep(title: "Artwork", status: "Complete", systemImage: "photo.fill"),
        PackageStep(title: "Synopsis", status: "Complete", systemImage: "text.alignleft"),
        PackageStep(title: "Cast / Credits", status: "In Progress", systemImage: "person.2.fill"),
        PackageStep(title: "Trailer / Preview Clip", status: "Needs Review", systemImage: "play.rectangle.fill"),
        PackageStep(title: "Depth Preview", status: "Preview Only", systemImage: "square.stack.3d.up.fill"),
        PackageStep(title: "Submission Notes", status: "Not Started", systemImage: "note.text")
    ]

    private let assetTiles = [
        AssetPreviewTile(title: "Poster", systemImage: "photo.fill"),
        AssetPreviewTile(title: "Trailer", systemImage: "play.rectangle.fill"),
        AssetPreviewTile(title: "Scene Stills", systemImage: "rectangle.stack.fill"),
        AssetPreviewTile(title: "Metadata", systemImage: "text.badge.checkmark"),
        AssetPreviewTile(title: "Preview Clip", systemImage: "film.fill"),
        AssetPreviewTile(title: "Notes", systemImage: "note.text")
    ]

    private let readinessSignals = [
        ReadinessSignal(title: "Required fields", value: "8 / 12", systemImage: "checklist"),
        ReadinessSignal(title: "Preview assets", value: "3 / 5", systemImage: "rectangle.stack.fill"),
        ReadinessSignal(title: "Review notes", value: "2 open", systemImage: "bubble.left.and.text.bubble.right.fill"),
        ReadinessSignal(title: "Package score", value: "68%", systemImage: "gauge.with.dots.needle.67percent")
    ]

    private let comingNext = [
        "Real uploads",
        "Asset manager",
        "Team review",
        "Version history",
        "Submission workflow"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                packageOverview
                packageStepsSection
                assetPreviewSection
                submissionReadinessSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Package Builder")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Package Builder")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Assemble artwork, metadata, previews, and submission notes.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No real files or services are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var packageOverview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Package Overview", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "shippingbox.fill")
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
                                PackageStatusBadge(title: "Draft")
                                Text("Last updated: Today")
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
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var packageStepsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Package Steps", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(packageSteps) { step in
                        PackageChecklistRow(step: step)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var assetPreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Asset Preview", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(assetTiles) { tile in
                    AssetPreviewCard(tile: tile)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            NavigationLink {
                CreatorAssetManagerPreviewView()
            } label: {
                HStack(spacing: HFSpacing.xs) {
                    Text("Open Asset Manager")
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

    private var submissionReadinessSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Submission Readiness", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(readinessSignals) { signal in
                    ReadinessSignalCard(signal: signal)
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

private struct PackageStep: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

private struct AssetPreviewTile: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
}

private struct ReadinessSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct PackageChecklistRow: View {
    let step: PackageStep

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: step.systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            Text(step.title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)

            Spacer(minLength: HFSpacing.xs)

            PackageStatusBadge(title: step.status)
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}

private struct AssetPreviewCard: View {
    let tile: AssetPreviewTile

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: tile.systemImage)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(tile.title)
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

private struct ReadinessSignalCard: View {
    let signal: ReadinessSignal

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

private struct PackageStatusBadge: View {
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
