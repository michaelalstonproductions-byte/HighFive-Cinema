import SwiftUI

struct HFSpineNavigationMapCard: View {
    let item: HFSpineNavigationMapItem

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

                        HFStatusBadge(title: item.status, isProminent: item.status == "Spine Review")
                    }

                    Text(item.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.sm) {
                        HFRouteChip(title: item.source, systemImage: "arrow.up.left.circle.fill")
                        HFRouteChip(title: item.destination, systemImage: "arrow.down.right.circle.fill")
                    }
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
