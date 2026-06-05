import SwiftUI

struct HFReleaseBlockerRow: View {
    let title: String
    let status: String
    var systemImage = "exclamationmark.triangle.fill"

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: HFSpacing.xs)

            HFStatusBadge(title: status, isProminent: status == "Blocking")
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}
