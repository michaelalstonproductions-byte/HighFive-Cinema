import SwiftUI

struct HFRouteChip: View {
    let title: String
    var systemImage: String = "arrow.right"
    var isActive = false

    var body: some View {
        HStack(spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .black))
            Text(title)
                .font(HFTypography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(isActive ? .black : HFColors.textPrimary)
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 7)
        .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.glassSurface))
        .overlay(
            Capsule()
                .stroke(isActive ? HFColors.goldStroke : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}
