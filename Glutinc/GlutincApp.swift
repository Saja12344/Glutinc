import SwiftUI

@main
struct GlutincApp: App {
    @StateObject var cloudVM = UserCloudVM()
    @ObservedObject var languageStore = LanguageStore.shared

    var body: some Scene {
        WindowGroup {
            Splash()
                .environmentObject(cloudVM)
                .environmentObject(languageStore)
                .environment(\.locale, languageStore.locale)
                .environment(\.layoutDirection, languageStore.layoutDirection)
                .id(languageStore.code)
                .preferredColorScheme(.dark)
                .tint(AppColors.teal)
        }
    }
}
