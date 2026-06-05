import SwiftUI

struct HFRecommendationCard: View {
    let recommendation: HFPersonalizedRecommendation
    var minWidth: CGFloat = 228

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: recommendation.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Spacer(minLength: HFSpacing.xs)

                    HFStatusBadge(title: recommendation.accentLabel, isProminent: false)
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(recommendation.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(recommendation.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HFRecommendationReasonBadge(reason: recommendation.reason)
            }
            .frame(width: minWidth, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
