
import CloudKit
import UIKit

final class CloudKitService {

    private let container = CKContainer(identifier: "iCloud.com.sga.Glutinc")
    
    private let publicDB: CKDatabase
    private let privateDB: CKDatabase


    init() {
        self.publicDB  = container.publicCloudDatabase
        self.privateDB = container.privateCloudDatabase
    }

    // MARK: - USER PROFILE (مسموح async لأنه Query بحقل appleID)
//
//    func fetchUserProfile(by appleID: String) async throws -> UserProfile? {
//        let predicate = NSPredicate(format: "appleID == %@", appleID)
//        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
//
//        let operation = CKQueryOperation(query: query)
//        operation.resultsLimit = 1
//
//        var profile: UserProfile?
//
//        operation.recordMatchedBlock = { _, result in
//            if case let .success(record) = result {
//                profile = UserProfile(record: record)
//            }
//        }
//
//        return try await withCheckedThrowingContinuation { cont in
//            operation.queryResultBlock = { result in
//                switch result {
//                case .success:
//                    cont.resume(returning: profile)
//                case .failure(let error):
//                    cont.resume(throwing: error)
//                }
//            }
//            self.privateDB.add(operation)
//        }
//    }
    func fetchUserProfile(by appleID: String) async throws -> UserProfile? {
        let recordID = CKRecord.ID(recordName: appleID)

        do {
            let record = try await privateDB.record(for: recordID)
            return UserProfile(record: record)
        } catch {
            return nil
        }
    }

//
//    func upsertUserProfile(_ profile: UserProfile) async throws {
//        if let existing = try await fetchUserProfile(by: profile.appleID),
//           let recordID = existing.recordID {
//
//            let record = try await publicDB.record(for: recordID)
//            let updated = profile.toRecord(existing: record)
//            _ = try await privateDB.save(updated)
//
//        } else {
//            let newRecord = profile.toRecord()
//            _ = try await privateDB.save(newRecord)
//        }
//    }
    func upsertUserProfile(_ profile: UserProfile) async throws {
        let recordID = CKRecord.ID(recordName: profile.appleID)

        let record: CKRecord
        do {
            record = try await privateDB.record(for: recordID)
        } catch {
            record = CKRecord(recordType: CKTypes.userProfile, recordID: recordID)
        }

        let updated = profile.toRecord(existing: record)
        _ = try await privateDB.save(updated)
    }

    // MARK: - UPDATE USER NAME
//    func updateUserName(appleID: String, newName: String) async throws {
//
//        guard let profile = try await fetchUserProfile(by: appleID),
//              let recordID = profile.recordID else { return }
//
//        let record = try await publicDB.record(for: recordID)
//        record["displayName"] = newName as CKRecordValue
//        _ = try await privateDB.save(record)
//    }
    func updateUserName(appleID: String, newName: String) async throws {
        let recordID = CKRecord.ID(recordName: appleID)
        let record = try await privateDB.record(for: recordID)
        record["displayName"] = newName as CKRecordValue
        _ = try await privateDB.save(record)
    }

    // MARK: - UPDATE USER PHOTO
//    func updateUserPhoto(appleID: String, image: UIImage?) async throws {
//
//        guard let profile = try await fetchUserProfile(by: appleID),
//              let recordID = profile.recordID else { return }
//
//        let record = try await publicDB.record(for: recordID)
//
//        if let image,
//           let url = try? TemporaryFile.write(image: image) {
//            record["photo"] = CKAsset(fileURL: url)
//        } else {
//            record["photo"] = nil
//        }
//
//        _ = try await publicDB.save(record)
//    }
    func updateUserPhoto(appleID: String, image: UIImage?) async throws {
        let recordID = CKRecord.ID(recordName: appleID)
        let record = try await privateDB.record(for: recordID)

        if let image,
           let url = try? TemporaryFile.write(image: image) {
            record["photo"] = CKAsset(fileURL: url)
        } else {
            record["photo"] = nil
        }

        _ = try await privateDB.save(record)
    }



    // MARK: - SAVE PRODUCT

