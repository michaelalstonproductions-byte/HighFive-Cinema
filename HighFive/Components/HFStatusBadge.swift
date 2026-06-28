import SwiftUI

struct HFStatusBadge: View {
    let title: String
    var systemImage: String?
    var isProminent = true

    var body: some View {
        HStack(spacing: HFSpacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 9, weight: .black))
            }

            Text(title)
                .font(HFTypography.micro)
                .hfSingleLineText(minimumScaleFactor: 0.68)
        }
        .foregroundStyle(isProminent ? .black : HFColors.gold)
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 6)
        .background(isProminent ? AnyShapeStyle(HFColors.gold) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
        .overlay(
            Capsule()
                .stroke(isProminent ? Color.clear : HFColors.goldStroke, lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}
