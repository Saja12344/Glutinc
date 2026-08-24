import Foundation

struct ClassifiedIngredient: Identifiable, Hashable {
    let id = UUID()
    let originalText: String
    let normalizedTokens: [String]
    let classification: IngredientGlutenClassification
    let canonicalName: String?
    let category: IngredientCategory?
    let possibleMatch: String?
    let isNested: Bool
    let lowOCRConfidence: Bool
}

enum IngredientMatcher {
    static let modifiers: Set<String> = [
        "organic", "natural", "fresh", "dried", "raw", "pure", "extra", "virgin",
        "refined", "whole", "ground", "stone", "concentrated", "pasteurized",
        "skimmed", "instant", "powdered", "dark", "unsweetened", "sweetened",
        "and", "of", "with", "in", "the", "a", "an", "de",
        "عضوي", "طبيعي", "طازج", "مجفف", "كامل", "مطحون", "نقي", "مركز", "مبستر"
    ]

    static func classify(_ parsed: ParsedIngredient, lowOCRConfidence: Bool) -> ClassifiedIngredient {
        let tokens = ScanTextNormalizer.tokens(parsed.originalText)
        guard !tokens.isEmpty else {
            return ClassifiedIngredient(
                originalText: parsed.originalText,
                normalizedTokens: [],
                classification: .unknown,
                canonicalName: nil,
                category: nil,
                possibleMatch: nil,
                isNested: parsed.isNested,
                lowOCRConfidence: lowOCRConfidence
            )
        }

        var i = 0
        var matchedRules: [IngredientRule] = []
        var unmatched: [String] = []

        while i < tokens.count {
            if let hit = longestMatch(tokens: tokens, start: i) {
                matchedRules.append(IngredientLexicon.rules[hit.alias.ruleIndex])
                i += hit.alias.tokens.count
            } else {
                unmatched.append(tokens[i])
                i += 1
            }
        }

        let leftover = unmatched.filter { !modifiers.contains($0) }
        let possible = leftover.compactMap(possibleGlutenOCR(for:)).first

        let gluten = matchedRules.contains { $0.classification == .containsGluten }
        let oatsOrAmbiguous = matchedRules.contains { $0.classification == .ambiguous }
        let hasKnown = !matchedRules.isEmpty

        let classification: IngredientGlutenClassification
        if gluten {
            classification = .containsGluten
        } else if possible != nil {
            classification = .unknown
        } else if !leftover.isEmpty {
            classification = leftover.count == unmatched.count && !hasKnown ? .unknown : .unknown
        } else if oatsOrAmbiguous {
            classification = .ambiguous
        } else if hasKnown {
            classification = .noKnownGluten
        } else {
            classification = .unknown
        }

        let canonical = matchedRules.first(where: { $0.classification == .containsGluten })?.canonicalName
            ?? matchedRules.first?.canonicalName

        return ClassifiedIngredient(
            originalText: parsed.originalText,
            normalizedTokens: tokens,
            classification: classification,
            canonicalName: canonical,
            category: matchedRules.first?.category,
            possibleMatch: possible,
            isNested: parsed.isNested,
            lowOCRConfidence: lowOCRConfidence
        )
    }

    private static func longestMatch(tokens: [String], start: Int) -> (alias: IngredientLexicon.CompiledAlias, length: Int)? {
        let remaining = tokens.count - start
        for alias in IngredientLexicon.compiledAliases {
            let count = alias.tokens.count
            guard count <= remaining else { continue }
            if Array(tokens[start..<(start + count)]) == alias.tokens {
                return (alias, count)
            }
        }
        return nil
    }

    static func knownConceptCount(in text: String) -> Int {
        let tokens = ScanTextNormalizer.tokens(text)
        var i = 0
        var count = 0
        while i < tokens.count {
            if let hit = longestMatch(tokens: tokens, start: i) {
                count += 1
                i += hit.alias.tokens.count
            } else {
                i += 1
            }
        }
        return count
    }

    /// Fuzzy similarity may only produce review, never automatic glutenDetected.
    static func possibleGlutenOCR(for token: String) -> String? {
        guard token.count >= 4 else { return nil }
        if modifiers.contains(token) { return nil }
        for glutenToken in IngredientLexicon.glutenSingleTokens {
            guard token.first == glutenToken.first else { continue }
            let distance = ScanTextNormalizer.levenshtein(token, glutenToken)
            if distance == 1 {
                return glutenToken
            }
        }
        return nil
    }
}
