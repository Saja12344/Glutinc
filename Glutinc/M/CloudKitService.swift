
import CloudKit
import UIKit

final class CloudKitService {

    private let container = CKContainer(identifier: "iCloud.com.sga.Glutinc")
    
    private let publicDB: CKDatabase

    init() {
        self.publicDB = container.publicCloudDatabase
    }

    // MARK: - USER PROFILE (مسموح async لأنه Query بحقل appleID)

    func fetchUserProfile(by appleID: String) async throws -> UserProfile? {
        let predicate = NSPredicate(format: "appleID == %@", appleID)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)

        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1

        var profile: UserProfile?

        operation.recordMatchedBlock = { _, result in
            if case let .success(record) = result {
                profile = UserProfile(record: record)
            }
        }

        return try await withCheckedThrowingContinuation { cont in
            operation.queryResultBlock = { result in
                switch result {
                case .success:
                    cont.resume(returning: profile)
                case .failure(let error):
                    cont.resume(throwing: error)
                }
            }
            self.publicDB.add(operation)
        }
    }

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
    // MARK: - UPDATE USER NAME
    func updateUserName(appleID: String, newName: String) async throws {

        guard let profile = try await fetchUserProfile(by: appleID),
              let recordID = profile.recordID else { return }

        let record = try await publicDB.record(for: recordID)
        record["displayName"] = newName as CKRecordValue
        _ = try await publicDB.save(record)
    }

    // MARK: - UPDATE USER PHOTO
    func updateUserPhoto(appleID: String, image: UIImage?) async throws {

        guard let profile = try await fetchUserProfile(by: appleID),
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
        // ⛔️ لا حفظ بدون صورة
        guard let url = try? TemporaryFile.write(image: product.image) else {
            print("❌ Failed to write product image")
            completion(false)
            return
        }

        // ✅ صورة إجبارية
        record["image"] = CKAsset(fileURL: url)

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

    // MARK: - FETCH PRODUCTS (بدون matching ❗️)
//
//    func fetchProducts(completion: @escaping ([ProductModel]) -> Void) {
//
//        let query = CKQuery(
//            recordType: "Product",
//            predicate: NSPredicate(value: true)
//        )
//
//        let operation = CKQueryOperation(query: query)
//        operation.resultsLimit = 100
//
//        var products: [ProductModel] = []
//
//        operation.recordMatchedBlock = { _, result in
//            if case let .success(record) = result {
//
//                let product = ProductModel(
//                    id: record["productID"] as? String ?? record.recordID.recordName,
//                    productName: record["productName"] as? String ?? "",
//                    username: record["username"] as? String ?? "",
//                    rating: record["rating"] as? Double ?? 0,
//                    isGlutenFree: record["isGlutenFree"] as? Bool ?? false,
//                    price: record["price"] as? String ?? "",
//                    location: record["location"] as? String ?? "",
//                    category: record["category"] as? String ?? "",
//                    notes: record["notes"] as? String,
//                    productURL: record["productURL"] as? String
//                )
//
//                products.append(product)
//            }
//        }
//
//        operation.queryResultBlock = { _ in
//            DispatchQueue.main.async {
//                print("✅ FINAL FETCH:", products.count)
//                completion(products)
//            }
//        }
//
//        publicDB.add(operation)
//    }
//    func fetchProducts(completion: @escaping ([ProductModel]) -> Void) {
//
//        let query = CKQuery(
//            recordType: "Product",
//            predicate: NSPredicate(value: true)
//        )
//
//        let operation = CKQueryOperation(query: query)
//        operation.resultsLimit = 100
//
//        var products: [ProductModel] = []
//
//        operation.recordMatchedBlock = { _, result in
//            if case let .success(record) = result {
//
//                let product = ProductModel(
//                    id: record["productID"] as? String ?? record.recordID.recordName,
//                    productName: record["productName"] as? String ?? "",
//                    username: record["username"] as? String ?? "",
//                    rating: record["rating"] as? Double ?? 0,
//                    isGlutenFree: record["isGlutenFree"] as? Bool ?? false,
//                    price: record["price"] as? String ?? "",
//                    location: record["location"] as? String ?? "",
//                    category: record["category"] as? String ?? "",
//                    notes: record["notes"] as? String,
//                    productURL: record["productURL"] as? String
//                )
//
//                products.append(product)
//            }
//        }
//
//        operation.queryResultBlock = { _ in
//            DispatchQueue.main.async {
//                print("✅ FINAL FETCH:", products.count)
//                completion(products)
//            }
//        }
//
//        publicDB.add(operation) // ✅ نفس الكونتينر
//    }
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

                    return ProductModel(
                        id: record["productID"] as? String ?? record.recordID.recordName,
                        productName: record["productName"] as? String ?? "",
                        username: record["username"] as? String ?? "",
                        rating: record["rating"] as? Double ?? 0,
                        isGlutenFree: record["isGlutenFree"] as? Bool ?? false,
                        price: record["price"] as? String ?? "",
                        location: record["location"] as? String ?? "",
                        category: record["category"] as? String ?? "",
                        notes: record["notes"] as? String,
                        productURL: record["productURL"] as? String,
                        image: image              // ✅ هذا كان ناقص
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
