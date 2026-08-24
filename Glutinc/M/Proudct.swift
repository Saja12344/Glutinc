import Foundation
import UIKit

struct ProductModel: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var productName: String
    var username: String
    var rating: Double
    var isGlutenFree: Bool
    var price: String
    var location: String
    var category: String
    let detectedIngredients: [String]
    var notes: String?
    var productURL: String?
    let image: UIImage
    var ownerAppleID: String
    var analysisStatusRaw: String? = nil
    var createdAt: Date? = nil
    var dataSource: String = "community"
    var manufacturerWarnings: [String] = []
    var certificationStatus: String? = nil
    var certificationSource: String? = nil
    var lastVerifiedAt: Date? = nil
    var recordName: String? = nil
    var barcode: String? = nil
    var ingredientText: String? = nil
    var verificationStatusRaw: String? = nil
    var glutenAnalysisStatusRaw: String? = nil
    var verifiedBy: String? = nil
    var ingredientCount: Int = 0

    var verificationStatus: VerificationStatus {
        if let raw = verificationStatusRaw, let status = VerificationStatus(rawValue: raw) {
            return status
        }
        return .pending
    }

    var glutenAnalysisStatus: GlutenAnalysisStatus {
        if let raw = glutenAnalysisStatusRaw, let status = GlutenAnalysisStatus(rawValue: raw) {
            return status
        }
        return scanStatus.catalogGlutenStatus
    }

    var scanStatus: ScanAnalysisStatus {
        if let raw = analysisStatusRaw, let status = ScanAnalysisStatus(rawValue: raw) {
            return status
        }
        return isGlutenFree ? .noneDetected : .glutenDetected
    }

    var isEligibleForExplore: Bool {
        ProductCatalog.isEligibleForExplore(
            verification: verificationStatus,
            gluten: glutenAnalysisStatus
        )
    }

    var glutenCardLabel: String {
        if isCertifiedGlutenFree {
            return L10n.t("Certified Gluten-Free", ar: "معتمد كمنتج خالٍ من الغلوتين")
        }
        return glutenAnalysisStatus.cardLabel
    }

    var isCertifiedGlutenFree: Bool {
        certificationStatus == "certified"
    }
}
