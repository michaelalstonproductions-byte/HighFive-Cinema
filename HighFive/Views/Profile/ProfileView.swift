import SwiftUI

struct ProfileView: View {
    @Binding var selectedProfile: UserProfile
    var onOpenMyList: (() -> Void)?
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var showsProfileSwitcher = false
    @State private var showsSignOutAlert = false
    @State private var showsNotifications = false
    @State private var activeMockSheet: ProfileMockSheet?
    @State private var profileNameDraft = ""
    @StateObject private var notificationStore = HFNotificationCenterStore()

    private let menuItems: [(title: String, systemImage: String)] = [
        ("Notifications", "bell.fill"),
        ("My List", "bookmark.fill"),
        ("Viewing Preferences", "slider.horizontal.3"),
        ("Account Preview", "person.crop.circle.fill"),
        ("Help", "questionmark.circle.fill")
    ]

    private var activeUserProfile: UserProfile {
        UserProfile(
            id: streamingStore.activeViewingProfile.id,
            name: streamingStore.activeViewingProfile.displayName,
            avatarSystemName: streamingStore.activeViewingProfile.avatarSymbol,
            accentName: streamingStore.activeViewingProfile.accentName,
            isKidsProfile: false
        )
    }

    var body: some View {
        Group {
            if let launchTarget = Self.qaLaunchTarget {
                qaLaunchView(launchTarget)
            } else {
                profileContent
            }
        }
        .accessibilityIdentifier("hf.profile.root")
        .accessibilityIdentifier("hf.profile.screen")
        .safeAreaInset(edge: .top) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.topProtected")
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 4)
                .accessibilityIdentifier("hf.safeArea.bottomProtected")
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

    private var profileContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                selectedProfilePanel
                backendServicesSection
                consumerSummarySection
                accountProfileSection
                accountReadinessSection
                accountProfileProofSection
                avatarRow
                manageProfilesButton

