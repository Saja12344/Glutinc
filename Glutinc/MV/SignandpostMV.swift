//
//  SignandpostMV.swift
//  Glutinc22
//
//  Created by Norah Masoud Aloqayli on 17/06/1447 AH.
//

import Combine
import AuthenticationServices
import SwiftUI
import CloudKit   // ⬅️ NEW: CloudKit for iCloud database

@MainActor
final class SignInViewModel: ObservableObject {

    @Published var user: UserProfile?
    @Published var errorMessage: String = ""
    @Published var rating: Int = 0
    @Published var selectedCategory: String = ""
    @Published var categories = ["Others","Meat & Alternatives","Drinks", "Grains & Flours","Dairy"]

    private let userDefaultsKey = "loggedInUserId"
    private let ck = CloudKitService()

    init() {
        loadUserSession()
    }

    // ✅ تسجيل الدخول بـ Apple
    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {

        case .success(let authResults):
            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else { return }

            let id = credential.user
            let name = credential.fullName?.givenName ?? ""
            let email = credential.email ?? ""

            Task {
                do {
                    // ✅ إنشاء / تحديث البروفايل في CloudKit
                    let profile = UserProfile(
                        appleID: id,
                        displayName: name,
                        email: email
                    )

                    try await ck.upsertUserProfile(profile)

                    // ✅ تحديث الواجهة + حفظ الجلسة
                    self.user = profile
                    self.saveUserSession(user: profile)

                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }

        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    // ✅ حفظ الجلسة
    private func saveUserSession(user: UserProfile) {
        UserDefaults.standard.set(user.appleID, forKey: userDefaultsKey)
        UserDefaults.standard.set(user.displayName, forKey: "\(userDefaultsKey)_name")
        UserDefaults.standard.set(user.email, forKey: "\(userDefaultsKey)_email")
    }

    // ✅ استرجاع الجلسة
    private func loadUserSession() {
        if let id = UserDefaults.standard.string(forKey: userDefaultsKey),
           let name = UserDefaults.standard.string(forKey: "\(userDefaultsKey)_name"),
           let email = UserDefaults.standard.string(forKey: "\(userDefaultsKey)_email") {

            self.user = UserProfile(
                appleID: id,
                displayName: name,
                email: email
            )
        }
    }
}
