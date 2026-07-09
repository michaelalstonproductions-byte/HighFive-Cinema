import SwiftUI

struct HFGlassPanel<Content: View>: View {
    let cornerRadius: CGFloat
    let strokeColor: Color
    let content: Content
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    init(
        cornerRadius: CGFloat = HFSpacing.panelRadius,
        strokeColor: Color = HFColors.stroke,
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
                    .fill(reduceTransparency ? AnyShapeStyle(Color.black.opacity(0.96)) : AnyShapeStyle(.ultraThinMaterial))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(reduceTransparency ? Color.black.opacity(0.42) : HFColors.glassSurface)
                    )
                    .overlay(
                        HFColors.opticalGlassGradient
                        .opacity(reduceTransparency ? 0.14 : 0.42)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
                    .overlay(
                        HFColors.cinematicPanelGradient
                            .opacity(reduceTransparency ? 0.10 : 0.32)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    )
                    .overlay(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(HFColors.glassRim, lineWidth: 0.7)
                            .padding(1)
                    }
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(Color.white.opacity(reduceTransparency ? 0.06 : 0.13))
                            .frame(height: 1)
                            .padding(.horizontal, max(10, cornerRadius * 0.58))
                            .padding(.top, 1.5)
                    }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        reduceTransparency ? AnyShapeStyle(strokeColor.opacity(0.70)) : AnyShapeStyle(HFColors.subtleGlassRimGradient),
                        lineWidth: 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor.opacity(0.34), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.62), radius: 20, x: 0, y: 14)
            .shadow(color: Color.black.opacity(0.28), radius: 5, x: 0, y: 1)
            .shadow(color: strokeColor.opacity(reduceTransparency ? 0 : 0.12), radius: 24, x: 0, y: 10)
            .accessibilityIdentifier(reduceTransparency ? "hf.material.glass.reduceTransparency" : "hf.material.glass.panel")
    }
}
