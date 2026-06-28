import SwiftUI

struct HFTabItem<Value: Hashable>: Identifiable {
    let value: Value
    let title: String
    let systemImage: String

    var id: String { "\(value)" }
}

struct HFTabBar<Value: Hashable>: View {
    let items: [HFTabItem<Value>]
    @Binding var selection: Value
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.tabSelectionAnimation) {
                        selection = item.value
                    }
                } label: {
                    let isSelected = selection == item.value
                    VStack(spacing: HFSpacing.xxs) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: HFResponsiveFit.bottomTabIconSize(width: screenWidth), weight: isSelected ? .bold : .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .frame(
                                width: HFResponsiveFit.bottomTabIconSize(width: screenWidth) + 8,
                                height: HFResponsiveFit.bottomTabIconSize(width: screenWidth) + 4
                            )
                        Text(item.title)
                            .font(.system(size: HFResponsiveFit.bottomTabFontSize(width: screenWidth), weight: .semibold, design: .default))
                            .hfSingleLineText(minimumScaleFactor: 0.64)
                    }
                    .foregroundStyle(isSelected ? HFColors.gold : HFColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: HFResponsiveFit.minimumTapTarget)
                    .frame(height: HFResponsiveFit.bottomTabItemHeight(width: screenWidth))
                    .scaleEffect(reduceMotion ? 1 : (isSelected ? 1.035 : 1))
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [HFColors.gold.opacity(0.28), HFColors.orange.opacity(0.12)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(HFColors.gold.opacity(0.58), lineWidth: 1)
                                )
                                .padding(.horizontal, HFSpacing.xs)
                                .shadow(color: HFColors.amberGlow.opacity(0.38), radius: 14, x: 0, y: 8)
                                .transition(.opacity.combined(with: .scale(scale: 0.92)))
                        }
                    }
                    .contentShape(Capsule())
                    .animation(reduceMotion ? .easeOut(duration: 0.01) : HFSpatialMotionTokens.tabSelectionAnimation, value: isSelected)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: min(467, max(320, screenWidth - (HFResponsiveFit.bottomTabHorizontalPadding(width: screenWidth) * 2))))
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, HFSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.black.opacity(0.88))
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            HFColors.warmGlow.opacity(0.34),
                            Color.clear,
                            HFColors.cyanGlow.opacity(0.06),
                            Color.black.opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(HFColors.subtleGlassRimGradient, lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(HFColors.gold.opacity(0.20), lineWidth: 1)
                .padding(1)
        )
        .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 26, x: 0, y: 16)
        .shadow(color: HFColors.shadow, radius: 22, x: 0, y: 14)
        .padding(.horizontal, HFResponsiveFit.bottomTabHorizontalPadding(width: screenWidth))
        .padding(.bottom, HFSpacing.md)
        .hfDynamicTypeGuard()
    }
}
