import SwiftUI

struct PrivacyView: View {

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Privacy Policy")
                        .font(.title2)
                        .bold()

                    Text("""
Your privacy matters to us.

This app does not sell your data.
We only store necessary information to provide the service.

More details will be added soon.
""")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
