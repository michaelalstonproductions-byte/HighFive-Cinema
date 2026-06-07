import SwiftUI

struct PillarHardeningCenterView: View {
    private let pillars = ["Watch", "Create", "Connect", "Launch", "Export"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Watch", "Create", "Connect", "Launch", "Export"])

                ForEach(pillars, id: \.self) { pillar in
                    hardeningSection(title: "\(pillar) Hardening", pillar: pillar)
                }

                hardeningRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Pillar Hardening")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Pillar review", isProminent: true)

            Text("Pillar Hardening Center")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Strengthen Watch, Create, Connect, Launch, and Export as product pillars.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func hardeningSection(title: String, pillar: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineGapData.hardeningItems(for: pillar)) { item in
                    HFPillarHardeningCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var hardeningRule: some View {
        HFInsightCard(
            title: "Hardening Rule",
            message: "The spine is ready for visual parity only when every pillar has a clear local review path.",
            systemImage: "shield.lefthalf.filled"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
