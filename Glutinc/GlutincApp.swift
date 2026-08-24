import SwiftUI

@main
struct GlutincApp: App {
    @StateObject var cloudVM = UserCloudVM()

    var body: some Scene {
        WindowGroup {
            Splash()
                .environmentObject(cloudVM)
                .preferredColorScheme(.dark)
                .tint(AppColors.teal)
        }
    }
}
