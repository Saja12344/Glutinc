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
    private let db = CKContainer.default().publicCloudDatabase

    // Fetch first page
    func fetchRecentPosts() async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        let query = CKQuery(recordType: "Post", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        var items: [CKPost] = []
        let (results, cursor) = try await db.records(matching: query)

        for (_, result) in results {
            if case let .success(record) = result, let p = CKPost(record: record) {
                items.append(p)
            }
        }
        return (items, cursor)
    }

    // Fetch next page
    func fetchRecentPosts(cursor: CKQueryOperation.Cursor) async throws -> ([CKPost], CKQueryOperation.Cursor?) {
        var items: [CKPost] = []
        let (results, next) = try await db.records(continuingMatchFrom: cursor)
        for (_, result) in results {
            if case let .success(record) = result, let p = CKPost(record: record) {
                items.append(p)
            }
        }
        return (items, next)
    }

    // Optional: create a post (call this from a compose screen)
    func createPost(title: String, content: String, image: UIImage?) async throws {
        let record = CKRecord(recordType: "Post")
        record["title"] = title as CKRecordValue
        record["content"] = content as CKRecordValue

        if let image, let url = try? TemporaryFile.write(image: image) {
            record["image"] = CKAsset(fileURL: url)
        }

        _ = try await db.save(record)
    }
}

// Tiny helper for CKAsset temp files
private enum TemporaryFile {
    static func write(image: UIImage) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        try image.jpegData(compressionQuality: 0.9)?.write(to: url)
        return url
    }
}
