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
        ("Viewing Preferences", "slider.horizontal.3"),
        ("Account Preview", "person.crop.circle.fill"),
        ("Help", "questionmark.circle.fill")
    ]

    var body: some View {
        Group {
            if let launchTarget = Self.qaLaunchTarget {
                qaLaunchView(launchTarget)
            } else {
                profileContent
            }
        }
        .accessibilityIdentifier("hf.profile.root")
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

    private var profileContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                selectedProfilePanel
                avatarRow
                manageProfilesButton

                menu
                roomsGatewayHero
                highFiveRoomsSection
                buildQAToolsSection
                signOutButton
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
    }

    @ViewBuilder
    private func qaLaunchView(_ target: HFProfileQALaunchTarget) -> some View {
        switch target {
        case .roomsGateway:
            profileRoomsGatewayQAView
        case .watch:
            WatchRoomView()
        case .create:
            CreateRoomView()
        case .connect:
            ConnectRoomView()
        case .launch:
            LaunchRoomView()
        case .export:
            ExportRoomView()
        case .developerQA:
            DeveloperQAHubView()
        case .demoTour:
            FinalDemoTourView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Text("Your Profile")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
            Text("Manage your viewing space, saved titles, and HighFive Rooms.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your Profile, manage your viewing space, saved titles, and HighFive Rooms")
    }

    private enum HFProfileQALaunchTarget {
        case roomsGateway
        case watch
        case create
        case connect
        case launch
        case export
        case developerQA
        case demoTour
    }

    private static var qaLaunchTarget: HFProfileQALaunchTarget? {
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("--hf-start-profile-rooms") { return .roomsGateway }
        if arguments.contains("--hf-start-watch-room") { return .watch }
        if arguments.contains("--hf-start-create-room") { return .create }
        if arguments.contains("--hf-start-connect-room") { return .connect }
        if arguments.contains("--hf-start-launch-room") { return .launch }
        if arguments.contains("--hf-start-export-room") { return .export }
        if arguments.contains("--hf-start-developer-qa") { return .developerQA }
        if arguments.contains("--hf-start-demo-tour") { return .demoTour }
        return nil
    }

    private var profileRoomsGatewayQAView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                roomsGatewayHero
                highFiveRoomsSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Profile switcher, watching as \(selectedProfile.name)")
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
            HFSectionHeader(title: "Internal", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                NavigationLink {
                    DeveloperQAHubView()
                } label: {
                    HFInternalGatewayCard(
                        title: "Developer / QA Hub",
                        subtitle: "Internal validation, visual parity, route quality, and release readiness.",
                        systemImage: "wrench.and.screwdriver.fill"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Developer QA Hub, internal validation and release readiness")
                .accessibilityIdentifier("hf.profile.developerQaButton")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.profile.internalSection")
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
                        status: "WATCH",
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
                        status: "CREATE",
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
                        status: "CONNECT",
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
                        subtitle: "Premieres, campaigns, timelines, and release readiness.",
                        status: "LAUNCH",
                        systemImage: "flag.checkered",
                        accent: HFColors.gold
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Launch Room, premiere and campaign preview for release readiness")

                NavigationLink {
                    ExportRoomView()
                } label: {
                    HFProductRoomEntryCard(
                        title: "Export",
                        subtitle: "Deliverables, media kits, and distribution packages.",
                        status: "EXPORT",
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
        .accessibilityLabel("HighFive Rooms, product spaces for watching, creating, connecting, launching, and export readiness")
        .accessibilityIdentifier("hf.profile.roomsSection")
    }

    private var roomsGatewayHero: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "rectangle.3.group.fill")
                        .font(.system(size: 25, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 54, height: 54)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("HighFive Rooms Gateway")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                        Text("Start in Watch, then move into creator, community, launch, and delivery previews without leaving the local app shell.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(["Watch", "Create", "Connect", "Launch", "Export"], id: \.self) { room in
                        Text(room)
                            .font(HFTypography.micro)
                            .foregroundStyle(room == "Watch" ? .black : HFColors.gold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
                            .background(room == "Watch" ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.10)))
                            .overlay(Capsule().stroke(HFColors.gold.opacity(room == "Watch" ? 0 : 0.22), lineWidth: 1))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(HFSpacing.lg)
            .background(
                LinearGradient(
                    colors: [HFColors.warmGlow.opacity(0.26), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HighFive Rooms Gateway")
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
        case "Viewing Preferences":
            activeMockSheet = ProfileMockSheet(
                title: "Viewing Preferences",
                message: "Streaming display, download, and playback preferences will live here later.",
                systemImage: "gearshape.fill"
            )
        case "Account Preview":
            activeMockSheet = ProfileMockSheet(
                title: "Account Preview",
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

private struct HFInternalGatewayCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(HFColors.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(title)
                            .font(HFTypography.menu)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("INTERNAL")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textMuted)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .padding(.horizontal, HFSpacing.xs)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.06))
                            .overlay(Capsule().stroke(HFColors.glassStroke, lineWidth: 1))
                            .clipShape(Capsule())
                    }

                    Text(subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(HFColors.textMuted)
                    .padding(.top, 4)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), internal validation and release readiness")
    }
}

private struct HFRoomReadinessSignal: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let detail: String
    let systemImage: String
}

private struct HFRoomPipelineStage: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let systemImage: String
}

private struct HFRoomWorkflowStep: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFRoomBoundaryItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

private struct HFRoomDepthBlueprint {
    let readinessScore: Int
    let readinessTitle: String
    let readinessSubtitle: String
    let readinessSignals: [HFRoomReadinessSignal]
    let pipelineStages: [HFRoomPipelineStage]
    let workflowSteps: [HFRoomWorkflowStep]
    let boundaryTitle: String
    let boundarySubtitle: String
    let boundaryItems: [HFRoomBoundaryItem]
}

private struct HFRoomWorkflowStage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
}

private struct HFRoomWorkflowChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFRoomWorkflowPlan {
    let title: String
    let subtitle: String
    let stages: [HFRoomWorkflowStage]
    let checklist: [HFRoomWorkflowChecklistItem]
    let nextStepTitle: String
    let nextStepSubtitle: String
    let nextStepActionTitle: String
}

private struct HFRoomWorkflowDrilldown: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let detailTitle: String
    let detailBody: String
    let checklist: [String]
    let systemImage: String
}

private struct HFRoomWorkflowDrilldownPlan {
    let title: String
    let subtitle: String
    let ctaTitle: String
    let stages: [HFRoomWorkflowDrilldown]
}

private struct HFCreatorPackageItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFCreatorPackageSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let progress: Double
    let systemImage: String
    let prepares: String
    let readySummary: String
    let previewSummary: String
    let deferredSummary: String
    let items: [HFCreatorPackageItem]
}

private struct HFCreatorPackageReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
}

private struct HFCreatorPackagePreview {
    let title: String
    let logline: String
    let genre: String
    let audience: String
    let packageStatus: String
    let sections: [HFCreatorPackageSection]
    let readiness: [HFCreatorPackageReadinessRow]
}

private struct HFCreatorSlateMaterial: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
    let systemImage: String
}

private struct HFCreatorSlateProject: Identifiable {
    let id = UUID()
    let title: String
    let format: String
    let genre: String
    let status: String
    let logline: String
    let audience: String
    let packageProgress: Double
    let systemImage: String
    let materials: [HFCreatorSlateMaterial]
}

private struct HFCreatorSlatePreview {
    let title: String
    let subtitle: String
    let activeProjectCount: Int
    let readyPackageCount: Int
    let draftPackageCount: Int
    let protectedSystemCount: Int
    let projects: [HFCreatorSlateProject]
}

private struct HFConnectPlannerPrompt: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFConnectPlannerSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let prepares: String
    let previewSummary: String
    let deferredSummary: String
    let prompts: [HFConnectPlannerPrompt]
}

private struct HFConnectReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
}

private struct HFConnectAudiencePreview {
    let title: String
    let subtitle: String
    let focusTitle: String
    let audienceTone: String
    let plannerStatus: String
    let sections: [HFConnectPlannerSection]
    let readiness: [HFConnectReadinessRow]
}

private struct HFLaunchPlannerItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFLaunchPlannerSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let prepares: String
    let previewSummary: String
    let deferredSummary: String
    let items: [HFLaunchPlannerItem]
}

private struct HFLaunchPlannerReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
}

private struct HFLaunchCampaignPreview {
    let title: String
    let subtitle: String
    let campaignFocus: String
    let releaseWindow: String
    let audienceTone: String
    let plannerStatus: String
    let sections: [HFLaunchPlannerSection]
    let readiness: [HFLaunchPlannerReadinessRow]
}

private struct HFExportPackageItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFExportPackageSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let prepares: String
    let previewSummary: String
    let deferredSummary: String
    let items: [HFExportPackageItem]
}

private struct HFExportPackageReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
}

private struct HFExportDistributionPreview {
    let title: String
    let subtitle: String
    let packageFocus: String
    let deliveryWindow: String
    let packageTone: String
    let plannerStatus: String
    let sections: [HFExportPackageSection]
    let readiness: [HFExportPackageReadinessRow]
}

private struct HFWatchHubItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFWatchHubSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let prepares: String
    let previewSummary: String
    let deferredSummary: String
    let items: [HFWatchHubItem]
}

private struct HFWatchHubReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
}

private struct HFWatchViewingHubPreview {
    let title: String
    let subtitle: String
    let viewingFocus: String
    let tonightPick: String
    let hubStatus: String
    let sections: [HFWatchHubSection]
    let readiness: [HFWatchHubReadinessRow]
}

private enum HFRoomDepthData {
    static let watch = HFRoomDepthBlueprint(
        readinessScore: 86,
        readinessTitle: "Viewing Readiness",
        readinessSubtitle: "Consumer surfaces are ready for a local watch-room demo.",
        readinessSignals: [
            HFRoomReadinessSignal(title: "Hero title", value: "Ready", detail: "Featured title routes into Movie Detail.", systemImage: "star.fill"),
            HFRoomReadinessSignal(title: "Saved path", value: "Ready", detail: "My List remains the viewer library route.", systemImage: "bookmark.fill"),
            HFRoomReadinessSignal(title: "Offline shelf", value: "Preview", detail: "Downloads is display-only and local.", systemImage: "arrow.down.circle.fill")
        ],
        pipelineStages: [
            HFRoomPipelineStage(title: "Home", status: "Entry", systemImage: "house.fill"),
            HFRoomPipelineStage(title: "Detail", status: "Inspect", systemImage: "film.fill"),
            HFRoomPipelineStage(title: "List", status: "Save", systemImage: "bookmark.fill"),
            HFRoomPipelineStage(title: "Download", status: "Shelf", systemImage: "arrow.down.circle.fill")
        ],
        workflowSteps: [
            HFRoomWorkflowStep(title: "Choose a title", detail: "Start from Home, Search, Library, or a featured card.", status: "Viewer", systemImage: "rectangle.stack.fill"),
            HFRoomWorkflowStep(title: "Inspect the story", detail: "Movie Detail carries synopsis, creator context, and related titles.", status: "Local", systemImage: "doc.text.fill"),
            HFRoomWorkflowStep(title: "Keep momentum", detail: "My List and Downloads keep the viewer inside consumer tabs.", status: "Ready", systemImage: "play.rectangle.fill")
        ],
        boundaryTitle: "Watch Safe Boundary",
        boundarySubtitle: "Watch Room is a static SwiftUI consumer preview. Player, capture, and protected media systems stay disconnected.",
        boundaryItems: [
            HFRoomBoundaryItem(title: "No player engine", detail: "Watch actions remain preview navigation only.", systemImage: "play.slash.fill"),
            HFRoomBoundaryItem(title: "No media capture", detail: "Capture and recording behavior are outside this room.", systemImage: "video.slash.fill"),
            HFRoomBoundaryItem(title: "No protected media edits", detail: "Protected media systems remain untouched.", systemImage: "lock.shield.fill")
        ]
    )

    static let create = HFRoomDepthBlueprint(
        readinessScore: 74,
        readinessTitle: "Studio Readiness",
        readinessSubtitle: "The creator package has enough local structure for product review.",
        readinessSignals: [
            HFRoomReadinessSignal(title: "Project slate", value: "Ready", detail: "Three local projects show status and needs.", systemImage: "film.stack.fill"),
            HFRoomReadinessSignal(title: "Pitch package", value: "Preview", detail: "Story, audience, format, and release angle are framed.", systemImage: "text.quote"),
            HFRoomReadinessSignal(title: "Media kit", value: "Review", detail: "Poster, stills, synopsis, credits, and notes are tracked.", systemImage: "photo.stack.fill")
        ],
        pipelineStages: [
            HFRoomPipelineStage(title: "Project", status: "Select", systemImage: "film.stack.fill"),
            HFRoomPipelineStage(title: "Pitch", status: "Shape", systemImage: "text.quote"),
            HFRoomPipelineStage(title: "Kit", status: "Package", systemImage: "photo.stack.fill"),
            HFRoomPipelineStage(title: "Launch", status: "Prep", systemImage: "flag.checkered")
        ],
        workflowSteps: [
            HFRoomWorkflowStep(title: "Frame the project", detail: "Use project cards to show stage, readiness, and needs.", status: "Preview", systemImage: "rectangle.3.group.fill"),
            HFRoomWorkflowStep(title: "Build the package", detail: "Move through creator identity, pitch, media kit, and launch prep.", status: "Local", systemImage: "shippingbox.fill"),
            HFRoomWorkflowStep(title: "Hand off safely", detail: "Launch and Export references remain planning surfaces only.", status: "Protected", systemImage: "lock.shield.fill")
        ],
        boundaryTitle: "Create Safe Boundary",
        boundarySubtitle: "Creator Studio stays local and static. No uploads, creator accounts, backend sync, payment logic, file access, rendering, or live creator systems are introduced.",
        boundaryItems: [
            HFRoomBoundaryItem(title: "No uploads", detail: "Media kit cards are display-only.", systemImage: "arrow.up.doc"),
            HFRoomBoundaryItem(title: "No creator backend", detail: "Creator identity and projects are local preview data.", systemImage: "server.rack"),
            HFRoomBoundaryItem(title: "No render/export hooks", detail: "Professional systems remain protected.", systemImage: "lock.shield.fill")
        ]
    )

    static let connect = HFRoomDepthBlueprint(
        readinessScore: 69,
        readinessTitle: "Community Readiness",
        readinessSubtitle: "Connect has enough local surface area to explain audience energy without live social systems.",
        readinessSignals: [
            HFRoomReadinessSignal(title: "Communities", value: "Preview", detail: "Rooms and project communities are reachable.", systemImage: "person.3.fill"),
            HFRoomReadinessSignal(title: "Reactions", value: "Local", detail: "Activity and reactions are static signals.", systemImage: "heart.text.square.fill"),
            HFRoomReadinessSignal(title: "Watch party", value: "Future", detail: "Conversation framing exists without live participation.", systemImage: "play.tv.fill")
        ],
        pipelineStages: [
            HFRoomPipelineStage(title: "Discover", status: "Find", systemImage: "magnifyingglass"),
            HFRoomPipelineStage(title: "Room", status: "Enter", systemImage: "bubble.left.and.bubble.right.fill"),
            HFRoomPipelineStage(title: "React", status: "Signal", systemImage: "heart.fill"),
            HFRoomPipelineStage(title: "Follow", status: "Return", systemImage: "person.badge.plus.fill")
        ],
        workflowSteps: [
            HFRoomWorkflowStep(title: "Find a community", detail: "Open communities around titles, creators, and release moments.", status: "Preview", systemImage: "person.3.fill"),
            HFRoomWorkflowStep(title: "Read the room", detail: "Activity, discussions, and reactions show audience context.", status: "Local", systemImage: "text.bubble.fill"),
            HFRoomWorkflowStep(title: "Bridge to launch", detail: "Community energy supports Launch Room planning without sending messages.", status: "Safe", systemImage: "flag.checkered")
        ],
        boundaryTitle: "Connect Safe Boundary",
        boundarySubtitle: "Connect Room is a static community preview. Messaging, notifications, uploads, live reactions, accounts, analytics, and backend social services stay disconnected.",
        boundaryItems: [
            HFRoomBoundaryItem(title: "No messaging", detail: "Discussion rows do not send or receive messages.", systemImage: "bubble.left.and.bubble.right.slash.fill"),
            HFRoomBoundaryItem(title: "No notifications", detail: "No push or reminder system is connected.", systemImage: "bell.slash.fill"),
            HFRoomBoundaryItem(title: "No social backend", detail: "Followers, reactions, and room counts are mock data.", systemImage: "server.rack")
        ]
    )

    static let launch = HFRoomDepthBlueprint(
        readinessScore: 72,
        readinessTitle: "Launch Readiness",
        readinessSubtitle: "Campaign, timeline, materials, and handoff planning are structured for review.",
        readinessSignals: [
            HFRoomReadinessSignal(title: "Timeline", value: "Preview", detail: "Release phases are visible and ordered.", systemImage: "calendar.badge.clock"),
            HFRoomReadinessSignal(title: "Campaign", value: "Local", detail: "Campaign copy is framed without publishing.", systemImage: "megaphone.fill"),
            HFRoomReadinessSignal(title: "Audience", value: "Mock", detail: "Momentum numbers are display-only.", systemImage: "person.3.fill")
        ],
        pipelineStages: [
            HFRoomPipelineStage(title: "Package", status: "Lock", systemImage: "shippingbox.fill"),
            HFRoomPipelineStage(title: "Warmup", status: "Build", systemImage: "flame.fill"),
            HFRoomPipelineStage(title: "Campaign", status: "Preview", systemImage: "megaphone.fill"),
            HFRoomPipelineStage(title: "Premiere", status: "Plan", systemImage: "flag.checkered")
        ],
        workflowSteps: [
            HFRoomWorkflowStep(title: "Lock release basics", detail: "Title, synopsis, creator notes, and poster direction come first.", status: "Review", systemImage: "checklist.checked"),
            HFRoomWorkflowStep(title: "Build the campaign", detail: "Shape audience hook, campaign header, and creator note.", status: "Preview", systemImage: "megaphone.fill"),
            HFRoomWorkflowStep(title: "Prepare handoff", detail: "Export handoff remains readiness copy, not a delivery system.", status: "Protected", systemImage: "lock.shield.fill")
        ],
        boundaryTitle: "Launch Safe Boundary",
        boundarySubtitle: "Launch Room is planning-only. Payments, commerce frameworks, subscriptions, campaign publishing, waitlists, notifications, analytics, and backend launch services stay disconnected.",
        boundaryItems: [
            HFRoomBoundaryItem(title: "No commerce", detail: "No paywall, subscription, commerce framework, or payment path exists.", systemImage: "creditcard"),
            HFRoomBoundaryItem(title: "No publishing", detail: "Campaign pages and waitlists are static previews.", systemImage: "paperplane.fill"),
            HFRoomBoundaryItem(title: "No analytics", detail: "Audience numbers are local display copy.", systemImage: "chart.bar.xaxis")
        ]
    )

    static let export = HFRoomDepthBlueprint(
        readinessScore: 66,
        readinessTitle: "Export Readiness",
        readinessSubtitle: "Deliverables, media kit, festival package, and platform checklist are organized as protected planning data.",
        readinessSignals: [
            HFRoomReadinessSignal(title: "Deliverables", value: "Review", detail: "Package groups are visible without generating files.", systemImage: "shippingbox.fill"),
            HFRoomReadinessSignal(title: "Festival kit", value: "Preview", detail: "Submission materials are grouped for review.", systemImage: "rosette"),
            HFRoomReadinessSignal(title: "Distribution", value: "Protected", detail: "Handoff is planning-only.", systemImage: "lock.shield.fill")
        ],
        pipelineStages: [
            HFRoomPipelineStage(title: "Collect", status: "List", systemImage: "tray.full.fill"),
            HFRoomPipelineStage(title: "Review", status: "Check", systemImage: "checklist.checked"),
            HFRoomPipelineStage(title: "Package", status: "Plan", systemImage: "shippingbox.fill"),
            HFRoomPipelineStage(title: "Handoff", status: "Protect", systemImage: "lock.shield.fill")
        ],
        workflowSteps: [
            HFRoomWorkflowStep(title: "Review required materials", detail: "Deliverables, poster package, trailer notes, credits, and press copy are visible.", status: "Preview", systemImage: "doc.text.fill"),
            HFRoomWorkflowStep(title: "Map platform needs", detail: "Platform checklists describe future requirements without endpoints.", status: "Local", systemImage: "tv.fill"),
            HFRoomWorkflowStep(title: "Protect delivery systems", detail: "No render, file writing, share, or distribution API behavior is connected.", status: "Protected", systemImage: "lock.shield.fill")
        ],
        boundaryTitle: "Export Safe Boundary",
        boundarySubtitle: "Export Room is a local readiness preview. Rendering, export engines, file writing, photo-library access, share sheets, uploads, platform delivery, backend submissions, and distribution APIs stay disconnected.",
        boundaryItems: [
            HFRoomBoundaryItem(title: "No generated files", detail: "Package cards do not write, export, or save content.", systemImage: "doc.badge.gearshape"),
            HFRoomBoundaryItem(title: "No share surfaces", detail: "No system share or delivery flow is connected.", systemImage: "square.and.arrow.up"),
            HFRoomBoundaryItem(title: "No render pipeline", detail: "Rendering and export engines stay protected.", systemImage: "viewfinder")
        ]
    )
}

private enum HFRoomWorkflowPlans {
    static let watch = HFRoomWorkflowPlan(
        title: "Viewing Flow",
        subtitle: "A calm viewer path from featured title to saved and offline-ready shelves.",
        stages: [
            HFRoomWorkflowStage(title: "Featured", subtitle: "Start with the premiere surface.", status: "Ready", systemImage: "star.fill"),
            HFRoomWorkflowStage(title: "Continue", subtitle: "Return to an in-progress title.", status: "Preview", systemImage: "play.rectangle.fill"),
            HFRoomWorkflowStage(title: "My List", subtitle: "Keep saved titles close.", status: "Ready", systemImage: "bookmark.fill"),
            HFRoomWorkflowStage(title: "Downloads", subtitle: "Show the offline-ready shelf.", status: "Local", systemImage: "arrow.down.circle.fill"),
            HFRoomWorkflowStage(title: "Discover", subtitle: "Move into search and discovery.", status: "Preview", systemImage: "magnifyingglass")
        ],
        checklist: [
            HFRoomWorkflowChecklistItem(title: "Featured premiere ready", detail: "Hero and Movie Detail route are ready for review.", state: "Ready"),
            HFRoomWorkflowChecklistItem(title: "Saved titles visible", detail: "My List keeps the viewer in the five-tab shell.", state: "Ready"),
            HFRoomWorkflowChecklistItem(title: "Offline-ready shelf", detail: "Downloads remains display-only in this phase.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Discovery rails", detail: "Search and discovery provide the return path.", state: "Preview")
        ],
        nextStepTitle: "Review Viewing Flow",
        nextStepSubtitle: "Check that featured, saved, offline-ready, and discovery paths stay viewer-facing.",
        nextStepActionTitle: "Review Watch Preview"
    )

