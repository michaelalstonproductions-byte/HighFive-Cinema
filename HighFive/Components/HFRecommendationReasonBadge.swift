import SwiftUI

struct HFRecommendationReasonBadge: View {
    let reason: String

    var body: some View {
        HStack(spacing: HFSpacing.xxs) {
            Image(systemName: "sparkle")
                .font(.system(size: 9, weight: .black))
            Text(reason)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .font(HFTypography.micro)
        .foregroundStyle(HFColors.gold)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 24)
        .background(HFColors.gold.opacity(0.12))
        .clipShape(Capsule())
    }
}
