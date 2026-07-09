import SwiftUI

struct HFPosterCropTuning {
    let scale: CGFloat
    let yOffset: CGFloat
    let alignment: Alignment

    static let standard = HFPosterCropTuning(
        scale: 1.06,
        yOffset: 8,
        alignment: .center
    )

    static func catalog(movieID: String) -> HFPosterCropTuning {
        switch movieID {
        case "paranormall-s1":
            return HFPosterCropTuning(scale: 1.08, yOffset: 12, alignment: .top)

        case "friendly":
            return HFPosterCropTuning(scale: 1.06, yOffset: 8, alignment: .top)

        case "big-loss",
             "artist-development",
             "maple-street",
             "sunshine",
             "old-satan",
             "arrival-time",
             "black-turnip",
             "bleu-velvet",
             "lost-ones",
             "breaking-chain",
             "blackmailed",
             "halfway-there",
             "toxic":
            return HFPosterCropTuning(scale: 1.08, yOffset: 10, alignment: .top)

        default:
            return .standard
        }
    }

    static func detailMini(movieID: String) -> HFPosterCropTuning {
        switch movieID {
        case "paranormall-s1":
            return HFPosterCropTuning(scale: 1.10, yOffset: 12, alignment: .top)

        case "friendly":
            return HFPosterCropTuning(scale: 1.08, yOffset: 10, alignment: .top)

        default:
            return HFPosterCropTuning(scale: 1.08, yOffset: 8, alignment: .top)
        }
    }
}

struct HFPosterCard: View {
    let movie: Movie
    var width: CGFloat = 140
    var showTitle: Bool = true
    var showMetadata: Bool = false
    var showProgress: Bool = false
    var posterOnly: Bool = false
    @GestureState private var isPressing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasEntered = false

    private var posterHeight: CGFloat {
        posterArtworkHeight + depthFramePadding * 2
    }

    private var posterArtworkWidth: CGFloat {
        max(1, width - depthFramePadding * 2)
    }

    private var posterArtworkHeight: CGFloat {
        posterArtworkWidth * 1.5
    }

    private var depthFramePadding: CGFloat {
        HFDepthPosterScale.catalog.padding
    }

    private var posterCropTuning: HFPosterCropTuning {
        HFPosterCropTuning.catalog(movieID: movie.id)
    }

    private var effectivePosterScale: CGFloat {
        max(posterCropTuning.scale, 1 + ((abs(posterCropTuning.yOffset) * 2 + 2) / posterArtworkHeight))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            posterHeaderBadges

            posterFrame

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
        .accessibilityLabel(accessibilitySummary)
        .accessibilityHint("Opens the title detail when selected")
        .accessibilityIdentifier("hf.catalog.posterCard.\(movie.id)")
        .onAppear {
            guard !hasEntered else { return }
            if reduceMotion {
                hasEntered = true
            } else {
                withAnimation(HFSpatialMotionTokens.cinematicFocusAnimation.delay(HFSpatialMotionTokens.posterEntranceDelay)) {
                    hasEntered = true
                }
            }
        }
    }

    private var accessibilitySummary: String {
        var parts = [movie.title, movie.metadataLine]
        if movie.isOriginal {
            parts.append("HighFive Original")
        }
        if showsOfflineBadge {
            parts.append("Available offline")
        }
        if movie.isComingSoon {
            parts.append(movie.isOriginal ? "Originals coming soon" : "Coming soon")
        }
        if let progress = movie.progress {
            parts.append("\(Int(progress * 100)) percent watched")
        }
        return parts.joined(separator: ". ")
    }