                menu
                roomsGatewayHero
                productSuiteProgressSection
                ecosystemPresentationModeSection
                highFiveProductStorySection
                functionalCoreSummarySection
                catalogServiceSummarySection
                playerServiceSummarySection
                libraryDownloadsServiceSection
                communicationServicesSection
                launchCampaignServicesSection
                exportDeliveryServicesSection
                paymentEntitlementServicesSection
                publicMomentumSummarySection
                watchExportSummarySection
                highFiveRoomsSection
                buildQAToolsSection
                signOutButton
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
    }

    @ViewBuilder
    private func qaLaunchView(_ target: HFProfileQALaunchTarget) -> some View {
        switch target {
        case .roomsGateway:
            profileRoomsGatewayQAView
        case .creatorStudio:
            CreatorStudioView()
        case .socialMediaKit:
            CreatorStudioView(initialFocus: .socialMediaKit)
        case .vodPackage:
            CreatorStudioView(initialFocus: .vodPackage)
        case .watch:
            WatchRoomView()
        case .create:
            CreatorStudioView()
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
        case creatorStudio
        case socialMediaKit
        case vodPackage
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
        if arguments.contains("--hf-start-creator-studio") { return .creatorStudio }
        if arguments.contains("--hf-start-social-media-kit") { return .socialMediaKit }
        if arguments.contains("--hf-start-vod-package") { return .vodPackage }
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
                backendServicesSection
                roomsGatewayHero
                productSuiteProgressSection
                ecosystemPresentationModeSection
                highFiveProductStorySection
                functionalCoreSummarySection
                catalogServiceSummarySection
                playerServiceSummarySection
                libraryDownloadsServiceSection
                communicationServicesSection
                launchCampaignServicesSection
                publicMomentumSummarySection
                watchExportSummarySection
                highFiveRoomsSection
            }
            .padding(.top, HFSpacing.xxl)
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
                HFProfileAvatarCard(profile: activeUserProfile, isSelected: true, compact: true)
                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text("Watching as")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                    Text(streamingStore.activeViewingProfile.displayName)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(streamingStore.activeViewingProfile.role)
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

    private var consumerSummarySection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HFSectionHeader(title: "Your HighFive", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: streamingStore.activeViewingProfile.avatarSymbol)
                            .font(.system(size: 23, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 50, height: 50)
                            .background(HFColors.goldGradient)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Your HighFive")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Viewing profile, saved shelf, downloads, and the Rooms gateway stay connected from one consumer-first profile.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        HFProfileConsumerSummaryCard(title: "Viewing profile", detail: streamingStore.activeViewingProfile.displayName, systemImage: streamingStore.activeViewingProfile.avatarSymbol, isActive: true)
                        HFProfileConsumerSummaryCard(title: "My List", detail: "Saved shelf", systemImage: "bookmark.fill")
                        HFProfileConsumerSummaryCard(title: "Downloads", detail: "Offline shelf", systemImage: "arrow.down.circle.fill")
                        HFProfileConsumerSummaryCard(title: "Rooms gateway", detail: "Watch to Export", systemImage: "rectangle.3.group.fill")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Your HighFive, consumer profile summary with viewing profile, My List, Downloads, and Rooms gateway")
        .accessibilityIdentifier("hf.profile.consumerSummary")
    }

    private var accountProfileSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.38)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                            .fill(HFColors.goldGradient)
                        Text(streamingStore.profileInitials)
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: streamingStore.accountMode, accent: HFColors.gold)
                        Text("Your HighFive Profile")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Your local viewing identity connects Home, My List, Downloads, and Rooms.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: HFSpacing.sm) {
                    Image(systemName: streamingStore.activeViewingProfile.avatarSymbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                    VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                        Text(streamingStore.activeViewingProfile.displayName)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(streamingStore.activeViewingProfile.role)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                    }
                    Spacer()
                    HFRoomStatusChip(title: "Active", accent: HFColors.gold)
                }
                .padding(HFSpacing.sm)
                .background(Color.white.opacity(0.055))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                .accessibilityIdentifier("hf.account.profile.activeProfile")

                TextField("Display name", text: $profileNameDraft)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textPrimary)
                    .textInputAutocapitalization(.words)
                    .padding(HFSpacing.md)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                            .stroke(HFColors.glassStroke, lineWidth: 1)
                    )
                    .accessibilityIdentifier("hf.account.profile.editName")
                    .accessibilityIdentifier("hf.account.profile.displayName")

                Button {
                    streamingStore.updateDisplayName(profileNameDraft)
                    selectedProfile = UserProfile(
                        id: streamingStore.activeViewingProfile.id,
                        name: streamingStore.activeViewingProfile.displayName,
                        avatarSystemName: streamingStore.activeViewingProfile.avatarSymbol,
                        accentName: streamingStore.activeViewingProfile.accentName,
                        isKidsProfile: false
                    )
                    profileNameDraft = streamingStore.activeViewingProfile.displayName
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Profile Name")
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.account.profile.saveName")

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    Text("Choose viewing profile")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: HFSpacing.xs)], alignment: .leading, spacing: HFSpacing.xs) {
                        ForEach(streamingStore.localProfiles) { profile in
                            Button {
                                streamingStore.selectProfile(profile)
                                selectedProfile = UserProfile(
                                    id: profile.id,
                                    name: streamingStore.activeViewingProfile.displayName,
                                    avatarSystemName: profile.avatarSymbol,
                                    accentName: profile.accentName,
                                    isKidsProfile: false
                                )
                                profileNameDraft = streamingStore.activeViewingProfile.displayName
                            } label: {
                                HFAccountProfilePickerCard(
                                    profile: profile,
                                    isActive: profile.id == streamingStore.activeProfileID
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .accessibilityIdentifier("hf.account.profile.profilePicker")
                }

                VStack(spacing: HFSpacing.xs) {
                    HFConsumerMomentumRow(title: "Cloud Account Not Connected Yet", detail: "Provider-ready local profile state only.", status: "Deferred", systemImage: "person.crop.circle.badge.exclamationmark")
                        .accessibilityIdentifier("hf.account.profile.cloudStatus")
                    HFConsumerMomentumRow(title: streamingStore.profilePrivacyState, detail: "Local profile state is ready for a future service decision.", status: "Ready", systemImage: "hand.raised.fill")
                        .accessibilityIdentifier("hf.account.profile.privacyState")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .onAppear {
            if profileNameDraft.isEmpty {
                profileNameDraft = streamingStore.activeViewingProfile.displayName
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Your HighFive Profile, Local Profile Active, Cloud Account Not Connected Yet, Privacy Ready")
        .accessibilityIdentifier("hf.account.profile.section")
    }

    private var accountReadinessSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Provider Ready", accent: HFColors.gold)
                        Text("Account Readiness")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local profile behavior is active while future account services remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    HFAccountReadinessRow(title: "Local profile", status: "Active", systemImage: "person.crop.circle.fill")
                    HFAccountReadinessRow(title: "Saved list", status: "Local", systemImage: "bookmark.fill")
                    HFAccountReadinessRow(title: "Downloads", status: "Local State", systemImage: "arrow.down.circle.fill")
                    HFAccountReadinessRow(title: "Cloud account", status: "Not Connected Yet", systemImage: "icloud.slash.fill")
                    HFAccountReadinessRow(title: "Payments", status: "Not Connected Yet", systemImage: "creditcard")
                    HFAccountReadinessRow(title: "Streaming access", status: "Not Connected Yet", systemImage: "play.rectangle.fill")
                    HFAccountReadinessRow(title: "Privacy review", status: "Ready for service decision", systemImage: "hand.raised.fill")
                }
                .accessibilityIdentifier("hf.account.profile.localState")
                .accessibilityIdentifier("hf.account.profile.serviceReadiness")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Account Readiness, local profile active, saved list local, downloads local state, cloud account not connected yet, privacy ready")
        .accessibilityIdentifier("hf.account.profile.readiness")
    }

    private var accountProfileProofSection: some View {
        HFInsightCard(
            title: "Connected Profile Proof",
            message: "Local profile identity now connects saved state, downloaded state, updates, checklist, and delivery summary.",
            systemImage: "person.crop.circle.badge.checkmark"
        )
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Connected Profile Proof, local profile identity connects saved state downloaded state updates checklist and delivery summary")
        .accessibilityIdentifier("hf.profile.accountProfileProof")
    }

    private var backendServicesSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: streamingStore.backendStatus.systemImage)
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: streamingStore.backendStatus.statusLabel, accent: HFColors.gold)
                        Text("Backend Services")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(streamingStore.backendStatus.detail)
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.backendServiceStatuses) { service in
                        HFConsumerMomentumRow(
                            title: service.title,
                            detail: service.detail,
                            status: service.statusLabel,
                            systemImage: service.systemImage
                        )
                        .accessibilityIdentifier(service.accessibilityIdentifier)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Backend Services, \(streamingStore.backendStatus.statusLabel)")
        .accessibilityIdentifier("hf.profile.backendServices")
        .accessibilityIdentifier("hf.backend.status")
        .accessibilityIdentifier("hf.backend.providerReady")
    }

    private var creatorModeCard: some View {
                NavigationLink {
                    CreatorStudioView()
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
        .accessibilityIdentifier("hf.route.profileToCreatorStudio")
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
                    CreatorStudioView()
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
                .accessibilityIdentifier("hf.route.profileToCreatorStudio")

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
                .accessibilityIdentifier("hf.route.profileToConnect")

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
                .accessibilityIdentifier("hf.route.profileToLaunch")

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
                .accessibilityIdentifier("hf.route.profileToExport")
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HighFive Rooms, product spaces for watching, creating, connecting, launching, and export readiness")
        .accessibilityIdentifier("hf.profile.roomsSection")
    }

    private var productSuiteProgressSection: some View {
        HFProfileProductSuiteProgressSection(rows: HFRoomMegaExpansionData.productSuiteRows)
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var ecosystemPresentationModeSection: some View {
        HFProfileEcosystemPresentationSection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var highFiveProductStorySection: some View {
        HFProfileHighFiveProductStorySection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var functionalCoreSummarySection: some View {
        HFProfileFunctionalCoreSummarySection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var catalogServiceSummarySection: some View {
        HFProfileCatalogServiceSummarySection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var playerServiceSummarySection: some View {
        HFProfilePlayerServiceSummarySection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var libraryDownloadsServiceSection: some View {
        HFProfileLibraryDownloadsServiceSection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var communicationServicesSection: some View {
        HFProfileCommunicationServicesSection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var launchCampaignServicesSection: some View {
        HFProfileLaunchCampaignServicesSection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var exportDeliveryServicesSection: some View {
        HFProfileExportDeliveryServicesSection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var paymentEntitlementServicesSection: some View {
        HFProfilePaymentEntitlementServicesSection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var publicMomentumSummarySection: some View {
        HFProfilePublicMomentumSummarySection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var watchExportSummarySection: some View {
        HFProfileWatchExportSummarySection()
            .padding(.horizontal, HFSpacing.screenHorizontal)
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

private struct HFAccountProfilePickerCard: View {
    let profile: HFLocalViewingProfile
    let isActive: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: profile.avatarSymbol)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(isActive ? .black : HFColors.gold)
                .frame(width: 32, height: 32)
                .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                .clipShape(Circle())

            Text(profile.displayName)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(profile.role)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.13) : Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(isActive ? HFColors.goldStroke : HFColors.glassStroke, lineWidth: 1)
        )
        .accessibilityLabel("Use This Profile, \(profile.displayName), \(profile.role)")
    }
}

private struct HFAccountReadinessRow: View {
    let title: String
    let status: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 32, height: 32)
                .background(HFColors.gold.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(status == "Active" || status.hasPrefix("Ready") ? .black : HFColors.gold)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 24)
                .background(status == "Active" || status.hasPrefix("Ready") ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.10)))
                .clipShape(Capsule())
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFProfileConsumerSummaryCard: View {
    let title: String
    let detail: String
    let systemImage: String
    var isActive = false

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(isActive ? .black : HFColors.gold)
                .frame(width: 30, height: 30)
                .background(isActive ? AnyShapeStyle(HFColors.goldGradient) : AnyShapeStyle(HFColors.gold.opacity(0.12)))
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 100, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(isActive ? HFColors.gold.opacity(0.14) : Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(isActive ? HFColors.gold.opacity(0.38) : HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
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

private struct HFCreatorPitchBeat: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFCreatorPitchSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let shapes: String
    let readySummary: String
    let previewSummary: String
    let deferredSummary: String
    let beats: [HFCreatorPitchBeat]
}

private struct HFCreatorPitchReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
}

private struct HFCreatorPitchPackage: Identifiable {
    let id = UUID()
    let projectTitle: String
    let pitchTitle: String
    let logline: String
    let genre: String
    let format: String
    let audience: String
    let releaseAngle: String
    let pitchStatus: String
    let sections: [HFCreatorPitchSection]
    let readinessRows: [HFCreatorPitchReadinessRow]
}

private struct HFCreatorMediaKitItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFCreatorMediaKitSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let prepares: String
    let readySummary: String
    let previewSummary: String
    let deferredSummary: String
    let items: [HFCreatorMediaKitItem]
}

private struct HFCreatorMediaKitReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
}

private struct HFCreatorMediaKit: Identifiable {
    let id = UUID()
    let projectTitle: String
    let kitTitle: String
    let publicBlurb: String
    let visualDirection: String
    let creatorBio: String
    let kitStatus: String
    let sections: [HFCreatorMediaKitSection]
    let readinessRows: [HFCreatorMediaKitReadinessRow]
}

private struct HFCreatorLaunchPrepItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let state: String
}

private struct HFCreatorLaunchPrepSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let prepares: String
    let readySummary: String
    let previewSummary: String
    let deferredSummary: String
    let items: [HFCreatorLaunchPrepItem]
}

private struct HFCreatorLaunchPrepReadinessRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
}

private struct HFCreatorLaunchPrep: Identifiable {
    let id = UUID()
    let projectTitle: String
    let prepTitle: String
    let positioning: String
    let releaseWindow: String
    let audienceWarmup: String
    let prepStatus: String
    let sections: [HFCreatorLaunchPrepSection]
    let readinessRows: [HFCreatorLaunchPrepReadinessRow]
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

private struct HFRoomBoardCard: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFRoomBoardColumn: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: String
    let systemImage: String
    let cards: [HFRoomBoardCard]
}

private struct HFRoomCalendarMilestone: Identifiable {
    let id = UUID()
    let title: String
    let dateLabel: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFRoomSuiteProgressRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFEcosystemPresentationAct: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let pillar: String
    let route: String
    let proof: String
    let status: String
    let systemImage: String
}

private struct HFEcosystemProofRow: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
    let systemImage: String
}

private struct HFRoomBoardExpansion {
    let title: String
    let subtitle: String
    let ctaTitle: String
    let columns: [HFRoomBoardColumn]
    let momentumRows: [HFRoomSuiteProgressRow]
    let boardIdentifier: String
    let momentumIdentifier: String
    let planIdentifier: String
    let accessibilityLabel: String
}

private enum HFEcosystemPresentationData {
    static let acts: [HFEcosystemPresentationAct] = [
        HFEcosystemPresentationAct(
            title: "WATCH",
            subtitle: "Premium streaming and viewing journey",
            pillar: "Consumer",
            route: "Home -> Movie Detail -> Profile",
            proof: "Home, Search, Movie Detail, Library, Downloads",
            status: "Built",
            systemImage: "play.rectangle.fill"
        ),
        HFEcosystemPresentationAct(
            title: "CREATE",
            subtitle: "Creator Studio suite and package prep",
            pillar: "Studio",
            route: "Profile -> HighFive Rooms -> Create",
            proof: "Studio Slate, Project Package, Pitch, Media Kit",
            status: "Built",
            systemImage: "wand.and.stars"
        ),
        HFEcosystemPresentationAct(
            title: "CONNECT",
            subtitle: "Audience energy and public momentum",
            pillar: "Public",
            route: "Profile -> HighFive Rooms -> Connect",
            proof: "Momentum Board, Creator Updates, Conversation Pack",
            status: "Built",
            systemImage: "person.2.fill"
        ),
        HFEcosystemPresentationAct(
            title: "LAUNCH",
            subtitle: "Release calendar and premiere readiness",
            pillar: "Premiere",
            route: "Profile -> HighFive Rooms -> Launch",
            proof: "Calendar, Campaign Momentum, Premiere Pack",
            status: "Built",
            systemImage: "flag.checkered"
        ),
        HFEcosystemPresentationAct(
            title: "EXPORT",
            subtitle: "Professional delivery and handoff planning",
            pillar: "Pro Path",
            route: "Profile -> HighFive Rooms -> Export",
            proof: "Delivery Board, Festival Pack, Handoff Planner",
            status: "Built",
            systemImage: "shippingbox.fill"
        ),
        HFEcosystemPresentationAct(
            title: "PROOF",
            subtitle: "Developer / QA internal validation",
            pillar: "Internal",
            route: "Profile -> Developer / QA -> Demo Tour",
            proof: "Product Spine, Visual Parity, Screenshot Review",
            status: "Internal",
            systemImage: "lock.shield.fill"
        )
    ]

    static let productStoryRows: [HFEcosystemProofRow] = [
        HFEcosystemProofRow(title: "Start With Watch", detail: "Home, Search, Movie Detail, Library, Downloads. Consumer streaming first.", status: "Built", systemImage: "play.rectangle.fill"),
        HFEcosystemProofRow(title: "Expand Into Rooms", detail: "Watch, Create, Connect, Launch, Export. Product suite visible through Profile.", status: "Built", systemImage: "rectangle.3.group.fill"),
        HFEcosystemProofRow(title: "Prove The Ecosystem", detail: "Demo Tour, Product Spine, Visual Parity, Protected Systems. Developer / QA only.", status: "Internal", systemImage: "checkmark.seal.fill"),
        HFEcosystemProofRow(title: "Keep Systems Safe", detail: "Protected media, delivery, server, commerce, and audience-contact services remain separated.", status: "Protected", systemImage: "shield.lefthalf.filled")
    ]
}

private enum HFRoomMegaExpansionData {
    static let productSuiteRows: [HFRoomSuiteProgressRow] = [
        HFRoomSuiteProgressRow(title: "WATCH", detail: "Premium Viewing Hub", status: "Built", systemImage: "play.rectangle.fill"),
        HFRoomSuiteProgressRow(title: "CREATE", detail: "Creator Studio Suite", status: "Evidence Locked", systemImage: "wand.and.stars"),
        HFRoomSuiteProgressRow(title: "CONNECT", detail: "Audience Planner + Board", status: "Built", systemImage: "person.2.fill"),
        HFRoomSuiteProgressRow(title: "LAUNCH", detail: "Campaign Planner + Release Calendar", status: "Built", systemImage: "flag.checkered"),
        HFRoomSuiteProgressRow(title: "EXPORT", detail: "Distribution Package + Delivery Board", status: "Built", systemImage: "shippingbox.fill"),
        HFRoomSuiteProgressRow(title: "MOMENTUM", detail: "Launch + Connect public path", status: "Built", systemImage: "flame.fill"),
        HFRoomSuiteProgressRow(title: "INTERNAL", detail: "Developer / QA", status: "Internal Only", systemImage: "lock.shield.fill")
    ]

    static let watchBoard = HFRoomBoardExpansion(
        title: "Tonight’s Watch Board",
        subtitle: "A local viewing plan for tonight's feature, saved titles, offline shelf, and next discovery step.",
        ctaTitle: "Review Watch Plan",
        columns: [
            HFRoomBoardColumn(
                title: "Featured Premiere",
                subtitle: "Tonight's anchor title.",
                status: "Ready",
                systemImage: "star.fill",
                cards: [
                    HFRoomBoardCard(title: "The Friendly", detail: "Warm premium original.", status: "Ready", systemImage: "film.fill"),
                    HFRoomBoardCard(title: "Watch Now Preview", detail: "Safe local action wording only.", status: "Ready", systemImage: "play.rectangle.fill")
                ]
            ),
            HFRoomBoardColumn(
                title: "Continue Watching",
                subtitle: "Resume context without player state.",
                status: "Local",
                systemImage: "play.rectangle.fill",
                cards: [
                    HFRoomBoardCard(title: "Midnight Borough", detail: "Pick up the mystery.", status: "Local", systemImage: "moon.stars.fill"),
                    HFRoomBoardCard(title: "Scene Cue", detail: "Return path is display copy.", status: "Preview", systemImage: "arrow.turn.down.right")
                ]
            ),
            HFRoomBoardColumn(
                title: "My List",
                subtitle: "Saved shelf for the next choice.",
                status: "Preview",
                systemImage: "bookmark.fill",
                cards: [
                    HFRoomBoardCard(title: "Golden Hour Kids", detail: "Family watch-night shelf.", status: "Preview", systemImage: "sun.max.fill"),
                    HFRoomBoardCard(title: "Priority", detail: "Local saved-title order.", status: "Local", systemImage: "list.number")
                ]
            ),
            HFRoomBoardColumn(
                title: "Offline Shelf",
                subtitle: "Offline-ready concept only.",
                status: "Deferred",
                systemImage: "arrow.down.circle.fill",
                cards: [
                    HFRoomBoardCard(title: "Available Offline Preview", detail: "Shelf copy is static.", status: "Deferred", systemImage: "tray.fill"),
                    HFRoomBoardCard(title: "Protected Player Path", detail: "Viewing systems stay separate.", status: "Protected", systemImage: "lock.shield.fill")
                ]
            ),
            HFRoomBoardColumn(
                title: "Discovery Path",
                subtitle: "Guide the next title.",
                status: "Ready",
                systemImage: "magnifyingglass",
                cards: [
                    HFRoomBoardCard(title: "HighFive Picks", detail: "Originals and Coming Soon rails.", status: "Ready", systemImage: "sparkles"),
                    HFRoomBoardCard(title: "Next Step", detail: "Search and Home remain the consumer path.", status: "Preview", systemImage: "arrow.right.circle.fill")
                ]
            )
        ],
        momentumRows: [
            HFRoomSuiteProgressRow(title: "Featured title", detail: "Tonight's pick is ready.", status: "Ready", systemImage: "star.fill"),
            HFRoomSuiteProgressRow(title: "Saved shelf", detail: "My List path is ready.", status: "Ready", systemImage: "bookmark.fill"),
            HFRoomSuiteProgressRow(title: "Offline shelf", detail: "Offline shelf remains a preview.", status: "Preview", systemImage: "arrow.down.circle.fill"),
            HFRoomSuiteProgressRow(title: "Discovery rails", detail: "Discovery path is ready.", status: "Ready", systemImage: "magnifyingglass"),
            HFRoomSuiteProgressRow(title: "Player systems", detail: "Viewing engines remain separated.", status: "Protected", systemImage: "lock.shield.fill")
        ],
        boardIdentifier: "hf.room.watch.watchBoard",
        momentumIdentifier: "hf.room.watch.viewingMomentum",
        planIdentifier: "hf.room.watch.watchPlan",
        accessibilityLabel: "Tonight's Watch Board, local viewing board preview with protected player systems"
    )

    static let audienceBoard = HFRoomBoardExpansion(
        title: "Audience Board",
        subtitle: "A local community board for audience groups, creator updates, reactions, and premiere conversation.",
        ctaTitle: "Review Audience Board",
        columns: [
            HFRoomBoardColumn(title: "Communities", subtitle: "Who gathers around the title.", status: "Preview", systemImage: "person.3.fill", cards: [
                HFRoomBoardCard(title: "Premiere viewers", detail: "Opening-night audience group.", status: "Preview", systemImage: "person.2.fill"),
                HFRoomBoardCard(title: "Creator supporters", detail: "People following the creator story.", status: "Draft", systemImage: "heart.fill"),
                HFRoomBoardCard(title: "Family audience", detail: "Warm family-forward viewers.", status: "Ready", systemImage: "figure.2.and.child.holdinghands")
            ]),
            HFRoomBoardColumn(title: "Creator Updates", subtitle: "Local update themes.", status: "Draft", systemImage: "text.bubble.fill", cards: [
                HFRoomBoardCard(title: "Behind-the-scenes note", detail: "A warm creator memory.", status: "Draft", systemImage: "note.text"),
                HFRoomBoardCard(title: "Premiere reminder", detail: "Safe preview copy only.", status: "Preview", systemImage: "calendar.badge.clock"),
                HFRoomBoardCard(title: "Release reflection", detail: "Post-premiere creator note.", status: "Local", systemImage: "quote.bubble.fill")
            ]),
            HFRoomBoardColumn(title: "Reaction Moments", subtitle: "Static response cues.", status: "Local", systemImage: "heart.text.square.fill", cards: [
                HFRoomBoardCard(title: "Warm response", detail: "Family-forward reaction cue.", status: "Local", systemImage: "heart.fill"),
                HFRoomBoardCard(title: "Favorite scene", detail: "Story beat prompt.", status: "Preview", systemImage: "sparkles"),
                HFRoomBoardCard(title: "Watch mood", detail: "Hopeful and shared.", status: "Ready", systemImage: "moon.fill")
            ]),
            HFRoomBoardColumn(title: "Premiere Conversation", subtitle: "Release-week prompts.", status: "Preview", systemImage: "flag.checkered", cards: [
                HFRoomBoardCard(title: "What moment stayed with you?", detail: "Reflective premiere prompt.", status: "Preview", systemImage: "questionmark.bubble.fill"),
                HFRoomBoardCard(title: "Who would you watch this with?", detail: "Family watch-night cue.", status: "Preview", systemImage: "person.2.fill"),
                HFRoomBoardCard(title: "Why this title tonight?", detail: "Simple watch choice prompt.", status: "Local", systemImage: "sparkles")
            ]),
            HFRoomBoardColumn(title: "Community Readiness", subtitle: "Plan safety and tone.", status: "Local", systemImage: "checkmark.shield.fill", cards: [
                HFRoomBoardCard(title: "Update copy preview", detail: "Creator update wording.", status: "Draft", systemImage: "doc.text.fill"),
                HFRoomBoardCard(title: "Prompt preview", detail: "Audience prompt set.", status: "Preview", systemImage: "text.bubble.fill"),
                HFRoomBoardCard(title: "Safety boundary", detail: "Live community systems stay separated.", status: "Protected", systemImage: "lock.shield.fill")
            ])
        ],
        momentumRows: [
            HFRoomSuiteProgressRow(title: "Community plan", detail: "Audience groups are mapped.", status: "Preview", systemImage: "person.3.fill"),
            HFRoomSuiteProgressRow(title: "Creator updates", detail: "Update copy is drafted.", status: "Draft", systemImage: "text.bubble.fill"),
            HFRoomSuiteProgressRow(title: "Reaction prompts", detail: "Response cues are local.", status: "Local", systemImage: "heart.fill"),
            HFRoomSuiteProgressRow(title: "Conversation prompts", detail: "Premiere prompts are ready.", status: "Preview", systemImage: "questionmark.bubble.fill"),
            HFRoomSuiteProgressRow(title: "Live community systems", detail: "Participation systems remain separated.", status: "Protected", systemImage: "lock.shield.fill")
        ],
        boardIdentifier: "hf.room.connect.audienceBoard",
        momentumIdentifier: "hf.room.connect.audienceMomentum",
        planIdentifier: "hf.room.connect.communityPlan",
        accessibilityLabel: "Audience Board, local audience community preview with protected live community systems"
    )

    static let deliveryBoard = HFRoomBoardExpansion(
        title: "Delivery Board",
        subtitle: "A local delivery board for package status, handoff readiness, and protected output boundaries.",
        ctaTitle: "Review Delivery Board",
        columns: [
            HFRoomBoardColumn(title: "Deliverables", subtitle: "Core title materials.", status: "Draft", systemImage: "tray.full.fill", cards: [
                HFRoomBoardCard(title: "Poster", detail: "Key art direction.", status: "Preview", systemImage: "photo.fill"),
                HFRoomBoardCard(title: "Stills", detail: "Still-frame placeholders.", status: "Draft", systemImage: "photo.stack.fill"),
                HFRoomBoardCard(title: "Synopsis", detail: "Short and long copy.", status: "Ready", systemImage: "doc.text.fill")
            ]),
            HFRoomBoardColumn(title: "Media Kit", subtitle: "Press-ready package copy.", status: "Preview", systemImage: "newspaper.fill", cards: [
                HFRoomBoardCard(title: "Press copy", detail: "Public story copy.", status: "Preview", systemImage: "text.alignleft"),
                HFRoomBoardCard(title: "Creator bio", detail: "Creator context.", status: "Draft", systemImage: "person.text.rectangle.fill"),
                HFRoomBoardCard(title: "Release language", detail: "Launch copy handoff.", status: "Preview", systemImage: "quote.bubble.fill")
            ]),
            HFRoomBoardColumn(title: "Festival Package", subtitle: "Festival-facing materials.", status: "Local", systemImage: "rosette", cards: [
                HFRoomBoardCard(title: "Festival synopsis", detail: "Festival story copy.", status: "Preview", systemImage: "doc.text.fill"),
                HFRoomBoardCard(title: "Director statement", detail: "Statement slot.", status: "Draft", systemImage: "person.fill.viewfinder"),
                HFRoomBoardCard(title: "Submission notes", detail: "Local notes only.", status: "Local", systemImage: "note.text")
            ]),
            HFRoomBoardColumn(title: "Platform Checklist", subtitle: "Future delivery requirements.", status: "Preview", systemImage: "checklist.checked", cards: [
                HFRoomBoardCard(title: "Title metadata", detail: "Title, genre, runtime.", status: "Preview", systemImage: "tag.fill"),
                HFRoomBoardCard(title: "Artwork set", detail: "Poster and backdrop readiness.", status: "Draft", systemImage: "rectangle.stack.fill"),
                HFRoomBoardCard(title: "Advisory placeholder", detail: "Review-only advisory copy.", status: "Preview", systemImage: "exclamationmark.shield.fill")
            ]),
            HFRoomBoardColumn(title: "Handoff Readiness", subtitle: "Protected package review.", status: "Protected", systemImage: "checkmark.shield.fill", cards: [
                HFRoomBoardCard(title: "Package review", detail: "Completeness check.", status: "Preview", systemImage: "checkmark.seal.fill"),
                HFRoomBoardCard(title: "Missing items", detail: "Open review rows.", status: "Draft", systemImage: "list.bullet.rectangle.fill"),
                HFRoomBoardCard(title: "Delivery summary", detail: "Preview-only handoff note.", status: "Preview", systemImage: "shippingbox.fill")
            ])
        ],
        momentumRows: [
            HFRoomSuiteProgressRow(title: "Deliverables", detail: "Materials are drafted.", status: "Draft", systemImage: "tray.full.fill"),
            HFRoomSuiteProgressRow(title: "Media Kit", detail: "Press materials are previewed.", status: "Preview", systemImage: "newspaper.fill"),
            HFRoomSuiteProgressRow(title: "Festival Package", detail: "Festival rows are local.", status: "Local", systemImage: "rosette"),
            HFRoomSuiteProgressRow(title: "Platform Checklist", detail: "Requirements are previewed.", status: "Preview", systemImage: "checklist.checked"),
            HFRoomSuiteProgressRow(title: "Delivery systems", detail: "Output systems remain separated.", status: "Protected", systemImage: "lock.shield.fill")
        ],
        boardIdentifier: "hf.room.export.deliveryBoard",
        momentumIdentifier: "hf.room.export.deliveryReadinessBoard",
        planIdentifier: "hf.room.export.handoffPlan",
        accessibilityLabel: "Delivery Board, local distribution package preview with protected delivery systems"
    )

    static let programBoardColumns: [HFRoomBoardColumn] = [
        HFRoomBoardColumn(title: "Featured Programming", subtitle: "Tonight's premium viewing path.", status: "Ready", systemImage: "star.fill", cards: [
            HFRoomBoardCard(title: "The Friendly", detail: "Warm premiere original.", status: "Ready", systemImage: "film.fill"),
            HFRoomBoardCard(title: "Warm premiere original", detail: "Story-first feature placement.", status: "Ready", systemImage: "sparkles"),
            HFRoomBoardCard(title: "Tonight's featured path", detail: "Clear editorial start point.", status: "Ready", systemImage: "arrow.right.circle.fill")
        ]),
        HFRoomBoardColumn(title: "HighFive Originals", subtitle: "Creator-led programming lane.", status: "Built", systemImage: "sparkles.tv.fill", cards: [
            HFRoomBoardCard(title: "Creator-led slate", detail: "Original titles grouped together.", status: "Built", systemImage: "wand.and.stars"),
            HFRoomBoardCard(title: "Family watch-night title", detail: "Warm shared-viewing placement.", status: "Preview", systemImage: "figure.2.and.child.holdinghands"),
            HFRoomBoardCard(title: "Premium discovery lane", detail: "Originals stay visible after the hero.", status: "Built", systemImage: "rectangle.stack.fill")
        ]),
        HFRoomBoardColumn(title: "Collections", subtitle: "Curated groups for repeat viewing.", status: "Preview", systemImage: "square.grid.2x2.fill", cards: [
            HFRoomBoardCard(title: "Family Watch Night", detail: "Shared viewing shelf.", status: "Preview", systemImage: "person.2.fill"),
            HFRoomBoardCard(title: "Late Night Mystery", detail: "Darker genre lane.", status: "Local", systemImage: "moon.stars.fill"),
            HFRoomBoardCard(title: "Golden Hour Stories", detail: "Warm original collection.", status: "Preview", systemImage: "sun.max.fill")
        ]),
        HFRoomBoardColumn(title: "Continue Path", subtitle: "Keep the viewer moving.", status: "Local", systemImage: "play.rectangle.fill", cards: [
            HFRoomBoardCard(title: "Resume title", detail: "Return to an in-progress story.", status: "Local", systemImage: "arrow.clockwise"),
            HFRoomBoardCard(title: "Saved shelf", detail: "My List remains the next stop.", status: "Ready", systemImage: "bookmark.fill"),
            HFRoomBoardCard(title: "Related picks", detail: "More Like This keeps momentum.", status: "Preview", systemImage: "rectangle.stack.fill")
        ]),
        HFRoomBoardColumn(title: "Discovery Bridge", subtitle: "Move from one title to the next.", status: "Ready", systemImage: "magnifyingglass", cards: [
            HFRoomBoardCard(title: "Because You Watched", detail: "Follow the mood into another title.", status: "Ready", systemImage: "sparkles"),
            HFRoomBoardCard(title: "New This Week", detail: "Fresh titles stay visible.", status: "Ready", systemImage: "calendar.badge.clock"),
            HFRoomBoardCard(title: "Coming Soon", detail: "Next premiere shelf.", status: "Preview", systemImage: "flag.checkered")
        ])
    ]

    static let viewingJourneyStages: [HFRoomBoardColumn] = [
        HFRoomBoardColumn(title: "Start With A Premiere", subtitle: "Open with a strong title decision.", status: "Ready", systemImage: "star.fill", cards: [
            HFRoomBoardCard(title: "Featured title", detail: "The Friendly leads the path.", status: "Ready", systemImage: "film.fill"),
            HFRoomBoardCard(title: "Watch mood", detail: "Warm, hopeful, premium.", status: "Ready", systemImage: "moon.stars.fill"),
            HFRoomBoardCard(title: "Editorial reason", detail: "Clear why-this-tonight framing.", status: "Preview", systemImage: "text.book.closed.fill")
        ]),
        HFRoomBoardColumn(title: "Continue The Story", subtitle: "Move from title choice to follow-up.", status: "Preview", systemImage: "arrow.turn.down.right", cards: [
            HFRoomBoardCard(title: "Resume context", detail: "Pick back up cleanly.", status: "Local", systemImage: "arrow.clockwise"),
            HFRoomBoardCard(title: "Related title", detail: "More Like This stays close.", status: "Ready", systemImage: "rectangle.stack.fill"),
            HFRoomBoardCard(title: "Next-night path", detail: "Keep the viewer in the collection.", status: "Preview", systemImage: "moon.fill")
        ]),
        HFRoomBoardColumn(title: "Save For Later", subtitle: "Build a personal viewing shelf.", status: "Local", systemImage: "bookmark.fill", cards: [
            HFRoomBoardCard(title: "Saved shelf", detail: "Titles stay organized.", status: "Ready", systemImage: "bookmark.fill"),
            HFRoomBoardCard(title: "Family watch list", detail: "Shared titles have a home.", status: "Preview", systemImage: "person.2.fill"),
            HFRoomBoardCard(title: "Mood-based queue", detail: "Choose by evening feel.", status: "Local", systemImage: "slider.horizontal.3")
        ]),
        HFRoomBoardColumn(title: "Discover More", subtitle: "Return to premium discovery.", status: "Ready", systemImage: "magnifyingglass", cards: [
            HFRoomBoardCard(title: "Originals lane", detail: "Creator-led stories stay visible.", status: "Built", systemImage: "sparkles.tv.fill"),
            HFRoomBoardCard(title: "New this week", detail: "Fresh shelf for repeat visits.", status: "Ready", systemImage: "calendar"),
            HFRoomBoardCard(title: "Coming soon", detail: "Future premiere cue.", status: "Preview", systemImage: "flag.checkered")
        ])
    ]

    static let featuredSlateRows: [HFRoomSuiteProgressRow] = [
        HFRoomSuiteProgressRow(title: "The Friendly", detail: "Warm family premiere.", status: "Ready", systemImage: "film.fill"),
        HFRoomSuiteProgressRow(title: "Midnight Borough", detail: "Late-night mystery lane.", status: "Preview", systemImage: "moon.stars.fill"),
        HFRoomSuiteProgressRow(title: "Golden Hour Kids", detail: "Family collection path.", status: "Local", systemImage: "sun.max.fill"),
        HFRoomSuiteProgressRow(title: "HighFive Originals", detail: "Creator-led slate.", status: "Built", systemImage: "sparkles.tv.fill"),
        HFRoomSuiteProgressRow(title: "Coming Soon", detail: "Next premiere shelf.", status: "Preview", systemImage: "flag.checkered")
    ]

    static let featuredSlateReadinessRows: [HFRoomSuiteProgressRow] = [
        HFRoomSuiteProgressRow(title: "Featured path", detail: "Program path is ready.", status: "Ready", systemImage: "star.fill"),
        HFRoomSuiteProgressRow(title: "Originals lane", detail: "Originals are grouped.", status: "Built", systemImage: "sparkles"),
        HFRoomSuiteProgressRow(title: "Collections", detail: "Collection paths are previewed.", status: "Preview", systemImage: "square.grid.2x2.fill"),
        HFRoomSuiteProgressRow(title: "Saved shelf", detail: "My List remains local.", status: "Local", systemImage: "bookmark.fill"),
        HFRoomSuiteProgressRow(title: "Player systems", detail: "Viewing engines remain separated.", status: "Protected", systemImage: "lock.shield.fill")
    ]

    static let professionalDeliveryColumns: [HFRoomBoardColumn] = [
        HFRoomBoardColumn(title: "Handoff Package", subtitle: "Professional title package summary.", status: "Preview", systemImage: "shippingbox.fill", cards: [
            HFRoomBoardCard(title: "Title package summary", detail: "Core story and readiness snapshot.", status: "Preview", systemImage: "doc.text.fill"),
            HFRoomBoardCard(title: "Creator note", detail: "Creator context travels with the title.", status: "Draft", systemImage: "person.text.rectangle.fill"),
            HFRoomBoardCard(title: "Credits row", detail: "Key creative credits grouped.", status: "Local", systemImage: "list.bullet.rectangle.fill"),
            HFRoomBoardCard(title: "Package status", detail: "Manual review state only.", status: "Preview", systemImage: "checkmark.seal.fill")
        ]),
        HFRoomBoardColumn(title: "Festival Materials", subtitle: "Festival-facing language and review slots.", status: "Draft", systemImage: "rosette", cards: [
            HFRoomBoardCard(title: "Festival synopsis", detail: "Short festival story copy.", status: "Draft", systemImage: "doc.text.fill"),
            HFRoomBoardCard(title: "Director statement", detail: "Statement copy slot.", status: "Preview", systemImage: "quote.bubble.fill"),
            HFRoomBoardCard(title: "Credits", detail: "Creative credits remain visible.", status: "Local", systemImage: "person.2.fill"),
            HFRoomBoardCard(title: "Screener placeholder", detail: "Review wording only.", status: "Preview", systemImage: "rectangle.dashed")
        ]),
        HFRoomBoardColumn(title: "Platform Checklist", subtitle: "Future platform package checklist.", status: "Preview", systemImage: "checklist.checked", cards: [
            HFRoomBoardCard(title: "Title metadata", detail: "Title, genre, and format.", status: "Draft", systemImage: "tag.fill"),
            HFRoomBoardCard(title: "Artwork set", detail: "Poster and backdrop readiness.", status: "Preview", systemImage: "rectangle.stack.fill"),
            HFRoomBoardCard(title: "Runtime", detail: "Runtime field for review.", status: "Local", systemImage: "clock.fill"),
            HFRoomBoardCard(title: "Advisory placeholder", detail: "Advisory language slot.", status: "Preview", systemImage: "exclamationmark.shield.fill")
        ]),
        HFRoomBoardColumn(title: "Press Delivery", subtitle: "Press and public package language.", status: "Preview", systemImage: "newspaper.fill", cards: [
            HFRoomBoardCard(title: "Press copy", detail: "Public story copy.", status: "Preview", systemImage: "text.alignleft"),
            HFRoomBoardCard(title: "Creator bio", detail: "Creator identity context.", status: "Draft", systemImage: "person.crop.square.fill"),
            HFRoomBoardCard(title: "Title description", detail: "Short title framing.", status: "Ready", systemImage: "doc.plaintext.fill"),
            HFRoomBoardCard(title: "Visual materials", detail: "Key art readiness notes.", status: "Preview", systemImage: "photo.stack.fill")
        ]),
        HFRoomBoardColumn(title: "Protected Delivery Systems", subtitle: "Professional boundaries stay clear.", status: "Protected", systemImage: "lock.shield.fill", cards: [
            HFRoomBoardCard(title: "Document handling separated", detail: "No local document workflow is connected.", status: "Protected", systemImage: "doc.badge.gearshape"),
            HFRoomBoardCard(title: "Processing systems separated", detail: "Professional engines stay outside this room.", status: "Protected", systemImage: "viewfinder"),
            HFRoomBoardCard(title: "Delivery services separated", detail: "No platform route is connected.", status: "Protected", systemImage: "tv.fill"),
            HFRoomBoardCard(title: "Review services separated", detail: "Handoff stays planning-only.", status: "Protected", systemImage: "checkmark.shield.fill")
        ])
    ]

    static let festivalPlatformReadinessRows: [HFRoomSuiteProgressRow] = [
        HFRoomSuiteProgressRow(title: "Festival synopsis", detail: "Festival copy is drafted.", status: "Draft", systemImage: "doc.text.fill"),
        HFRoomSuiteProgressRow(title: "Director statement", detail: "Statement is previewed.", status: "Preview", systemImage: "quote.bubble.fill"),
        HFRoomSuiteProgressRow(title: "Credits", detail: "Credits remain local.", status: "Local", systemImage: "person.2.fill"),
        HFRoomSuiteProgressRow(title: "Artwork set", detail: "Artwork readiness is previewed.", status: "Preview", systemImage: "rectangle.stack.fill"),
        HFRoomSuiteProgressRow(title: "Platform metadata", detail: "Metadata is drafted.", status: "Draft", systemImage: "tag.fill"),
        HFRoomSuiteProgressRow(title: "Delivery systems", detail: "Delivery services remain separated.", status: "Protected", systemImage: "lock.shield.fill")
    ]

    static let handoffPlannerStages: [HFRoomBoardColumn] = [
        HFRoomBoardColumn(title: "Package Review", subtitle: "Confirm title handoff basics.", status: "Preview", systemImage: "checkmark.seal.fill", cards: [
            HFRoomBoardCard(title: "Title facts", detail: "Title, genre, and format.", status: "Ready", systemImage: "tag.fill"),
            HFRoomBoardCard(title: "Public copy", detail: "Short public framing.", status: "Preview", systemImage: "text.alignleft"),
            HFRoomBoardCard(title: "Creator note", detail: "Creator context prepared.", status: "Draft", systemImage: "person.text.rectangle.fill")
        ]),
        HFRoomBoardColumn(title: "Festival Prep", subtitle: "Festival package language.", status: "Draft", systemImage: "rosette", cards: [
            HFRoomBoardCard(title: "Synopsis", detail: "Festival-facing synopsis.", status: "Draft", systemImage: "doc.text.fill"),
            HFRoomBoardCard(title: "Statement", detail: "Director statement slot.", status: "Preview", systemImage: "quote.bubble.fill"),
            HFRoomBoardCard(title: "Credits", detail: "Creative credits grouped.", status: "Local", systemImage: "person.2.fill")
        ]),
        HFRoomBoardColumn(title: "Platform Prep", subtitle: "Platform package checklist.", status: "Preview", systemImage: "checklist.checked", cards: [
            HFRoomBoardCard(title: "Artwork set", detail: "Poster and backdrop review.", status: "Preview", systemImage: "photo.stack.fill"),
            HFRoomBoardCard(title: "Runtime", detail: "Runtime field ready.", status: "Local", systemImage: "clock.fill"),
            HFRoomBoardCard(title: "Advisory", detail: "Advisory copy placeholder.", status: "Draft", systemImage: "exclamationmark.shield.fill")
        ]),
        HFRoomBoardColumn(title: "Final Handoff", subtitle: "Readiness summary before future workflows.", status: "Protected", systemImage: "lock.shield.fill", cards: [
            HFRoomBoardCard(title: "Missing items", detail: "Open review rows are visible.", status: "Draft", systemImage: "list.bullet.rectangle.fill"),
            HFRoomBoardCard(title: "Protected systems", detail: "Professional systems stay separate.", status: "Protected", systemImage: "lock.shield.fill"),
            HFRoomBoardCard(title: "Readiness summary", detail: "Manual handoff state only.", status: "Preview", systemImage: "checkmark.seal.fill")
        ])
    ]

    static let releaseMilestones: [HFRoomCalendarMilestone] = [
        HFRoomCalendarMilestone(title: "Announcement", dateLabel: "Preview Week 1", detail: "Public title framing and creator note.", status: "Draft", systemImage: "sparkles"),
        HFRoomCalendarMilestone(title: "Campaign Window", dateLabel: "Preview Week 2", detail: "Campaign headline, poster direction, and public blurb.", status: "Preview", systemImage: "megaphone.fill"),
        HFRoomCalendarMilestone(title: "Premiere Window", dateLabel: "Preview Week 4", detail: "Premiere copy, audience prompt, and watch-night positioning.", status: "Local", systemImage: "flag.checkered"),
        HFRoomCalendarMilestone(title: "Post-Release Push", dateLabel: "Preview Week 5", detail: "Creator update and community reflection prompt.", status: "Deferred", systemImage: "arrow.up.forward.circle.fill"),
        HFRoomCalendarMilestone(title: "Readiness Review", dateLabel: "Before Release", detail: "Materials, audience plan, campaign direction, safety boundary.", status: "Ready", systemImage: "checkmark.seal.fill")
    ]

    static let launchControlRows: [HFRoomSuiteProgressRow] = [
        HFRoomSuiteProgressRow(title: "Campaign identity", detail: "Campaign framing is previewed.", status: "Preview", systemImage: "megaphone.fill"),
        HFRoomSuiteProgressRow(title: "Premiere timeline", detail: "Release milestones are drafted.", status: "Draft", systemImage: "calendar.badge.clock"),
        HFRoomSuiteProgressRow(title: "Audience build", detail: "Audience warmup remains local.", status: "Local", systemImage: "person.3.fill"),
        HFRoomSuiteProgressRow(title: "Materials review", detail: "Public materials are previewed.", status: "Preview", systemImage: "photo.stack.fill"),
        HFRoomSuiteProgressRow(title: "Live release services", detail: "Release services remain separated.", status: "Protected", systemImage: "lock.shield.fill")
    ]

    static let publicMomentumColumns: [HFRoomBoardColumn] = [
        HFRoomBoardColumn(title: "Creator Updates", subtitle: "Prepared public update beats.", status: "Draft", systemImage: "text.bubble.fill", cards: [
            HFRoomBoardCard(title: "Behind-the-scenes note", detail: "A warm production memory.", status: "Draft", systemImage: "note.text"),
            HFRoomBoardCard(title: "Creator reflection", detail: "Story-first creator voice.", status: "Preview", systemImage: "quote.bubble.fill"),
            HFRoomBoardCard(title: "Premiere reminder copy", detail: "A soft release-week cue.", status: "Local", systemImage: "calendar.badge.clock"),
            HFRoomBoardCard(title: "Post-release thank-you", detail: "A closing creator note.", status: "Preview", systemImage: "heart.fill")
        ]),
        HFRoomBoardColumn(title: "Audience Energy", subtitle: "Prompts that gather viewers around a title.", status: "Preview", systemImage: "person.3.fill", cards: [
            HFRoomBoardCard(title: "Warm reaction prompt", detail: "Invite a story-first response.", status: "Ready", systemImage: "heart.text.square.fill"),
            HFRoomBoardCard(title: "Favorite scene question", detail: "Guide attention to a memorable moment.", status: "Local", systemImage: "sparkles"),
            HFRoomBoardCard(title: "Family watch-night angle", detail: "Frame who this title is for.", status: "Preview", systemImage: "figure.2.and.child.holdinghands"),
            HFRoomBoardCard(title: "Who would you watch this with?", detail: "A simple shared-viewing prompt.", status: "Ready", systemImage: "person.2.fill")
        ]),
        HFRoomBoardColumn(title: "Premiere Conversation", subtitle: "Opening-night prompt set.", status: "Preview", systemImage: "flag.checkered", cards: [
            HFRoomBoardCard(title: "Opening-night prompt", detail: "Start from the premiere mood.", status: "Ready", systemImage: "moon.stars.fill"),
            HFRoomBoardCard(title: "Community highlight", detail: "Surface a warm audience moment.", status: "Local", systemImage: "sparkles.rectangle.stack.fill"),
            HFRoomBoardCard(title: "Watch mood question", detail: "Ask what the title made viewers feel.", status: "Preview", systemImage: "questionmark.bubble.fill"),
            HFRoomBoardCard(title: "Creator response idea", detail: "A prepared reply theme.", status: "Draft", systemImage: "person.text.rectangle.fill")
        ]),
        HFRoomBoardColumn(title: "Community Readiness", subtitle: "Local readiness for the public layer.", status: "Protected", systemImage: "checkmark.shield.fill", cards: [
            HFRoomBoardCard(title: "Prompt pack ready", detail: "Conversation starters are organized.", status: "Ready", systemImage: "checkmark.seal.fill"),
            HFRoomBoardCard(title: "Update copy drafted", detail: "Creator notes are prepared.", status: "Draft", systemImage: "doc.text.fill"),
            HFRoomBoardCard(title: "Audience tone aligned", detail: "Warm, premium, story-first.", status: "Local", systemImage: "dial.low.fill"),
            HFRoomBoardCard(title: "Live systems protected", detail: "Participation services stay separate.", status: "Protected", systemImage: "lock.shield.fill")
        ])
    ]

    static let creatorUpdatePlannerStages: [HFRoomBoardColumn] = [
        HFRoomBoardColumn(title: "Before Premiere", subtitle: "Shape the first public note.", status: "Draft", systemImage: "calendar", cards: [
            HFRoomBoardCard(title: "Creator note", detail: "Set the title's personal context.", status: "Draft", systemImage: "note.text"),
            HFRoomBoardCard(title: "Watch mood", detail: "Warm, hopeful, family-forward.", status: "Ready", systemImage: "moon.stars.fill"),
            HFRoomBoardCard(title: "Title promise", detail: "Kindness, memory, and watch-night comfort.", status: "Preview", systemImage: "sparkles")
        ]),
        HFRoomBoardColumn(title: "Premiere Week", subtitle: "Prepare the audience-facing moment.", status: "Preview", systemImage: "flag.checkered", cards: [
            HFRoomBoardCard(title: "Audience prompt", detail: "Ask viewers what stayed with them.", status: "Preview", systemImage: "questionmark.bubble.fill"),
            HFRoomBoardCard(title: "Community angle", detail: "Invite shared family viewing.", status: "Local", systemImage: "person.3.fill"),
            HFRoomBoardCard(title: "Public blurb", detail: "Short release copy is ready to review.", status: "Draft", systemImage: "text.alignleft")
        ]),
        HFRoomBoardColumn(title: "After Premiere", subtitle: "Keep the story moving.", status: "Local", systemImage: "arrow.up.forward.circle.fill", cards: [
            HFRoomBoardCard(title: "Reflection prompt", detail: "What did the ending leave behind?", status: "Preview", systemImage: "text.bubble.fill"),
            HFRoomBoardCard(title: "Creator thank-you", detail: "A warm closing note.", status: "Draft", systemImage: "heart.fill"),
            HFRoomBoardCard(title: "Next-watch path", detail: "Guide viewers toward related titles.", status: "Ready", systemImage: "rectangle.stack.fill")
        ]),
        HFRoomBoardColumn(title: "Ongoing Community", subtitle: "Future public story beats.", status: "Preview", systemImage: "repeat.circle.fill", cards: [
            HFRoomBoardCard(title: "Recurring update idea", detail: "Creator notes after launch week.", status: "Preview", systemImage: "text.bubble.fill"),
            HFRoomBoardCard(title: "Title discussion prompt", detail: "Keep the conversation story-first.", status: "Local", systemImage: "bubble.left.and.bubble.right.fill"),
            HFRoomBoardCard(title: "Future release bridge", detail: "Connect audience energy into Launch.", status: "Draft", systemImage: "flag.checkered")
        ])
    ]

    static let conversationPrompts: [HFRoomBoardCard] = [
        HFRoomBoardCard(title: "What moment stayed with you?", detail: "Reflect on the emotional hook.", status: "Ready", systemImage: "sparkles"),
        HFRoomBoardCard(title: "Who would you watch this with?", detail: "Invite a shared viewing answer.", status: "Ready", systemImage: "person.2.fill"),
        HFRoomBoardCard(title: "What scene should others notice?", detail: "Guide viewers to a standout beat.", status: "Preview", systemImage: "eye.fill"),
        HFRoomBoardCard(title: "Why this title tonight?", detail: "Frame the premiere choice.", status: "Local", systemImage: "moon.stars.fill"),
        HFRoomBoardCard(title: "What did the ending make you feel?", detail: "Prompt an emotional response.", status: "Preview", systemImage: "heart.text.square.fill"),
        HFRoomBoardCard(title: "Which character felt closest to home?", detail: "Keep conversation warm and personal.", status: "Draft", systemImage: "person.fill")
    ]

    static let conversationReadinessRows: [HFRoomSuiteProgressRow] = [
        HFRoomSuiteProgressRow(title: "Prompts", detail: "Conversation starters are ready.", status: "Ready", systemImage: "text.bubble.fill"),
        HFRoomSuiteProgressRow(title: "Creator response", detail: "Response themes are previewed.", status: "Preview", systemImage: "person.text.rectangle.fill"),
        HFRoomSuiteProgressRow(title: "Audience groups", detail: "Groups remain local.", status: "Local", systemImage: "person.3.fill"),
        HFRoomSuiteProgressRow(title: "Live community", detail: "Participation services remain separate.", status: "Protected", systemImage: "lock.shield.fill")
    ]

    static let publicReleaseMilestones: [HFRoomCalendarMilestone] = [
        HFRoomCalendarMilestone(title: "Announcement", dateLabel: "Preview Week 1", detail: "Public title framing, creator note, and first poster direction.", status: "Draft", systemImage: "sparkles"),
        HFRoomCalendarMilestone(title: "Trailer / Preview Window", dateLabel: "Preview Week 2", detail: "First public blurb, still-frame row, and watch mood.", status: "Preview", systemImage: "rectangle.stack.fill"),
        HFRoomCalendarMilestone(title: "Premiere Week", dateLabel: "Preview Week 4", detail: "Premiere copy, community prompt, and creator update.", status: "Local", systemImage: "flag.checkered"),
        HFRoomCalendarMilestone(title: "Opening Night", dateLabel: "Preview Night", detail: "Watch-night framing and audience conversation starter.", status: "Ready", systemImage: "moon.stars.fill"),
        HFRoomCalendarMilestone(title: "Post-Release Push", dateLabel: "Preview Week 5", detail: "Creator reflection, related titles, and continuing audience energy.", status: "Preview", systemImage: "arrow.up.forward.circle.fill")
    ]

    static let campaignMomentumColumns: [HFRoomBoardColumn] = [
        HFRoomBoardColumn(title: "Campaign Identity", subtitle: "Public story frame.", status: "Preview", systemImage: "megaphone.fill", cards: [
            HFRoomBoardCard(title: "Headline", detail: "Warm premiere for a HighFive Original.", status: "Draft", systemImage: "textformat.size"),
            HFRoomBoardCard(title: "Public promise", detail: "A heartfelt family watch-night story.", status: "Preview", systemImage: "sparkles"),
            HFRoomBoardCard(title: "Creator note", detail: "Personal context for the release.", status: "Local", systemImage: "person.text.rectangle.fill"),
            HFRoomBoardCard(title: "Tone line", detail: "Warm, premium, story-first.", status: "Ready", systemImage: "dial.low.fill")
        ]),
        HFRoomBoardColumn(title: "Materials Window", subtitle: "Public materials to review.", status: "Draft", systemImage: "photo.stack.fill", cards: [
            HFRoomBoardCard(title: "Poster direction", detail: "Soft gold light and intimate portraits.", status: "Draft", systemImage: "photo.fill"),
            HFRoomBoardCard(title: "Press copy", detail: "Short and long public blurbs.", status: "Preview", systemImage: "newspaper.fill"),
            HFRoomBoardCard(title: "Still-frame row", detail: "Key emotional moments.", status: "Local", systemImage: "rectangle.stack.fill"),
            HFRoomBoardCard(title: "Title metadata", detail: "Genre, format, and advisory placeholder.", status: "Preview", systemImage: "tag.fill")
        ]),
        HFRoomBoardColumn(title: "Audience Build", subtitle: "Momentum into premiere week.", status: "Local", systemImage: "person.3.fill", cards: [
            HFRoomBoardCard(title: "Creator update", detail: "Release-week creator voice.", status: "Preview", systemImage: "text.bubble.fill"),
            HFRoomBoardCard(title: "Community prompt", detail: "Opening-night conversation starter.", status: "Ready", systemImage: "questionmark.bubble.fill"),
            HFRoomBoardCard(title: "Watch-night hook", detail: "Who would you watch this with?", status: "Local", systemImage: "moon.stars.fill"),
            HFRoomBoardCard(title: "Premiere reminder copy", detail: "Soft public cue for launch week.", status: "Draft", systemImage: "calendar.badge.clock")
        ]),
        HFRoomBoardColumn(title: "Release Readiness", subtitle: "Final local review board.", status: "Protected", systemImage: "checkmark.shield.fill", cards: [
            HFRoomBoardCard(title: "Title page copy", detail: "Public synopsis and headline.", status: "Preview", systemImage: "doc.text.fill"),
            HFRoomBoardCard(title: "Campaign copy", detail: "Headline and promise aligned.", status: "Draft", systemImage: "megaphone.fill"),
            HFRoomBoardCard(title: "Media kit check", detail: "Public materials reviewed.", status: "Local", systemImage: "shippingbox.fill"),
            HFRoomBoardCard(title: "Safety boundary", detail: "Live release services remain separate.", status: "Protected", systemImage: "lock.shield.fill")
        ])
    ]

    static let premiereReadinessRows: [HFRoomSuiteProgressRow] = [
        HFRoomSuiteProgressRow(title: "Public framing", detail: "Title promise is ready.", status: "Ready", systemImage: "sparkles"),
        HFRoomSuiteProgressRow(title: "Campaign headline", detail: "Headline is previewed.", status: "Preview", systemImage: "megaphone.fill"),
        HFRoomSuiteProgressRow(title: "Media materials", detail: "Materials are drafted.", status: "Draft", systemImage: "photo.stack.fill"),
        HFRoomSuiteProgressRow(title: "Audience prompts", detail: "Prompts remain local.", status: "Local", systemImage: "text.bubble.fill"),
        HFRoomSuiteProgressRow(title: "Creator update", detail: "Update copy is previewed.", status: "Preview", systemImage: "person.text.rectangle.fill"),
        HFRoomSuiteProgressRow(title: "Live release services", detail: "Release services remain separate.", status: "Protected", systemImage: "lock.shield.fill")
    ]
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

private enum HFCreatorPitchPackagePreviewData {
    static let pitch = HFCreatorPitchPackage(
        projectTitle: "The Friendly",
        pitchTitle: "A warm premium premiere for family-forward streaming.",
        logline: "A heartfelt cinematic story built around kindness, memory, and a family watch-night mood.",
        genre: "Drama / Family / Original",
        format: "Feature Film",
        audience: "Premium streaming viewers and family watch-night audiences.",
        releaseAngle: "A HighFive Original positioned for a warm premiere campaign.",
        pitchStatus: "Preview Pitch",
        sections: [
            HFCreatorPitchSection(
                title: "Story Positioning",
                subtitle: "Define the story promise and emotional lane.",
                status: "Ready",
                systemImage: "doc.text.fill",
                shapes: "Shapes the core promise, emotional hook, and genre lane for a premium pitch.",
                readySummary: "Core promise and emotional hook are ready to inspect.",
                previewSummary: "Comparable feel and audience mood remain local pitch notes.",
                deferredSummary: "Live editorial review is not connected.",
                beats: [
                    HFCreatorPitchBeat(title: "Core promise", detail: "A kind, memory-led family story with cinematic warmth.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Emotional hook", detail: "Kindness reframes the family watch-night mood.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Genre lane", detail: "Drama, family, and original streaming positioning.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Audience mood", detail: "Hopeful, premium, and shared.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Comparable feel", detail: "Festival-friendly warmth with streaming accessibility.", state: "Preview")
                ]
            ),
            HFCreatorPitchSection(
                title: "Audience Promise",
                subtitle: "Clarify who the title serves and why they stay.",
                status: "Preview",
                systemImage: "person.3.fill",
                shapes: "Shapes the primary viewer, watch-night use case, and viewer takeaway.",
                readySummary: "Primary viewer and title promise are defined.",
                previewSummary: "Community angle and viewer takeaway are still preview copy.",
                deferredSummary: "Live audience systems remain disconnected.",
                beats: [
                    HFCreatorPitchBeat(title: "Primary viewer", detail: "Premium viewers looking for a warm original.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Watch-night use case", detail: "A family-forward weekend premiere.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Community angle", detail: "A story people can recommend across generations.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Title promise", detail: "A heartfelt original built around kindness.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Viewer takeaway", detail: "Leave with a warmer sense of memory and connection.", state: "Draft")
                ]
            ),
            HFCreatorPitchSection(
                title: "Format / Release Fit",
                subtitle: "Match format, runtime, and placement to the title.",
                status: "Draft",
                systemImage: "rectangle.stack.fill",
                shapes: "Shapes the feature fit, release path, premiere suitability, and HighFive placement.",
                readySummary: "Feature format and HighFive placement are clear.",
                previewSummary: "Runtime expectation and release path remain pitch placeholders.",
                deferredSummary: "Live release services remain disconnected.",
                beats: [
                    HFCreatorPitchBeat(title: "Feature fit", detail: "Best held as a feature-length emotional arc.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Runtime expectation", detail: "Feature-length placeholder for pitch context.", state: "Draft"),
                    HFCreatorPitchBeat(title: "Release path", detail: "Warm original premiere with follow-on discovery.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Premiere suitability", detail: "Strong fit for a calm featured premiere.", state: "Preview"),
                    HFCreatorPitchBeat(title: "HighFive placement", detail: "Originals-led story with family watch appeal.", state: "Ready")
                ]
            ),
            HFCreatorPitchSection(
                title: "Creator Statement",
                subtitle: "Frame the voice behind the title.",
                status: "Preview",
                systemImage: "person.text.rectangle.fill",
                shapes: "Shapes creator voice, story origin, timing, and audience connection.",
                readySummary: "Creator voice and title intention are framed.",
                previewSummary: "Story origin and why-now copy are local editorial notes.",
                deferredSummary: "Identity services remain disconnected.",
                beats: [
                    HFCreatorPitchBeat(title: "Creator voice", detail: "Warm, grounded, and cinematic.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Story origin", detail: "A personal idea about kindness and memory.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Why now", detail: "A gentle original for viewers seeking emotional calm.", state: "Draft"),
                    HFCreatorPitchBeat(title: "Audience connection", detail: "The title invites shared family conversation.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Title intention", detail: "Make the viewer feel seen and restored.", state: "Ready")
                ]
            ),
            HFCreatorPitchSection(
                title: "Visual / Media Notes",
                subtitle: "Preview the visual direction without media intake.",
                status: "Deferred",
                systemImage: "photo.stack.fill",
                shapes: "Shapes poster direction, stills placeholders, tone references, and media-kit reminders.",
                readySummary: "Tone reference and title card note are present.",
                previewSummary: "Poster direction and stills are planning placeholders.",
                deferredSummary: "Library access and media intake remain disconnected.",
                beats: [
                    HFCreatorPitchBeat(title: "Poster direction", detail: "Warm key art with a clear family silhouette.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Stills placeholder", detail: "Local row for future still selection context.", state: "Deferred"),
                    HFCreatorPitchBeat(title: "Tone reference", detail: "Soft gold, gentle contrast, quiet cinematic frame.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Title card note", detail: "Simple, premium, and readable.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Media kit reminder", detail: "Press copy and creator bio need final review.", state: "Draft")
                ]
            ),
            HFCreatorPitchSection(
                title: "Launch Angle",
                subtitle: "Connect the pitch to a future campaign plan.",
                status: "Local",
                systemImage: "flag.checkered",
                shapes: "Shapes campaign hook, premiere line, creator update, and launch-room bridge.",
                readySummary: "Campaign hook and premiere line are ready to preview.",
                previewSummary: "Creator update and audience build remain local planning notes.",
                deferredSummary: "Live release and audience-alert systems remain disconnected.",
                beats: [
                    HFCreatorPitchBeat(title: "Campaign hook", detail: "A heartfelt HighFive Original for family watch night.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Premiere line", detail: "A warm premiere built around kindness and memory.", state: "Ready"),
                    HFCreatorPitchBeat(title: "Creator update", detail: "A creator note can frame the title origin.", state: "Draft"),
                    HFCreatorPitchBeat(title: "Audience build", detail: "Family-forward discovery and saved-title momentum.", state: "Preview"),
                    HFCreatorPitchBeat(title: "Launch room bridge", detail: "Prepared for local campaign planning only.", state: "Local")
                ]
            )
        ],
        readinessRows: [
            HFCreatorPitchReadinessRow(title: "Story Positioning", detail: "Core story promise is ready for local review.", status: "Ready"),
            HFCreatorPitchReadinessRow(title: "Audience Promise", detail: "Viewer promise and use case are preview-ready.", status: "Preview"),
            HFCreatorPitchReadinessRow(title: "Format / Release Fit", detail: "Feature positioning needs one more pass.", status: "Draft"),
            HFCreatorPitchReadinessRow(title: "Creator Statement", detail: "Voice and intention are framed.", status: "Preview"),
            HFCreatorPitchReadinessRow(title: "Media Notes", detail: "Visual direction remains a planning placeholder.", status: "Deferred"),
            HFCreatorPitchReadinessRow(title: "Delivery Systems", detail: "Professional delivery remains separated.", status: "Protected")
        ]
    )
}

private enum HFCreatorMediaKitPreviewData {
    static let kit = HFCreatorMediaKit(
        projectTitle: "The Friendly",
        kitTitle: "Warm premiere media kit for a HighFive Original.",
        publicBlurb: "A heartfelt cinematic story about kindness, memory, and the feeling of a family watch night.",
        visualDirection: "Soft gold light, intimate portraits, hopeful family atmosphere.",
        creatorBio: "A creator-led story package prepared for premium streaming discovery.",
        kitStatus: "Preview Kit",
        sections: [
            HFCreatorMediaKitSection(
                title: "Poster / Key Art Direction",
                subtitle: "Shape the first public visual signal.",
                status: "Draft",
                systemImage: "photo.artframe",
                prepares: "Prepares the public key-art mood, palette, title treatment, and tagline direction.",
                readySummary: "Visual mood and palette are framed for local review.",
                previewSummary: "Title treatment and tagline idea remain preview copy.",
                deferredSummary: "Real media intake and production services remain disconnected.",
                items: [
                    HFCreatorMediaKitItem(title: "Hero image mood", detail: "Soft family portrait energy with premium cinematic warmth.", state: "Draft"),
                    HFCreatorMediaKitItem(title: "Color palette", detail: "Soft gold, deep black, warm ivory, and restrained amber.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Title treatment", detail: "Simple, readable, and centered on emotional clarity.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Tagline idea", detail: "A family story about what kindness leaves behind.", state: "Draft"),
                    HFCreatorMediaKitItem(title: "Poster note", detail: "Keep the art intimate, not spectacle-led.", state: "Preview")
                ]
            ),
            HFCreatorMediaKitSection(
                title: "Still Frames",
                subtitle: "Plan the public still sequence.",
                status: "Preview",
                systemImage: "rectangle.stack.fill",
                prepares: "Prepares the still-frame story order for press, title pages, and launch planning.",
                readySummary: "Emotional close-up and family table moment are ready to discuss.",
                previewSummary: "Exterior, transition, and premiere still rows are planning placeholders.",
                deferredSummary: "Image library access and media selection remain disconnected.",
                items: [
                    HFCreatorMediaKitItem(title: "Emotional close-up", detail: "A quiet face-led frame that sells the title heart.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Family table moment", detail: "A shared scene that communicates watch-night warmth.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Golden-hour exterior", detail: "A hopeful exterior frame for release pages.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Quiet transition", detail: "A softer frame for editorial pacing context.", state: "Draft"),
                    HFCreatorMediaKitItem(title: "Premiere still placeholder", detail: "A local row for future public-review context.", state: "Deferred")
                ]
            ),
            HFCreatorMediaKitSection(
                title: "Press Copy",
                subtitle: "Prepare public synopsis and quote language.",
                status: "Ready",
                systemImage: "newspaper.fill",
                prepares: "Prepares short-form and long-form copy for public title presentation.",
                readySummary: "Short synopsis and review-ready summary are ready for local review.",
                previewSummary: "Premiere blurb and creator quote remain editable planning copy.",
                deferredSummary: "Server release systems remain disconnected.",
                items: [
                    HFCreatorMediaKitItem(title: "Short synopsis", detail: "A warm original about kindness, memory, and family connection.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Long synopsis", detail: "A fuller story summary for title pages and press context.", state: "Draft"),
                    HFCreatorMediaKitItem(title: "Premiere blurb", detail: "A soft public-facing line for the launch surface.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Creator quote", detail: "A concise note about why this story matters now.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Review-ready summary", detail: "A polished local copy block for internal review.", state: "Ready")
                ]
            ),
            HFCreatorMediaKitSection(
                title: "Creator Bio",
                subtitle: "Frame the creator voice behind the title.",
                status: "Preview",
                systemImage: "person.text.rectangle.fill",
                prepares: "Prepares the public creator profile, story origin, and audience connection.",
                readySummary: "Creator voice and personal statement are framed.",
                previewSummary: "Background note and story origin remain local preview text.",
                deferredSummary: "Identity services remain disconnected.",
                items: [
                    HFCreatorMediaKitItem(title: "Creator voice", detail: "Warm, grounded, and emotionally direct.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Background note", detail: "A brief context line for creator discovery.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Story origin", detail: "Kindness and memory are the source idea.", state: "Draft"),
                    HFCreatorMediaKitItem(title: "Audience connection", detail: "The title is positioned for shared family viewing.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Personal statement", detail: "A clear intention for why the story should be watched.", state: "Ready")
                ]
            ),
            HFCreatorMediaKitSection(
                title: "Credits / Metadata",
                subtitle: "Organize public title facts.",
                status: "Draft",
                systemImage: "list.bullet.rectangle.fill",
                prepares: "Prepares the public facts that support title pages, press notes, and package review.",
                readySummary: "Director and runtime rows are present.",
                previewSummary: "Producer, cast, and advisory rows remain placeholders.",
                deferredSummary: "Platform services remain disconnected.",
                items: [
                    HFCreatorMediaKitItem(title: "Director", detail: "Creator-led director line for public package review.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Producer", detail: "Producer credit row remains a local placeholder.", state: "Draft"),
                    HFCreatorMediaKitItem(title: "Cast placeholder", detail: "Cast line can be reviewed without account services.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Runtime", detail: "Feature-length placeholder for public metadata.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Rating / advisory placeholder", detail: "Public guidance stays planning-only.", state: "Draft")
                ]
            ),
            HFCreatorMediaKitSection(
                title: "Public Launch Blurb",
                subtitle: "Bridge the kit into launch planning.",
                status: "Local",
                systemImage: "megaphone.fill",
                prepares: "Prepares public headline, audience hook, watch-night promise, and Launch Room direction.",
                readySummary: "Hero headline and watch-night promise are ready to preview.",
                previewSummary: "Audience hook and platform positioning remain local planning notes.",
                deferredSummary: "Live campaign and delivery systems remain disconnected.",
                items: [
                    HFCreatorMediaKitItem(title: "Hero headline", detail: "The Friendly brings warmth to family watch night.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Audience hook", detail: "For viewers who want an original with heart.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Watch-night promise", detail: "A calm, premium story to share together.", state: "Ready"),
                    HFCreatorMediaKitItem(title: "Platform positioning", detail: "HighFive Original with discovery and premiere value.", state: "Preview"),
                    HFCreatorMediaKitItem(title: "Launch-room bridge", detail: "Campaign copy can move into local Launch planning.", state: "Local")
                ]
            )
        ],
        readinessRows: [
            HFCreatorMediaKitReadinessRow(title: "Poster Direction", detail: "Key-art mood and palette are drafted.", status: "Draft"),
            HFCreatorMediaKitReadinessRow(title: "Still Frames", detail: "Public still sequence is preview-ready.", status: "Preview"),
            HFCreatorMediaKitReadinessRow(title: "Press Copy", detail: "Short copy and summary are ready.", status: "Ready"),
            HFCreatorMediaKitReadinessRow(title: "Creator Bio", detail: "Creator voice is framed for public context.", status: "Preview"),
            HFCreatorMediaKitReadinessRow(title: "Credits / Metadata", detail: "Title facts need one more pass.", status: "Draft"),
            HFCreatorMediaKitReadinessRow(title: "Delivery Systems", detail: "Professional handoff remains separated.", status: "Protected")
        ]
    )
}

private enum HFCreatorLaunchPrepPreviewData {
    static let prep = HFCreatorLaunchPrep(
        projectTitle: "The Friendly",
        prepTitle: "Warm premiere launch prep for a HighFive Original.",
        positioning: "A family-forward original positioned around kindness, memory, and a premium watch-night mood.",
        releaseWindow: "Preview premiere window",
        audienceWarmup: "Creator update, public blurb, watch-night promise, and community prompt.",
        prepStatus: "Preview Launch Prep",
        sections: [
            HFCreatorLaunchPrepSection(
                title: "Premiere Positioning",
                subtitle: "Frame the public release promise.",
                status: "Ready",
                systemImage: "sparkles.tv.fill",
                prepares: "Prepares the premiere promise, title hook, watch-night angle, mood line, and public framing.",
                readySummary: "Premiere promise and title hook are ready for local review.",
                previewSummary: "Mood line and public framing remain preview copy.",
                deferredSummary: "Live release services remain disconnected.",
                items: [
                    HFCreatorLaunchPrepItem(title: "Premiere promise", detail: "A warm original made for shared family viewing.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Title hook", detail: "Kindness, memory, and a premium watch-night mood.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Watch-night angle", detail: "Positioned as a calm weekend premiere.", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Mood line", detail: "Soft gold, gentle, hopeful, and intimate.", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Public framing", detail: "A HighFive Original with creator-led warmth.", state: "Draft")
                ]
            ),
            HFCreatorLaunchPrepSection(
                title: "Campaign Direction",
                subtitle: "Shape launch copy without live campaign systems.",
                status: "Preview",
                systemImage: "megaphone.fill",
                prepares: "Prepares campaign headline, creator quote, release copy, visual phrase, and Launch Room bridge.",
                readySummary: "Campaign headline and release copy are framed.",
                previewSummary: "Creator quote and visual phrase remain local planning notes.",
                deferredSummary: "Campaign execution remains disconnected.",
                items: [
                    HFCreatorLaunchPrepItem(title: "Campaign headline", detail: "The Friendly brings warmth to family watch night.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Creator quote", detail: "A short origin note can anchor the public story.", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Release copy", detail: "A heartfelt original centered on kindness and memory.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Visual phrase", detail: "Soft gold premiere with intimate family energy.", state: "Draft"),
                    HFCreatorLaunchPrepItem(title: "Launch-room bridge", detail: "Prepared for local Launch Room planning.", state: "Local")
                ]
            ),
            HFCreatorLaunchPrepSection(
                title: "Audience Warmup",
                subtitle: "Plan the audience setup before launch.",
                status: "Local",
                systemImage: "person.3.fill",
                prepares: "Prepares creator update topic, community prompt, family viewer hook, early interest note, and watch reminder copy.",
                readySummary: "Family viewer hook and creator update topic are ready to preview.",
                previewSummary: "Community prompt and early-interest note remain local copy.",
                deferredSummary: "Audience systems remain disconnected.",
                items: [
                    HFCreatorLaunchPrepItem(title: "Creator update topic", detail: "Why this story belongs in a family watch night.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Community prompt", detail: "What memory would you want to share after watching?", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Family viewer hook", detail: "A story to watch with someone who remembers you.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Early interest note", detail: "Local copy for future audience planning.", state: "Draft"),
                    HFCreatorLaunchPrepItem(title: "Watch reminder copy", detail: "A soft prompt for the premiere window.", state: "Preview")
                ]
            ),
            HFCreatorLaunchPrepSection(
                title: "Launch Materials",
                subtitle: "Gather the title materials needed for release planning.",
                status: "Draft",
                systemImage: "rectangle.stack.badge.person.crop.fill",
                prepares: "Prepares poster direction, press copy, public blurb, still-frame row, and creator note.",
                readySummary: "Public blurb and creator note are framed.",
                previewSummary: "Poster direction and still-frame row are planning placeholders.",
                deferredSummary: "Media intake and delivery services remain disconnected.",
                items: [
                    HFCreatorLaunchPrepItem(title: "Poster direction", detail: "Warm key-art tone from the Media Kit.", state: "Draft"),
                    HFCreatorLaunchPrepItem(title: "Press copy", detail: "Short public copy is ready for launch review.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Public blurb", detail: "A family-forward original about kindness and memory.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Still-frame row", detail: "Local still sequence supports launch planning.", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Creator note", detail: "Voice and origin carry forward from the pitch.", state: "Preview")
                ]
            ),
            HFCreatorLaunchPrepSection(
                title: "Release Checklist",
                subtitle: "Check package alignment before handoff.",
                status: "Preview",
                systemImage: "checklist.checked",
                prepares: "Prepares title page copy, campaign headline, media kit check, pitch alignment, and readiness review.",
                readySummary: "Title page copy and pitch alignment are readable.",
                previewSummary: "Media kit check and readiness review remain local rows.",
                deferredSummary: "Server release services remain disconnected.",
                items: [
                    HFCreatorLaunchPrepItem(title: "Title page copy", detail: "Public title presentation is ready to inspect.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Campaign headline", detail: "Launch headline matches the media kit tone.", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Media kit check", detail: "Poster, stills, press copy, and creator bio are grouped.", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Pitch alignment", detail: "Story promise matches the public launch copy.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Readiness review", detail: "Final local pass before Launch Room planning.", state: "Draft")
                ]
            ),
            HFCreatorLaunchPrepSection(
                title: "Launch Room Handoff",
                subtitle: "Bridge Creator Studio into Launch Room planning.",
                status: "Local",
                systemImage: "arrow.triangle.branch",
                prepares: "Prepares campaign plan, audience tone, materials status, safety boundary, and future Launch Room bridge.",
                readySummary: "Campaign plan and materials status are summarized.",
                previewSummary: "Audience tone and Launch Room bridge stay local.",
                deferredSummary: "Live launch systems remain disconnected.",
                items: [
                    HFCreatorLaunchPrepItem(title: "Campaign plan", detail: "Warm premiere push for a HighFive Original.", state: "Preview"),
                    HFCreatorLaunchPrepItem(title: "Audience tone", detail: "Family-forward, cinematic, premium.", state: "Ready"),
                    HFCreatorLaunchPrepItem(title: "Materials status", detail: "Media Kit and Pitch surfaces feed this handoff.", state: "Local"),
                    HFCreatorLaunchPrepItem(title: "Safety boundary", detail: "Live launch operations remain separated.", state: "Protected"),
                    HFCreatorLaunchPrepItem(title: "Future Launch Room bridge", detail: "Prepared for local Launch Room review.", state: "Local")
                ]
            )
        ],
        readinessRows: [
            HFCreatorLaunchPrepReadinessRow(title: "Premiere Positioning", detail: "Title promise and hook are ready.", status: "Ready"),
            HFCreatorLaunchPrepReadinessRow(title: "Campaign Direction", detail: "Headline and release copy are preview-ready.", status: "Preview"),
            HFCreatorLaunchPrepReadinessRow(title: "Audience Warmup", detail: "Creator update and community prompt are local.", status: "Local"),
            HFCreatorLaunchPrepReadinessRow(title: "Launch Materials", detail: "Poster and still rows need one more pass.", status: "Draft"),
            HFCreatorLaunchPrepReadinessRow(title: "Release Checklist", detail: "Package alignment is visible for review.", status: "Preview"),
            HFCreatorLaunchPrepReadinessRow(title: "Live Launch Systems", detail: "Release services remain separated.", status: "Protected")
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

private struct HFProfileProductSuiteProgressSection: View {
    let rows: [HFRoomSuiteProgressRow]

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Suite Progress", accent: HFColors.gold)
                        Text("HighFive Product Suite")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Watch, Create, Connect, Launch, and Export are now local product previews inside the same streaming-first app.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(rows) { row in
                        HFRoomSuiteProgressTile(row: row, accent: row.title == "INTERNAL" ? Color.gray : HFColors.gold)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HighFive Product Suite, local ecosystem progress summary, internal tools remain internal only")
        .accessibilityIdentifier("hf.profile.productSuiteProgress")
    }
}

private struct HFProfileEcosystemPresentationSection: View {
    private let acts = HFEcosystemPresentationData.acts

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 50, height: 50)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Presentation Preview", accent: HFColors.gold)

                        Text("Ecosystem Presentation Mode")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Walk the HighFive story from Watch to Create, Connect, Launch, Export, then internal proof.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 138), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(acts) { act in
                        ecosystemActTile(act)
                    }
                }

                NavigationLink {
                    FinalDemoTourView()
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "play.rectangle.on.rectangle.fill")
                        Text("Review Product Story")
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(HFColors.goldGradient)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Review Product Story, open local presentation preview")
                .accessibilityIdentifier("hf.profile.presentationStoryCard")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Ecosystem Presentation Mode, local presentation preview for Watch Create Connect Launch Export and internal proof")
        .accessibilityIdentifier("hf.profile.ecosystemPresentationMode")
    }

    private func ecosystemActTile(_ act: HFEcosystemPresentationAct) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(spacing: HFSpacing.xs) {
                Image(systemName: act.systemImage)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(HFColors.gold)

                Text(act.title)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.gold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Text(act.subtitle)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(act.proof)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.78)

            HFRoomStatusChip(title: act.status, accent: act.status == "Internal" ? Color.gray : HFColors.gold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(HFColors.glassSurface)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(act.title), \(act.subtitle), proof \(act.proof), status \(act.status)")
    }
}

private struct HFProfileHighFiveProductStorySection: View {
    private let rows = HFEcosystemPresentationData.productStoryRows

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "HighFive Product Story", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.glassStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    Text("HighFive starts as a premium streaming app. Profile opens the product suite: Watch, Create, Connect, Launch, and Export. Developer / QA stays internal.")
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        ForEach(rows) { row in
                            HFRoomSuiteProgressTile(
                                row: HFRoomSuiteProgressRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage),
                                accent: row.status == "Internal" || row.status == "Protected" ? Color.gray : HFColors.gold
                            )
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("HighFive Product Story, streaming first product suite and internal proof remain separated")
        .accessibilityIdentifier("hf.profile.highfiveProductStory")
    }
}

private struct HFProfileFunctionalCoreSummarySection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local App Behavior", accent: HFColors.gold)
                        Text("Functional Core")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Movies, Watch Now, My List, Downloads, local updates, release checklist, and delivery summary now share a connected local app foundation.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.currentFunctionalProofRows, id: \.self) { row in
                        HFConsumerMomentumRow(title: row, detail: "Unified local app state", status: "Connected", systemImage: "checkmark.circle.fill")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Functional Core, connected app foundation for movies Watch Now My List Downloads local updates release checklist and delivery summary")
        .accessibilityIdentifier("hf.profile.functionalCoreSummary")
        .accessibilityIdentifier("hf.profile.connectedAppSummary")
    }
}

private struct HFProfileCatalogServiceSummarySection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Catalog Adapter", accent: HFColors.gold)
                            .accessibilityIdentifier("hf.catalog.localAdapter.active")
                        Text("Movie Catalog Service")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Remote Catalog Provider")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                        Text("Not Connected Yet")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .accessibilityIdentifier("hf.catalog.provider.notConnected")
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.catalogReadinessRows, id: \.self) { row in
                        HFConsumerMomentumRow(title: row, detail: "Catalog readiness proof", status: row.contains("Not Connected Yet") ? "Future" : "Active", systemImage: "checkmark.circle.fill")
                    }
                }

                HFInsightCard(
                    title: "Future Integration",
                    message: "Ready for provider selection and contract wiring.",
                    systemImage: "arrow.triangle.2.circlepath"
                )
                .accessibilityIdentifier("hf.catalog.remoteReady.status")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Movie Catalog Service, Local Catalog Adapter active, Remote Catalog Provider Not Connected Yet")
        .accessibilityIdentifier("hf.catalog.profile.serviceSummary")
        .accessibilityIdentifier("hf.catalog.profile.readiness")
        .accessibilityIdentifier("hf.profile.catalogServiceProof")
    }
}

