import SwiftUI

struct CreatorCirclesPreviewView: View {
    @State private var followedCircleIDs: Set<UUID> = []
    @State private var connectedRoleIDs: Set<UUID> = []

    private let comingNext = [
        "Real creator circles",
        "Real collaboration requests",
        "Real creator messaging",
        "Verified profiles",
        "Marketplace hiring"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                HFBreadcrumbTrail(items: ["Connect", "Creator Circles"])
                featuredCirclesSection
                collaborationSignalsSection
                suggestedConnectionsSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Creator Circles")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Creator Circles")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)

            Text("Find collaborators, follow creative teams, and preview creator networks.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. Follows, connects, and collaboration signals are local mock UI.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var featuredCirclesSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Featured Circles", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.creatorCircles) { circle in
                    circleCard(circle)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var collaborationSignalsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Collaboration Signals", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                HFMetricCard(title: "Open collaborations", value: "24", systemImage: "person.2.wave.2.fill")
                HFMetricCard(title: "Creators available", value: "48", systemImage: "person.crop.circle.badge.checkmark")
                HFMetricCard(title: "Package requests", value: "7", systemImage: "tray.full.fill")
                HFMetricCard(title: "Review-ready teams", value: "12", systemImage: "checkmark.seal.fill")
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var suggestedConnectionsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Suggested Connections", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(HFConnectPreviewData.suggestedConnections) { connection in
                    suggestedConnectionCard(connection)
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

    private func circleCard(_ circle: HFConnectCreatorCircle) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.md) {
                HStack(alignment: .top, spacing: HFSpacing.md) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                        .frame(width: 44, height: 44)
                        .background(HFColors.gold.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                    VStack(alignment: .leading, spacing: HFSpacing.xs) {
                        HStack(spacing: HFSpacing.xs) {
                            Text(circle.name)
                                .font(HFTypography.body)
                                .foregroundStyle(HFColors.textPrimary)
                            Spacer(minLength: HFSpacing.xs)
                            HFStatusBadge(title: circle.status, isProminent: false)
                        }
                        Text("Members: \(circle.members)")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                        Text("Focus: \(circle.focus)")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HFSpacing.sm) {
                        ForEach(circle.suggestedRoles, id: \.self) { role in
                            HFRouteChip(title: role, systemImage: "person.fill")
                        }
                    }
                }

                Button {
                    toggleCircle(circle.id)
                } label: {
                    Text(followedCircleIDs.contains(circle.id) ? "Following Circle" : "Follow Circle")
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle mock follow for \(circle.name)")
            }
            .padding(HFSpacing.md)
        }
    }

    private func suggestedConnectionCard(_ connection: HFConnectSuggestedConnection) -> some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.glassStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 44, height: 44)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(spacing: HFSpacing.xs) {
                        Text(connection.name)
                            .font(HFTypography.body)
                            .foregroundStyle(HFColors.textPrimary)
                        Spacer(minLength: HFSpacing.xs)
                        HFStatusBadge(title: connection.role, isProminent: false)
                    }
                    Text(connection.focus)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        toggleConnection(connection.id)
                    } label: {
                        Text(connectedRoleIDs.contains(connection.id) ? "Connected Preview" : "Connect Preview")
                            .font(HFTypography.micro)
                            .foregroundStyle(HFColors.gold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .background(HFColors.gold.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Toggle mock connect for \(connection.name)")
                }
            }
            .padding(HFSpacing.md)
        }
    }

    private func toggleCircle(_ id: UUID) {
        if followedCircleIDs.contains(id) {
            followedCircleIDs.remove(id)
        } else {
            followedCircleIDs.insert(id)
        }
    }

    private func toggleConnection(_ id: UUID) {
        if connectedRoleIDs.contains(id) {
            connectedRoleIDs.remove(id)
        } else {
            connectedRoleIDs.insert(id)
        }
    }
}
