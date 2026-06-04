import SwiftUI

struct HFSegmentedControl<Selection: Hashable>: View {
    let items: [(Selection, String)]
    @Binding var selection: Selection

    var body: some View {
        HStack(spacing: HFSpacing.xs) {
            ForEach(items, id: \.0) { value, title in
                Button {
                    selection = value
                } label: {
                    Text(title)
                        .font(HFTypography.caption)
                        .foregroundStyle(selection == value ? .black : HFColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            if selection == value {
                                HFColors.goldGradient
                            } else {
                                Color.clear
                            }
                        }
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(HFSpacing.xxs)
        .background(HFColors.surface.opacity(0.88))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(HFColors.glassStroke, lineWidth: 1))
    }
}
