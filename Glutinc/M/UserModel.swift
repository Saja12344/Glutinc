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
    var name: String = ""
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
    @Published var userRecordID: String?


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
//    var myPosts: [ProductModel] {
//        guard let userID = signedUser?.id else {
//            print("❌ signedUser nil – no posts")
//            return []
//        }
//
//        let filtered = products.filter { $0.ownerAppleID == userID }
//        print("📦 products:", products.count)
//        print("👤 myPosts:", filtered.count)
//
//        return filtered
//    }
 




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
    
//    var myPosts: [ProductModel] {
//        guard let userID = signedUser?.id else { return [] }
//        return products.filter { $0.ownerAppleID == userID }
//    }
    var myPosts: [ProductModel] {
        guard let ownerID = userRecordID else {
            print("❌ no userRecordID")
            return []
        }

        let filtered = products.filter { $0.ownerAppleID == ownerID }
        print("👤 ownerID:", ownerID)
        print("📦 myPosts:", filtered.count)


        return filtered
    }



    // MARK: - ✅ تسجيل الدخول بـ Apple + CloudKit

    func handleSignIn(result: Result<ASAuthorization, Error>) {

        switch result {

        case .success(let authResults):
            guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential else {
                return
            }

            let id = credential.user
            let appleName = credential.fullName?.givenName
            let email = credential.email ?? ""

            // 1️⃣ تحديث الواجهة فورًا
            self.signedUser = AppUser(
                id: id,
                name: appleName ?? "",
                email: email
            )

            self.user.appleID = id

            // تحميل المنتجات
            self.loadProductsFromCloud()
            self.hasLoadedProducts = true

            self.saveUserSession(user: self.signedUser!)

            // 2️⃣ التعامل مع CloudKit
            Task {
                do {
                    // نحاول نجيب البروفايل أولًا
                    if let existingProfile = try await ck.fetchUserProfile(by: id) {

                        // ✅ مستخدم قديم → نستخدم الاسم المخزن
                        await MainActor.run {
                            self.user.name = existingProfile.displayName
                            self.userRecordID = existingProfile.recordID?.recordName
                        }

                    } else {
                        // 🆕 مستخدم جديد → نستخدم اسم Apple (لو موجود)
                        let displayName = appleName ?? "User"

                        let profile = UserProfile(
                            appleID: id,
                            displayName: displayName,
                            email: email
                        )

                        try await ck.upsertUserProfile(profile)

                        await MainActor.run {
                            self.user.name = displayName
                            self.userRecordID = id
                        }
                    }



                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        print("❌ CloudKit error:", error.localizedDescription)
                    }
                }
            }

        case .failure(let error):
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                return
            }
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

            // ⬅️ مهم جدًا
            self.loadProductsFromCloud()
            self.hasLoadedProducts = true
            
            Task {
                if let profile = try? await ck.fetchUserProfile(by: id) {
                    self.user.appleID = id
                    self.user.name = profile.displayName
                    self.userRecordID = profile.recordID?.recordName   // ⭐ هنا كمان
                    print("♻️ session userRecordID:", self.userRecordID ?? "nil")
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

    // MARK: - ☁️ حذف المستخدم من CloudKit
    func deleteUserFromCloud() {

        guard let recordName = userRecordID else {
            print("❌ لا يوجد userRecordID")
            return
        }

        let recordID = CKRecord.ID(recordName: recordName)
        let database = CKContainer(identifier: "iCloud.com.sga.Glutinc")
            .privateCloudDatabase

        database.delete(withRecordID: recordID) { _, error in
            if let error = error {
                print("❌ فشل حذف المستخدم من CloudKit:", error.localizedDescription)
            } else {
                print("☁️ تم حذف المستخدم من CloudKit")
            }
        }
    }




    // MARK: - 🗑️ حذف الحساب
    func deleteAccount() {

        deleteUserFromCloud()

        signedUser = nil
        user = UserModel()
        userRecordID = nil

        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey)_name")
        UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey)_email")

        print("🗑️ تم حذف الحساب محليًا")
    }


    // MARK: - ✅ التقييم (بقي كما هو)
    func updateRating(to value: Int) {
        rating = value
    }
}
