import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            AppColors.navy.ignoresSafeArea()

            LinearGradient(
                colors: [
                    AppColors.teal.opacity(0.22),
                    AppColors.navy.opacity(0)
                ],
                startPoint: .topTrailing,
                endPoint: .center
            )
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
    }
}