private struct HFProfilePlayerServiceSummarySection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Playback Source Resolver", accent: HFColors.gold)
                        Text("Player Service")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Watch Now route, catalog identity, and playback source readiness are connected locally.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.playerReadinessRows, id: \.self) { row in
                        HFConsumerMomentumRow(title: row, detail: "Player service readiness", status: row.contains("Not Connected Yet") || row.contains("Missing") ? "Future" : "Active", systemImage: "checkmark.circle.fill")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Player Service, Watch Now route, catalog identity, and playback source resolver are active locally")
        .accessibilityIdentifier("hf.player.profile.serviceSummary")
        .accessibilityIdentifier("hf.player.profile.readiness")
        .accessibilityIdentifier("hf.profile.playerServiceProof")
    }
}

private struct HFProfileLibraryDownloadsServiceSection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "icloud.and.arrow.down.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Ready", accent: HFColors.gold)
                        Text("Library + Downloads Services")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Cloud Library Service and Offline Asset Service are connected locally for \(streamingStore.activeViewingProfile.displayName).")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    HFConsumerMomentumRow(title: "Cloud Library Service", detail: "Local Ready", status: "Active", systemImage: "bookmark.fill")
                        .accessibilityIdentifier("hf.profile.cloudLibraryProof")
                    HFConsumerMomentumRow(title: "Saved List Sync", detail: "Not Connected Yet", status: "Future", systemImage: "icloud.slash.fill")
                    HFConsumerMomentumRow(title: "Offline Asset Service", detail: "Local Ready", status: "Active", systemImage: "arrow.down.circle.fill")
                        .accessibilityIdentifier("hf.profile.offlineAssetProof")
                    HFConsumerMomentumRow(title: "Remote Download Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
                        .accessibilityIdentifier("hf.profile.downloadProviderStatus")
                    HFConsumerMomentumRow(title: "Media storage", detail: "Not Connected Yet", status: "Future", systemImage: "tray")
                    HFConsumerMomentumRow(title: "Privacy / Account Boundary", detail: "Ready", status: "Ready", systemImage: "person.crop.circle.badge.checkmark")
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Library and Downloads Services, Cloud Library Service local ready, Offline Asset Service local ready, Remote Download Provider Not Connected Yet")
        .accessibilityIdentifier("hf.profile.libraryDownloadsService")
    }
}

