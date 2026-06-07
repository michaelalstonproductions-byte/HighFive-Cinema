import SwiftUI

struct HFDeadEndCleanupCard: View {
    let item: HFDeadEndCleanupItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                icon

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(alignment: .top, spacing: HFSpacing.sm) {
                        Text(item.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.sm)

                        HFStatusBadge(title: item.cleanupState, isProminent: item.cleanupState == "Required")
                    }

                    Text(item.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HFRouteChip(title: item.pillar, systemImage: "checklist.checked")
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private var icon: some View {
        ZStack {
            Circle()
                .fill(HFColors.gold.opacity(0.14))
            Image(systemName: item.systemImage)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(HFColors.gold)
        }
        .frame(width: 44, height: 44)
    }
}
