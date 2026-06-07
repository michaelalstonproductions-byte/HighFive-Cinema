import SwiftUI

struct SpineRouteCoverageView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                coverageSignalsSection
                hardeningRoutesSection
                routeSection(title: "Watch Routes", pillar: "Watch")
                routeSection(title: "Create Routes", pillar: "Create")
                routeSection(title: "Connect Routes", pillar: "Connect")
                routeSection(title: "Launch Routes", pillar: "Launch")
                routeSection(title: "Export Routes", pillar: "Export")
                missingRealSystemsSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Route Coverage")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Coverage map", isProminent: true)

            Text("Spine Route Coverage")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Confirm each local product pillar has a review path.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var coverageSignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Coverage Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: HFSpacing.md)], spacing: HFSpacing.md) {
                ForEach(HFProductSpineCompletionData.coverageSignals) { signal in
                    HFSpineCoverageSignalCard(signal: signal)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var hardeningRoutesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Gap + Review Path Checks", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    ProductSpineGapReviewView()
                } label: {
                    HFActionTile(title: "Product Spine Gap Review", subtitle: "Check weak local routes and locked placeholders.", systemImage: "exclamationmark.triangle.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    SpineReviewPathsView()
                } label: {
                    HFActionTile(title: "Spine Review Paths", subtitle: "Use repeatable QA order for every pillar.", systemImage: "map.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func routeSection(title: String, pillar: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineCompletionData.routes(for: pillar)) { item in
                    HFProductSpineRouteLink(item: item) {
                        HFProductSpineRouteCard(item: item, showsRouteCue: item.routeType != "static")
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var missingRealSystemsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Missing Real Systems", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFProductSpineCompletionData.locks.prefix(6)) { lock in
                    HFLockedSystemCard(item: lock)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }
}
