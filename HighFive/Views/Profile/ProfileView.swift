import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile
    var onOpenMyList: (() -> Void)?
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var showsProfileSwitcher = false
    @State private var showsSignOutAlert = false
    @State private var mockMessage: ProfileMockMessage?

    private var savedMovies: [Movie] {
        streamingStore.allCatalogMovies.filter { streamingStore.isSaved($0) }
    }

    private var downloadedMovies: [Movie] {
        streamingStore.allCatalogMovies.filter { streamingStore.isDownloaded($0) || $0.isDownloaded }
    }

    private var continueWatchingMovies: [Movie] {
        streamingStore.allCatalogMovies.filter { $0.progress != nil }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                activeProfileCard
                profileSwitcherRail
                viewingStats
                highfiveHub
                preferencesPanel
                menu
                signOutButton
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
        }
        .accessibilityIdentifier("hf.profile.root")
        .accessibilityIdentifier("hf.profile.screen")
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsProfileSwitcher) {
            ProfileSwitcherView(selectedProfile: $selectedProfile, showsHeader: true)
                .padding(HFSpacing.lg)
                .background(HFColors.screenBackground.ignoresSafeArea())
        }
        .alert("Sign Out?", isPresented: $showsSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("This signs out of this device session.")
        }
        .alert(item: $mockMessage) { message in
            Alert(
                title: Text(message.title),
                message: Text(message.body),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Profile")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)

                Text("Manage your viewing profile.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()

            Button {
                showsProfileSwitcher = true
            } label: {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 46, height: 46)
                    .background(HFColors.goldGradient)
                    .clipShape(Circle())
                    .shadow(color: HFColors.amberGlow.opacity(0.35), radius: 18, x: 0, y: 10)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Switch profile")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var activeProfileCard: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .center, spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.goldGradient)
                        Image(systemName: selectedProfile.avatarSystemName)
                            .font(.system(size: 40, weight: .black))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(selectedProfile.name)
                            .font(.system(size: 30, weight: .black, design: .default))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)

                        Text(selectedProfile.isKidsProfile ? "Kids profile" : "Premium viewer")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)

                        HStack(spacing: HFSpacing.xs) {
                            HFProfileBadge(title: selectedProfile.accentName, systemImage: "sparkles")
                            HFProfileBadge(title: streamingStore.accountMode, systemImage: "checkmark.seal.fill")
                        }
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: HFSpacing.sm) {
                    HFButton("Switch", systemImage: "person.2.fill", style: .primary) {
                        showsProfileSwitcher = true
                    }

                    HFButton("My List", systemImage: "bookmark.fill", style: .secondary) {
                        onOpenMyList?()
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var profileSwitcherRail: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Who's Watching", actionTitle: "Switch") {
                showsProfileSwitcher = true
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    ForEach(HFMockData.userProfiles) { profile in
                        profileAvatarButton(profile)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private func profileAvatarButton(_ profile: UserProfile) -> some View {
        Button {
            selectedProfile = profile
        } label: {
            VStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(selectedProfile.id == profile.id ? HFColors.goldGradient : LinearGradient(colors: [HFColors.surfaceElevated, HFColors.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: profile.avatarSystemName)
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(selectedProfile.id == profile.id ? .black : HFColors.textPrimary)
                }
                .frame(width: 74, height: 74)
                .overlay(
                    Circle()
                        .stroke(selectedProfile.id == profile.id ? HFColors.gold : HFColors.glassStroke, lineWidth: 2)
                )

                Text(profile.name)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .frame(width: 82)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Use \(profile.name) profile")
    }

    private var viewingStats: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Viewing Snapshot", actionTitle: nil)

            HStack(spacing: HFSpacing.sm) {
                HFProfileStatCard(title: "Saved", value: "\(savedMovies.count)", systemImage: "bookmark.fill")
                HFProfileStatCard(title: "Offline", value: "\(downloadedMovies.count)", systemImage: "arrow.down.circle.fill")
                HFProfileStatCard(title: "Watching", value: "\(continueWatchingMovies.count)", systemImage: "play.circle.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            if let movie = continueWatchingMovies.first {
                NavigationLink(value: movie) {
                    HFProfileContinueCard(movie: movie)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private var highfiveHub: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "HighFive Hub", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Creator Studio")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Build local drafts, prepare the Social Kit, and package VOD for private review without provider connections.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: HFSpacing.sm) {
                        NavigationLink {
                            CreatorStudioView()
                        } label: {
                            HFProfileHubRouteRow(title: "Creator Studio", subtitle: "Local Draft", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            CreatorStudioView(initialFocus: .socialMediaKit)
                        } label: {
                            HFProfileHubRouteRow(title: "Social Media Kit", subtitle: "Provider-ready", systemImage: "bubble.left.and.bubble.right.fill")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            CreatorStudioView(initialFocus: .vodPackage)
                        } label: {
                            HFProfileHubRouteRow(title: "VOD Package", subtitle: "Not Connected Yet", systemImage: "shippingbox.fill")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.profile.highfiveHub")
    }

    private var preferencesPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.glassStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(spacing: HFSpacing.md) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 46, height: 46)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Viewing Preferences")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Dark cinematic playback, smart recommendations, and profile-specific saves.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.sm) {
                    HFPreferenceRow(title: "Autoplay previews", detail: "On", systemImage: "play.rectangle.fill")
                    HFPreferenceRow(title: "Offline quality", detail: "High", systemImage: "arrow.down.circle.fill")
                    HFPreferenceRow(title: "Kids mode", detail: selectedProfile.isKidsProfile ? "On" : "Off", systemImage: "star.circle.fill")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var menu: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Profile & More", actionTitle: nil)

            VStack(spacing: HFSpacing.sm) {
                HFProfileMenuButton(title: "My List", subtitle: "\(savedMovies.count) saved titles", systemImage: "bookmark.fill") {
                    onOpenMyList?()
                }
                HFProfileMenuButton(title: "Downloads", subtitle: "\(downloadedMovies.count) available offline", systemImage: "arrow.down.circle.fill") {
                    mockMessage = ProfileMockMessage(
                        title: "Downloads",
                        body: "Use the Downloads tab to manage your offline titles."
                    )
                }
                HFProfileMenuButton(title: "Manage Profiles", subtitle: "Switch profiles or add a new viewer", systemImage: "person.2.fill") {
                    showsProfileSwitcher = true
                }
                HFProfileMenuButton(title: "Help", subtitle: "Streaming preview support", systemImage: "questionmark.circle.fill") {
                    mockMessage = ProfileMockMessage(
                        title: "Help",
                        body: "Help is ready for streaming support, profile questions, and download guidance."
                    )
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var signOutButton: some View {
        Button {
            showsSignOutAlert = true
        } label: {
            Text("Sign Out")
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(HFColors.surfaceElevated.opacity(0.72))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(HFColors.glassStroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct HFProfileBadge: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 9, weight: .black))
            Text(title)
                .font(HFTypography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(HFColors.gold)
        .padding(.horizontal, HFSpacing.xs)
        .frame(height: 24)
        .background(HFColors.gold.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct HFProfileStatCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(HFColors.gold)

            Text(value)
                .font(.system(size: 26, weight: .black, design: .default))
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.md)
        .background(HFColors.surfaceElevated.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
    }
}

private struct HFProfileContinueCard: View {
    let movie: Movie

    var body: some View {
        HStack(spacing: HFSpacing.md) {
            HFPosterCard(movie: movie, width: 92, showTitle: false, showMetadata: false, showProgress: true)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text("Continue Watching")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                    .textCase(.uppercase)

                Text(movie.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)

                Text(movie.metadataLine)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(1)

                if let progress = movie.progress {
                    ProgressView(value: progress)
                        .tint(HFColors.gold)
                        .accessibilityLabel("Playback progress")
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(HFColors.textMuted)
        }
        .padding(HFSpacing.md)
        .background(HFColors.surface.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.panelRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.18), lineWidth: 1)
        )
    }
}

private struct HFPreferenceRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            Text(title)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)

            Spacer()

            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 26)
                .background(HFColors.surface.opacity(0.72))
                .clipShape(Capsule())
        }
    }
}

private struct HFProfileMenuButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(HFColors.textMuted)
            }
            .padding(HFSpacing.md)
            .background(HFColors.surfaceElevated.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                    .stroke(HFColors.glassStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct HFProfileHubRouteRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 42, height: 42)
                .background(HFColors.gold.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                Text(subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(HFColors.textMuted)
        }
        .padding(HFSpacing.md)
        .background(HFColors.surfaceElevated.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
    }
}

private struct ProfileMockMessage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}
