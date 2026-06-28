import SwiftUI

struct HFSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search movies, shows, creators"

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(HFIconography.symbolFont(size: HFIconography.controlIconSize, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(HFColors.gold)
                .frame(width: HFIconography.menuIconFrame)

            TextField(placeholder, text: $text)
                .font(HFTypography.body)
                .foregroundStyle(HFColors.textPrimary)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(HFIconography.symbolFont(size: HFIconography.actionIconSize, weight: .bold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(HFColors.textMuted)
                        .frame(width: HFIconography.actionIconFrame, height: HFIconography.actionIconFrame)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HFSpacing.md)
        .frame(height: HFSpacing.searchBarHeight)
        .background(HFColors.surface.opacity(0.94))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.glassStroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
