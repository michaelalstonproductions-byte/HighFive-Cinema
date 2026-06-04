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

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    selection = item.value
                } label: {
                    VStack(spacing: HFSpacing.xxs) {
                        Image(systemName: item.systemImage)
                            .font(.system(size: 20, weight: .semibold))
                        Text(item.title)
                            .font(HFTypography.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                    .foregroundStyle(selection == item.value ? HFColors.gold : HFColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: HFSpacing.tabBarHeight - HFSpacing.sm)
                    .background {
                        if selection == item.value {
                            Capsule()
                                .fill(HFColors.gold.opacity(0.12))
                                .padding(.horizontal, HFSpacing.xs)
                        }
                    }
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, HFSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius + 4, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: HFSpacing.panelRadius + 4, style: .continuous)
                        .fill(HFColors.background.opacity(0.78))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius + 4, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .shadow(color: HFColors.shadow, radius: 22, x: 0, y: 14)
        .padding(.horizontal, HFSpacing.floatingTabHorizontal)
        .padding(.bottom, HFSpacing.sm)
    }
}
