import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    var onFindMore: (() -> Void)?

    private var downloads: [Movie] {
        HFMockData.movies.filter { streamingStore.isDownloaded($0) }
    }

    private var usedStorage: Double {
        Double(downloads.count) * 1.6
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                storageStatus

                if downloads.isEmpty {
                    emptyState
                } else {
                    downloadList
                }

                findMoreButton
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Downloads")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Offline titles available from local mock data.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var storageStatus: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Storage Status")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
            Text("\(downloads.count) titles  |  \(usedStorage, specifier: "%.1f") GB used")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.14))
                        Capsule()
                            .fill(HFColors.goldGradient)
                            .frame(width: min(proxy.size.width, proxy.size.width * min(0.82, usedStorage / 10.0)))
                    }
                }
                .frame(height: 7)

                Text("Local offline preview storage. Remove downloads to clear the mock queue.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var downloadList: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Downloaded Movies", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(downloads) { movie in
                    HStack(spacing: HFSpacing.sm) {
                        NavigationLink(value: movie) {
                            HFMovieCard(movie: movie)
                        }
                        .buttonStyle(.plain)

                        Button {
                            streamingStore.toggleDownload(movie)
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.10))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    streamingStore.removeAllDownloads()
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "trash.fill")
                        Text("Remove All Downloads")
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(HFColors.glassSurface)
                    .overlay(Capsule().stroke(HFColors.goldStroke, lineWidth: 1))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var emptyState: some View {
        HFEmptyState(
            title: "No Downloads Yet",
            message: "Download a local mock title from the available slate and it will appear here.",
            systemImage: "arrow.down.circle",
            actionTitle: "Find More To Download",
            action: onFindMore
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var findMoreButton: some View {
        Button {
            onFindMore?()
        } label: {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: "plus.circle.fill")
                Text("Find More To Download")
            }
            .font(HFTypography.smallAction)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(HFColors.goldGradient)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
