import SwiftUI

struct SpineReviewPathsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header

                ForEach(HFProductSpineGapData.reviewPaths) { path in
                    reviewPathSection(path)
                }

                deadEndCleanupSection
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

    private var deadEndCleanupSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Dead-End Check", actionTitle: nil)

            NavigationLink {
                DeadEndCleanupChecklistView()
            } label: {
                HFActionTile(title: "Dead-End Cleanup Checklist", subtitle: "Confirm missing optional routes are static locked cards, not broken paths.", systemImage: "checklist.checked")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }
}
