import SwiftUI

struct HFMovieCard: View {
    let movie: Movie

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
            HStack(spacing: HFSpacing.md) {
                HFPosterCard(movie: movie, width: 88, showTitle: false, showProgress: movie.progress != nil)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(movie.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                    Text(movie.subtitle)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)
                    Text(movie.metadataLine)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                    HStack(spacing: HFSpacing.xs) {
                        ForEach(movie.genres.prefix(2), id: \.self) { genre in
                            Text(genre)
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.gold)
                                .padding(.horizontal, HFSpacing.xs)
                                .padding(.vertical, HFSpacing.xxs)
                                .background(HFColors.gold.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(HFSpacing.sm)
        }
    }
}