    static let create = HFRoomWorkflowPlan(
        title: "Creator Package Timeline",
        subtitle: "Prepare a project package from slate to launch materials with local preview steps.",
        stages: [
            HFRoomWorkflowStage(title: "Project Slate", subtitle: "Choose the title package to prepare.", status: "Ready", systemImage: "film.stack.fill"),
            HFRoomWorkflowStage(title: "Story Positioning", subtitle: "Clarify promise, audience, tone, and format.", status: "Draft", systemImage: "text.quote"),
            HFRoomWorkflowStage(title: "Pitch Package", subtitle: "Shape the story and release angle.", status: "Preview", systemImage: "rectangle.stack.fill"),
            HFRoomWorkflowStage(title: "Media Kit", subtitle: "Group poster, stills, synopsis, and creator notes.", status: "Preview", systemImage: "photo.stack.fill"),
            HFRoomWorkflowStage(title: "Launch Prep", subtitle: "Carry finished copy into release planning.", status: "Deferred", systemImage: "flag.checkered")
        ],
        checklist: [
            HFRoomWorkflowChecklistItem(title: "Title synopsis", detail: "Short story summary is ready for the package.", state: "Ready"),
            HFRoomWorkflowChecklistItem(title: "Audience promise", detail: "Viewer promise is drafted for pitch review.", state: "Draft"),
            HFRoomWorkflowChecklistItem(title: "Poster / stills placeholder", detail: "Visual placeholders are present for review.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Creator profile", detail: "Creator identity is display-only and ready to inspect.", state: "Ready"),
            HFRoomWorkflowChecklistItem(title: "Pitch notes", detail: "Story, tone, and format notes are prepared locally.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Launch materials", detail: "Release copy is grouped for later planning.", state: "Deferred")
        ],
        nextStepTitle: "Prepare Pitch Package",
        nextStepSubtitle: "Shape the story, audience, and release angle before launch.",
        nextStepActionTitle: "Review Pitch Preview"
    )

    static let connect = HFRoomWorkflowPlan(
        title: "Audience Connection Timeline",
        subtitle: "Organize community activity around a title while staying local and preview-only.",
        stages: [
            HFRoomWorkflowStage(title: "Communities", subtitle: "Group audiences by title and creator.", status: "Preview", systemImage: "person.3.fill"),
            HFRoomWorkflowStage(title: "Creator Updates", subtitle: "Plan behind-the-scenes story beats.", status: "Local", systemImage: "text.bubble.fill"),
            HFRoomWorkflowStage(title: "Reactions", subtitle: "Review static audience response signals.", status: "Preview", systemImage: "heart.text.square.fill"),
            HFRoomWorkflowStage(title: "Following", subtitle: "Show how viewers return to creators.", status: "Preview", systemImage: "person.badge.plus.fill"),
            HFRoomWorkflowStage(title: "Watch Community", subtitle: "Frame a future conversation moment.", status: "Deferred", systemImage: "play.tv.fill")
        ],
        checklist: [
            HFRoomWorkflowChecklistItem(title: "Creator update topic", detail: "A local topic is ready for room review.", state: "Draft"),
            HFRoomWorkflowChecklistItem(title: "Premiere conversation", detail: "The room frames release-week audience context.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Audience group", detail: "Community grouping is visible and static.", state: "Ready"),
            HFRoomWorkflowChecklistItem(title: "Reaction preview", detail: "Response cards remain local signals.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Watch community prompt", detail: "Prompt copy is prepared for later room review.", state: "Deferred")
        ],
        nextStepTitle: "Preview Community Moment",
        nextStepSubtitle: "Plan how audiences gather around the story before real social systems are connected.",
        nextStepActionTitle: "Review Community Preview"
    )

    static let launch = HFRoomWorkflowPlan(
        title: "Launch Timeline",
        subtitle: "Prepare a premiere and release campaign as a static planning workflow.",
        stages: [
            HFRoomWorkflowStage(title: "Announcement", subtitle: "Frame the first public story beat.", status: "Draft", systemImage: "sparkles"),
            HFRoomWorkflowStage(title: "Campaign Preview", subtitle: "Shape headline, hook, and creator note.", status: "Preview", systemImage: "megaphone.fill"),
            HFRoomWorkflowStage(title: "Premiere Window", subtitle: "Hold a placeholder for timing review.", status: "Deferred", systemImage: "calendar.badge.clock"),
            HFRoomWorkflowStage(title: "Audience Build", subtitle: "Connect community energy to launch copy.", status: "Preview", systemImage: "person.3.fill"),
            HFRoomWorkflowStage(title: "Release Readiness", subtitle: "Check materials before release review.", status: "Ready", systemImage: "checkmark.seal.fill")
        ],
        checklist: [
            HFRoomWorkflowChecklistItem(title: "Campaign headline", detail: "Headline direction is ready for review.", state: "Draft"),
            HFRoomWorkflowChecklistItem(title: "Premiere date placeholder", detail: "Timing remains a static planning field.", state: "Deferred"),
            HFRoomWorkflowChecklistItem(title: "Poster materials", detail: "Key art direction is represented locally.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Synopsis", detail: "Short and long story copy support the plan.", state: "Ready"),
            HFRoomWorkflowChecklistItem(title: "Creator note", detail: "Creator context is ready for launch review.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Release readiness", detail: "Manual readiness remains local and static.", state: "Ready")
        ],
        nextStepTitle: "Prepare Premiere Plan",
        nextStepSubtitle: "Shape the public release story before live campaign systems are connected.",
        nextStepActionTitle: "Review Launch Plan"
    )

    static let export = HFRoomWorkflowPlan(
        title: "Delivery Timeline",
        subtitle: "Organize deliverables and distribution readiness as protected planning data.",
        stages: [
            HFRoomWorkflowStage(title: "Deliverables", subtitle: "List the package materials.", status: "Review", systemImage: "shippingbox.fill"),
            HFRoomWorkflowStage(title: "Media Kit", subtitle: "Group artwork, stills, synopsis, and notes.", status: "Preview", systemImage: "photo.stack.fill"),
            HFRoomWorkflowStage(title: "Festival Package", subtitle: "Prepare festival-facing copy.", status: "Preview", systemImage: "rosette"),
            HFRoomWorkflowStage(title: "Platform Checklist", subtitle: "Map future platform requirements.", status: "Protected", systemImage: "checklist.checked"),
            HFRoomWorkflowStage(title: "Handoff Readiness", subtitle: "Review package completeness.", status: "Protected", systemImage: "lock.shield.fill")
        ],
        checklist: [
            HFRoomWorkflowChecklistItem(title: "Poster", detail: "Key art direction is represented for review.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Stills", detail: "Still selections remain local references.", state: "Draft"),
            HFRoomWorkflowChecklistItem(title: "Synopsis", detail: "Short and long copy are ready to inspect.", state: "Ready"),
            HFRoomWorkflowChecklistItem(title: "Credits", detail: "Credit details remain a review item.", state: "Deferred"),
            HFRoomWorkflowChecklistItem(title: "Creator notes", detail: "Creator context carries from launch planning.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Festival packet", detail: "Festival-facing materials are grouped locally.", state: "Preview"),
            HFRoomWorkflowChecklistItem(title: "Platform checklist", detail: "Requirements are static and protected.", state: "Protected")
        ],
        nextStepTitle: "Review Distribution Package",
        nextStepSubtitle: "Check package completeness before real delivery systems are connected.",
        nextStepActionTitle: "Review Handoff Preview"
    )
}

private enum HFRoomWorkflowDrilldownPlans {
    static let watch = HFRoomWorkflowDrilldownPlan(
        title: "Watch Flow Drilldown",
        subtitle: "Choose a consumer stage and preview how it supports the streaming layer.",
        ctaTitle: "Preview Watch Flow",
        stages: [
            HFRoomWorkflowDrilldown(
                title: "Featured",
                subtitle: "Premiere surface",
                status: "Ready",
                detailTitle: "Featured entry",
                detailBody: "Shows how a featured title anchors the first viewer moment before any player surface is involved.",
                checklist: ["Hero title", "Poster rail", "Movie Detail path", "Local preview copy"],
                systemImage: "star.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Continue Watching",
                subtitle: "Return path",
                status: "Preview",
                detailTitle: "Progress return",
                detailBody: "Frames a calm return path for in-progress titles using static viewer context.",
                checklist: ["In-progress title", "Detail route", "Progress label", "Five-tab shell"],
                systemImage: "play.rectangle.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "My List",
                subtitle: "Saved shelf",
                status: "Ready",
                detailTitle: "Saved titles",
                detailBody: "Keeps saved films visible in the consumer library without adding persistence.",
                checklist: ["Saved card", "Library route", "Title metadata", "Local state copy"],
                systemImage: "bookmark.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Downloads",
                subtitle: "Offline-ready shelf",
                status: "Local",
                detailTitle: "Download shelf preview",
                detailBody: "Explains the offline-ready shelf as display-only product structure.",
                checklist: ["Shelf status", "Download label", "Protected boundary", "Static title row"],
                systemImage: "arrow.down.circle.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Discover",
                subtitle: "Search path",
                status: "Preview",
                detailTitle: "Discovery movement",
                detailBody: "Shows how viewers move from a room preview into search and discovery surfaces.",
                checklist: ["Search route", "Discovery rail", "Genre hint", "Viewer-facing copy"],
                systemImage: "magnifyingglass"
            )
        ]
    )

    static let create = HFRoomWorkflowDrilldownPlan(
        title: "Creator Package Drilldown",
        subtitle: "Select a stage to inspect the local package detail before any live studio services exist.",
        ctaTitle: "Preview Selected Stage",
        stages: [
            HFRoomWorkflowDrilldown(
                title: "Project Slate",
                subtitle: "Title foundation",
                status: "Ready",
                detailTitle: "Organize the slate",
                detailBody: "Organize titles, formats, and story packages before building a pitch.",
                checklist: ["Title summary", "Format", "Story package", "Creator note", "Release angle"],
                systemImage: "film.stack.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Story Positioning",
                subtitle: "Audience promise",
                status: "Draft",
                detailTitle: "Clarify the title promise",
                detailBody: "Clarify audience, genre, and promise of the title.",
                checklist: ["Audience promise", "Genre note", "Tone", "Viewer hook", "Comparable space"],
                systemImage: "text.quote"
            ),
            HFRoomWorkflowDrilldown(
                title: "Pitch Package",
                subtitle: "Story and angle",
                status: "Preview",
                detailTitle: "Shape the pitch",
                detailBody: "Prepare the story, creator angle, and release positioning.",
                checklist: ["Logline", "Creator angle", "Pitch notes", "Release angle", "Review copy"],
                systemImage: "rectangle.stack.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Media Kit",
                subtitle: "Materials preview",
                status: "Preview",
                detailTitle: "Preview title materials",
                detailBody: "Preview the materials a title will need later.",
                checklist: ["Poster placeholder", "Still placeholder", "Synopsis", "Credits", "Creator note"],
                systemImage: "photo.stack.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Launch Prep",
                subtitle: "Plan bridge",
                status: "Deferred",
                detailTitle: "Prepare the bridge",
                detailBody: "Connect the project package to the future launch plan.",
                checklist: ["Launch copy", "Audience hook", "Creator note", "Release angle", "Readiness flag"],
                systemImage: "flag.checkered"
            )
        ]
    )

    static let connect = HFRoomWorkflowDrilldownPlan(
        title: "Audience Moment Drilldown",
        subtitle: "Inspect local community stages without connecting live social services.",
        ctaTitle: "Preview Selected Moment",
        stages: [
            HFRoomWorkflowDrilldown(
                title: "Communities",
                subtitle: "Audience groups",
                status: "Preview",
                detailTitle: "Group viewer interest",
                detailBody: "Group viewers around titles, creators, and premieres.",
                checklist: ["Audience group", "Title context", "Creator link", "Premiere prompt", "Room tone"],
                systemImage: "person.3.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Creator Updates",
                subtitle: "Update planning",
                status: "Local",
                detailTitle: "Plan creator moments",
                detailBody: "Plan update moments that keep audiences engaged.",
                checklist: ["Update topic", "Behind-the-scenes angle", "Creator voice", "Release context", "Preview copy"],
                systemImage: "text.bubble.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Reactions",
                subtitle: "Energy preview",
                status: "Preview",
                detailTitle: "Preview audience energy",
                detailBody: "Preview how audience energy may appear around a title.",
                checklist: ["Reaction preview", "Tone signal", "Audience energy", "Title beat", "Local status"],
                systemImage: "heart.text.square.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Following",
                subtitle: "Relationship layer",
                status: "Preview",
                detailTitle: "Show return paths",
                detailBody: "Show the relationship layer without real accounts.",
                checklist: ["Creator follow preview", "Title interest", "Return path", "Local badge", "Safe boundary"],
                systemImage: "person.badge.plus.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Watch Community",
                subtitle: "Content conversation",
                status: "Deferred",
                detailTitle: "Frame the viewing moment",
                detailBody: "Frame conversation around the content itself.",
                checklist: ["Watch conversation angle", "Premiere prompt", "Audience group", "Story beat", "Preview-only label"],
                systemImage: "play.tv.fill"
            )
        ]
    )

    static let launch = HFRoomWorkflowDrilldownPlan(
        title: "Launch Stage Drilldown",
        subtitle: "Choose a release stage and inspect the local premiere planning detail.",
        ctaTitle: "Preview Selected Launch Stage",
        stages: [
            HFRoomWorkflowDrilldown(
                title: "Announcement",
                subtitle: "First public story",
                status: "Draft",
                detailTitle: "Shape the announcement",
                detailBody: "Shape the first public story around the title.",
                checklist: ["Campaign headline", "Title promise", "Creator note", "Poster material", "Audience hook"],
                systemImage: "sparkles"
            ),
            HFRoomWorkflowDrilldown(
                title: "Campaign Preview",
                subtitle: "Copy and materials",
                status: "Preview",
                detailTitle: "Organize the campaign",
                detailBody: "Organize campaign copy and key materials.",
                checklist: ["Campaign headline", "Synopsis", "Poster material", "Creator note", "Readiness flag"],
                systemImage: "megaphone.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Premiere Window",
                subtitle: "Timing context",
                status: "Deferred",
                detailTitle: "Preview timing",
                detailBody: "Preview release timing and premiere context.",
                checklist: ["Premiere date placeholder", "Release window", "Context note", "Audience cue", "Static status"],
                systemImage: "calendar.badge.clock"
            ),
            HFRoomWorkflowDrilldown(
                title: "Audience Build",
                subtitle: "Momentum planning",
                status: "Preview",
                detailTitle: "Prepare momentum",
                detailBody: "Prepare momentum before launch.",
                checklist: ["Audience hook", "Community prompt", "Creator update", "Campaign copy", "Preview signal"],
                systemImage: "person.3.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Release Readiness",
                subtitle: "Future launch fit",
                status: "Ready",
                detailTitle: "Check release fit",
                detailBody: "Confirm the title package is ready for a future live launch system.",
                checklist: ["Readiness flag", "Synopsis", "Poster material", "Creator note", "Campaign review"],
                systemImage: "checkmark.seal.fill"
            )
        ]
    )

    static let export = HFRoomWorkflowDrilldownPlan(
        title: "Package Stage Drilldown",
        subtitle: "Inspect distribution readiness locally before real delivery systems are connected.",
        ctaTitle: "Preview Selected Package Stage",
        stages: [
            HFRoomWorkflowDrilldown(
                title: "Deliverables",
                subtitle: "Materials list",
                status: "Review",
                detailTitle: "Review delivery needs",
                detailBody: "Review the materials a title will need for delivery.",
                checklist: ["Poster", "Stills", "Synopsis", "Credits", "Creator notes"],
                systemImage: "shippingbox.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Media Kit",
                subtitle: "Press package",
                status: "Preview",
                detailTitle: "Preview press materials",
                detailBody: "Preview press and title assets in one package.",
                checklist: ["Poster", "Stills", "Synopsis", "Creator notes", "Press blurb"],
                systemImage: "photo.stack.fill"
            ),
            HFRoomWorkflowDrilldown(
                title: "Festival Package",
                subtitle: "Festival handoff",
                status: "Preview",
                detailTitle: "Organize festival fit",
                detailBody: "Organize a future festival-ready handoff.",
                checklist: ["Festival packet", "Synopsis", "Credits", "Creator notes", "Poster"],
                systemImage: "rosette"
            ),
            HFRoomWorkflowDrilldown(
                title: "Platform Checklist",
                subtitle: "Requirement preview",
                status: "Protected",
                detailTitle: "Preview platform needs",
                detailBody: "Preview requirements before platform submission exists.",
                checklist: ["Platform checklist", "Synopsis", "Credits", "Poster", "Readiness note"],
                systemImage: "checklist.checked"
            ),
            HFRoomWorkflowDrilldown(
                title: "Handoff Readiness",
                subtitle: "Completeness check",
                status: "Protected",
                detailTitle: "Check package completeness",
                detailBody: "Check package completeness before real delivery systems are connected.",
                checklist: ["Package status", "Festival packet", "Platform checklist", "Creator notes", "Handoff preview"],
                systemImage: "lock.shield.fill"
            )
        ]
    )
}

private enum HFCreatorPackageBuilderPreviewData {
    static let package = HFCreatorPackagePreview(
        title: "The Friendly",
        logline: "A warm cinematic story prepared for a HighFive premiere.",
        genre: "Drama / Family / Original",
        audience: "Premium streaming viewers",
        packageStatus: "Preview Package",
        sections: [
            HFCreatorPackageSection(
                title: "Project Identity",
                subtitle: "Define the title, format, and creator foundation.",
                status: "Ready",
                progress: 0.86,
                systemImage: "person.text.rectangle.fill",
                prepares: "Prepares the public title foundation for a local package review.",
                readySummary: "Title, genre, and creator note are ready to inspect.",
                previewSummary: "Runtime remains a preview field for package context.",
                deferredSummary: "Live account connection remains deferred.",
                items: [
                    HFCreatorPackageItem(title: "Title", detail: "The Friendly", state: "Ready"),
                    HFCreatorPackageItem(title: "Logline", detail: "A warm cinematic story prepared for a HighFive premiere.", state: "Ready"),
                    HFCreatorPackageItem(title: "Genre", detail: "Drama / Family / Original", state: "Ready"),
                    HFCreatorPackageItem(title: "Runtime", detail: "Feature-length placeholder", state: "Preview"),
                    HFCreatorPackageItem(title: "Creator note", detail: "Creator context anchors the package tone.", state: "Ready")
                ]
            ),
            HFCreatorPackageSection(
                title: "Story Package",
                subtitle: "Shape the story promise and emotional frame.",
                status: "Ready",
                progress: 0.78,
                systemImage: "doc.text.fill",
                prepares: "Prepares story copy that can support detail, pitch, and launch surfaces.",
                readySummary: "Synopsis and tone are structured for review.",
                previewSummary: "Comparable titles and key moment are preview-only notes.",
                deferredSummary: "No live editorial workflow is connected.",
                items: [
                    HFCreatorPackageItem(title: "Synopsis", detail: "A concise story summary for a premium streaming package.", state: "Ready"),
                    HFCreatorPackageItem(title: "Tone", detail: "Warm, cinematic, hopeful, and grounded.", state: "Ready"),
                    HFCreatorPackageItem(title: "Audience promise", detail: "A family-forward original with emotional momentum.", state: "Draft"),
                    HFCreatorPackageItem(title: "Comparable titles", detail: "Premium originals and festival-friendly drama.", state: "Preview"),
                    HFCreatorPackageItem(title: "Key moment", detail: "A final reveal that reframes the project heart.", state: "Preview")
                ]
            ),
            HFCreatorPackageSection(
                title: "Audience Positioning",
                subtitle: "Clarify who the title is for and how they enter.",
                status: "Draft",
                progress: 0.62,
                systemImage: "person.3.fill",
                prepares: "Prepares the viewer promise, watch mood, and community angle.",
                readySummary: "Primary audience is defined for review.",
                previewSummary: "Community angle and premiere hook remain preview copy.",
                deferredSummary: "Audience systems remain disconnected.",
                items: [
                    HFCreatorPackageItem(title: "Primary audience", detail: "Premium streaming viewers", state: "Ready"),
                    HFCreatorPackageItem(title: "Watch mood", detail: "Warm weekend premiere with family appeal.", state: "Draft"),
                    HFCreatorPackageItem(title: "Community angle", detail: "Creator story and audience reaction moment.", state: "Preview"),
                    HFCreatorPackageItem(title: "Premiere hook", detail: "A heartfelt original made for shared discovery.", state: "Preview")
                ]
            ),
            HFCreatorPackageSection(
                title: "Pitch Materials",
                subtitle: "Turn the package into a clear creative pitch.",
                status: "Preview",
                progress: 0.70,
                systemImage: "text.quote",
                prepares: "Prepares the story angle, creator statement, and release positioning.",
                readySummary: "Pitch headline and story angle are present.",
                previewSummary: "Creator statement and release positioning are preview materials.",
                deferredSummary: "No Publishing action exists in this preview.",
                items: [
                    HFCreatorPackageItem(title: "Pitch headline", detail: "A heartfelt original for HighFive families.", state: "Ready"),
                    HFCreatorPackageItem(title: "Story angle", detail: "Warm drama with creator-led emotional stakes.", state: "Preview"),
                    HFCreatorPackageItem(title: "Creator statement", detail: "A short perspective note frames why this story matters.", state: "Draft"),
                    HFCreatorPackageItem(title: "Release positioning", detail: "Prepared for Watch, Connect, and Launch planning.", state: "Preview")
                ]
            ),
            HFCreatorPackageSection(
                title: "Media Kit Readiness",
                subtitle: "Preview visual and press materials without intake.",
                status: "Deferred",
                progress: 0.42,
                systemImage: "photo.stack.fill",
                prepares: "Prepares the visible materials list before media systems exist.",
                readySummary: "Credits and creator bio have review structure.",
                previewSummary: "Poster and stills remain placeholders.",
                deferredSummary: "Media intake and photo-library access remain deferred.",
                items: [
                    HFCreatorPackageItem(title: "Poster placeholder", detail: "Key art slot is present for package review.", state: "Preview"),
                    HFCreatorPackageItem(title: "Stills placeholder", detail: "Still selections are represented as local planning rows.", state: "Preview"),
                    HFCreatorPackageItem(title: "Credits", detail: "Credit line review is tracked.", state: "Draft"),
                    HFCreatorPackageItem(title: "Press copy", detail: "Short press blurb is planned.", state: "Deferred"),
                    HFCreatorPackageItem(title: "Creator bio", detail: "Creator profile copy supports the media kit.", state: "Ready")
                ]
            ),
            HFCreatorPackageSection(
                title: "Launch Prep",
                subtitle: "Bridge the package into premiere planning.",
                status: "Preview",
                progress: 0.58,
                systemImage: "flag.checkered",
                prepares: "Prepares the launch-facing story without live release systems.",
                readySummary: "Campaign headline is drafted for review.",
                previewSummary: "Premiere window and release materials are preview-only.",
                deferredSummary: "Notifications, commerce, and campaign Publishing remain disconnected.",
                items: [
                    HFCreatorPackageItem(title: "Campaign headline", detail: "The Friendly arrives as a warm HighFive original.", state: "Draft"),
                    HFCreatorPackageItem(title: "Premiere window", detail: "Local placeholder for release timing.", state: "Preview"),
                    HFCreatorPackageItem(title: "Release materials", detail: "Story, poster, and creator notes are grouped.", state: "Preview"),
                    HFCreatorPackageItem(title: "Launch checklist", detail: "Readiness remains local and manual.", state: "Preview")
                ]
            )
        ],
        readiness: [
            HFCreatorPackageReadinessRow(title: "Story Foundation", status: "Ready", detail: "Identity, logline, and synopsis are reviewable."),
            HFCreatorPackageReadinessRow(title: "Audience Positioning", status: "Draft", detail: "Audience promise and watch mood need polish."),
            HFCreatorPackageReadinessRow(title: "Pitch Materials", status: "Preview", detail: "Pitch copy is present for local inspection."),
            HFCreatorPackageReadinessRow(title: "Media Kit", status: "Deferred", detail: "Visual materials remain placeholders."),
            HFCreatorPackageReadinessRow(title: "Launch Prep", status: "Preview", detail: "Campaign copy is framed for future planning."),
            HFCreatorPackageReadinessRow(title: "Export / Render", status: "Protected", detail: "Professional systems remain disconnected.")
        ]
    )
}

