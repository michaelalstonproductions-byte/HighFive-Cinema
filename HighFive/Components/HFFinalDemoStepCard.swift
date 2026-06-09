import SwiftUI

struct HFFinalDemoStepCard: View {
    let step: HFFinalDemoStep
    let stepNumber: Int

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Text("\(stepNumber)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(width: 34, height: 34)
                        .background(HFColors.goldGradient)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(step.actName)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            Image(systemName: step.systemImage)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(HFColors.gold)

                            Text(step.title)
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Text(step.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)

                    HFStatusBadge(title: step.status, isProminent: step.status == "Ready")
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                    HFRouteChip(title: step.pillar, systemImage: "circle.grid.2x2.fill")
                    HFRouteChip(title: step.routeLabel, systemImage: "arrow.right")
                    HFRouteChip(title: step.screenshotTarget, systemImage: "camera.viewfinder")
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    detailBlock(label: "Purpose", value: step.purpose)
                    detailBlock(label: "Expected Proof", value: step.expectedProof)
                    detailBlock(label: "Safety", value: step.safetyNote)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.title), \(step.actName), pillar \(step.pillar), route \(step.routeLabel), purpose \(step.purpose), expected proof \(step.expectedProof), screenshot \(step.screenshotTarget), safety \(step.safetyNote)")
    }

    private func detailBlock(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Text(label)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)

            Text(value)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
