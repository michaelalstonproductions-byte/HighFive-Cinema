import SwiftUI

struct HFStatusBadge: View {
    let title: String
    var systemImage: String?
    var isProminent = true

    var body: some View {
        HStack(spacing: HFSpacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(HFIconography.symbolFont(size: HFIconography.chipIconSize, weight: .black))
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: HFIconography.chipIconFrame)
            }

            Text(title)
                .font(HFTypography.micro)
                .hfSingleLineText(minimumScaleFactor: 0.68)
        }
        .foregroundStyle(isProminent ? .black : HFColors.gold)
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 6)
        .background(isProminent ? AnyShapeStyle(HFColors.gold) : AnyShapeStyle(HFColors.selectedGoldFill))
        .overlay(
            Capsule()
                .stroke(isProminent ? Color.clear : HFColors.goldStroke, lineWidth: 1)
        )
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}
