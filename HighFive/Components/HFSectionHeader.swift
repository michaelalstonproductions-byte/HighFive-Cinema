import SwiftUI

struct HFSectionHeader: View {
    let title: String
    var actionTitle: String? = "See All"
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer()

            if let actionTitle {
                Button(action: { action?() }) {
                    Text(actionTitle)
                        .font(HFTypography.body.weight(.bold))
                        .foregroundStyle(HFColors.gold)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
