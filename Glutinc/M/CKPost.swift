//
//  CKPost.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//

import SwiftUI
import CloudKit

struct CKPost: Identifiable, Hashable {
    let id: CKRecord.ID
    let title: String
    let content: String
    let image: UIImage?
    let createdAt: Date

    init(record: CKRecord) {
        self.id = record.recordID

        // Map fields with safe defaults so init is NON-optional
        self.title = record[CKSchema.PostKeys.title] as? String ?? ""
        self.content = record["content"] as? String ?? ""

        if let asset = record[CKSchema.PostKeys.imageAsset] as? CKAsset,
           let url = asset.fileURL,
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            self.image = img
        } else {
            self.image = nil
        }

        self.createdAt =
            (record[CKSchema.PostKeys.createdAt] as? Date) ??
            record.creationDate ??
            .distantPast
    }
}

// Back-compat for any old code that referenced `imageAsset`
extension CKPost {
    var imageAsset: UIImage? { image }
}
