import SwiftUI

struct HFLegalTextSheet: View {
    let title: String
    let version: String
    let text: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Version \(version)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(HFColors.gold)

                    Text(text)
                        .font(.system(size: 14))
                        .lineSpacing(4)
                        .foregroundStyle(.white.opacity(0.84))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(22)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(HFColors.gold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("hf.legal.textSheet")
    }
}
