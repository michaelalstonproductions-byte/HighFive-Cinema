import SwiftUI

struct FinalSpineWalkthroughView: View {
    private let pillars = ["Watch", "Create", "Connect", "Launch", "Export / Safety"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                overviewSection

                ForEach(pillars, id: \.self) { pillar in
                    walkthroughSection(title: sectionTitle(for: pillar), pillar: pillar)
                }

                walkthroughRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Final Walkthrough")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Final local walk", isProminent: true)

            Text("Final Spine Walkthrough")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Walk the complete HighFive product spine before visual parity.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Walkthrough Overview", actionTitle: nil)
            HFBreadcrumbTrail(items: ["Watch", "Create", "Connect", "Launch", "Export"])

            HFInsightCard(
                title: "Final local walkthrough",
                message: "Use this final local walkthrough to confirm the product structure before matching the mockups.",
                systemImage: "map.fill"
            )
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func walkthroughSection(title: String, pillar: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineFinalWalkthroughData.walkthroughSteps(for: pillar)) { step in
                    HFFinalSpineWalkthroughCard(step: step)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func sectionTitle(for pillar: String) -> String {
        pillar == "Export / Safety" ? "Export / Safety Steps" : "\(pillar) Steps"
    }

    private var walkthroughRule: some View {
        HFInsightCard(
            title: "Walkthrough Rule",
            message: "Do not start visual parity until this walkthrough is QA-passed and the repo is clean.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
