import SwiftUI

struct DownloadsView: View {
    private var downloads: [Movie] {
        HFMockData.movies.filter(\.isDownloaded)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Downloads")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Local mock downloads. No network sync is performed in this phase.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.top, HFSpacing.lg)

                if downloads.isEmpty {
                    emptyState
                } else {
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
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
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
}