    func saveProduct(_ product: ProductModel, completion: @escaping (Bool) -> Void) {

        let record = CKRecord(recordType: "Product")

        record["productID"]     = product.id as CKRecordValue
        record["productName"]   = product.productName as CKRecordValue
        record["username"]      = product.username as CKRecordValue
        record["rating"]        = product.rating as CKRecordValue
        record["isGlutenFree"]  = product.isGlutenFree as CKRecordValue
        record["price"]         = product.price as CKRecordValue
        record["location"]      = product.location as CKRecordValue
        record["category"]      = product.category as CKRecordValue
        record["createdAt"]     = Date() as CKRecordValue
        record["ownerAppleID"] = product.ownerAppleID as CKRecordValue
        record["analysisStatus"] = (product.analysisStatusRaw ?? product.scanStatus.rawValue) as CKRecordValue
        record["glutenAnalysisStatus"] = product.glutenAnalysisStatus.rawValue as CKRecordValue
        record["verificationStatus"] = product.verificationStatus.rawValue as CKRecordValue
        record["dataSource"] = product.dataSource as CKRecordValue
        record["ingredientCount"] = product.ingredientCount as CKRecordValue
        if let barcode = product.barcode {
            record["barcode"] = barcode as CKRecordValue
        }
        if let ingredientText = product.ingredientText {
            record["ingredientText"] = ingredientText as CKRecordValue
        }
        if let verifiedBy = product.verifiedBy {
            record["verifiedBy"] = verifiedBy as CKRecordValue
        }
        if let lastVerified = product.lastVerifiedAt {
            record["lastVerifiedAt"] = lastVerified as CKRecordValue
        }
        if !product.manufacturerWarnings.isEmpty {
            record["manufacturerWarnings"] = product.manufacturerWarnings as CKRecordValue
        }
        if !product.detectedIngredients.isEmpty {
            record["detectedIngredients"] = product.detectedIngredients as CKRecordValue
        }
        // ⛔️ لا حفظ بدون صورة
        guard let url = try? TemporaryFile.write(image: product.image) else {
            print("❌ Failed to write product image")
            completion(false)
            return
        }

        // ✅ صورة إجبارية
        record["image"] = CKAsset(fileURL: url)
        // ✅ detected ingredients
        if !product.detectedIngredients.isEmpty {
            record["detectedIngredients"] = product.detectedIngredients as CKRecordValue
        }

        if let notes = product.notes {
            record["notes"] = notes as CKRecordValue
        }

        if let url = product.productURL {
            record["productURL"] = url as CKRecordValue
        }

        publicDB.save(record) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Save product error:", error)
                    completion(false)
                } else {
                    print("✅ Product saved")
                    completion(true)
                }
            }
        }
    }

    func fetchProducts(completion: @escaping ([ProductModel]) -> Void) {

        let query = CKQuery(
            recordType: "Product",
            predicate: NSPredicate(value: true)
        )

        Task {
            do {
                let (matchResults, _) = try await publicDB.records(matching: query)

                let products: [ProductModel] = matchResults.compactMap { _, result in
                    guard case let .success(record) = result else { return nil }

                    // ✅ الصورة إجبارية
                    guard
                        let asset = record["image"] as? CKAsset,
                        let fileURL = asset.fileURL,
                        let image = UIImage(contentsOfFile: fileURL.path)
                    else {
                        print("⚠️ Product skipped (no image)")
                        return nil
                    }
                    let detectedIngredients =
                        record["detectedIngredients"] as? [String] ?? []

                    return ProductModel(
                        id: record["productID"] as? String ?? record.recordID.recordName,
                        productName: record["productName"] as? String ?? "",
                        username: record["username"] as? String ?? "",
                        rating: record["rating"] as? Double ?? 0,
                        isGlutenFree: record["isGlutenFree"] as? Bool ?? false,
                        price: record["price"] as? String ?? "",
                        location: record["location"] as? String ?? "",
                        category: record["category"] as? String ?? "",
                        detectedIngredients: detectedIngredients,
                        notes: record["notes"] as? String,
                        productURL: record["productURL"] as? String,
                        image: image,
                        ownerAppleID: record["ownerAppleID"] as? String ?? "",
                        analysisStatusRaw: record["analysisStatus"] as? String,
                        createdAt: record["createdAt"] as? Date ?? record.creationDate,
                        dataSource: record["dataSource"] as? String ?? "community",
                        manufacturerWarnings: record["manufacturerWarnings"] as? [String] ?? [],
                        certificationStatus: record["certificationStatus"] as? String,
                        certificationSource: record["certificationSource"] as? String,
                        lastVerifiedAt: record["lastVerifiedAt"] as? Date,
                        recordName: record.recordID.recordName,
                        barcode: record["barcode"] as? String,
                        ingredientText: record["ingredientText"] as? String,
                        verificationStatusRaw: record["verificationStatus"] as? String,
                        glutenAnalysisStatusRaw: record["glutenAnalysisStatus"] as? String,
                        verifiedBy: record["verifiedBy"] as? String,
                        ingredientCount: record["ingredientCount"] as? Int ?? 0
                    )
                }

                await MainActor.run {
                    print("✅ FINAL FETCH:", products.count)
                    completion(products)
                }

            } catch {
                print("❌ CloudKit fetch error:", error)
                await MainActor.run {
                    completion([])
                }
            }
        }
    }

    // MARK: - Reports (public, for CloudKit Dashboard review)

    func saveReport(_ draft: ContentReportDraft, completion: @escaping (Bool) -> Void) {
        let record = CKRecord(recordType: "ContentReport")
        record["reporterUserId"] = draft.reporterUserId as CKRecordValue
        record["reportedUserId"] = draft.reportedUserId as CKRecordValue
        record["contentId"] = draft.contentId as CKRecordValue
        record["contentType"] = draft.contentType.rawValue as CKRecordValue
        record["reason"] = draft.reason.rawValue as CKRecordValue
        record["additionalDetails"] = draft.additionalDetails as CKRecordValue
        record["status"] = "pending" as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue

        publicDB.save(record) { _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }
    }

    func saveProductCorrection(
        productID: String,
        reporterUserId: String,
        reason: ProductCorrectionReason,
        details: String,
        completion: @escaping (Bool) -> Void
    ) {
        let record = CKRecord(recordType: "ProductCorrection")
        record["productID"] = productID as CKRecordValue
        record["reporterUserId"] = reporterUserId as CKRecordValue
        record["reason"] = reason.rawValue as CKRecordValue
        record["details"] = details as CKRecordValue
        record["status"] = "pending" as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue

        publicDB.save(record) { _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }
    }

    // MARK: - Blocks (private DB — never notify the blocked user)

    func blockUser(blockedUserId: String, completion: @escaping (Bool) -> Void) {
        let record = CKRecord(
            recordType: "BlockedUser",
            recordID: CKRecord.ID(recordName: blockedUserId)
        )
        record["blockedUserId"] = blockedUserId as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        privateDB.save(record) { _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }
    }

    func unblockUser(blockedUserId: String, completion: @escaping (Bool) -> Void) {
        privateDB.delete(withRecordID: CKRecord.ID(recordName: blockedUserId)) { _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }
    }

    func fetchBlockedUserIDs(completion: @escaping ([String]) -> Void) {
        let query = CKQuery(recordType: "BlockedUser", predicate: NSPredicate(value: true))
        Task {
            do {
                let (results, _) = try await privateDB.records(matching: query)
                let ids: [String] = results.compactMap { _, result in
                    guard case let .success(record) = result else { return nil }
                    return record["blockedUserId"] as? String ?? record.recordID.recordName
                }
                await MainActor.run { completion(ids) }
            } catch {
                await MainActor.run { completion([]) }
            }
        }
    }

    // MARK: - Saved products (private DB)

    func saveBookmark(productID: String, completion: @escaping (Bool) -> Void) {
        let record = CKRecord(
            recordType: "SavedProduct",
            recordID: CKRecord.ID(recordName: productID)
        )
        record["productID"] = productID as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        privateDB.save(record) { _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }
    }

    func removeBookmark(productID: String, completion: @escaping (Bool) -> Void) {
        privateDB.delete(withRecordID: CKRecord.ID(recordName: productID)) { _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }
    }

    func fetchSavedProductIDs(completion: @escaping ([String]) -> Void) {
        let query = CKQuery(recordType: "SavedProduct", predicate: NSPredicate(value: true))
        Task {
            do {
                let (results, _) = try await privateDB.records(matching: query)
                let ids: [String] = results.compactMap { _, result in
                    guard case let .success(record) = result else { return nil }
                    return record["productID"] as? String ?? record.recordID.recordName
                }
                await MainActor.run { completion(ids) }
            } catch {
                await MainActor.run { completion([]) }
            }
        }
    }

    func deleteAllPrivateRecords(ofType type: String) async {
        let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
        do {
            let (results, _) = try await privateDB.records(matching: query)
            for (recordID, result) in results {
                if case .success = result {
                    try? await privateDB.deleteRecord(withID: recordID)
                }
            }
        } catch {
            print("⚠️ Could not clear \(type):", error.localizedDescription)
        }
    }

    func anonymizeProducts(ownerAppleID: String, completion: @escaping (Bool) -> Void) {
        fetchProducts { products in
            let mine = products.filter { $0.ownerAppleID == ownerAppleID }
            guard !mine.isEmpty else {
                completion(true)
                return
            }
            Task {
                var ok = true
                for product in mine {
                    guard let recordName = product.recordName else { continue }
                    do {
                        let record = try await self.publicDB.record(for: CKRecord.ID(recordName: recordName))
                        record["username"] = "Deleted account" as CKRecordValue
                        record["ownerAppleID"] = "deleted" as CKRecordValue
                        _ = try await self.publicDB.save(record)
                    } catch {
                        ok = false
                    }
                }
                await MainActor.run { completion(ok) }
            }
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
        gluten: GlutenAnalysisStatus? = nil,
        verifiedBy: String?,
        completion: @escaping (Bool) -> Void
    ) {
        Task {
            do {
                let record = try await publicDB.record(for: CKRecord.ID(recordName: recordName))
                record["verificationStatus"] = status.rawValue as CKRecordValue
                if status == .verified {
                    record["lastVerifiedAt"] = Date() as CKRecordValue
                    if let verifiedBy {
                        record["verifiedBy"] = verifiedBy as CKRecordValue
                    }
                }
                if let gluten {
                    record["glutenAnalysisStatus"] = gluten.rawValue as CKRecordValue
                }
                _ = try await publicDB.save(record)
                await MainActor.run { completion(true) }
            } catch {
                await MainActor.run { completion(false) }
            }
        }
    }

    func fetchReports(completion: @escaping ([ModerationReport]) -> Void) {
        let query = CKQuery(recordType: "ContentReport", predicate: NSPredicate(value: true))
        Task {
            do {
                let (results, _) = try await publicDB.records(matching: query)
                let reports: [ModerationReport] = results.compactMap { _, result in
                    guard case let .success(record) = result else { return nil }
                    return ModerationReport(record: record)
                }
                await MainActor.run { completion(reports.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }) }
            } catch {
                await MainActor.run { completion([]) }
            }
        }
    }

    func updateReportStatus(recordName: String, status: String, reviewer: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let record = try await publicDB.record(for: CKRecord.ID(recordName: recordName))
                record["status"] = status as CKRecordValue
                record["reviewedAt"] = Date() as CKRecordValue
                record["reviewedBy"] = reviewer as CKRecordValue
                _ = try await publicDB.save(record)
                await MainActor.run { completion(true) }
            } catch {
                await MainActor.run { completion(false) }
            }
        }
    }

    private func mapProduct(_ record: CKRecord) -> ProductModel? {
        guard
            let asset = record["image"] as? CKAsset,
            let fileURL = asset.fileURL,
            let image = UIImage(contentsOfFile: fileURL.path)
        else { return nil }
        return ProductModel(
            id: record["productID"] as? String ?? record.recordID.recordName,
            productName: record["productName"] as? String ?? "",
            username: record["username"] as? String ?? "",
            rating: record["rating"] as? Double ?? 0,
            isGlutenFree: record["isGlutenFree"] as? Bool ?? false,
            price: record["price"] as? String ?? "",
            location: record["location"] as? String ?? "",
            category: record["category"] as? String ?? "",
            detectedIngredients: record["detectedIngredients"] as? [String] ?? [],
            notes: record["notes"] as? String,
            productURL: record["productURL"] as? String,
            image: image,
            ownerAppleID: record["ownerAppleID"] as? String ?? "",
            analysisStatusRaw: record["analysisStatus"] as? String,
            createdAt: record["createdAt"] as? Date ?? record.creationDate,
            dataSource: record["dataSource"] as? String ?? "community",
            manufacturerWarnings: record["manufacturerWarnings"] as? [String] ?? [],
            certificationStatus: record["certificationStatus"] as? String,
            certificationSource: record["certificationSource"] as? String,
            lastVerifiedAt: record["lastVerifiedAt"] as? Date,
            recordName: record.recordID.recordName,
            barcode: record["barcode"] as? String,
            ingredientText: record["ingredientText"] as? String,
            verificationStatusRaw: record["verificationStatus"] as? String,
            glutenAnalysisStatusRaw: record["glutenAnalysisStatus"] as? String,
            verifiedBy: record["verifiedBy"] as? String,
            ingredientCount: record["ingredientCount"] as? Int ?? 0
        )
    }

    func deleteUserProfile(appleID: String, completion: @escaping (Bool) -> Void) {
        privateDB.delete(withRecordID: CKRecord.ID(recordName: appleID)) { _, error in
            DispatchQueue.main.async { completion(error == nil) }
        }
    }
}

enum TemporaryFile {

    static func write(image: UIImage) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NSError(
                domain: "TemporaryFile",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG"]
            )
        }

        try data.write(to: url)
        return url
    }
}
