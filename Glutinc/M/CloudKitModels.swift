//
//  CloudKitModels.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//

import CloudKit
import UIKit

// MARK: - CloudKit Schema (record types & keys)
enum CKSchema {
    // User
    static let userProfile = "UserProfile"
    enum UserKeys {
        static let appleID      = "appleID"        // String
        static let displayName  = "displayName"    // String
        static let email        = "email"          // String? (optional)
        static let photoAsset   = "photoAsset"     // CKAsset? (optional)
    }

    // Post (user-created content shown on Profile -> Posts)
    static let post = "Post"
    enum PostKeys {
        static let title        = "title"          // String
        static let imageAsset   = "image"          // CKAsset? (optional)
        static let authorRef    = "authorRef"      // CKReference -> UserProfile
        static let createdAt    = "createdAt"      // Date
    }

    // Bookmark (Saved posts)
    static let bookmark = "Bookmark"
    enum BookmarkKeys {
        static let userRef      = "userRef"        // CKReference -> UserProfile
        static let postRef      = "postRef"        // CKReference -> Post
    }
}

// MARK: - Helpers
extension CKAsset {
    var uiImage: UIImage? {
        guard let url = fileURL else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

// MARK: - UserProfile (your existing model)
struct UserProfile {
    var recordID: CKRecord.ID?
    var appleID: String
    var displayName: String
    var email: String?
    var photoAsset: CKAsset?

    // Convenience: easy access to UIImage for UI
    var photoImage: UIImage? { photoAsset?.uiImage }

    init(record: CKRecord) {
        self.recordID    = record.recordID
        self.appleID     = record[CKSchema.UserKeys.appleID] as? String ?? ""
        self.displayName = record[CKSchema.UserKeys.displayName] as? String ?? ""
        self.email       = record[CKSchema.UserKeys.email] as? String
        self.photoAsset  = record[CKSchema.UserKeys.photoAsset] as? CKAsset
    }

    init(appleID: String, displayName: String, email: String? = nil, photoAsset: CKAsset? = nil) {
        self.recordID    = nil
        self.appleID     = appleID
        self.displayName = displayName
        self.email       = email
        self.photoAsset  = photoAsset
    }

    func toRecord(in zoneID: CKRecordZone.ID? = nil) -> CKRecord {
        let record: CKRecord
        if let id = recordID {
            record = CKRecord(recordType: CKSchema.userProfile, recordID: id)
        } else if let zoneID {
            record = CKRecord(recordType: CKSchema.userProfile, zoneID: zoneID)
        } else {
            record = CKRecord(recordType: CKSchema.userProfile)
        }

        record[CKSchema.UserKeys.appleID]     = appleID as CKRecordValue
        record[CKSchema.UserKeys.displayName] = displayName as CKRecordValue
        if let email { record[CKSchema.UserKeys.email] = email as CKRecordValue }
        if let photoAsset { record[CKSchema.UserKeys.photoAsset] = photoAsset }
        return record
    }
}

// MARK: - Bridge model used by the UI (ProfileView)
struct CKUserModel: Identifiable, Hashable {
    let id: CKRecord.ID
    var name: String
    var photo: UIImage?

    // Build from your existing UserProfile so the VM/Views stay simple
    init(from profile: UserProfile) {
        self.id    = profile.recordID ?? CKRecord.ID(recordName: "temp-user")
        self.name  = profile.displayName
        self.photo = profile.photoImage
    }
}
/*
// MARK: - Post model for grid rendering
struct CKPost: Identifiable, Hashable {
    let id: CKRecord.ID
    var title: String
    var image: UIImage?
    var createdAt: Date

    init(record: CKRecord) {
        self.id        = record.recordID
        self.title     = record[CKSchema.PostKeys.title] as? String ?? ""
        self.image     = (record[CKSchema.PostKeys.imageAsset] as? CKAsset)?.uiImage
        self.createdAt = (record[CKSchema.PostKeys.createdAt] as? Date)
            ?? record.creationDate
            ?? .distantPast
    }
}
*/
