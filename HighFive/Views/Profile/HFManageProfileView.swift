import SwiftUI

struct HFManageProfileView: View {
    @ObservedObject var profileStore: HFLocalProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var avatarSymbol = "person.crop.circle.fill"
    @State private var showDeleteConfirmation = false

    private let avatarOptions = [
        "person.crop.circle.fill",
        "sparkles",
        "film.fill",
        "play.rectangle.fill",
        "star.circle.fill",
        "bolt.circle.fill"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                profilePreview
                editCard
                avatarCard
                saveButton
                infoCard
                deleteButton
            }
            .padding(20)
        }
        .background(HFColors.background.ignoresSafeArea())
        .navigationTitle("Manage Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            profileStore.reload()
            displayName = profileStore.displayName
            avatarSymbol = profileStore.avatarSymbol
        }
        .confirmationDialog(
            "Delete local profile?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Local Profile", role: .destructive) {
                profileStore.deleteLocalProfile()
                dismiss()
            }

            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This removes the local profile from this device. It does not cancel or delete Apple purchases.")
        }
        .accessibilityIdentifier("hf.profile.manage.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Manage Profile")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            Text("Update your local HighFive Cinema profile.")
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textSecondary)
        }
    }

    private var profilePreview: some View {
        HStack(spacing: 14) {
            Image(systemName: avatarSymbol)
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(HFColors.gold)
                .frame(width: 76, height: 76)
                .background(Color.white.opacity(0.07), in: Circle())
                .overlay(Circle().stroke(HFColors.gold.opacity(0.25), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "HighFive Viewer" : displayName)
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(HFColors.textPrimary)
                    .lineLimit(1)

                Text("Local viewing profile")
                    .font(HFTypography.caption)
                    .foregroundStyle(HFColors.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var editCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Profile Name")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            TextField("HighFive Viewer", text: $displayName)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(14)
                .foregroundStyle(HFColors.textPrimary)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .accessibilityIdentifier("hf.profile.manage.nameField")
        }
        .padding(16)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var avatarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile Icon")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(avatarOptions, id: \.self) { symbol in
                    Button {
                        avatarSymbol = symbol
                    } label: {
                        Image(systemName: symbol)
                            .font(.system(size: 26, weight: .black))
                            .foregroundStyle(symbol == avatarSymbol ? .black : HFColors.gold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(symbol == avatarSymbol ? HFColors.gold : Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var saveButton: some View {
        Button {
            profileStore.save(displayName: displayName, avatarSymbol: avatarSymbol)
            dismiss()
        } label: {
            Text("Save Changes")
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(HFColors.goldGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("hf.profile.manage.save")
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Account & Purchases")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(HFColors.textPrimary)

            Text("This profile is local to this device. Purchases, restore access, and refunds are handled through Apple.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Deleting the local profile does not remove purchased access.")
                .font(HFTypography.caption)
                .foregroundStyle(HFColors.textSecondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirmation = true
        } label: {
            Text("Delete Local Profile")
                .font(.system(size: 15, weight: .black))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .accessibilityIdentifier("hf.profile.manage.deleteLocal")
    }
}
