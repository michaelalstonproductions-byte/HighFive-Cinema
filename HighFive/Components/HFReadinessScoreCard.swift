import SwiftUI

struct HFReadinessScoreCard: View {
    let title: String
    let value: String
    let progress: Double?
    var systemImage = "gauge.with.dots.needle.67percent"

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 38, height: 38)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(value)
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let progress {
                    ProgressView(value: progress)
                        .tint(HFColors.gold)
                        .background(HFColors.glassStroke)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