private enum HFCreatorStudioSlatePreviewData {
    static let slate = HFCreatorSlatePreview(
        title: "Studio Slate",
        subtitle: "Organize title packages before media intake, accounts, documents, package production, delivery, or server systems are connected.",
        activeProjectCount: 3,
        readyPackageCount: 1,
        draftPackageCount: 2,
        protectedSystemCount: 4,
        projects: [
            HFCreatorSlateProject(
                title: "The Friendly",
                format: "Feature Film",
                genre: "Drama / Family",
                status: "Package Ready",
                logline: "A warm cinematic story prepared for a HighFive premiere.",
                audience: "Premium streaming viewers",
                packageProgress: 0.84,
                systemImage: "film.fill",
                materials: [
                    HFCreatorSlateMaterial(title: "Title synopsis", detail: "Story foundation is ready for package review.", state: "Ready", systemImage: "doc.text.fill"),
                    HFCreatorSlateMaterial(title: "Audience promise", detail: "Family-forward streaming promise is defined.", state: "Ready", systemImage: "person.3.fill"),
                    HFCreatorSlateMaterial(title: "Poster / stills placeholder", detail: "Visual slots are present as local planning rows.", state: "Draft", systemImage: "photo.stack.fill"),
                    HFCreatorSlateMaterial(title: "Creator note", detail: "Creator intent is framed for package context.", state: "Preview", systemImage: "note.text"),
                    HFCreatorSlateMaterial(title: "Launch angle", detail: "Warm premiere positioning connects to Launch planning.", state: "Preview", systemImage: "flag.checkered"),
                    HFCreatorSlateMaterial(title: "Delivery handoff", detail: "Professional delivery remains protected planning copy.", state: "Protected", systemImage: "lock.shield.fill")
                ]
            ),
            HFCreatorSlateProject(
                title: "Midnight Borough",
                format: "Limited Series",
                genre: "Mystery / Thriller",
                status: "Pitch Draft",
                logline: "A moody city mystery shaped for episodic release.",
                audience: "Late-night discovery viewers",
                packageProgress: 0.56,
                systemImage: "building.2.crop.circle.fill",
                materials: [
                    HFCreatorSlateMaterial(title: "Series premise", detail: "Core mystery frame is being shaped.", state: "Draft", systemImage: "doc.text.magnifyingglass"),
                    HFCreatorSlateMaterial(title: "Audience hook", detail: "Late-night discovery angle is ready for review.", state: "Preview", systemImage: "moon.stars.fill"),
                    HFCreatorSlateMaterial(title: "Episode slate", detail: "Episode arc rows remain local package notes.", state: "Draft", systemImage: "rectangle.stack.fill"),
                    HFCreatorSlateMaterial(title: "Pitch statement", detail: "Creator-led statement needs one more pass.", state: "Draft", systemImage: "text.quote"),
                    HFCreatorSlateMaterial(title: "Launch angle", detail: "Release direction is held for future planning.", state: "Deferred", systemImage: "flag")
                ]
            ),
            HFCreatorSlateProject(
                title: "Golden Hour Kids",
                format: "Short Collection",
                genre: "Family / Adventure",
                status: "Media Kit Draft",
                logline: "A bright family collection prepared for creator-led launch.",
                audience: "Family watch-night viewers",
                packageProgress: 0.64,
                systemImage: "sun.max.fill",
                materials: [
                    HFCreatorSlateMaterial(title: "Collection summary", detail: "Short-form story grouping is in draft shape.", state: "Draft", systemImage: "square.grid.2x2.fill"),
                    HFCreatorSlateMaterial(title: "Family audience promise", detail: "Watch-night positioning is ready to inspect.", state: "Preview", systemImage: "person.2.fill"),
                    HFCreatorSlateMaterial(title: "Media kit notes", detail: "Visual and copy needs are tracked locally.", state: "Draft", systemImage: "photo.on.rectangle.angled"),
                    HFCreatorSlateMaterial(title: "Creator statement", detail: "Creator voice is framed for the collection.", state: "Preview", systemImage: "person.text.rectangle.fill"),
                    HFCreatorSlateMaterial(title: "Release angle", detail: "Campaign direction stays future-facing.", state: "Deferred", systemImage: "sparkles")
                ]
            )
        ]
    )
}

private enum HFConnectAudiencePlannerPreviewData {
    static let plan = HFConnectAudiencePreview(
        title: "Audience Planner",
        subtitle: "Plan audience moments around a title before Messaging, Accounts, Notifications, Analytics, or Backend systems are connected.",
        focusTitle: "The Friendly Audience Plan",
        audienceTone: "Warm, premium, family-forward",
        plannerStatus: "Preview Plan",
        sections: [
            HFConnectPlannerSection(
                title: "Audience Groups",
                subtitle: "Map who gathers around the premiere.",
                status: "Preview",
                systemImage: "person.3.fill",
                prepares: "Prepares the viewer groups that can gather around a title in local planning.",
                previewSummary: "Audience grouping is visible as static planning copy.",
                deferredSummary: "Accounts and live relationship systems remain disconnected.",
                prompts: [
                    HFConnectPlannerPrompt(title: "Premiere viewers", detail: "Viewers arriving for the first release moment.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Family audience", detail: "Warm family-forward audience fit.", state: "Ready"),
                    HFConnectPlannerPrompt(title: "Creator supporters", detail: "People following the creator story in preview copy.", state: "Draft"),
                    HFConnectPlannerPrompt(title: "Genre fans", detail: "Drama and original-story viewers.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Saved-title viewers", detail: "People who saved the title in the local shell.", state: "Local")
                ]
            ),
            HFConnectPlannerSection(
                title: "Creator Updates",
                subtitle: "Plan creator-led moments before release.",
                status: "Draft",
                systemImage: "text.bubble.fill",
                prepares: "Prepares update themes and creator voice for local audience review.",
                previewSummary: "Update copy is drafted without posting or delivery.",
                deferredSummary: "Live posting and Notifications remain disconnected.",
                prompts: [
                    HFConnectPlannerPrompt(title: "Behind-the-scenes note", detail: "A warm creator note about the title origin.", state: "Draft"),
                    HFConnectPlannerPrompt(title: "Production journal", detail: "A short production memory for the room.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Premiere reminder copy", detail: "Static wording for a future release reminder.", state: "Deferred"),
                    HFConnectPlannerPrompt(title: "Creator voice", detail: "Grounded, optimistic, and premium.", state: "Ready"),
                    HFConnectPlannerPrompt(title: "Update theme", detail: "The story behind the premiere moment.", state: "Draft")
                ]
            ),
            HFConnectPlannerSection(
                title: "Reaction Moments",
                subtitle: "Shape local response cues around the title.",
                status: "Local",
                systemImage: "heart.text.square.fill",
                prepares: "Prepares static reaction cues that show how audience energy might feel.",
                previewSummary: "Reactions are local labels and do not record behavior.",
                deferredSummary: "Analytics and Tracking remain protected.",
                prompts: [
                    HFConnectPlannerPrompt(title: "Warm reaction", detail: "A family-forward response cue.", state: "Local"),
                    HFConnectPlannerPrompt(title: "Favorite scene", detail: "A prompt for the strongest story beat.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Premiere response", detail: "A local release-week response idea.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Community highlight", detail: "A future highlight slot, not a live feed.", state: "Deferred"),
                    HFConnectPlannerPrompt(title: "Watch mood", detail: "Hopeful, comfortable, and shared.", state: "Ready")
                ]
            ),
            HFConnectPlannerSection(
                title: "Watch Community Prompts",
                subtitle: "Frame conversation around the content itself.",
                status: "Preview",
                systemImage: "play.tv.fill",
                prepares: "Prepares content-centered prompts that can guide future room design.",
                previewSummary: "Prompt rows are static and local.",
                deferredSummary: "Chat and Comments remain disconnected.",
                prompts: [
                    HFConnectPlannerPrompt(title: "What moment stayed with you?", detail: "A reflective prompt for the title heart.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Who would you watch this with?", detail: "A family and friends viewing cue.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "What scene should others notice?", detail: "A discovery-oriented room prompt.", state: "Draft"),
                    HFConnectPlannerPrompt(title: "Why this title tonight?", detail: "A simple watch-mood prompt.", state: "Local")
                ]
            ),
            HFConnectPlannerSection(
                title: "Premiere Conversation",
                subtitle: "Prepare the release-week audience frame.",
                status: "Preview",
                systemImage: "flag.checkered",
                prepares: "Prepares a premiere conversation plan without live participation.",
                previewSummary: "The release-week topic and creator note are visible locally.",
                deferredSummary: "Watch-party systems remain placeholders only.",
                prompts: [
                    HFConnectPlannerPrompt(title: "Premiere topic", detail: "Why this story matters on release night.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Audience prompt", detail: "A simple prompt for shared viewing context.", state: "Draft"),
                    HFConnectPlannerPrompt(title: "Creator note", detail: "A warm note from the project perspective.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Watch-party placeholder", detail: "A non-live planning slot.", state: "Deferred"),
                    HFConnectPlannerPrompt(title: "Post-premiere reflection", detail: "A local reflection idea for later review.", state: "Preview")
                ]
            ),
            HFConnectPlannerSection(
                title: "Community Readiness",
                subtitle: "Check local community planning before live systems exist.",
                status: "Protected",
                systemImage: "checkmark.shield.fill",
                prepares: "Prepares a safety-aware review of Connect planning content.",
                previewSummary: "Update copy, prompts, and creator notes can be reviewed.",
                deferredSummary: "Messaging, Comments, Notifications, Analytics, Social Graph, and Backend systems stay disconnected.",
                prompts: [
                    HFConnectPlannerPrompt(title: "Update copy", detail: "Creator update wording is available for review.", state: "Draft"),
                    HFConnectPlannerPrompt(title: "Audience prompt", detail: "Audience-facing prompts are grouped locally.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Creator note", detail: "Creator context supports the community moment.", state: "Preview"),
                    HFConnectPlannerPrompt(title: "Community angle", detail: "Warm, premium, and title-centered.", state: "Ready"),
                    HFConnectPlannerPrompt(title: "Safety boundary", detail: "Live systems remain disconnected.", state: "Protected")
                ]
            )
        ],
        readiness: [
            HFConnectReadinessRow(title: "Community Plan", status: "Preview", detail: "Audience groups and release framing are visible."),
            HFConnectReadinessRow(title: "Creator Updates", status: "Draft", detail: "Creator voice and update theme need review."),
            HFConnectReadinessRow(title: "Reaction Prompts", status: "Local", detail: "Response cues remain local static labels."),
            HFConnectReadinessRow(title: "Premiere Conversation", status: "Preview", detail: "Release-week prompt planning is present."),
            HFConnectReadinessRow(title: "Messaging / Comments", status: "Deferred", detail: "Live participation systems are not connected."),
            HFConnectReadinessRow(title: "Analytics / Social Graph", status: "Protected", detail: "Measurement and relationship systems remain protected.")
        ]
    )
}

private enum HFLaunchCampaignPlannerPreviewData {
    static let campaign = HFLaunchCampaignPreview(
        title: "Campaign Planner",
        subtitle: "Plan a premiere campaign before Payments, Waitlists, Notifications, Analytics, or Backend Publishing are connected.",
        campaignFocus: "Warm premiere push for a HighFive Original",
        releaseWindow: "Preview premiere window",
        audienceTone: "Family-forward, cinematic, premium",
        plannerStatus: "Preview Campaign",
        sections: [
            HFLaunchPlannerSection(
                title: "Campaign Identity",
                subtitle: "Frame the public story before release.",
                status: "Preview",
                systemImage: "megaphone.fill",
                prepares: "Prepares the headline, title hook, creator note, and release promise.",
                previewSummary: "Identity copy is visible locally for review.",
                deferredSummary: "Backend Publishing and commerce systems remain disconnected.",
                items: [
                    HFLaunchPlannerItem(title: "Campaign headline", detail: "The Friendly arrives as a warm HighFive Original.", state: "Draft"),
                    HFLaunchPlannerItem(title: "Release promise", detail: "A cinematic family-forward premiere with creator heart.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Creator note", detail: "A short creator perspective anchors the public story.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Title hook", detail: "An original story made for shared discovery.", state: "Ready"),
                    HFLaunchPlannerItem(title: "Tone", detail: "Warm, premium, hopeful, and cinematic.", state: "Ready")
                ]
            ),
            HFLaunchPlannerSection(
                title: "Premiere Timeline",
                subtitle: "Sequence the release moment from announcement to opening night.",
                status: "Draft",
                systemImage: "calendar.badge.clock",
                prepares: "Prepares release pacing and premiere context for local review.",
                previewSummary: "Timeline rows are planning copy only.",
                deferredSummary: "Notifications and live scheduling remain disconnected.",
                items: [
                    HFLaunchPlannerItem(title: "Announcement", detail: "Introduce the title and release promise.", state: "Draft"),
                    HFLaunchPlannerItem(title: "Trailer window", detail: "Preview the timing around trailer positioning.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Premiere week", detail: "Frame the title as a featured HighFive moment.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Opening night", detail: "Local launch-night copy for the room.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Post-release push", detail: "Prepare follow-up discovery copy.", state: "Deferred")
                ]
            ),
            HFLaunchPlannerSection(
                title: "Audience Build",
                subtitle: "Prepare audience energy before the premiere.",
                status: "Local",
                systemImage: "person.3.fill",
                prepares: "Prepares interest cues and community handoff copy for local launch planning.",
                previewSummary: "Audience momentum is represented as static preview language.",
                deferredSummary: "Accounts, Notifications, and Analytics stay disconnected.",
                items: [
                    HFLaunchPlannerItem(title: "Early interest", detail: "Warm audience intent around the premiere.", state: "Local"),
                    HFLaunchPlannerItem(title: "Creator update", detail: "Creator-facing launch note for Connect handoff.", state: "Draft"),
                    HFLaunchPlannerItem(title: "Community prompt", detail: "A title-centered audience prompt.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Watch reminder", detail: "Preview wording for a future release reminder.", state: "Deferred"),
                    HFLaunchPlannerItem(title: "Premiere conversation", detail: "Connect Room context supports launch week.", state: "Preview")
                ]
            ),
            HFLaunchPlannerSection(
                title: "Launch Materials",
                subtitle: "Review public copy and visual readiness.",
                status: "Preview",
                systemImage: "photo.stack.fill",
                prepares: "Prepares the visible material checklist that supports launch presentation.",
                previewSummary: "Poster, synopsis, and release copy are reviewable as static rows.",
                deferredSummary: "Asset intake and live publishing stay disconnected.",
                items: [
                    HFLaunchPlannerItem(title: "Poster", detail: "Key art direction anchors the release surface.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Synopsis", detail: "Short story copy supports the campaign frame.", state: "Ready"),
                    HFLaunchPlannerItem(title: "Creator quote", detail: "Creator voice strengthens launch positioning.", state: "Draft"),
                    HFLaunchPlannerItem(title: "Stills", detail: "Still references remain placeholders.", state: "Deferred"),
                    HFLaunchPlannerItem(title: "Release copy", detail: "Public copy is ready for local review.", state: "Preview")
                ]
            ),
            HFLaunchPlannerSection(
                title: "Release Checklist",
                subtitle: "Check title page and campaign copy readiness.",
                status: "Preview",
                systemImage: "checklist.checked",
                prepares: "Prepares the manual checklist for a future live release system.",
                previewSummary: "Title page, copy, and creator note rows are present.",
                deferredSummary: "Payments, Tickets, and Waitlists remain disconnected.",
                items: [
                    HFLaunchPlannerItem(title: "Title page", detail: "Streaming-facing title presentation is ready to inspect.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Campaign copy", detail: "Launch headline and release promise are grouped.", state: "Draft"),
                    HFLaunchPlannerItem(title: "Creator note", detail: "Creator perspective supports the premiere frame.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Premiere date placeholder", detail: "Timing remains local placeholder copy.", state: "Deferred"),
                    HFLaunchPlannerItem(title: "Materials review", detail: "Launch assets are organized for preview.", state: "Preview")
                ]
            ),
            HFLaunchPlannerSection(
                title: "Launch Readiness",
                subtitle: "Review the plan before live systems exist.",
                status: "Protected",
                systemImage: "checkmark.shield.fill",
                prepares: "Prepares a safety-aware readiness check across campaign, timeline, audience, and materials.",
                previewSummary: "Planner content can be inspected without Publishing.",
                deferredSummary: "Commerce, store services, audience reminders, measurement, and server systems stay disconnected.",
                items: [
                    HFLaunchPlannerItem(title: "Campaign preview", detail: "Campaign plan is visible locally.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Timeline review", detail: "Premiere timing is a draft plan.", state: "Draft"),
                    HFLaunchPlannerItem(title: "Audience plan", detail: "Audience buildup remains local.", state: "Local"),
                    HFLaunchPlannerItem(title: "Materials status", detail: "Public materials are reviewable.", state: "Preview"),
                    HFLaunchPlannerItem(title: "Safety boundary", detail: "Live systems remain disconnected.", state: "Protected")
                ]
            )
        ],
        readiness: [
            HFLaunchPlannerReadinessRow(title: "Campaign Plan", status: "Preview", detail: "Campaign identity and release promise are visible."),
            HFLaunchPlannerReadinessRow(title: "Premiere Timeline", status: "Draft", detail: "Release pacing is planned as local copy."),
            HFLaunchPlannerReadinessRow(title: "Launch Materials", status: "Preview", detail: "Poster, synopsis, and release copy are grouped."),
            HFLaunchPlannerReadinessRow(title: "Audience Build", status: "Local", detail: "Audience momentum remains static and local."),
            HFLaunchPlannerReadinessRow(title: "Payments / Tickets", status: "Deferred", detail: "Commerce and access systems are not connected."),
            HFLaunchPlannerReadinessRow(title: "Notifications / Analytics", status: "Protected", detail: "Live delivery and measurement systems remain protected.")
        ]
    )
}

private enum HFExportDistributionPackagePreviewData {
    static let package = HFExportDistributionPreview(
        title: "Distribution Package",
        subtitle: "Prepare a title handoff before File, Render, Export, Share, Platform, or server delivery systems are connected.",
        packageFocus: "Professional handoff package for festivals, press, and future platform delivery",
        deliveryWindow: "Preview handoff window",
        packageTone: "Studio-ready, organized, premium",
        plannerStatus: "Preview Package",
        sections: [
            HFExportPackageSection(
                title: "Distribution Package",
                subtitle: "Frame the professional handoff package.",
                status: "Preview",
                systemImage: "shippingbox.fill",
                prepares: "Prepares the package title, purpose, tone, and review notes.",
                previewSummary: "Package framing is visible as local planning content.",
                deferredSummary: "Delivery systems and professional output remain disconnected.",
                items: [
                    HFExportPackageItem(title: "Package title", detail: "The Friendly Distribution Package", state: "Preview"),
                    HFExportPackageItem(title: "Handoff purpose", detail: "Prepared for festivals, press, and future platform delivery.", state: "Ready"),
                    HFExportPackageItem(title: "Delivery tone", detail: "Studio-ready, organized, premium.", state: "Ready"),
                    HFExportPackageItem(title: "Review status", detail: "Local package review before professional systems exist.", state: "Draft"),
                    HFExportPackageItem(title: "Package notes", detail: "Notes remain static and review-only.", state: "Preview")
                ]
            ),
            HFExportPackageSection(
                title: "Deliverables",
                subtitle: "Organize the required title materials.",
                status: "Draft",
                systemImage: "tray.full.fill",
                prepares: "Prepares core materials expected in a professional handoff.",
                previewSummary: "Poster, stills, synopsis, credits, and creator notes are checklist rows.",
                deferredSummary: "Generated packages and system handoff remain disconnected.",
                items: [
                    HFExportPackageItem(title: "Poster", detail: "Key art direction anchors the package.", state: "Preview"),
                    HFExportPackageItem(title: "Stills", detail: "Still selections remain placeholders.", state: "Draft"),
                    HFExportPackageItem(title: "Synopsis", detail: "Short and long story copy support review.", state: "Ready"),
                    HFExportPackageItem(title: "Credits", detail: "Credit package is tracked for review.", state: "Draft"),
                    HFExportPackageItem(title: "Creator notes", detail: "Creator perspective travels with the package.", state: "Preview")
                ]
            ),
            HFExportPackageSection(
                title: "Media Kit",
                subtitle: "Prepare press and public materials.",
                status: "Preview",
                systemImage: "photo.stack.fill",
                prepares: "Prepares the press-facing language and visual readiness list.",
                previewSummary: "Media kit rows are static review fields.",
                deferredSummary: "Media intake and library access stay disconnected.",
                items: [
                    HFExportPackageItem(title: "Press copy", detail: "Public story copy is framed for review.", state: "Preview"),
                    HFExportPackageItem(title: "Creator bio", detail: "Creator background supports press context.", state: "Draft"),
                    HFExportPackageItem(title: "Title description", detail: "Description supports festival and platform review.", state: "Ready"),
                    HFExportPackageItem(title: "Visual materials", detail: "Poster and stills are represented as placeholders.", state: "Preview"),
                    HFExportPackageItem(title: "Release language", detail: "Launch copy carries into handoff planning.", state: "Preview")
                ]
            ),
            HFExportPackageSection(
                title: "Festival Package",
                subtitle: "Preview festival-ready handoff materials.",
                status: "Local",
                systemImage: "rosette",
                prepares: "Prepares festival-facing story, credits, statement, and notes.",
                previewSummary: "Festival package content is local and static.",
                deferredSummary: "Submission forms, accounts, and delivery pipes remain disconnected.",
                items: [
                    HFExportPackageItem(title: "Festival synopsis", detail: "Festival-facing story copy is available.", state: "Preview"),
                    HFExportPackageItem(title: "Director statement", detail: "Statement slot is ready for review.", state: "Draft"),
                    HFExportPackageItem(title: "Credits", detail: "Credit review supports festival readiness.", state: "Draft"),
                    HFExportPackageItem(title: "Screener placeholder", detail: "Placeholder only; no playback or delivery system.", state: "Deferred"),
                    HFExportPackageItem(title: "Submission notes", detail: "Notes stay local for future planning.", state: "Local")
                ]
            ),
            HFExportPackageSection(
                title: "Platform Checklist",
                subtitle: "Review future platform requirements.",
                status: "Preview",
                systemImage: "checklist.checked",
                prepares: "Prepares platform-facing metadata and requirement notes.",
                previewSummary: "Checklist content is visible without live delivery.",
                deferredSummary: "Platform services and distributor handoff remain disconnected.",
                items: [
                    HFExportPackageItem(title: "Title metadata", detail: "Title, genre, runtime, and description fields are represented.", state: "Preview"),
                    HFExportPackageItem(title: "Artwork set", detail: "Poster and backdrop readiness are tracked.", state: "Draft"),
                    HFExportPackageItem(title: "Runtime", detail: "Runtime is a review placeholder.", state: "Deferred"),
                    HFExportPackageItem(title: "Rating / advisory", detail: "Advisory copy can be planned locally.", state: "Preview"),
                    HFExportPackageItem(title: "Platform notes", detail: "Requirement notes remain static.", state: "Preview")
                ]
            ),
            HFExportPackageSection(
                title: "Handoff Readiness",
                subtitle: "Check package completeness safely.",
                status: "Protected",
                systemImage: "checkmark.shield.fill",
                prepares: "Prepares a safety-aware package review before professional systems exist.",
                previewSummary: "Package review, missing items, and delivery summary are visible.",
                deferredSummary: "File handling, sharing, Render Engines, Export Engines, platform delivery, and server submissions remain disconnected.",
                items: [
                    HFExportPackageItem(title: "Package review", detail: "Distribution package is ready for local inspection.", state: "Preview"),
                    HFExportPackageItem(title: "Missing items", detail: "Incomplete materials are represented as checklist rows.", state: "Draft"),
                    HFExportPackageItem(title: "Deferred systems", detail: "Professional output systems remain off.", state: "Deferred"),
                    HFExportPackageItem(title: "Protected exports", detail: "Export and Render engines stay protected.", state: "Protected"),
                    HFExportPackageItem(title: "Delivery summary", detail: "Handoff summary remains preview-only.", state: "Preview")
                ]
            )
        ],
        readiness: [
            HFExportPackageReadinessRow(title: "Deliverables", status: "Draft", detail: "Poster, stills, synopsis, credits, and notes need review."),
            HFExportPackageReadinessRow(title: "Media Kit", status: "Preview", detail: "Press and title materials are represented locally."),
            HFExportPackageReadinessRow(title: "Festival Package", status: "Local", detail: "Festival package content is static and reviewable."),
            HFExportPackageReadinessRow(title: "Platform Checklist", status: "Preview", detail: "Platform requirements are visible without delivery."),
            HFExportPackageReadinessRow(title: "File / Share Systems", status: "Deferred", detail: "Document and system handoff surfaces are disconnected."),
            HFExportPackageReadinessRow(title: "Render / Export Engines", status: "Protected", detail: "Professional output engines remain protected.")
        ]
    )
}

private enum HFWatchViewingHubPreviewData {
    static let hub = HFWatchViewingHubPreview(
        title: "Viewing Hub",
        subtitle: "Preview the premium watching path before Player systems, accounts, measurement, offline delivery, or sync systems are connected.",
        viewingFocus: "Featured premiere, saved titles, offline shelf, and discovery path",
        tonightPick: "The Friendly",
        hubStatus: "Preview Hub",
        sections: [
            HFWatchHubSection(
                title: "Featured Premiere",
                subtitle: "Anchor tonight around a premium title.",
                status: "Ready",
                systemImage: "star.fill",
                prepares: "Prepares the first viewing moment with a featured title and editorial reason.",
                previewSummary: "The featured premiere card is local and static.",
                deferredSummary: "Player systems and server streaming remain disconnected.",
                items: [
                    HFWatchHubItem(title: "Tonight pick", detail: "The Friendly", state: "Ready"),
                    HFWatchHubItem(title: "Hero title", detail: "A warm HighFive premiere placed at the center of Watch Room.", state: "Ready"),
                    HFWatchHubItem(title: "Streaming mood", detail: "Premium, family-forward, cinematic evening viewing.", state: "Preview"),
                    HFWatchHubItem(title: "Editorial reason", detail: "A featured original with creator-led story momentum.", state: "Ready"),
                    HFWatchHubItem(title: "Primary action preview", detail: "Safe local viewing action copy only.", state: "Preview")
                ]
            ),
            HFWatchHubSection(
                title: "Continue Watching",
                subtitle: "Represent viewing momentum without real viewing state.",
                status: "Local",
                systemImage: "play.rectangle.fill",
                prepares: "Prepares the resume lane and next-up context for a premium watch hub.",
                previewSummary: "Progress and resume context are local display rows.",
                deferredSummary: "Player state, account sync, and measurement remain disconnected.",
                items: [
                    HFWatchHubItem(title: "In-progress title", detail: "Neon Canyon", state: "Local"),
                    HFWatchHubItem(title: "Progress preview", detail: "48 percent preview progress.", state: "Preview"),
                    HFWatchHubItem(title: "Next scene copy", detail: "Return to the canyon reveal.", state: "Local"),
                    HFWatchHubItem(title: "Resume context", detail: "A premium continuation cue without real viewing state.", state: "Preview"),
                    HFWatchHubItem(title: "Local state only", detail: "No account sync or player state is connected.", state: "Protected")
                ]
            ),
            HFWatchHubSection(
                title: "My List",
                subtitle: "Preview the saved-title shelf inside Watch Room.",
                status: "Preview",
                systemImage: "bookmark.fill",
                prepares: "Prepares saved-title priority and mood for the local viewing hub.",
                previewSummary: "Saved shelf rows are static product copy.",
                deferredSummary: "Account storage and server sync remain disconnected.",
                items: [
                    HFWatchHubItem(title: "Saved title", detail: "Midnight Orchard", state: "Preview"),
                    HFWatchHubItem(title: "Watch mood", detail: "Festival night, quiet drama, cinematic discovery.", state: "Ready"),
                    HFWatchHubItem(title: "Title priority", detail: "High priority preview slot.", state: "Preview"),
                    HFWatchHubItem(title: "Queue preview", detail: "Saved queue appears as a local shelf concept.", state: "Local"),
                    HFWatchHubItem(title: "Saved shelf", detail: "Library path remains the real tab destination.", state: "Ready")
                ]
            ),
            HFWatchHubSection(
                title: "Offline Shelf",
                subtitle: "Show offline intent without real download behavior.",
                status: "Deferred",
                systemImage: "arrow.down.circle.fill",
                prepares: "Prepares the offline-ready shelf concept for consumer planning.",
                previewSummary: "Offline rows are preview labels only.",
                deferredSummary: "Real offline delivery and storage systems remain disconnected.",
                items: [
                    HFWatchHubItem(title: "Offline-ready preview", detail: "A future shelf for saved viewing access.", state: "Preview"),
                    HFWatchHubItem(title: "Download shelf concept", detail: "A display-only shelf connected to the Downloads tab.", state: "Deferred"),
                    HFWatchHubItem(title: "Storage card concept", detail: "Storage state is represented as copy only.", state: "Deferred"),
                    HFWatchHubItem(title: "Available offline copy", detail: "Preview wording for future offline access.", state: "Preview"),
                    HFWatchHubItem(title: "Deferred real downloads", detail: "Offline delivery remains disconnected.", state: "Protected")
                ]
            ),
            HFWatchHubSection(
                title: "Discovery Path",
                subtitle: "Guide the next title after tonight's premiere.",
                status: "Ready",
                systemImage: "magnifyingglass",
                prepares: "Prepares a streaming-first discovery lane that points to Search and Home.",
                previewSummary: "Recommendations are local editorial rows.",
                deferredSummary: "Measurement and personalization services remain disconnected.",
                items: [
                    HFWatchHubItem(title: "HighFive Picks", detail: "Premium picks are framed as local editorial rails.", state: "Ready"),
                    HFWatchHubItem(title: "Originals", detail: "Original titles support the premium streaming position.", state: "Preview"),
                    HFWatchHubItem(title: "Trending", detail: "Trending copy remains static.", state: "Local"),
                    HFWatchHubItem(title: "Because you watched", detail: "A local recommendation label only.", state: "Preview"),
                    HFWatchHubItem(title: "Coming soon", detail: "Future titles can be framed without live services.", state: "Preview")
                ]
            ),
            HFWatchHubSection(
                title: "Viewing Readiness",
                subtitle: "Check the local viewing hub before live systems exist.",
                status: "Protected",
                systemImage: "checkmark.shield.fill",
                prepares: "Prepares a safety-aware viewing readiness check across Watch Room surfaces.",
                previewSummary: "Featured, list, offline, and discovery states are reviewable.",
                deferredSummary: "Player systems, offline delivery, sync, and measurement remain disconnected.",
                items: [
                    HFWatchHubItem(title: "Featured ready", detail: "Featured premiere is ready for local review.", state: "Ready"),
                    HFWatchHubItem(title: "List ready", detail: "Saved-title shelf has preview content.", state: "Preview"),
                    HFWatchHubItem(title: "Offline preview", detail: "Offline shelf remains concept-only.", state: "Deferred"),
                    HFWatchHubItem(title: "Discovery ready", detail: "Discovery path points to consumer tabs.", state: "Ready"),
                    HFWatchHubItem(title: "Protected playback", detail: "Player systems remain disconnected.", state: "Protected")
                ]
            )
        ],
        readiness: [
            HFWatchHubReadinessRow(title: "Featured Premiere", status: "Ready", detail: "Tonight pick and editorial reason are present."),
            HFWatchHubReadinessRow(title: "Continue Watching", status: "Local", detail: "Resume context is local display copy."),
            HFWatchHubReadinessRow(title: "My List", status: "Preview", detail: "Saved-title shelf is represented in the hub."),
            HFWatchHubReadinessRow(title: "Offline Shelf", status: "Deferred", detail: "Offline delivery remains concept-only."),
            HFWatchHubReadinessRow(title: "Playback / Player", status: "Protected", detail: "Viewing engines remain disconnected."),
            HFWatchHubReadinessRow(title: "Analytics / Sync", status: "Protected", detail: "Measurement and sync systems remain disconnected.")
        ]
    )
}

private struct HFWatchViewingHubSection: View {
    let hub: HFWatchViewingHubPreview
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFWatchHubSection {
        guard hub.sections.indices.contains(selectedSectionIndex) else {
            return hub.sections[0]
        }
        return hub.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFWatchViewingHeroCard(hub: hub, accent: accent)

            HFWatchViewingSectionSelector(
                sections: hub.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFWatchViewingDetailPanel(section: selectedSection, accent: accent)
            HFWatchViewingReadinessSummary(rows: hub.readiness, accent: accent)
            HFWatchViewingBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Viewing Hub, local premium watch preview.")
        .accessibilityIdentifier("hf.room.watch.viewingHub")
    }
}

private struct HFWatchViewingHeroCard: View {
    let hub: HFWatchViewingHubPreview
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "play.rectangle.on.rectangle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Viewing Hub", accent: accent)
                        Text("Viewing Hub")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(hub.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("The Friendly Viewing Hub")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: hub.hubStatus, accent: accent)
                    }

