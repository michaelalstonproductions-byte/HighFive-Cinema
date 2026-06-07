import SwiftUI

struct HFVisualPassChecklistCard: View {
    let checkpoint: HFFinalSpineCheckpoint

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                icon

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(alignment: .top, spacing: HFSpacing.sm) {
                        Text(checkpoint.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.sm)

                        HFStatusBadge(title: checkpoint.status, isProminent: checkpoint.status == "Required")
                    }

                    Text(checkpoint.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HFRouteChip(title: checkpoint.checkpointType, systemImage: "checklist.checked")
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(HFColors.gold.opacity(0.14))
            Image(systemName: checkpoint.systemImage)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(HFColors.gold)
        }
        .frame(width: 44, height: 44)
    }
}
