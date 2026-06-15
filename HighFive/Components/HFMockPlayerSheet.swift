import SwiftUI

struct HFMockPlayerSheet: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @State private var showsProtectedDepthPreview = false

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: HFSpacing.xl) {
                HStack {
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("HighFive Player")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local Preview")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                    }
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
                    .accessibilityIdentifier("hf.functional.player.close")
                    .accessibilityLabel("Close player")
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
                .accessibilityIdentifier("hf.player.cinematicFrame")

                HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                    VStack(alignment: .leading, spacing: HFSpacing.md) {
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundStyle(HFColors.gold)
                        Text("Player route ready")
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer()
                        Text("Ready")
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
                        Text("No streaming provider connected. HighFive player controls are local preview only.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(HFSpacing.lg)
                }
                .accessibilityIdentifier("hf.player.localPreview")

                Button {
                    showsProtectedDepthPreview = true
                } label: {
                    Label("Try Depth + Peek", systemImage: "cube.transparent")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.player.depthPeekCTA")

                Spacer()
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showsProtectedDepthPreview) {
            HighFiveProtectedSpatialPeekBridge()
        }
        .accessibilityIdentifier("hf.functional.player.watchNow")
        .accessibilityIdentifier("hf.player.surface")
        .accessibilityIdentifier("hf.player.primaryActions")
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
