import SwiftUI

struct DownloadsView: View {
    private var downloads: [Movie] {
        HFMockData.movies.filter(\.isDownloaded)
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
            .padding(.bottom, HFSpacing.xxl)
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
                            .frame(width: min(proxy.size.width, proxy.size.width * 0.42))
                    }
                }
                .frame(height: 7)
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
                    NavigationLink(value: movie) {
                        HFMovieCard(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var emptyState: some View {
        HFGlassPanel {
            VStack(spacing: HFSpacing.md) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(HFColors.gold)
                Text("No Downloads Yet")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Downloaded movies will appear here when local media support is wired.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(HFSpacing.xl)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var findMoreButton: some View {
        Button {} label: {
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
