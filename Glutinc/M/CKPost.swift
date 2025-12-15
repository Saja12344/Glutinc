////
////  CKPost.swift
////  Glutinc22
////
////  Created by Deemah Alhazmi on 08/12/2025.
////
//
//import SwiftUI
//import CloudKit
//
//struct CKPost: Identifiable, Hashable {
//    let id: String
//    // ☁️ Cloud (اختياري)
//    let recordID: CKRecord.ID?
//    let title: String
//    let content: String
//    let image: UIImage?
//    let createdAt: Date
//    
//    var isPendingUpload: Bool = false
//
//
//    init?(record: CKRecord) {
//        guard let title = record["title"] as? String,
//              let content = record["content"] as? String,
//              let createdAt = record.creationDate else { return nil }
//
//        var uiImage: UIImage? = nil
//        if let asset = record["image"] as? CKAsset,
//           let url = asset.fileURL,
//           let data = try? Data(contentsOf: url),
//           let img = UIImage(data: data) {
//            uiImage = img
//        }
//
//        self.id        = record.recordID.recordName
//        self.recordID  = record.recordID
//        self.title     = title
//        self.content   = content
//        self.image     = uiImage
//        self.createdAt = createdAt
//        self.isPendingUpload = false
//
//    }
//    // MARK: - Local init ⭐
//       init(
//           title: String,
//           content: String,
//           image: UIImage?
//       ) {
//           self.id        = UUID().uuidString
//           self.recordID  = nil
//           self.title     = title
//           self.content   = content
//           self.image     = image
//           self.createdAt = Date()
//           self.isPendingUpload = true
//       }
//}
//
//// Compatibility for older views that used `imageAsset`
//extension CKPost { var imageAsset: UIImage? { image } }
