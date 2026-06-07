import SwiftUI

struct HFSpineReviewPathCard: View {
    let path: HFSpineReviewPath

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: path.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 40, height: 40)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Text(path.title)
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            Spacer(minLength: HFSpacing.xs)

                            HFStatusBadge(title: path.status, isProminent: false)
                        }

                        Text(path.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(Array(path.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            Text("\(index + 1)")
                                .font(HFTypography.micro)
                                .foregroundStyle(.black)
                                .frame(width: 24, height: 24)
                                .background(HFColors.goldGradient)
                                .clipShape(Circle())

                            Text(step)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
    }
}
