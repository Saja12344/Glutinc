////
////  UserKit.swift
////  Glutinc
////
////  Created by Deemah Alhazmi on 01/12/2025.
////
//
//import SwiftUI
//import Combine
//import UIKit
//import PhotosUI
//import CloudKit
//
//struct UserModel {
//    var appleID: String = ""          // set after sign in
//    var name: String = "Jasmin"
//    var photo: UIImage? = nil
//    var savedImages: [String] = ["prod1","prod2"]
//    var notificationsEnabled: Bool = true
//}
//
//@MainActor
//final class UserVM: ObservableObject {
//    @Published var user = UserModel()
//    private let ck = CloudKitService()
//
//    // Call this once after Sign in (pass cred.user)
//    func setAppleID(_ id: String) async {
//        user.appleID = id
//        // try load profile from iCloud
//        if let profile = try? await ck.fetchUserProfile(by: id) {
//            user.name = profile.displayName
//            if let url = profile.photoAsset?.fileURL, let img = UIImage(contentsOfFile: url.path) {
//                user.photo = img
//            }
//        } else {
//            // first time: create a profile
//            _ = try? await ck.upsertUserProfile(UserProfile(appleID: id, displayName: user.name, email: nil))
//        }
//    }
//
//    func updateName(_ new: String) {
//        user.name = new.trimmingCharacters(in: .whitespacesAndNewlines)
//        Task { if !user.appleID.isEmpty { try? await ck.updateUserName(appleID: user.appleID, newName: user.name) } }
//    }
//
//    func updatePhoto(_ image: UIImage?) {
//        user.photo = image
//        Task { if !user.appleID.isEmpty { try? await ck.updateUserPhoto(appleID: user.appleID, image: image) } }
//    }
//    func logout() {
//          user = UserModel()   // تصفير كامل البيانات
//          print("✅ تم تسجيل الخروج")
//      }
//}