private struct HFProfileCommunicationServicesSection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Communication Adapter", accent: HFColors.gold)
                        Text("Communication Services")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Audience updates and channel records stay local while remote communication and moderation providers remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.communicationProofRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Communication Services, Local Communication Adapter active, Remote Communication Provider Not Connected Yet, Moderation Provider Not Connected Yet")
        .accessibilityIdentifier("hf.profile.communicationServices")
        .accessibilityIdentifier("hf.profile.communicationProof")
        .accessibilityIdentifier("hf.profile.communicationProviderStatus")
        .accessibilityIdentifier("hf.profile.moderationReadiness")
    }
}

private struct HFProfileLaunchCampaignServicesSection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Launch Campaign Adapter", accent: HFColors.gold)
                        Text("Launch Campaign Services")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Release calendar, milestones, communication bridge, and export handoff are connected locally while remote campaign providers remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.launchCampaignProofRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch Campaign Services, Local Launch Campaign Adapter active, Remote Campaign Provider Not Connected Yet")
        .accessibilityIdentifier("hf.profile.launchCampaignServices")
        .accessibilityIdentifier("hf.profile.launchCampaignProof")
        .accessibilityIdentifier("hf.profile.launchCampaignProviderStatus")
        .accessibilityIdentifier("hf.profile.launchCampaignReadiness")
    }
}

