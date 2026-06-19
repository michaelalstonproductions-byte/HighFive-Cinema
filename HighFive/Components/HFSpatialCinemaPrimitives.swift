import SwiftUI

struct HFOpticalGlassSurface<Content: View>: View {
    let cornerRadius: CGFloat
    let strokeColor: Color
    let content: Content

    init(
        cornerRadius: CGFloat = HFSpacing.panelRadius,
        strokeColor: Color = HFColors.glassStroke,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.black.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.white.opacity(0.035))
                    )
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.02),
                                Color.black.opacity(0.36)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.55), radius: 18, x: 0, y: 12)
    }
}

struct HFDepthContourOverlay: View {
    var color: Color = HFColors.cyanGlow
    var lineWidth: CGFloat = 1

    var body: some View {
        GeometryReader { proxy in
            let inset = max(12, min(proxy.size.width, proxy.size.height) * 0.06)
            ZStack {
                RoundedRectangle(cornerRadius: HFSpacing.heroRadius + 4, style: .continuous)
                    .stroke(color.opacity(0.36), lineWidth: lineWidth)
                    .padding(inset)

                RoundedRectangle(cornerRadius: HFSpacing.heroRadius + 12, style: .continuous)
                    .stroke(color.opacity(0.18), lineWidth: lineWidth)
                    .padding(inset * 1.9)

                HStack {
                    contourMark
                    Spacer()
                    contourMark
                }
                .padding(.horizontal, inset * 0.9)
                .padding(.top, inset * 1.2)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var contourMark: some View {
        Capsule()
            .fill(color.opacity(0.62))
            .frame(width: 34, height: 2)
            .shadow(color: color.opacity(0.55), radius: 8)
    }
}

struct HFEnergyAction: View {
    enum Style {
        case gold
        case cyan
        case glass
    }

    let title: String
    let systemImage: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(HFTypography.smallAction)
                .foregroundStyle(foregroundStyle)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundStyle)
                .overlay(border)
                .clipShape(Capsule())
                .shadow(color: glowColor, radius: glowRadius, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var foregroundStyle: Color {
        switch style {
        case .gold:
            return .black
        case .cyan, .glass:
            return HFColors.textPrimary
        }
    }

    private var backgroundStyle: AnyShapeStyle {
        switch style {
        case .gold:
            return AnyShapeStyle(HFColors.goldGradient)
        case .cyan:
            return AnyShapeStyle(Color.black.opacity(0.58))
        case .glass:
            return AnyShapeStyle(Color.white.opacity(0.12))
        }
    }

    @ViewBuilder
    private var border: some View {
        switch style {
        case .gold:
            Capsule().stroke(HFColors.gold.opacity(0.72), lineWidth: 1)
        case .cyan:
            Capsule().stroke(HFColors.cyanGlow.opacity(0.68), lineWidth: 1)
        case .glass:
            Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1)
        }
    }

    private var glowColor: Color {
        switch style {
        case .gold:
            return HFColors.amberGlow.opacity(0.32)
        case .cyan:
            return HFColors.cyanGlow.opacity(0.24)
        case .glass:
            return Color.clear
        }
    }

    private var glowRadius: CGFloat {
        style == .glass ? 0 : 16
    }
}
