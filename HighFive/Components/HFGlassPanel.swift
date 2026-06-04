import SwiftUI

struct HFGlassPanel<Content: View>: View {
    let cornerRadius: CGFloat
    let strokeColor: Color
    let content: Content

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
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(HFColors.backgroundRaised.opacity(0.58))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1)
            )
            .shadow(color: HFColors.shadow, radius: 18, x: 0, y: 12)
    }
}
