//
//  CloudKitModels.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//
//
//  CloudKitModels.swift
//  Glutinc22
//

import CloudKit
import UIKit

/// Record type names & keys in CloudKit
enum CKSchema {
    static let userProfile = "UserProfile"

    enum UserKeys {
        static let appleID      = "appleID"        // String
        static let displayName  = "displayName"    // String
        static let email        = "email"          // String? (optional)
        static let photoAsset   = "photoAsset"     // CKAsset? (optional)
    }
}

/// Lightweight model that we map to/from CKRecord
struct UserProfile {
    var recordID: CKRecord.ID?
    var appleID: String
    var displayName: String
    var email: String?
    var photoAsset: CKAsset?

    init(record: CKRecord) {
        self.recordID   = record.recordID
        self.appleID    = record[CKSchema.UserKeys.appleID] as? String ?? ""
        self.displayName = record[CKSchema.UserKeys.displayName] as? String ?? ""
        self.email      = record[CKSchema.UserKeys.email] as? String
        self.photoAsset = record[CKSchema.UserKeys.photoAsset] as? CKAsset
    }

    init(appleID: String, displayName: String, email: String? = nil, photoAsset: CKAsset? = nil) {
        self.recordID = nil
        self.appleID = appleID
        self.displayName = displayName
        self.email = email
        self.photoAsset = photoAsset
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
