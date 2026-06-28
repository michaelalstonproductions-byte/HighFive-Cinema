import SwiftUI

struct HFMovieCard: View {
    let movie: Movie

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
            HStack(spacing: HFSpacing.md) {
                HFPosterCard(movie: movie, width: 102, showTitle: false, showProgress: movie.progress != nil)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(movie.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .hfReadableText(lines: 2, minimumScaleFactor: 0.78)
                    Text(movie.subtitle)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .hfReadableText(lines: 2, minimumScaleFactor: 0.80)
                    Text(movie.metadataLine)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                        .hfSingleLineText(minimumScaleFactor: 0.72)

                    HStack(spacing: HFSpacing.xxs) {
                        if movie.isOriginal {
                            HFMovieSignalChip(title: "Original", systemImage: "sparkles")
                        }
                        if movie.isDownloaded {
                            HFMovieSignalChip(title: "Offline", systemImage: "arrow.down.circle.fill")
                        }
                        if movie.progress != nil {
                            HFMovieSignalChip(title: "Resume", systemImage: "play.fill")
                        }
                    }

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

                    if let progress = movie.progress {
                        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.16))
                                    Capsule()
                                        .fill(HFColors.goldGradient)
                                        .frame(width: proxy.size.width * min(max(progress, 0), 1))
                                }
                            }
                            .frame(height: 5)

                            Text("\(Int(progress * 100))% watched")
                                .font(HFTypography.micro)
                                .foregroundStyle(HFColors.gold)
                        }
                        .padding(.top, HFSpacing.xxs)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(HFSpacing.sm)
        }
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct HFMovieSignalChip: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(.system(size: 8, weight: .black))
            Text(title)
                .font(HFTypography.micro)
        }
        .foregroundStyle(HFColors.gold)
        .hfSingleLineText(minimumScaleFactor: 0.72)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 24)
        .background(HFColors.gold.opacity(0.10))
        .overlay(Capsule().stroke(HFColors.gold.opacity(0.22), lineWidth: 1))
        .clipShape(Capsule())
    }
}
