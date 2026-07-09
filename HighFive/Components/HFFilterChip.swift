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
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.11),
                                HFColors.gold.opacity(0.035),
                                Color.black.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
                .overlay(
                    Capsule()
                        .stroke(isSelected ? HFColors.gold.opacity(0.82) : HFColors.glassStroke.opacity(0.90), lineWidth: 1)
                )
                .shadow(color: isSelected ? HFColors.amberGlow.opacity(0.20) : .black.opacity(0.12), radius: isSelected ? 10 : 6, x: 0, y: 5)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) filter")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Filters the current catalog view")
    }
}
