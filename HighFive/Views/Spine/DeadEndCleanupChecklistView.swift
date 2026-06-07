import SwiftUI

struct DeadEndCleanupChecklistView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                cleanupSection(title: "Tappable Route Check", group: "Route")
                cleanupSection(title: "Product Copy Check", group: "Copy")
                cleanupSection(title: "Pillar Clarity Check", group: "Pillar")
                cleanupRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Dead-End Cleanup")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Static checklist", isProminent: true)

            Text("Dead-End Cleanup Checklist")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Prevent confusing cards before the visual identity pass.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func cleanupSection(title: String, group: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineRouteQualityData.cleanupItems(for: group)) { item in
                    HFDeadEndCleanupCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var cleanupRule: some View {
        HFInsightCard(
            title: "Cleanup Rule",
            message: "If a route cannot open a real local screen, make it a static locked card instead of a broken path.",
            systemImage: "lock.shield.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
