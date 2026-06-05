import SwiftUI

struct HFPersonalSignalCard: View {
    let signal: HFPersonalSignal

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: signal.systemImage)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 38, height: 38)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(signal.title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                    Text(signal.value)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(signal.caption)
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}
