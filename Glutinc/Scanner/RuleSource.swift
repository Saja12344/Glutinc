import Foundation

/// Provenance for a classification rule. Do not label rules as regulator-verified
/// unless they were actually reviewed against that authority.
struct RuleSource: Hashable, Sendable {
    let authority: String
    let reference: String
    let lastReviewedAt: Date?

    /// Developer-maintained terms. Not FDA, SFDA, GSO, Codex, or EU verified.
    static let internalManual = RuleSource(
        authority: "internal/manual",
        reference: "Developer-maintained ingredient terms. Not independently verified against SFDA, GSO, Codex, FDA, or EU allergen annexes.",
        lastReviewedAt: nil
    )
}

enum ScanTextSource: String, Sendable {
    case ocr
    case userEdited
    case providedText
}

enum ScanQuality: String, Sendable {
    case good
    case partial
    case poor
}

enum IngredientGlutenClassification: String, Sendable {
    case containsGluten
    case noKnownGluten
    case ambiguous
    case unknown
}

enum IngredientCategory: String, Sendable {
    case glutenGrain
    case glutenDerivative
    case ordinaryIngredient
    case ambiguous
    case oats
    case processingAid
}

struct IngredientRule: Hashable, Sendable {
    let canonicalName: String
    let aliasesEN: [String]
    let aliasesAR: [String]
    let classification: IngredientGlutenClassification
    let category: IngredientCategory
    let source: RuleSource
    let notes: String?
}
