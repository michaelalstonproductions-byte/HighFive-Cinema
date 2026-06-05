import SwiftUI

struct CreatorProfilePreviewView: View {
    let creator: HFConnectCreator
    @State private var isFollowing = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", creator.name])
                projectCommunityRoute
                creatorCirclesRoute
                graphRoutesSection
                featuredProjectsSection
                recentUpdatesSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle(creator.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.gold.opacity(0.16))
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                    }
                    .frame(width: 82, height: 82)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(creator.name)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        HFStatusBadge(title: creator.role, isProminent: false)
                        Text(creator.bio)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                    HFMetricCard(title: "Mock followers", value: creator.followers, systemImage: "person.2.fill")
                    HFMetricCard(title: "Featured projects", value: "\(creator.projects.count)", systemImage: "film.stack.fill")
                }

                Button {
                    isFollowing.toggle()
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: isFollowing ? "checkmark" : "plus")
                        Text(isFollowing ? "Following Preview" : "Follow Preview")
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFollowing ? "Following preview" : "Follow preview")

                Text("Follow state is local to this screen and does not create an account or real follow.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredProjectsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Projects", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(creator.projects, id: \.self) { project in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "film.stack.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 24)
                            Text(project)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer()
                            HFStatusBadge(title: "Preview", isProminent: false)
                        }
                        .padding(.vertical, HFSpacing.xxs)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var projectCommunityRoute: some View {
        NavigationLink {
            ProjectCommunityPreviewView()
        } label: {
            HFActionTile(
                title: "Open Project Community",
                subtitle: "Preview follows, update saves, audience signals, and discussion cards.",
                systemImage: "person.3.sequence.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Project Community Preview")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorCirclesRoute: some View {
        NavigationLink {
            CreatorCirclesPreviewView()
        } label: {
            HFActionTile(
                title: "Open Creator Circles",
                subtitle: "Preview creative circles, collaborator roles, and local connect state.",
                systemImage: "circle.hexagongrid.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Circles Preview")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var graphRoutesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Creator Discovery", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    SocialGraphPreviewView()
                } label: {
                    HFActionTile(
                        title: "View Creator Connections",
                        subtitle: "Preview how this creator relates to projects, rooms, reviewers, and collaborators.",
                        systemImage: "point.3.connected.trianglepath.dotted"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Social Graph Preview")

                NavigationLink {
                    FollowSuggestionsPreviewView()
                } label: {
                    HFActionTile(
                        title: "Find Related Creators",
                        subtitle: "Open local suggestions for creators, projects, and rooms connected to this profile.",
                        systemImage: "person.crop.circle.badge.plus"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Follow Suggestions Preview")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var recentUpdatesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Recent Updates", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(creator.updates, id: \.self) { update in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 24)
                            Text(update)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
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
                    ForEach(["real profiles", "followers", "comments", "messaging"], id: \.self) { item in
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
}
