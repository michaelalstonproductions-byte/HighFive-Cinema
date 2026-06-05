import SwiftUI

struct HFFooterActionBar<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                content
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }
}
