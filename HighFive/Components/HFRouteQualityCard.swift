import SwiftUI

struct HFRouteQualityCard: View {
    let item: HFRouteQualityItem

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

                        HFStatusBadge(title: item.routeState, isProminent: item.routeState == "Local route")
                    }

                    Text(item.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.sm) {
                        HFRouteChip(title: item.pillar, systemImage: "circle.grid.2x2.fill")
                        HFRouteChip(title: item.issueType, systemImage: "tag.fill")
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
