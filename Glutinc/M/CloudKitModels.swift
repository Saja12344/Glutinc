//
//  CloudKitModels.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//

import Foundation
import CloudKit
import UIKit

enum CKTypes {
    static let userProfile = "UserProfile"
    static let post        = "Post"
}

enum CKDB {
    static let container = CKContainer.default()
    static let publicDB  = container.publicCloudDatabase
    static let privateDB = container.privateCloudDatabase
}

// MARK: - UserProfile
struct UserProfile {
    var recordID: CKRecord.ID?
    var appleID: String             // from Sign in with Apple credential.user
    var displayName: String
    var email: String?
    var photoAsset: CKAsset?

    init(appleID: String, displayName: String, email: String?) {
        self.appleID = appleID
        self.displayName = displayName
        self.email = email
    }

    init?(record: CKRecord) {
        guard record.recordType == CKTypes.userProfile else { return nil }
        recordID    = record.recordID
        appleID     = record["appleID"] as? String ?? ""
        displayName = record["displayName"] as? String ?? ""
        email       = record["email"] as? String
        photoAsset  = record["photo"] as? CKAsset
    }

    func toRecord(existing: CKRecord? = nil) -> CKRecord {
        let r = existing ?? CKRecord(recordType: CKTypes.userProfile)
        r["appleID"]     = appleID as CKRecordValue
        r["displayName"] = displayName as CKRecordValue
        if let email { r["email"] = email as CKRecordValue }
        if let photoAsset { r["photo"] = photoAsset }
        return r
    }
}

// MARK: - Post (community in Public DB)
/*struct CKPost {
    var recordID: CKRecord.ID?
    var text: String
    var imageAsset: CKAsset?
    var createdAt: Date

    init(text: String, imageAsset: CKAsset? = nil, createdAt: Date = Date()) {
        self.text = text
        self.imageAsset = imageAsset
        self.createdAt = createdAt
    }

    init?(record: CKRecord) {
        guard record.recordType == CKTypes.post else { return nil }
        recordID   = record.recordID
        text       = record["text"] as? String ?? ""
        imageAsset = record["image"] as? CKAsset
        createdAt  = record["createdAt"] as? Date ?? Date()
    }

    func toRecord(existing: CKRecord? = nil) -> CKRecord {
        let r = existing ?? CKRecord(recordType: CKTypes.post)
        r["text"]      = text as CKRecordValue
        r["createdAt"] = createdAt as CKRecordValue
        if let imageAsset { r["image"] = imageAsset }
        return r
    }
}*/
