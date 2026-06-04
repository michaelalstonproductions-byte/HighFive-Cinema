import SwiftUI

struct HFFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                .padding(.horizontal, HFSpacing.md)
                .frame(height: 36)
                .background {
                    if isSelected {
                        HFColors.goldGradient
                    } else {
                        HFColors.surfaceElevated.opacity(0.86)
                    }
                }
                .overlay(
                    Capsule()
                        .stroke(isSelected ? HFColors.gold.opacity(0.82) : HFColors.glassStroke, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
