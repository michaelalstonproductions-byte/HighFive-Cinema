import SwiftUI

struct HFPosterCard: View {
    let movie: Movie
    var width: CGFloat = 140
    var showTitle: Bool = true
    var showMetadata: Bool = false
    var showProgress: Bool = false
    var posterOnly: Bool = false

    private var posterHeight: CGFloat {
        width * 1.5
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            ZStack(alignment: .bottomLeading) {
                posterArtwork
                    .frame(width: width, height: posterHeight)

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.30), Color.black.opacity(0.78)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(width: width, height: posterHeight)

                LinearGradient(
                    colors: [Color.white.opacity(0.16), .clear],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .frame(width: width, height: posterHeight)

                if movie.isComingSoon {
                    Text("Coming\nSoon")
                        .font(.system(size: HFResponsiveFit.smallBadgeFontSize(width: width), weight: .black, design: .default))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .textCase(.uppercase)
                        .frame(
                            width: HFResponsiveFit.comingSoonBadgeSize(width: width),
                            height: HFResponsiveFit.comingSoonBadgeSize(width: width)
                        )
                        .background(HFColors.goldGradient)
                        .clipShape(Circle())
                        .shadow(color: HFColors.amberGlow.opacity(0.26), radius: 10, x: 0, y: 5)
                        .padding(HFSpacing.xs)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .accessibilityLabel("Coming soon")
                }

                if width >= 100 {
                    posterSignalBadges
                        .padding(HFSpacing.xs)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            .frame(width: width, height: posterHeight)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [HFColors.gold.opacity(0.42), Color.white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: HFColors.amberGlow.opacity(0.16), radius: 18, x: 0, y: 12)
            .shadow(color: HFColors.shadow.opacity(0.82), radius: 16, x: 0, y: 12)

            if showTitle && !posterOnly {
                Text(movie.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .hfReadableText(lines: 2, minimumScaleFactor: 0.78)
                    .frame(width: width, alignment: .leading)

                if showMetadata {
                    Text(movie.metadataLine)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                        .hfSingleLineText(minimumScaleFactor: 0.72)
                        .frame(width: width, alignment: .leading)
                }
            }
        }
        .frame(width: width, alignment: .top)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var posterSignalBadges: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            if movie.isOriginal {
                HFPosterSignalBadge(title: "Original", systemImage: "sparkles")
            }

            if movie.isDownloaded {
                HFPosterSignalBadge(title: "Offline", systemImage: "arrow.down.circle.fill")
            }
        }
    }

    @ViewBuilder
    private var posterArtwork: some View {
        if HFPosterAssetHealth.hasImage(named: movie.posterAssetName), let assetName = movie.posterAssetName {
            Image(assetName)
                .resizable()
                .aspectRatio(2 / 3, contentMode: .fill)
                .scaledToFill()
                .frame(width: width, height: posterHeight)
                .clipped()
                .accessibilityLabel(movie.title)
        } else {
            HFPosterFallback(title: movie.title)
                .frame(width: width, height: posterHeight)
        }
    }
}

private struct HFPosterSignalBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(.system(size: 8, weight: .black))
            Text(title)
                .font(.system(size: 9, weight: .black, design: .default))
        }
        .foregroundStyle(.black)
        .hfSingleLineText(minimumScaleFactor: 0.74)
        .padding(.horizontal, 7)
        .frame(height: 20)
        .background(HFColors.goldGradient)
        .clipShape(Capsule())
        .shadow(color: HFColors.shadow.opacity(0.32), radius: 8, x: 0, y: 4)
    }
}
