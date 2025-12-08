//
//  SignandpostMV.swift
//  Glutinc22
//
//  Created by Norah Masoud Aloqayli on 17/06/1447 AH.
//

import Combine
import AuthenticationServices
import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String = ""
    @Published var rating: Int = 0
    @Published var selectedCategory: String = ""
    @Published var categories = ["Others"," Meat& Alternatives","Drinks", "Grains & Flours ","Dairy"]
    
    private let userDefaultsKey = "loggedInUserId"

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

               DispatchQueue.main.async {
                    self.user = User(id: id, name: name, email: email)
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
          }
      }
    
    func updateRating(to value: Int) {
            rating = value
        }
    
}