private struct HFProfileExportDeliveryServicesSection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Export Delivery Adapter", accent: HFColors.gold)
                        Text("Export Delivery Services")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Delivery Package, Distribution Handoff, Launch Campaign Handoff, and provider readiness are connected locally while remote delivery providers remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.exportDeliveryProofRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Export Delivery Services, Local Export Delivery Adapter active, Remote Delivery Provider Not Connected Yet")
        .accessibilityIdentifier("hf.profile.exportDeliveryServices")
        .accessibilityIdentifier("hf.profile.exportDeliveryProof")
        .accessibilityIdentifier("hf.profile.exportDeliveryProviderStatus")
        .accessibilityIdentifier("hf.profile.exportDeliveryReadiness")
    }
}

private struct HFProfilePaymentEntitlementServicesSection: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                header
                readinessRows
                localToRemoteAdapterRows
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Payment and Entitlement Services, Local Entitlement Adapter active, Remote Payment Provider Not Connected Yet, Store Provider Not Connected Yet")
        .accessibilityIdentifier("hf.profile.paymentEntitlementServices")
        .accessibilityIdentifier("hf.profile.paymentEntitlementProof")
        .accessibilityIdentifier("hf.profile.paymentProviderStatus")
        .accessibilityIdentifier("hf.profile.storeProviderStatus")
        .accessibilityIdentifier("hf.profile.entitlementReadiness")
        .accessibilityIdentifier("hf.services.paymentEntitlement")
        .accessibilityIdentifier("hf.services.localEntitlementAdapter")
        .accessibilityIdentifier("hf.services.remotePaymentProviderReady")
        .accessibilityIdentifier("hf.services.storeProviderReady")
        .accessibilityIdentifier("hf.services.entitlementReadiness")
        .accessibilityIdentifier("hf.services.accessTiers")
        .accessibilityIdentifier("hf.services.localToRemotePaymentAdapter")
    }

    private var header: some View {
        HStack(alignment: .top, spacing: HFSpacing.md) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 48, height: 48)
                .background(HFColors.gold.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HFRoomStatusChip(title: "Local Entitlement Adapter", accent: HFColors.gold)
                Text("Payment + Entitlement Services")
                    .font(HFTypography.section)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Access Tiers, Profile Access, Player, Library, Downloads, Export, and Launch boundaries are organized locally while future providers remain disconnected.")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private var readinessRows: some View {
        VStack(spacing: HFSpacing.xs) {
            ForEach(streamingStore.paymentReadinessRows) { row in
                HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
            }
        }
    }

    private var localToRemoteAdapterRows: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HFSectionHeader(title: "Local-to-Remote Payment Adapter", actionTitle: nil)
            ForEach(streamingStore.localToRemotePaymentAdapterRows) { row in
                HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
            }
        }
        .accessibilityIdentifier("hf.payment.localToRemoteAdapter")
        .accessibilityIdentifier("hf.payment.accessTierRecord")
        .accessibilityIdentifier("hf.payment.entitlementRecord")
    }
}

private struct HFRoomBoardExpansionSection: View {
    let expansion: HFRoomBoardExpansion
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "rectangle.3.group.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Local Board", accent: accent)
                            Text(expansion.title)
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(expansion.subtitle)
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: HFSpacing.xs)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            ForEach(expansion.columns) { column in
                                HFRoomBoardColumnCard(column: column, accent: accent)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(HFSpacing.lg)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(expansion.accessibilityLabel)
            .accessibilityIdentifier(expansion.boardIdentifier)

            HFRoomMomentumSummary(
                title: expansion.title == "Delivery Board" ? "Delivery Readiness Board" : expansion.title == "Audience Board" ? "Audience Momentum" : "Viewing Momentum",
                rows: expansion.momentumRows,
                accent: accent,
                identifier: expansion.momentumIdentifier
            )

            Text(expansion.ctaTitle)
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .accessibilityLabel("\(expansion.ctaTitle), safe local preview action")
                .accessibilityIdentifier(expansion.planIdentifier)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct HFRoomBoardColumnCard: View {
    let column: HFRoomBoardColumn
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.26)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                HStack(alignment: .top, spacing: HFSpacing.xs) {
                    Image(systemName: column.systemImage)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 34, height: 34)
                        .background(accent.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(column.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        HFRoomStatusChip(title: column.status, accent: accent)
                    }
                }

                Text(column.subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    ForEach(column.cards) { card in
                        HFRoomBoardMiniCard(card: card, accent: accent)
                    }
                }
            }
            .frame(width: 216, alignment: .topLeading)
            .padding(HFSpacing.sm)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(column.title), \(column.status), \(column.cards.map(\.title).joined(separator: ", "))")
    }
}

private struct HFRoomBoardMiniCard: View {
    let card: HFRoomBoardCard
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.xs) {
            Image(systemName: card.systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 24, height: 24)
                .background(accent.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(card.title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(card.detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                HFRoomStatusChip(title: card.status, accent: accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.xs)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFRoomMomentumSummary: View {
    let title: String
    let rows: [HFRoomSuiteProgressRow]
    let accent: Color
    let identifier: String

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text(title)
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    HFRoomStatusChip(title: "Local", accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(rows) { row in
                        HFRoomSuiteProgressTile(row: row, accent: accent)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title), local momentum summary with protected live systems")
        .accessibilityIdentifier(identifier)
    }
}

private struct HFRoomSuiteProgressTile: View {
    let row: HFRoomSuiteProgressRow
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.xs) {
            Image(systemName: row.systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 30, height: 30)
                .background(accent.opacity(0.13))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(row.title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(row.detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                HFRoomStatusChip(title: row.status, accent: accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.title), \(row.detail), \(row.status)")
    }
}

private struct HFProfilePublicMomentumSummarySection: View {
    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.cyan.opacity(0.34)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.cyan)
                    .frame(width: 48, height: 48)
                    .background(Color.cyan.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomLocalPreviewBadge(title: "Built", accent: Color.cyan)
                    Text("Launch + Connect Momentum")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Connect and Launch now carry audience energy, creator updates, public release calendar, and premiere readiness as local product previews.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch and Connect Momentum, local audience and premiere planning summary")
        .accessibilityIdentifier("hf.profile.publicMomentumSummary")
    }
}

private struct HFProfileWatchExportSummarySection: View {
    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.purple.opacity(0.34)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.purple)
                    .frame(width: 48, height: 48)
                    .background(Color.purple.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomLocalPreviewBadge(title: "Built", accent: Color.purple)
                    Text("Watch + Export Professional Path")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Watch and Export now carry programming, viewing journey, featured slate, professional delivery, festival readiness, and handoff planning as local product previews.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Watch and Export Professional Path, local programming and professional delivery planning summary")
        .accessibilityIdentifier("hf.profile.watchExportSummary")
    }
}

private struct HFWatchProgramBoardSection: View {
    let columns: [HFRoomBoardColumn]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Program Board", accent: accent)
                            Text("Premium Program Board")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Shape what viewers see next across featured premieres, collections, originals, and discovery paths.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            ForEach(columns) { column in
                                HFRoomBoardColumnCard(column: column, accent: accent)
                                    .accessibilityIdentifier(identifier(for: column.title))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(HFSpacing.lg)
            }

            Text("Review Program Board")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .accessibilityLabel("Review Program Board, safe local preview action")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Premium Program Board, local programming plan for featured titles originals collections continue path and discovery bridge")
        .accessibilityIdentifier("hf.room.watch.programBoard")
    }

    private func identifier(for title: String) -> String {
        switch title {
        case "Featured Programming":
            return "hf.room.watch.featuredProgramming"
        case "HighFive Originals":
            return "hf.room.watch.originalsLane"
        case "Collections":
            return "hf.room.watch.collectionLane"
        case "Continue Path":
            return "hf.room.watch.continuePath"
        case "Discovery Bridge":
            return "hf.room.watch.discoveryBridge"
        default:
            return "hf.room.watch.programBoard.column"
        }
    }
}

private struct HFViewingJourneyPlannerSection: View {
    let stages: [HFRoomBoardColumn]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Viewing Journey Planner", subtitle: "Show how a viewer moves from featured title to related titles and saved shelf.")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(stages) { stage in
                        HFRoomBoardColumnCard(column: stage, accent: accent)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }

            Text("Preview Viewing Journey")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityLabel("Preview Viewing Journey, safe local preview action")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Viewing Journey Planner, local premium viewing journey stages")
        .accessibilityIdentifier("hf.room.watch.viewingJourneyPlanner")
    }
}

