import SwiftUI

struct HFBlockingItemRow: View {
    let title: String
    var isReady = false

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isReady ? HFColors.gold : HFColors.orange)
                .frame(width: 28)

            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}
