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

    private var usedStorageLabel: String {
        let tenths = Int((usedStorage * 10).rounded())
        return "\(tenths / 10).\(tenths % 10)"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                downloadHero
                connectedStateSection
                catalogDownloadsSection
                profileStateSection
                offlineWatchHubSection
                storageStatus
                offlinePlan

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
        .accessibilityIdentifier("hf.consumer.downloads.root")
        .accessibilityIdentifier("hf.functional.downloads.downloadedState")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .alert("Remove Offline Titles?", isPresented: $showsRemoveAllAlert) {
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
                Text("Offline")
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
                .fill(HFColors.amberGlow.opacity(0.22))
                .frame(width: 300, height: 300)
                .blur(radius: 5)

            HStack(spacing: -36) {
                heroPoster(movie: downloads.dropFirst(1).first ?? HFMockData.movies[2], rotation: -14)
                heroPoster(movie: downloads.first ?? HFMockData.movies[0], rotation: 0)
                    .zIndex(1)
                heroPoster(movie: downloads.dropFirst(2).first ?? HFMockData.movies[3], rotation: 14)
            }
            .padding(.top, HFSpacing.sm)

            VStack(spacing: HFSpacing.xs) {
                Spacer()
                Text("OFFLINE SHELF")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                    .kerning(1.3)
                Text(downloads.isEmpty ? "No offline titles" : "\(downloads.count) offline titles")
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text(downloads.isEmpty ? "Find more to fill your offline shelf." : "Ready when you are.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }
            .padding(.bottom, HFSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 334)
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .background(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .fill(HFColors.warmGlow.opacity(0.18))
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.vertical, HFSpacing.lg)
        )
    }

    private func heroPoster(movie: Movie, rotation: Double) -> some View {
        HFPosterCard(movie: movie, width: 146, showTitle: false, posterOnly: true)
            .rotationEffect(.degrees(rotation))
            .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 24, x: 0, y: 16)
    }

    private var storageStatus: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Offline Capacity")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("\(downloads.count) titles  |  \(usedStorage, specifier: "%.1f") GB saved")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
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

                Text("Keep favorite titles ready for travel, commutes, and low-signal nights.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.consumer.downloads.storageCard")
    }

    private var offlineWatchHubSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Offline Watch Hub", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 50, height: 50)
                            .background(HFColors.gold.opacity(0.13))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Ready when you are.")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Keep available offline titles, shelf planning, and find-more paths together in one calm viewing space.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFOfflineHubCard(title: "Available Offline", detail: "\(downloads.count) titles", systemImage: "checkmark.circle.fill", isActive: true)
                        HFOfflineHubCard(title: "Ready When You Are", detail: "Travel and low-signal nights", systemImage: "airplane")
                        HFOfflineHubCard(title: "Find More To Download", detail: "Browse more titles", systemImage: "plus.circle.fill")
                        HFOfflineHubCard(title: "Offline Shelf", detail: "Watch later path", systemImage: "rectangle.stack.fill")
                        HFOfflineHubCard(title: "Storage Preview", detail: "\(usedStorageLabel) GB planned", systemImage: "internaldrive.fill")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Offline Watch Hub, available offline, ready when you are, find more, offline shelf, and storage preview")
        .accessibilityIdentifier("hf.consumer.downloads.offlineWatchHub")
    }

    private var connectedStateSection: some View {
        HFInsightCard(
            title: "Connected Offline State",
            message: "Downloaded titles update from Movie Detail.",
            systemImage: "point.3.connected.trianglepath.dotted"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.functional.downloads.connectedState")
    }

    private var catalogDownloadsSection: some View {
        HFInsightCard(
            title: "Catalog Downloads",
            message: "Offline-ready titles resolve through the shared movie catalog.",
            systemImage: "rectangle.stack.fill.badge.plus"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Catalog Downloads, offline-ready titles resolve through the shared movie catalog")
        .accessibilityIdentifier("hf.catalog.downloads.connected")
    }

    private var profileStateSection: some View {
        HFInsightCard(
            title: "Offline for \(streamingStore.activeViewingProfile.displayName)",
            message: "Downloaded state follows your active local profile.",
            systemImage: streamingStore.activeViewingProfile.avatarSymbol
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Offline for \(streamingStore.activeViewingProfile.displayName), downloaded state follows your active local profile")
        .accessibilityIdentifier("hf.account.downloads.profileState")
    }

    private var offlinePlan: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Offline Plan", actionTitle: nil)

            VStack(spacing: HFSpacing.xs) {
                HFConsumerMomentumRow(title: "Offline-ready titles", detail: downloads.isEmpty ? "Find more titles for the shelf." : "\(downloads.count) titles ready for later.", status: downloads.isEmpty ? "Open" : "Ready", systemImage: "checkmark.circle.fill")
                HFConsumerMomentumRow(title: "Storage preview", detail: "\(usedStorageLabel) GB represented in this shelf.", status: "Preview", systemImage: "internaldrive.fill")
                HFConsumerMomentumRow(title: "Download shelf", detail: "Saved titles stay organized for travel and quiet nights.", status: "Local", systemImage: "rectangle.stack.fill")
                HFConsumerMomentumRow(title: "Find more path", detail: "Discover leads back to titles worth keeping nearby.", status: "Ready", systemImage: "magnifyingglass")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Offline plan summary")
        .accessibilityIdentifier("hf.consumer.downloads.offlinePlan")
    }

    private var downloadList: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Available Offline", actionTitle: nil)

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
                        .accessibilityLabel("Remove \(movie.title) from offline titles")
                    }
                }

                Button {
                    showsRemoveAllAlert = true
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "trash.fill")
                        Text("Remove Offline Titles")
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
                .accessibilityLabel("Remove offline titles")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.consumer.downloads.offlineShelf")
    }

    private var emptyState: some View {
        HFEmptyState(
            title: "No Offline Titles Yet",
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

private struct HFOfflineHubCard: View {
    let title: String
    let detail: String
    let systemImage: String
    var isActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(isActive ? .black : HFColors.gold)
                .frame(width: 30, height: 30)
                .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 104, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFDownloadPlanTile: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HFGlassPanel(cornerRadius: 16, strokeColor: HFColors.gold.opacity(0.22)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 32, height: 32)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(Circle())

                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(subtitle)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.sm)
        }
    }
}
