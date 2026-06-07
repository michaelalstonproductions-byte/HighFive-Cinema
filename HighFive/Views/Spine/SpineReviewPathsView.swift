import SwiftUI

struct SpineReviewPathsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header

                ForEach(HFProductSpineGapData.reviewPaths) { path in
                    reviewPathSection(path)
                }
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Review Paths")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "QA order", isProminent: true)

            Text("Spine Review Paths")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Walk each product pillar in a repeatable QA order.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func reviewPathSection(_ path: HFSpineReviewPath) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: path.title, actionTitle: nil)

            HFSpineReviewPathCard(path: path)
                .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }
}
