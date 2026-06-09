import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    var onFindMore: (() -> Void)?
    @State private var showsRemoveAllAlert = false

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
                downloadHero
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
        .alert("Remove All Downloads?", isPresented: $showsRemoveAllAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove All", role: .destructive) {
                streamingStore.removeAllDownloads()
            }
        } message: {
            Text("This clears the preview download queue only.")
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Downloads")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Offline-ready titles for your next watch.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()

            Button {
                onFindMore?()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Find more downloads")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var downloadHero: some View {
        ZStack {
            Circle()
                .fill(HFColors.gold.opacity(0.18))
                .frame(width: 244, height: 244)
                .blur(radius: 2)

            HStack(spacing: -36) {
                heroPoster(movie: downloads.dropFirst(1).first ?? HFMockData.movies[2], rotation: -14)
                heroPoster(movie: downloads.first ?? HFMockData.movies[0], rotation: 0)
                    .zIndex(1)
                heroPoster(movie: downloads.dropFirst(2).first ?? HFMockData.movies[3], rotation: 14)
            }
            .padding(.top, HFSpacing.sm)

            VStack(spacing: HFSpacing.xs) {
                Spacer()
                Text(downloads.isEmpty ? "No titles downloaded" : "\(downloads.count) titles downloaded")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text(downloads.isEmpty ? "Find more to fill your offline shelf." : "Ready when you are.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .padding(.bottom, HFSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 278)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func heroPoster(movie: Movie, rotation: Double) -> some View {
        HFPosterCard(movie: movie, width: 142, showTitle: false, posterOnly: true)
            .rotationEffect(.degrees(rotation))
            .shadow(color: HFColors.shadow, radius: 18, x: 0, y: 12)
    }

    private var storageStatus: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Storage Status")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("\(downloads.count) titles  |  \(usedStorage, specifier: "%.1f") GB saved")
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

                Text("Manage saved titles and make space for more movies.")
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
                        .accessibilityLabel("Remove \(movie.title) download")
                    }
                }

                Button {
                    showsRemoveAllAlert = true
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
                .accessibilityLabel("Remove all downloads")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var emptyState: some View {
        HFEmptyState(
            title: "No Downloads Yet",
            message: "Download a title from the available slate and it will appear here.",
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
        .accessibilityLabel("Find more to download")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
