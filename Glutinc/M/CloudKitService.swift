//
//  CloudKitService.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//
//
//  CloudKitService.swift
//  Glutinc22
//

import CloudKit
import UIKit

final class CloudKitService {

    private let publicDB = CKContainer.default().publicCloudDatabase

    // MARK: - ✅ POSTS (كما هو عندك)

    func fetchRecentPosts() async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        let query = CKQuery(recordType: "Post", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        var items: [CKPost] = []
        let (results, cursor) = try await publicDB.records(matching: query)

        for (_, result) in results {
            if case let .success(record) = result,
               let p = CKPost(record: record) {
                items.append(p)
            }
        }
        return (items, cursor)
    }

    func fetchRecentPosts(cursor: CKQueryOperation.Cursor) async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        var items: [CKPost] = []
        let (results, next) = try await publicDB.records(continuingMatchFrom: cursor)

        for (_, result) in results {
            if case let .success(record) = result,
               let p = CKPost(record: record) {
                items.append(p)
            }
        }
        return (items, next)
    }

    func createPost(title: String, content: String, image: UIImage?) async throws {
        let record = CKRecord(recordType: "Post")
        record["title"] = title as CKRecordValue
        record["content"] = content as CKRecordValue

        if let image,
           let url = try? TemporaryFile.write(image: image) {
            record["image"] = CKAsset(fileURL: url)
        }

        _ = try await publicDB.save(record)
    }

    // MARK: - ✅ USER PROFILE (جديد ✅)

    // ✅ جلب البروفايل
    func fetchUserProfile(by appleID: String) async throws -> UserProfile? {
        let predicate = NSPredicate(format: "appleID == %@", appleID)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)

        let (results, _) = try await publicDB.records(matching: query)

        for (_, result) in results {
            if case let .success(record) = result {
                return UserProfile(record: record)
            }
        }

        return nil
    }


    // ✅ إنشاء أو تحديث البروفايل
    func upsertUserProfile(_ profile: UserProfile) async throws {
        if let existing = try await fetchUserProfile(by: profile.appleID),
           let recordID = existing.recordID {

            let record = try await publicDB.record(for: recordID)
            let updated = profile.toRecord(existing: record)
            _ = try await publicDB.save(updated)

        } else {
            let newRecord = profile.toRecord()
            _ = try await publicDB.save(newRecord)
        }
    }

    // ✅ تحديث الاسم فقط
    func updateUserName(appleID: String, newName: String) async throws {
        guard var profile = try await fetchUserProfile(by: appleID),
              let recordID = profile.recordID else { return }

        let record = try await CKDB.publicDB.record(for: recordID)
        record["displayName"] = newName as CKRecordValue
        _ = try await CKDB.publicDB.save(record)
    }

    // ✅ تحديث الصورة فقط
    func updateUserPhoto(appleID: String, image: UIImage?) async throws {
        guard var profile = try await fetchUserProfile(by: appleID),
              let recordID = profile.recordID else { return }

        let record = try await publicDB.record(for: recordID)

        if let image,
           let url = try? TemporaryFile.write(image: image) {
            record["photo"] = CKAsset(fileURL: url)
        } else {
            record["photo"] = nil
        }

        _ = try await publicDB.save(record)
    }

}

// MARK: - ✅ CKAsset Temp Helper (كما هو عندك)

private enum TemporaryFile {
    static func write(image: UIImage) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        try image.jpegData(compressionQuality: 0.9)?.write(to: url)
        return url
    }
}