                    Text(hub.viewingFocus)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFWatchViewingMetric(title: "Tonight", value: hub.tonightPick, accent: accent)
                        HFWatchViewingMetric(title: "Featured", value: "Ready", accent: accent)
                        HFWatchViewingMetric(title: "Continue", value: "Local", accent: accent)
                        HFWatchViewingMetric(title: "My List", value: "Preview", accent: accent)
                        HFWatchViewingMetric(title: "Offline", value: "Deferred", accent: accent)
                        HFWatchViewingMetric(title: "Player", value: "Protected", accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Viewing Hub, local premium watch preview. The Friendly Viewing Hub, \(hub.hubStatus)")
        .accessibilityIdentifier("hf.room.watch.viewingHero")
    }
}

private struct HFWatchViewingMetric: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
            Text(value)
                .font(HFTypography.caption)
                .foregroundStyle(title == "Tonight" ? HFColors.textSecondary : accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFWatchViewingSectionSelector: View {
    let sections: [HFWatchHubSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Viewing Sections")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Local Selection", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        Button {
                            selectedSectionIndex = index
                        } label: {
                            HFWatchViewingSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Viewing sections for local premium watch preview")
        .accessibilityIdentifier("hf.room.watch.viewingSections")
    }
}

private struct HFWatchViewingSectionCard: View {
    let section: HFWatchHubSection
    let isSelected: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: section.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isSelected ? .black : accent)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? Color.black.opacity(0.10) : accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: section.status, accent: isSelected ? .black : accent)
                }
            }

            Text(section.subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .black.opacity(0.72) : HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(Array(section.items.prefix(3))) { item in
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isSelected ? .black : accent)
                            .padding(.top, 2)
                        Text(item.title)
                            .font(HFTypography.micro)
                            .foregroundStyle(isSelected ? .black.opacity(0.74) : HFColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(width: 220, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(isSelected ? accent : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.82) : accent.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(section.title) section. \(section.status).")
    }
}

private struct HFWatchViewingDetailPanel: View {
    let section: HFWatchHubSection
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: section.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Selected Viewing Area", accent: accent)
                        Text("Selected Viewing Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFWatchViewingDetailRow(title: "Prepares", detail: section.prepares, accent: accent)
                    HFWatchViewingDetailRow(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFWatchViewingDetailRow(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.items) { item in
                        HFWatchViewingItemRow(item: item, accent: accent)
                    }
                }

                Text("Preview Viewing Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Viewing Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Viewing Area, \(section.title), \(section.prepares)")
        .accessibilityIdentifier("hf.room.watch.viewingDetail")
    }
}

private struct HFWatchViewingDetailRow: View {
    let title: String
    let detail: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            HFRoomStatusChip(title: title, accent: accent)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HFWatchViewingItemRow: View {
    let item: HFWatchHubItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: item.state, accent: accent)
                }
            }

            Text(item.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.state), \(item.detail)")
    }
}

private struct HFWatchViewingReadinessSummary: View {
    let rows: [HFWatchHubReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Viewing Readiness")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local", accent: accent)
                }

                VStack(spacing: HFSpacing.sm) {
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(row.title)
                                    .font(HFTypography.smallAction)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(row.detail)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: HFSpacing.sm)
                            HFRoomStatusChip(title: row.status, accent: accent)
                        }
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.055))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Viewing Readiness, \(rows.map { "\($0.title), \($0.status)" }.joined(separator: ", "))")
        .accessibilityIdentifier("hf.room.watch.viewingReadiness")
    }
}

private struct HFWatchViewingBoundaryCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Safe Preview", accent: accent)
                    Text("Watch Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local viewing-hub preview. Player systems, account sync, measurement, offline delivery, group watch, and server streaming remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Safe Preview")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Watch Safety Boundary, player sync measurement offline delivery group watch and server streaming remain disconnected.")
        .accessibilityIdentifier("hf.room.watch.viewingBoundary")
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
                    status: "Local Preview",
                    systemImage: "play.rectangle.fill",
                    accent: HFColors.gold
                )

                HFRoomExperienceStrip(
                    accent: HFColors.gold,
                    items: ["Streaming-first", "Saved titles", "Offline-ready"]
                )

                HFWatchViewingHubSection(hub: HFWatchViewingHubPreviewData.hub, accent: HFColors.gold)
                HFRoomDepthSnapshotStrip(accent: HFColors.gold)
                HFRoomWorkflowDrilldownSection(plan: HFRoomWorkflowDrilldownPlans.watch, accent: HFColors.gold, roomID: "watch")
                HFRoomGuidedWorkflowSection(plan: HFRoomWorkflowPlans.watch, accent: HFColors.gold, roomID: "watch")
                HFRoomReadinessPanel(blueprint: HFRoomDepthData.watch, accent: HFColors.gold)
                HFRoomPipelineStrip(stages: HFRoomDepthData.watch.pipelineStages, accent: HFColors.gold)
                HFRoomWorkflowDepthPanel(steps: HFRoomDepthData.watch.workflowSteps, accent: HFColors.gold)

                VStack(spacing: HFSpacing.md) {
                    NavigationLink {
                        MovieDetailView(movie: featuredMovie)
                    } label: {
                        HFRoomFeatureCard(title: "Continue Watching", subtitle: "Resume titles already in progress with the Watch Now path.", status: "Local Preview", systemImage: "play.fill", accent: HFColors.gold)
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
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Watch Room feature cards")
                .accessibilityIdentifier("hf.room.watch.features")

                HFRoomSafeBoundaryCard(blueprint: HFRoomDepthData.watch, accent: HFColors.gold)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Watch Room")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.room.watch.root")
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

                HFRoomExperienceStrip(
                    accent: Color.orange,
                    items: ["Project slate", "Pitch package", "Media kit"]
                )

                HFCreatorStudioSlateSection(slate: HFCreatorStudioSlatePreviewData.slate, accent: Color.orange)
                HFCreatorPackageBuilderSection(package: HFCreatorPackageBuilderPreviewData.package, accent: Color.orange)
                HFRoomDepthSnapshotStrip(accent: Color.orange)
                HFRoomWorkflowDrilldownSection(plan: HFRoomWorkflowDrilldownPlans.create, accent: Color.orange, roomID: "create")
                HFRoomGuidedWorkflowSection(plan: HFRoomWorkflowPlans.create, accent: Color.orange, roomID: "create")
                HFRoomReadinessPanel(blueprint: HFRoomDepthData.create, accent: Color.orange)
                HFRoomPipelineStrip(stages: HFRoomDepthData.create.pipelineStages, accent: Color.orange)
                HFRoomWorkflowDepthPanel(steps: HFRoomDepthData.create.workflowSteps, accent: Color.orange)

                studioSectionSelector
                selectedSectionView
                    .accessibilityIdentifier("hf.room.create.features")
                HFRoomSafeBoundaryCard(blueprint: HFRoomDepthData.create, accent: Color.orange)
                studioSafetyBoundary
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Studio")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.room.create.root")
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

private struct HFCreatorStudioSlateSection: View {
    let slate: HFCreatorSlatePreview
    let accent: Color
    @State private var selectedProjectIndex = 0

    private var selectedProject: HFCreatorSlateProject {
        guard slate.projects.indices.contains(selectedProjectIndex) else {
            return slate.projects[0]
        }
        return slate.projects[selectedProjectIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFCreatorStudioSlateOverviewCard(slate: slate, accent: accent)

            HFCreatorStudioProjectCards(
                projects: slate.projects,
                selectedProjectIndex: $selectedProjectIndex,
                accent: accent
            )

            HFCreatorStudioSelectedProjectPanel(project: selectedProject, accent: accent)
            HFCreatorStudioPackageProgressSection(accent: accent)
            HFCreatorStudioCreativeMaterialsSection(accent: accent)
            HFCreatorStudioLaunchConnectionCard(accent: accent)
            HFCreatorStudioBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Studio Slate, local creator project slate preview.")
        .accessibilityIdentifier("hf.room.create.studioSlate")
    }
}

private struct HFCreatorStudioSlateOverviewCard: View {
    let slate: HFCreatorSlatePreview
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "rectangle.3.group.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Studio Slate", accent: accent)
                        Text(slate.title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(slate.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 136), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    HFCreatorStudioSlateMetric(title: "Active Projects", value: "\(slate.activeProjectCount)", accent: accent)
                    HFCreatorStudioSlateMetric(title: "Ready Packages", value: "\(slate.readyPackageCount)", accent: accent)
                    HFCreatorStudioSlateMetric(title: "Draft Packages", value: "\(slate.draftPackageCount)", accent: accent)
                    HFCreatorStudioSlateMetric(title: "Protected Systems", value: "Locked", accent: accent)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Studio Slate, local creator project slate preview. \(slate.activeProjectCount) active projects.")
    }
}

