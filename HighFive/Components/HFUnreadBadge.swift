import SwiftUI

struct HFUnreadBadge: View {
    let count: Int

    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(HFTypography.micro)
            .foregroundStyle(.black)
            .frame(minWidth: 20, minHeight: 20)
            .padding(.horizontal, count > 9 ? 4 : 0)
            .background(HFColors.gold)
            .clipShape(Capsule())
            .opacity(count > 0 ? 1 : 0)
            .accessibilityHidden(count == 0)
    }
}
