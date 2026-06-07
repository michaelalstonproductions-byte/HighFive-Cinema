import SwiftUI

struct SpineNavigationMapView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                mapSection(title: "Entry Points", status: "Entry Point")
                mapSection(title: "Spine Review Routes", status: "Spine Review")
                mapSection(title: "Visual Prep Routes", status: "Visual Prep")
                mapNote
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Navigation Map")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Local map", isProminent: true)

            Text("Spine Navigation Map")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Map how reviewers move through the local product spine.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func mapSection(title: String, status: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineRouteQualityData.navigationItems(status: status)) { item in
                    HFSpineNavigationMapCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var mapNote: some View {
        HFInsightCard(
            title: "Map Note",
            message: "This map is a local navigation reference only. It does not run audits, save route state, or connect services.",
            systemImage: "map.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