private struct HFCreatorStudioSlateMetric: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(value)
                .font(HFTypography.smallAction)
                .foregroundStyle(accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFCreatorStudioProjectCards: View {
    let projects: [HFCreatorSlateProject]
    @Binding var selectedProjectIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Active Project Slate")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Local Selection", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(projects.enumerated()), id: \.element.id) { index, project in
                        Button {
                            selectedProjectIndex = index
                        } label: {
                            HFCreatorStudioProjectCard(
                                project: project,
                                isSelected: selectedProjectIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(project.title), \(project.status), Review Package Preview.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Active Project Slate.")
        .accessibilityIdentifier("hf.room.create.projectCards")
    }
}

private struct HFCreatorStudioProjectCard: View {
    let project: HFCreatorSlateProject
    let isSelected: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: project.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? .black : accent)
                    .frame(width: 38, height: 38)
                    .background(isSelected ? Color.black.opacity(0.10) : accent.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HFRoomStatusChip(title: project.status, accent: isSelected ? .black : accent)
                    Text(project.title)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(project.format)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .black.opacity(0.72) : HFColors.textSecondary)
            Text(project.genre)
                .font(HFTypography.micro)
                .foregroundStyle(isSelected ? .black.opacity(0.66) : HFColors.textMuted)
                .fixedSize(horizontal: false, vertical: true)
            Text(project.logline)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .black.opacity(0.72) : HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            StudioProgressBar(title: "Package progress", value: Int(project.packageProgress * 100), accent: isSelected ? .black : accent)

            VStack(alignment: .leading, spacing: 3) {
                Text("Audience")
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? .black.opacity(0.58) : HFColors.textMuted)
                Text(project.audience)
                    .font(HFTypography.caption)
                    .foregroundStyle(isSelected ? .black.opacity(0.76) : HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text("Review Package Preview")
                .font(HFTypography.micro)
                .foregroundStyle(isSelected ? .black : accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.xs)
                .padding(.vertical, 8)
                .background((isSelected ? Color.black : accent).opacity(0.12))
                .clipShape(Capsule())
        }
        .frame(width: 244, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(isSelected ? accent : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.82) : accent.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(project.title), \(project.format), \(project.status), \(Int(project.packageProgress * 100)) percent package progress.")
    }
}

private struct HFCreatorStudioSelectedProjectPanel: View {
    let project: HFCreatorSlateProject
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: project.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Selected Project Package", accent: accent)
                        Text("Selected Project Package")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(project.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFCreatorStudioDetailLine(title: "Logline", detail: project.logline, accent: accent)
                    HFCreatorStudioDetailLine(title: "Audience", detail: project.audience, accent: accent)
                    HFCreatorStudioDetailLine(title: "Package status", detail: project.status, accent: accent)
                }

                StudioProgressBar(title: "Package progress", value: Int(project.packageProgress * 100), accent: accent)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(project.materials) { material in
                        HFCreatorStudioMaterialRow(material: material, accent: accent)
                    }
                }

                Text("Preview Project Package")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Project Package, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Project Package. \(project.title). \(project.status).")
        .accessibilityIdentifier("hf.room.create.selectedProject")
    }
}

private struct HFCreatorStudioDetailLine: View {
    let title: String
    let detail: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            HFRoomStatusChip(title: title, accent: accent)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HFCreatorStudioMaterialRow: View {
    let material: HFCreatorSlateMaterial
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: material.systemImage)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(material.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: material.state, accent: accent)
                }
            }

            Text(material.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(material.title), \(material.state), \(material.detail)")
    }
}

private struct HFCreatorStudioPackageProgressSection: View {
    let accent: Color

    private let rows: [(title: String, status: String, detail: String, value: Int)] = [
        ("Identity", "Ready", "Title, format, and creator note are in place.", 88),
        ("Story", "Draft", "Synopsis and tone are shaped for review.", 64),
        ("Audience", "Preview", "Audience promise is clear enough to inspect.", 58),
        ("Media Kit", "Draft", "Visual placeholders and press rows are tracked.", 46),
        ("Launch Prep", "Preview", "Release direction is connected to Launch planning.", 60),
        ("Export / Render", "Protected", "Professional systems remain separated.", 12)
    ]

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Package Progress")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local", accent: accent)
                }

                VStack(spacing: HFSpacing.sm) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(row.title)
                                        .font(HFTypography.smallAction)
                                        .foregroundStyle(HFColors.textPrimary)
                                    Text(row.detail)
                                        .font(HFTypography.caption)
                                        .foregroundStyle(HFColors.textMuted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: HFSpacing.sm)
                                HFRoomStatusChip(title: row.status, accent: accent)
                            }
                            StudioProgressBar(title: "Progress", value: row.value, accent: accent)
                        }
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.055))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Package Progress.")
        .accessibilityIdentifier("hf.room.create.packageProgress")
    }
}

private struct HFCreatorStudioCreativeMaterialsSection: View {
    let accent: Color

    private let cards: [(title: String, detail: String, systemImage: String, status: String)] = [
        ("Story Notes", "Shape synopsis, tone, audience, and creator intent.", "doc.text.fill", "Ready"),
        ("Visual Materials", "Track poster, stills, and media-kit placeholders.", "photo.stack.fill", "Draft"),
        ("Pitch Copy", "Prepare headline, release angle, and creator statement.", "text.quote", "Preview"),
        ("Launch Connection", "Prepare the title for a future Launch Room plan.", "flag.checkered", "Preview"),
        ("Protected Systems", "Media intake, documents, server services, package production, and delivery remain disconnected.", "lock.shield.fill", "Protected")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Creative Materials", subtitle: "Local material cards for story, visuals, pitch, and release direction.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(Array(cards.enumerated()), id: \.offset) { _, card in
                    HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.26)) {
                        VStack(alignment: .leading, spacing: HFSpacing.sm) {
                            Image(systemName: card.systemImage)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(accent)
                                .frame(width: 42, height: 42)
                                .background(accent.opacity(0.14))
                                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                            Text(card.title)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                            HFRoomStatusChip(title: card.status, accent: accent)
                            Text(card.detail)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(HFSpacing.md)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(card.title), \(card.status), \(card.detail)")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creative Materials.")
        .accessibilityIdentifier("hf.room.create.creativeMaterials")
    }
}

private struct HFCreatorStudioLaunchConnectionCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Planning Bridge", accent: accent)
                    Text("Launch Connection")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Creator packages can prepare campaign direction, while live release, audience alerts, commerce, waitlists, measurement, and server systems remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Preview Launch Connection")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch Connection.")
        .accessibilityIdentifier("hf.room.create.launchConnection")
    }
}

private struct HFCreatorStudioBoundaryCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 48, height: 48)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Safe Preview", accent: accent)
                    Text("Studio Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local creator slate preview. Media intake, library access, document handling, identity services, server release systems, package production, delivery systems, commerce, and platform services remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Safe Preview")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Studio Safety Boundary, live systems remain disconnected.")
        .accessibilityIdentifier("hf.room.create.studioBoundary")
    }
}

private struct HFCreatorPackageBuilderSection: View {
    let package: HFCreatorPackagePreview
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFCreatorPackageSection {
        guard package.sections.indices.contains(selectedSectionIndex) else {
            return package.sections[0]
        }
        return package.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFCreatorPackageHeroCard(package: package, accent: accent)

            HFCreatorPackageSectionSelector(
                sections: package.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFCreatorPackageDetailPanel(section: selectedSection, accent: accent)
            HFCreatorPackageReadinessSummary(rows: package.readiness, accent: accent)
            HFCreatorPackageBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Project Package Builder, local creator package preview.")
        .accessibilityIdentifier("hf.room.create.packageBuilder")
    }
}

private struct HFCreatorPackageHeroCard: View {
    let package: HFCreatorPackagePreview
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "shippingbox.and.arrow.backward.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Project Package Builder", accent: accent)
                        Text("Project Package Builder")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Shape a title package before Uploads, Publishing, Render, or Export systems are connected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(package.title)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: package.packageStatus, accent: accent)
                    }

                    Text(package.logline)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFCreatorPackageMetric(title: "Genre", value: package.genre, accent: accent)
                        HFCreatorPackageMetric(title: "Audience", value: package.audience, accent: accent)
                        HFCreatorPackageMetric(title: "Story", value: "Ready", accent: accent)
                        HFCreatorPackageMetric(title: "Media", value: "Draft", accent: accent)
                        HFCreatorPackageMetric(title: "Launch", value: "Preview", accent: accent)
                        HFCreatorPackageMetric(title: "Export", value: "Deferred", accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Project Package Builder, local creator package preview. \(package.title), \(package.packageStatus)")
        .accessibilityIdentifier("hf.room.create.packageHero")
    }
}

private struct HFCreatorPackageMetric: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
            Text(value)
                .font(HFTypography.caption)
                .foregroundStyle(title == "Genre" || title == "Audience" ? HFColors.textSecondary : accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFCreatorPackageSectionSelector: View {
    let sections: [HFCreatorPackageSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Package Sections")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Local Selection", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        Button {
                            selectedSectionIndex = index
                        } label: {
                            HFCreatorPackageSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) package section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Package sections for local project package preview")
        .accessibilityIdentifier("hf.room.create.packageSections")
    }
}

private struct HFCreatorPackageSectionCard: View {
    let section: HFCreatorPackageSection
    let isSelected: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: section.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isSelected ? .black : accent)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? Color.black.opacity(0.10) : accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: section.status, accent: isSelected ? .black : accent)
                }
            }

            Text(section.subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .black.opacity(0.72) : HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HFCreatorPackageProgressIndicator(progress: section.progress, accent: isSelected ? .black : accent)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(Array(section.items.prefix(3))) { item in
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isSelected ? .black : accent)
                            .padding(.top, 2)
                        Text(item.title)
                            .font(HFTypography.micro)
                            .foregroundStyle(isSelected ? .black.opacity(0.74) : HFColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(width: 220, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(isSelected ? accent : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.82) : accent.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(section.title) package section. \(section.status). \(Int(section.progress * 100)) percent preview readiness.")
    }
}

private struct HFCreatorPackageProgressIndicator: View {
    let progress: Double
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.14))
                Capsule()
                    .fill(accent)
                    .frame(width: max(8, proxy.size.width * CGFloat(min(max(progress, 0), 1))))
            }
        }
        .frame(height: 7)
        .accessibilityLabel("Progress \(Int(progress * 100)) percent")
    }
}

private struct HFCreatorPackageDetailPanel: View {
    let section: HFCreatorPackageSection
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: section.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Selected Package Area", accent: accent)
                        Text("Selected Package Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFCreatorPackageDetailRow(title: "Prepares", detail: section.prepares, accent: accent)
                    HFCreatorPackageDetailRow(title: "Ready", detail: section.readySummary, accent: accent)
                    HFCreatorPackageDetailRow(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFCreatorPackageDetailRow(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.items) { item in
                        HFCreatorPackageItemRow(item: item, accent: accent)
                    }
                }

                Text("Preview Package Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Package Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Package Area, \(section.title), \(section.prepares)")
        .accessibilityIdentifier("hf.room.create.packageDetail")
    }
}

private struct HFCreatorPackageDetailRow: View {
    let title: String
    let detail: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            HFRoomStatusChip(title: title, accent: accent)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HFCreatorPackageItemRow: View {
    let item: HFCreatorPackageItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: item.state, accent: accent)
                }
            }

            Text(item.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.state), \(item.detail)")
    }
}

private struct HFCreatorPackageReadinessSummary: View {
    let rows: [HFCreatorPackageReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Package Readiness")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local", accent: accent)
                }

                VStack(spacing: HFSpacing.sm) {
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(row.title)
                                    .font(HFTypography.smallAction)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(row.detail)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: HFSpacing.sm)
                            HFRoomStatusChip(title: row.status, accent: accent)
                        }
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.055))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Package Readiness, \(rows.map { "\($0.title), \($0.status)" }.joined(separator: ", "))")
        .accessibilityIdentifier("hf.room.create.packageReadiness")
    }
}

private struct HFCreatorPackageBoundaryCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Safe Preview", accent: accent)
                    Text("Studio Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local project-package preview. Uploads, Accounts, Backend services, photo-library access, File handling, Render, Export, Payments, and Publishing remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Safe Preview")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Studio Safety Boundary, live systems remain disconnected.")
        .accessibilityIdentifier("hf.room.create.packageBoundary")
    }
}

private struct HFConnectAudiencePlannerSection: View {
    let plan: HFConnectAudiencePreview
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFConnectPlannerSection {
        guard plan.sections.indices.contains(selectedSectionIndex) else {
            return plan.sections[0]
        }
        return plan.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFConnectAudienceHeroCard(plan: plan, accent: accent)

            HFConnectAudienceSectionSelector(
                sections: plan.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFConnectAudienceDetailPanel(section: selectedSection, accent: accent)
            HFConnectAudienceReadinessSummary(rows: plan.readiness, accent: accent)
            HFConnectAudienceBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Audience Planner, local audience community preview.")
        .accessibilityIdentifier("hf.room.connect.audiencePlanner")
    }
}

private struct HFConnectAudienceHeroCard: View {
    let plan: HFConnectAudiencePreview
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Audience Planner", accent: accent)
                        Text("Audience Planner")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(plan.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(plan.focusTitle)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: plan.plannerStatus, accent: accent)
                    }

                    Text("Premiere community and creator updates")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFConnectAudienceMetric(title: "Tone", value: plan.audienceTone, accent: accent)
                        HFConnectAudienceMetric(title: "Communities", value: "Preview", accent: accent)
                        HFConnectAudienceMetric(title: "Updates", value: "Draft", accent: accent)
                        HFConnectAudienceMetric(title: "Reactions", value: "Local", accent: accent)
                        HFConnectAudienceMetric(title: "Messaging", value: "Deferred", accent: accent)
                        HFConnectAudienceMetric(title: "Analytics", value: "Protected", accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Audience Planner, local audience community preview. \(plan.focusTitle), \(plan.plannerStatus)")
        .accessibilityIdentifier("hf.room.connect.audienceHero")
    }
}

private struct HFConnectAudienceMetric: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
            Text(value)
                .font(HFTypography.caption)
                .foregroundStyle(title == "Tone" ? HFColors.textSecondary : accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFConnectAudienceSectionSelector: View {
    let sections: [HFConnectPlannerSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Audience Sections")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Local Selection", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        Button {
                            selectedSectionIndex = index
                        } label: {
                            HFConnectAudienceSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) planner section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Audience sections for local audience planner preview")
        .accessibilityIdentifier("hf.room.connect.audienceSections")
    }
}

private struct HFConnectAudienceSectionCard: View {
    let section: HFConnectPlannerSection
    let isSelected: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: section.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isSelected ? .black : accent)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? Color.black.opacity(0.10) : accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: section.status, accent: isSelected ? .black : accent)
                }
            }

            Text(section.subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .black.opacity(0.72) : HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(Array(section.prompts.prefix(3))) { prompt in
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isSelected ? .black : accent)
                            .padding(.top, 2)
                        Text(prompt.title)
                            .font(HFTypography.micro)
                            .foregroundStyle(isSelected ? .black.opacity(0.74) : HFColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(width: 220, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(isSelected ? accent : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.82) : accent.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(section.title) planner section. \(section.status).")
    }
}

private struct HFConnectAudienceDetailPanel: View {
    let section: HFConnectPlannerSection
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: section.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Selected Audience Area", accent: accent)
                        Text("Selected Audience Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFConnectAudienceDetailRow(title: "Prepares", detail: section.prepares, accent: accent)
                    HFConnectAudienceDetailRow(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFConnectAudienceDetailRow(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.prompts) { prompt in
                        HFConnectAudiencePromptRow(prompt: prompt, accent: accent)
                    }
                }

                Text("Preview Audience Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Audience Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Audience Area, \(section.title), \(section.prepares)")
        .accessibilityIdentifier("hf.room.connect.audienceDetail")
    }
}

private struct HFConnectAudienceDetailRow: View {
    let title: String
    let detail: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            HFRoomStatusChip(title: title, accent: accent)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HFConnectAudiencePromptRow: View {
    let prompt: HFConnectPlannerPrompt
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "sparkle")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: prompt.state, accent: accent)
                }
            }

            Text(prompt.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(prompt.title), \(prompt.state), \(prompt.detail)")
    }
}

private struct HFConnectAudienceReadinessSummary: View {
    let rows: [HFConnectReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Audience Readiness")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local", accent: accent)
                }

                VStack(spacing: HFSpacing.sm) {
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(row.title)
                                    .font(HFTypography.smallAction)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(row.detail)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: HFSpacing.sm)
                            HFRoomStatusChip(title: row.status, accent: accent)
                        }
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.055))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Audience Readiness, \(rows.map { "\($0.title), \($0.status)" }.joined(separator: ", "))")
        .accessibilityIdentifier("hf.room.connect.audienceReadiness")
    }
}

private struct HFConnectAudienceBoundaryCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Safe Preview", accent: accent)
                    Text("Connect Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local audience-planning preview. Messaging, Comments, Accounts, Notifications, Analytics, Social Graph, and Backend systems remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Safe Preview")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Connect Safety Boundary, Messaging Notifications Analytics and Backend remain disconnected.")
        .accessibilityIdentifier("hf.room.connect.audienceBoundary")
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

                HFRoomExperienceStrip(
                    accent: Color.cyan,
                    items: ["Communities", "Audience energy", "Creator updates"]
                )

                HFConnectAudiencePlannerSection(plan: HFConnectAudiencePlannerPreviewData.plan, accent: Color.cyan)
                HFRoomDepthSnapshotStrip(accent: Color.cyan)
                HFRoomWorkflowDrilldownSection(plan: HFRoomWorkflowDrilldownPlans.connect, accent: Color.cyan, roomID: "connect")
                HFRoomGuidedWorkflowSection(plan: HFRoomWorkflowPlans.connect, accent: Color.cyan, roomID: "connect")
                HFRoomReadinessPanel(blueprint: HFRoomDepthData.connect, accent: Color.cyan)
                HFRoomPipelineStrip(stages: HFRoomDepthData.connect.pipelineStages, accent: Color.cyan)
                HFRoomWorkflowDepthPanel(steps: HFRoomDepthData.connect.workflowSteps, accent: Color.cyan)

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
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Connect Room feature cards")
                .accessibilityIdentifier("hf.room.connect.features")

                HFRoomSafeBoundaryCard(blueprint: HFRoomDepthData.connect, accent: Color.cyan)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Connect Room")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.room.connect.root")
    }
}

private struct HFLaunchCampaignPlannerSection: View {
    let campaign: HFLaunchCampaignPreview
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFLaunchPlannerSection {
        guard campaign.sections.indices.contains(selectedSectionIndex) else {
            return campaign.sections[0]
        }
        return campaign.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFLaunchCampaignHeroCard(campaign: campaign, accent: accent)

            HFLaunchCampaignSectionSelector(
                sections: campaign.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFLaunchCampaignDetailPanel(section: selectedSection, accent: accent)
            HFLaunchCampaignReadinessSummary(rows: campaign.readiness, accent: accent)
            HFLaunchCampaignBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Campaign Planner, local premiere campaign preview.")
        .accessibilityIdentifier("hf.room.launch.campaignPlanner")
    }
}

private struct HFLaunchCampaignHeroCard: View {
    let campaign: HFLaunchCampaignPreview
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "flag.checkered.2.crossed")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Campaign Planner", accent: accent)
                        Text("Campaign Planner")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(campaign.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("The Friendly Launch Plan")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: campaign.plannerStatus, accent: accent)
                    }

                    Text(campaign.campaignFocus)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFLaunchCampaignMetric(title: "Window", value: campaign.releaseWindow, accent: accent)
                        HFLaunchCampaignMetric(title: "Tone", value: campaign.audienceTone, accent: accent)
                        HFLaunchCampaignMetric(title: "Timeline", value: "Draft", accent: accent)
                        HFLaunchCampaignMetric(title: "Materials", value: "Preview", accent: accent)
                        HFLaunchCampaignMetric(title: "Audience", value: "Local", accent: accent)
                        HFLaunchCampaignMetric(title: "Tickets / Payments", value: "Deferred", accent: accent)
                        HFLaunchCampaignMetric(title: "Analytics", value: "Protected", accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Campaign Planner, local premiere campaign preview. The Friendly Launch Plan, \(campaign.plannerStatus)")
        .accessibilityIdentifier("hf.room.launch.campaignHero")
    }
}

private struct HFLaunchCampaignMetric: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
            Text(value)
                .font(HFTypography.caption)
                .foregroundStyle(title == "Window" || title == "Tone" ? HFColors.textSecondary : accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFLaunchCampaignSectionSelector: View {
    let sections: [HFLaunchPlannerSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Campaign Sections")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Local Selection", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        Button {
                            selectedSectionIndex = index
                        } label: {
                            HFLaunchCampaignSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Campaign sections for local premiere campaign preview")
        .accessibilityIdentifier("hf.room.launch.campaignSections")
    }
}

private struct HFLaunchCampaignSectionCard: View {
    let section: HFLaunchPlannerSection
    let isSelected: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: section.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isSelected ? .black : accent)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? Color.black.opacity(0.10) : accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: section.status, accent: isSelected ? .black : accent)
                }
            }

            Text(section.subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .black.opacity(0.72) : HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(Array(section.items.prefix(3))) { item in
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isSelected ? .black : accent)
                            .padding(.top, 2)
                        Text(item.title)
                            .font(HFTypography.micro)
                            .foregroundStyle(isSelected ? .black.opacity(0.74) : HFColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(width: 220, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(isSelected ? accent : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.82) : accent.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(section.title) section. \(section.status).")
    }
}

private struct HFLaunchCampaignDetailPanel: View {
    let section: HFLaunchPlannerSection
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: section.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Selected Launch Area", accent: accent)
                        Text("Selected Launch Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFLaunchCampaignDetailRow(title: "Prepares", detail: section.prepares, accent: accent)
                    HFLaunchCampaignDetailRow(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFLaunchCampaignDetailRow(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.items) { item in
                        HFLaunchCampaignItemRow(item: item, accent: accent)
                    }
                }

                Text("Preview Launch Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Launch Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Launch Area, \(section.title), \(section.prepares)")
        .accessibilityIdentifier("hf.room.launch.campaignDetail")
    }
}

private struct HFLaunchCampaignDetailRow: View {
    let title: String
    let detail: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            HFRoomStatusChip(title: title, accent: accent)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HFLaunchCampaignItemRow: View {
    let item: HFLaunchPlannerItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: item.state, accent: accent)
                }
            }

            Text(item.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.state), \(item.detail)")
    }
}

private struct HFLaunchCampaignReadinessSummary: View {
    let rows: [HFLaunchPlannerReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Launch Readiness")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local", accent: accent)
                }

                VStack(spacing: HFSpacing.sm) {
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(row.title)
                                    .font(HFTypography.smallAction)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(row.detail)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: HFSpacing.sm)
                            HFRoomStatusChip(title: row.status, accent: accent)
                        }
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.055))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Readiness, \(rows.map { "\($0.title), \($0.status)" }.joined(separator: ", "))")
        .accessibilityIdentifier("hf.room.launch.campaignReadiness")
    }
}

private struct HFLaunchCampaignBoundaryCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Safe Preview", accent: accent)
                    Text("Launch Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local campaign-planning preview. Commerce, store services, paid access, passes, audience lists, reminders, measurement, Campaign Publishing, and server systems remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Safe Preview")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch Safety Boundary, commerce reminders measurement and server systems remain disconnected.")
        .accessibilityIdentifier("hf.room.launch.campaignBoundary")
    }
}

private enum LaunchSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case timeline = "Timeline"
    case campaign = "Campaign"
    case audience = "Audience"
    case materials = "Materials"
    case releaseReadiness = "Release Readiness"
    case safetyBoundary = "Safety Boundary"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .overview: "rectangle.3.group.fill"
        case .timeline: "calendar.badge.clock"
        case .campaign: "megaphone.fill"
        case .audience: "person.3.fill"
        case .materials: "checklist.checked"
        case .releaseReadiness: "gauge.with.dots.needle.67percent"
        case .safetyBoundary: "lock.shield.fill"
        }
    }

    var accessibilityName: String {
        switch self {
        case .overview: "Launch Room overview section"
        case .timeline: "Timeline section, local preview of release phases"
        case .campaign: "Campaign section, preview of campaign page copy and launch materials"
        case .audience: "Audience section, display-only preview of audience buildup"
        case .materials: "Materials section, launch material readiness checklist"
        case .releaseReadiness: "Release Readiness section, local readiness groups"
        case .safetyBoundary: "Launch Safety Boundary section"
        }
    }
}

private struct LaunchTimelineStep: Identifiable {
    let id = UUID()
    let title: String
    let timing: String
    let focus: String
    let status: String
    let checklist: [String]
}

private struct LaunchAudienceSignal: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let signal: String
    let metric: String
    let systemImage: String
}

private struct LaunchCampaignItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct LaunchReadinessGroup: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
    let checklist: [String]
    let systemImage: String
}

private enum LaunchRoomData {
    static let overviewItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Premiere Timeline", status: "Preview", detail: "Plan the path from announcement to release.", systemImage: "calendar.badge.clock"),
        StudioChecklistItem(title: "Campaign Preview", status: "Local Preview", detail: "Shape the public-facing release story.", systemImage: "megaphone.fill"),
        StudioChecklistItem(title: "Audience Buildup", status: "Coming Soon", detail: "Preview momentum before a title premieres.", systemImage: "person.3.fill"),
        StudioChecklistItem(title: "Launch Checklist", status: "Preview", detail: "Track posters, trailers, synopsis, creator notes, and release materials.", systemImage: "checklist.checked"),
        StudioChecklistItem(title: "Release Status", status: "Readiness", detail: "See what is ready, pending, or deferred.", systemImage: "gauge.with.dots.needle.67percent"),
        StudioChecklistItem(title: "Export Handoff", status: "Protected", detail: "Prepare the title package before export systems are connected.", systemImage: "shippingbox.fill")
    ]

    static let timelineSteps: [LaunchTimelineStep] = [
        LaunchTimelineStep(
            title: "Package Lock",
            timing: "6 weeks before premiere",
            focus: "Finalize title, synopsis, creator profile, poster direction, and trailer notes.",
            status: "In Review",
            checklist: ["Title package", "Creator profile", "Poster direction"]
        ),
        LaunchTimelineStep(
            title: "Audience Warmup",
            timing: "4 weeks before premiere",
            focus: "Prepare community copy, creator updates, and early audience positioning.",
            status: "Preview",
            checklist: ["Community copy", "Creator update", "Audience positioning"]
        ),
        LaunchTimelineStep(
            title: "Campaign Page",
            timing: "3 weeks before premiere",
            focus: "Preview title page, trailer copy, poster stack, and release hook.",
            status: "Local Preview",
            checklist: ["Title page", "Trailer copy", "Release hook"]
        ),
        LaunchTimelineStep(
            title: "Premiere Window",
            timing: "Launch week",
            focus: "Coordinate Watch, Connect, and Launch surfaces around the title.",
            status: "Coming Soon",
            checklist: ["Watch surface", "Connect preview", "Launch copy"]
        ),
        LaunchTimelineStep(
            title: "Post-Premiere",
            timing: "After release",
            focus: "Prepare audience notes, related title rails, and export handoff.",
            status: "Deferred",
            checklist: ["Audience notes", "Related titles", "Export handoff"]
        )
    ]

    static let campaignItems: [LaunchCampaignItem] = [
        LaunchCampaignItem(title: "Campaign Header", detail: "The Friendly - Featured Premiere", status: "Preview", systemImage: "rectangle.on.rectangle.angled.fill"),
        LaunchCampaignItem(title: "Audience Hook", detail: "A cinematic story about an impossible idea becoming a movement.", status: "Local Preview", systemImage: "sparkles"),
        LaunchCampaignItem(title: "Creator Note", detail: "Built for viewers who love premium indie stories, behind-the-scenes journeys, and character-driven drama.", status: "Preview", systemImage: "person.text.rectangle.fill"),
        LaunchCampaignItem(title: "Trailer Positioning", detail: "Lead with tone, creator stakes, and the final emotional reveal.", status: "Needs Review", systemImage: "film.fill"),
        LaunchCampaignItem(title: "Poster Stack", detail: "Use the existing title art direction as the premiere visual anchor.", status: "Readiness", systemImage: "photo.stack.fill"),
        LaunchCampaignItem(title: "Community Preview", detail: "Connect Room energy prepares the audience context before launch week.", status: "Coming Soon", systemImage: "person.2.fill")
    ]

    static let audienceSignals: [LaunchAudienceSignal] = [
        LaunchAudienceSignal(title: "Audience Warmup", detail: "Prepare community energy before the premiere.", signal: "Preview Momentum", metric: "12.4K interested", systemImage: "flame.fill"),
        LaunchAudienceSignal(title: "Creator Followers Preview", detail: "Audience interest from creator and title communities.", signal: "Local Signal", metric: "8.7K following", systemImage: "person.crop.circle.badge.checkmark"),
        LaunchAudienceSignal(title: "Waitlist Preview", detail: "A future space for viewers who want release updates.", signal: "Coming Soon", metric: "4.1K preview audience", systemImage: "person.crop.circle.badge.clock"),
        LaunchAudienceSignal(title: "Premiere Room Preview", detail: "Connect Room energy prepared for launch week.", signal: "Audience Preview", metric: "2.4K room energy", systemImage: "bubble.left.and.bubble.right.fill")
    ]

    static let materialItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Poster", status: "Ready", detail: "Key art direction is present in the local title package.", systemImage: "photo.fill"),
        StudioChecklistItem(title: "Backdrop", status: "Needs Review", detail: "Backdrop should support a cinematic release page.", systemImage: "photo.on.rectangle.angled"),
        StudioChecklistItem(title: "Trailer Notes", status: "Deferred", detail: "Trailer planning remains copy-only with no playback integration.", systemImage: "film.fill"),
        StudioChecklistItem(title: "Synopsis", status: "Ready", detail: "Short and long synopsis support Watch and Launch surfaces.", systemImage: "doc.text.fill"),
        StudioChecklistItem(title: "Creator Note", status: "Preview", detail: "Creator perspective frames the launch story.", systemImage: "person.text.rectangle.fill"),
        StudioChecklistItem(title: "Press Blurb", status: "Deferred", detail: "Press copy remains a planning item.", systemImage: "newspaper.fill"),
        StudioChecklistItem(title: "Community Copy", status: "Needs Review", detail: "Audience-facing copy should match Connect Room tone.", systemImage: "text.bubble.fill"),
        StudioChecklistItem(title: "Campaign Hook", status: "Ready", detail: "The premiere hook anchors campaign preview copy.", systemImage: "megaphone.fill"),
        StudioChecklistItem(title: "Related Titles", status: "Preview", detail: "Related rails support discovery after launch.", systemImage: "rectangle.stack.fill"),
        StudioChecklistItem(title: "Export Handoff Notes", status: "Protected", detail: "Delivery notes are planning-only until export systems exist.", systemImage: "shippingbox.fill")
    ]

    static let readinessGroups: [LaunchReadinessGroup] = [
        LaunchReadinessGroup(title: "Watch Surface", status: "Preview", detail: "Consumer surfaces that make the title watchable.", checklist: ["Movie Detail page", "Watch Now CTA", "Related Titles", "My List routing"], systemImage: "play.rectangle.fill"),
        LaunchReadinessGroup(title: "Create Package", status: "Readiness", detail: "Creator-side materials prepared before the launch moment.", checklist: ["Creator Profile", "Pitch summary", "Media Kit", "Poster and trailer notes"], systemImage: "wand.and.stars"),
        LaunchReadinessGroup(title: "Connect Surface", status: "Preview", detail: "Audience energy that supports the release story.", checklist: ["Community preview", "Reactions preview", "Creator updates", "Watch community"], systemImage: "person.2.fill"),
        LaunchReadinessGroup(title: "Launch Surface", status: "Local Preview", detail: "Planning view for campaign, timeline, and release status.", checklist: ["Campaign preview", "Timeline", "Audience warmup", "Release status"], systemImage: "flag.checkered"),
        LaunchReadinessGroup(title: "Export Handoff", status: "Protected", detail: "Professional readiness notes before real export systems exist.", checklist: ["Deliverables notes", "Platform checklist", "Distribution package preview"], systemImage: "shippingbox.fill")
    ]

    static let safetyItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Payments", status: "Deferred", detail: "No commerce system is connected to Launch Room.", systemImage: "creditcard"),
        StudioChecklistItem(title: "StoreKit", status: "Protected", detail: "StoreKit remains outside this product-room UI pass.", systemImage: "lock.shield.fill"),
        StudioChecklistItem(title: "Subscriptions", status: "Deferred", detail: "No paid access or subscription flow is introduced.", systemImage: "person.badge.key.fill"),
        StudioChecklistItem(title: "Campaign Publishing", status: "Deferred", detail: "Campaigns are local previews only.", systemImage: "paperplane.fill"),
        StudioChecklistItem(title: "Waitlists", status: "Deferred", detail: "Audience interest numbers are display-only.", systemImage: "person.crop.circle.badge.clock"),
        StudioChecklistItem(title: "Notifications", status: "Deferred", detail: "No reminder or push system is connected.", systemImage: "bell.slash.fill"),
        StudioChecklistItem(title: "Analytics", status: "Deferred", detail: "Audience signals are static preview copy.", systemImage: "chart.bar.xaxis"),
        StudioChecklistItem(title: "Backend", status: "Deferred", detail: "Launch Room uses local static SwiftUI data only.", systemImage: "server.rack")
    ]
}

private struct LaunchRoomView: View {
    @State private var selectedLaunchSection: LaunchSection = .overview
    private let accent = HFColors.gold

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFProductRoomHero(
                    eyebrow: "LAUNCH",
                    title: "Launch Room",
                    subtitle: "Prepare premieres, campaigns, and release moments.",
                    purpose: "This room previews release and campaign planning.",
                    heroCopy: "A premium space for premiere timelines, campaign previews, audience buildup, launch checklists, and release readiness.",
                    status: "Launch Preview",
                    systemImage: "flag.checkered",
                    accent: accent
                )

                HFRoomExperienceStrip(
                    accent: accent,
                    items: ["Timeline", "Campaign", "Readiness"]
                )

                HFLaunchCampaignPlannerSection(campaign: HFLaunchCampaignPlannerPreviewData.campaign, accent: accent)
                HFRoomDepthSnapshotStrip(accent: accent)
                HFRoomWorkflowDrilldownSection(plan: HFRoomWorkflowDrilldownPlans.launch, accent: accent, roomID: "launch")
                HFRoomGuidedWorkflowSection(plan: HFRoomWorkflowPlans.launch, accent: accent, roomID: "launch")
                HFRoomReadinessPanel(blueprint: HFRoomDepthData.launch, accent: accent)
                HFRoomPipelineStrip(stages: HFRoomDepthData.launch.pipelineStages, accent: accent)
                HFRoomWorkflowDepthPanel(steps: HFRoomDepthData.launch.workflowSteps, accent: accent)

                launchSectionSelector
                selectedSectionView
                    .accessibilityIdentifier("hf.room.launch.features")
                HFRoomSafeBoundaryCard(blueprint: HFRoomDepthData.launch, accent: accent)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Launch Room")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.room.launch.root")
    }

    private var launchSectionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(LaunchSection.allCases) { section in
                    Button {
                        selectedLaunchSection = section
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: section.systemImage)
                                .font(.system(size: 12, weight: .bold))
                            Text(section.rawValue)
                        }
                        .font(HFTypography.micro)
                        .foregroundStyle(selectedLaunchSection == section ? .black : HFColors.textSecondary)
                        .padding(.horizontal, HFSpacing.sm)
                        .padding(.vertical, 10)
                        .background(selectedLaunchSection == section ? accent : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedLaunchSection == section ? accent.opacity(0.78) : HFColors.glassStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(section.accessibilityName)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Room section selector")
    }

    @ViewBuilder
    private var selectedSectionView: some View {
        switch selectedLaunchSection {
        case .overview:
            overviewSection
        case .timeline:
            timelineSection
        case .campaign:
            campaignSection
        case .audience:
            audienceSection
        case .materials:
            materialsSection
        case .releaseReadiness:
            releaseReadinessSection
        case .safetyBoundary:
            launchSafetyBoundary
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Launch Overview", subtitle: "The local command surface for preparing a title release.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(LaunchRoomData.overviewItems) { item in
                    StudioChecklistCard(item: item, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Room overview cards")
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Release Timeline", subtitle: "A cinematic path from package lock to post-premiere handoff.")

            VStack(spacing: HFSpacing.md) {
                ForEach(LaunchRoomData.timelineSteps) { step in
                    LaunchTimelineCard(step: step, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Timeline section, local preview of release phases")
    }

    private var campaignSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Campaign Preview", subtitle: "Shape the public release story without publishing a campaign.")

            HFGlassPanel(cornerRadius: 28, strokeColor: accent.opacity(0.40)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HFRoomStatusChip(title: "Local Preview", accent: accent)
                    Text("The Friendly - Featured Premiere")
                        .font(HFTypography.title)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("A cinematic story about an impossible idea becoming a movement.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: HFSpacing.sm) {
                        LaunchPassiveCTA(title: "Preview Campaign", accent: accent)
                        LaunchPassiveCTA(title: "Review Copy", accent: accent)
                        LaunchPassiveCTA(title: "Prepare Launch Page", accent: accent)
                    }
                }
                .padding(HFSpacing.lg)
            }

            VStack(spacing: HFSpacing.sm) {
                ForEach(LaunchRoomData.campaignItems) { item in
                    LaunchCampaignCard(item: item, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Campaign section, preview of campaign page copy and launch materials")
    }

    private var audienceSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Audience Buildup", subtitle: "Display-only audience momentum that bridges Connect into Launch.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(LaunchRoomData.audienceSignals) { signal in
                    LaunchAudienceSignalCard(signal: signal, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Audience section, display-only preview of audience buildup")
    }

    private var materialsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Launch Materials", subtitle: "Track release materials without touching assets, files, or photo systems.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(LaunchRoomData.materialItems) { item in
                    StudioChecklistCard(item: item, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Materials section, launch material readiness checklist")
    }

    private var releaseReadinessSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Release Readiness", subtitle: "Manual readiness groups across Watch, Create, Connect, Launch, and Export handoff.")

            VStack(spacing: HFSpacing.md) {
                ForEach(LaunchRoomData.readinessGroups) { group in
                    LaunchReadinessGroupCard(group: group, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Release Readiness section, local readiness groups")
    }

    private var launchSafetyBoundary: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Launch Safety Boundary")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Launch Room is a local product preview. Payments, subscriptions, StoreKit, crowdfunding, notifications, analytics, campaign publishing, waitlists, and backend launch systems remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Protected for this phase.")
                            .font(HFTypography.caption)
                            .foregroundStyle(accent)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(LaunchRoomData.safetyItems) { item in
                        StudioSafetyChip(item: item)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Safety Boundary, payments StoreKit subscriptions notifications analytics waitlists campaign publishing and backend remain disconnected")
    }
}

private struct LaunchTimelineCard: View {
    let step: LaunchTimelineStep
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 44, height: 44)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(step.title)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                            HFRoomStatusChip(title: step.status, accent: accent)
                        }
                        Text(step.timing)
                            .font(HFTypography.caption)
                            .foregroundStyle(accent)
                        Text(step.focus)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(step.checklist, id: \.self) { item in
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(accent)
                                .padding(.top, 2)
                            Text(item)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    LaunchPassiveCTA(title: "Review Timeline", accent: accent)
                    LaunchPassiveCTA(title: "Preview Phase", accent: accent)
                    LaunchPassiveCTA(title: "Check Readiness", accent: accent)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.title), \(step.timing), \(step.status), \(step.focus)")
    }
}

private struct LaunchCampaignCard: View {
    let item: LaunchCampaignItem
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
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

private struct LaunchAudienceSignalCard: View {
    let signal: LaunchAudienceSignal
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: signal.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(signal.metric)
                        .font(HFTypography.title)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(signal.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                    HFRoomStatusChip(title: signal.signal, accent: accent)
                    Text(signal.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(signal.title), \(signal.metric), \(signal.signal), \(signal.detail)")
    }
}

private struct LaunchReadinessGroupCard: View {
    let group: LaunchReadinessGroup
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: group.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 44, height: 44)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(group.title)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                            HFRoomStatusChip(title: group.status, accent: accent)
                        }
                        Text(group.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(group.checklist, id: \.self) { item in
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(accent)
                                .padding(.top, 2)
                            Text(item)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(group.title), \(group.status), \(group.detail)")
    }
}

private struct LaunchPassiveCTA: View {
    let title: String
    let accent: Color

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.68)
            .padding(.horizontal, HFSpacing.xs)
            .padding(.vertical, 8)
            .background(accent.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(accent.opacity(0.34), lineWidth: 1))
    }
}

private struct HFExportDistributionPackageSection: View {
    let package: HFExportDistributionPreview
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFExportPackageSection {
        guard package.sections.indices.contains(selectedSectionIndex) else {
            return package.sections[0]
        }
        return package.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFExportDistributionHeroCard(package: package, accent: accent)

            HFExportDistributionSectionSelector(
                sections: package.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFExportDistributionDetailPanel(section: selectedSection, accent: accent)
            HFExportDistributionReadinessSummary(rows: package.readiness, accent: accent)
            HFExportDistributionBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Distribution Package, local export distribution preview.")
        .accessibilityIdentifier("hf.room.export.distributionPackage")
    }
}

private struct HFExportDistributionHeroCard: View {
    let package: HFExportDistributionPreview
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "shippingbox.and.arrow.backward.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Distribution Package", accent: accent)
                        Text("Distribution Package")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(package.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("The Friendly Distribution Package")
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: package.plannerStatus, accent: accent)
                    }

                    Text(package.packageFocus)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFExportDistributionMetric(title: "Window", value: package.deliveryWindow, accent: accent)
                        HFExportDistributionMetric(title: "Tone", value: package.packageTone, accent: accent)
                        HFExportDistributionMetric(title: "Deliverables", value: "Draft", accent: accent)
                        HFExportDistributionMetric(title: "Media Kit", value: "Preview", accent: accent)
                        HFExportDistributionMetric(title: "Festival", value: "Local", accent: accent)
                        HFExportDistributionMetric(title: "Platform", value: "Deferred", accent: accent)
                        HFExportDistributionMetric(title: "Render / Export", value: "Protected", accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Distribution Package, local export distribution preview. The Friendly Distribution Package, \(package.plannerStatus)")
        .accessibilityIdentifier("hf.room.export.distributionHero")
    }
}

private struct HFExportDistributionMetric: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
            Text(value)
                .font(HFTypography.caption)
                .foregroundStyle(title == "Window" || title == "Tone" ? HFColors.textSecondary : accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFExportDistributionSectionSelector: View {
    let sections: [HFExportPackageSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Package Sections")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Local Selection", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                        Button {
                            selectedSectionIndex = index
                        } label: {
                            HFExportDistributionSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Distribution package sections for local export distribution preview")
        .accessibilityIdentifier("hf.room.export.distributionSections")
    }
}

private struct HFExportDistributionSectionCard: View {
    let section: HFExportPackageSection
    let isSelected: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                Image(systemName: section.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(isSelected ? .white : accent)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? Color.white.opacity(0.18) : accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(isSelected ? .white : HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: section.status, accent: isSelected ? .white : accent)
                }
            }

            Text(section.subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(isSelected ? .white.opacity(0.78) : HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                ForEach(Array(section.items.prefix(3))) { item in
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isSelected ? .white : accent)
                            .padding(.top, 2)
                        Text(item.title)
                            .font(HFTypography.micro)
                            .foregroundStyle(isSelected ? .white.opacity(0.78) : HFColors.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(width: 220, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(isSelected ? accent : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.82) : accent.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(section.title) section. \(section.status).")
    }
}

private struct HFExportDistributionDetailPanel: View {
    let section: HFExportPackageSection
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: section.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Selected Package Area", accent: accent)
                        Text("Selected Package Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFExportDistributionDetailRow(title: "Prepares", detail: section.prepares, accent: accent)
                    HFExportDistributionDetailRow(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFExportDistributionDetailRow(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.items) { item in
                        HFExportDistributionItemRow(item: item, accent: accent)
                    }
                }

                Text("Preview Package Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Package Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Package Area, \(section.title), \(section.prepares)")
        .accessibilityIdentifier("hf.room.export.distributionDetail")
    }
}

private struct HFExportDistributionDetailRow: View {
    let title: String
    let detail: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            HFRoomStatusChip(title: title, accent: accent)
            Text(detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct HFExportDistributionItemRow: View {
    let item: HFExportPackageItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: item.state, accent: accent)
                }
            }

            Text(item.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.state), \(item.detail)")
    }
}

private struct HFExportDistributionReadinessSummary: View {
    let rows: [HFExportPackageReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Distribution Readiness")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local", accent: accent)
                }

                VStack(spacing: HFSpacing.sm) {
                    ForEach(rows) { row in
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(row.title)
                                    .font(HFTypography.smallAction)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(row.detail)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: HFSpacing.sm)
                            HFRoomStatusChip(title: row.status, accent: accent)
                        }
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.055))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Distribution Readiness, \(rows.map { "\($0.title), \($0.status)" }.joined(separator: ", "))")
        .accessibilityIdentifier("hf.room.export.distributionReadiness")
    }
}

private struct HFExportDistributionBoundaryCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Safe Preview", accent: accent)
                    Text("Export Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local distribution-package preview. File handling, media library access, system handoff sheets, Render Engines, Export Engines, platform delivery, server submissions, and distribution services remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Safe Preview")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Export Safety Boundary, File handling Render Export Sharing Platform and server systems remain disconnected.")
        .accessibilityIdentifier("hf.room.export.distributionBoundary")
    }
}

