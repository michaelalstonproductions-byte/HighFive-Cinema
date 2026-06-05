import SwiftUI

struct HFWorkflowStageRow: View {
    let title: String
    let status: String
    let systemImage: String
    var isCurrent = false

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: isCurrent ? HFColors.goldStroke : HFColors.glassStroke) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(isCurrent ? 0.2 : 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(isCurrent ? "Current stage" : "Open preview")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }

                Spacer()

                HFStatusBadge(title: status, isProminent: isCurrent)
            }
            .padding(HFSpacing.md)
        }
    }
}
