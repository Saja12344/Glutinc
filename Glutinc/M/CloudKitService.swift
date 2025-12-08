//
//  CloudKitService.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//
//  CloudKitService.swift
//  Glutinc22
//

import CloudKit
import UIKit

final class CloudKitService {

    private let container: CKContainer
    private let db: CKDatabase

    init(container: CKContainer = .default()) {
        self.container = container
        self.db = container.publicCloudDatabase   // use the Public DB for community
    }

    // MARK: - User Profile

    /// Fetch a single profile by Apple ID (credential.user).
    func fetchUserProfile(by appleID: String) async throws -> UserProfile? {
        let predicate = NSPredicate(format: "%K == %@", CKSchema.UserKeys.appleID, appleID)
        let query = CKQuery(recordType: CKSchema.userProfile, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

        return try await withCheckedThrowingContinuation { cont in
            db.perform(query, inZoneWith: nil) { records, error in
                if let error { return cont.resume(throwing: error) }
                guard let rec = records?.first else { return cont.resume(returning: nil) }
                cont.resume(returning: UserProfile(record: rec))
            }
        }
    }

    /// Create or update a profile (upsert).
    @discardableResult
    func upsertUserProfile(_ profile: UserProfile) async throws -> UserProfile {
        let record = profile.toRecord()
        let saved = try await db.save(record: record)
        return UserProfile(record: saved)
    }

    /// Update only the display name.
    func updateUserName(appleID: String, newName: String) async throws {
        guard var profile = try await fetchUserProfile(by: appleID) else {
            // no record yet — create it
            _ = try await upsertUserProfile(UserProfile(appleID: appleID, displayName: newName))
            return
        }
        var rec = profile.toRecord()
        rec[CKSchema.UserKeys.displayName] = newName as CKRecordValue
        let saved = try await db.save(record: rec)
        profile = UserProfile(record: saved)
    }

    /// Update only the profile photo.
    func updateUserPhoto(appleID: String, image: UIImage?) async throws {
        guard let image else { return }  // nothing to save

        // 1) Convert to CKAsset
        let asset = try makeAsset(from: image)

        // 2) Fetch record and update
        guard var profile = try await fetchUserProfile(by: appleID) else {
            // create a new record with photo if missing
            _ = try await upsertUserProfile(UserProfile(appleID: appleID,
                                                        displayName: "",
                                                        email: nil,
                                                        photoAsset: asset))
            return
        }
        var rec = profile.toRecord()
        rec[CKSchema.UserKeys.photoAsset] = asset
        let saved = try await db.save(record: rec)
        profile = UserProfile(record: saved)
    }

    // MARK: - Helpers

    /// Save UIImage as JPEG to a temporary file and wrap in CKAsset.
    private func makeAsset(from image: UIImage) throws -> CKAsset {
        let data = image.jpegData(compressionQuality: 0.9) ?? Data()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        try data.write(to: url, options: .atomic)
        return CKAsset(fileURL: url)
    }
}

// MARK: - CKDatabase async save convenience

private extension CKDatabase {
    func save(record: CKRecord) async throws -> CKRecord {
        try await withCheckedThrowingContinuation { cont in
            self.save(record) { saved, error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: saved!) }
            }
        }
    }
}
