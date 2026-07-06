import SwiftUI

enum HFDepthPosterScale {
    case detail
    case catalog

    var outerPadding: CGFloat {
        switch self {
        case .detail: return 10
        case .catalog: return 5
        }
    }

    var framePadding: CGFloat {
        switch self {
        case .detail: return 14
        case .catalog: return 6
        }
    }

    var padding: CGFloat {
        outerPadding + framePadding
    }

    var posterCornerRadius: CGFloat {
        switch self {
        case .detail: return 22
        case .catalog: return 16
        }
    }

    var outerCornerRadius: CGFloat {
        switch self {
        case .detail: return 6
        case .catalog: return 20
        }
    }

    var shadowRadius: CGFloat {
        switch self {
        case .detail: return 34
        case .catalog: return 14
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .detail: return 22
        case .catalog: return 8
        }
    }

    var depthRotation: Double {
        switch self {
        case .detail: return 3.0
        case .catalog: return 1.35
        }
    }

    var naturalGlowBlur: CGFloat {
        switch self {
        case .detail: return 22
        case .catalog: return 9
        }
    }

    var naturalGlowCoreWidth: CGFloat {
        switch self {
        case .detail: return 3.8
        case .catalog: return 1.8
        }
    }

    var naturalGlowOpacity: Double {
        switch self {
        case .detail: return 0.28
        case .catalog: return 0.14
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .detail: return "hf.titleDetail.depthPosterFrame"
        case .catalog: return "hf.catalog.depthPosterFrame"
        }
    }
}

struct HFDepthPosterFrame<Poster: View>: View {
    let width: CGFloat
    let height: CGFloat
    let scale: HFDepthPosterScale
    let role: HFDepthSurfaceRole
    let depthEnabled: Bool
    let poster: Poster

    init(
        width: CGFloat,
        height: CGFloat,
        scale: HFDepthPosterScale,
        role: HFDepthSurfaceRole? = nil,
        depthEnabled: Bool = true,
        @ViewBuilder poster: () -> Poster
    ) {
        self.width = width
        self.height = height
        self.scale = scale
        self.role = role ?? (scale == .detail ? .detailPoster : .rowCard)
        self.depthEnabled = depthEnabled
        self.poster = poster()
    }

