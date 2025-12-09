//
//  UserKit.swift
//  Glutinc
//
//  Created by Deemah Alhazmi on 01/12/2025.
//

import SwiftUI
import Combine
import UIKit
import PhotosUI
import CloudKit

// Your lightweight UI model stays the same
struct UserModel {
    var appleID: String = ""          // set after sign in
    var name: String = "Jasmin"
    var photo: UIImage? = nil
    var savedImages: [String] = ["prod1","prod2"]   // legacy demo (can remove later)
    var notificationsEnabled: Bool = true
}

@MainActor
final class UserVM: ObservableObject {

    // MARK: - Published UI state

    @Published var user = UserModel()

    // Profile data from CloudKit
    @Published var posts: [CKPost] = []          // user's own posts
    @Published var saved: [CKPost] = []          // user's saved (bookmarked) posts

    // Loading & errors (nice for ProgressView / alerts)
    @Published var isLoadingProfile = false
    @Published var isLoadingPosts = false
    @Published var isLoadingSaved = false
    @Published var errorMessage: String?

    // MARK: - Private

    private let ck = CloudKitService()
    private var userProfileID: CKRecord.ID?      // needed for post & bookmark queries

    // MARK: - Sign-in / bootstrap

    /// Call this once after your sign-in flow finishes (pass the credential.user string).
    func setAppleID(_ id: String) async {
        guard !id.isEmpty else { return }
        user.appleID = id

        // Ensure there is a UserProfile record; if missing, create one.
        do {
            let profile = try await ck.fetchOrCreateUser(appleID: id, defaultName: user.name)
            userProfileID = profile.recordID
            user.name = profile.displayName
            user.photo = profile.photoImage
        } catch {
            errorMessage = "Failed to load/create user profile: \(error.localizedDescription)"
        }
    }

    // MARK: - Public loaders (use in ProfileView)

    /// Load profile (name/photo), user's posts, and saved posts in parallel.
    func loadAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadProfile() }
            group.addTask { await self.loadMyPosts() }
            group.addTask { await self.loadSaved() }
        }
    }

    /// Refresh only profile fields (name/photo).
    func loadProfile() async {
        guard !user.appleID.isEmpty else { return }
        isLoadingProfile = true
        defer { isLoadingProfile = false }

        do {
            // fetch or create, then reflect into UI
            let profile = try await ck.fetchOrCreateUser(appleID: user.appleID, defaultName: user.name)
            userProfileID = profile.recordID
            user.name = profile.displayName
            user.photo = profile.photoImage
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }

    /// Load posts authored by the current user.
    func loadMyPosts() async {
        guard let pid = userProfileID ?? (try? await ck.fetchOrCreateUser(appleID: user.appleID, defaultName: user.name).recordID) else { return }
        isLoadingPosts = true
        defer { isLoadingPosts = false }

        do {
            let (items, _) = try await ck.fetchPostsByAuthor(userProfileID: pid, limit: 40)
            posts = items
        } catch {
            errorMessage = "Failed to load posts: \(error.localizedDescription)"
        }
    }

    /// Load saved/bookmarked posts for the user.
    func loadSaved() async {
        guard let pid = userProfileID ?? (try? await ck.fetchOrCreateUser(appleID: user.appleID, defaultName: user.name).recordID) else { return }
        isLoadingSaved = true
        defer { isLoadingSaved = false }

        do {
            let items = try await ck.fetchSavedPosts(for: pid, limit: 200)
            saved = items
        } catch {
            errorMessage = "Failed to load saved posts: \(error.localizedDescription)"
        }
    }

    // MARK: - Profile updates

    func updateName(_ new: String) {
        let trimmed = new.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        user.name = trimmed
        Task { [appleID = user.appleID] in
            guard !appleID.isEmpty else { return }
            do { try await ck.updateUserName(appleID: appleID, newName: trimmed) }
            catch { await MainActor.run { self.errorMessage = "Name update failed: \(error.localizedDescription)" } }
        }
    }

    func updatePhoto(_ image: UIImage?) {
        user.photo = image
        Task { [appleID = user.appleID] in
            guard !appleID.isEmpty else { return }
            do { try await ck.updateUserPhoto(appleID: appleID, image: image) }
            catch { await MainActor.run { self.errorMessage = "Photo update failed: \(error.localizedDescription)" } }
        }
    }

    // MARK: - Optional helpers (use wherever needed)

    /// Create a new post for the current user.
    func createPost(title: String, content: String, image: UIImage?) async {
        guard let pid = userProfileID else { return }
        do {
            try await ck.createPost(title: title, content: content, image: image, authorProfileID: pid)
            await loadMyPosts()   // refresh
        } catch {
            errorMessage = "Failed to create post: \(error.localizedDescription)"
        }
    }

    /// Bookmark (save) a post.
    func bookmark(postID: CKRecord.ID) async {
        guard let pid = userProfileID else { return }
        do {
            try await ck.saveBookmark(userProfileID: pid, postID: postID)
            await loadSaved()
        } catch {
            errorMessage = "Failed to save post: \(error.localizedDescription)"
        }
    }

    /// Remove bookmark.
    func removeBookmark(postID: CKRecord.ID) async {
        guard let pid = userProfileID else { return }
        do {
            try await ck.removeBookmark(userProfileID: pid, postID: postID)
            await loadSaved()
        } catch {
            errorMessage = "Failed to remove saved post: \(error.localizedDescription)"
        }
    }
}
