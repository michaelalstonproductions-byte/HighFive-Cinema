import SwiftUI

struct HFFinalDemoStepCard: View {
    let step: HFFinalDemoStep
    let stepNumber: Int
    var showsRouteCue = true

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Text("\(stepNumber)")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(.black)
                    .frame(width: 34, height: 34)
                    .background(HFColors.goldGradient)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(alignment: .top, spacing: HFSpacing.sm) {
                        Image(systemName: step.systemImage)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(HFColors.gold)

                        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                            Text(step.title)
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(step.subtitle)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: HFSpacing.xs)

                        HFStatusBadge(title: step.status, isProminent: false)
                    }

                    HStack(spacing: HFSpacing.xs) {
                        HFRouteChip(title: step.pillar, systemImage: "circle.grid.2x2.fill")

                        if showsRouteCue {
                            HFRouteChip(title: step.routeLabel, systemImage: "arrow.right")
                        } else {
                            HFRouteChip(title: "Locked until scoped", systemImage: "lock.fill")
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
    }
}
