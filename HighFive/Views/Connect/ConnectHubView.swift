import SwiftUI

struct ConnectHubView: View {
    private let comingNext = [
        "Real profiles",
        "Live follows",
        "Creator comments",
        "Messaging",
        "Project communities"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Profile", "Connect Preview"])
                discoveryRoutesSection
                featuredCreatorsSection
                projectUpdatesSection
                communitySignalsSection
                trendingPackagesSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Connect")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Connect")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Discover creators, follow projects, and see what’s building on HighFive.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Creator profiles, follows, comments, and messaging are local mock UI.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredCreatorsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Creators", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.featuredCreators) { creator in
                    NavigationLink {
                        CreatorProfilePreviewView(creator: creator)
                    } label: {
                        creatorCard(creator)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(creator.name) creator profile preview")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var discoveryRoutesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Community Discovery", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    CommunityDiscoveryPreviewView()
                } label: {
                    HFActionTile(
                        title: "Community Discovery",
                        subtitle: "Find creator communities, project circles, and audience conversations.",
                        systemImage: "person.3.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Community Discovery Preview")

                NavigationLink {
                    WatchPartyPreviewView()
                } label: {
                    HFActionTile(
                        title: "Watch Party Preview",
                        subtitle: "Preview shared viewing rooms without playback sync or live chat.",
                        systemImage: "play.tv.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Watch Party Preview")

                NavigationLink {
                    ProjectCommunityPreviewView()
                } label: {
                    HFActionTile(
                        title: "Project Community",
                        subtitle: "Follow The Friendly updates, audience signals, and mock discussions.",
                        systemImage: "film.stack.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Project Community Preview")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var projectUpdatesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Project Updates", actionTitle: nil)

            NavigationLink {
                ActivityFeedPreviewView()
            } label: {
                HFActionTile(
                    title: "Open Activity Feed",
                    subtitle: "Review mock project updates, reactions, and comment previews.",
                    systemImage: "text.bubble.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Activity Feed Preview")
            .padding(.horizontal, HFSpacing.screenHorizontal)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.projectUpdates) { update in
                    NavigationLink {
                        ProjectCommunityPreviewView()
                    } label: {
                        projectUpdateCard(update)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open project community for \(update.title)")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var communitySignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Community Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.communitySignals) { signal in
                    HFMetricCard(title: signal.title, value: signal.value, systemImage: signal.systemImage)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var trendingPackagesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Trending Packages", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(Array(HFConnectPreviewData.trendingPackages.enumerated()), id: \.element) { index, package in
                        HStack(spacing: HFSpacing.md) {
                            Text("\(index + 1)")
                                .font(HFTypography.caption)
                                .foregroundStyle(.black)
                                .frame(width: 30, height: 30)
                                .background(HFColors.gold)
                                .clipShape(Circle())
                            Text(package)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
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

    private func creatorCard(_ creator: HFConnectCreator) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                ZStack {
                    Circle()
                        .fill(HFColors.gold.opacity(0.16))
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(creator.name)
                            .font(HFTypography.menu)
                            .foregroundStyle(HFColors.textPrimary)
                        Spacer(minLength: HFSpacing.xs)
                        HFStatusBadge(title: creator.role, isProminent: false)
                    }

                    Text(creator.bio)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(creator.followers) mock followers")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private func projectUpdateCard(_ update: HFConnectProjectUpdate) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: update.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(update.title)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                        Spacer(minLength: HFSpacing.xs)
                        HFStatusBadge(title: update.status, isProminent: false)
                    }
                    Text(update.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}
