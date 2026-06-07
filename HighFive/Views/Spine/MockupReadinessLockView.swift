import SwiftUI

struct MockupReadinessLockView: View {
    private let groups = ["Home + Tabs", "Watch", "Create", "Connect", "Launch", "Export / Safety"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header

                ForEach(groups, id: \.self) { group in
                    readinessSection(title: sectionTitle(for: group), group: group)
                }

                lockRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Mockup Readiness")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Structure lock", isProminent: true)

            Text("Mockup Readiness Lock")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Confirm the structure is ready before Figma/mockup matching.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func readinessSection(title: String, group: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineFinalWalkthroughData.readinessItems(for: group)) { item in
                    HFMockupReadinessLockCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func sectionTitle(for group: String) -> String {
        "\(group) Readiness"
    }

    private var lockRule: some View {
        HFInsightCard(
            title: "Lock Rule",
            message: "Mockup parity starts only after product structure, routes, safety locks, and repo truth are stable.",
            systemImage: "lock.shield.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