    private var posterFrame: some View {
        PremiumDepthPosterView(
            width: posterArtworkWidth,
            height: posterArtworkHeight,
            scale: .catalog,
            role: isPressing ? .focusedCard : .rowCard,
            depthEnabled: true
        ) {
            posterImageContent
        }
        .hfCinematicCardMotion(isPressed: isPressing, isEntered: hasEntered, accent: HFColors.gold, reduceMotion: reduceMotion)
        .contentShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius + 4, style: .continuous))
        .shadow(color: HFColors.amberGlow.opacity(isPressing ? 0.20 : 0.10), radius: isPressing ? 22 : 15, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.58), radius: isPressing ? 20 : 13, x: 0, y: 11)
        .hoverEffect(.lift)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressing) { _, state, _ in
                    state = true
                }
        )
        .accessibilityIdentifier("hf.catalog.posterFrame.\(movie.id)")
    }

    private var posterImageContent: some View {
        ZStack(alignment: .bottomLeading) {
            posterArtwork
                .frame(width: posterArtworkWidth, height: posterArtworkHeight)

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.20), Color.black.opacity(0.54)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: posterArtworkWidth, height: posterArtworkHeight)

            LinearGradient(
                colors: [Color.white.opacity(0.16), HFColors.gold.opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .center
            )
            .frame(width: posterArtworkWidth, height: posterArtworkHeight)

            LinearGradient(
                colors: [.clear, HFColors.cyanGlow.opacity(0.06), HFColors.amberGlow.opacity(0.08)],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            .frame(width: posterArtworkWidth, height: posterArtworkHeight)

            premiumPosterFinish
            premiumPosterReflection
            premiumPosterSelectionSheen

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
        .frame(width: posterArtworkWidth, height: posterArtworkHeight)
        .aspectRatio(2.0 / 3.0, contentMode: .fit)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.30),
                            HFColors.gold.opacity(movie.isOriginal ? 0.62 : 0.34),
                            HFColors.cyanGlow.opacity(movie.progress == nil ? 0.08 : 0.18),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .background(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius + 4, style: .continuous)
                .fill(HFColors.gold.opacity(movie.isOriginal ? 0.18 : 0.085))
                .blur(radius: 20)
                .offset(y: 11)
        )
        .accessibilityIdentifier("hf.catalog.posterImage.\(movie.id)")
    }

    private var premiumPosterFinish: some View {
        ZStack {
            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                HFColors.gold.opacity(0.12),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1)
                Spacer(minLength: 0)
                Rectangle()
                    .fill(HFColors.gold.opacity(movie.isOriginal ? 0.24 : 0.10))
                    .frame(width: 1)
            }

            LinearGradient(
                colors: [
                    Color.white.opacity(0.24),
                    Color.white.opacity(0.02),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: UnitPoint(x: 0.62, y: 0.44)
            )
            .blendMode(.screen)

            Capsule()
                .fill(Color.white.opacity(0.14))
                .frame(width: posterArtworkWidth * 0.74, height: 1)
                .blur(radius: 2)
                .offset(y: -posterArtworkHeight * 0.38)
        }
        .frame(width: posterArtworkWidth, height: posterArtworkHeight)
        .accessibilityHidden(true)
    }

    private var premiumPosterReflection: some View {
        ZStack {
            HFColors.posterReflectionGradient
                .opacity(isPressing ? 0.92 : 0.82)
                .blendMode(.screen)

            Rectangle()
                .fill(Color.white.opacity(0.18))
                .frame(width: posterArtworkWidth * 0.30, height: posterArtworkHeight * 1.28)
                .rotationEffect(.degrees(23))
                .offset(x: -posterArtworkWidth * 0.18, y: -posterArtworkHeight * 0.15)
                .blur(radius: 9)
                .opacity(movie.isOriginal ? 0.54 : 0.36)

            VStack {
                Rectangle()
                    .fill(HFColors.posterEdgeLight)
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .fill(Color.black.opacity(0.24))
                    .frame(height: 1)
            }

            HStack {
                Rectangle()
                    .fill(HFColors.gold.opacity(movie.isOriginal ? 0.26 : 0.13))
                    .frame(width: 1)
                    .blur(radius: 0.4)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.09))
                    .frame(width: 1)
            }
        }
        .frame(width: posterArtworkWidth, height: posterArtworkHeight)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var premiumPosterSelectionSheen: some View {
        RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(isPressing ? 0.36 : 0.18),
                        HFColors.gold.opacity(isPressing ? 0.54 : 0.18),
                        HFColors.cyanGlow.opacity(isPressing ? 0.22 : 0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isPressing ? 1.4 : 0.8
            )
            .shadow(color: HFColors.amberGlow.opacity(isPressing ? 0.22 : 0.08), radius: isPressing ? 14 : 8, x: 0, y: 6)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var posterHeaderBadges: some View {
        let badges = posterBadges
        if !badges.isEmpty {
            HStack(spacing: HFSpacing.xxs) {
                ForEach(badges, id: \.title) { badge in
                    HFPosterSignalBadge(title: badge.title, systemImage: badge.systemImage)
                        .accessibilityIdentifier("hf.catalog.posterBadge.\(movie.id)")
                }
                Spacer(minLength: 0)
            }
            .frame(width: width, alignment: .leading)
        }
    }

    private var posterBadges: [PosterBadge] {
        var badges: [PosterBadge] = []

        if movie.isComingSoon {
            badges.append(PosterBadge(title: "Coming Soon", systemImage: "calendar.badge.clock"))
        } else if movie.isOriginal {
            badges.append(PosterBadge(title: "HighFive Original", systemImage: "sparkles"))
        }

        if showsOfflineBadge {
            badges.append(PosterBadge(title: "Offline", systemImage: "arrow.down.circle.fill"))
        }

        return badges
    }

    private var showsOfflineBadge: Bool {
        movie.isDownloaded && movie.id != "friendly"
    }

    @ViewBuilder
    private var posterArtwork: some View {
        if HFPosterAssetHealth.hasImage(named: movie.posterAssetName), let assetName = movie.posterAssetName {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(
                    width: posterArtworkWidth * effectivePosterScale,
                    height: posterArtworkHeight * effectivePosterScale,
                    alignment: posterCropTuning.alignment
                )
                .offset(y: posterCropTuning.yOffset)
                .frame(width: posterArtworkWidth, height: posterArtworkHeight)
                .clipped()
                .accessibilityHidden(true)
        } else {
            HFPosterFallback(title: movie.title)
                .frame(width: posterArtworkWidth, height: posterArtworkHeight)
                .accessibilityHidden(true)
        }
    }
}

private struct PosterBadge {
    let title: String
    let systemImage: String
}

private struct HFPosterSignalBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(HFIconography.symbolFont(size: HFIconography.chipIconSize, weight: .black))
                .symbolRenderingMode(.hierarchical)
                .frame(width: HFIconography.chipIconFrame)
            Text(title)
                .font(.system(size: 9, weight: .black, design: .default))
        }
        .foregroundStyle(.black)
        .lineLimit(1)
        .minimumScaleFactor(0.62)
        .padding(.horizontal, 8)
        .frame(maxWidth: 136)
        .frame(height: 22)
        .background(HFColors.goldGradient)
        .clipShape(Capsule())
        .shadow(color: HFColors.shadow.opacity(0.32), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}
