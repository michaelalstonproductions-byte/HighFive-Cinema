import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile
    var onOpenMyList: (() -> Void)?
    @State private var showsProfileSwitcher = false
    @State private var showsSignOutAlert = false
    @State private var showsNotifications = false
    @State private var activeMockSheet: ProfileMockSheet?
    @StateObject private var notificationStore = HFNotificationCenterStore()

    private let menuItems: [(title: String, systemImage: String)] = [
        ("Notifications", "bell.fill"),
        ("My List", "bookmark.fill"),
        ("App Settings", "gearshape.fill"),
        ("Account", "person.crop.circle.fill"),
        ("Help", "questionmark.circle.fill")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                selectedProfilePanel
                avatarRow
                manageProfilesButton

                menu
                highFiveRoomsSection
                buildQAToolsSection
                signOutButton
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .sheet(isPresented: $showsProfileSwitcher) {
            ProfileSwitcherView(selectedProfile: $selectedProfile, showsHeader: true)
                .padding(HFSpacing.lg)
                .background(HFColors.screenBackground.ignoresSafeArea())
        }
        .sheet(item: $activeMockSheet) { sheet in
            ProfileMockSheetView(sheet: sheet)
        }
        .sheet(isPresented: $showsNotifications) {
            HFNotificationSheet(store: notificationStore)
        }
        .alert("Sign Out?", isPresented: $showsSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {}
        } message: {
            Text("This is a preview confirmation. No account state will change.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Profiles & More")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Switch profiles, manage your list, adjust settings, and get help.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var profileShortcutsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "HighFive Preview", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                creatorModeCard
                ecosystemCommandShortcut
                connectPreviewShortcut
                NavigationLink {
                    CreatorAccessPreviewView()
                } label: {
                    HFActionTile(
                        title: "Access Preview",
                        subtitle: "Review future audience access locally.",
                        systemImage: "lock.shield.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Access Preview")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var selectedProfilePanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(spacing: HFSpacing.md) {
                HFProfileAvatarCard(profile: selectedProfile, isSelected: true, compact: true)
                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text("Watching as")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                    Text(selectedProfile.name)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(selectedProfile.isKidsProfile ? "Kids profile" : "Standard profile")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
                Spacer()
            }
            .padding(HFSpacing.lg)
            .background(
                LinearGradient(
                    colors: [HFColors.warmGlow.opacity(0.24), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorModeCard: some View {
        NavigationLink {
            CreatorEntryView()
        } label: {
            HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
                HStack(spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HFColors.gold.opacity(0.16))
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text("Creator Mode")
                            .font(HFTypography.menu)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Build creator packages with studio, dashboard, and workflow previews")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
                .padding(HFSpacing.md)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Mode")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var ecosystemCommandShortcut: some View {
        NavigationLink {
            EcosystemCommandCenterView()
        } label: {
            HFActionTile(
                title: "HighFive Command Center",
                subtitle: "Open the connected map for Watch, Create, Connect, Launch, and future Export.",
                systemImage: "command"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open HighFive Command Center")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorWorkflowShortcut: some View {
        NavigationLink {
            CreatorWorkflowCommandCenterView()
        } label: {
            HFActionTile(
                title: "Creator Command Center",
                subtitle: "Build package, review, readiness, and release signals.",
                systemImage: "command"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Command Center")
    }

    private var creatorLaunchShortcut: some View {
        NavigationLink {
            CreatorLaunchCenterPreviewView()
        } label: {
            HFActionTile(
                title: "Creator Launch Center",
                subtitle: "Prepare launch plan, audience interest, and mock access setup.",
                systemImage: "flag.checkered"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Creator Launch Center")
    }

    private var connectPreviewShortcut: some View {
        NavigationLink {
            ConnectHubView()
        } label: {
            HFActionTile(
                title: "Connect Preview",
                subtitle: "Follow creator communities, project updates, and mock signals.",
                systemImage: "person.2.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Connect Preview")
    }

    private var personalizedHubShortcut: some View {
        NavigationLink {
            PersonalizedHubView()
        } label: {
            HFActionTile(
                title: "For You",
                subtitle: "Local paths across Watch, Create, Connect, Launch, and Access.",
                systemImage: "sparkles"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Personalized Hub")
    }

    private var productRoutesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Product Paths", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                creatorWorkflowShortcut
                connectPreviewShortcut
                creatorLaunchShortcut
                personalizedHubShortcut
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var previewReleaseSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Launch & Release Preview", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    AppReleasePresentationView()
                } label: {
                    HFActionTile(
                        title: "Release Presentation",
                        subtitle: "Review the Watch, Create, Connect, and Launch story.",
                        systemImage: "sparkles"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open HighFive Preview")

                NavigationLink {
                    AppOnboardingPreviewView()
                } label: {
                    HFActionTile(
                        title: "Onboarding Preview",
                        subtitle: "Preview the first-run story without changing app launch behavior.",
                        systemImage: "rectangle.stack.badge.play.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Onboarding Preview")

                NavigationLink {
                    CreatorAccessPreviewView()
                } label: {
                    HFActionTile(
                        title: "Access Preview",
                        subtitle: "Review future audience access without enabling live services.",
                        systemImage: "lock.shield.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Access Preview")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var buildQAToolsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Developer / QA", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    DeveloperQAHubView()
                } label: {
                    HFActionTile(
                        title: "Developer / QA Hub",
                        subtitle: "Internal validation, visual parity, route quality, and release readiness.",
                        systemImage: "wrench.and.screwdriver.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open Developer QA Hub")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var highFiveRoomsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HFSectionHeader(title: "HighFive Rooms", actionTitle: nil)
                Text("Watch, create, connect, launch, and prepare your content ecosystem.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    WatchRoomView()
                } label: {
                    HFProductRoomEntryCard(
                        title: "Watch",
                        subtitle: "Streaming home, saved titles, downloads, and discovery.",
                        status: "Live Preview",
                        systemImage: "play.rectangle.fill",
                        accent: HFColors.gold
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Watch Room, streaming home and saved titles")

                NavigationLink {
                    CreateRoomView()
                } label: {
                    HFProductRoomEntryCard(
                        title: "Create",
                        subtitle: "Projects, pitches, creator profiles, and studio materials.",
                        status: "Studio Preview",
                        systemImage: "wand.and.stars",
                        accent: Color.orange
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Create Room, creator studio preview")

                NavigationLink {
                    ConnectRoomView()
                } label: {
                    HFProductRoomEntryCard(
                        title: "Connect",
                        subtitle: "Audience communities, reactions, and creator engagement.",
                        status: "Community Preview",
                        systemImage: "person.2.fill",
                        accent: Color.cyan
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Connect Room, community preview")

                NavigationLink {
                    LaunchRoomView()
                } label: {
                    HFProductRoomEntryCard(
                        title: "Launch",
                        subtitle: "Prepare premieres, campaigns, timelines, and release pages.",
                        status: "Launch Preview",
                        systemImage: "flag.checkered",
                        accent: Color.green
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Launch Room, premiere and campaign preview")

                NavigationLink {
                    ExportRoomView()
                } label: {
                    HFProductRoomEntryCard(
                        title: "Export",
                        subtitle: "Deliverables, media kits, and distribution packages.",
                        status: "Readiness Preview",
                        systemImage: "shippingbox.fill",
                        accent: Color.purple
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Export Room, deliverables and distribution readiness preview")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HighFive Rooms section")
    }

    private var avatarRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.md) {
                ForEach(HFMockData.userProfiles) { profile in
                    Button {
                        selectedProfile = profile
                    } label: {
                        HFProfileAvatarCard(profile: profile, isSelected: selectedProfile.id == profile.id)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var manageProfilesButton: some View {
        Button {
            showsProfileSwitcher = true
        } label: {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: "person.2.fill")
                Text("Manage Profiles")
            }
            .font(HFTypography.smallAction)
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(HFColors.goldGradient)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Manage Profiles")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var menu: some View {
        VStack(spacing: HFSpacing.sm) {
            ForEach(menuItems, id: \.title) { item in
                HFMenuRow(
                    title: item.title,
                    systemImage: item.systemImage,
                    badgeCount: item.title == "Notifications" ? notificationStore.unreadCount : 0
                ) {
                    handleMenuItem(item.title)
                }
                .accessibilityLabel(item.title == "Notifications" ? "Notifications, \(notificationStore.unreadCount) unread" : item.title)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func handleMenuItem(_ title: String) {
        switch title {
        case "My List":
            onOpenMyList?()
        case "Notifications":
            showsNotifications = true
        case "App Settings":
            activeMockSheet = ProfileMockSheet(
                title: "App Settings",
                message: "Streaming display, download, and playback preferences will live here later.",
                systemImage: "gearshape.fill"
            )
        case "Account":
            activeMockSheet = ProfileMockSheet(
                title: "Account",
                message: "Account preferences are in preview. No sign-in or billing is connected.",
                systemImage: "person.crop.circle.fill"
            )
        case "Help":
            activeMockSheet = ProfileMockSheet(
                title: "Help",
                message: "Help content is in preview. No live support service is connected.",
                systemImage: "questionmark.circle.fill"
            )
        default:
            break
        }
    }

    private var signOutButton: some View {
        Button {
            showsSignOutAlert = true
        } label: {
            Text("Sign Out")
                .font(HFTypography.menu)
                .foregroundStyle(HFColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white.opacity(0.10))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(HFColors.glassStroke, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct ProfileMockSheet: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let systemImage: String
}

private struct ProfileMockSheetView: View {
    let sheet: ProfileMockSheet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            HFColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: HFSpacing.xl) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(HFColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                    VStack(spacing: HFSpacing.lg) {
                        ZStack {
                            Circle()
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: sheet.systemImage)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                        }
                        .frame(width: 78, height: 78)

                        VStack(spacing: HFSpacing.sm) {
                            Text(sheet.title)
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .multilineTextAlignment(.center)
                            Text(sheet.message)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(HFSpacing.xl)
                }

                Spacer()
            }
            .padding(HFSpacing.lg)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private struct HFProductRoomEntryCard: View {
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.34)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 46, height: 46)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.menu)
                            .foregroundStyle(HFColors.textPrimary)
                        HFRoomStatusChip(title: status, accent: accent)
                    }

                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(accent)
                    .padding(.top, 4)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) Room, \(subtitle)")
    }
}

private struct WatchRoomView: View {
    @State private var searchMode: HFSearchHubMode = .discover

    private var featuredMovie: Movie {
        HFMockData.movie("the-friendly") ?? HFMockData.movies[0]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFProductRoomHero(
                    eyebrow: "WATCH",
                    title: "Watch Room",
                    subtitle: "The consumer streaming layer of HighFive Cinema.",
                    purpose: "This room connects the viewer to content.",
                    heroCopy: "Your streaming home for featured titles, saved films, downloads, and discovery.",
                    status: "Live Preview",
                    systemImage: "play.rectangle.fill",
                    accent: HFColors.gold
                )

                VStack(spacing: HFSpacing.md) {
                    NavigationLink {
                        MovieDetailView(movie: featuredMovie)
                    } label: {
                        HFRoomFeatureCard(title: "Continue Watching", subtitle: "Resume titles already in progress with the Watch Now path.", status: "Live Preview", systemImage: "play.fill", accent: HFColors.gold)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        MyListView()
                    } label: {
                        HFRoomFeatureCard(title: "My List", subtitle: "Saved titles ready for your next watch.", status: "Local Preview", systemImage: "bookmark.fill", accent: HFColors.gold)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SearchView(mode: $searchMode)
                    } label: {
                        HFRoomFeatureCard(title: "Discover", subtitle: "Browse movies, originals, and upcoming premieres.", status: "Preview", systemImage: "magnifyingglass", accent: HFColors.gold)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        DownloadsView()
                    } label: {
                        HFRoomFeatureCard(title: "Downloads", subtitle: "Offline-ready titles in one place.", status: "Local Preview", systemImage: "arrow.down.circle.fill", accent: HFColors.gold)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        MovieDetailView(movie: featuredMovie)
                    } label: {
                        HFRoomFeatureCard(title: "Featured Titles", subtitle: "HighFive picks and editorial rails.", status: "Preview", systemImage: "star.fill", accent: HFColors.gold)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Watch Room")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum StudioSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case projects = "Projects"
    case profile = "Creator Profile"
    case pitch = "Pitch"
    case mediaKit = "Media Kit"
    case launchPrep = "Launch Prep"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .overview: "rectangle.3.group.fill"
        case .projects: "film.stack.fill"
        case .profile: "person.crop.square.fill"
        case .pitch: "text.quote"
        case .mediaKit: "photo.stack.fill"
        case .launchPrep: "flag.checkered"
        }
    }

    var accessibilityName: String {
        switch self {
        case .overview: "Overview section"
        case .projects: "Projects section, local preview of creator projects"
        case .profile: "Creator Profile section"
        case .pitch: "Pitch section"
        case .mediaKit: "Media Kit section, preview of poster trailer stills and synopsis readiness"
        case .launchPrep: "Launch Prep section"
        }
    }
}

private struct StudioProject: Identifiable {
    let id = UUID()
    let title: String
    let format: String
    let stage: String
    let readiness: Int
    let needs: [String]
    let status: String
}

private struct StudioChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
    let systemImage: String
}

private struct StudioPitchItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

private enum StudioData {
    static let overviewItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Active Projects", status: "Preview", detail: "Organize films, episodes, shorts, and campaigns.", systemImage: "film.stack.fill"),
        StudioChecklistItem(title: "Creator Identity", status: "Preview", detail: "Shape the public profile behind the work.", systemImage: "person.crop.square.fill"),
        StudioChecklistItem(title: "Pitch Package", status: "Local Preview", detail: "Prepare story, audience, format, and positioning.", systemImage: "text.quote"),
        StudioChecklistItem(title: "Media Kit", status: "Preview", detail: "Collect key art, stills, synopsis, and creator notes.", systemImage: "photo.stack.fill"),
        StudioChecklistItem(title: "Launch Readiness", status: "Coming Soon", detail: "Track what the title needs before premiere.", systemImage: "flag.checkered"),
        StudioChecklistItem(title: "Export Prep", status: "Protected", detail: "Prepare deliverables before real delivery systems are connected.", systemImage: "shippingbox.fill")
    ]

    static let projects: [StudioProject] = [
        StudioProject(
            title: "The Friendly",
            format: "Feature Film",
            stage: "Packaging",
            readiness: 72,
            needs: ["Pitch polish", "Trailer notes", "Launch copy"],
            status: "Studio Preview"
        ),
        StudioProject(
            title: "Neon Canyon",
            format: "Limited Series",
            stage: "Development",
            readiness: 48,
            needs: ["Creator profile", "Key art", "Audience notes"],
            status: "Local Preview"
        ),
        StudioProject(
            title: "Midnight Orchard",
            format: "Short Film",
            stage: "Festival Prep",
            readiness: 81,
            needs: ["Poster package", "Festival synopsis", "Credits review"],
            status: "Readiness"
        )
    ]

    static let profileItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Profile name", status: "Ready", detail: "HighFive Studio", systemImage: "checkmark.seal.fill"),
        StudioChecklistItem(title: "Short bio", status: "Ready", detail: "A cinematic team preparing premium stories for streaming, community, and launch.", systemImage: "text.alignleft"),
        StudioChecklistItem(title: "Creator image placeholder", status: "Needs Review", detail: "Use a visual placeholder until approved creator artwork is available.", systemImage: "person.crop.square"),
        StudioChecklistItem(title: "Featured project", status: "Ready", detail: "The Friendly anchors the current studio package.", systemImage: "star.fill"),
        StudioChecklistItem(title: "Social links", status: "Deferred", detail: "Relationship links stay disconnected in this phase.", systemImage: "link"),
        StudioChecklistItem(title: "Verification", status: "Deferred", detail: "Verification is a future account system.", systemImage: "checkmark.shield")
    ]

    static let pitchItems: [StudioPitchItem] = [
        StudioPitchItem(title: "Logline", detail: "A small-town team turns an impossible idea into a cinematic movement.", systemImage: "quote.opening"),
        StudioPitchItem(title: "Audience", detail: "Fans of premium indie stories, behind-the-scenes creator journeys, and character-driven drama.", systemImage: "person.3.fill"),
        StudioPitchItem(title: "Format", detail: "Feature, limited series, shorts, and creator-led packages can be framed for HighFive.", systemImage: "rectangle.stack.fill"),
        StudioPitchItem(title: "Tone", detail: "Cinematic, hopeful, grounded, and emotional.", systemImage: "sparkles"),
        StudioPitchItem(title: "Comparable space", detail: "Premium streaming originals, festival dramas, and creator-led documentaries.", systemImage: "rectangle.on.rectangle.angled.fill"),
        StudioPitchItem(title: "Why now", detail: "Creator-first storytelling is becoming the next premium viewing category.", systemImage: "clock.badge.checkmark.fill"),
        StudioPitchItem(title: "Release angle", detail: "Package the story for streaming, community, launch, and readiness moments.", systemImage: "megaphone.fill")
    ]

    static let mediaKitItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Poster", status: "Ready", detail: "Key art reference is present in the local content slate.", systemImage: "photo.fill"),
        StudioChecklistItem(title: "Backdrop", status: "Needs Review", detail: "Backdrop treatment should match the premium streaming UI.", systemImage: "photo.on.rectangle.angled"),
        StudioChecklistItem(title: "Trailer", status: "Deferred", detail: "Trailer notes can be prepared without playback integration.", systemImage: "film.fill"),
        StudioChecklistItem(title: "Stills", status: "Needs Review", detail: "Still selections remain display-only for this phase.", systemImage: "rectangle.stack.fill"),
        StudioChecklistItem(title: "Synopsis", status: "Ready", detail: "Short and long synopsis blocks can support detail and launch pages.", systemImage: "doc.text.fill"),
        StudioChecklistItem(title: "Credits", status: "Needs Review", detail: "Credit lines should be reviewed before public launch.", systemImage: "person.text.rectangle.fill"),
        StudioChecklistItem(title: "Creator Notes", status: "Preview", detail: "Creator context helps connect the story to the audience.", systemImage: "note.text"),
        StudioChecklistItem(title: "Press Blurb", status: "Deferred", detail: "Press copy stays a planning item until launch systems mature.", systemImage: "newspaper.fill")
    ]

    static let launchPrepItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Title package", status: "Preview", detail: "Title, synopsis, key art, and creator context are grouped for review.", systemImage: "shippingbox.fill"),
        StudioChecklistItem(title: "Creator profile", status: "Preview", detail: "Creator identity supports the release story.", systemImage: "person.crop.square.fill"),
        StudioChecklistItem(title: "Poster package", status: "Needs Review", detail: "Review key art before premiere positioning.", systemImage: "photo.stack.fill"),
        StudioChecklistItem(title: "Trailer notes", status: "Deferred", detail: "Trailer planning stays local and non-playback.", systemImage: "film.fill"),
        StudioChecklistItem(title: "Audience copy", status: "Preview", detail: "Write short, clear audience-facing copy.", systemImage: "text.bubble.fill"),
        StudioChecklistItem(title: "Launch timeline", status: "Coming Soon", detail: "Timeline planning bridges into the Launch Room.", systemImage: "calendar.badge.clock"),
        StudioChecklistItem(title: "Community preview", status: "Preview", detail: "Connect Room can frame audience energy around the title.", systemImage: "person.2.fill"),
        StudioChecklistItem(title: "Distribution notes", status: "Protected", detail: "Delivery planning stays separate from real distribution systems.", systemImage: "lock.shield.fill")
    ]

    static let safetyItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Uploads", status: "Deferred", detail: "Media intake is not connected in this phase.", systemImage: "arrow.up.doc"),
        StudioChecklistItem(title: "Accounts", status: "Deferred", detail: "Creator identity is display-only.", systemImage: "person.crop.circle.badge.exclamationmark"),
        StudioChecklistItem(title: "Payments", status: "Deferred", detail: "No commerce system is part of this room.", systemImage: "creditcard"),
        StudioChecklistItem(title: "Rendering", status: "Protected", detail: "Rendering systems remain outside this SwiftUI room.", systemImage: "viewfinder"),
        StudioChecklistItem(title: "Export Engine", status: "Protected", detail: "Professional delivery remains a protected future system.", systemImage: "shippingbox.fill"),
        StudioChecklistItem(title: "Backend", status: "Deferred", detail: "Studio data is static and local for this phase.", systemImage: "server.rack")
    ]
}

private struct CreateRoomView: View {
    @State private var selectedStudioSection: StudioSection = .overview

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFProductRoomHero(
                    eyebrow: "CREATE",
                    title: "Creator Studio",
                    subtitle: "Plan, package, and prepare stories for HighFive.",
                    purpose: "This room previews the creator-side studio.",
                    heroCopy: "A premium workspace for projects, creator identity, pitches, media kits, and launch readiness.",
                    status: "Studio Preview",
                    systemImage: "wand.and.stars",
                    accent: Color.orange
                )

                studioSectionSelector
                selectedSectionView
                studioSafetyBoundary
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Studio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var studioSectionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(StudioSection.allCases) { section in
                    Button {
                        selectedStudioSection = section
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: section.systemImage)
                                .font(.system(size: 12, weight: .bold))
                            Text(section.rawValue)
                        }
                        .font(HFTypography.micro)
                        .foregroundStyle(selectedStudioSection == section ? .black : HFColors.textSecondary)
                        .padding(.horizontal, HFSpacing.sm)
                        .padding(.vertical, 10)
                        .background(selectedStudioSection == section ? Color.orange : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedStudioSection == section ? Color.orange.opacity(0.78) : HFColors.glassStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(section.accessibilityName)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio section selector")
    }

    @ViewBuilder
    private var selectedSectionView: some View {
        switch selectedStudioSection {
        case .overview:
            overviewSection
        case .projects:
            projectsSection
        case .profile:
            creatorProfileSection
        case .pitch:
            pitchSection
        case .mediaKit:
            mediaKitSection
        case .launchPrep:
            launchPrepSection
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Studio Overview", subtitle: "The local command surface for preparing a HighFive title.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(StudioData.overviewItems) { item in
                    StudioChecklistCard(item: item, accent: Color.orange)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Studio overview cards")
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Project Slate", subtitle: "Premium local project cards, not a file manager.")

            VStack(spacing: HFSpacing.md) {
                ForEach(StudioData.projects) { project in
                    StudioProjectCard(project: project)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorProfileSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Creator Identity", subtitle: "Preview the public creator profile before account systems exist.")

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.orange.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "person.crop.square.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.orange)
                            .frame(width: 58, height: 58)
                            .background(Color.orange.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("HighFive Studio")
                                .font(HFTypography.title)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Independent Film Team")
                                .font(HFTypography.caption)
                                .foregroundStyle(Color.orange)
                            Text("A cinematic team preparing premium stories for streaming, community, and launch.")
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(spacing: HFSpacing.xs) {
                        ForEach(["Drama", "Documentary", "Sci-Fi", "Comedy"], id: \.self) { genre in
                            HFRoomStatusChip(title: genre, accent: Color.orange)
                        }
                    }

                    StudioProgressBar(title: "Profile completeness", value: 68, accent: Color.orange)
                }
                .padding(HFSpacing.lg)
            }

            VStack(spacing: HFSpacing.sm) {
                ForEach(StudioData.profileItems) { item in
                    StudioChecklistRow(item: item, accent: Color.orange)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Profile section, public identity preview")
    }

    private var pitchSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Pitch Package", subtitle: "Shape the story, audience, format, and release angle.")

            VStack(spacing: HFSpacing.sm) {
                ForEach(StudioData.pitchItems) { item in
                    StudioPitchCard(item: item)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pitch section, story packaging preview")
    }

    private var mediaKitSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Media Kit", subtitle: "Organize release materials without touching real asset systems.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(StudioData.mediaKitItems) { item in
                    StudioChecklistCard(item: item, accent: Color.orange)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Media Kit section, preview of poster trailer stills and synopsis readiness")
    }

    private var launchPrepSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Launch Prep", subtitle: "Bridge Create into Launch with planning-only readiness.")

            VStack(spacing: HFSpacing.sm) {
                ForEach(StudioData.launchPrepItems) { item in
                    StudioChecklistRow(item: item, accent: Color.orange)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Prep section, release readiness preview")
    }

    private var studioSafetyBoundary: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Studio Safety Boundary")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Creator Studio is a local product preview. Uploads, Accounts, Payments, Rendering, and delivery systems remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(StudioData.safetyItems) { item in
                        StudioSafetyChip(item: item)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Studio Safety Boundary, protected systems remain disconnected")
    }
}

private struct StudioRoomSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text(title)
                .font(HFTypography.section)
                .foregroundStyle(HFColors.textPrimary)
            Text(subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct StudioChecklistCard: View {
    let item: StudioChecklistItem
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(item.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                    HFRoomStatusChip(title: item.status, accent: accent)
                    Text(item.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.status), \(item.detail)")
    }
}

private struct StudioProjectCard: View {
    let project: StudioProject

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.orange.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: project.status, accent: Color.orange)
                        Text(project.title)
                            .font(HFTypography.title)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("\(project.format) · \(project.stage)")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }

                    Spacer()

                    StudioReadinessRing(value: project.readiness)
                }

                StudioProgressBar(title: "Readiness", value: project.readiness, accent: Color.orange)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(project.needs, id: \.self) { need in
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.orange)
                                .padding(.top, 2)
                            Text(need)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    StudioPassiveCTA(title: "View Package")
                    StudioPassiveCTA(title: "Review Checklist")
                    StudioPassiveCTA(title: "Prepare Pitch")
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.title), \(project.format), \(project.stage), \(project.readiness) percent ready")
    }
}

private struct StudioReadinessRing: View {
    let value: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 5)
            Circle()
                .trim(from: 0, to: CGFloat(value) / 100)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(value)%")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textPrimary)
        }
        .frame(width: 54, height: 54)
    }
}

private struct StudioProgressBar: View {
    let title: String
    let value: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack {
                Text(title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textMuted)
                Spacer()
                Text("\(value)%")
                    .font(HFTypography.caption)
                    .foregroundStyle(accent)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                    Capsule()
                        .fill(accent)
                        .frame(width: max(8, proxy.size.width * CGFloat(value) / 100))
                }
            }
            .frame(height: 8)
        }
    }
}

private struct StudioChecklistRow: View {
    let item: StudioChecklistItem
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.24)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 38, height: 38)
                    .background(accent.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(item.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                        HFRoomStatusChip(title: item.status, accent: accent)
                    }

                    Text(item.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.status), \(item.detail)")
    }
}

private struct StudioPitchCard: View {
    let item: StudioPitchItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: Color.orange.opacity(0.28)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.orange)
                    .frame(width: 42, height: 42)
                    .background(Color.orange.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(item.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(item.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.detail)")
    }
}

private struct StudioPassiveCTA: View {
    let title: String

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(Color.orange)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.xs)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.orange.opacity(0.34), lineWidth: 1))
    }
}

private struct StudioSafetyChip: View {
    let item: StudioChecklistItem

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HFRoomStatusChip(title: item.status, accent: HFColors.gold)
            Text(item.title)
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.textPrimary)
            Text(item.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.status), \(item.detail)")
    }
}

private struct ConnectRoomView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFProductRoomHero(
                    eyebrow: "CONNECT",
                    title: "Connect Room",
                    subtitle: "Build audience relationships around stories and creators.",
                    purpose: "This room previews community and fan engagement.",
                    heroCopy: "A place for creator communities, reactions, following, and audience energy.",
                    status: "Community Preview",
                    systemImage: "person.2.fill",
                    accent: Color.cyan
                )

                VStack(spacing: HFSpacing.md) {
                    NavigationLink {
                        ConnectHubView()
                    } label: {
                        HFRoomFeatureCard(title: "Communities", subtitle: "Group audiences around titles, creators, and premieres.", status: "Preview", systemImage: "person.3.fill", accent: Color.cyan)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ActivityFeedPreviewView()
                    } label: {
                        HFRoomFeatureCard(title: "Reactions", subtitle: "Preview fan response and engagement signals.", status: "Local Preview", systemImage: "heart.text.square.fill", accent: Color.cyan)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        FollowSuggestionsPreviewView()
                    } label: {
                        HFRoomFeatureCard(title: "Following", subtitle: "Help audiences keep up with creators and releases.", status: "Preview", systemImage: "person.badge.plus.fill", accent: Color.cyan)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SocialRoomsPreviewView()
                    } label: {
                        HFRoomFeatureCard(title: "Creator Updates", subtitle: "Share progress, release notes, and behind-the-scenes moments.", status: "Local Preview", systemImage: "text.bubble.fill", accent: Color.cyan)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        WatchPartyPreviewView()
                    } label: {
                        HFRoomFeatureCard(title: "Watch Community", subtitle: "Turn viewing into conversation around great content.", status: "Coming Soon", systemImage: "play.tv.fill", accent: Color.cyan)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Connect Room")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LaunchRoomView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFProductRoomHero(
                    eyebrow: "LAUNCH",
                    title: "Launch Room",
                    subtitle: "Prepare premieres, campaigns, and release moments.",
                    purpose: "This room previews release and campaign planning.",
                    heroCopy: "A launch command space for premieres, audience buildup, campaign pages, and release readiness.",
                    status: "Launch Preview",
                    systemImage: "flag.checkered",
                    accent: Color.green
                )

                VStack(spacing: HFSpacing.md) {
                    NavigationLink {
                        CreatorLaunchCenterPreviewView()
                    } label: {
                        HFRoomFeatureCard(title: "Premiere Timeline", subtitle: "Plan the path from announcement to release.", status: "Preview", systemImage: "calendar.badge.clock", accent: Color.green)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        AppReleasePresentationView()
                    } label: {
                        HFRoomFeatureCard(title: "Campaign Preview", subtitle: "Shape the public-facing launch page.", status: "Launch Preview", systemImage: "rectangle.on.rectangle.angled.fill", accent: Color.green)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        CreatorAccessPreviewView()
                    } label: {
                        HFRoomFeatureCard(title: "Audience Waitlist", subtitle: "Preview demand and interest before release.", status: "Preview", systemImage: "person.crop.circle.badge.clock", accent: Color.green)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        AppDemoChecklistView()
                    } label: {
                        HFRoomFeatureCard(title: "Launch Checklist", subtitle: "Track posters, trailers, synopsis, and release materials.", status: "Readiness", systemImage: "checklist.checked", accent: Color.green)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        ReleaseCandidatePrepView()
                    } label: {
                        HFRoomFeatureCard(title: "Release Status", subtitle: "See what is ready, pending, or deferred.", status: "Local Preview", systemImage: "gauge.with.dots.needle.67percent", accent: Color.green)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Launch Room")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ExportRoomView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFProductRoomHero(
                    eyebrow: "EXPORT",
                    title: "Export Room",
                    subtitle: "Prepare deliverables, media kits, and platform packages.",
                    purpose: "This room previews professional readiness and distribution preparation.",
                    heroCopy: "A professional space for deliverables, media kits, festival packages, and distribution readiness.",
                    status: "Readiness Preview",
                    systemImage: "shippingbox.fill",
                    accent: Color.purple
                )

                VStack(spacing: HFSpacing.md) {
                    HFRoomFeatureCard(title: "Deliverables", subtitle: "Track required materials for release and distribution.", status: "Readiness", systemImage: "checklist.checked", accent: Color.purple)
                    HFRoomFeatureCard(title: "Poster Package", subtitle: "Organize key art, thumbnails, and promotional visuals.", status: "Preview", systemImage: "photo.fill", accent: Color.purple)
                    HFRoomFeatureCard(title: "Trailer Package", subtitle: "Prepare trailers, teasers, and preview assets.", status: "Coming Soon", systemImage: "film.fill", accent: Color.purple)
                    HFRoomFeatureCard(title: "Festival Package", subtitle: "Collect synopsis, stills, credits, and submission materials.", status: "Readiness", systemImage: "rosette", accent: Color.purple)
                    HFRoomFeatureCard(title: "Distribution Checklist", subtitle: "Prepare platform requirements before real export exists.", status: "Local Preview", systemImage: "list.bullet.rectangle.fill", accent: Color.purple)
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)

                QAInfoPanel(
                    icon: "lock.shield.fill",
                    title: "Export systems remain locked",
                    subtitle: "This room is planning-only. It does not generate files, open share flows, access photos, or run delivery systems."
                )
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Export Room")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HFProductRoomHero: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let purpose: String
    let heroCopy: String
    let status: String
    let systemImage: String
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: 28, strokeColor: accent.opacity(0.38)) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [accent.opacity(0.22), HFColors.warmGlow.opacity(0.10), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(alignment: .leading, spacing: HFSpacing.lg) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomStatusChip(title: eyebrow, accent: accent)
                            Text(title)
                                .font(HFTypography.display)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(subtitle)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()

                        Image(systemName: systemImage)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 58, height: 58)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    HFRoomStatusChip(title: status, accent: accent)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text(purpose)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(heroCopy)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(HFSpacing.md)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                }
                .padding(HFSpacing.lg)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle), \(status)")
    }
}

private struct HFRoomFeatureCard: View {
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                        HFRoomStatusChip(title: status, accent: accent)
                    }

                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(subtitle), \(status)")
    }
}

private struct HFRoomStatusChip: View {
    let title: String
    let accent: Color

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.xs)
            .padding(.vertical, 6)
            .background(accent.opacity(0.12))
            .overlay(Capsule().stroke(accent.opacity(0.38), lineWidth: 1))
            .clipShape(Capsule())
            .accessibilityLabel("Status: \(title)")
    }
}

private struct DeveloperQAHubView: View {
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: HFSpacing.sm)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                releaseReadinessSection
                consumerScreenQASection
                visualParitySection
                protectedSystemsSection
                routeQualitySection
                buildLaunchChecklistSection
                screenshotReviewSection
                internalToolsSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Developer / QA")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HFStatusBadge(title: "Internal Only", systemImage: "lock.shield.fill", isProminent: false)

                Text("Developer / QA Hub")
                    .font(HFTypography.display)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Internal build room for release readiness, visual parity, route quality, and protected-system safety.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HFGlassPanel(cornerRadius: 28, strokeColor: HFColors.goldStroke) {
                ZStack(alignment: .topTrailing) {
                    LinearGradient(
                        colors: [
                            HFColors.gold.opacity(0.24),
                            Color.orange.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(alignment: .leading, spacing: HFSpacing.lg) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                                Text("HighFive Cinema")
                                    .font(HFTypography.section)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text("Internal Build Room")
                                    .font(HFTypography.title)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer()

                            Image(systemName: "rectangle.3.group.bubble.left.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 56, height: 56)
                                .background(HFColors.gold.opacity(0.14))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        VStack(spacing: HFSpacing.sm) {
                            checkpointRow(label: "Current Checkpoint", value: "Phase 12.5 Consumer UI Visual Parity")
                            checkpointRow(label: "Last Known Commit", value: "948738d")
                            checkpointRow(label: "Last Known Tag", value: "phase-12-5-consumer-ui-visual-parity")
                            checkpointRow(label: "Primary Status", value: "Needs Visual Assembly QA", isProminent: true)
                        }

                        Text("Manual checkpoint / last known handoff data. This screen does not read live repository state.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(HFSpacing.lg)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func checkpointRow(label: String, value: String, isProminent: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: HFSpacing.sm) {
            Text(label)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textMuted)
            Spacer(minLength: HFSpacing.sm)
            Text(value)
                .font(isProminent ? HFTypography.smallAction : HFTypography.caption)
                .foregroundStyle(isProminent ? HFColors.gold : HFColors.textPrimary)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }

    private var releaseReadinessSection: some View {
        hubSection(
            title: "Release Readiness",
            subtitle: "Static status board for the current visual checkpoint."
        ) {
            LazyVGrid(columns: columns, spacing: HFSpacing.sm) {
                ForEach(HFDeveloperQAData.releaseReadiness) { item in
                    QAStatusCard(item: item)
                }
            }
        }
    }

    private var consumerScreenQASection: some View {
        hubSection(
            title: "Consumer Screen QA",
            subtitle: "Screen-by-screen review focus for the consumer streaming shell."
        ) {
            VStack(spacing: HFSpacing.md) {
                ForEach(HFDeveloperQAData.screenReviews) { review in
                    QAScreenReviewCard(review: review)
                }
            }
        }
    }

    private var visualParitySection: some View {
        hubSection(
            title: "Visual Parity Center",
            subtitle: "Locked Figma authority and secondary style boundaries."
        ) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                QAInfoPanel(
                    icon: "rectangle.3.group.fill",
                    title: "HighFive Cinema Master Template",
                    subtitle: "File Key: G2QYwgGfR08ZsF1oQpgDuG\nCanvas: 01_Streaming_System"
                )

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Production Frames")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)

                    ForEach(HFDeveloperQAData.figmaFrames) { frame in
                        QAFrameReferenceRow(frame: frame)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Known Measurements")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)

                    LazyVGrid(columns: columns, spacing: HFSpacing.sm) {
                        ForEach(HFDeveloperQAData.figmaMeasurements) { item in
                            QAStatusCard(item: item)
                        }
                    }
                }

                QAInfoPanel(
                    icon: "sparkles",
                    title: "Home_Discovery_Gold · 11:9977",
                    subtitle: "Classification: Secondary / Style Support Only. Use for dark/gold cinematic polish only; never replace production frames."
                )
            }
        }
    }

    private var protectedSystemsSection: some View {
        hubSection(
            title: "Protected Systems Seal",
            subtitle: "Read-only vault. No unlock, edit, repair, or connect actions live here."
        ) {
            LazyVGrid(columns: columns, spacing: HFSpacing.sm) {
                ForEach(HFDeveloperQAData.protectedSystems) { system in
                    QAProtectedSystemCard(system: system)
                }
            }
        }
    }

    private var routeQualitySection: some View {
        hubSection(
            title: "Route Quality Center",
            subtitle: "Manual route checks that keep internal validation away from consumer screens."
        ) {
            VStack(spacing: HFSpacing.sm) {
                ForEach(HFDeveloperQAData.routeValidations) { route in
                    QARouteValidationRow(route: route)
                }
            }
        }
    }

    private var buildLaunchChecklistSection: some View {
        hubSection(
            title: "Build + Launch Checklist",
            subtitle: "Manual validation checklist. The app does not execute these commands."
        ) {
            VStack(spacing: HFSpacing.sm) {
                QAInfoPanel(
                    icon: "clock.badge.checkmark.fill",
                    title: "Last Known Handoff Data",
                    subtitle: "Phase 12.4 · Commit: 201663e · Tag: phase-12-4-consumer-streaming-reconstruction\nPhase 12.5 · Commit: 948738d · Tag: phase-12-5-consumer-ui-visual-parity"
                )

                ForEach(HFDeveloperQAData.buildChecklist) { item in
                    QAChecklistRow(item: item)
                }
            }
        }
    }

    private var screenshotReviewSection: some View {
        hubSection(
            title: "Screenshot Review",
            subtitle: "Expected review captures for the visible template assembly pass."
        ) {
            VStack(spacing: HFSpacing.sm) {
                ForEach(HFDeveloperQAData.screenshotReviews) { item in
                    QAScreenshotReviewCard(item: item)
                }
            }
        }
    }

    private var internalToolsSection: some View {
        hubSection(
            title: "Internal Tools Index",
            subtitle: "Existing local review tools. These do not run live services or automation."
        ) {
            VStack(spacing: HFSpacing.md) {
                toolLink(
                    title: "Product Spine",
                    subtitle: "Open the internal spine map for Watch, Create, Connect, Launch, and Export.",
                    systemImage: "point.3.connected.trianglepath.dotted"
                ) {
                    ProductSpineCompletionView()
                }

                toolLink(
                    title: "Product Spine Completion",
                    subtitle: "Review the full local Watch, Create, Connect, Launch, Export spine.",
                    systemImage: "rectangle.connected.to.line.below"
                ) {
                    ProductSpineCompletionView()
                }

                toolLink(
                    title: "Final Demo Tour",
                    subtitle: "Walk through internal demo routes without exposing them to Home.",
                    systemImage: "map.fill"
                ) {
                    FinalDemoTourView()
                }

                toolLink(
                    title: "Route Quality Center",
                    subtitle: "Review route clarity, destinations, and dead-end cleanup.",
                    systemImage: "arrow.triangle.branch"
                ) {
                    RouteQualityCenterView()
                }

                toolLink(
                    title: "Mockup Readiness Lock",
                    subtitle: "Check readiness before Figma visual parity work.",
                    systemImage: "checkmark.seal.fill"
                ) {
                    MockupReadinessLockView()
                }

                toolLink(
                    title: "Spine Safety Seal",
                    subtitle: "Confirm protected systems stay locked during UI work.",
                    systemImage: "shield.lefthalf.filled"
                ) {
                    SpineSafetySealView()
                }

                toolLink(
                    title: "Visual Pass Launch Checklist",
                    subtitle: "Track visual pass launch checks as manual review items.",
                    systemImage: "checklist.checked"
                ) {
                    VisualPassLaunchChecklistView()
                }

                toolLink(
                    title: "Dead-End Cleanup Checklist",
                    subtitle: "Audit local-only route exits and preview language.",
                    systemImage: "point.3.connected.trianglepath.dotted"
                ) {
                    DeadEndCleanupChecklistView()
                }

                toolLink(
                    title: "Spine Navigation Map",
                    subtitle: "Review the internal route map for the local product spine.",
                    systemImage: "map"
                ) {
                    SpineNavigationMapView()
                }

                toolLink(
                    title: "Pre-Mockup Readiness Review",
                    subtitle: "Check source readiness before parity work.",
                    systemImage: "doc.text.magnifyingglass"
                ) {
                    PreMockupReadinessReviewView()
                }

                toolLink(
                    title: "Visual Parity Backlog",
                    subtitle: "Track visual backlog items away from consumer surfaces.",
                    systemImage: "rectangle.stack.badge.plus"
                ) {
                    VisualParityBacklogView()
                }

                toolLink(
                    title: "Product Spine Gap Review",
                    subtitle: "Review remaining local spine gaps before release review.",
                    systemImage: "exclamationmark.triangle.fill"
                ) {
                    ProductSpineGapReviewView()
                }
            }
        }
    }

    private func hubSection<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: title, actionTitle: nil)

            Text(subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            content()
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func toolLink<Destination: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HFActionTile(title: title, subtitle: subtitle, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }
}

private enum HFQAStatus {
    case passed
    case needsReview
    case protected
    case deferred
    case blocked
    case needed
    case needsManualQA
    case captured
    case reviewed
    case needsFix

    var title: String {
        switch self {
        case .passed: return "Passed"
        case .needsReview: return "Needs Review"
        case .protected: return "Protected"
        case .deferred: return "Deferred"
        case .blocked: return "Blocked"
        case .needed: return "Needed"
        case .needsManualQA: return "Needs Manual QA"
        case .captured: return "Captured"
        case .reviewed: return "Reviewed"
        case .needsFix: return "Needs Fix"
        }
    }

    var systemImage: String {
        switch self {
        case .passed, .reviewed: return "checkmark.circle.fill"
        case .needsReview, .needed, .needsManualQA: return "clock.fill"
        case .protected: return "lock.shield.fill"
        case .deferred: return "pause.circle.fill"
        case .blocked, .needsFix: return "exclamationmark.triangle.fill"
        case .captured: return "camera.viewfinder"
        }
    }

    var color: Color {
        switch self {
        case .passed, .reviewed:
            return Color.green
        case .needsReview, .needed, .needsManualQA, .captured:
            return HFColors.gold
        case .protected:
            return Color.cyan
        case .deferred:
            return Color.gray
        case .blocked, .needsFix:
            return Color.red
        }
    }
}

private struct HFQAStatusItem: Identifiable {
    let id = UUID()
    let title: String
    let status: HFQAStatus
    let detail: String
    let systemImage: String
}

private struct HFQAScreenReview: Identifiable {
    let id = UUID()
    let screen: String
    let figmaSource: String
    let status: HFQAStatus
    let reviewFocus: String
    let checklist: [String]
}

private struct HFQAFrameReference: Identifiable {
    let id = UUID()
    let name: String
    let node: String
    let purpose: String
}

private struct HFQAProtectedSystem: Identifiable {
    let id = UUID()
    let name: String
    let systemImage: String
}

private struct HFQARouteValidation: Identifiable {
    let id = UUID()
    let route: String
    let expectedBehavior: String
    let status: HFQAStatus
    let notes: String
}

private struct HFQAScreenshotReview: Identifiable {
    let id = UUID()
    let screen: String
    let expectedName: String
    let status: HFQAStatus
    let reviewFocus: String
}

private enum HFDeveloperQAData {
    static let releaseReadiness: [HFQAStatusItem] = [
        HFQAStatusItem(title: "Build Passed", status: .passed, detail: "Last known build completed successfully.", systemImage: "hammer.fill"),
        HFQAStatusItem(title: "Simulator Launched", status: .passed, detail: "App launched on booted iPhone 17 Pro simulator.", systemImage: "iphone.gen3"),
        HFQAStatusItem(title: "Consumer Shell Locked", status: .protected, detail: "Home, Search, Library, Downloads, and Profile remain the only tabs.", systemImage: "rectangle.bottomthird.inset.filled"),
        HFQAStatusItem(title: "Protected Systems Safe", status: .protected, detail: "No protected systems should be touched during UI passes.", systemImage: "lock.shield.fill"),
        HFQAStatusItem(title: "Screenshots Needed", status: .needsReview, detail: "Visual review requires screen captures.", systemImage: "camera.viewfinder"),
        HFQAStatusItem(title: "Visual Assembly In Progress", status: .needsReview, detail: "Figma direction still needs visible screenshot comparison.", systemImage: "sparkles")
    ]

    static let screenReviews: [HFQAScreenReview] = [
        HFQAScreenReview(
            screen: "Home",
            figmaSource: "HF_Home · Node 1:2",
            status: .needsReview,
            reviewFocus: "Premium streaming entry and first five seconds.",
            checklist: [
                "Hero feels cinematic",
                "Poster rails are visible",
                "Watch Now CTA is visible",
                "No dashboard language",
                "No QA/internal tools exposed",
                "Bottom tab remains locked"
            ]
        ),
        HFQAScreenReview(
            screen: "Search / Discover",
            figmaSource: "HF_Discover · Node 1:191",
            status: .needsReview,
            reviewFocus: "Content discovery, filters, and poster-first results.",
            checklist: [
                "Search field has clear focus",
                "Category filters use the gold active state",
                "Discovery rails are content-led",
                "No route matrix is visible"
            ]
        ),
        HFQAScreenReview(
            screen: "Library",
            figmaSource: "No dedicated locked Figma frame yet",
            status: .deferred,
            reviewFocus: "Validate against consumer shell and My List behavior.",
            checklist: [
                "Saved titles are visible",
                "Movie detail routing works",
                "Empty states invite discovery",
                "No account setup requirement"
            ]
        ),
        HFQAScreenReview(
            screen: "Downloads",
            figmaSource: "HF_Downloads · Node 1:150",
            status: .needsReview,
            reviewFocus: "Offline shelf feel with poster stack and download rows.",
            checklist: [
                "Poster stack hero is visible",
                "Storage card is compact",
                "Rows feel like streaming content",
                "Find More To Download is clear"
            ]
        ),
        HFQAScreenReview(
            screen: "Profile",
            figmaSource: "HF_Profile · Node 1:115",
            status: .needsReview,
            reviewFocus: "Consumer profile first, internal tools hidden lower.",
            checklist: [
                "Profile switcher is clear",
                "Settings and Help are easy to find",
                "Developer / QA Hub is secondary",
                "Internal tools are not first-glance content"
            ]
        ),
        HFQAScreenReview(
            screen: "Movie Detail",
            figmaSource: "HF_Movie_Detail · Node 1:78",
            status: .needsReview,
            reviewFocus: "Cinematic title page with clear Watch and Save actions.",
            checklist: [
                "Tall cinematic hero is visible",
                "Metadata is readable",
                "Watch Now is primary",
                "Save/My List is secondary",
                "Related titles are visible",
                "No real AVPlayer integration"
            ]
        )
    ]

    static let figmaFrames: [HFQAFrameReference] = [
        HFQAFrameReference(name: "HF_Home", node: "1:2", purpose: "Consumer home authority"),
        HFQAFrameReference(name: "HF_Movie_Detail", node: "1:78", purpose: "Title detail authority"),
        HFQAFrameReference(name: "HF_Profile", node: "1:115", purpose: "Profile authority"),
        HFQAFrameReference(name: "HF_Downloads", node: "1:150", purpose: "Downloads authority"),
        HFQAFrameReference(name: "HF_Discover", node: "1:191", purpose: "Discover authority")
    ]

    static let figmaMeasurements: [HFQAStatusItem] = [
        HFQAStatusItem(title: "Screen", status: .protected, detail: "500 x 1020", systemImage: "iphone"),
        HFQAStatusItem(title: "Hero", status: .protected, detail: "500 x 630", systemImage: "rectangle.topthird.inset.filled"),
        HFQAStatusItem(title: "Hero Radius", status: .protected, detail: "20px", systemImage: "rectangle.roundedtop.fill"),
        HFQAStatusItem(title: "Poster Cards", status: .protected, detail: "140-152 x 210", systemImage: "photo.fill"),
        HFQAStatusItem(title: "Poster Radius", status: .protected, detail: "15px", systemImage: "rectangle.portrait.fill"),
        HFQAStatusItem(title: "Bottom Tab Shelf", status: .protected, detail: "500 x 115", systemImage: "rectangle.bottomthird.inset.filled"),
        HFQAStatusItem(title: "Inner Tab Group", status: .protected, detail: "467 x 81", systemImage: "rectangle.inset.filled")
    ]

    static let protectedSystems: [HFQAProtectedSystem] = [
        HFQAProtectedSystem(name: "Depth", systemImage: "cube.transparent"),
        HFQAProtectedSystem(name: "Motion", systemImage: "gyroscope"),
        HFQAProtectedSystem(name: "Playback", systemImage: "play.rectangle.fill"),
        HFQAProtectedSystem(name: "Layer4", systemImage: "square.stack.3d.up.fill"),
        HFQAProtectedSystem(name: "Rendering", systemImage: "viewfinder"),
        HFQAProtectedSystem(name: "Creator", systemImage: "wand.and.stars"),
        HFQAProtectedSystem(name: "App/UI", systemImage: "rectangle.3.group.fill"),
        HFQAProtectedSystem(name: "Store", systemImage: "cart.fill"),
        HFQAProtectedSystem(name: "Assets", systemImage: "photo.stack.fill"),
        HFQAProtectedSystem(name: "Poster Mappings", systemImage: "photo.fill"),
        HFQAProtectedSystem(name: "Backdrop Mappings", systemImage: "photo.on.rectangle.angled"),
        HFQAProtectedSystem(name: "Info.plist", systemImage: "doc.text.fill"),
        HFQAProtectedSystem(name: "PrivacyInfo", systemImage: "hand.raised.fill"),
        HFQAProtectedSystem(name: "Entitlements", systemImage: "key.fill"),
        HFQAProtectedSystem(name: "Figma Blueprint", systemImage: "rectangle.3.group.fill")
    ]

    static let routeValidations: [HFQARouteValidation] = [
        HFQARouteValidation(route: "Home -> Movie Detail", expectedBehavior: "Tap a poster or featured title and open Movie Detail.", status: .needsManualQA, notes: "Confirm navigation works without exposing internal tools."),
        HFQARouteValidation(route: "Search -> Movie Detail", expectedBehavior: "Search results open the selected Movie Detail screen.", status: .needsManualQA, notes: "Local search only."),
        HFQARouteValidation(route: "Discover -> Movie Detail", expectedBehavior: "Discovery rails route into Movie Detail.", status: .needsManualQA, notes: "No consumer route matrix."),
        HFQARouteValidation(route: "Library -> Movie Detail", expectedBehavior: "Saved and in-progress titles open Movie Detail.", status: .needsManualQA, notes: "Validate My List behavior."),
        HFQARouteValidation(route: "Downloads -> Movie Detail", expectedBehavior: "Downloaded local titles open detail where supported.", status: .needsManualQA, notes: "No file-system behavior."),
        HFQARouteValidation(route: "Profile -> Developer / QA Hub", expectedBehavior: "Internal hub is reachable only from Profile.", status: .passed, notes: "No new bottom tab."),
        HFQARouteValidation(route: "Profile -> Settings", expectedBehavior: "Settings opens local preview copy only.", status: .passed, notes: "No live account service."),
        HFQARouteValidation(route: "Profile -> Creator Preview", expectedBehavior: "Creator preview routes remain secondary.", status: .needsManualQA, notes: "Do not dominate profile first glance."),
        HFQARouteValidation(route: "Profile -> Connect Preview", expectedBehavior: "Connect preview routes remain secondary.", status: .needsManualQA, notes: "Community systems stay local.")
    ]

    static let buildChecklist: [HFQAStatusItem] = [
        HFQAStatusItem(title: "git status clean", status: .needsReview, detail: "Manual repo check before commit.", systemImage: "checkmark.circle"),
        HFQAStatusItem(title: "protected-path scan passed", status: .needsReview, detail: "No protected paths changed.", systemImage: "lock.shield"),
        HFQAStatusItem(title: "forbidden import scan passed", status: .needsReview, detail: "No live-service imports added.", systemImage: "magnifyingglass"),
        HFQAStatusItem(title: "xcodebuild passed", status: .needsReview, detail: "Simulator build must pass before promotion.", systemImage: "hammer"),
        HFQAStatusItem(title: "app installed on simulator", status: .needsReview, detail: "Install on booted simulator when available.", systemImage: "iphone.and.arrow.forward"),
        HFQAStatusItem(title: "app launched on simulator", status: .needsReview, detail: "Launch the HighFive app bundle.", systemImage: "play.fill"),
        HFQAStatusItem(title: "screenshots captured", status: .needed, detail: "Capture consumer screens for visual review.", systemImage: "camera"),
        HFQAStatusItem(title: "commit created", status: .deferred, detail: "Only after build and scans pass.", systemImage: "checkmark.seal"),
        HFQAStatusItem(title: "tag created", status: .deferred, detail: "Only after complete phase checkpoint.", systemImage: "tag")
    ]

    static let screenshotReviews: [HFQAScreenshotReview] = [
        HFQAScreenshotReview(screen: "Home", expectedName: "highfive-visible-template-assembly-home.png", status: .needed, reviewFocus: "Hero scale, gold mood, poster density, no dashboard feel."),
        HFQAScreenshotReview(screen: "Discover/Search", expectedName: "highfive-visible-template-assembly-discover.png", status: .needed, reviewFocus: "Content discovery and filter treatment."),
        HFQAScreenshotReview(screen: "Movie Detail", expectedName: "highfive-visible-template-assembly-movie-detail.png", status: .needed, reviewFocus: "Cinematic title page and actions."),
        HFQAScreenshotReview(screen: "Downloads", expectedName: "highfive-visible-template-assembly-downloads.png", status: .needed, reviewFocus: "Offline shelf and Find More To Download CTA."),
        HFQAScreenshotReview(screen: "Profile", expectedName: "highfive-visible-template-assembly-profile.png", status: .needed, reviewFocus: "Consumer-first profile, internal tools hidden lower."),
        HFQAScreenshotReview(screen: "Developer / QA Hub", expectedName: "highfive-dev-qa-hub.png", status: .needed, reviewFocus: "Internal control room, readable statuses, no live-system execution.")
    ]
}

private struct QAStatusCard: View {
    let item: HFQAStatusItem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: item.status.color.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(alignment: .top) {
                    Image(systemName: item.systemImage)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(item.status.color)
                        .frame(width: 36, height: 36)
                        .background(item.status.color.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    Spacer()

                    QAStatusPill(status: item.status)
                }

                Text(item.title)
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct QAScreenReviewCard: View {
    let review: HFQAScreenReview

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: review.status.color.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(review.screen)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(review.figmaSource)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                    }

                    Spacer()

                    QAStatusPill(status: review.status)
                }

                Text(review.reviewFocus)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(review.checklist, id: \.self) { item in
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(HFColors.gold)
                                .padding(.top, 2)
                            Text(item)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct QAInfoPanel: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 40, height: 40)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct QAFrameReferenceRow: View {
    let frame: HFQAFrameReference

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "rectangle.inset.filled")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28, height: 28)
                .background(HFColors.gold.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("\(frame.name) · \(frame.node)")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(frame.purpose)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
            }

            Spacer()
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct QAProtectedSystemCard: View {
    let system: HFQAProtectedSystem

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: Color.cyan.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: system.systemImage)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.cyan)
                    .frame(width: 34, height: 34)
                    .background(Color.cyan.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(system.name)
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                QAStatusPill(status: .protected)
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct QARouteValidationRow: View {
    let route: HFQARouteValidation

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: route.status.color.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(alignment: .top) {
                    Text(route.route)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    QAStatusPill(status: route.status)
                }

                Text(route.expectedBehavior)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(route.notes)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct QAChecklistRow: View {
    let item: HFQAStatusItem

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: item.systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(item.status.color)
                .frame(width: 30, height: 30)
                .background(item.status.color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                Text(item.detail)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            QAStatusPill(status: item.status)
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct QAScreenshotReviewCard: View {
    let item: HFQAScreenshotReview

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: item.status.color.opacity(0.3)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.screen)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(item.expectedName)
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    QAStatusPill(status: item.status)
                }

                Text(item.reviewFocus)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct QAStatusPill: View {
    let status: HFQAStatus

    var body: some View {
        HStack(spacing: HFSpacing.xxs) {
            Image(systemName: status.systemImage)
                .font(.system(size: 9, weight: .black))
            Text(status.title)
                .font(HFTypography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, HFSpacing.xs)
        .padding(.vertical, 6)
        .background(status.color.opacity(0.13))
        .overlay(Capsule().stroke(status.color.opacity(0.4), lineWidth: 1))
        .clipShape(Capsule())
    }
}
