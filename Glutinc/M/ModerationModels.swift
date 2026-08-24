import Foundation
import CloudKit

enum ReportReason: String, CaseIterable, Identifiable {
    case spam
    case harassment
    case hate
    case dangerous
    case medicalMisinfo
    case inappropriate
    case impersonation
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .spam:
            return L10n.t("Spam", ar: "رسائل مزعجة")
        case .harassment:
            return L10n.t("Harassment", ar: "تحرش")
        case .hate:
            return L10n.t("Hate speech", ar: "خطاب كراهية")
        case .dangerous:
            return L10n.t("Dangerous information", ar: "معلومات خطرة")
        case .medicalMisinfo:
            return L10n.t("Medical misinformation", ar: "معلومات طبية مضللة")
        case .inappropriate:
            return L10n.t("Inappropriate content", ar: "محتوى غير لائق")
        case .impersonation:
            return L10n.t("Impersonation", ar: "انتحال شخصية")
        case .other:
            return L10n.t("Other", ar: "أخرى")
        }
    }
}

enum ContentType: String {
    case post
    case profile
    case product
    case comment
}

enum ProductCorrectionReason: String, CaseIterable, Identifiable {
    case incorrectIngredients
    case outdated
    case wrongClassification
    case wrongImage
    case wrongProduct
    case notAProduct
    case duplicate
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .incorrectIngredients:
            return L10n.t("Incorrect ingredients", ar: "مكونات غير صحيحة")
        case .outdated:
            return L10n.t("Outdated information", ar: "معلومات قديمة")
        case .wrongClassification:
            return L10n.t("Incorrect gluten classification", ar: "تصنيف غلوتين غير صحيح")
        case .wrongImage:
            return L10n.t("Wrong product image", ar: "صورة منتج خاطئة")
        case .wrongProduct:
            return L10n.t("Wrong product information", ar: "معلومات منتج خاطئة")
        case .notAProduct:
            return L10n.t("This is not a food/product", ar: "هذا ليس منتجًا غذائيًا")
        case .duplicate:
            return L10n.t("Duplicate product", ar: "منتج مكرر")
        case .other:
            return L10n.t("Other", ar: "أخرى")
        }
    }
}

struct ContentReportDraft {
    var reporterUserId: String
    var reportedUserId: String
    var contentId: String
    var contentType: ContentType
    var reason: ReportReason
    var additionalDetails: String
}

struct ModerationReport: Identifiable {
    var id: String
    var reporterUserId: String
    var reportedUserId: String
    var contentId: String
    var contentType: String
    var reason: String
    var additionalDetails: String
    var status: String
    var createdAt: Date?
    var recordName: String

    init(record: CKRecord) {
        id = record.recordID.recordName
        recordName = record.recordID.recordName
        reporterUserId = record["reporterUserId"] as? String ?? ""
        reportedUserId = record["reportedUserId"] as? String ?? ""
        contentId = record["contentId"] as? String ?? ""
        contentType = record["contentType"] as? String ?? "product"
        reason = record["reason"] as? String ?? ""
        additionalDetails = record["additionalDetails"] as? String ?? ""
        status = record["status"] as? String ?? "pending"
        createdAt = record["createdAt"] as? Date ?? record.creationDate
    }
}
