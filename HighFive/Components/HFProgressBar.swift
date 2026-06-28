import SwiftUI

struct HFProgressBar: View {
    let title: String
    let value: Double
    var valueLabel: String?

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)

                Spacer()

                Text(valueLabel ?? "\(Int(value * 100))%")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
            }

            ProgressView(value: value)
                .tint(HFColors.gold)
                .background(HFColors.controlFill)
                .clipShape(Capsule())
        }
    }
}
