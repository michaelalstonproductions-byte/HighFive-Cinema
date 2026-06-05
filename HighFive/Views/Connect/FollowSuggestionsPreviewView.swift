import SwiftUI

struct FollowSuggestionsPreviewView: View {
    @State private var followedSuggestionIDs: Set<UUID> = []

    private let comingNext = [
        "Real recommendation engine",
        "Real follow graph",
        "Verified creator profiles",
        "Creator-to-creator discovery"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Follow Suggestions"])
                suggestedCreatorsSection
                suggestedProjectsSection
                suggestedRoomsSection
                mockFollowStateSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Follow Suggestions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Follow Suggestions")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.74)

            Text("Preview creators, projects, and communities you may want to follow.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Follow state is local to this screen and does not create an account.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var suggestedCreatorsSection: some View {
        suggestionSection(title: "Suggested Creators", suggestions: HFConnectPreviewData.followSuggestions)
    }

    private var suggestedProjectsSection: some View {
        suggestionSection(title: "Suggested Projects", suggestions: HFConnectPreviewData.suggestedProjects)
    }

    private var suggestedRoomsSection: some View {
        suggestionSection(title: "Suggested Rooms", suggestions: HFConnectPreviewData.suggestedRooms)
    }

    private var mockFollowStateSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Mock Follow State", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(spacing: HFSpacing.md) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 42, height: 42)
                            .background(HFColors.gold.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("\(followedSuggestionIDs.count) local follows selected")
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Selections reset when this preview screen is dismissed.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
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

    private func suggestionSection(title: String, suggestions: [HFConnectFollowSuggestion]) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(suggestions) { suggestion in
                    suggestionCard(suggestion)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func suggestionCard(_ suggestion: HFConnectFollowSuggestion) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: suggestion.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 42, height: 42)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(suggestion.title)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: suggestion.type, isProminent: false)
                        }

                        Text(suggestion.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)

                        Text(suggestion.reason)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("\(suggestion.followers) mock followers")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                }

                Button {
                    toggleFollow(suggestion.id)
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: followedSuggestionIDs.contains(suggestion.id) ? "checkmark" : "plus")
                        Text(followedSuggestionIDs.contains(suggestion.id) ? "Following Preview" : "Follow Preview")
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(followedSuggestionIDs.contains(suggestion.id) ? "Following \(suggestion.title) preview" : "Follow \(suggestion.title) preview")
            }
            .padding(HFSpacing.md)
        }
    }

    private func toggleFollow(_ id: UUID) {
        if followedSuggestionIDs.contains(id) {
            followedSuggestionIDs.remove(id)
        } else {
            followedSuggestionIDs.insert(id)
        }
    }
}
