import SwiftUI

struct CreatorTeamPermissionsPreviewView: View {
    private let members = [
        CreatorPermissionMember(
            name: "Michael Alston",
            role: "Owner",
            access: "Full Access",
            status: "Active",
            systemImage: "person.crop.circle.fill.badge.checkmark"
        ),
        CreatorPermissionMember(
            name: "Creative Lead",
            role: "Reviewer",
            access: "Notes + Approval",
            status: "Active",
            systemImage: "checkmark.seal.fill"
        ),
        CreatorPermissionMember(
            name: "Editor",
            role: "Contributor",
            access: "Trailer + Preview Clips",
            status: "Active",
            systemImage: "film.fill"
        ),
        CreatorPermissionMember(
            name: "Producer",
            role: "Reviewer",
            access: "Metadata + Rights",
            status: "Pending",
            systemImage: "person.crop.circle.badge.clock"
        )
    ]

    private let groups = [
        CreatorPermissionGroup(title: "Owner", description: "Full package control", systemImage: "crown.fill"),
        CreatorPermissionGroup(title: "Reviewer", description: "Notes, approvals, status updates", systemImage: "text.bubble.fill"),
        CreatorPermissionGroup(title: "Contributor", description: "Asset updates and draft edits", systemImage: "pencil.and.outline"),
        CreatorPermissionGroup(title: "Viewer", description: "Read-only preview access", systemImage: "eye.fill")
    ]

    private let matrixRows = [
        CreatorPermissionMatrixRow(title: "Package editing", access: "Owner, Contributor"),
        CreatorPermissionMatrixRow(title: "Review notes", access: "Owner, Reviewer"),
        CreatorPermissionMatrixRow(title: "Asset changes", access: "Owner, Contributor"),
        CreatorPermissionMatrixRow(title: "Submission approval", access: "Owner, Reviewer"),
        CreatorPermissionMatrixRow(title: "Version restore", access: "Owner only")
    ]

    private let comingNext = [
        "Real team invites",
        "Account-based roles",
        "Permission enforcement",
        "Reviewer assignments",
        "Approval routing"
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HFSpacing.xl) {
                header
                teamAccessSection
                teamMembersSection
                permissionGroupsSection
                accessMatrixSection
                comingNextSection
            }
            .padding(.top, HFSpacing.lg)
            .padding(.bottom, HFSpacing.floatingTabClearance)
        }
        .background(HFColors.screenBackground.ignoresSafeArea())
        .navigationTitle("Team Permissions")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: HFSpacing.sm) {
            Text("Team Permissions")
                .font(HFTypography.display)
                .foregroundStyle(HFColors.textPrimary)
                .minimumScaleFactor(0.78)

            Text("Preview roles, access levels, and review responsibilities.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Preview only. No live identities, invites, or role enforcement are connected.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.gold)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, HFSpacing.screenHorizontal)
    }

    private var teamAccessSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Team Access", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.panelRadius, strokeColor: HFColors.goldStroke) {
                VStack(alignment: .leading, spacing: HFSpacing.md) {
                    HStack(alignment: .top, spacing: HFSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: HFSpacing.md, style: .continuous)
                                .fill(HFColors.gold.opacity(0.16))
                            Image(systemName: "person.3.sequence.fill")
                                .font(.system(size: 30, weight: .black))
                                .foregroundStyle(HFColors.gold)
                        }
                        .frame(width: 68, height: 68)

                        VStack(alignment: .leading, spacing: HFSpacing.xs) {
                            Text("The Friendly — Creator Package")
                                .font(HFTypography.section)
                                .foregroundStyle(HFColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: HFSpacing.xs) {
                                CreatorPermissionStatusBadge(title: "Preview Only")
                                Text("Review roles: 3")
                                    .font(HFTypography.caption)
                                    .foregroundStyle(HFColors.textSecondary)
                            }
                        }

                        Spacer(minLength: HFSpacing.xs)
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.sm) {
                        CreatorPermissionMetric(title: "Team members", value: "4", systemImage: "person.2.fill")
                        CreatorPermissionMetric(title: "Pending invites", value: "2", systemImage: "envelope.badge.fill")
                    }

                    HStack(spacing: HFSpacing.sm) {
                        Text("Access status")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.textSecondary)
                        Spacer()
                        Text("Preview Only")
                            .font(HFTypography.caption)
                            .foregroundStyle(HFColors.gold)
                    }

                    Button {
                    } label: {
                        HStack(spacing: HFSpacing.xs) {
                            Text("Review Roles")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .black))
                        }
                        .font(HFTypography.smallAction)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(HFColors.goldGradient)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(HFSpacing.lg)
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var teamMembersSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Team Members", actionTitle: nil)

            VStack(spacing: HFSpacing.md) {
                ForEach(members) { member in
                    CreatorPermissionMemberCard(member: member)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var permissionGroupsSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Permission Groups", actionTitle: nil)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HFSpacing.md) {
                ForEach(groups) { group in
                    CreatorPermissionGroupCard(group: group)
                }
            }
            .padding(.horizontal, HFSpacing.screenHorizontal)
        }
    }

    private var accessMatrixSection: some View {
        VStack(alignment: .leading, spacing: HFSpacing.md) {
            HFSectionHeader(title: "Access Matrix", actionTitle: nil)

            HFGlassPanel(cornerRadius: HFSpacing.cardRadius) {
                VStack(spacing: HFSpacing.sm) {
                    ForEach(matrixRows) { row in
                        CreatorPermissionMatrixItem(row: row)
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
}

private struct CreatorPermissionMember: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let access: String
    let status: String
    let systemImage: String
}

private struct CreatorPermissionGroup: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
}

private struct CreatorPermissionMatrixRow: Identifiable {
    let id = UUID()
    let title: String
    let access: String
}

private struct CreatorPermissionMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 30, height: 30)
                .background(HFColors.gold.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)

                Text(title)
                    .font(HFTypography.micro)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(HFSpacing.sm)
        .background(HFColors.glassSurface)
        .overlay(
            RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: HFSpacing.sm, style: .continuous))
    }
}

