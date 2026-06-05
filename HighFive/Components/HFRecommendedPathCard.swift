import SwiftUI

struct HFRecommendedPathCard: View {
    let path: HFRecommendedPath

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: path.systemImage)
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 54, height: 54)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(path.title)
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: path.status)
                        }

                        Text(path.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.sm) {
                    ForEach(Array(path.steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: HFSpacing.sm) {
                            Text("\(index + 1)")
                                .font(HFTypography.micro)
                                .foregroundStyle(.black)
                                .frame(width: 24, height: 24)
                                .background(HFColors.gold)
                                .clipShape(Circle())

                            Text(step)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer()
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
    }
}
