import SwiftUI

struct HFFinalSpineWalkthroughCard: View {
    let step: HFFinalSpineWalkthroughStep

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                stepIcon

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(alignment: .top, spacing: HFSpacing.sm) {
                        Text(step.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.sm)

                        HFStatusBadge(title: step.status, isProminent: step.status == "Local route")
                    }

                    Text(step.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: HFSpacing.sm) {
                        HFRouteChip(title: step.pillar, systemImage: "circle.grid.2x2.fill")
                        HFRouteChip(title: "Step \(step.stepNumber)", systemImage: "number.circle.fill")
                    }
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private var stepIcon: some View {
        ZStack {
            Circle()
                .fill(HFColors.gold.opacity(0.14))
            Image(systemName: step.systemImage)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(HFColors.gold)
        }
        .frame(width: 44, height: 44)
    }
}
