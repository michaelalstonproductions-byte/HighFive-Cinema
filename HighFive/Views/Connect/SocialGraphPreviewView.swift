import SwiftUI

struct SocialGraphPreviewView: View {
    @State private var savedNodeIDs: Set<UUID> = []

    private let comingNext = [
        "Real follow graph",
        "Verified profiles",
        "Creator relationship mapping",
        "Studio discovery",
        "Marketplace recommendations"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Social Graph"])
                graphSnapshotSection
                creatorNetworkSection
                projectRelationshipsSection
                mutualCommunitiesSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Social Graph")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Social Graph")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Preview how creators, projects, rooms, and audiences connect.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. This is static local relationship mapping with no accounts or follow backend.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var graphSnapshotSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Graph Snapshot", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                HFMetricCard(title: "Creators connected", value: "48", systemImage: "person.2.fill")
                HFMetricCard(title: "Project circles", value: "18", systemImage: "circle.hexagongrid.fill")
                HFMetricCard(title: "Active rooms", value: "24", systemImage: "bubble.left.and.bubble.right.fill")
                HFMetricCard(title: "Shared audiences", value: "12.4K", systemImage: "person.3.fill")
                HFMetricCard(title: "Marketplace signals", value: "48", systemImage: "storefront.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var creatorNetworkSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Your Creator Network", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.socialGraphNodes) { node in
                    graphNodeCard(node)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var projectRelationshipsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Project Relationships", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.projectRelationships) { node in
                    graphNodeCard(node)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var mutualCommunitiesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Mutual Communities", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(HFConnectPreviewData.mutualCommunities, id: \.self) { community in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "person.3.sequence.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 24)
                            Text(community)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer()
                            HFStatusBadge(title: "Mutual", isProminent: false)
                        }
                        .padding(.vertical, HFSpacing.xxs)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var comingNextSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Coming Next", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(comingNext, id: \.self) { item in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 22)
                            Text(item)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                            Spacer()
                        }
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func graphNodeCard(_ node: HFConnectGraphNode) -> some View {
        Button {
            toggleSaved(node.id)
        } label: {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: node.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(node.title)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: node.relationship, isProminent: false)
                        }

                        Text(node.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: HFSpacing.sm) {
                            HFRouteChip(title: node.metric)
                            HFRouteChip(title: savedNodeIDs.contains(node.id) ? "Saved mock node" : "Tap to save")
                        }
                    }
                }
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Toggle saved state for \(node.title) graph preview")
    }

    private func toggleSaved(_ id: UUID) {
        if savedNodeIDs.contains(id) {
            savedNodeIDs.remove(id)
        } else {
            savedNodeIDs.insert(id)
        }
    }
}
