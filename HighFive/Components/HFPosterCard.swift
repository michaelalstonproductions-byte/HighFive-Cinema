import SwiftUI

struct HFPosterCard: View {
    let movie: Movie
    var width: CGFloat = 140
    var showTitle: Bool = true
    var showMetadata: Bool = false
    var showProgress: Bool = false
    var posterOnly: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            ZStack(alignment: .bottomLeading) {
                posterArtwork
                    .frame(width: width, height: width * 1.5)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.72)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                if movie.isComingSoon {
                    Text("COMING SOON")
                        .font(HFTypography.micro)
                        .foregroundStyle(.black)
                        .padding(.horizontal, HFSpacing.xs)
                        .padding(.vertical, HFSpacing.xxs)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                        .padding(HFSpacing.xs)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                if showProgress, let progress = movie.progress {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                            Capsule()
                                .fill(HFColors.goldGradient)
                                .frame(width: max(0, min(proxy.size.width, proxy.size.width * progress)))
                        }
                    }
                    .frame(height: 5)
                    .padding(.horizontal, HFSpacing.xs)
                    .padding(.bottom, HFSpacing.xs)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.24), lineWidth: 1)
            )
            .shadow(color: HFColors.amberGlow.opacity(0.14), radius: 16, x: 0, y: 12)
            .shadow(color: HFColors.shadow.opacity(0.78), radius: 14, x: 0, y: 10)

            if showTitle && !posterOnly {
                Text(movie.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: width, alignment: .leading)

                if showMetadata {
                    Text(movie.metadataLine)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                        .frame(width: width, alignment: .leading)
                }
            }
        }
        .frame(width: width, alignment: .top)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var posterArtwork: some View {
        if HFPosterAssetHealth.hasImage(named: movie.posterAssetName), let assetName = movie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .accessibilityLabel(movie.title)
        } else {
            HFPosterFallback(title: movie.title)
        }
    }
}