private struct CreatorPermissionMemberCard: View {
    let member: CreatorPermissionMember

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            HStack(alignment: .top, spacing: HFSpacing.md) {
                Image(systemName: member.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 42, height: 42)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                VStack(alignment: .leading, spacing: HFSpacing.xs) {
                    HStack(alignment: .top, spacing: HFSpacing.xs) {
                        Text(member.name)
                            .font(HFTypography.cardTitle)
                            .foregroundStyle(HFColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: HFSpacing.xs)

                        CreatorPermissionStatusBadge(title: member.status)
                    }

                    Text(member.role)
                        .font(HFTypography.caption)
                        .foregroundStyle(HFColors.gold)

                    Text(member.access)
                        .font(HFTypography.body)
                        .foregroundStyle(HFColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorPermissionGroupCard: View {
    let group: CreatorPermissionGroup

    var body: some View {
        HFGlassPanel(cornerRadius: HFSpacing.cardRadius, strokeColor: HFColors.goldStroke) {
            VStack(alignment: .leading, spacing: HFSpacing.sm) {
                Image(systemName: group.systemImage)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(HFColors.gold)
                    .frame(width: 36, height: 36)
                    .background(HFColors.gold.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: HFSpacing.xs, style: .continuous))

                Text(group.title)
                    .font(HFTypography.cardTitle)
                    .foregroundStyle(HFColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(group.description)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(HFSpacing.md)
        }
    }
}

private struct CreatorPermissionMatrixItem: View {
    let row: CreatorPermissionMatrixRow

    var body: some View {
        HStack(alignment: .top, spacing: HFSpacing.sm) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(HFColors.gold)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: HFSpacing.xxs) {
                Text(row.title)
                    .font(HFTypography.body)
                    .foregroundStyle(HFColors.textPrimary)

                Text(row.access)
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, HFSpacing.xxs)
    }
}

private struct CreatorPermissionStatusBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(HFTypography.micro)
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, HFSpacing.xs)
            .padding(.vertical, 6)
            .background(HFColors.gold)
            .clipShape(Capsule())
    }
}
