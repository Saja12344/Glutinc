//
//  UserModel.swift
//  Glutinc
//
//  Created by saja khalid on 17/06/1447 AH.
//


import SwiftUI
import Combine
import UIKit
import PhotosUI
import CloudKit
import AuthenticationServices

// ✅ نفس موديلك تمامًا
struct UserModel {
    var appleID: String = ""
    var name: String = "Jasmin"
    var photo: UIImage? = nil
    var savedImages: [String] = ["prod1","prod2"]
    var notificationsEnabled: Bool = true
}

// ✅ موديل تسجيل الدخول (نفس اللي عندك)
struct AppUser {
    let id: String
    let name: String
    let email: String
}

@MainActor
final class UserCloudVM: ObservableObject {

    // ✅ نفس المتغيرات اللي كنتِ تستخدمينها
    @Published var user = UserModel()
    @Published var signedUser: AppUser?
    @Published var errorMessage: String = ""
    @Published var rating: Int = 0
    @Published var selectedCategory: String = ""
    @Published var categories = ["Others","Meat& Alternatives","Drinks", "Grains & Flours","Dairy"]
    @Published var products: [ProductModel] = []
    @Published var hasLoadedProducts = false


    private let userDefaultsKey = "loggedInUserId"
    private let ck = CloudKitService()

    // ✅ عند تشغيل التطبيق
    init() {
        loadUserSession()
        CKContainer(identifier: "iCloud.com.sga.Glutinc").accountStatus { status, error in
               DispatchQueue.main.async {
                   print("☁️ iCloud status:", status.rawValue)

                   if let error = error {
                       print("☁️ iCloud error:", error.localizedDescription)
                   }
               }
           }
       }

    func uploadProduct(_ product: ProductModel, completion: @escaping (Bool) -> Void) {

        ck.saveProduct(product) { success in
            if success {
                self.products.insert(product, at: 0)
                print("📌 Products count:", self.products.count)
            }
            completion(success)
        }
    }

    func loadProductsFromCloud() {
        ck.fetchProducts { fetched in
            print("📥 Cloud fetch count:", fetched.count)

            if !fetched.isEmpty {
                self.products = fetched
            } else {
                print("⚠️ Fetch returned 0 – keeping existing data")
            }
        }
    }

    // MARK: - ✅ تسجيل الدخول بـ Apple + CloudKit
    func handleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {

        case .success(let authResults):
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {

                let id = credential.user
                let name = credential.fullName?.givenName ?? ""
                let email = credential.email ?? ""

                Task {
                    do {
                        // ✅ إنشاء / تحديث البروفايل في iCloud
                        let profile = UserProfile(
                            appleID: id,
                            displayName: name,
                            email: email
                        )
                        _ = try await ck.upsertUserProfile(profile)

                        // ✅ تحديث الواجهة
                        let u = AppUser(id: id, name: name, email: email)
                        self.signedUser = u
                        self.saveUserSession(user: u)

                        // ✅ ربط الدخول بالبروفايل الداخلي
                        await self.setAppleID(id)

                    } catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }

        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - ✅ ربط Apple ID بالبروفايل
    func setAppleID(_ id: String) async {
        user.appleID = id

        if let profile = try? await ck.fetchUserProfile(by: id) {
            user.name = profile.displayName

            if let url = profile.photoAsset?.fileURL,
               let img = UIImage(contentsOfFile: url.path) {
                user.photo = img
            }
        } else {
            // أول مرة: إنشاء بروفايل
            _ = try? await ck.upsertUserProfile(
                UserProfile(
                    appleID: id,
                    displayName: user.name,
                    email: nil
                )
            )
        }
    }

    // MARK: - ✅ تعديل الاسم + رفعه للكلاود
    func updateName(_ new: String) {
        user.name = new.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            if !user.appleID.isEmpty {
                try? await ck.updateUserName(
                    appleID: user.appleID,
                    newName: user.name
                )
            }
        }
    }

    // MARK: - ✅ تعديل الصورة + رفعها للكلاود
    func updatePhoto(_ image: UIImage?) {
        user.photo = image

        Task {
            if !user.appleID.isEmpty {
                try? await ck.updateUserPhoto(
                    appleID: user.appleID,
                    image: image
                )
            }
        }
    }

    // MARK: - ✅ حفظ الجلسة محليًا
    private func saveUserSession(user: AppUser) {
        UserDefaults.standard.set(user.id, forKey: userDefaultsKey)
        UserDefaults.standard.set(user.name, forKey: "\(userDefaultsKey)_name")
        UserDefaults.standard.set(user.email, forKey: "\(userDefaultsKey)_email")
    }

    // MARK: - ✅ استرجاع الجلسة تلقائيًا
    private func loadUserSession() {
        if let id = UserDefaults.standard.string(forKey: userDefaultsKey),
           let name = UserDefaults.standard.string(forKey: "\(userDefaultsKey)_name"),
           let email = UserDefaults.standard.string(forKey: "\(userDefaultsKey)_email") {

            self.signedUser = AppUser(id: id, name: name, email: email)

            Task {
                if let profile = try? await ck.fetchUserProfile(by: id) {
                    self.user.appleID = id
                    self.user.name = profile.displayName
                }
            }
        }
    }

    // MARK: - ✅ تسجيل الخروج
    func logout() {
        signedUser = nil
        user = UserModel()

        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey)_name")
        UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey)_email")

        print("✅ تم تسجيل الخروج ومسح الجلسة")
    }

    // MARK: - ✅ التقييم (بقي كما هو)
    func updateRating(to value: Int) {
        rating = value
    }
}
