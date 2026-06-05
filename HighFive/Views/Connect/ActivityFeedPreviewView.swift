import SwiftUI

struct ActivityFeedPreviewView: View {
    @State private var selectedFilter = "All"
    @State private var likedItemIDs: Set<UUID> = []
    @State private var savedItemIDs: Set<UUID> = []

    private let filters = [
        "All",
        "Creators",
        "Projects",
        "Following",
        "Marketplace",
        "Reviews"
    ]

    private let comingNext = [
        "real comments",
        "accounts",
        "notifications"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Activity Feed"])
                filterSection
                projectCommunityRoute
                socialRoomRoute
                connectSignalsRoutes
                activityFeedSection
                projectUpdatesSection
                commentsPreviewSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Activity Feed")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Activity Feed")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("See mock project updates, reactions, and community momentum.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Reactions and comments are static local cards.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Feed Filters", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(filters, id: \.self) { filter in
                        HFFilterChip(title: filter, isSelected: selectedFilter == filter) {
                            selectedFilter = filter
                        }
                        .accessibilityLabel("Select \(filter) local feed filter")
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var projectCommunityRoute: some View {
        NavigationLink {
            ProjectCommunityPreviewView()
        } label: {
            HFActionTile(
                title: "Open Project Community",
                subtitle: "Review The Friendly updates, mock discussion, and local audience signals.",
                systemImage: "person.3.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Project Community Preview")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var socialRoomRoute: some View {
        NavigationLink {
            SocialRoomDetailPreviewView()
        } label: {
            HFActionTile(
                title: "Open Social Room Detail",
                subtitle: "Preview The Friendly Watch Room discussion and room signals.",
                systemImage: "star.bubble.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Social Room Detail Preview")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var connectSignalsRoutes: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Connect Signals", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    ConnectNotificationsPreviewView()
                } label: {
                    HFActionTile(
                        title: "View Connect Notifications",
                        subtitle: "Open grouped mock signals for streaming, creator workflow, and Connect.",
                        systemImage: "bell.badge.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Connect Notifications Preview")

                NavigationLink {
                    SocialGraphPreviewView()
                } label: {
                    HFActionTile(
                        title: "Open Social Graph",
                        subtitle: "Preview relationship mapping for creators, projects, rooms, and audiences.",
                        systemImage: "point.3.connected.trianglepath.dotted"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Social Graph Preview")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var activityFeedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Activity Feed", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.feedItems) { item in
                    activityCard(item)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var projectUpdatesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Project Update Cards", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.projectUpdates) { update in
                    HFActionTile(title: update.title, subtitle: update.detail, systemImage: update.systemImage, trailingSystemImage: "circle.fill")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var commentsPreviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Mock Comments Preview", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    commentLine(author: "Creative Lead", text: "Poster direction feels locked for preview.")
                    commentLine(author: "Editor", text: "Trailer opening needs one more pacing pass.")
                    commentLine(author: "Studio Review", text: "Submission notes are ready for a final pass.")
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

    private func activityCard(_ item: HFConnectActivityItem) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: item.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(item.title)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(item.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(item.actor)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    HFStatusBadge(title: "\(item.reactions) mock reactions", isProminent: false)
                    HFStatusBadge(title: "\(item.comments) comment previews", isProminent: false)
                    Spacer()
                }

                Divider()
                    .overlay(HFColors.glassStroke)

                HStack(spacing: HFSpacing.sm) {
                    mockFeedAction(
                        title: likedItemIDs.contains(item.id) ? "Liked" : "Like",
                        systemImage: likedItemIDs.contains(item.id) ? "hand.thumbsup.fill" : "hand.thumbsup"
                    ) {
                        toggleLiked(item.id)
                    }

                    mockFeedAction(title: "Comment", systemImage: "text.bubble.fill") {}

                    mockFeedAction(
                        title: savedItemIDs.contains(item.id) ? "Saved" : "Save",
                        systemImage: savedItemIDs.contains(item.id) ? "bookmark.fill" : "bookmark"
                    ) {
                        toggleSaved(item.id)
                    }

                    mockFeedAction(title: "Share", systemImage: "square.and.arrow.up") {}
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private func mockFeedAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: HFSpacing.xxs) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                Text(title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HFSpacing.xs)
            .background(HFColors.gold.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) mock activity action")
    }

    private func toggleLiked(_ id: UUID) {
        if likedItemIDs.contains(id) {
            likedItemIDs.remove(id)
        } else {
            likedItemIDs.insert(id)
        }
    }

    private func toggleSaved(_ id: UUID) {
        if savedItemIDs.contains(id) {
            savedItemIDs.remove(id)
        } else {
            savedItemIDs.insert(id)
        }
    }

    private func commentLine(author: String, text: String) -> some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(author)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(text)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}
