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
    @Published var blockedUserIDs: Set<String> = []
    @Published var savedProductIDs: Set<String> = []
    @Published var isDeletingAccount = false
    @Published var reports: [ModerationReport] = []
    @Published var pendingAuthAction: AuthGatedAction?

    enum AuthGatedAction: Equatable {
        case save(productID: String)
        case post
        case report
        case none
    }

    var isSignedIn: Bool { signedUser != nil }

    var visibleProducts: [ProductModel] {
        products.filter { !blockedUserIDs.contains($0.ownerAppleID) && $0.ownerAppleID != "deleted" }
    }

    var exploreProducts: [ProductModel] {
        visibleProducts.filter(\.isEligibleForExplore)
    }

    var isAdmin: Bool {
        guard let id = signedUser?.id else { return false }
        return AppConfig.adminAppleIDs.contains(id)
    }

    var savedProducts: [ProductModel] {
        visibleProducts.filter { savedProductIDs.contains($0.id) }
    }


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
            if !fetched.isEmpty {
                self.products = fetched
            }
        }
    }

    func loadExploreProducts() {
        ck.fetchExploreProducts { fetched in
            let blocked = self.blockedUserIDs
            let explore = fetched.filter { !blocked.contains($0.ownerAppleID) }
            let others = self.products.filter { !$0.isEligibleForExplore }
            var merged = explore
            for item in others where !merged.contains(where: { $0.id == item.id }) {
                merged.append(item)
            }
            self.products = merged
            self.hasLoadedProducts = true
        }
    }

    func submitCatalogProduct(_ product: ProductModel, completion: @escaping (Bool, String?) -> Void) {
        if let existing = ProductValidator.existingMatch(
            barcode: product.barcode,
            name: product.productName,
            in: products
        ) {
            completion(false, L10n.t(
                "This product already exists. Opening the existing listing instead of creating a duplicate.",
                ar: "هذا المنتج موجود مسبقًا. سيتم استخدام السجل الحالي بدل إنشاء نسخة مكررة."
            ))
            return
        }
        ck.saveProduct(product) { success in
            if success {
                self.products.insert(product, at: 0)
            }
            completion(success, nil)
        }
    }

    func moderateProduct(
        _ product: ProductModel,
        verification: VerificationStatus,
        gluten: GlutenAnalysisStatus? = nil,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        guard let recordName = product.recordName else {
            completion(false)
            return
        }
        ck.updateProductVerification(
            recordName: recordName,
            status: verification,
            gluten: gluten,
            verifiedBy: signedUser?.id
        ) { ok in
            if ok, let index = self.products.firstIndex(where: { $0.id == product.id }) {
                self.products[index].verificationStatusRaw = verification.rawValue
                self.products[index].verifiedBy = self.signedUser?.id
                self.products[index].lastVerifiedAt = Date()
                if let gluten {
                    self.products[index].glutenAnalysisStatusRaw = gluten.rawValue
                }
            }
            completion(ok)
        }
    }

    func refreshReports() {
        ck.fetchReports { reports in
            self.reports = reports
        }
    }

    func setReportStatus(_ report: ModerationReport, status: String, completion: @escaping (Bool) -> Void) {
        ck.updateReportStatus(recordName: report.recordName, status: status, reviewer: signedUser?.id ?? "admin") { ok in
            if ok { self.refreshReports() }
            completion(ok)
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

            self.loadProductsFromCloud()
            self.hasLoadedProducts = true
            self.loadModerationState()
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

            self.loadProductsFromCloud()
            self.hasLoadedProducts = true
            self.loadModerationState()
            
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
        userRecordID = nil
        blockedUserIDs = []
        savedProductIDs = []
        pendingAuthAction = nil

        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey)_name")
        UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey)_email")
    }

    func loadModerationState() {
        guard isSignedIn else { return }
        ck.fetchBlockedUserIDs { ids in
            self.blockedUserIDs = Set(ids)
        }
        ck.fetchSavedProductIDs { ids in
            self.savedProductIDs = Set(ids)
        }
    }

    @discardableResult
    func requireSignIn(for action: AuthGatedAction) -> Bool {
        if isSignedIn { return true }
        pendingAuthAction = action
        return false
    }

    func toggleSave(productID: String) {
        guard requireSignIn(for: .save(productID: productID)) else { return }
        if savedProductIDs.contains(productID) {
            savedProductIDs.remove(productID)
            ck.removeBookmark(productID: productID) { _ in }
        } else {
            savedProductIDs.insert(productID)
            ck.saveBookmark(productID: productID) { _ in }
        }
    }

    func isSaved(_ productID: String) -> Bool {
        savedProductIDs.contains(productID)
    }

    func reportContent(_ draft: ContentReportDraft, completion: @escaping (Bool) -> Void) {
        guard requireSignIn(for: .report) else {
            completion(false)
            return
        }
        ck.saveReport(draft, completion: completion)
    }

    func reportIncorrectProduct(
        productID: String,
        reason: ProductCorrectionReason,
        details: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let reporter = signedUser?.id ?? userRecordID else {
            pendingAuthAction = .report
            completion(false)
            return
        }
        ck.saveProductCorrection(
            productID: productID,
            reporterUserId: reporter,
            reason: reason,
            details: details,
            completion: completion
        )
    }

    func blockUser(userId: String) {
        guard isSignedIn, !userId.isEmpty, userId != signedUser?.id else { return }
        blockedUserIDs.insert(userId)
        ck.blockUser(blockedUserId: userId) { _ in }
    }

    // MARK: - 🗑️ حذف الحساب
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        guard let appleID = signedUser?.id ?? (user.appleID.isEmpty ? nil : user.appleID) else {
            logout()
            completion(true)
            return
        }

        isDeletingAccount = true
        ck.anonymizeProducts(ownerAppleID: appleID) { _ in
            Task {
                await self.ck.deleteAllPrivateRecords(ofType: "SavedProduct")
                await self.ck.deleteAllPrivateRecords(ofType: "BlockedUser")
                self.ck.deleteUserProfile(appleID: appleID) { _ in
                    self.isDeletingAccount = false
                    self.logout()
                    completion(true)
                }
            }
        }
    }


    // MARK: - ✅ التقييم (بقي كما هو)
    func updateRating(to value: Int) {
        rating = value
    }
}
