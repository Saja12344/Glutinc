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

    init?(record: CKRecord) {
        guard let title = record["title"] as? String,
              let content = record["content"] as? String,
              let createdAt = record.creationDate else { return nil }

        var uiImage: UIImage? = nil
        if let asset = record["image"] as? CKAsset,
           let url = asset.fileURL,
           let data = try? Data(contentsOf: url),
           let img = UIImage(data: data) {
            uiImage = img
        }

        self.id        = record.recordID
        self.title     = title
        self.content   = content
        self.image     = uiImage
        self.createdAt = createdAt
    }
}

// Compatibility for older views that used `imageAsset`
extension CKPost { var imageAsset: UIImage? { image } }
