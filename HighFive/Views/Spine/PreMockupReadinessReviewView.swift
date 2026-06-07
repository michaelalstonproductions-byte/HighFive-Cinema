import SwiftUI

struct PreMockupReadinessReviewView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                readinessSection(title: "Structure Readiness", group: "Structure Readiness")
                readinessSection(title: "Pillar Readiness", group: "Pillar Readiness")
                readinessSection(title: "Safety Readiness", group: "Safety Readiness")
                readinessSection(title: "What Mockup Parity Handles Later", group: "Mockup Later")
                finalLockRoutesSection
                readinessRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Pre-Mockup Readiness")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Before mockups", isProminent: true)

            Text("Pre-Mockup Readiness Review")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Confirm the spine is stable before matching the mockups.")
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
                ForEach(HFProductSpineRouteQualityData.readinessItems(for: group)) { item in
                    HFPreMockupReadinessCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var finalLockRoutesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Final Lock Routes", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    FinalSpineWalkthroughView()
                } label: {
                    HFActionTile(title: "Final Spine Walkthrough", subtitle: "Walk Watch, Create, Connect, Launch, and Export before visual parity.", systemImage: "map.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    MockupReadinessLockView()
                } label: {
                    HFActionTile(title: "Mockup Readiness Lock", subtitle: "Confirm the product is ready for visual parity.", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    VisualPassLaunchChecklistView()
                } label: {
                    HFActionTile(title: "Visual Pass Launch Checklist", subtitle: "Confirm repo, product, and visual scope requirements before mockup matching.", systemImage: "checklist.checked")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var readinessRule: some View {
        HFInsightCard(
            title: "Readiness Rule",
            message: "Mockup parity starts after the local product spine is stable, QA-passed, and free of confusing dead ends.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