private struct HFFeaturedSlatePackSection: View {
    let rows: [HFRoomSuiteProgressRow]
    let readinessRows: [HFRoomSuiteProgressRow]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "star.square.on.square.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Featured Slate", accent: accent)
                            Text("Featured Slate Pack")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("A local programming pack for featured titles, originals, collections, and the coming-soon shelf.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        ForEach(rows) { row in
                            HFRoomSuiteProgressTile(row: row, accent: accent)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        ForEach(readinessRows) { row in
                            HFRoomSuiteProgressTile(row: row, accent: accent)
                        }
                    }

                    Text("Review Featured Slate")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .accessibilityLabel("Review Featured Slate, safe local preview action")
                }
                .padding(HFSpacing.lg)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Featured Slate Pack, local featured title originals collections saved shelf and protected player readiness")
        .accessibilityIdentifier("hf.room.watch.featuredSlatePack")
    }
}

private struct HFProfessionalDeliveryBoardSection: View {
    let columns: [HFRoomBoardColumn]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Professional", accent: accent)
                            Text("Professional Delivery Board")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Organize title handoff, festival package, platform checklist, and professional delivery readiness before live delivery systems exist.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            ForEach(columns) { column in
                                HFRoomBoardColumnCard(column: column, accent: accent)
                                    .accessibilityIdentifier(identifier(for: column.title))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(HFSpacing.lg)
            }

            Text("Review Delivery Board")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .accessibilityLabel("Review Delivery Board, safe local preview action")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Professional Delivery Board, local handoff festival platform press and protected delivery planning")
        .accessibilityIdentifier("hf.room.export.professionalDelivery")
    }

    private func identifier(for title: String) -> String {
        switch title {
        case "Handoff Package":
            return "hf.room.export.deliveryBoard"
        case "Festival Materials":
            return "hf.room.export.festivalMaterials"
        case "Platform Checklist":
            return "hf.room.export.platformChecklist"
        case "Press Delivery":
            return "hf.room.export.pressDelivery"
        case "Protected Delivery Systems":
            return "hf.room.export.protectedDeliverySystems"
        default:
            return "hf.room.export.professionalDelivery.column"
        }
    }
}

private struct HFFestivalPlatformReadinessSection: View {
    let rows: [HFRoomSuiteProgressRow]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFRoomMomentumSummary(
                title: "Festival + Platform Readiness Pack",
                rows: rows,
                accent: accent,
                identifier: "hf.room.export.festivalPlatformReadiness"
            )

            Text("This pack organizes professional handoff language for future delivery workflows while delivery systems remain disconnected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            Text("Review Readiness Pack")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityLabel("Review Readiness Pack, safe local preview action")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Festival and Platform Readiness Pack, local festival platform and delivery readiness rows")
    }
}

private struct HFDistributionHandoffPlannerSection: View {
    let stages: [HFRoomBoardColumn]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Distribution Handoff Planner", subtitle: "Preview package review, festival prep, platform prep, and final handoff readiness.")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(stages) { stage in
                        HFRoomBoardColumnCard(column: stage, accent: accent)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }

            Text("Preview Handoff Planner")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityLabel("Preview Handoff Planner, safe local preview action")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Distribution Handoff Planner, local professional handoff planning stages")
        .accessibilityIdentifier("hf.room.export.handoffPlanner")
    }
}

private struct HFPublicMomentumBoardSection: View {
    let columns: [HFRoomBoardColumn]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Local Momentum", accent: accent)
                            Text("Public Momentum Board")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Plan creator updates, audience prompts, and premiere conversation before live community systems are connected.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            ForEach(columns) { column in
                                HFRoomBoardColumnCard(column: column, accent: accent)
                                    .accessibilityIdentifier(identifier(for: column.title))
                            }
                        }
                        .padding(.vertical, 2)
                        .accessibilityIdentifier("hf.room.connect.momentumBoard")
                    }
                }
                .padding(HFSpacing.lg)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Public Momentum Board, local creator updates audience prompts and premiere conversation planning")
            .accessibilityIdentifier("hf.room.connect.publicMomentum")

            Text("Review Momentum Board")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .accessibilityLabel("Review Momentum Board, safe local preview action")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private func identifier(for title: String) -> String {
        switch title {
        case "Creator Updates":
            return "hf.room.connect.creatorUpdates"
        case "Premiere Conversation":
            return "hf.room.connect.premiereConversation"
        case "Community Readiness":
            return "hf.room.connect.communityReadinessBoard"
        default:
            return "hf.room.connect.momentumBoard.column"
        }
    }
}

private struct HFCreatorUpdatePlannerSection: View {
    let stages: [HFRoomBoardColumn]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Creator Update Planner", subtitle: "Prepare safe public update moments around the title.")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: HFSpacing.sm) {
                    ForEach(stages) { stage in
                        HFRoomBoardColumnCard(column: stage, accent: accent)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }

            Text("Preview Creator Update")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityLabel("Preview Creator Update, safe local preview action")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Creator Update Planner, local public update planning stages")
        .accessibilityIdentifier("hf.room.connect.creatorUpdatePlanner")
    }
}

private struct HFPremiereConversationPackSection: View {
    let prompts: [HFRoomBoardCard]
    let readinessRows: [HFRoomSuiteProgressRow]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Prompt Pack", accent: accent)
                            Text("Premiere Conversation Pack")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Tone: Warm, premium, story-first, family-forward.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        ForEach(prompts) { prompt in
                            HFRoomBoardMiniCard(card: prompt, accent: accent)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        ForEach(readinessRows) { row in
                            HFRoomSuiteProgressTile(row: row, accent: accent)
                        }
                    }

                    Text("Review Conversation Pack")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .accessibilityLabel("Review Conversation Pack, safe local preview action")
                }
                .padding(HFSpacing.lg)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Premiere Conversation Pack, local prompt pack with readiness rows")
        .accessibilityIdentifier("hf.room.connect.conversationPack")
    }
}

private struct HFPublicReleaseCalendarSection: View {
    let milestones: [HFRoomCalendarMilestone]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Public Calendar", accent: accent)
                            Text("Public Release Calendar")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Plan the path from announcement to premiere without live campaign systems.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: HFSpacing.sm) {
                        ForEach(milestones) { milestone in
                            HFReleaseMilestoneRow(milestone: milestone, accent: accent)
                        }
                    }
                    .accessibilityIdentifier("hf.room.launch.releaseMilestoneStack")

                    Text("Review Release Calendar")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .accessibilityLabel("Review Release Calendar, safe local preview action")
                }
                .padding(HFSpacing.lg)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Public Release Calendar, local announcement to premiere milestone preview")
        .accessibilityIdentifier("hf.room.launch.publicReleaseCalendar")
    }
}

private struct HFCampaignMomentumBoardSection: View {
    let columns: [HFRoomBoardColumn]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "megaphone.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Momentum Board", accent: accent)
                            Text("Campaign Momentum Board")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Shape campaign identity, materials, audience build, and release readiness as a local Launch Room preview.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: HFSpacing.sm) {
                            ForEach(columns) { column in
                                HFRoomBoardColumnCard(column: column, accent: accent)
                                    .accessibilityIdentifier(column.title == "Release Readiness" ? "hf.room.launch.releaseReadinessBoard" : "hf.room.launch.campaignMomentumBoard.column")
                            }
                        }
                        .padding(.vertical, 2)
                    }

                    Text("Review Campaign Momentum")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(accent)
                        .clipShape(Capsule())
                        .accessibilityLabel("Review Campaign Momentum, safe local preview action")
                }
                .padding(HFSpacing.lg)
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Campaign Momentum Board, local campaign identity materials audience build and release readiness")
        .accessibilityIdentifier("hf.room.launch.campaignMomentumBoard")
    }
}

private struct HFPremiereReadinessPackSection: View {
    let rows: [HFRoomSuiteProgressRow]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFRoomMomentumSummary(title: "Premiere Readiness Pack", rows: rows, accent: accent, identifier: "hf.room.launch.premiereReadinessPack")

            Text("This package can inform the Launch Room and Connect Room while live release systems remain disconnected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, HFSpacing.screenHorizontal)

            Text("Review Premiere Pack")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .padding(.horizontal, HFSpacing.screenHorizontal)
                .accessibilityLabel("Review Premiere Pack, safe local preview action")
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Premiere Readiness Pack, local public framing campaign headline media materials audience prompts and creator update")
    }
}

private struct HFReleaseCalendarExpansionSection: View {
    let milestones: [HFRoomCalendarMilestone]
    let controlRows: [HFRoomSuiteProgressRow]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.38)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(accent)
                            .frame(width: 50, height: 50)
                            .background(accent.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFRoomLocalPreviewBadge(title: "Release Board", accent: accent)
                            Text("Release Calendar")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("A local milestone plan for campaign timing, premiere copy, audience prompts, and readiness review.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(spacing: HFSpacing.sm) {
                        ForEach(milestones) { milestone in
                            HFReleaseMilestoneRow(milestone: milestone, accent: accent)
                        }
                    }
                    .accessibilityIdentifier("hf.room.launch.releaseMilestones")
                }
                .padding(HFSpacing.lg)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Release Calendar, local premiere campaign calendar preview")
            .accessibilityIdentifier("hf.room.launch.releaseCalendar")

            HFRoomMomentumSummary(title: "Launch Control Board", rows: controlRows, accent: accent, identifier: "hf.room.launch.launchControlBoard")

            Text("Review Release Calendar")
                .font(HFTypography.smallAction)
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .padding(.horizontal, HFSpacing.md)
                .padding(.vertical, 11)
                .background(accent)
                .clipShape(Capsule())
                .accessibilityLabel("Review Release Calendar, safe local preview action")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }
}

private struct HFReleaseMilestoneRow: View {
    let milestone: HFRoomCalendarMilestone
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: milestone.systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(accent)
                .frame(width: 38, height: 38)
                .background(accent.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: HFSpacing.xs) {
                    Text(milestone.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                    HFRoomStatusChip(title: milestone.status, accent: accent)
                }
                Text(milestone.dateLabel)
                    .font(HFTypography.caption)
                    .foregroundStyle(accent)
                Text(milestone.detail)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: HFSpacing.xs)
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(milestone.title), \(milestone.dateLabel), \(milestone.status), \(milestone.detail)")
    }
}

private struct WatchRoomView: View {
    @EnvironmentObject private var streamingStore: HFStreamingStore
    @State private var searchMode: HFSearchHubMode = .discover

    private var featuredMovie: Movie {
        streamingStore.featuredMovie
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

                playerReadinessSection
                HFWatchViewingHubSection(hub: HFWatchViewingHubPreviewData.hub, accent: HFColors.gold)
                HFRoomBoardExpansionSection(expansion: HFRoomMegaExpansionData.watchBoard, accent: HFColors.gold)
                HFWatchProgramBoardSection(columns: HFRoomMegaExpansionData.programBoardColumns, accent: HFColors.gold)
                HFViewingJourneyPlannerSection(stages: HFRoomMegaExpansionData.viewingJourneyStages, accent: HFColors.gold)
                HFFeaturedSlatePackSection(rows: HFRoomMegaExpansionData.featuredSlateRows, readinessRows: HFRoomMegaExpansionData.featuredSlateReadinessRows, accent: HFColors.gold)
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

    private var playerReadinessSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Player Service Readiness")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Catalog title and player route are active. Streaming source remains provider-ready only.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.playerReadinessRows, id: \.self) { row in
                        HFConsumerMomentumRow(title: row, detail: "Watch Room player readiness", status: row.contains("Not Connected Yet") || row.contains("Missing") ? "Future" : "Active", systemImage: "checkmark.circle.fill")
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Player Service Readiness, catalog title active, player route active, streaming source not connected yet")
        .accessibilityIdentifier("hf.room.watch.playerReadiness")
        .accessibilityIdentifier("hf.room.watch.streamingSourceStatus")
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
                HFCreatorPitchPackageSection(pitch: HFCreatorPitchPackagePreviewData.pitch, accent: Color.orange)
                HFCreatorMediaKitPreviewSection(kit: HFCreatorMediaKitPreviewData.kit, accent: Color.orange)
                HFCreatorLaunchPrepPreviewSection(prep: HFCreatorLaunchPrepPreviewData.prep, accent: Color.orange)
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

private struct HFCreatorPitchPackageSection: View {
    let pitch: HFCreatorPitchPackage
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFCreatorPitchSection {
        guard pitch.sections.indices.contains(selectedSectionIndex) else {
            return pitch.sections[0]
        }
        return pitch.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFCreatorPitchHeroCard(pitch: pitch, accent: accent)

            HFCreatorPitchSectionSelector(
                sections: pitch.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFCreatorPitchDetailPanel(section: selectedSection, accent: accent)
            HFCreatorPitchReadinessSummary(rows: pitch.readinessRows, accent: accent)
            HFCreatorPitchConnectionCard(accent: accent)
            HFCreatorPitchBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pitch Package, local creator pitch package preview.")
        .accessibilityIdentifier("hf.room.create.pitchPackage")
    }
}

private struct HFCreatorPitchHeroCard: View {
    let pitch: HFCreatorPitchPackage
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Pitch Package", accent: accent)
                        Text("Pitch Package")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Shape story, audience, format, and release angle before media intake, release posting, package production, delivery, or server systems are connected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(pitch.projectTitle)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: pitch.pitchStatus, accent: accent)
                    }

                    Text(pitch.pitchTitle)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(accent)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(pitch.logline)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFCreatorPackageMetric(title: "Genre", value: pitch.genre, accent: accent)
                        HFCreatorPackageMetric(title: "Format", value: pitch.format, accent: accent)
                        HFCreatorPackageMetric(title: "Story", value: "Ready", accent: accent)
                        HFCreatorPackageMetric(title: "Audience", value: "Preview", accent: accent)
                        HFCreatorPackageMetric(title: "Media", value: "Deferred", accent: accent)
                        HFCreatorPackageMetric(title: "Launch", value: "Local", accent: accent)
                    }

                    HFCreatorStudioDetailLine(title: "Audience", detail: pitch.audience, accent: accent)
                    HFCreatorStudioDetailLine(title: "Release angle", detail: pitch.releaseAngle, accent: accent)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pitch Package, local creator pitch package preview. \(pitch.projectTitle), \(pitch.pitchStatus)")
        .accessibilityIdentifier("hf.room.create.pitchHero")
    }
}

private struct HFCreatorPitchSectionSelector: View {
    let sections: [HFCreatorPitchSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Pitch Sections")
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
                            HFCreatorPitchSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) pitch section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pitch Package sections for local creator pitch package preview")
        .accessibilityIdentifier("hf.room.create.pitchSections")
    }
}

private struct HFCreatorPitchSectionCard: View {
    let section: HFCreatorPitchSection
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
                ForEach(Array(section.beats.prefix(3))) { beat in
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(isSelected ? .black : accent)
                            .padding(.top, 2)
                        Text(beat.title)
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
        .accessibilityLabel("\(section.title) pitch section. \(section.status).")
    }
}

private struct HFCreatorPitchDetailPanel: View {
    let section: HFCreatorPitchSection
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
                        HFRoomLocalPreviewBadge(title: "Selected Pitch Area", accent: accent)
                        Text("Selected Pitch Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFCreatorStudioDetailLine(title: "Shapes", detail: section.shapes, accent: accent)
                    HFCreatorStudioDetailLine(title: "Ready", detail: section.readySummary, accent: accent)
                    HFCreatorStudioDetailLine(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFCreatorStudioDetailLine(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.beats) { beat in
                        HFCreatorPitchBeatRow(beat: beat, accent: accent)
                    }
                }

                Text("Preview Pitch Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Pitch Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Pitch Area, \(section.title), \(section.shapes)")
        .accessibilityIdentifier("hf.room.create.pitchDetail")
    }
}

private struct HFCreatorPitchBeatRow: View {
    let beat: HFCreatorPitchBeat
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(beat.title)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(HFColors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HFRoomStatusChip(title: beat.state, accent: accent)
                }
            }

            Text(beat.detail)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(beat.title), \(beat.state), \(beat.detail)")
    }
}

private struct HFCreatorPitchReadinessSummary: View {
    let rows: [HFCreatorPitchReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Pitch Readiness")
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
        .accessibilityLabel("Pitch Readiness.")
        .accessibilityIdentifier("hf.room.create.pitchReadiness")
    }
}

private struct HFCreatorPitchConnectionCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Local Bridge", accent: accent)
                    Text("Package Connection")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("The pitch package feeds the local project slate, media kit, and launch preparation surfaces while live creator systems remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Package Connection")
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
        .accessibilityLabel("Package Connection.")
        .accessibilityIdentifier("hf.room.create.pitchConnection")
    }
}

private struct HFCreatorPitchBoundaryCard: View {
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
                    Text("Pitch Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local pitch-package preview. Media intake, library access, document handling, identity services, server release systems, package production, delivery systems, commerce, and platform services remain disconnected.")
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
        .accessibilityLabel("Pitch Safety Boundary, live systems remain disconnected.")
        .accessibilityIdentifier("hf.room.create.pitchBoundary")
    }
}

