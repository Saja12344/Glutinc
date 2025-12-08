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

class SignInViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String = ""
    @Published var rating: Int = 0
    @Published var selectedCategory: String = ""
    @Published var categories = ["Others"," Meat& Alternatives","Drinks", "Grains & Flours ","Dairy"]
    
    private let userDefaultsKey = "loggedInUserId"
    private let ck = CloudKitService()   // ⬅️ NEW: service that talks to CloudKit

    init() {
        loadUserSession()
    }

    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {

                let id = credential.user
                let name = credential.fullName?.givenName ?? ""
                let email = credential.email ?? ""

                // ⬅️ NEW: upsert profile in iCloud, then save local session
                Task {
                    do {
                        // Create or update the user profile in the **Private** CloudKit database
                        let profile = UserProfile(appleID: id, displayName: name, email: email)
                        _ = try await ck.upsertUserProfile(profile)

                        // Update UI + persist session on main thread
                        await MainActor.run {
                            let u = User(id: id, name: name, email: email)
                            self.user = u
                            self.saveUserSession(user: u)
                        }
                    } catch {
                        await MainActor.run { self.errorMessage = error.localizedDescription }
                    }
                }
            }

        case .failure(let error):
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func saveUserSession(user: User) {
        UserDefaults.standard.set(user.id, forKey: userDefaultsKey)
        UserDefaults.standard.set(user.name, forKey: "\(userDefaultsKey)_name")
        UserDefaults.standard.set(user.email, forKey: "\(userDefaultsKey)_email")
    }

    // استرجاع بيانات الجلسة عند بدء التطبيق
    private func loadUserSession() {
        if let id = UserDefaults.standard.string(forKey: userDefaultsKey),
           let name = UserDefaults.standard.string(forKey: "\(userDefaultsKey)_name"),
           let email = UserDefaults.standard.string(forKey: "\(userDefaultsKey)_email") {
            self.user = User(id: id, name: name, email: email)

            // ⬅️ OPTIONAL refresh from CloudKit (gets latest displayName if changed elsewhere)
            Task {
                if let profile = try? await ck.fetchUserProfile(by: id) {
                    await MainActor.run {
                        self.user = User(id: id,
                                         name: profile.displayName,
                                         email: email.isEmpty ? (profile.email ?? "") : email)
                    }
                }
            }
        }
    }
    
    func updateRating(to value: Int) {
        rating = value
    }
}
