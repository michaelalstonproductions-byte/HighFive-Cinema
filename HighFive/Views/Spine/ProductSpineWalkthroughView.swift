import SwiftUI

struct ProductSpineWalkthroughView: View {
    private let walkthroughGroups: [(title: String, pillar: String, routeTitles: [String])] = [
        ("Step 1 - Watch", "Watch", ["Home", "Search", "Movie Detail", "My List", "Downloads"]),
        ("Step 2 - Create", "Create", ["Creator Mode", "Package Builder", "Team Review", "Release Readiness"]),
        ("Step 3 - Connect", "Connect", ["Connect Hub", "Social Rooms", "Creator Circles", "Activity Feed"]),
        ("Step 4 - Launch", "Launch", ["Launch Center", "Access Preview", "Release Presentation", "Demo Checklist"]),
        ("Step 5 - Export", "Export", ["Export Safety Center", "Social Export Hub", "Protected Capture Roadmap"])
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Watch", "Create", "Connect", "Launch", "Export"])

                ForEach(walkthroughGroups, id: \.title) { group in
                    walkthroughSection(group)
                }

                beforeVisualPassSection
                walkthroughRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Spine Walkthrough")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Walkthrough", isProminent: true)

            Text("Product Spine Walkthrough")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Walk the local product in the order it should be understood.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func walkthroughSection(_ group: (title: String, pillar: String, routeTitles: [String])) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: group.title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(items(for: group), id: \.id) { item in
                    HFProductSpineRouteLink(item: item) {
                        HFProductSpineRouteCard(item: item, showsRouteCue: item.routeType != "static")
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func items(for group: (title: String, pillar: String, routeTitles: [String])) -> [HFProductSpineRouteItem] {
        let routes = HFProductSpineCompletionData.routes(for: group.pillar)
        return group.routeTitles.compactMap { title in
            routes.first { $0.title == title }
        }
    }

    private var beforeVisualPassSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Before Visual Pass", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    PillarHardeningCenterView()
                } label: {
                    HFActionTile(title: "Pillar Hardening Center", subtitle: "Confirm each pillar has a clear review path.", systemImage: "shield.lefthalf.filled")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    SpineReviewPathsView()
                } label: {
                    HFActionTile(title: "Spine Review Paths", subtitle: "Walk the product spine in repeatable QA order.", systemImage: "map.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    PreVisualLockView()
                } label: {
                    HFActionTile(title: "Pre-Visual Lock", subtitle: "Confirm mockup matching comes after spine QA.", systemImage: "checkmark.seal.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var walkthroughRule: some View {
        HFInsightCard(
            title: "Walkthrough Rule",
            message: "Use this route order for product understanding. Use mockups later for visual alignment.",
            systemImage: "map.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
