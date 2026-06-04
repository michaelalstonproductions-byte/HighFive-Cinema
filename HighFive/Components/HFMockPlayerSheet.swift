import SwiftUI

struct HFMockPlayerSheet: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: HFSpacing.xl) {
                HStack {
                    Text("Now Playing Preview")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                ZStack(alignment: .bottomLeading) {
                    playerArtwork
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(movie.title)
                            .font(HFTypography.heroTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)
                        Text(movie.subtitle)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                    .padding(HFSpacing.lg)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                        .stroke(HFColors.goldStroke, lineWidth: 1)
                )

                HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                    VStack(alignment: .leading, spacing: HFSpacing.md) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(HFColors.gold)
                            Text("Local mock playback only")
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer()
                            Text("42%")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.gold)
                        }

                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.16))
                                Capsule()
                                    .fill(HFColors.goldGradient)
                                    .frame(width: proxy.size.width * 0.42)
                            }
                        }
                        .frame(height: 7)
                    }
                    .padding(HFSpacing.lg)
                }

                Spacer()
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var playerArtwork: some View {
        if HFPosterAssetHealth.hasImage(named: movie.backdropAssetName ?? movie.posterAssetName),
           let assetName = movie.backdropAssetName ?? movie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
        } else {
            HFPosterFallback(title: movie.title)
        }
    }
}
