import SwiftUI

struct HFEcosystemPriorityCard: View {
    let priority: HFEcosystemPriority

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: priority.systemImage)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Text(priority.title)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.xs)

                        HFStatusBadge(title: priority.status, isProminent: false)
                    }

                    Text(priority.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
        }
    }
}
