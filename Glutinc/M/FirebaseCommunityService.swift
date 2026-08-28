import Foundation
import UIKit
import CloudKit

/// Community backend used by the app. Posts are stored on-device so publish
/// works without iCloud. Drop in `GoogleService-Info.plist` later to sync with Firebase.
final class FirebaseCommunityService {
    static let shared = FirebaseCommunityService()

    private let queue = DispatchQueue(label: "glutinc.firebase.community")
    private let fm = FileManager.default

    private var root: URL {
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fm.temporaryDirectory
        let dir = base.appendingPathComponent("GlutincCommunity", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private var productsURL: URL { root.appendingPathComponent("products.json") }
    private var imagesDir: URL {
        let dir = root.appendingPathComponent("images", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    private var profilesURL: URL { root.appendingPathComponent("profiles.json") }
    private var blockedURL: URL { root.appendingPathComponent("blocked.json") }
    private var savedURL: URL { root.appendingPathComponent("saved.json") }
    private var reportsURL: URL { root.appendingPathComponent("reports.json") }

    private struct StoredProduct: Codable {
        var id: String
        var productName: String
        var username: String
        var rating: Double
        var isGlutenFree: Bool
        var price: String
        var location: String
        var category: String
        var detectedIngredients: [String]
        var notes: String?
        var productURL: String?
        var ownerAppleID: String
        var analysisStatusRaw: String?
        var createdAt: Date?
        var dataSource: String
        var manufacturerWarnings: [String]
        var certificationStatus: String?
        var certificationSource: String?
        var lastVerifiedAt: Date?
        var recordName: String?
        var barcode: String?
        var ingredientText: String?
        var verificationStatusRaw: String?
        var glutenAnalysisStatusRaw: String?
        var verifiedBy: String?
        var ingredientCount: Int
    }

    private struct StoredProfile: Codable {
        var appleID: String
        var displayName: String
        var email: String?
    }

    private struct StoredReport: Codable {
        var recordName: String
        var reporterUserId: String
        var reportedUserId: String
        var contentId: String
        var contentType: String
        var reason: String
        var additionalDetails: String
        var status: String
        var createdAt: Date
    }

    private init() {}

    // MARK: - Products

    func saveProduct(_ product: ProductModel, completion: @escaping (Bool) -> Void) {
        queue.async {
            var items = self.loadStoredProducts()
            items.removeAll { $0.id == product.id }
            items.insert(self.stored(from: product), at: 0)
            self.writeStoredProducts(items)
            if let data = product.image.jpegData(compressionQuality: 0.82) {
                try? data.write(to: self.imageURL(product.id), options: .atomic)
            }
            DispatchQueue.main.async { completion(true) }
        }
    }

    func fetchProducts(completion: @escaping ([ProductModel]) -> Void) {
        queue.async {
            let products = self.loadStoredProducts().compactMap { self.model(from: $0) }
            DispatchQueue.main.async { completion(products) }
        }
    }

    func fetchExploreProducts(completion: @escaping ([ProductModel]) -> Void) {
        fetchProducts { all in
            completion(all.filter { $0.ownerAppleID != "deleted" && $0.isEligibleForExplore })
        }
    }

    func updateProductVerification(
        recordName: String,
        status: VerificationStatus,
        gluten: GlutenAnalysisStatus?,
        verifiedBy: String?,
        completion: @escaping (Bool) -> Void
    ) {
        queue.async {
            var items = self.loadStoredProducts()
            if let index = items.firstIndex(where: { $0.recordName == recordName || $0.id == recordName }) {
                items[index].verificationStatusRaw = status.rawValue
                items[index].verifiedBy = verifiedBy
                items[index].lastVerifiedAt = Date()
                if let gluten {
                    items[index].glutenAnalysisStatusRaw = gluten.rawValue
                }
                self.writeStoredProducts(items)
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    func anonymizeProducts(ownerAppleID: String, completion: @escaping (Bool) -> Void) {
        queue.async {
            var items = self.loadStoredProducts()
            for i in items.indices where items[i].ownerAppleID == ownerAppleID {
                items[i].ownerAppleID = "deleted"
                items[i].username = "Deleted user"
            }
            self.writeStoredProducts(items)
            DispatchQueue.main.async { completion(true) }
        }
    }

    // MARK: - Profile

    func fetchUserProfile(by appleID: String) async throws -> UserProfile? {
        try await withCheckedContinuation { cont in
            queue.async {
                let profile = self.loadProfiles().first(where: { $0.appleID == appleID }).map { stored -> UserProfile in
                    var profile = UserProfile(
                        appleID: stored.appleID,
                        displayName: stored.displayName,
                        email: stored.email
                    )
                    profile.recordID = CKRecord.ID(recordName: stored.appleID)
                    return profile
                }
                cont.resume(returning: profile)
            }
        }
    }

    func upsertUserProfile(_ profile: UserProfile) async throws {
        try await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            queue.async {
                var profiles = self.loadProfiles()
                profiles.removeAll { $0.appleID == profile.appleID }
                profiles.append(StoredProfile(
                    appleID: profile.appleID,
                    displayName: profile.displayName,
                    email: profile.email
                ))
                self.writeJSON(profiles, to: self.profilesURL)
                cont.resume()
            }
        }
    }

    func updateUserName(appleID: String, newName: String) async throws {
        if var profile = try await fetchUserProfile(by: appleID) {
            profile.displayName = newName
            try await upsertUserProfile(profile)
        }
    }

    func updateUserPhoto(appleID: String, image: UIImage?) async throws {
        _ = appleID
        _ = image
    }

    func deleteUserProfile(appleID: String, completion: @escaping (Bool) -> Void) {
        queue.async {
            var profiles = self.loadProfiles()
            profiles.removeAll { $0.appleID == appleID }
            self.writeJSON(profiles, to: self.profilesURL)
            DispatchQueue.main.async { completion(true) }
        }
    }

    // MARK: - Saved / blocked

    func saveBookmark(productID: String, completion: @escaping (Bool) -> Void) {
        mutateIDSet(at: savedURL, add: productID, completion: completion)
    }

    func removeBookmark(productID: String, completion: @escaping (Bool) -> Void) {
        mutateIDSet(at: savedURL, remove: productID, completion: completion)
    }

    func fetchSavedProductIDs(completion: @escaping ([String]) -> Void) {
        queue.async {
            let ids = self.loadIDSet(at: self.savedURL)
            DispatchQueue.main.async { completion(Array(ids)) }
        }
    }

    func blockUser(blockedUserId: String, completion: @escaping (Bool) -> Void) {
        mutateIDSet(at: blockedURL, add: blockedUserId, completion: completion)
    }

    func unblockUser(blockedUserId: String, completion: @escaping (Bool) -> Void) {
        mutateIDSet(at: blockedURL, remove: blockedUserId, completion: completion)
    }

    func fetchBlockedUserIDs(completion: @escaping ([String]) -> Void) {
        queue.async {
            let ids = self.loadIDSet(at: self.blockedURL)
            DispatchQueue.main.async { completion(Array(ids)) }
        }
    }

    func deleteAllPrivateRecords(ofType type: String) async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            queue.async {
                if type == "SavedProduct" {
                    self.writeJSON([String](), to: self.savedURL)
                } else if type == "BlockedUser" {
                    self.writeJSON([String](), to: self.blockedURL)
                }
                cont.resume()
            }
        }
    }

    // MARK: - Reports

    func saveReport(_ draft: ContentReportDraft, completion: @escaping (Bool) -> Void) {
        queue.async {
            var reports = self.loadReports()
            reports.append(StoredReport(
                recordName: UUID().uuidString,
                reporterUserId: draft.reporterUserId,
                reportedUserId: draft.reportedUserId,
                contentId: draft.contentId,
                contentType: draft.contentType.rawValue,
                reason: draft.reason.rawValue,
                additionalDetails: draft.additionalDetails,
                status: "pending",
                createdAt: Date()
            ))
            self.writeJSON(reports, to: self.reportsURL)
            DispatchQueue.main.async { completion(true) }
        }
    }

    func saveProductCorrection(
        productID: String,
        reporterUserId: String,
        reason: ProductCorrectionReason,
        details: String,
        completion: @escaping (Bool) -> Void
    ) {
        let draft = ContentReportDraft(
            reporterUserId: reporterUserId,
            reportedUserId: "",
            contentId: productID,
            contentType: .product,
            reason: .other,
            additionalDetails: "\(reason.rawValue): \(details)"
        )
        saveReport(draft, completion: completion)
    }

    func fetchReports(completion: @escaping ([ModerationReport]) -> Void) {
        completion([])
    }

    func updateReportStatus(
        recordName: String,
        status: String,
        reviewer: String,
        completion: @escaping (Bool) -> Void
    ) {
        _ = recordName
        _ = status
        _ = reviewer
        completion(true)
    }

    // MARK: - Disk

    private func imageURL(_ id: String) -> URL {
        imagesDir.appendingPathComponent("\(id).jpg")
    }

    private func stored(from product: ProductModel) -> StoredProduct {
        StoredProduct(
            id: product.id,
            productName: product.productName,
            username: product.username,
            rating: product.rating,
            isGlutenFree: product.isGlutenFree,
            price: product.price,
            location: product.location,
            category: product.category,
            detectedIngredients: product.detectedIngredients,
            notes: product.notes,
            productURL: product.productURL,
            ownerAppleID: product.ownerAppleID,
            analysisStatusRaw: product.analysisStatusRaw,
            createdAt: product.createdAt,
            dataSource: product.dataSource,
            manufacturerWarnings: product.manufacturerWarnings,
            certificationStatus: product.certificationStatus,
            certificationSource: product.certificationSource,
            lastVerifiedAt: product.lastVerifiedAt,
            recordName: product.recordName ?? product.id,
            barcode: product.barcode,
            ingredientText: product.ingredientText,
            verificationStatusRaw: product.verificationStatusRaw,
            glutenAnalysisStatusRaw: product.glutenAnalysisStatusRaw,
            verifiedBy: product.verifiedBy,
            ingredientCount: product.ingredientCount
        )
    }

    private func model(from stored: StoredProduct) -> ProductModel? {
        let image: UIImage
        if let data = try? Data(contentsOf: imageURL(stored.id)), let loaded = UIImage(data: data) {
            image = loaded
        } else {
            image = UIImage()
        }
        return ProductModel(
            id: stored.id,
            productName: stored.productName,
            username: stored.username,
            rating: stored.rating,
            isGlutenFree: stored.isGlutenFree,
            price: stored.price,
            location: stored.location,
            category: stored.category,
            detectedIngredients: stored.detectedIngredients,
            notes: stored.notes,
            productURL: stored.productURL,
            image: image,
            ownerAppleID: stored.ownerAppleID,
            analysisStatusRaw: stored.analysisStatusRaw,
            createdAt: stored.createdAt,
            dataSource: stored.dataSource,
            manufacturerWarnings: stored.manufacturerWarnings,
            certificationStatus: stored.certificationStatus,
            certificationSource: stored.certificationSource,
            lastVerifiedAt: stored.lastVerifiedAt,
            recordName: stored.recordName,
            barcode: stored.barcode,
            ingredientText: stored.ingredientText,
            verificationStatusRaw: stored.verificationStatusRaw,
            glutenAnalysisStatusRaw: stored.glutenAnalysisStatusRaw,
            verifiedBy: stored.verifiedBy,
            ingredientCount: stored.ingredientCount
        )
    }

    private func loadStoredProducts() -> [StoredProduct] {
        loadJSON(from: productsURL, as: [StoredProduct].self) ?? []
    }

    private func writeStoredProducts(_ items: [StoredProduct]) {
        writeJSON(items, to: productsURL)
    }

    private func loadProfiles() -> [StoredProfile] {
        loadJSON(from: profilesURL, as: [StoredProfile].self) ?? []
    }

    private func loadReports() -> [StoredReport] {
        loadJSON(from: reportsURL, as: [StoredReport].self) ?? []
    }

    private func loadIDSet(at url: URL) -> Set<String> {
        Set(loadJSON(from: url, as: [String].self) ?? [])
    }

    private func mutateIDSet(at url: URL, add: String? = nil, remove: String? = nil, completion: @escaping (Bool) -> Void) {
        queue.async {
            var ids = self.loadIDSet(at: url)
            if let add { ids.insert(add) }
            if let remove { ids.remove(remove) }
            self.writeJSON(Array(ids), to: url)
            DispatchQueue.main.async { completion(true) }
        }
    }

    private func loadJSON<T: Decodable>(from url: URL, as type: T.Type) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func writeJSON<T: Encodable>(_ value: T, to url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        if let data = try? encoder.encode(value) {
            try? data.write(to: url, options: .atomic)
        }
    }
}
