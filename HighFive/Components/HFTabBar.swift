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

    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    selection = item.value
                } label: {
                    VStack(spacing: HFSpacing.xxs) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: HFResponsiveFit.bottomTabIconSize(width: screenWidth), weight: .semibold))
                            .frame(height: HFResponsiveFit.bottomTabIconSize(width: screenWidth) + 2)
                        Text(item.title)
                            .font(.system(size: HFResponsiveFit.bottomTabFontSize(width: screenWidth), weight: .semibold, design: .default))
                            .hfSingleLineText(minimumScaleFactor: 0.64)
                    }
                    .foregroundStyle(selection == item.value ? HFColors.gold : HFColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: HFResponsiveFit.minimumTapTarget)
                    .frame(height: HFResponsiveFit.bottomTabItemHeight(width: screenWidth))
                    .background {
                        if selection == item.value {
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
                        }
                    }
                    .contentShape(Capsule())
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
                        .fill(Color.black.opacity(0.90))
                )
                .overlay(
                    LinearGradient(
                        colors: [HFColors.warmGlow.opacity(0.42), Color.clear, Color.black.opacity(0.24)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(HFColors.gold.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 26, x: 0, y: 16)
        .shadow(color: HFColors.shadow, radius: 22, x: 0, y: 14)
        .padding(.horizontal, HFResponsiveFit.bottomTabHorizontalPadding(width: screenWidth))
        .padding(.bottom, HFSpacing.md)
        .hfDynamicTypeGuard()
    }
}
