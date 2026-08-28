import SwiftUI

struct Splash: View {
    @EnvironmentObject var cloudVM: UserCloudVM
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isActive = false
    @State private var logoProgress: CGFloat = 0
    @State private var wordReveal: CGFloat = 0

    private let logoFinal: CGFloat = 78
    private let logoStart: CGFloat = 168
    private let wordHeight: CGFloat = 36
    private let wordAspect: CGFloat = 738 / 224
    private let lockupSpacing: CGFloat = 4

    var body: some View {
        Group {
            if isActive {
                MainTabContainer()
                    .environmentObject(cloudVM)
            } else {
                ZStack {
                    BackgroundView()
                    lockup
                }
                .task { await playSplash() }
            }
        }
    }

    private var wordWidth: CGFloat { wordHeight * wordAspect }

    private var lockup: some View {
        GeometryReader { geo in
            let logoSize = logoStart + (logoFinal - logoStart) * logoProgress
            let lockupWidth = logoFinal + lockupSpacing + wordWidth
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let lockupLogoX = centerX - lockupWidth / 2 + logoFinal / 2
            let logoX = centerX + (lockupLogoX - centerX) * logoProgress
            let wordX = lockupLogoX + logoFinal / 2 + lockupSpacing + wordWidth / 2

            ZStack {
                Image("logo-mark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: logoSize, height: logoSize)
                    .position(x: logoX, y: centerY)
                    .flipsForRightToLeftLayoutDirection(false)

                Image("GlutincWordmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: wordWidth, height: wordHeight)
                    .mask { SoftRevealMask(progress: wordReveal) }
                    .opacity(wordReveal > 0.001 ? 1 : 0)
                    .position(x: wordX, y: centerY)
                    .flipsForRightToLeftLayoutDirection(false)
            }
            .environment(\.layoutDirection, .leftToRight)
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    @MainActor
    private func playSplash() async {
        if reduceMotion {
            logoProgress = 1
            wordReveal = 1
            try? await Task.sleep(for: .milliseconds(800))
            withAnimation(.easeInOut(duration: 0.4)) {
                isActive = true
            }
            return
        }

        try? await Task.sleep(for: .milliseconds(550))
        withAnimation(.easeInOut(duration: 0.7)) {
            logoProgress = 1
        }
        try? await Task.sleep(for: .milliseconds(700))
        withAnimation(.easeInOut(duration: 1.3)) {
            wordReveal = 1
        }
        try? await Task.sleep(for: .milliseconds(1300))
        try? await Task.sleep(for: .milliseconds(400))
        withAnimation(.easeInOut(duration: 0.45)) {
            isActive = true
        }
    }
}

private struct SoftRevealMask: View {
    var progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            let feather = min(28, geo.size.width * 0.12)
            let lead = max(progress * (geo.size.width + feather), 0.001)

            LinearGradient(
                stops: [
                    .init(color: .white, location: 0),
                    .init(color: .white, location: max(0, (lead - feather) / lead)),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: lead, height: geo.size.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}
