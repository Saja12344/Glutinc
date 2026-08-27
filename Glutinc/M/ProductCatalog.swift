import Foundation

enum VerificationStatus: String, Codable, CaseIterable {
    case pending
    case verified
    case rejected
    case needsReview

    var title: String {
        switch self {
        case .pending:
            return L10n.t("Awaiting verification", ar: "بانتظار التوثيق")
        case .verified:
            return L10n.t("Verified Product", ar: "منتج موثّق")
        case .rejected:
            return L10n.t("Submission rejected", ar: "رُفض الطلب")
        case .needsReview:
            return L10n.t("Needs review", ar: "يحتاج مراجعة")
        }
    }
}

enum GlutenAnalysisStatus: String, Codable, CaseIterable {
    case noGlutenDetected
    case containsGluten
    case uncertain
    case notAnalyzed

    var cardLabel: String {
        switch self {
        case .noGlutenDetected:
            return L10n.t("No Gluten Detected", ar: "لم يُكتشف غلوتين")
        case .containsGluten:
            return L10n.t("Contains gluten", ar: "يحتوي على غلوتين")
        case .uncertain:
            return L10n.t("Uncertain", ar: "غير مؤكد")
        case .notAnalyzed:
            return L10n.t("Not analyzed", ar: "لم يُحلَّل")
        }
    }

    var fullLabel: String {
        switch self {
        case .noGlutenDetected:
            return L10n.t("No gluten ingredients detected", ar: "لم يتم اكتشاف مكونات تحتوي على الغلوتين")
        case .containsGluten:
            return L10n.t("Gluten-containing ingredient detected", ar: "تم اكتشاف مكوّن يحتوي على الغلوتين")
        case .uncertain:
            return L10n.t("Some ingredients could not be confidently classified.", ar: "تعذر تصنيف بعض المكونات بشكل مؤكد.")
        case .notAnalyzed:
            return L10n.t("Ingredients were not analyzed.", ar: "لم تُحلَّل المكونات.")
        }
    }

    var iconName: String {
        switch self {
        case .noGlutenDetected: return "list.clipboard"
        case .containsGluten: return "exclamationmark.octagon.fill"
        case .uncertain: return "questionmark.circle.fill"
        case .notAnalyzed: return "slash.circle"
        }
    }
}

extension ScanAnalysisStatus {
    var catalogGlutenStatus: GlutenAnalysisStatus {
        switch self {
        case .noneDetected: return .noGlutenDetected
        case .glutenDetected: return .containsGluten
        case .reviewRecommended: return .uncertain
        case .unverifiable, .unreadableIngredients: return .notAnalyzed
        }
    }
}

enum ProductCatalog {
    static func isEligibleForExplore(
        verification: VerificationStatus,
        gluten: GlutenAnalysisStatus
    ) -> Bool {
        _ = gluten
        return verification != .rejected
    }
}
