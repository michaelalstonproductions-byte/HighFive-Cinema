import SwiftUI

struct HFProductSpinePillarCard: View {
    let pillar: HFProductSpineCompletionPillar

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    Image(systemName: pillar.systemImage)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Spacer(minLength: HFSpacing.xs)

                    HFStatusBadge(title: pillar.status, isProminent: false)
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(pillar.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)

                    Text(pillar.goal)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(pillar.subtitle)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