private enum ExportSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case deliverables = "Deliverables"
    case mediaKit = "Media Kit"
    case festivalPackage = "Festival Package"
    case platformChecklist = "Platform Checklist"
    case distributionReadiness = "Distribution Readiness"
    case safetyBoundary = "Safety Boundary"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .overview: "rectangle.3.group.fill"
        case .deliverables: "shippingbox.fill"
        case .mediaKit: "photo.stack.fill"
        case .festivalPackage: "rosette"
        case .platformChecklist: "checklist.checked"
        case .distributionReadiness: "checkmark.seal.fill"
        case .safetyBoundary: "lock.shield.fill"
        }
    }

    var accessibilityName: String {
        switch self {
        case .overview: "Export Room overview section"
        case .deliverables: "Deliverables section, local preview of release package materials"
        case .mediaKit: "Media Kit section, preview of poster trailer stills synopsis credits and press readiness"
        case .festivalPackage: "Festival Package section, local preview of festival submission materials"
        case .platformChecklist: "Platform Checklist section, preview-only platform requirements"
        case .distributionReadiness: "Distribution Readiness section, local handoff map"
        case .safetyBoundary: "Export Safety Boundary section"
        }
    }
}

private struct ExportDeliverable: Identifiable {
    let id = UUID()
    let title: String
    let type: String
    let status: String
    let includes: [String]
    let systemImage: String
}

private struct ExportChecklistGroup: Identifiable {
    let id = UUID()
    let title: String
    let status: String
    let detail: String
    let items: [String]
    let systemImage: String
}

private struct ExportReadinessGroup: Identifiable {
    let id = UUID()
    let title: String
    let readiness: String
    let detail: String
    let checklist: [String]
    let systemImage: String
}

private enum ExportRoomData {
    static let overviewItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Deliverables", status: "Readiness Preview", detail: "Track the required materials for release, festivals, and platform delivery.", systemImage: "shippingbox.fill"),
        StudioChecklistItem(title: "Media Kit", status: "Preview", detail: "Prepare posters, stills, synopsis, credits, creator notes, and press copy.", systemImage: "photo.stack.fill"),
        StudioChecklistItem(title: "Festival Package", status: "Local Preview", detail: "Organize submission-ready materials for festival review.", systemImage: "rosette"),
        StudioChecklistItem(title: "Platform Checklist", status: "Protected", detail: "Preview requirements for future platform delivery.", systemImage: "checklist.checked"),
        StudioChecklistItem(title: "Distribution Readiness", status: "Preview", detail: "Review title package completeness before real export systems are connected.", systemImage: "checkmark.seal.fill"),
        StudioChecklistItem(title: "Launch Handoff", status: "Coming Soon", detail: "Carry campaign, audience, and release notes into delivery preparation.", systemImage: "flag.checkered")
    ]

    static let deliverables: [ExportDeliverable] = [
        ExportDeliverable(
            title: "Master Title Package",
            type: "Release package",
            status: "Needs Review",
            includes: ["Title metadata", "Synopsis", "Runtime notes", "Rating guidance"],
            systemImage: "film.stack.fill"
        ),
        ExportDeliverable(
            title: "Poster Package",
            type: "Marketing artwork",
            status: "Ready Preview",
            includes: ["Key art", "Thumbnail direction", "Vertical poster", "Horizontal backdrop"],
            systemImage: "photo.stack.fill"
        ),
        ExportDeliverable(
            title: "Trailer Package",
            type: "Preview assets",
            status: "In Review",
            includes: ["Trailer notes", "Teaser copy", "Premiere hook", "Caption guidance"],
            systemImage: "film.fill"
        ),
        ExportDeliverable(
            title: "Credit Package",
            type: "Production details",
            status: "Deferred",
            includes: ["Cast", "Crew", "Studio notes", "Rights notes preview"],
            systemImage: "person.text.rectangle.fill"
        ),
        ExportDeliverable(
            title: "Press Package",
            type: "Publicity material",
            status: "Preview",
            includes: ["Press blurb", "Creator statement", "Festival logline", "Audience positioning"],
            systemImage: "newspaper.fill"
        )
    ]

    static let mediaKitItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Poster", status: "Ready Preview", detail: "Key art and thumbnail direction are ready for visual review.", systemImage: "photo.fill"),
        StudioChecklistItem(title: "Backdrop", status: "Needs Review", detail: "Backdrop direction should support Watch, Launch, and delivery surfaces.", systemImage: "photo.on.rectangle.angled"),
        StudioChecklistItem(title: "Trailer", status: "Needs Review", detail: "Trailer positioning, teaser copy, and premiere hook need final polish.", systemImage: "film.fill"),
        StudioChecklistItem(title: "Teaser", status: "Coming Soon", detail: "Short-form teaser planning remains display-only.", systemImage: "play.rectangle.fill"),
        StudioChecklistItem(title: "Stills", status: "Needs Review", detail: "Still selections remain preview references only.", systemImage: "rectangle.stack.fill"),
        StudioChecklistItem(title: "Synopsis", status: "Ready", detail: "Short and long synopsis support streaming and press surfaces.", systemImage: "doc.text.fill"),
        StudioChecklistItem(title: "Credits", status: "Deferred", detail: "Credits remain a readiness item until final review.", systemImage: "person.2.fill"),
        StudioChecklistItem(title: "Creator Notes", status: "Preview", detail: "Creator statement and behind-the-scenes context are prepared for launch handoff.", systemImage: "note.text"),
        StudioChecklistItem(title: "Press Blurb", status: "Preview", detail: "Press copy frames the public story without publishing.", systemImage: "newspaper.fill"),
        StudioChecklistItem(title: "Audience Hook", status: "Ready", detail: "The launch hook carries into professional package review.", systemImage: "sparkles")
    ]

    static let festivalGroups: [ExportChecklistGroup] = [
        ExportChecklistGroup(title: "Story Package", status: "Preview", detail: "Core story materials for festival review.", items: ["Logline", "Short synopsis", "Long synopsis", "Director statement", "Genre and tone"], systemImage: "text.quote"),
        ExportChecklistGroup(title: "Visual Package", status: "Needs Review", detail: "Visual references for selection committees and press.", items: ["Poster", "Stills", "Trailer notes", "Backdrop", "Thumbnail direction"], systemImage: "photo.stack.fill"),
        ExportChecklistGroup(title: "Credits Package", status: "Deferred", detail: "Production details remain local planning data.", items: ["Cast", "Crew", "Studio", "Runtime", "Language"], systemImage: "person.text.rectangle.fill"),
        ExportChecklistGroup(title: "Press Package", status: "Preview", detail: "Public-facing materials for review and coverage.", items: ["Press blurb", "Creator bio", "Audience positioning", "Festival notes", "Review quote placeholder"], systemImage: "newspaper.fill"),
        ExportChecklistGroup(title: "Submission Readiness", status: "Protected", detail: "No real submission, accounts, forms, or delivery systems are connected.", items: ["Materials review", "Rights notes preview", "Delivery notes", "Contact details deferred", "Platform handoff protected"], systemImage: "lock.shield.fill")
    ]

    static let platformGroups: [ExportChecklistGroup] = [
        ExportChecklistGroup(title: "HighFive Cinema", status: "Preview", detail: "Requirements for the local HighFive streaming surface.", items: ["Movie detail package", "Poster/backdrop readiness", "Watch surface copy", "Related title placement", "Launch handoff notes"], systemImage: "play.rectangle.fill"),
        ExportChecklistGroup(title: "Streaming Platform Package", status: "Protected", detail: "Future package requirements without delivery infrastructure.", items: ["Title metadata", "Runtime", "Synopsis", "Artwork package", "Trailer notes"], systemImage: "tv.fill"),
        ExportChecklistGroup(title: "Festival Platform Package", status: "Local Preview", detail: "Festival-facing materials prepared as static readiness copy.", items: ["Festival synopsis", "Director statement", "Press materials", "Stills", "Screening notes"], systemImage: "rosette"),
        ExportChecklistGroup(title: "Marketing Package", status: "Preview", detail: "Promotion materials carried forward from Launch.", items: ["Poster", "Social-safe copy", "Trailer hook", "Audience angle", "Creator notes"], systemImage: "megaphone.fill"),
        ExportChecklistGroup(title: "Distribution Package", status: "Coming Soon", detail: "Future distribution handoff remains protected and local-only.", items: ["Deliverable list", "Platform notes", "Rights notes preview", "Export handoff", "Final review"], systemImage: "shippingbox.fill")
    ]

    static let readinessGroups: [ExportReadinessGroup] = [
        ExportReadinessGroup(title: "Watch Surface", readiness: "Preview", detail: "Consumer-facing title presentation is ready for package review.", checklist: ["Movie Detail ready", "Poster/backdrop ready", "Watch Now preview", "Related titles", "My List routing"], systemImage: "play.rectangle.fill"),
        ExportReadinessGroup(title: "Create Package", readiness: "Readiness", detail: "Creator-side story materials are gathered for delivery prep.", checklist: ["Creator profile", "Pitch summary", "Media kit", "Production notes", "Story positioning"], systemImage: "wand.and.stars"),
        ExportReadinessGroup(title: "Connect Surface", readiness: "Preview", detail: "Audience energy supports the final handoff story.", checklist: ["Community preview", "Reactions preview", "Creator updates", "Audience energy", "Watch community"], systemImage: "person.2.fill"),
        ExportReadinessGroup(title: "Launch Package", readiness: "Local Preview", detail: "Release planning carries into export readiness.", checklist: ["Campaign preview", "Timeline", "Audience buildup", "Release status", "Materials readiness"], systemImage: "flag.checkered"),
        ExportReadinessGroup(title: "Export Package", readiness: "Protected", detail: "Professional package stays local until real systems exist.", checklist: ["Deliverables", "Media kit", "Festival package", "Platform checklist", "Distribution handoff"], systemImage: "shippingbox.fill")
    ]

    static let safetyItems: [StudioChecklistItem] = [
        StudioChecklistItem(title: "Export Engine", status: "Protected", detail: "No export engine is connected to this room.", systemImage: "shippingbox.fill"),
        StudioChecklistItem(title: "Render Engine", status: "Protected", detail: "Rendering systems remain outside this SwiftUI preview.", systemImage: "viewfinder"),
        StudioChecklistItem(title: "File Writing", status: "Deferred", detail: "No folders, documents, or generated packages are written.", systemImage: "doc.badge.gearshape"),
        StudioChecklistItem(title: "Photos", status: "Deferred", detail: "No photo library or picker access is introduced.", systemImage: "photo"),
        StudioChecklistItem(title: "Share Sheets", status: "Deferred", detail: "No share or system handoff surfaces are connected.", systemImage: "square.and.arrow.up"),
        StudioChecklistItem(title: "Platform Delivery", status: "Deferred", detail: "Delivery endpoints remain future planning only.", systemImage: "paperplane.fill"),
        StudioChecklistItem(title: "Backend", status: "Deferred", detail: "Export Room uses local static SwiftUI data only.", systemImage: "server.rack"),
        StudioChecklistItem(title: "Distribution APIs", status: "Deferred", detail: "No distributor or platform submission APIs are connected.", systemImage: "network")
    ]
}

private struct ExportRoomView: View {
    @State private var selectedExportSection: ExportSection = .overview
    private let accent = Color.purple

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                HFProductRoomHero(
                    eyebrow: "EXPORT",
                    title: "Export Room",
                    subtitle: "Prepare deliverables, media kits, and platform packages.",
                    purpose: "This room previews professional readiness and distribution preparation.",
                    heroCopy: "A professional space for title deliverables, media kits, festival packages, distribution readiness, and platform handoff preparation.",
                    status: "Readiness Preview",
                    systemImage: "shippingbox.fill",
                    accent: accent
                )

                HFRoomExperienceStrip(
                    accent: accent,
                    items: ["Deliverables", "Media kit", "Handoff"]
                )

                HFExportDistributionPackageSection(package: HFExportDistributionPackagePreviewData.package, accent: accent)
                HFRoomDepthSnapshotStrip(accent: accent)
                HFRoomWorkflowDrilldownSection(plan: HFRoomWorkflowDrilldownPlans.export, accent: accent, roomID: "export")
                HFRoomGuidedWorkflowSection(plan: HFRoomWorkflowPlans.export, accent: accent, roomID: "export")
                HFRoomReadinessPanel(blueprint: HFRoomDepthData.export, accent: accent)
                HFRoomPipelineStrip(stages: HFRoomDepthData.export.pipelineStages, accent: accent)
                HFRoomWorkflowDepthPanel(steps: HFRoomDepthData.export.workflowSteps, accent: accent)

                exportSectionSelector
                selectedSectionView
                    .accessibilityIdentifier("hf.room.export.features")
                HFRoomSafeBoundaryCard(blueprint: HFRoomDepthData.export, accent: accent)
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Export Room")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("hf.room.export.root")
    }

    private var exportSectionSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(ExportSection.allCases) { section in
                    Button {
                        selectedExportSection = section
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: section.systemImage)
                                .font(.system(size: 12, weight: .bold))
                            Text(section.rawValue)
                        }
                        .font(HFTypography.micro)
                        .foregroundStyle(selectedExportSection == section ? .white : HFColors.textSecondary)
                        .padding(.horizontal, HFSpacing.sm)
                        .padding(.vertical, 10)
                        .background(selectedExportSection == section ? accent : Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(selectedExportSection == section ? accent.opacity(0.78) : HFColors.glassStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(section.accessibilityName)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Export Room section selector")
    }

    @ViewBuilder
    private var selectedSectionView: some View {
        switch selectedExportSection {
        case .overview:
            overviewSection
        case .deliverables:
            deliverablesSection
        case .mediaKit:
            mediaKitSection
        case .festivalPackage:
            festivalPackageSection
        case .platformChecklist:
            platformChecklistSection
        case .distributionReadiness:
            distributionReadinessSection
        case .safetyBoundary:
            exportSafetyBoundary
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Export Overview", subtitle: "The local command surface for professional package readiness.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(ExportRoomData.overviewItems) { item in
                    StudioChecklistCard(item: item, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Export Room overview cards")
    }

    private var deliverablesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Deliverables", subtitle: "Professional package checklist without file management or generation.")

            VStack(spacing: HFSpacing.md) {
                ForEach(ExportRoomData.deliverables) { deliverable in
                    ExportDeliverableCard(deliverable: deliverable, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Deliverables section, local preview of release package materials")
    }

    private var mediaKitSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Media Kit", subtitle: "Organize readiness copy without touching assets or file systems.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(ExportRoomData.mediaKitItems) { item in
                    StudioChecklistCard(item: item, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Media Kit section, preview of poster trailer stills synopsis credits and press readiness")
    }

    private var festivalPackageSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Festival Package", subtitle: "Submission readiness preview with no forms, uploads, accounts, or payments.")

            VStack(spacing: HFSpacing.md) {
                ForEach(ExportRoomData.festivalGroups) { group in
                    ExportChecklistGroupCard(group: group, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Festival Package section, local preview of festival submission materials")
    }

    private var platformChecklistSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Platform Checklist", subtitle: "Preview future platform requirements without delivery endpoints.")

            VStack(spacing: HFSpacing.md) {
                ForEach(ExportRoomData.platformGroups) { group in
                    ExportChecklistGroupCard(group: group, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Platform Checklist section, preview-only platform requirements")
    }

    private var distributionReadinessSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Distribution Readiness", subtitle: "Manual Watch, Create, Connect, Launch, and Export handoff map.")

            VStack(spacing: HFSpacing.md) {
                ForEach(ExportRoomData.readinessGroups) { group in
                    ExportReadinessGroupCard(group: group, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Distribution Readiness section, local handoff map")
    }

    private var exportSafetyBoundary: some View {
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
                        Text("Export Safety Boundary")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Export Room is a local product preview. Rendering, export engine, file writing, Photos, share sheets, platform delivery, backend submissions, and distribution APIs remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Protected for this phase.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                    }
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                    ForEach(ExportRoomData.safetyItems) { item in
                        StudioSafetyChip(item: item)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Export Safety Boundary, export engine rendering file writing Photos share sheets platform delivery backend and distribution APIs remain disconnected")
    }
}

private struct ExportDeliverableCard: View {
    let deliverable: ExportDeliverable
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: deliverable.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 44, height: 44)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(deliverable.title)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                            HFRoomStatusChip(title: deliverable.status, accent: accent)
                        }
                        Text(deliverable.type)
                            .font(HFTypography.caption)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(deliverable.includes, id: \.self) { item in
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(accent)
                                .padding(.top, 2)
                            Text(item)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    LaunchPassiveCTA(title: "Review Package", accent: accent)
                    LaunchPassiveCTA(title: "Preview Checklist", accent: accent)
                    LaunchPassiveCTA(title: "Check Readiness", accent: accent)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(deliverable.title), \(deliverable.type), \(deliverable.status)")
    }
}

private struct ExportChecklistGroupCard: View {
    let group: ExportChecklistGroup
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: group.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 44, height: 44)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(group.title)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                            HFRoomStatusChip(title: group.status, accent: accent)
                        }
                        Text(group.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(group.items, id: \.self) { item in
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(accent)
                                .padding(.top, 2)
                            Text(item)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(group.title), \(group.status), \(group.detail)")
    }
}

private struct ExportReadinessGroupCard: View {
    let group: ExportReadinessGroup
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: group.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 44, height: 44)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(group.title)
                                .font(HFTypography.smallAction)
                                .foregroundStyle(HFColors.textPrimary)
                            HFRoomStatusChip(title: group.readiness, accent: accent)
                        }
                        Text(group.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(group.checklist, id: \.self) { item in
                        HStack(alignment: .top, spacing: HFSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(accent)
                                .padding(.top, 2)
                            Text(item)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                        }
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(group.title), \(group.readiness), \(group.detail)")
    }
}

private struct HFRoomGuidedWorkflowSection: View {
    let plan: HFRoomWorkflowPlan
    let accent: Color
    let roomID: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFRoomWorkflowFocusCard(plan: plan, accent: accent)
            HFRoomWorkflowTimeline(stages: plan.stages, accent: accent)
            HFRoomWorkflowChecklist(items: plan.checklist, accent: accent, roomID: roomID)
            HFRoomWorkflowNextStepCard(plan: plan, accent: accent, roomID: roomID)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(plan.title), guided local workflow, \(plan.subtitle)")
        .accessibilityIdentifier("hf.room.\(roomID).workflow")
    }
}

private struct HFRoomWorkflowFocusCard: View {
    let plan: HFRoomWorkflowPlan
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Guided Workflow", accent: accent)
                        Text(plan.title)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(plan.subtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    HFRoomWorkflowMetric(title: "Stages", value: "\(plan.stages.count)", accent: accent)
                    HFRoomWorkflowMetric(title: "Checklist", value: "\(plan.checklist.count)", accent: accent)
                    HFRoomWorkflowMetric(title: "Mode", value: "Local", accent: accent)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plan.title), \(plan.stages.count) stages, \(plan.checklist.count) checklist items, local mode")
    }
}

private struct HFRoomWorkflowMetric: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(value)
                .font(HFTypography.smallAction)
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFRoomWorkflowTimeline: View {
    let stages: [HFRoomWorkflowStage]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Workflow Timeline")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Preview", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        HFRoomWorkflowStageCard(stage: stage, index: index + 1, accent: accent)

                        if index < stages.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(accent.opacity(0.70))
                                .padding(.top, 54)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Workflow Timeline, \(stages.map(\.title).joined(separator: ", "))")
    }
}

private struct HFRoomWorkflowStageCard: View {
    let stage: HFRoomWorkflowStage
    let index: Int
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HStack(spacing: HFSpacing.xs) {
                    Text("\(index)")
                        .font(HFTypography.micro)
                        .foregroundStyle(.black)
                        .frame(width: 22, height: 22)
                        .background(accent)
                        .clipShape(Circle())

                    Image(systemName: stage.systemImage)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(accent)
                }

                Text(stage.title)
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                HFRoomStatusChip(title: stage.status, accent: accent)

                Text(stage.subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 158, alignment: .leading)
            .padding(HFSpacing.sm)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Stage \(index), \(stage.title), \(stage.status), \(stage.subtitle)")
    }
}

private struct HFRoomWorkflowChecklist: View {
    let items: [HFRoomWorkflowChecklistItem]
    let accent: Color
    let roomID: String

    private let columns = [
        GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Workflow Checklist")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Manual", accent: accent)
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.sm) {
                ForEach(items) { item in
                    HFRoomWorkflowChecklistCard(item: item, accent: accent)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Workflow Checklist, \(items.count) local checklist items")
        .accessibilityIdentifier("hf.room.\(roomID).checklist")
    }
}

private struct HFRoomWorkflowChecklistCard: View {
    let item: HFRoomWorkflowChecklistItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text(item.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: item.state, accent: accent)
                }
            }

            Text(item.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(accent.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.state), \(item.detail)")
    }
}

private struct HFRoomWorkflowNextStepCard: View {
    let plan: HFRoomWorkflowPlan
    let accent: Color
    let roomID: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Next Step", accent: accent)
                    Text(plan.nextStepTitle)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(plan.nextStepSubtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(plan.nextStepActionTitle)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.sm)
                        .padding(.vertical, 10)
                        .background(accent)
                        .clipShape(Capsule())
                        .padding(.top, HFSpacing.xs)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Next step, \(plan.nextStepTitle), \(plan.nextStepSubtitle), \(plan.nextStepActionTitle)")
        .accessibilityIdentifier("hf.room.\(roomID).nextStep")
    }
}

private struct HFRoomWorkflowDrilldownSection: View {
    let plan: HFRoomWorkflowDrilldownPlan
    let accent: Color
    let roomID: String
    @State private var selectedStageIndex = 0

    private var selectedStage: HFRoomWorkflowDrilldown {
        guard plan.stages.indices.contains(selectedStageIndex) else {
            return plan.stages[0]
        }
        return plan.stages[selectedStageIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "rectangle.3.group.bubble.left.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 46, height: 46)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomLocalPreviewBadge(title: "Local Drilldown", accent: accent)
                    Text(plan.title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(plan.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HFRoomWorkflowStageSelector(
                stages: plan.stages,
                selectedStageIndex: $selectedStageIndex,
                accent: accent,
                roomID: roomID
            )

            HFRoomWorkflowDetailPanel(
                stage: selectedStage,
                ctaTitle: plan.ctaTitle,
                accent: accent,
                roomID: roomID
            )
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(plan.title), selected stage \(selectedStage.title), local drilldown preview")
        .accessibilityIdentifier("hf.room.\(roomID).drilldown")
    }
}

private struct HFRoomWorkflowStageSelector: View {
    let stages: [HFRoomWorkflowDrilldown]
    @Binding var selectedStageIndex: Int
    let accent: Color
    let roomID: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Select Stage")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Tap to inspect", accent: accent)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        Button {
                            selectedStageIndex = index
                        } label: {
                            HFRoomWorkflowSelectorChip(
                                stage: stage,
                                index: index + 1,
                                isSelected: selectedStageIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(stage.title), \(stage.status), selected stage \(selectedStageIndex == index ? "yes" : "no")")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Stage selector, local stage choices")
        .accessibilityIdentifier("hf.room.\(roomID).stageSelector")
    }
}

private struct HFRoomWorkflowSelectorChip: View {
    let stage: HFRoomWorkflowDrilldown
    let index: Int
    let isSelected: Bool
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(spacing: HFSpacing.xs) {
                Text("\(index)")
                    .font(HFTypography.micro)
                    .foregroundStyle(isSelected ? .black : accent)
                    .frame(width: 22, height: 22)
                    .background(isSelected ? accent : accent.opacity(0.12))
                    .clipShape(Circle())

                Image(systemName: stage.systemImage)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? .black : accent)
            }

            Text(stage.title)
                .font(HFTypography.smallAction)
                .foregroundStyle(isSelected ? .black : HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text(stage.subtitle)
                .font(HFTypography.micro)
                .foregroundStyle(isSelected ? .black.opacity(0.72) : HFColors.textMuted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 150, alignment: .topLeading)
        .frame(minHeight: 108, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isSelected ? accent : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isSelected ? accent.opacity(0.82) : accent.opacity(0.24), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFRoomWorkflowDetailPanel: View {
    let stage: HFRoomWorkflowDrilldown
    let ctaTitle: String
    let accent: Color
    let roomID: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: stage.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 50, height: 50)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Selected Stage", accent: accent)
                            HFRoomStatusChip(title: stage.status, accent: accent)
                        }

                        Text(stage.detailTitle)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(stage.detailBody)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HFRoomWorkflowChecklistPreview(items: stage.checklist, accent: accent)

                Text(ctaTitle)
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("safe preview CTA, \(ctaTitle)")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Detail panel, selected stage \(stage.title), \(stage.detailBody), local checklist preview")
        .accessibilityIdentifier("hf.room.\(roomID).detailPanel")
    }
}

private struct HFRoomWorkflowChecklistPreview: View {
    let items: [String]
    let accent: Color

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: HFSpacing.sm)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Local Checklist Preview")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Static", accent: accent)
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.sm) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(accent)
                            .padding(.top, 2)

                        Text(item)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(HFSpacing.sm)
                    .background(Color.white.opacity(0.055))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("local checklist preview, \(items.joined(separator: ", "))")
    }
}

