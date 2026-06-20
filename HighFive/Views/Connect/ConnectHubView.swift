import SwiftUI

enum HFConnectSpatialMode {
    case hub
    case watchRoom
    case premiereLobby
}

struct ConnectHubView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var followedCreatorIDs: Set<UUID> = []
    @State private var savedRoomIDs: Set<UUID> = []
    @State private var mode: HFConnectSpatialMode
    @State private var showingInspector = false
    @State private var showingActivity = false
    @State private var showingInvite = false
    @State private var reactionCount = 3

    private let movie: Movie?

    private var usesSpatialFallbackLayout: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    init(initialMode: HFConnectSpatialMode = .hub, movie: Movie? = nil) {
        self._mode = State(initialValue: initialMode)
        self.movie = movie
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                spatialConnectWorld
                secondaryConnectContexts
            }
            .padding(.top, HFSpacing.xxl)
            .padding(.bottom, HFSpacing.floatingTabClearance + HFSpacing.tabBarHeight)
            .accessibilityIdentifier("hf.spatial.connect")
        }
        .background(connectBackground)
        .navigationTitle("Connect")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingInspector) {
            connectInspector
        }
        .sheet(isPresented: $showingActivity) {
            localActivitySheet
        }
        .sheet(isPresented: $showingInvite) {
            invitationSheet
        }
        .accessibilityIdentifier("hf.connect.system")
    }

    private var currentMovie: Movie {
        movie ?? HFMockData.movie("friendly") ?? HFMockData.movies[0]
    }

    private var roomTitle: String {
        switch mode {
        case .hub:
            return "Watch Together"
        case .watchRoom:
            return "Local Preview Room"
        case .premiereLobby:
            return "Premiere Lobby"
        }
    }

    private var connectBackground: some View {
        ZStack {
            HFColors.screenBackground
            RadialGradient(
                colors: [HFColors.cyanGlow.opacity(0.16), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 380
            )
            RadialGradient(
                colors: [HFColors.amberGlow.opacity(0.15), .clear],
                center: .bottomLeading,
                startRadius: 30,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }

    private var spatialConnectWorld: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.heroRadius, strokeColor: HFColors.cyanGlow.opacity(0.28)) {
            Group {
                if usesSpatialFallbackLayout {
                    VStack(alignment: .leading, spacing: HFSpacing.md) {
                        sceneCopy
                        moviePortal(width: 286, height: 342)
                            .frame(maxWidth: .infinity, alignment: .center)
                        presenceSummaryFallback
                        modeStatus
                        roomControls
                    }
                    .padding(HFSpacing.md)
                    .accessibilityIdentifier("hf.spatial.accessibility.fallbackLayout")
                } else {
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        let height = proxy.size.height
                        ZStack {
                            connectDepthSurface
                            presenceArcs(in: proxy.size)
                            moviePortal(width: min(width * 0.70, 304), height: min(height * 0.56, 386))
                                .position(x: width * 0.50, y: height * 0.43)
                            presenceConstellation(in: proxy.size)
                            sceneCopy
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            modeStatus
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            roomControls
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                .padding(.horizontal, HFSpacing.md)
                                .padding(.bottom, HFSpacing.md)
                        }
                    }
                }
            }
            .frame(height: usesSpatialFallbackLayout ? 760 : 660)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(roomTitle), \(currentMovie.title), room presence preview")
            .accessibilityIdentifier("hf.spatial.accessibility.largeType")
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier(mode == .watchRoom ? "hf.spatial.watchRoom" : mode == .premiereLobby ? "hf.spatial.premiereLobby" : "hf.spatial.connect")
    }

    private var connectDepthSurface: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, reduceTransparency ? Color.black : HFColors.charcoal.opacity(0.88), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            HFDepthContourOverlay(color: HFColors.cyanGlow, lineWidth: 0.8)
                .opacity(mode == .premiereLobby ? 0.28 : 0.38)
            Circle()
                .fill(HFColors.cyanGlow.opacity(0.12))
                .frame(width: 250, height: 250)
                .blur(radius: 42)
                .offset(x: 92, y: -122)
            Circle()
                .fill(HFColors.amberGlow.opacity(0.14))
                .frame(width: 210, height: 210)
                .blur(radius: 46)
                .offset(x: -104, y: 170)
        }
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))
        .accessibilityHidden(true)
    }

    private func moviePortal(width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            portalArtwork
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.20), Color.black.opacity(0.84)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                        .stroke(HFColors.gold.opacity(mode == .premiereLobby ? 0.66 : 0.42), lineWidth: 1.2)
                )
                .overlay(HFDepthContourOverlay(color: HFColors.gold.opacity(0.86), lineWidth: 0.72))
                .shadow(color: HFColors.cyanGlow.opacity(0.22), radius: reduceMotion ? 0 : 26, x: 0, y: 18)

            VStack(alignment: .leading, spacing: HFSpacing.xs) {
                Text(currentMovie.title)
                    .font(.system(size: 30, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)

                Text(mode == .watchRoom ? "Watching locally" : currentMovie.subtitle)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)
            }
            .padding(HFSpacing.lg)
        }
        .scaleEffect(reduceMotion ? 1 : (mode == .hub ? 1.0 : 1.025))
                .animation(reduceMotion ? .easeOut(duration: 0.01) : HFSpatialMotionTokens.sceneEntranceAnimation, value: mode)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(currentMovie.title), movie portal")
        .accessibilityIdentifier(mode == .watchRoom ? "hf.spatial.watchRoom.portal" : mode == .premiereLobby ? "hf.spatial.premiereLobby.portal" : "hf.spatial.connect.portal")
    }

    private var portalArtwork: some View {
        Group {
            if let assetName = currentMovie.backdropAssetName ?? currentMovie.posterAssetName,
               HFPosterAssetHealth.hasImage(named: assetName) {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [HFColors.charcoal, HFColors.warmGlow.opacity(0.42), HFColors.background],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var sceneCopy: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Connect")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .textCase(.uppercase)
                .tracking(1.4)

            Text(roomTitle)
                .font(HFTypography.title)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .accessibilityIdentifier("hf.spatial.connect.title")

            if mode == .premiereLobby {
                Text("Countdown preview")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .accessibilityIdentifier("hf.spatial.premiereLobby.countdown")
            } else {
                Text("Room presence preview")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }
        }
        .padding(HFSpacing.lg)
    }

    private var modeStatus: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            if mode == .watchRoom {
                Text("Playback synchronization not connected")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .padding(.horizontal, HFSpacing.sm)
                    .frame(height: 28)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())
                    .accessibilityIdentifier("hf.spatial.watchRoom.syncNotConnected")
            }

            Text(mode == .watchRoom ? "Local Preview" : "\(HFConnectPreviewData.featuredCreators.count + 3) viewers nearby")
                .font(HFTypography.micro)
                .foregroundStyle(mode == .watchRoom ? HFColors.gold : HFColors.cyanGlow)
                .padding(.horizontal, HFSpacing.sm)
                .frame(height: 28)
                .background(Color.black.opacity(0.42))
                .overlay(Capsule().stroke(Color.white.opacity(0.13), lineWidth: 1))
                .clipShape(Capsule())
                .accessibilityIdentifier(mode == .watchRoom ? "hf.spatial.watchRoom.localPreview" : "hf.spatial.connect.localPreview")
        }
        .padding(.leading, HFSpacing.lg)
        .padding(.bottom, 96)
    }

    private func presenceArcs(in size: CGSize) -> some View {
        Path { path in
            let center = CGPoint(x: size.width * 0.50, y: size.height * 0.42)
            let points = [
                CGPoint(x: size.width * 0.22, y: size.height * 0.27),
                CGPoint(x: size.width * 0.80, y: size.height * 0.30),
                CGPoint(x: size.width * 0.18, y: size.height * 0.62),
                CGPoint(x: size.width * 0.82, y: size.height * 0.61)
            ]
            for point in points {
                path.move(to: point)
                path.addQuadCurve(to: center, control: CGPoint(x: (point.x + center.x) / 2, y: min(point.y, center.y) - 42))
            }
        }
        .stroke(HFColors.cyanGlow.opacity(reduceMotion ? 0.18 : 0.36), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [4, 8]))
        .accessibilityHidden(true)
    }

    private func presenceConstellation(in size: CGSize) -> some View {
        ZStack {
            presenceNode(name: "Maya", role: "Host", isHost: true, identifier: mode == .premiereLobby ? "hf.spatial.premiereLobby.host" : mode == .watchRoom ? "hf.spatial.watchRoom.host" : "hf.spatial.connect.host")
                .position(x: size.width * 0.22, y: size.height * 0.27)

            presenceNode(name: "Ari", role: "Guest", isHost: false, identifier: mode == .watchRoom ? "hf.spatial.watchRoom.guests" : mode == .premiereLobby ? "hf.spatial.premiereLobby.guests" : "hf.spatial.connect.presence")
                .position(x: size.width * 0.80, y: size.height * 0.30)

            presenceNode(name: "Noah", role: "Guest", isHost: false, identifier: "hf.spatial.connect.presence")
                .position(x: size.width * 0.18, y: size.height * 0.62)

            presenceNode(name: "Elle", role: "Guest", isHost: false, identifier: "hf.spatial.connect.presence")
                .position(x: size.width * 0.82, y: size.height * 0.61)
        }
        .opacity(mode == .hub ? 0.96 : 1)
        .scaleEffect(reduceMotion ? 1 : (mode == .watchRoom ? 1.02 : 1))
        .animation(reduceMotion ? .easeOut(duration: 0.01) : HFSpatialMotionTokens.standardAnimation, value: mode)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Viewer constellation, host and three guests")
        .accessibilityIdentifier("hf.spatial.connect.constellation")
    }

    private func presenceNode(name: String, role: String, isHost: Bool, identifier: String) -> some View {
        VStack(spacing: HFSpacing.xxs) {
            ZStack {
                Circle()
                    .fill(isHost ? HFColors.goldGradient : LinearGradient(colors: [HFColors.cyanGlow.opacity(0.82), Color.white.opacity(0.72)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: isHost ? 54 : 44, height: isHost ? 54 : 44)
                    .shadow(color: (isHost ? HFColors.amberGlow : HFColors.cyanGlow).opacity(0.38), radius: reduceMotion ? 0 : 14)
                Image(systemName: isHost ? "star.fill" : "person.fill")
                    .font(.system(size: isHost ? 18 : 15, weight: .black))
                    .foregroundStyle(isHost ? .black : HFColors.background)
                if differentiateWithoutColor && isHost {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.black)
                        .offset(x: 18, y: -18)
                        .accessibilityHidden(true)
                }
            }

            Text(isHost ? "Host" : name)
                .font(HFTypography.micro)
                .foregroundStyle(isHost ? HFColors.gold : HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(width: 78, height: 80)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name), \(role)")
        .accessibilityIdentifier(identifier)
    }

    private var presenceSummaryFallback: some View {
        HStack(spacing: HFSpacing.sm) {
            presenceNode(name: "Maya", role: "Host", isHost: true, identifier: mode == .premiereLobby ? "hf.spatial.premiereLobby.host" : mode == .watchRoom ? "hf.spatial.watchRoom.host" : "hf.spatial.connect.host")
            presenceNode(name: "Ari", role: "Guest", isHost: false, identifier: mode == .watchRoom ? "hf.spatial.watchRoom.guests" : mode == .premiereLobby ? "hf.spatial.premiereLobby.guests" : "hf.spatial.connect.presence")
            presenceNode(name: "Noah", role: "Guest", isHost: false, identifier: "hf.spatial.connect.presence")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Host and guest presence summary")
    }

    @ViewBuilder
    private var roomControls: some View {
        switch mode {
        case .hub:
            HFSpatialActionCluster {
                HFEnergyAction(title: "Enter Local Room", systemImage: "play.fill", style: .gold) {
                    withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.standardAnimation) {
                        mode = .watchRoom
                    }
                }
                .accessibilityIdentifier("hf.spatial.connect.enterRoom")

                HStack(spacing: HFSpacing.sm) {
                    HFEnergyAction(title: "Invite", systemImage: "person.badge.plus.fill", style: .cyan) {
                        showingInvite = true
                    }
                    .accessibilityIdentifier("hf.spatial.connect.invite")

                    HFEnergyAction(title: "More", systemImage: "ellipsis", style: .glass) {
                        showingInspector = true
                    }
                    .accessibilityIdentifier("hf.spatial.connect.more")
                }
            }
        case .watchRoom:
            HFSpatialActionCluster {
                HFEnergyAction(title: "Continue Local Preview", systemImage: "play.fill", style: .gold) {}
                    .accessibilityIdentifier("hf.spatial.watchRoom.localPreview")

                HStack(spacing: HFSpacing.sm) {
                    HFEnergyAction(title: "React", systemImage: "sparkles", style: .cyan) {
                        reactionCount += 1
                    }
                    .accessibilityIdentifier("hf.spatial.watchRoom.reactions")

                    HFEnergyAction(title: "Invite", systemImage: "person.badge.plus.fill", style: .glass) {
                        showingInvite = true
                    }
                    .accessibilityIdentifier("hf.spatial.watchRoom.invite")

                    HFEnergyAction(title: "Leave", systemImage: "xmark", style: .glass) {
                        withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.standardAnimation) {
                            mode = .hub
                        }
                    }
                    .accessibilityIdentifier("hf.spatial.watchRoom.leave")
                }
            }
        case .premiereLobby:
            HFSpatialActionCluster {
                HFEnergyAction(title: "Enter Lobby", systemImage: "sparkles.tv.fill", style: .gold) {
                    withAnimation(reduceMotion ? nil : HFSpatialMotionTokens.standardAnimation) {
                        mode = .watchRoom
                    }
                }
                .accessibilityIdentifier("hf.spatial.premiereLobby.enter")

                HStack(spacing: HFSpacing.sm) {
                    HFEnergyAction(title: "Invite", systemImage: "person.badge.plus.fill", style: .cyan) {
                        showingInvite = true
                    }

                    HFEnergyAction(title: "More", systemImage: "ellipsis", style: .glass) {
                        showingInspector = true
                    }
                }
            }
        }
    }

    private var secondaryConnectContexts: some View {
        HFOpticalGlassSurface(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.24)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Label("Premiere Lobby", systemImage: "sparkles.tv.fill")
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Spacer()
                    Button("Activity") {
                        showingActivity = true
                    }
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.cyanGlow)
                    .accessibilityIdentifier("hf.connect.activity")
                }

                HStack(spacing: HFSpacing.sm) {
                    Button {
                        mode = .premiereLobby
                    } label: {
                        secondaryContextPill(title: "Premiere Lobby", subtitle: "18:00 preview", systemImage: "clock.fill")
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        CreatorStudioView()
                    } label: {
                        creatorCirclePreview
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    showingInspector = true
                } label: {
                    Label("Activity Local Only", systemImage: "lock.shield.fill")
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("hf.connect.activity.localOnly")
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var creatorCirclePreview: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Label("Creator Circle", systemImage: "person.3.fill")
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .accessibilityIdentifier("hf.spatial.creatorCircle")
            Text(currentMovie.title)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .lineLimit(1)
                .accessibilityIdentifier("hf.spatial.creatorCircle.project")
            Text("Release milestone reviewed locally")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(2)
                .accessibilityIdentifier("hf.spatial.creatorCircle.milestone")
            Text("Open Studio")
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.cyanGlow)
                .accessibilityIdentifier("hf.spatial.creatorCircle.openStudio")
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(HFColors.glassStroke, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Creator Circle, \(currentMovie.title), release milestone reviewed locally, open studio")
        .accessibilityIdentifier("hf.spatial.creatorCircle.members")
    }

    private func secondaryContextPill(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(HFColors.gold)
            Text(title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(subtitle)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .padding(HFSpacing.md)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous).stroke(HFColors.glassStroke, lineWidth: 1))
    }

    private var connectInspector: some View {
        NavigationStack {
            HFSpatialInspectorChrome(
                title: "Room Inspector",
                detail: "Local room status, presence boundaries, and messaging boundaries stay secondary to the movie portal.",
                accent: HFColors.cyanGlow
            ) {
                VStack(alignment: .leading, spacing: HFSpacing.sm) {
                    Text("Local Preview Room")
                    Text("Presence Provider Not Connected")
                        .accessibilityIdentifier("hf.connect.presenceNotConnected")
                    Text("Playback Sync Not Connected")
                        .accessibilityIdentifier("hf.connect.syncNotConnected")
                    Text("Invitations Local Only")
                        .accessibilityIdentifier("hf.connect.invitesLocalOnly")
                    Text("No live messaging")
                        .accessibilityIdentifier("hf.connect.noLiveMessaging")
                    Text("No remote watch-room provider")
                        .accessibilityIdentifier("hf.connect.noLiveRoomProvider")
                }
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
            }
            .accessibilityIdentifier("hf.connect.inspector")
        }
        .presentationDetents([.medium, .large])
    }

    private var localActivitySheet: some View {
        NavigationStack {
            List {
                Text("Saved \(currentMovie.title)")
                Text("Joined a local room preview")
                Text("Opened a creator circle")
                Text("Reviewed a release milestone")
                Text("Activity Local Only")
                    .accessibilityIdentifier("hf.connect.activity.localOnly")
            }
            .navigationTitle("Activity")
            .accessibilityIdentifier("hf.connect.activity")
        }
        .presentationDetents([.medium])
    }

    private var invitationSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                Text("Invite")
                    .font(HFTypography.title)
                    .foregroundStyle(HFColors.textPrimary)
                Text("Invitations stay local in this preview. No remote delivery or messaging transport is active.")
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(HFSpacing.lg)
            .background(HFColors.screenBackground.ignoresSafeArea())
            .navigationTitle("Invite")
        }
        .presentationDetents([.medium])
    }

    private var header: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.34)) {
            VStack(alignment: .leading, spacing: HFSpacing.lg) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "person.2.wave.2.fill")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.black)
                        .frame(width: 56, height: 56)
                        .background(HFColors.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Connect System")
                            .font(HFTypography.title)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

                        Text("Watch rooms, creator circles, activity feed, and social graph.")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: HFSpacing.sm)

                    NavigationLink {
                        ConnectNotificationsPreviewView()
                    } label: {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 46, height: 46)
                            .background(HFColors.goldGradient)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open notifications")
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: HFSpacing.xs) {
                    HFStatusBadge(title: "02 Connect System", isProminent: true)
                    HFStatusBadge(title: "Active", isProminent: false)
                    HFStatusBadge(title: "Local Preview", isProminent: false)
                    HFStatusBadge(title: "Provider-ready", isProminent: false)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    HFConnectSystemMetric(title: "Rooms", value: "\(HFConnectPreviewData.socialRooms.count)", systemImage: "bubble.left.and.bubble.right.fill")
                    HFConnectSystemMetric(title: "Creators", value: "\(HFConnectPreviewData.featuredCreators.count)", systemImage: "person.crop.circle.fill")
                    HFConnectSystemMetric(title: "Signals", value: "\(HFConnectPreviewData.communitySignals.count)", systemImage: "chart.line.uptrend.xyaxis")
                    HFConnectSystemMetric(title: "Provider", value: "Local", systemImage: "network.slash")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("hf.connect.hero")
    }

    private var connectSystemStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: HFSpacing.sm) {
                HFConnectSystemCard(title: "Watch Rooms", detail: "The Friendly and Paranormall rooms", status: "Local", systemImage: "play.tv.fill")
                    .accessibilityIdentifier("hf.connect.watchRooms")
                HFConnectSystemCard(title: "Creator Circles", detail: "Follow creators and review packages", status: "Preview", systemImage: "person.3.fill")
                    .accessibilityIdentifier("hf.connect.creatorCircles")
                HFConnectSystemCard(title: "Activity Feed", detail: "Reactions, notes, and comments", status: "Local", systemImage: "rectangle.stack.fill")
                    .accessibilityIdentifier("hf.connect.activityFeed")
                HFConnectSystemCard(title: "Social Graph", detail: "Project relationships and signals", status: "Provider-ready", systemImage: "point.3.connected.trianglepath.dotted")
                    .accessibilityIdentifier("hf.connect.socialGraph")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .accessibilityIdentifier("hf.connect.systemStrip")
    }

    private var storiesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.featuredCreators) { creator in
                    NavigationLink {
                        CreatorProfilePreviewView(creator: creator)
                    } label: {
                        HFConnectStoryAvatar(
                            name: creator.name,
                            subtitle: creator.role,
                            systemImage: "person.crop.circle.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }

                ForEach(HFConnectPreviewData.socialRooms.prefix(3)) { room in
                    NavigationLink {
                        SocialRoomDetailPreviewView(room: room)
                    } label: {
                        HFConnectStoryAvatar(
                            name: room.name,
                            subtitle: "\(room.activeNow) active",
                            systemImage: "bubble.left.and.bubble.right.fill"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var featuredReel: some View {
        NavigationLink {
            ActivityFeedPreviewView()
        } label: {
            ZStack(alignment: .bottomLeading) {
                featuredArtwork
                    .frame(height: 520)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.18), Color.black.opacity(0.94)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack {
                        HFStatusBadge(title: "Local Preview", isProminent: true)
                        HFStatusBadge(title: "Creator Feed", isProminent: false)
                        Spacer()
                        VStack(spacing: HFSpacing.sm) {
                            HFConnectVerticalMetric(systemImage: "heart.fill", value: "4.8K")
                            HFConnectVerticalMetric(systemImage: "text.bubble.fill", value: "318")
                            HFConnectVerticalMetric(systemImage: "bookmark.fill", value: "1.2K")
                        }
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: HFSpacing.sm) {
                        Text("The Friendly Watch Room")
                            .font(.system(size: 34, weight: .black, design: .default))
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.72)

                        Text("Poster reactions are up, trailer comments are moving, and creators are joining the room.")
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: HFSpacing.sm) {
                            Label("Watch feed", systemImage: "play.fill")
                                .font(HFTypography.smallAction)
                                .foregroundStyle(.black)
                                .padding(.horizontal, HFSpacing.md)
                                .frame(height: 42)
                                .background(HFColors.goldGradient)
                                .clipShape(Capsule())

                            Label("37 active", systemImage: "person.2.fill")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textPrimary)
                                .padding(.horizontal, HFSpacing.sm)
                                .frame(height: 42)
                                .background(Color.white.opacity(0.14))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(HFSpacing.lg)
            }
            .overlay(
                RoundedRectangle(cornerRadius: HFSpacing.heroRadius, style: .continuous)
                    .stroke(HFColors.gold.opacity(0.44), lineWidth: 1)
            )
            .shadow(color: HFColors.amberGlow.opacity(0.22), radius: 26, x: 0, y: 18)
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open The Friendly Watch Room feed")
    }

    private var featuredArtwork: some View {
        Group {
            if let movie = HFMockData.movie("friendly"),
               HFPosterAssetHealth.hasImage(named: movie.backdropAssetName ?? movie.posterAssetName),
               let assetName = movie.backdropAssetName ?? movie.posterAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [HFColors.charcoal, HFColors.warmGlow.opacity(0.42), HFColors.background],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }

    private var feedEntry: some View {
        NavigationLink {
            ActivityFeedPreviewView()
        } label: {
            HFActionTile(
                title: "Open Feed",
                subtitle: "Swipe through creator posts, community reactions, watch rooms, and project updates.",
                systemImage: "play.rectangle.on.rectangle.fill"
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Connect feed")
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var connectSystemPanel: some View {
        HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.30)) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "rectangle.connected.to.line.below")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 48, height: 48)
                        .background(HFColors.gold.opacity(0.13))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        Text("Community System")
                            .font(HFTypography.section)
                            .foregroundStyle(HFColors.textPrimary)
                        Text("Connect stays local: rooms, follows, comments, saves, and notifications are preview state only. No live provider is connected.")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                    HFConnectSystemMetric(title: "Social provider", value: "Not Connected Yet", systemImage: "network.slash")
                        .accessibilityIdentifier("hf.connect.notConnectedYet")
                    HFConnectSystemMetric(title: "Posting", value: "Off", systemImage: "lock.shield.fill")
                    HFConnectSystemMetric(title: "Rooms", value: "Preview", systemImage: "bubble.left.and.bubble.right.fill")
                    HFConnectSystemMetric(title: "Notifications", value: "Local", systemImage: "bell.badge.fill")
                }
            }
            .padding(HFSpacing.lg)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
        .accessibilityIdentifier("hf.connect.providerBoundary")
    }

    private var featuredCreatorsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Creator Circles", actionTitle: nil)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HFSpacing.md) {
                    ForEach(HFConnectPreviewData.featuredCreators) { creator in
                        NavigationLink {
                            CreatorProfilePreviewView(creator: creator)
                        } label: {
                            creatorCard(creator)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, HFSpacing.screenHorizontal)
            }
        }
    }

    private func creatorCard(_ creator: HFConnectCreator) -> some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HStack(spacing: HFSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(HFColors.goldGradient)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28, weight: .black))
                        .foregroundStyle(.black)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                    Text(creator.name)
                        .font(HFTypography.cardTitle)
                        .foregroundStyle(HFColors.textPrimary)
                    Text(creator.role)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                }
            }

            Text(creator.bio)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("\(creator.followers) followers")
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.gold)
                Spacer()
            }

            Button {
                toggleFollow(creator.id)
            } label: {
                Text(followedCreatorIDs.contains(creator.id) ? "Following" : "Follow")
                    .font(HFTypography.smallAction)
                    .foregroundStyle(followedCreatorIDs.contains(creator.id) ? HFColors.textPrimary : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(followedCreatorIDs.contains(creator.id) ? AnyShapeStyle(Color.white.opacity(0.14)) : AnyShapeStyle(HFColors.goldGradient))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 210, alignment: .topLeading)
        .padding(HFSpacing.md)
        .background(HFColors.glassSurface)
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.24), lineWidth: 1)
        )
    }

    private var roomsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Watch Rooms", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.socialRooms.prefix(3)) { room in
                    NavigationLink {
                        SocialRoomDetailPreviewView(room: room)
                    } label: {
                        roomCard(room)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func roomCard(_ room: HFConnectSocialRoom) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 20, weight: .black))
                    .foregroundStyle(.black)
                    .frame(width: 52, height: 52)
                    .background(HFColors.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack {
                        Text(room.name)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text(room.activeNow)
                            .font(HFTypography.micro)
                            .foregroundStyle(.black)
                            .padding(.horizontal, HFSpacing.xs)
                            .frame(height: 22)
                            .background(HFColors.goldGradient)
                            .clipShape(Capsule())
                    }

                    Text(room.subtitle)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: HFSpacing.sm) {
                        Label(room.members, systemImage: "person.2.fill")
                        Label("\(room.comments) comments", systemImage: "text.bubble.fill")
                        Spacer()
                        Button {
                            toggleRoomSave(room.id)
                        } label: {
                            Image(systemName: savedRoomIDs.contains(room.id) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }
                        .buttonStyle(.plain)
                    }
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private var projectUpdatesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Activity Feed", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.projectUpdates) { update in
                    NavigationLink {
                        ProjectCommunityPreviewView()
                    } label: {
                        HStack(spacing: HFSpacing.md) {
                            Image(systemName: update.systemImage)
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(HFColors.gold)
                                .frame(width: 44, height: 44)
                                .background(HFColors.gold.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                                Text(update.title)
                                    .font(HFTypography.cardTitle)
                                    .foregroundStyle(HFColors.textPrimary)
                                Text(update.detail)
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }
                        .padding(HFSpacing.md)
                        .background(HFColors.glassSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                                .stroke(HFColors.gold.opacity(0.16), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var signalStrip: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Social Graph", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.communitySignals) { signal in
                    HFMetricCard(title: signal.title.replacingOccurrences(of: "Mock ", with: ""), value: signal.value, systemImage: signal.systemImage)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var connectMomentumSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Connect Momentum", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.gold.opacity(0.22)) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.black)
                            .frame(width: 48, height: 48)
                            .background(HFColors.goldGradient)
                            .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("Active local social surface")
                                .font(HFTypography.cardTitle)
                                .foregroundStyle(HFColors.textPrimary)
                            Text("Reactions, follows, rooms, and graph signals are product preview state. No live provider, account connection, OAuth, posting, or comments backend is active.")
                                .font(HFTypography.caption)
                                .foregroundStyle(HFColors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(spacing: HFSpacing.sm) {
                        HFStatusBadge(title: "Active", isProminent: true)
                        HFStatusBadge(title: "Provider-ready", isProminent: false)
                        HFStatusBadge(title: "Not Connected Yet", isProminent: false)
                    }
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private func toggleFollow(_ id: UUID) {
        if followedCreatorIDs.contains(id) {
            followedCreatorIDs.remove(id)
        } else {
            followedCreatorIDs.insert(id)
        }
    }

    private func toggleRoomSave(_ id: UUID) {
        if savedRoomIDs.contains(id) {
            savedRoomIDs.remove(id)
        } else {
            savedRoomIDs.insert(id)
        }
    }
}

private struct HFConnectStoryAvatar: View {
    let name: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(spacing: HFSpacing.xs) {
            ZStack {
                Circle()
                    .stroke(HFColors.goldGradient, lineWidth: 3)
                Circle()
                    .fill(HFColors.surfaceElevated)
                    .padding(4)
                Image(systemName: systemImage)
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(HFColors.gold)
            }
            .frame(width: 78, height: 78)

            Text(name)
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(1)
                .frame(width: 86)

            Text(subtitle)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textMuted)
                .lineLimit(1)
                .frame(width: 86)
        }
    }
}

private struct HFConnectSystemCard: View {
    let title: String
    let detail: String
    let status: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(.black)
                .frame(width: 38, height: 38)
                .background(HFColors.goldGradient)
                .clipShape(Circle())

            Text(title)
                .font(HFTypography.cardTitle)
                .foregroundStyle(HFColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(detail)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Spacer(minLength: HFSpacing.xs)

            Text(status)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.gold)
                .padding(.horizontal, HFSpacing.xs)
                .frame(height: 22)
                .background(HFColors.gold.opacity(0.10))
                .overlay(Capsule().stroke(HFColors.gold.opacity(0.24), lineWidth: 1))
                .clipShape(Capsule())
        }
        .frame(width: 154, height: 148, alignment: .topLeading)
        .padding(HFSpacing.sm)
        .background(HFColors.glassSurface)
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous)
                .stroke(HFColors.gold.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.cardRadius, style: .continuous))
    }
}

private struct HFConnectSystemMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.xs) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 30, height: 30)
                .background(HFColors.gold.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
                Text(value)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HFSpacing.sm)
        .background(Color.white.opacity(0.055))
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))
    }
}

private struct HFConnectVerticalMetric: View {
    let systemImage: String
    let value: String

    var body: some View {
        VStack(spacing: HFSpacing.xxs) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.textPrimary)
                .frame(width: 42, height: 42)
                .background(Color.black.opacity(0.36))
                .clipShape(Circle())
            Text(value)
                .font(HFTypography.micro)
                .foregroundStyle(HFColors.textPrimary)
        }
    }
}
