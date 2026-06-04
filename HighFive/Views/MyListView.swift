import SwiftUI

struct MyListView: View {
    private var savedMovies: [Movie] {
        HFMockData.movies.filter { $0.isDownloaded || $0.progress != nil || $0.isOriginal }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Library")
                        .font(HFTypography.display)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Saved content, local previews, and your HighFive list.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .padding(.top, HFSpacing.lg)

                VStack(spacing: HFSpacing.md) {
                    ForEach(savedMovies) { movie in
                        NavigationLink(value: movie) {
                            HFMovieCard(movie: movie)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
    }
}
