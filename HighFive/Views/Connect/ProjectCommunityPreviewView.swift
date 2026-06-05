import SwiftUI

struct ProjectCommunityPreviewView: View {
    @State private var isFollowingProject = false
    @State private var savedUpdateIDs: Set<String> = []

    private let community = HFConnectPreviewData.projectCommunity
    private let comingNext = [
        "Real project communities",
        "Creator posts",
        "Fan discussions",
        "Studio signals",
        "Moderation"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                projectHeader
                HFBreadcrumbTrail(items: ["Connect", "Project Community"])
                communityFeedSection
                socialRoomsSection
                creatorCirclesSection
                communityActionsSection
                audienceSignalsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Project Community")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var projectHeader: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "film.stack.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 62, height: 62)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(community.projectTitle)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(community.subtitle)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                        HFStatusBadge(title: community.status, isProminent: false)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                    HFMetricCard(title: "Followers", value: community.followers, systemImage: "person.2.fill")
                    HFMetricCard(title: "Updates", value: community.updates, systemImage: "rectangle.stack.fill")
                }

                Button {
                    isFollowingProject.toggle()
                } label: {
                    Text(isFollowingProject ? "Following Project Preview" : "Follow Project")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFollowingProject ? "Following project preview" : "Follow project preview")

                Text("Project follows, saves, discussions, and shares are local mock state only.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var communityFeedSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Community Feed", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(community.feed, id: \.self) { update in
                    HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
                        HStack(alignment: .top, spacing: HFSpacing.md) {
                            Image(systemName: savedUpdateIDs.contains(update) ? "bookmark.fill" : "sparkles")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 38, height: 38)
                                .background(HFColors.gold.opacity(0.14))
                                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                                Text(update)
                                    .font(HFTypography.body)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text("Local project update preview")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                            }

                            Spacer()
                        }
                        .padding(HFSpacing.md)
                    }
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var socialRoomsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Social Rooms", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.socialRooms.prefix(3)) { room in
                    NavigationLink {
                        SocialRoomDetailPreviewView(room: room)
                    } label: {
                        HFActionTile(
                            title: room.name,
                            subtitle: "\(room.type) • \(room.members) members • \(room.status)",
                            systemImage: "bubble.left.and.bubble.right.fill"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open \(room.name) social room detail")
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var creatorCirclesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Creator Circles", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(HFConnectPreviewData.creatorCircles.prefix(3)) { circle in
                        HStack(spacing: HFSpacing.sm) {
                            Image(systemName: "circle.hexagongrid.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                                Text(circle.name)
                                    .font(HFTypography.body)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(circle.focus)
                                    .font(HFTypography.micro)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                            HFStatusBadge(title: "Circle", isProminent: false)
                        }
                        .padding(.vertical, HFSpacing.xxs)
                    }
                }
                .padding(HFSpacing.md)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            NavigationLink {
                CreatorCirclesPreviewView()
            } label: {
                HFActionTile(
                    title: "Open Creator Circles",
                    subtitle: "Preview collaborator circles and local connect actions.",
                    systemImage: "person.2.wave.2.fill"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Creator Circles Preview")
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var communityActionsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Community Actions", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                mockAction(title: isFollowingProject ? "Following" : "Follow Project", systemImage: "plus.circle.fill") {
                    isFollowingProject.toggle()
                }
                mockAction(title: "Save Update", systemImage: "bookmark.fill") {
                    if let first = community.feed.first {
                        toggleSave(first)
                    }
                }
                mockAction(title: "Preview Discussion", systemImage: "text.bubble.fill") {}
                mockAction(title: "Share Package", systemImage: "square.and.arrow.up.fill") {}
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var audienceSignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Audience Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(community.signals) { signal in
                    HFMetricCard(title: signal.title, value: signal.value, systemImage: signal.systemImage)
                }
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

    private func mockAction(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 36, height: 36)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                    Text(title)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Mock only")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.gold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) mock project community action")
    }

    private func toggleSave(_ update: String) {
        if savedUpdateIDs.contains(update) {
            savedUpdateIDs.remove(update)
        } else {
            savedUpdateIDs.insert(update)
        }
    }
}
