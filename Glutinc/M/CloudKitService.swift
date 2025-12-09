//
//  CloudKitService.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//

import CloudKit
import UIKit

final class CloudKitService {

    private let container: CKContainer
    private let db: CKDatabase

    init(container: CKContainer = .default()) {
        self.container = container
        self.db = container.publicCloudDatabase   // community data in Public DB
    }

    // MARK: - USER PROFILE

    /// Fetch a single profile by Apple ID (your own stored identifier).
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

    /// Ensure a profile exists for this appleID. Creates with default name if missing.
    @discardableResult
    func fetchOrCreateUser(appleID: String, defaultName: String = "New User", email: String? = nil) async throws -> UserProfile {
        if let exists = try await fetchUserProfile(by: appleID) { return exists }
        let created = try await upsertUserProfile(
            UserProfile(appleID: appleID, displayName: defaultName, email: email, photoAsset: nil)
        )
        return created
    }

    /// Update only the display name.
    func updateUserName(appleID: String, newName: String) async throws {
        guard var profile = try await fetchUserProfile(by: appleID) else {
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
        guard let image else { return }
        let asset = try makeAsset(from: image)

        guard var profile = try await fetchUserProfile(by: appleID) else {
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

    // MARK: - POSTS (Public DB, by authorRef)

    /// Most-recent posts (for feed). Uses creationDate DESC.
    func fetchRecentPosts(limit: Int = 25) async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CKSchema.post, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return try await runPostQuery(query: query, cursor: nil, limit: limit)
    }

    /// Continue feed pagination.
    func fetchRecentPosts(cursor: CKQueryOperation.Cursor, limit: Int = 25) async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        return try await runPostQuery(query: nil, cursor: cursor, limit: limit)
    }

    /// Posts authored by a specific user profile (for Profile -> Posts).
    func fetchPostsByAuthor(userProfileID: CKRecord.ID, limit: Int = 30) async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        let ref = CKRecord.Reference(recordID: userProfileID, action: .none)
        let predicate = NSPredicate(format: "%K == %@", CKSchema.PostKeys.authorRef, ref)
        let query = CKQuery(recordType: CKSchema.post, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: CKSchema.PostKeys.createdAt, ascending: false)]
        return try await runPostQuery(query: query, cursor: nil, limit: limit)
    }

    /// Create a new post. Sets authorRef + createdAt.
    func createPost(title: String, content: String, image: UIImage?, authorProfileID: CKRecord.ID) async throws {
        let record = CKRecord(recordType: CKSchema.post)
        record[CKSchema.PostKeys.title]     = title as CKRecordValue
        // you can still store content, even if CKPost doesn't use it
        record["content"]                   = content as CKRecordValue
        record[CKSchema.PostKeys.authorRef] = CKRecord.Reference(recordID: authorProfileID, action: .none)
        record[CKSchema.PostKeys.createdAt] = Date() as CKRecordValue

        if let image {
            let asset = try makeAsset(from: image)
            record[CKSchema.PostKeys.imageAsset] = asset
        }
        _ = try await db.save(record: record)
    }

    // MARK: - SAVED (Bookmarks)

    /// All saved posts for the user (Profile -> Saved).
    func fetchSavedPosts(for userProfileID: CKRecord.ID, limit: Int = 200) async throws -> [CKPost] {
        // 1) Find bookmarks for this user
        let uref = CKRecord.Reference(recordID: userProfileID, action: .none)
        let predicate = NSPredicate(format: "%K == %@", CKSchema.BookmarkKeys.userRef, uref)
        let query = CKQuery(recordType: CKSchema.bookmark, predicate: predicate)

        let (bookmarkRecords, _) = try await records(matching: query, limit: limit)
        let postIDs: [CKRecord.ID] = bookmarkRecords.compactMap {
            ($0[CKSchema.BookmarkKeys.postRef] as? CKRecord.Reference)?.recordID
        }
        if postIDs.isEmpty { return [] }

        // 2) Batch fetch posts, map to CKPost
        let fetchedRecords = try await db.fetchRecords(ids: postIDs)
        let posts: [CKPost] = fetchedRecords.map { CKPost(record: $0) }


        // 3) Sort by createdAt DESC
        return posts.sorted { $0.createdAt > $1.createdAt }
    }

    /// Save bookmark.
    func saveBookmark(userProfileID: CKRecord.ID, postID: CKRecord.ID) async throws {
        let rec = CKRecord(recordType: CKSchema.bookmark)
        rec[CKSchema.BookmarkKeys.userRef] = CKRecord.Reference(recordID: userProfileID, action: .none)
        rec[CKSchema.BookmarkKeys.postRef] = CKRecord.Reference(recordID: postID, action: .none)
        _ = try await db.save(record: rec)
    }

    /// Remove bookmark.
    func removeBookmark(userProfileID: CKRecord.ID, postID: CKRecord.ID) async throws {
        let pred = NSPredicate(format: "%K == %@ AND %K == %@",
                               CKSchema.BookmarkKeys.userRef, CKRecord.Reference(recordID: userProfileID, action: .none),
                               CKSchema.BookmarkKeys.postRef, CKRecord.Reference(recordID: postID, action: .none))
        let q = CKQuery(recordType: CKSchema.bookmark, predicate: pred)
        let (bookmarkRecords, _) = try await records(matching: q, limit: 10)
        for rec in bookmarkRecords {
            try await db.deleteAsync(recordID: rec.recordID)
        }
    }

    // MARK: - INTERNAL QUERY HELPERS

    /// Run a paged post query and map to CKPost.
    private func runPostQuery(query: CKQuery?, cursor: CKQueryOperation.Cursor?, limit: Int) async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        try await withCheckedThrowingContinuation { cont in
            let op: CKQueryOperation
            if let cursor {
                op = CKQueryOperation(cursor: cursor)
            } else if let query {
                op = CKQueryOperation(query: query)
            } else {
                return cont.resume(throwing: NSError(domain: "CloudKitService",
                                                     code: -1,
                                                     userInfo: [NSLocalizedDescriptionKey: "Invalid query parameters"]))
            }

            op.resultsLimit = limit
            var items: [CKPost] = []

            op.recordFetchedBlock = { record in
                items.append(CKPost(record: record))
            }

            op.queryResultBlock = { result in
                switch result {
                case .success(let next):
                    cont.resume(returning: (items, next))
                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }

            self.db.add(op)
        }
    }

    /// Generic helper to run a simple query and return all records (non-paged).
    private func records(matching query: CKQuery, limit: Int = 50) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        try await withCheckedThrowingContinuation { cont in
            let op = CKQueryOperation(query: query)
            op.resultsLimit = limit

            var items: [CKRecord] = []
            op.recordFetchedBlock = { items.append($0) }
            op.queryResultBlock = { result in
                switch result {
                case .success(let cursor):
                    cont.resume(returning: (items, cursor))
                case .failure(let err):
                    cont.resume(throwing: err)
                }
            }
            self.db.add(op)
        }
    }

    // MARK: - ASSET HELPER

    /// Save UIImage as JPEG to a temporary file and wrap in CKAsset.
    private func makeAsset(from image: UIImage) throws -> CKAsset {
        let data = image.jpegData(compressionQuality: 0.9) ?? Data()
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        try data.write(to: url, options: .atomic)
        return CKAsset(fileURL: url)
    }
}

// MARK: - CKDatabase async conveniences

private extension CKDatabase {
    func save(record: CKRecord) async throws -> CKRecord {
        try await withCheckedThrowingContinuation { cont in
            self.save(record) { saved, error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: saved!) }
            }
        }
    }

    func deleteRecord(withID id: CKRecord.ID) async throws {
        try await withCheckedThrowingContinuation { cont in
            self.delete(withRecordID: id) { _, error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: ()) }
            }
        }
    }
}
