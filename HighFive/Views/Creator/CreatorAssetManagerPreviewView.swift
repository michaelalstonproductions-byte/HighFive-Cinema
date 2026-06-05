import SwiftUI

struct CreatorAssetManagerPreviewView: View {
    private let assetLibrary = [
        CreatorAssetItem(title: "Poster Artwork", type: "Image", status: "Ready", systemImage: "photo.fill"),
        CreatorAssetItem(title: "Trailer Cut", type: "Video", status: "Needs Review", systemImage: "play.rectangle.fill"),
        CreatorAssetItem(title: "Scene Stills", type: "Gallery", status: "Ready", systemImage: "rectangle.stack.fill"),
        CreatorAssetItem(title: "Metadata Sheet", type: "Text", status: "In Progress", systemImage: "text.badge.checkmark"),
        CreatorAssetItem(title: "Preview Clip", type: "Video", status: "Draft", systemImage: "film.fill"),
        CreatorAssetItem(title: "Submission Notes", type: "Document", status: "Not Started", systemImage: "note.text")
    ]

    private let assetHealth = [
        CreatorAssetSignal(title: "Required assets", value: "8 / 12", systemImage: "checklist"),
        CreatorAssetSignal(title: "Preview assets", value: "3 / 5", systemImage: "rectangle.stack.fill"),
        CreatorAssetSignal(title: "Missing metadata", value: "2 fields", systemImage: "exclamationmark.triangle.fill"),
        CreatorAssetSignal(title: "Review notes", value: "2 open", systemImage: "bubble.left.and.text.bubble.right.fill")
    ]

    private let packageFolders = [
        "Artwork",
        "Video",
        "Metadata",
        "Gallery",
        "Notes",
        "Exports"
    ]

    private let comingNext = [
        "Real uploads",
        "Version history",
        "Team comments",
        "File permissions",
        "Cloud storage"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                workflowLinksSection
                assetLibrarySection
                assetHealthSection
                packageFoldersSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Asset Manager")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Asset Manager")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Organize artwork, trailers, stills, metadata, and preview materials.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No real files, uploads, storage, or services are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var workflowLinksSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Workflow Links", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    CreatorPackageBuilderPreviewView()
                } label: {
                    HFActionTile(title: "Package Builder", subtitle: "Return to package steps and readiness.", systemImage: "shippingbox.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    CreatorSubmissionWorkflowPreviewView()
                } label: {
                    HFActionTile(title: "Submission Workflow", subtitle: "Check readiness gates after asset review.", systemImage: "paperplane.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var assetLibrarySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Asset Library", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(assetLibrary) { item in
                    CreatorAssetLibraryCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var assetHealthSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Asset Health", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(assetHealth) { signal in
                    CreatorAssetSignalCard(signal: signal)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var packageFoldersSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Package Folders", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                ForEach(packageFolders, id: \.self) { folder in
                    folderChip(folder)
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

    private func folderChip(_ title: String) -> some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: icon(for: title))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(HFColors.gold)

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, HFSpacing.sm)
        .padding(.vertical, HFSpacing.sm)
        .background(HFColors.glassSurface)
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous))
    }

    private func icon(for folder: String) -> String {
        switch folder {
        case "Artwork":
            return "photo.fill"
        case "Video":
            return "play.rectangle.fill"
        case "Metadata":
            return "text.badge.checkmark"
        case "Gallery":
            return "rectangle.stack.fill"
        case "Notes":
            return "note.text"
        default:
            return "square.and.arrow.up.on.square.fill"
        }
    }
}

private struct CreatorAssetItem: Identifiable {
    let id = UUID()
    let title: String
    let type: String
    let status: String
    let systemImage: String
}

private struct CreatorAssetSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct CreatorAssetLibraryCard: View {
    let item: CreatorAssetItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(item.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(item.type)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)

                    CreatorAssetStatusBadge(title: item.status)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorAssetSignalCard: View {
    let signal: CreatorAssetSignal

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

private struct CreatorAssetStatusBadge: View {
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
