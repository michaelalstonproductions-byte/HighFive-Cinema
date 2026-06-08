import SwiftUI

struct RouteQualityCenterView: View {
    private let pillars = ["Watch", "Create", "Connect", "Launch", "Export"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                routeQualitySnapshotSection

                ForEach(pillars, id: \.self) { pillar in
                    qualitySection(title: "\(pillar) Route Quality", pillar: pillar)
                }

                finalWalkthroughRouteSection
                routeQualityRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Route Quality")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Internal review", isProminent: true)

            Text("Route Quality Center")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Internal route review for local SwiftUI screens. It does not connect backend, accounts, payments, uploads, capture, share, render, or export systems.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var routeQualitySnapshotSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Route Quality Snapshot", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: HFSpacing.md)], spacing: HFSpacing.md) {
                ForEach([
                    ("Watch", "Local route", "play.rectangle.fill"),
                    ("Create", "Local route", "wand.and.stars"),
                    ("Connect", "Static preview", "person.2.fill"),
                    ("Launch", "Static preview", "flag.checkered"),
                    ("Export", "Locked future", "lock.shield.fill")
                ], id: \.0) { item in
                    HFEcosystemCard(
                        title: item.0,
                        subtitle: "Routes are labeled as \(item.1.lowercased()) before visual parity.",
                        systemImage: item.2,
                        status: item.1,
                        minWidth: 210
                    )
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func qualitySection(title: String, pillar: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineRouteQualityData.routeQualityItems(for: pillar)) { item in
                    HFRouteQualityCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var finalWalkthroughRouteSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Final Walkthrough", actionTitle: nil)

            NavigationLink {
                FinalSpineWalkthroughView()
            } label: {
                HFActionTile(title: "Final Spine Walkthrough", subtitle: "Use the final route order before visual parity begins.", systemImage: "map.fill")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var routeQualityRule: some View {
        HFInsightCard(
            title: "Route Quality Rule",
            message: "Every tappable card should either open an existing local SwiftUI route or clearly say it is locked for a future scoped phase.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
