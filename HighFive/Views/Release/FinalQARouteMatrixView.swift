import SwiftUI

struct FinalQARouteMatrixView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                routeSection(title: "Watch Routes", items: HFFinalDemoTourData.viewerPath, icon: "play.rectangle.fill")
                routeSection(title: "Create Routes", items: HFFinalDemoTourData.creatorPath, icon: "shippingbox.fill")
                routeSection(title: "Connect Routes", items: HFFinalDemoTourData.communityPath, icon: "person.2.fill")
                routeSection(title: "Launch Routes", items: HFFinalDemoTourData.launchPath, icon: "flag.checkered")
                routeSection(title: "Export Routes", items: HFFinalDemoTourData.exportPath, icon: "square.and.arrow.up", status: "Future")
                demoRoutesSection
                safetySection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Final QA Matrix")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Local matrix", isProminent: true)

            Text("Final QA Route Matrix")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Review the local screens that final QA should walk.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func routeSection(title: String, items: [String], icon: String, status: String = "Local") -> some View {
        HFDemoChecklistCard(title: title, items: items, systemImage: icon, status: status)
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var demoRoutesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Demo / Walkthrough Routes", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    FinalDemoTourView()
                } label: {
                    HFActionTile(title: "Final Demo Tour", subtitle: "Walk through the full HighFive product spine.", systemImage: "map.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DemoAudiencePathView()
                } label: {
                    HFActionTile(title: "Demo Audience Paths", subtitle: "Choose viewer, creator, community, launch, export, or full product paths.", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DemoSafetySummaryView()
                } label: {
                    HFActionTile(title: "Demo Safety Summary", subtitle: "Confirm local-only behavior and locked systems.", systemImage: "lock.shield.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DemoReviewChecklistView()
                } label: {
                    HFActionTile(title: "Demo Review Checklist", subtitle: "Review static walkthrough checkpoints.", systemImage: "checklist.checked")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var safetySection: some View {
        HFDemoChecklistCard(
            title: "Safety Routes",
            items: ["Demo Safety Summary", "Release Candidate Prep", "Product Spine Lockdown", "Export locked planning copy"],
            systemImage: "shield.lefthalf.filled",
            status: "Locked"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
