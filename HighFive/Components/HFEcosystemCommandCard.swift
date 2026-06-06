import SwiftUI

struct HFEcosystemCommandCard: View {
    let item: HFEcosystemCommandItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: item.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 40, height: 40)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Spacer(minLength: HFSpacing.xs)

                    HFStatusBadge(title: item.status, isProminent: false)
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(item.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(item.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: 214, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
