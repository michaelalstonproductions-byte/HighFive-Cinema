import SwiftUI

struct ReleaseCandidatePrepView: View {
    private let pillars = [
        ("Watch", "Streaming shell, Movie Detail, Search, Library, Downloads.", "Ready", "play.rectangle.fill"),
        ("Create", "Creator Mode, package builder, team review, release readiness.", "Local", "shippingbox.fill"),
        ("Connect", "Connect Hub, rooms, circles, graph, suggestions, activity.", "Local", "person.2.fill"),
        ("Launch", "Launch Center, access preview, presentation, demo checklist.", "Local", "flag.checkered"),
        ("Export", "Future share-ready previews stay locked until scoped.", "Future", "square.and.arrow.up")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                spineSnapshotSection
                finalDemoSection
                finalChecklistSection
                safetyLocksSection
                routeReadinessSection
                knownRisksSection
                releaseRule
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("RC Prep")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFStatusBadge(title: "Final QA prep", isProminent: true)

            Text("Release Candidate Prep")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Lock the HighFive product spine before final QA.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var spineSnapshotSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Product Spine Snapshot", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: HFSpacing.md)], spacing: HFSpacing.md) {
                ForEach(pillars, id: \.0) { pillar in
                    HFEcosystemCard(title: pillar.0, subtitle: pillar.1, systemImage: pillar.3, status: pillar.2, minWidth: 220)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var finalDemoSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Final Demo", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    FinalDemoTourView()
                } label: {
                    HFActionTile(title: "Final Demo Tour", subtitle: "Walk the complete Watch to Export product spine.", systemImage: "map.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DemoAudiencePathView()
                } label: {
                    HFActionTile(title: "Demo Paths", subtitle: "Choose viewer, creator, community, launch, export, or full product walkthroughs.", systemImage: "point.topleft.down.curvedto.point.bottomright.up")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DemoSafetySummaryView()
                } label: {
                    HFActionTile(title: "Demo Safety Summary", subtitle: "Confirm the walkthrough remains local, locked, and protected.", systemImage: "lock.shield.fill")
                }
                .buttonStyle(.plain)

                NavigationLink {
                    DemoReviewChecklistView()
                } label: {
                    HFActionTile(title: "Demo Review Checklist", subtitle: "Review the static final walkthrough checklist.", systemImage: "checklist.checked")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var finalChecklistSection: some View {
        HFDemoChecklistCard(
            title: "Final QA Checklist",
            items: [
                "Five tabs present",
                "Home explains the product",
                "Profile acts as product hub",
                "Ecosystem Command Center is reachable",
                "Watch, Create, Connect, Launch, and Export are all discoverable"
            ],
            systemImage: "checkmark.seal.fill",
            status: "Static"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var safetyLocksSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Critical Safety Locks", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFFinalDemoTourData.safetyLocks.prefix(8)) { lock in
                    HFDemoSafetyLockCard(lock: lock)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var routeReadinessSection: some View {
        HFDemoChecklistCard(
            title: "Route Readiness",
            items: [
                "Watch: Home, Search, Movie Detail, My List, Downloads",
                "Create: Creator Mode, Command Center, Package Builder, Release Readiness",
                "Connect: Hub, Social Rooms, Creator Circles, Social Graph, Activity",
                "Launch: Launch Center, Access Preview, Release Presentation, Demo Checklist",
                "Export: Future preview path and safety locks are visible"
            ],
            systemImage: "arrow.triangle.branch",
            status: "Local"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var knownRisksSection: some View {
        HFDemoChecklistCard(
            title: "Known Risks",
            items: [
                "Dirty-tree tags",
                "Figma drift",
                "Poster mapping risk",
                "Protected capture risk",
                "Real export risk",
                "Permission prompt risk",
                "StoreKit/payment risk",
                "Backend/auth risk"
            ],
            systemImage: "exclamationmark.triangle.fill",
            status: "Review"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var releaseRule: some View {
        HFInsightCard(
            title: "Release Candidate Rule",
            message: "HighFive is ready for final QA only when the tree is clean, the current phase is committed, the QA tag is on HEAD, and every real system remains locked until separately scoped.",
            systemImage: "checkmark.seal.fill"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}
