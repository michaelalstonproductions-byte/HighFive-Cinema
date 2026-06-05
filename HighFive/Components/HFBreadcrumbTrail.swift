import SwiftUI

struct HFBreadcrumbTrail: View {
    let items: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.xs) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HFRouteChip(
                        title: item,
                        systemImage: index == 0 ? "circle.grid.2x2.fill" : "chevron.right",
                        isActive: index == items.count - 1
                    )
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .scrollClipDisabled()
    }
}