private struct HFCreatorMediaKitPreviewSection: View {
    let kit: HFCreatorMediaKit
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFCreatorMediaKitSection {
        guard kit.sections.indices.contains(selectedSectionIndex) else {
            return kit.sections[0]
        }
        return kit.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFCreatorMediaKitHeroCard(kit: kit, accent: accent)

            HFCreatorMediaKitSectionSelector(
                sections: kit.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFCreatorMediaKitDetailPanel(section: selectedSection, accent: accent)
            HFCreatorMediaKitReadinessSummary(rows: kit.readinessRows, accent: accent)
            HFCreatorMediaKitConnectionCard(accent: accent)
            HFCreatorMediaKitBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Media Kit, local creator media kit preview.")
        .accessibilityIdentifier("hf.room.create.mediaKit")
    }
}

private struct HFCreatorMediaKitHeroCard: View {
    let kit: HFCreatorMediaKit
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Media Kit", accent: accent)
                        Text("Media Kit")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Prepare public-facing title materials before media intake, document handling, release posting, package production, delivery, or server systems are connected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(kit.projectTitle)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: kit.kitStatus, accent: accent)
                    }

                    Text(kit.kitTitle)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(accent)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(kit.publicBlurb)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFCreatorPackageMetric(title: "Poster Direction", value: "Draft", accent: accent)
                        HFCreatorPackageMetric(title: "Still Frames", value: "Preview", accent: accent)
                        HFCreatorPackageMetric(title: "Press Copy", value: "Ready", accent: accent)
                        HFCreatorPackageMetric(title: "Credits", value: "Draft", accent: accent)
                        HFCreatorPackageMetric(title: "Delivery Systems", value: "Protected", accent: accent)
                    }

                    HFCreatorStudioDetailLine(title: "Visual direction", detail: kit.visualDirection, accent: accent)
                    HFCreatorStudioDetailLine(title: "Creator bio", detail: kit.creatorBio, accent: accent)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Media Kit, local creator media kit preview. \(kit.projectTitle), \(kit.kitStatus)")
        .accessibilityIdentifier("hf.room.create.mediaKitHero")
    }
}

private struct HFCreatorMediaKitSectionSelector: View {
    let sections: [HFCreatorMediaKitSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Media Kit Sections")
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
                            HFCreatorMediaKitSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) media kit section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Media Kit sections for local creator media kit preview")
        .accessibilityIdentifier("hf.room.create.mediaKitSections")
    }
}

private struct HFCreatorMediaKitSectionCard: View {
    let section: HFCreatorMediaKitSection
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
        .accessibilityLabel("\(section.title) media kit section. \(section.status).")
    }
}

private struct HFCreatorMediaKitDetailPanel: View {
    let section: HFCreatorMediaKitSection
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
                        HFRoomLocalPreviewBadge(title: "Selected Media Kit Area", accent: accent)
                        Text("Selected Media Kit Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFCreatorStudioDetailLine(title: "Prepares", detail: section.prepares, accent: accent)
                    HFCreatorStudioDetailLine(title: "Ready", detail: section.readySummary, accent: accent)
                    HFCreatorStudioDetailLine(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFCreatorStudioDetailLine(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.items) { item in
                        HFCreatorMediaKitItemRow(item: item, accent: accent)
                    }
                }

                Text("Preview Media Kit Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Media Kit Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Media Kit Area, \(section.title), \(section.prepares)")
        .accessibilityIdentifier("hf.room.create.mediaKitDetail")
    }
}

private struct HFCreatorMediaKitItemRow: View {
    let item: HFCreatorMediaKitItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "sparkle.magnifyingglass")
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

private struct HFCreatorMediaKitReadinessSummary: View {
    let rows: [HFCreatorMediaKitReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Media Kit Readiness")
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
        .accessibilityLabel("Media Kit Readiness.")
        .accessibilityIdentifier("hf.room.create.mediaKitReadiness")
    }
}

private struct HFCreatorMediaKitConnectionCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Local Bridge", accent: accent)
                    Text("Launch + Export Connection")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("The media kit prepares public copy, title materials, and handoff notes for future Launch and Export rooms while live delivery systems remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Media Kit Connection")
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
        .accessibilityLabel("Launch and Export Connection.")
        .accessibilityIdentifier("hf.room.create.mediaKitConnection")
    }
}

private struct HFCreatorMediaKitBoundaryCard: View {
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
                    Text("Media Kit Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local media-kit preview. Media intake, image library access, document handling, identity services, release posting, package production, delivery systems, commerce, and platform services remain disconnected.")
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
        .accessibilityLabel("Media Kit Safety Boundary, live systems remain disconnected.")
        .accessibilityIdentifier("hf.room.create.mediaKitBoundary")
    }
}

private struct HFCreatorLaunchPrepPreviewSection: View {
    let prep: HFCreatorLaunchPrep
    let accent: Color
    @State private var selectedSectionIndex = 0

    private var selectedSection: HFCreatorLaunchPrepSection {
        guard prep.sections.indices.contains(selectedSectionIndex) else {
            return prep.sections[0]
        }
        return prep.sections[selectedSectionIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFCreatorLaunchPrepHeroCard(prep: prep, accent: accent)

            HFCreatorLaunchPrepSectionSelector(
                sections: prep.sections,
                selectedSectionIndex: $selectedSectionIndex,
                accent: accent
            )

            HFCreatorLaunchPrepDetailPanel(section: selectedSection, accent: accent)
            HFCreatorLaunchPrepReadinessSummary(rows: prep.readinessRows, accent: accent)
            HFCreatorLaunchRoomConnectionCard(accent: accent)
            HFCreatorLaunchPrepBoundaryCard(accent: accent)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Prep, local creator launch preparation preview.")
        .accessibilityIdentifier("hf.room.create.launchPrep")
    }
}

private struct HFCreatorLaunchPrepHeroCard: View {
    let prep: HFCreatorLaunchPrep
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(accent)
                        .frame(width: 52, height: 52)
                        .background(accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomLocalPreviewBadge(title: "Launch Prep", accent: accent)
                        Text("Launch Prep")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Prepare release direction before release services, audience reminders, commerce, measurement, or server systems are connected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.xs)
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(prep.projectTitle)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        HFRoomStatusChip(title: prep.prepStatus, accent: accent)
                    }

                    Text(prep.prepTitle)
                        .font(HFTypography.smallAction)
                        .foregroundStyle(accent)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(prep.positioning)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                        HFCreatorPackageMetric(title: "Positioning", value: "Ready", accent: accent)
                        HFCreatorPackageMetric(title: "Campaign Direction", value: "Preview", accent: accent)
                        HFCreatorPackageMetric(title: "Materials", value: "Draft", accent: accent)
                        HFCreatorPackageMetric(title: "Audience Warmup", value: "Local", accent: accent)
                        HFCreatorPackageMetric(title: "Live Launch Systems", value: "Protected", accent: accent)
                    }

                    HFCreatorStudioDetailLine(title: "Release window", detail: prep.releaseWindow, accent: accent)
                    HFCreatorStudioDetailLine(title: "Audience warmup", detail: prep.audienceWarmup, accent: accent)
                }
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch Prep, local creator launch preparation preview. \(prep.projectTitle), \(prep.prepStatus)")
        .accessibilityIdentifier("hf.room.create.launchPrepHero")
    }
}

private struct HFCreatorLaunchPrepSectionSelector: View {
    let sections: [HFCreatorLaunchPrepSection]
    @Binding var selectedSectionIndex: Int
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            HStack {
                Text("Launch Prep Sections")
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
                            HFCreatorLaunchPrepSectionCard(
                                section: section,
                                isSelected: selectedSectionIndex == index,
                                accent: accent
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(section.title) launch prep section.")
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Prep sections for local creator launch preparation preview")
        .accessibilityIdentifier("hf.room.create.launchPrepSections")
    }
}

private struct HFCreatorLaunchPrepSectionCard: View {
    let section: HFCreatorLaunchPrepSection
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
        .accessibilityLabel("\(section.title) launch prep section. \(section.status).")
    }
}

private struct HFCreatorLaunchPrepDetailPanel: View {
    let section: HFCreatorLaunchPrepSection
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
                        HFRoomLocalPreviewBadge(title: "Selected Launch Prep Area", accent: accent)
                        Text("Selected Launch Prep Area")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text(section.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(accent)
                    }
                }

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    HFCreatorStudioDetailLine(title: "Prepares", detail: section.prepares, accent: accent)
                    HFCreatorStudioDetailLine(title: "Ready", detail: section.readySummary, accent: accent)
                    HFCreatorStudioDetailLine(title: "Preview-only", detail: section.previewSummary, accent: accent)
                    HFCreatorStudioDetailLine(title: "Deferred", detail: section.deferredSummary, accent: accent)
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 154), spacing: HFSpacing.sm)], alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(section.items) { item in
                        HFCreatorLaunchPrepItemRow(item: item, accent: accent)
                    }
                }

                Text("Preview Launch Prep Area")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, HFSpacing.md)
                    .padding(.vertical, 11)
                    .background(accent)
                    .clipShape(Capsule())
                    .accessibilityLabel("Preview Launch Prep Area, safe local preview action")
            }
            .padding(HFSpacing.lg)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Selected Launch Prep Area, \(section.title), \(section.prepares)")
        .accessibilityIdentifier("hf.room.create.launchPrepDetail")
    }
}

private struct HFCreatorLaunchPrepItemRow: View {
    let item: HFCreatorLaunchPrepItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            HStack(alignment: .top, spacing: HFSpacing.xs) {
                Image(systemName: "flag.fill")
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

private struct HFCreatorLaunchPrepReadinessSummary: View {
    let rows: [HFCreatorLaunchPrepReadinessRow]
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack {
                    Text("Launch Prep Readiness")
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
        .accessibilityLabel("Launch Prep Readiness.")
        .accessibilityIdentifier("hf.room.create.launchPrepReadiness")
    }
}

private struct HFCreatorLaunchRoomConnectionCard: View {
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.32)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "arrow.up.right.square.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 48, height: 48)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HFRoomStatusChip(title: "Local Bridge", accent: accent)
                    Text("Launch Room Connection")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("Creator launch prep shapes campaign direction for the Launch Room while live release services remain disconnected.")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Review Launch Room Connection")
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
        .accessibilityLabel("Launch Room Connection.")
        .accessibilityIdentifier("hf.room.create.launchRoomConnection")
    }
}

private struct HFCreatorLaunchPrepBoundaryCard: View {
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
                    Text("Launch Prep Safety Boundary")
                        .font(HFTypography.section)
                        .foregroundStyle(HFColors.textPrimary)
                    Text("This is a local launch-prep preview. Release posting, audience reminders, commerce, audience lists, measurement, server systems, and campaign execution remain disconnected.")
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
        .accessibilityLabel("Launch Prep Safety Boundary, live systems remain disconnected.")
        .accessibilityIdentifier("hf.room.create.launchPrepBoundary")
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
    @EnvironmentObject private var streamingStore: HFStreamingStore

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

                localAudienceUpdatesSection
                communicationServiceSection
                audienceChannelsSection
                localToRemoteAdapterSection
                launchCampaignBridgeSection
                exportDeliveryPackageContextSection
                moderationReadinessSection
                HFConnectAudiencePlannerSection(plan: HFConnectAudiencePlannerPreviewData.plan, accent: Color.cyan)
                HFRoomBoardExpansionSection(expansion: HFRoomMegaExpansionData.audienceBoard, accent: Color.cyan)
                HFPublicMomentumBoardSection(columns: HFRoomMegaExpansionData.publicMomentumColumns, accent: Color.cyan)
                HFCreatorUpdatePlannerSection(stages: HFRoomMegaExpansionData.creatorUpdatePlannerStages, accent: Color.cyan)
                HFPremiereConversationPackSection(
                    prompts: HFRoomMegaExpansionData.conversationPrompts,
                    readinessRows: HFRoomMegaExpansionData.conversationReadinessRows,
                    accent: Color.cyan
                )
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

    private var localAudienceUpdatesSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.cyan.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.cyan)
                        .frame(width: 48, height: 48)
                        .background(Color.cyan.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Draft", accent: Color.cyan)
                        Text("Local Audience Updates")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Prepare creator updates and audience conversation locally before communication services exist.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HFConsumerMomentumRow(title: "Connected Local Updates", detail: "Audience updates are stored locally for preview.", status: "Connected", systemImage: "point.3.connected.trianglepath.dotted")
                    .accessibilityIdentifier("hf.functional.connect.connectedState")

                HFConsumerMomentumRow(title: "Updates prepared by \(streamingStore.activeViewingProfile.displayName)", detail: "Local profile identity stays attached to this draft board.", status: "Local", systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                    .accessibilityIdentifier("hf.account.connect.profileState")

                HFConsumerMomentumRow(title: "Catalog title context", detail: "Local updates are prepared around \(streamingStore.featuredMovie.title).", status: "Catalog", systemImage: "rectangle.stack.fill")
                    .accessibilityIdentifier("hf.catalog.connect.titleContext")

                TextField("Write a local update", text: localUpdateDraft, axis: .vertical)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2...4)
                    .padding(HFSpacing.md)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                            .stroke(HFColors.glassStroke, lineWidth: 1)
                    )
                    .accessibilityIdentifier("hf.functional.connect.updateInput")
                    .accessibilityIdentifier("hf.communication.updateInput")

                Button {
                    addLocalUpdate()
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Local Update")
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.cyan)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.functional.connect.addLocalUpdate")
                .accessibilityIdentifier("hf.communication.addLocalUpdate")
                .accessibilityLabel("Add Local Update")

                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    ForEach(Array(streamingStore.localAudienceUpdates.enumerated()), id: \.element.id) { index, update in
                        HFLocalUpdateRow(index: index + 1, update: update, accent: Color.cyan)
                    }
                }
                .accessibilityIdentifier("hf.functional.connect.updateList")
                .accessibilityIdentifier("hf.communication.localUpdateList")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Local Audience Updates, draft preview list, not sent")
        .accessibilityIdentifier("hf.functional.connect.localUpdates")
    }

    private var communicationServiceSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.cyan.opacity(0.36)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.cyan)
                        .frame(width: 48, height: 48)
                        .background(Color.cyan.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Communication Adapter", accent: Color.cyan)
                        Text("Communication Service")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local Audience Updates are structured for a future Remote Communication Provider.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.communicationReadinessRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Communication Service, Local Communication Adapter active, Remote Communication Provider Not Connected Yet")
        .accessibilityIdentifier("hf.connect.communicationService")
        .accessibilityIdentifier("hf.services.communication")
        .accessibilityIdentifier("hf.services.localCommunicationAdapter")
        .accessibilityIdentifier("hf.services.remoteCommunicationProviderReady")
        .accessibilityIdentifier("hf.services.communicationReadiness")
    }

    private var audienceChannelsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Audience Channels", subtitle: "Local channel records for preparing audience-facing updates.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: HFSpacing.sm)], spacing: HFSpacing.sm) {
                ForEach(streamingStore.audienceChannels) { channel in
                    HFCommunicationChannelCard(channel: channel, accent: Color.cyan)
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Audience Channels, Premiere Updates, Creator Notes, Audience Prompts, Release Reminders")
        .accessibilityIdentifier("hf.connect.audienceChannels")
        .accessibilityIdentifier("hf.services.audienceChannels")
    }

    private var localToRemoteAdapterSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.cyan.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.cyan)
                        .frame(width: 48, height: 48)
                        .background(Color.cyan.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Local-to-Remote Adapter")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Updates are prepared locally today and structured for a future remote communication provider.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.localToRemoteAdapterRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Local-to-Remote Adapter, local update schema ready, Remote Communication Provider Not Connected Yet")
        .accessibilityIdentifier("hf.connect.localToRemoteAdapter")
        .accessibilityIdentifier("hf.services.localToRemoteCommunicationAdapter")
    }

    private var launchCampaignBridgeSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.cyan.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.cyan)
                        .frame(width: 48, height: 48)
                        .background(Color.cyan.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Launch Campaign Bridge")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local audience updates can support future campaign packages while providers remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.launchCommunicationBridgeRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Launch Campaign Bridge, local audience updates support future campaign packages while providers remain disconnected")
        .accessibilityIdentifier("hf.connect.launchCampaignBridge")
    }

    private var exportDeliveryPackageContextSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.cyan.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.cyan)
                        .frame(width: 48, height: 48)
                        .background(Color.cyan.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Export Delivery Context")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local audience updates can support delivery notes while remote providers remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.exportCommunicationPackageRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Export Delivery Context, local audience updates can support delivery notes while remote providers remain disconnected")
        .accessibilityIdentifier("hf.connect.exportDeliveryPackageContext")
    }

    private var moderationReadinessSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: Color.cyan.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Color.cyan)
                        .frame(width: 48, height: 48)
                        .background(Color.cyan.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Moderation Readiness")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local review and safety checks are present while remote moderation remains disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.communicationModerationRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Moderation Readiness, local review active, remote moderation provider Not Connected Yet")
        .accessibilityIdentifier("hf.communication.moderationReadiness")
        .accessibilityIdentifier("hf.services.communicationModeration")
    }

    private func addLocalUpdate() {
        streamingStore.addLocalConnectUpdate(streamingStore.localConnectUpdateDraft)
    }

    private var localUpdateDraft: Binding<String> {
        Binding(
            get: { streamingStore.localConnectUpdateDraft },
            set: { streamingStore.localConnectUpdateDraft = $0 }
        )
    }
}

private struct HFLocalUpdateRow: View {
    let index: Int
    let update: HFAudienceUpdateRecord
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Text("\(index)")
                .font(HFTypography.caption)
                .foregroundStyle(.black)
                .frame(width: 28, height: 28)
                .background(accent)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(update.body)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(update.safetyLabel) • \(update.updatedAtLabel)")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                HFRoomStatusChip(title: update.status, accent: accent)
                    .accessibilityIdentifier("hf.communication.updateStatus")
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Local audience update by local profile for catalog title, \(update.status)")
        .accessibilityIdentifier("hf.communication.updateAuthorProfile")
        .accessibilityIdentifier("hf.communication.updateCatalogTitle")
    }
}

private struct HFCommunicationChannelCard: View {
    let channel: HFAudienceChannel
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: channel.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(channel.title)
                    .font(HFTypography.smallAction)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(channel.purpose)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HFRoomStatusChip(title: channel.status, accent: accent)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(channel.title), \(channel.status), \(channel.purpose)")
        .accessibilityIdentifier("hf.connect.audienceChannel")
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
    @EnvironmentObject private var streamingStore: HFStreamingStore
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

                localReleaseChecklistSection
                launchCampaignServiceSection
                releaseCalendarServiceSection
                campaignMilestonesServiceSection
                localToRemoteLaunchAdapterSection
                campaignReadinessServiceSection
                exportDeliveryHandoffSection
                paymentEntitlementBoundarySection
                HFLaunchCampaignPlannerSection(campaign: HFLaunchCampaignPlannerPreviewData.campaign, accent: accent)
                HFReleaseCalendarExpansionSection(
                    milestones: HFRoomMegaExpansionData.releaseMilestones,
                    controlRows: HFRoomMegaExpansionData.launchControlRows,
                    accent: accent
                )
                HFPublicReleaseCalendarSection(milestones: HFRoomMegaExpansionData.publicReleaseMilestones, accent: accent)
                HFCampaignMomentumBoardSection(columns: HFRoomMegaExpansionData.campaignMomentumColumns, accent: accent)
                HFPremiereReadinessPackSection(rows: HFRoomMegaExpansionData.premiereReadinessRows, accent: accent)
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

    private var launchChecklistProgress: Int {
        streamingStore.launchChecklistProgress
    }

