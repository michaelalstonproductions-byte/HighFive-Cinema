import SwiftUI

struct CommunityDiscoveryPreviewView: View {
    @State private var followedCommunityIDs: Set<UUID> = []

    private let comingNext = [
        "Real communities",
        "Real moderation",
        "Real comments",
        "Real follows",
        "Real messaging"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Community Discovery"])
                featuredCommunitiesSection
                discoveryCategoriesSection
                communitySignalsSection
                recommendedSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Community Discovery")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Community Discovery")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.76)

            Text("Find creator communities, project circles, and audience conversations.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Community follows and room signals are local mock UI.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredCommunitiesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Communities", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.communities) { community in
                    communityCard(community)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var discoveryCategoriesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Discovery Categories", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(HFConnectPreviewData.discoveryCategories, id: \.self) { category in
                        HFRouteChip(title: category, systemImage: "circle.grid.2x2.fill")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var communitySignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Community Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                HFMetricCard(title: "Active rooms", value: "24", systemImage: "rectangle.3.group.fill")
                HFMetricCard(title: "Project circles", value: "18", systemImage: "circle.hexagongrid.fill")
                HFMetricCard(title: "Watch parties planned", value: "7", systemImage: "play.tv.fill")
                HFMetricCard(title: "Creator updates today", value: "36", systemImage: "sparkles")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recommended For You", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(HFConnectPreviewData.recommendedCommunities, id: \.self) { item in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 24)
                            Text(item)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer()
                            HFStatusBadge(title: "Mock", isProminent: false)
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

    private func communityCard(_ community: HFConnectCommunity) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: community.systemImage)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 44, height: 44)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(community.name)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: community.status, isProminent: false)
                        }

                        Text(community.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("\(community.members) members • \(community.category)")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                    }
                }

                Button {
                    toggleFollow(community)
                } label: {
                    Text(followedCommunityIDs.contains(community.id) ? "Following Preview" : "Follow Community")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle mock follow for \(community.name)")
            }
            .padding(HFSpacing.md)
        }
    }

    private func toggleFollow(_ community: HFConnectCommunity) {
        if followedCommunityIDs.contains(community.id) {
            followedCommunityIDs.remove(community.id)
        } else {
            followedCommunityIDs.insert(community.id)
        }
    }
}
