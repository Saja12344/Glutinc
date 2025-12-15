//
//  FeedVM.swift
//  Glutinc22
//
//  Created by Deemah Alhazmi on 08/12/2025.
//

//
//import SwiftUI
//import Combine
//import CloudKit
//
//@MainActor
//final class FeedVM: ObservableObject {
//
//    @Published var posts: [CKPost] = []               // ← model is CKPost
//    private let ck = CloudKitService()
//    private var cursor: CKQueryOperation.Cursor?
//
//    // Load first posts
//    func load() async {
//        do {
//            let (items, next) = try await ck.fetchRecentPosts()
//            posts = items
//            cursor = next
//        } catch {
//            print("Feed load error:", error.localizedDescription)
//        }
//    }
//
//    // Pagination
//    func loadMore() async {
//        guard let c = cursor else { return }
//        do {
//            let (items, next) = try await ck.fetchRecentPosts(cursor: c)
//            posts += items
//            cursor = next
//        } catch {
//            print("Feed loadMore error:", error.localizedDescription)
//        }
//    }
//
//    // Optional: create then reload
//    func create(title: String, content: String, image: UIImage?) async {
//        do {
//            try await ck.createPost(title: title, content: content, image: image)
//            await load()
//        } catch {
//            print("Create post error:", error.localizedDescription)
//        }
//    }
//}
