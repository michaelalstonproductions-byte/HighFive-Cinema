import SwiftUI

struct ProductSpineGapReviewView: View {
    private let pillars = ["Watch", "Create", "Connect", "Launch", "Export"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                gapSnapshotSection

                ForEach(pillars, id: \.self) { pillar in
                    gapSection(title: "\(pillar) Gaps", pillar: pillar)
                }

                afterGapReviewSection
                gapRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Gap Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Spine hardening", isProminent: true)

            Text("Product Spine Gap Review")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Find weak spots before the final visual pass.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var gapSnapshotSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Gap Snapshot", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: HFSpacing.md)], spacing: HFSpacing.md) {
                ForEach([
                    ("Watch", "Local route present", "play.rectangle.fill"),
                    ("Create", "Local route present", "shippingbox.fill"),
                    ("Connect", "Local route present", "person.2.fill"),
                    ("Launch", "Local route present", "flag.checkered"),
                    ("Export", "Static card only", "lock.shield.fill")
                ], id: \.0) { item in
                    HFEcosystemCard(
                        title: item.0,
                        subtitle: item.1 == "Static card only" ? "Preview-only route state is documented and locked." : "Review path is present for local QA.",
                        systemImage: item.2,
                        status: item.1,
                        minWidth: 210
                    )
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func gapSection(title: String, pillar: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineGapData.gaps(for: pillar)) { item in
                    HFSpineGapCard(item: item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var afterGapReviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "After Gap Review", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    RouteQualityCenterView()
                } label: {
                    HFActionTile(title: "Route Quality Center", subtitle: "Confirm live local routes and locked placeholders are clearly labeled.", systemImage: "arrow.triangle.branch")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DeadEndCleanupChecklistView()
                } label: {
                    HFActionTile(title: "Dead-End Cleanup Checklist", subtitle: "Prevent static cards from reading like broken buttons.", systemImage: "checklist.checked")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var gapRule: some View {
        HFInsightCard(
            title: "Gap Rule",
            message: "Fix structural route gaps before visual parity. Do not connect real systems during spine hardening.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
