import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    var onFindMore: (() -> Void)?
    @State private var showsRemoveAllAlert = false

    private var downloads: [Movie] {
        streamingStore.downloadedMovies
    }

    private var usedStorage: Double {
        Double(downloads.count) * 1.6
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                downloadHero

                if downloads.isEmpty {
                    emptyState
                } else {
                    downloadList
                    removeAllButton
                }

                storageStatus
                findMoreButton
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.consumer.downloads.root")
        .accessibilityIdentifier("hf.downloads.screen")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .alert("Remove Offline Titles?", isPresented: $showsRemoveAllAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove All", role: .destructive) {
                streamingStore.removeAllDownloads()
            }
        } message: {
            Text("This removes every title from your offline shelf.")
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Downloads")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Offline planning for titles you want nearby.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()

            Button(action: { onFindMore?() }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Find more downloads")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var downloadHero: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            ZStack {
                Circle()
                    .fill(HFColors.amberGlow.opacity(0.20))
                    .frame(width: 260, height: 260)
                    .blur(radius: 4)

                HStack(spacing: -34) {
                    heroPoster(movie: downloads.dropFirst(1).first ?? HFMockData.movies[2], rotation: -14)
                    heroPoster(movie: downloads.first ?? HFMockData.movies[0], rotation: 0)
                        .zIndex(1)
                    heroPoster(movie: downloads.dropFirst(2).first ?? HFMockData.movies[3], rotation: 14)
                }

                VStack(spacing: HFSpacing.xs) {
                    Spacer()
                    Text("OFFLINE SHELF")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                        .kerning(1.3)
                    Text(downloads.isEmpty ? "No titles yet" : "\(downloads.count) titles ready")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .padding(HFSpacing.md)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func heroPoster(movie: Movie, rotation: Double) -> some View {
        HFPosterCard(movie: movie, width: 132, showTitle: false, posterOnly: true)
            .rotationEffect(.degrees(rotation))
            .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 20, x: 0, y: 14)
    }

    private var emptyState: some View {
        HFEmptyState(
            title: "Nothing saved offline",
            message: "Mark titles for offline from Movie Detail or browse more from Discover.",
            systemImage: "arrow.down.circle",
            actionTitle: "Find Titles",
            action: onFindMore
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var downloadList: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Ready Offline", actionTitle: "\(downloads.count)")
            VStack(spacing: HFSpacing.sm) {
                ForEach(downloads) { movie in
                    NavigationLink(value: movie) {
                        HFMovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var storageStatus: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Offline Capacity")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("\(downloads.count) titles  |  \(usedStorage, specifier: "%.1f") GB represented")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                    }
                    Spacer()
                    Image(systemName: "internaldrive.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.14))
                        Capsule()
                            .fill(HFColors.goldGradient)
                            .frame(width: min(proxy.size.width, proxy.size.width * min(0.82, usedStorage / 10.0)))
                    }
                }
                .frame(height: 7)

                Text("Local offline shelf only. No media files are created and no download provider is connected.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.downloads.localOfflineShelf")
    }

    private var findMoreButton: some View {
        HFButton("Find More to Download", systemImage: "plus") {
            onFindMore?()
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var removeAllButton: some View {
        Button {
            showsRemoveAllAlert = true
        } label: {
            Text("Remove All Offline Titles")
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.redAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white.opacity(0.08))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
