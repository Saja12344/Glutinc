import Foundation

enum AppConfig {
    static let cloudKitContainerID = "iCloud.com.sga.Glutinc"
    static let bundleID = "com.sga.Glutinc"
    static let appDisplayNameEN = "Glutinc"
    static let appDisplayNameAR = "قلوتنك"
    static let developerNameEN = "Team 3 Apple Academy"
    static let developerNameAR = "تيم 3 آبل أكاديمي"
    static let supportEmail: String? = "glutinc.sa@gmail.com"
    static let privacyPolicyURL: URL? = URL(string: "https://saja12344.github.io/Glutinc/privacy.html")
    static let healthDisclaimerURL: URL? = URL(string: "https://saja12344.github.io/Glutinc/health.html")
    static let communityGuidelinesURL: URL? = URL(string: "https://saja12344.github.io/Glutinc/community.html")
    static let termsOfUseURL: URL? = nil
    static let supportURL: URL? = nil
    /// Apple user IDs allowed to open in-app moderation. Leave empty until assigned.
    static let adminAppleIDs: [String] = []
}

enum L10n {
    static var isArabic: Bool {
        Locale.preferredLanguages.first?.hasPrefix("ar") == true
            || Locale.current.language.languageCode?.identifier == "ar"
    }

    static func t(_ english: String, ar arabic: String) -> String {
        isArabic ? arabic : english
    }
}