    private var localReleaseChecklistSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "checklist.checked")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Progress", accent: accent)
                        Text("Local Release Checklist")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Toggle launch prep items locally and review the current release progress.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: HFSpacing.sm) {
                    Text("\(launchChecklistProgress)/\(streamingStore.launchChecklistItems.count)")
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(HFColors.textPrimary)
                    Text("reviewed")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)
                    Spacer()
                    HFRoomStatusChip(title: launchChecklistProgress == streamingStore.launchChecklistItems.count ? "Ready" : "In Review", accent: accent)
                }
                .accessibilityIdentifier("hf.functional.launch.checklistProgress")

                HFConsumerMomentumRow(title: "Connected Launch Progress", detail: "Checklist progress updates locally.", status: "Connected", systemImage: "point.3.connected.trianglepath.dotted")
                    .accessibilityIdentifier("hf.functional.launch.connectedState")

                HFConsumerMomentumRow(title: "Release checklist for \(streamingStore.activeViewingProfile.displayName)", detail: "Local profile identity stays attached to launch prep.", status: "Local", systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                    .accessibilityIdentifier("hf.account.launch.profileState")

                HFConsumerMomentumRow(title: "Catalog title context", detail: "Launch progress is framed around \(streamingStore.featuredMovie.title).", status: "Catalog", systemImage: "rectangle.stack.fill")
                    .accessibilityIdentifier("hf.catalog.launch.titleContext")

                HFConsumerMomentumRow(title: "Communication Adapter Context", detail: "Release updates are structured locally for future communication service delivery.", status: "Local", systemImage: "text.bubble.fill")
                    .accessibilityIdentifier("hf.launch.communicationAdapterContext")

                HFConsumerMomentumRow(title: "Campaign status", detail: streamingStore.launchCampaignRecord.status, status: "Local", systemImage: "flag.checkered")
                    .accessibilityIdentifier("hf.launch.campaignStatus")
                    .accessibilityIdentifier("hf.launch.campaignLocalReview")
                    .accessibilityIdentifier("hf.launch.campaignNotPublished")

                VStack(spacing: HFSpacing.sm) {
                    ForEach(streamingStore.launchChecklistItems.indices, id: \.self) { index in
                        Toggle(isOn: Binding(
                            get: { streamingStore.launchChecklistStates[index] },
                            set: { streamingStore.toggleLaunchChecklistItem(index, isComplete: $0) }
                        )) {
                            Text(streamingStore.launchChecklistItems[index])
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .toggleStyle(.switch)
                        .tint(accent)
                        .padding(HFSpacing.sm)
                        .background(Color.white.opacity(0.055))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                        .accessibilityIdentifier("hf.functional.launch.checklistToggle")
                    }
                }

                Button {
                    selectedLaunchSection = .releaseReadiness
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Review Launch Progress")
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(accent)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.functional.launch.reviewProgress")
                .accessibilityLabel("Review Launch Progress")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Local Release Checklist, \(launchChecklistProgress) of \(streamingStore.launchChecklistItems.count) reviewed")
        .accessibilityIdentifier("hf.functional.launch.localChecklist")
    }

    private var launchCampaignServiceSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Launch Campaign Adapter", accent: accent)
                        Text("Launch Campaign Service")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Campaign plans stay local today and are structured for a future Remote Campaign Provider.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HFConsumerMomentumRow(title: streamingStore.launchCampaignRecord.title, detail: streamingStore.campaignPackageSummary, status: streamingStore.launchCampaignRecord.status, systemImage: "flag.checkered")
                    .accessibilityIdentifier("hf.launch.campaignRecord")
                HFConsumerMomentumRow(title: "Campaign profile", detail: streamingStore.activeViewingProfile.displayName, status: "Local", systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                    .accessibilityIdentifier("hf.launch.campaignProfile")
                HFConsumerMomentumRow(title: "Campaign catalog title", detail: streamingStore.featuredMovie.title, status: "Catalog", systemImage: "rectangle.stack.fill")
                    .accessibilityIdentifier("hf.launch.campaignCatalogTitle")

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.launchCampaignProofRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Campaign Service, Local Launch Campaign Adapter active, Remote Campaign Provider Not Connected Yet")
        .accessibilityIdentifier("hf.launch.campaignService")
        .accessibilityIdentifier("hf.services.launchCampaign")
        .accessibilityIdentifier("hf.services.localLaunchCampaignAdapter")
        .accessibilityIdentifier("hf.services.remoteCampaignProviderReady")
    }

    private var releaseCalendarServiceSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Release Calendar", subtitle: "Provider-ready local calendar records for the featured title.")

            VStack(spacing: HFSpacing.sm) {
                ForEach(streamingStore.releaseCalendarRows) { row in
                    HFLaunchServiceRecordRow(row: row, accent: accent)
                        .accessibilityIdentifier("hf.launch.releaseCalendarItem")
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Release Calendar, local release calendar records")
        .accessibilityIdentifier("hf.launch.releaseCalendar")
        .accessibilityIdentifier("hf.services.releaseCalendar")
    }

    private var campaignMilestonesServiceSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Launch Milestones", subtitle: "Structured local campaign milestones keep the checklist connected.")

            VStack(spacing: HFSpacing.sm) {
                ForEach(streamingStore.launchMilestoneRecords) { row in
                    HFLaunchServiceRecordRow(row: row, accent: accent)
                        .accessibilityIdentifier("hf.launch.campaignMilestone")
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Launch Milestones, campaign headline, premiere copy, audience prompt, media kit, and release calendar")
        .accessibilityIdentifier("hf.launch.campaignMilestones")
        .accessibilityIdentifier("hf.services.launchMilestones")
    }

    private var localToRemoteLaunchAdapterSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Local-to-Remote Launch Adapter")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Campaign plans are structured locally today and ready for a future remote campaign provider.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.localToRemoteLaunchAdapterRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Local-to-Remote Launch Adapter, local campaign schema ready, Remote Campaign Provider Not Connected Yet")
        .accessibilityIdentifier("hf.launch.localToRemoteAdapter")
        .accessibilityIdentifier("hf.services.localToRemoteLaunchAdapter")
    }

    private var campaignReadinessServiceSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Campaign Readiness")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local review connects communication and export handoff while remote campaign services remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.launchCampaignReadinessRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Campaign Readiness, local review active, Remote Campaign Provider Not Connected Yet")
        .accessibilityIdentifier("hf.launch.campaignReadiness")
        .accessibilityIdentifier("hf.services.launchCampaignReadiness")
        .accessibilityIdentifier("hf.services.launchCommunicationBridge")
        .accessibilityIdentifier("hf.services.launchExportHandoff")
    }

    private var exportDeliveryHandoffSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Export Delivery Handoff")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Launch campaign plans can support future delivery handoff packages while providers remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.exportLaunchHandoffRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Export Delivery Handoff, launch campaign plans can support future delivery handoff packages while providers remain disconnected")
        .accessibilityIdentifier("hf.launch.exportDeliveryHandoff")
    }

    private var paymentEntitlementBoundarySection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                StudioRoomSectionHeader(title: "Campaign Access Boundary", subtitle: "Launch campaign packages remain local. Payment and entitlement providers are not connected yet.")
                ForEach(streamingStore.launchEntitlementRows) { row in
                    HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Campaign Access Boundary, Launch campaign packages remain local, payment and entitlement providers are not connected yet")
        .accessibilityIdentifier("hf.launch.paymentEntitlementBoundary")
        .accessibilityIdentifier("hf.services.launchEntitlementBoundary")
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

private struct HFLaunchServiceRecordRow: View {
    let row: HFLaunchMilestoneRecord
    let accent: Color

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: accent.opacity(0.28)) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: row.systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.13))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(row.title)
                            .font(HFTypography.smallAction)
                            .foregroundStyle(HFColors.textPrimary)
                        HFRoomStatusChip(title: row.status, accent: accent)
                    }
                    Text(row.detail)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: HFSpacing.xs)
            }
            .padding(HFSpacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.title), \(row.status), \(row.detail)")
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
    @EnvironmentObject private var streamingStore: HFStreamingStore
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

                exportDeliveryServiceSection
                deliverySummarySection
                deliveryPackageSection
                deliveryRequirementsSection
                distributionHandoffSection
                localToRemoteExportAdapterSection
                exportReadinessSection
                paymentEntitlementBoundarySection
                HFExportDistributionPackageSection(package: HFExportDistributionPackagePreviewData.package, accent: accent)
                HFRoomBoardExpansionSection(expansion: HFRoomMegaExpansionData.deliveryBoard, accent: accent)
                HFProfessionalDeliveryBoardSection(columns: HFRoomMegaExpansionData.professionalDeliveryColumns, accent: accent)
                HFFestivalPlatformReadinessSection(rows: HFRoomMegaExpansionData.festivalPlatformReadinessRows, accent: accent)
                HFDistributionHandoffPlannerSection(stages: HFRoomMegaExpansionData.handoffPlannerStages, accent: accent)
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

    private var deliverySummarySection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.42)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Text Summary", accent: accent)
                        Text("Generate Delivery Summary")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Create a local text handoff summary from the current title and readiness package.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button {
                    streamingStore.generateDeliverySummary(for: streamingStore.featuredMovie)
                } label: {
                    HStack(spacing: HFSpacing.xs) {
                        Image(systemName: "wand.and.stars")
                        Text("Generate Summary")
                    }
                    .font(HFTypography.smallAction)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(accent)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.functional.export.generateSummary")
                .accessibilityIdentifier("hf.export.generateDeliverySummary")
                .accessibilityLabel("Generate Summary")

                HFConsumerMomentumRow(title: "Connected Delivery Summary", detail: "Package summary is generated from local app state.", status: "Connected", systemImage: "point.3.connected.trianglepath.dotted")
                    .accessibilityIdentifier("hf.functional.export.connectedState")

                HFConsumerMomentumRow(title: "Delivery summary prepared by \(streamingStore.activeViewingProfile.displayName)", detail: "Local profile identity stays attached to the text summary.", status: "Local", systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                    .accessibilityIdentifier("hf.account.export.profileState")

                HFConsumerMomentumRow(title: "Catalog title context", detail: "Delivery summary uses \(streamingStore.featuredMovie.title) from the shared catalog.", status: "Catalog", systemImage: "rectangle.stack.fill")
                    .accessibilityIdentifier("hf.catalog.export.titleContext")

                HFConsumerMomentumRow(title: "Communication Adapter Context", detail: "Delivery summaries can support future communication packages while remote providers remain disconnected.", status: "Local", systemImage: "text.bubble.fill")
                    .accessibilityIdentifier("hf.export.communicationAdapterContext")

                HFConsumerMomentumRow(title: "Launch Campaign Handoff", detail: "Delivery summaries can support launch handoff packages while campaign providers remain disconnected.", status: "Local", systemImage: "flag.checkered")
                    .accessibilityIdentifier("hf.export.launchCampaignHandoff")

                HFConsumerMomentumRow(title: "Delivery Summary Status", detail: streamingStore.deliveryPackageRecord.status, status: "Local", systemImage: "doc.text.fill")
                    .accessibilityIdentifier("hf.export.deliverySummaryStatus")
                    .accessibilityIdentifier("hf.export.deliverySummaryLocalOnly")
                    .accessibilityIdentifier("hf.export.deliveryNotSubmitted")

                if !streamingStore.generatedDeliverySummary.isEmpty {
                    Text(streamingStore.generatedDeliverySummary)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(HFSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                                .stroke(HFColors.glassStroke, lineWidth: 1)
                        )
                        .accessibilityIdentifier("hf.functional.export.summaryText")
                        .accessibilityIdentifier("hf.export.deliverySummaryText")

                    ShareLink(item: streamingStore.generatedDeliverySummary) {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Summary")
                        }
                        .font(HFTypography.smallAction)
                        .foregroundStyle(accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(accent.opacity(0.34), lineWidth: 1))
                    }
                    .accessibilityIdentifier("hf.functional.export.shareSummary")
                    .accessibilityLabel("Share Summary")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Generate Delivery Summary, local text package summary")
        .accessibilityIdentifier("hf.functional.export.deliverySummary")
    }

    private var paymentEntitlementBoundarySection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                StudioRoomSectionHeader(title: "Delivery Access Boundary", subtitle: "Delivery packages remain local. Payment and entitlement providers are not connected yet.")
                ForEach(streamingStore.exportEntitlementRows) { row in
                    HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Delivery Access Boundary, Delivery packages remain local, payment and entitlement providers are not connected yet")
        .accessibilityIdentifier("hf.export.paymentEntitlementBoundary")
        .accessibilityIdentifier("hf.services.exportEntitlementBoundary")
    }

    private var exportDeliveryServiceSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.40)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HFRoomStatusChip(title: "Local Export Delivery Adapter", accent: accent)
                        Text("Export Delivery Service")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Delivery packages stay local today and are structured for a future Remote Delivery Provider.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    HFConsumerMomentumRow(title: "Local Export Delivery Adapter", detail: "Active", status: "Active", systemImage: "point.3.connected.trianglepath.dotted")
                    HFConsumerMomentumRow(title: "Delivery Package", detail: "Local", status: "Local", systemImage: "doc.text.fill")
                    HFConsumerMomentumRow(title: "Delivery Requirements", detail: "Local", status: "Local", systemImage: "checklist.checked")
                    HFConsumerMomentumRow(title: "Distribution Handoff", detail: "Local", status: "Local", systemImage: "arrow.triangle.2.circlepath")
                    HFConsumerMomentumRow(title: "Launch Campaign Handoff", detail: "Local", status: "Local", systemImage: "flag.checkered")
                    HFConsumerMomentumRow(title: "Communication Package", detail: "Local", status: "Local", systemImage: "text.bubble.fill")
                    HFConsumerMomentumRow(title: "Remote Delivery Provider", detail: "Not Connected Yet", status: "Future", systemImage: "network.slash")
                    HFConsumerMomentumRow(title: "Platform Submission", detail: "Not Connected Yet", status: "Future", systemImage: "paperplane")
                    HFConsumerMomentumRow(title: "Media Render / File Export", detail: "Not Connected Yet", status: "Future", systemImage: "video.slash.fill")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Export Delivery Service, Local Export Delivery Adapter active, Remote Delivery Provider Not Connected Yet")
        .accessibilityIdentifier("hf.export.deliveryService")
        .accessibilityIdentifier("hf.services.exportDelivery")
        .accessibilityIdentifier("hf.services.localExportDeliveryAdapter")
        .accessibilityIdentifier("hf.services.remoteDeliveryProviderReady")
    }

    private var deliveryPackageSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                StudioRoomSectionHeader(title: "Delivery Package", subtitle: "Structured local package record for the featured title.")
                HFConsumerMomentumRow(title: streamingStore.deliveryPackageRecord.title, detail: streamingStore.deliveryPackageRecord.summary, status: streamingStore.deliveryPackageRecord.status, systemImage: "doc.text.fill")
                    .accessibilityIdentifier("hf.export.deliveryPackageStatus")
                HFConsumerMomentumRow(title: "Delivery package profile", detail: streamingStore.activeViewingProfile.displayName, status: "Local", systemImage: streamingStore.activeViewingProfile.avatarSymbol)
                    .accessibilityIdentifier("hf.export.deliveryPackageProfile")
                HFConsumerMomentumRow(title: "Delivery package catalog title", detail: streamingStore.featuredMovie.title, status: "Catalog", systemImage: "rectangle.stack.fill")
                    .accessibilityIdentifier("hf.export.deliveryPackageCatalogTitle")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Delivery Package, local delivery package record")
        .accessibilityIdentifier("hf.export.deliveryPackage")
        .accessibilityIdentifier("hf.services.deliveryPackage")
    }

    private var deliveryRequirementsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Delivery Requirements", subtitle: "Provider-ready local requirements without media files.")

            VStack(spacing: HFSpacing.sm) {
                ForEach(streamingStore.deliveryRequirementRows) { row in
                    HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                        .accessibilityIdentifier("hf.export.deliveryRequirement")
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Delivery Requirements, poster artwork checklist, festival synopsis, platform notes, accessibility copy, final media asset source required")
        .accessibilityIdentifier("hf.export.deliveryRequirements")
        .accessibilityIdentifier("hf.services.deliveryRequirements")
    }

    private var distributionHandoffSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            StudioRoomSectionHeader(title: "Distribution Handoff", subtitle: "Local handoff map across launch, communication, catalog, and library boundaries.")

            VStack(spacing: HFSpacing.sm) {
                ForEach(streamingStore.distributionHandoffRows) { row in
                    HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                        .accessibilityIdentifier("hf.export.distributionHandoffItem")
                }
            }
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Distribution Handoff, launch campaign handoff, communication package, catalog identity, cloud library boundary, Remote Delivery Provider Not Connected Yet")
        .accessibilityIdentifier("hf.export.distributionHandoff")
        .accessibilityIdentifier("hf.services.distributionHandoff")
    }

    private var localToRemoteExportAdapterSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Local-to-Remote Export Adapter")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Delivery packages are structured locally today and ready for a future remote delivery provider.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.localToRemoteExportAdapterRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Local-to-Remote Export Adapter, delivery package schema ready, Remote Delivery Provider Not Connected Yet")
        .accessibilityIdentifier("hf.export.localToRemoteAdapter")
        .accessibilityIdentifier("hf.services.localToRemoteExportAdapter")
    }

    private var exportReadinessSection: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: accent.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Export Readiness")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Local review connects catalog, launch campaign, communication package, and cloud library boundaries while remote delivery services remain disconnected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                VStack(spacing: HFSpacing.xs) {
                    ForEach(streamingStore.exportDeliveryReadinessRows) { row in
                        HFConsumerMomentumRow(title: row.title, detail: row.detail, status: row.status, systemImage: row.systemImage)
                    }
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Export Readiness, Local review active, Remote Delivery Provider Not Connected Yet")
        .accessibilityIdentifier("hf.export.deliveryReadiness")
        .accessibilityIdentifier("hf.services.exportDeliveryReadiness")
        .accessibilityIdentifier("hf.services.exportLaunchHandoff")
        .accessibilityIdentifier("hf.services.exportCommunicationPackage")
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
                presentationProofPathSection
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

    private func proofMomentIcon(for title: String) -> String {
        switch title {
        case "Product Story": return "point.3.connected.trianglepath.dotted"
        case "Demo Runway": return "play.rectangle.on.rectangle.fill"
        case "Screenshot Evidence": return "camera.viewfinder"
        case "Protected Systems": return "shield.lefthalf.filled"
        case "Route Quality": return "arrow.triangle.branch"
        case "Evidence Locks": return "checkmark.seal.fill"
        default: return "checkmark.circle.fill"
        }
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

    private var presentationProofPathSection: some View {
        hubSection(
            title: "Presentation Proof Path",
            subtitle: "Internal route for showing the full HighFive product story and evidence locks."
        ) {
            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.36)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "play.rectangle.on.rectangle.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(HFColors.gold)
                            .frame(width: 48, height: 48)
                            .background(HFColors.gold.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            HFStatusBadge(title: "Internal Only", systemImage: "lock.shield.fill", isProminent: false)
                            Text("Presentation Proof Path")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Internal route for showing the full HighFive product story and evidence locks.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }

                    LazyVGrid(columns: columns, alignment: .leading, spacing: HFSpacing.sm) {
                        HFRoomSuiteProgressTile(row: HFRoomSuiteProgressRow(title: "Demo Tour", detail: "Guided product story", status: "Ready", systemImage: "play.rectangle.fill"), accent: HFColors.gold)
                        HFRoomSuiteProgressTile(row: HFRoomSuiteProgressRow(title: "Product Spine", detail: "Five-pillar map", status: "Ready", systemImage: "point.3.connected.trianglepath.dotted"), accent: HFColors.gold)
                        HFRoomSuiteProgressTile(row: HFRoomSuiteProgressRow(title: "Visual Parity", detail: "Design review path", status: "Review", systemImage: "rectangle.on.rectangle.angled"), accent: HFColors.gold)
                        HFRoomSuiteProgressTile(row: HFRoomSuiteProgressRow(title: "Protected Systems", detail: "Safety seal", status: "Locked", systemImage: "shield.lefthalf.filled"), accent: Color.gray)
                        HFRoomSuiteProgressTile(row: HFRoomSuiteProgressRow(title: "Screenshot Review", detail: "Capture plan", status: "Needed", systemImage: "camera.viewfinder"), accent: HFColors.gold)
                        HFRoomSuiteProgressTile(row: HFRoomSuiteProgressRow(title: "Evidence Locks", detail: "Prior proofs", status: "Ready", systemImage: "checkmark.seal.fill"), accent: HFColors.gold)
                    }

                    NavigationLink {
                        FinalDemoTourView()
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Open Demo Tour")
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .padding(.horizontal, HFSpacing.md)
                        .padding(.vertical, 11)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open Demo Tour, internal presentation proof path")
                }
                .padding(HFSpacing.lg)
            }
        }
        .accessibilityIdentifier("hf.devqa.presentationProofPath")
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