    var body: some View {
        let profile = HFCinematicDepthDirector.profile(for: role)
        DepthMotionProvider(
            isEnabled: depthEnabled,
            clamp: 1,
            geometryInfluence: profile.geometryInfluence,
            role: role
        ) { motion in
            let x = motion.x
            let y = motion.y
            let motionActive = depthEnabled && motion.isActive

            ZStack {
                depthSmokeAndShadow(x: motionActive ? x : 0, y: motionActive ? y : 0)

                framedPoster(x: motionActive ? x : 0, y: motionActive ? y : 0)
                    .rotation3DEffect(
                        .degrees(motionActive ? Double(-x) * profile.rotationMax : 0),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.55
                    )
                    .rotation3DEffect(
                        .degrees(motionActive ? Double(y) * profile.rotationMax * 0.62 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.55
                    )
                    .shadow(
                        color: .black.opacity(scale == .detail ? 0.58 : 0.36),
                        radius: scale.shadowRadius,
                        x: motionActive ? -x * profile.backgroundOffsetMax * 0.70 : 0,
                        y: scale.shadowY
                    )
            }
            .frame(width: totalWidth, height: totalHeight)
        }
        .frame(width: totalWidth, height: totalHeight)
        .accessibilityIdentifier(scale.accessibilityIdentifier)
    }

    private var totalWidth: CGFloat {
        width + scale.padding * 2
    }

    private var totalHeight: CGFloat {
        height + scale.padding * 2
    }

    private func clamped(_ value: CGFloat) -> CGFloat {
        max(-1, min(1, value))
    }

    private func framedPoster(x: CGFloat, y: CGFloat) -> some View {
        ZStack {
            naturalBorderGlow

            outerFrame

            poster
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: scale.posterCornerRadius, style: .continuous))
                .overlay(innerGlassReflection(x: x, y: y))
                .overlay(edgeVignette)
                .overlay(
                    RoundedRectangle(cornerRadius: scale.posterCornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.62), lineWidth: 1)
                )
                .padding(scale.framePadding)
                .overlay(innerGoldLine)
                .padding(scale.outerPadding)
        }
        .frame(width: totalWidth, height: totalHeight)
    }

    private var naturalBorderGlow: some View {
        ZStack {
            HStack(spacing: 0) {
                verticalGlowEdge(alignment: .leading)
                Spacer(minLength: 0)
                verticalGlowEdge(alignment: .trailing)
            }

            VStack(spacing: 0) {
                horizontalGlowEdge()
                Spacer(minLength: 0)
                horizontalGlowEdge()
            }

            RoundedRectangle(cornerRadius: scale.outerCornerRadius, style: .continuous)
                .stroke(Color.white.opacity(scale == .detail ? 0.10 : 0.045), lineWidth: scale.naturalGlowCoreWidth)
                .blur(radius: scale == .detail ? 1.4 : 0.7)
                .opacity(scale == .detail ? 0.58 : 0.38)
        }
        .frame(width: totalWidth, height: totalHeight)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func verticalGlowEdge(alignment: Alignment) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: scale.naturalGlowCoreWidth, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(scale.naturalGlowOpacity * 0.25),
                            Color(red: 1.0, green: 0.86, blue: 0.36).opacity(scale.naturalGlowOpacity),
                            Color.white.opacity(scale.naturalGlowOpacity * 0.42),
                            Color(red: 0.95, green: 0.48, blue: 0.16).opacity(scale.naturalGlowOpacity * 0.68),
                            HFColors.gold.opacity(scale.naturalGlowOpacity * 0.20)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: scale.naturalGlowCoreWidth, height: totalHeight * 0.88)
                .blur(radius: 0.6)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.02),
                            HFColors.gold.opacity(scale.naturalGlowOpacity),
                            Color(red: 0.95, green: 0.50, blue: 0.18).opacity(scale.naturalGlowOpacity * 0.52),
                            HFColors.gold.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: scale == .detail ? 16 : 7, height: totalHeight * 0.96)
                .blur(radius: scale.naturalGlowBlur)
        }
        .frame(width: scale == .detail ? 26 : 12, height: totalHeight, alignment: alignment)
    }

    private func horizontalGlowEdge() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: scale.naturalGlowCoreWidth, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.02),
                            HFColors.gold.opacity(scale.naturalGlowOpacity * 0.62),
                            Color.white.opacity(scale.naturalGlowOpacity * 0.20),
                            HFColors.gold.opacity(scale.naturalGlowOpacity * 0.44),
                            HFColors.gold.opacity(0.02)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: totalWidth * 0.88, height: scale.naturalGlowCoreWidth)
                .blur(radius: 0.5)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(HFColors.gold.opacity(scale.naturalGlowOpacity * 0.42))
                .frame(width: totalWidth * 0.96, height: scale == .detail ? 12 : 5)
                .blur(radius: scale.naturalGlowBlur)
        }
        .frame(width: totalWidth, height: scale == .detail ? 24 : 10)
    }

    private var outerFrame: some View {
        RoundedRectangle(cornerRadius: scale.outerCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.020, green: 0.018, blue: 0.015),
                        Color(red: 0.120, green: 0.080, blue: 0.040),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: scale.outerCornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(scale == .detail ? 0.08 : 0.05),
                                HFColors.gold.opacity(scale == .detail ? 0.30 : 0.18),
                                Color.black.opacity(0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: scale == .detail ? 1.2 : 0.8
                    )
            )
            .overlay(frameTexture)
    }

    private var frameTexture: some View {
        ZStack {
            LinearGradient(
                colors: [
                    .clear,
                    Color.white.opacity(scale == .detail ? 0.030 : 0.016),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    .clear,
                    Color.black.opacity(0.24)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .blendMode(.screen)
        .allowsHitTesting(false)
    }

    private var innerGoldLine: some View {
        RoundedRectangle(cornerRadius: max(2, scale.posterCornerRadius - 2), style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        HFColors.gold.opacity(scale == .detail ? 0.66 : 0.38),
                        Color(red: 0.95, green: 0.55, blue: 0.20).opacity(scale == .detail ? 0.44 : 0.24),
                        HFColors.gold.opacity(scale == .detail ? 0.52 : 0.30)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: scale == .detail ? 1.2 : 0.8
            )
            .padding(scale.outerPadding + 4)
            .allowsHitTesting(false)
    }

    private func innerGlassReflection(x: CGFloat, y: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: scale.posterCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(scale == .detail ? 0.13 : 0.06),
                        .clear,
                        Color.white.opacity(0.024)
                    ],
                    startPoint: UnitPoint(
                        x: max(0, min(1, 0.10 - x * 0.12)),
                        y: max(0, min(1, 0.04 - y * 0.10))
                    ),
                    endPoint: UnitPoint(
                        x: max(0, min(1, 0.92 - x * 0.08)),
                        y: max(0, min(1, 0.96 - y * 0.08))
                    )
                )
            )
            .blendMode(.screen)
            .allowsHitTesting(false)
    }

    private var edgeVignette: some View {
        RoundedRectangle(cornerRadius: scale.posterCornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        .black.opacity(0.00),
                        .black.opacity(0.00),
                        .black.opacity(scale == .detail ? 0.18 : 0.10)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }

    private func depthSmokeAndShadow(x: CGFloat, y: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: scale == .detail ? 34 : 20, style: .continuous)
                .fill(HFColors.gold.opacity(scale == .detail ? 0.075 : 0.035))
                .blur(radius: scale == .detail ? 30 : 12)
                .offset(x: -x * 12, y: 16)

            RadialGradient(
                colors: [
                    HFColors.gold.opacity(scale == .detail ? 0.16 : 0.06),
                    .clear
                ],
                center: UnitPoint(
                    x: max(0.14, min(0.86, 0.50 - x * 0.14)),
                    y: max(0.12, min(0.70, 0.26 - y * 0.10))
                ),
                startRadius: 10,
                endRadius: scale == .detail ? 280 : 120
            )
            .frame(width: totalWidth + 40, height: totalHeight + 40)
            .allowsHitTesting(false)
        }
    }
}
