import SwiftUI

struct HFSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search movies, shows, creators"

    var body: some View {
        HStack(spacing: HFSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(HFColors.gold)

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
                        .foregroundStyle(HFColors.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, HFSpacing.md)
        .frame(height: 52)
        .background(HFColors.charcoal.opacity(0.92))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(HFColors.stroke, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
