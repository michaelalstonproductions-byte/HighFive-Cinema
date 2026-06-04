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
                            .font(.system(size: 23, weight: .semibold))
                        Text(item.title)
                            .font(HFTypography.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                    .foregroundStyle(selection == item.value ? HFColors.gold : HFColors.textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: HFSpacing.tabBarHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HFSpacing.xs)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(HFColors.background.opacity(0.78))
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(HFColors.stroke)
                .frame(height: 1)
        }
    }
}
