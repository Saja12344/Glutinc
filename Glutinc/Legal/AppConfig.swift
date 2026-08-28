import Foundation
import SwiftUI
import Combine

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

final class LanguageStore: ObservableObject {
    static let shared = LanguageStore()
    private static let key = "glutinc.language"

    /// `"ar"`, `"en"`, or `"system"`.
    @Published var code: String {
        didSet { UserDefaults.standard.set(code, forKey: Self.key) }
    }

    var isArabic: Bool {
        if code == "ar" { return true }
        if code == "en" { return false }
        return Locale.preferredLanguages.first?.hasPrefix("ar") == true
            || Locale.current.language.languageCode?.identifier == "ar"
    }

    var locale: Locale {
        Locale(identifier: isArabic ? "ar" : "en")
    }

    var layoutDirection: LayoutDirection {
        isArabic ? .rightToLeft : .leftToRight
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.key)
        code = stored ?? "ar"
    }
}

enum L10n {
    static var isArabic: Bool {
        LanguageStore.shared.isArabic
    }

    static func t(_ english: String, ar arabic: String) -> String {
        isArabic ? arabic : english
    }
}