private struct HFRoomLocalPreviewBadge: View {
    let title: String
    let accent: Color

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, HFSpacing.sm)
            .padding(.vertical, 7)
            .background(accent.opacity(0.12))
            .overlay(
                Capsule()
                    .stroke(accent.opacity(0.35), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

private struct HFRoomReadinessPanel: View {
    let blueprint: HFRoomDepthBlueprint
    let accent: Color

    private let columns = [
        GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)
    ]

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: CGFloat(blueprint.readinessScore) / 100)
                            .stroke(accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(blueprint.readinessScore)%")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.textPrimary)
                    }
                    .frame(width: 62, height: 62)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Readiness Panel", accent: accent)
                        Text(blueprint.readinessTitle)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(blueprint.readinessSubtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                StudioProgressBar(title: "Room depth score", value: blueprint.readinessScore, accent: accent)

                LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(blueprint.readinessSignals) { signal in
                        HFRoomReadinessSignalCard(signal: signal, accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(blueprint.readinessTitle), \(blueprint.readinessScore) percent, \(blueprint.readinessSubtitle)")
    }
}

private struct HFRoomReadinessSignalCard: View {
    let signal: HFRoomReadinessSignal
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: signal.systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(accent.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            Text(signal.title)
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HFRoomStatusChip(title: signal.value, accent: accent)

            Text(signal.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(signal.title), \(signal.value), \(signal.detail)")
    }
}

private struct HFRoomPipelineStrip: View {
    let stages: [HFRoomPipelineStage]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Pipeline")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Spacer()
                HFRoomStatusChip(title: "Static Flow", accent: accent)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.sm) {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        HFRoomPipelineStageCard(stage: stage, index: index + 1, accent: accent)

                        if index < stages.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(accent.opacity(0.82))
                        }
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Room pipeline, \(stages.map(\.title).joined(separator: ", "))")
    }
}

private struct HFRoomPipelineStageCard: View {
    let stage: HFRoomPipelineStage
    let index: Int
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HStack(spacing: HFSpacing.xs) {
                    Text("\(index)")
                        .font(HFTypography.micro)
                        .foregroundStyle(.black)
                        .frame(width: 22, height: 22)
                        .background(accent)
                        .clipShape(Circle())

                    Image(systemName: stage.systemImage)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accent)
                }

                Text(stage.title)
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(stage.status)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .frame(width: 112, alignment: .leading)
            .padding(HFSpacing.sm)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pipeline stage \(index), \(stage.title), \(stage.status)")
    }
}

private struct HFRoomWorkflowDepthPanel: View {
    let steps: [HFRoomWorkflowStep]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Workflow Depth", subtitle: "A local, reviewable path through this room.")

            VStack(spacing: HFSpacing.sm) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    HFRoomWorkflowStepRow(step: step, index: index + 1, accent: accent)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Workflow Depth section")
    }
}

private struct HFRoomWorkflowStepRow: View {
    let step: HFRoomWorkflowStep
    let index: Int
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.24)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                        .fill(accent.opacity(0.14))
                    VStack(spacing: 2) {
                        Image(systemName: step.systemImage)
                            .font(.system(size: 13, weight: .bold))
                        Text("\(index)")
                            .font(HFTypography.micro)
                    }
                    .foregroundStyle(accent)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(step.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        HFRoomStatusChip(title: step.status, accent: accent)
                    }

                    Text(step.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Workflow step \(index), \(step.title), \(step.status), \(step.detail)")
    }
}

private struct HFRoomSafeBoundaryCard: View {
    let blueprint: HFRoomDepthBlueprint
    let accent: Color

    private let columns = [
        GridItem(.adaptive(minimum: 140), spacing: HFSpacing.sm)
    ]

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Safe Boundary", accent: accent)
                        Text(blueprint.boundaryTitle)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(blueprint.boundarySubtitle)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(blueprint.boundaryItems) { item in
                        HFRoomBoundaryMiniCard(item: item, accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(blueprint.boundaryTitle), \(blueprint.boundarySubtitle)")
    }
}

private struct HFRoomBoundaryMiniCard: View {
    let item: HFRoomBoundaryItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: item.systemImage)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 34, height: 34)
                .background(accent.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            Text(item.title)
                .font(HFTypography.smallAction)
                .foregroundStyle(HFColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(item.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), \(item.detail)")
    }
}

private struct HFRoomDepthSnapshotStrip: View {
    let accent: Color

    private let items: [(title: String, subtitle: String, systemImage: String)] = [
        ("Readiness", "Cards visible", "gauge.with.dots.needle.67percent"),
        ("Workflow", "Section ready", "point.3.connected.trianglepath.dotted"),
        ("Boundary", "Safe card", "lock.shield.fill")
    ]

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack {
                    Text("Room Product Depth")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local UI", accent: accent)
                }

                HStack(spacing: HFSpacing.sm) {
                    ForEach(items, id: \.title) { item in
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: item.systemImage)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(accent)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(HFTypography.micro)
                                    .foregroundStyle(HFColors.textPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.72)
                                Text(item.subtitle)
                                    .font(HFTypography.micro)
                                    .foregroundStyle(HFColors.textMuted)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.72)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, HFSpacing.xs)
                        .padding(.vertical, 9)
                        .background(accent.opacity(0.10))
                        .overlay(
                            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                                .stroke(accent.opacity(0.24), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
                    }
                }
            }
            .padding(HFSpacing.sm)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Room Product Depth, readiness cards visible, workflow section ready, safe boundary card")
    }
}

private struct HFRoomExperienceStrip: View {
    let accent: Color
    let items: [String]

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.26)) {
            HStack(spacing: HFSpacing.sm) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 10, weight: .bold))
                        Text(item)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)
                    }
                    .font(HFTypography.micro)
                    .foregroundStyle(accent)
                    .padding(.horizontal, HFSpacing.xs)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(accent.opacity(0.10))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(accent.opacity(0.28), lineWidth: 1))
                }
            }
            .padding(HFSpacing.sm)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Room signals, \(items.joined(separator: ", "))")
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

                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: 170, height: 170)
                    .blur(radius: 18)
                    .offset(x: 62, y: -54)

                Circle()
                    .fill(HFColors.warmGlow.opacity(0.16))
                    .frame(width: 220, height: 220)
                    .blur(radius: 24)
                    .offset(x: -118, y: 132)

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
        .accessibilityIdentifier("hf.room.\(eyebrow.lowercased()).hero")
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
                productSpineSection
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
        .accessibilityIdentifier("hf.developerQa.root")
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
                            checkpointRow(label: "Current Checkpoint", value: "Phase 17.0A HighFive Rooms Ecosystem QA Lock")
                            checkpointRow(label: "Last Known Commit", value: "1db931a")
                            checkpointRow(label: "Last Known Tag", value: "phase-13-0a-creator-studio-room")
                            checkpointRow(label: "Primary Status", value: "Ecosystem Spine QA Lock", isProminent: true)
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

    private var productSpineSection: some View {
        hubSection(
            title: "Product Spine",
            subtitle: "Internal read-only map for Watch, Create, Connect, Launch, and Export."
        ) {
            VStack(spacing: HFSpacing.md) {
                ForEach(HFDeveloperQAData.productSpine) { pillar in
                    QAProductSpineCard(pillar: pillar)
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
                    title: "Consumer + Rooms Demo Tour",
                    subtitle: "Guided proof path for Watch, HighFive Rooms, Product Spine, and internal safety.",
                    systemImage: "play.rectangle.on.rectangle.fill"
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title) section")
        .accessibilityIdentifier(hubSectionIdentifier(for: title))
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
        .accessibilityLabel("\(title), \(subtitle)")
        .accessibilityIdentifier(toolIdentifier(for: title))
    }

    private func hubSectionIdentifier(for title: String) -> String {
        switch title {
        case "Product Spine": "hf.developerQa.productSpineButton"
        case "Visual Parity Center": "hf.developerQa.visualParityButton"
        case "Protected Systems Seal": "hf.developerQa.protectedSystemsButton"
        case "Route Quality Center": "hf.developerQa.routeQualityButton"
        case "Build + Launch Checklist": "hf.developerQa.buildChecklistButton"
        case "Screenshot Review": "hf.developerQa.screenshotReviewButton"
        default: "hf.developerQa.section.\(qaIdentifierSlug(title))"
        }
    }

    private func toolIdentifier(for title: String) -> String {
        switch title {
        case "Consumer + Rooms Demo Tour": "hf.developerQa.consumerRoomsDemoTourButton"
        case "Product Spine": "hf.developerQa.productSpineButton"
        case "Route Quality Center": "hf.developerQa.routeQualityButton"
        case "Visual Parity Backlog": "hf.developerQa.visualParityButton"
        case "Spine Safety Seal": "hf.developerQa.protectedSystemsButton"
        default: "hf.developerQa.tool.\(qaIdentifierSlug(title))"
        }
    }

    private func qaIdentifierSlug(_ value: String) -> String {
        value
            .lowercased()
            .map { character in
                character.isLetter || character.isNumber ? character : "-"
            }
            .reduce(into: "") { result, character in
                if character == "-", result.last == "-" {
                    return
                }
                result.append(character)
            }
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
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

private struct HFQAProductSpinePillar: Identifiable {
    let id = UUID()
    let pillar: String
    let room: String
    let primarySurfaces: [String]
    let status: HFQAStatus
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

    static let productSpine: [HFQAProductSpinePillar] = [
        HFQAProductSpinePillar(
            pillar: "WATCH",
            room: "Watch Room",
            primarySurfaces: ["Home", "Search / Discover", "Library", "Downloads", "Movie Detail"],
            status: .passed,
            systemImage: "play.rectangle.fill"
        ),
        HFQAProductSpinePillar(
            pillar: "CREATE",
            room: "Creator Studio",
            primarySurfaces: ["Overview", "Projects", "Creator Profile", "Pitch", "Media Kit", "Launch Prep"],
            status: .passed,
            systemImage: "wand.and.stars"
        ),
        HFQAProductSpinePillar(
            pillar: "CONNECT",
            room: "Connect Room",
            primarySurfaces: ["Overview", "Communities", "Reactions", "Following", "Creator Updates", "Watch Community"],
            status: .passed,
            systemImage: "person.2.fill"
        ),
        HFQAProductSpinePillar(
            pillar: "LAUNCH",
            room: "Launch Room",
            primarySurfaces: ["Overview", "Timeline", "Campaign", "Audience", "Materials", "Release Readiness"],
            status: .passed,
            systemImage: "flag.checkered"
        ),
        HFQAProductSpinePillar(
            pillar: "EXPORT",
            room: "Export Room",
            primarySurfaces: ["Overview", "Deliverables", "Media Kit", "Festival Package", "Platform Checklist", "Distribution Readiness"],
            status: .passed,
            systemImage: "shippingbox.fill"
        )
    ]

    static let routeValidations: [HFQARouteValidation] = [
        HFQARouteValidation(route: "Home -> Movie Detail", expectedBehavior: "Tap a poster or featured title and open Movie Detail.", status: .needsManualQA, notes: "Confirm navigation works without exposing internal tools."),
        HFQARouteValidation(route: "Search -> Movie Detail", expectedBehavior: "Search results open the selected Movie Detail screen.", status: .needsManualQA, notes: "Local search only."),
        HFQARouteValidation(route: "Discover -> Movie Detail", expectedBehavior: "Discovery rails route into Movie Detail.", status: .needsManualQA, notes: "No consumer route matrix."),
        HFQARouteValidation(route: "Library -> Movie Detail", expectedBehavior: "Saved and in-progress titles open Movie Detail.", status: .needsManualQA, notes: "Validate My List behavior."),
        HFQARouteValidation(route: "Downloads -> Movie Detail", expectedBehavior: "Downloaded local titles open detail where supported.", status: .needsManualQA, notes: "No file-system behavior."),
        HFQARouteValidation(route: "Profile -> Settings", expectedBehavior: "Settings opens local preview copy only.", status: .passed, notes: "No live account service."),
        HFQARouteValidation(route: "Profile -> HighFive Rooms / room section", expectedBehavior: "HighFive Rooms appears below consumer profile actions.", status: .passed, notes: "Product rooms stay inside Profile."),
        HFQARouteValidation(route: "Profile -> Watch Room", expectedBehavior: "Watch Room opens as the streaming product room.", status: .passed, notes: "No new bottom tab."),
        HFQARouteValidation(route: "Profile -> Creator Studio", expectedBehavior: "Creator Studio opens as the Create product room.", status: .passed, notes: "Separate from Developer / QA."),
        HFQARouteValidation(route: "Profile -> Connect Room", expectedBehavior: "Connect Room opens as the community preview room.", status: .passed, notes: "Separate from Creator Studio."),
        HFQARouteValidation(route: "Profile -> Launch Room", expectedBehavior: "Launch Room opens as the release readiness room.", status: .passed, notes: "No payment or campaign systems."),
        HFQARouteValidation(route: "Profile -> Export Room", expectedBehavior: "Export Room opens as the deliverables readiness room.", status: .passed, notes: "No export, render, or file systems."),
        HFQARouteValidation(route: "Profile -> Developer / QA Hub", expectedBehavior: "Internal hub is reachable only from Profile.", status: .passed, notes: "No new bottom tab."),
        HFQARouteValidation(route: "Developer / QA Hub -> Product Spine", expectedBehavior: "Product Spine appears as an internal validation section.", status: .passed, notes: "Read-only static QA surface."),
        HFQARouteValidation(route: "Developer / QA Hub -> Visual Parity", expectedBehavior: "Visual Parity Center lists locked Figma authority.", status: .passed, notes: "No Figma mutation."),
        HFQARouteValidation(route: "Developer / QA Hub -> Protected Systems Seal", expectedBehavior: "Protected systems are listed as locked.", status: .protected, notes: "No unlock, edit, or repair actions."),
        HFQARouteValidation(route: "Developer / QA Hub -> Screenshot Review", expectedBehavior: "Screenshot Review lists expected manual capture targets.", status: .needsManualQA, notes: "No file picker or Photos integration.")
    ]

    static let buildChecklist: [HFQAStatusItem] = [
        HFQAStatusItem(title: "git status clean", status: .needsReview, detail: "Manual repo check before commit.", systemImage: "checkmark.circle"),
        HFQAStatusItem(title: "protected-path scan passed", status: .needsReview, detail: "No protected paths changed.", systemImage: "lock.shield"),
        HFQAStatusItem(title: "forbidden import scan passed", status: .needsReview, detail: "No live-service imports added.", systemImage: "magnifyingglass"),
        HFQAStatusItem(title: "xcodebuild passed", status: .needsReview, detail: "Simulator build must pass before promotion.", systemImage: "hammer"),
        HFQAStatusItem(title: "app installed on simulator", status: .needsReview, detail: "Install on booted simulator when available.", systemImage: "iphone.and.arrow.forward"),
        HFQAStatusItem(title: "app launched on simulator", status: .needsReview, detail: "Launch the HighFive app bundle.", systemImage: "play.fill"),
        HFQAStatusItem(title: "screenshots captured", status: .needed, detail: "Capture consumer screens for visual review.", systemImage: "camera"),
        HFQAStatusItem(title: "rooms verified", status: .needsReview, detail: "Verify Watch, Creator Studio, Connect, Launch, and Export.", systemImage: "rectangle.3.group.fill"),
        HFQAStatusItem(title: "product spine locked", status: .needsReview, detail: "Confirm Product Spine maps all five pillars.", systemImage: "point.3.connected.trianglepath.dotted"),
        HFQAStatusItem(title: "commit created", status: .deferred, detail: "Only after build and scans pass.", systemImage: "checkmark.seal"),
        HFQAStatusItem(title: "tag created", status: .deferred, detail: "Only after complete phase checkpoint.", systemImage: "tag")
    ]

    static let screenshotReviews: [HFQAScreenshotReview] = [
        HFQAScreenshotReview(screen: "Home", expectedName: "highfive-ecosystem-home.png", status: .needed, reviewFocus: "Consumer streaming first impression."),
        HFQAScreenshotReview(screen: "Discover/Search", expectedName: "highfive-ecosystem-discover.png", status: .needed, reviewFocus: "Content discovery and filter treatment."),
        HFQAScreenshotReview(screen: "Movie Detail", expectedName: "highfive-ecosystem-movie-detail.png", status: .needed, reviewFocus: "Cinematic title page and actions."),
        HFQAScreenshotReview(screen: "Downloads", expectedName: "highfive-ecosystem-downloads.png", status: .needed, reviewFocus: "Offline shelf and download rows."),
        HFQAScreenshotReview(screen: "Profile", expectedName: "highfive-ecosystem-profile.png", status: .needed, reviewFocus: "Consumer-first profile, HighFive Rooms visible, Developer / QA separate."),
        HFQAScreenshotReview(screen: "Watch Room", expectedName: "highfive-ecosystem-watch-room.png", status: .needed, reviewFocus: "Streaming room with no AVPlayer integration."),
        HFQAScreenshotReview(screen: "Creator Studio", expectedName: "highfive-ecosystem-creator-studio.png", status: .needed, reviewFocus: "Project, pitch, media kit, and launch prep structure."),
        HFQAScreenshotReview(screen: "Connect Room", expectedName: "highfive-ecosystem-connect-room.png", status: .needed, reviewFocus: "Community preview with no messaging or analytics."),
        HFQAScreenshotReview(screen: "Launch Room", expectedName: "highfive-ecosystem-launch-room.png", status: .needed, reviewFocus: "Timeline, campaign, audience, materials, and readiness."),
        HFQAScreenshotReview(screen: "Export Room", expectedName: "highfive-ecosystem-export-room.png", status: .needed, reviewFocus: "Deliverables, media kit, festival, platform, and distribution readiness."),
        HFQAScreenshotReview(screen: "Developer / QA Hub", expectedName: "highfive-ecosystem-developer-qa.png", status: .needed, reviewFocus: "Internal control room with Product Spine and safety centers."),
        HFQAScreenshotReview(screen: "Product Spine", expectedName: "highfive-ecosystem-product-spine.png", status: .needed, reviewFocus: "WATCH, CREATE, CONNECT, LAUNCH, EXPORT map."),
        HFQAScreenshotReview(screen: "Protected Systems", expectedName: "highfive-ecosystem-protected-systems.png", status: .needed, reviewFocus: "Locked protected paths with no edit controls."),
        HFQAScreenshotReview(screen: "Screenshot Review", expectedName: "highfive-ecosystem-screenshot-review.png", status: .needed, reviewFocus: "Expected screenshot target list.")
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

private struct QAProductSpineCard: View {
    let pillar: HFQAProductSpinePillar

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: pillar.status.color.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: pillar.systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(pillar.status.color)
                        .frame(width: 44, height: 44)
                        .background(pillar.status.color.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(pillar.pillar)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(pillar.status.color)
                        Text(pillar.room)
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.sm)
                    QAStatusPill(status: pillar.status)
                }

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Primary sections")
                        .font(HFTypography.micro)
                        .foregroundStyle(HFColors.textMuted)

                    ForEach(pillar.primarySurfaces, id: \.self) { surface in
                        HStack(spacing: HFSpacing.xs) {
                            Circle()
                                .fill(pillar.status.color)
                                .frame(width: 5, height: 5)
                            Text(surface)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Product Spine \(pillar.pillar), room \(pillar.room)")
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
