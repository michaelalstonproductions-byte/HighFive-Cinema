import SwiftUI

struct HFEcosystemCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var status: String?
    var minWidth: CGFloat = 220

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 40, height: 40)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Spacer(minLength: HFSpacing.xs)

                    if let status {
                        HFStatusBadge(title: status, isProminent: false)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(width: minWidth, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
