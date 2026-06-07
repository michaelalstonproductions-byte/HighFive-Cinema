import SwiftUI

struct HFProductSpineRouteCard: View {
    let item: HFProductSpineRouteItem
    var showsRouteCue = true

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 40, height: 40)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(item.title)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.xs)

                        HFStatusBadge(title: item.status, isProminent: false)
                    }

                    Text(item.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HFRouteChip(title: item.pillar, systemImage: "circle.grid.2x2.fill", isActive: false)
                }

                if showsRouteCue {
                    Image(systemName: item.routeType == "locked" ? "lock.fill" : "arrow.right")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(HFColors.gold)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}
