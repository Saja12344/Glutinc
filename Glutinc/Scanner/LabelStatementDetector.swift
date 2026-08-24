import Foundation

struct LabelStatement {
    enum Kind: String {
        case allergenDeclaration
        case crossContactWarning
        case glutenFreeClaim
    }

    let kind: Kind
    let originalText: String
    let mentionsGlutenAllergen: Bool
}

enum LabelStatementDetector {
    static func detect(in text: String) -> [LabelStatement] {
        var statements: [LabelStatement] = []
        statements.append(contentsOf: glutenFreeClaims(in: text))
        statements.append(contentsOf: allergenDeclarations(in: text))
        statements.append(contentsOf: crossContactWarnings(in: text))
        return statements
    }

    /// Replace claim / warning / nutrition-adjacent spans with spaces so remaining
    /// ingredient matching does not see `gluten` inside `gluten-free`.
    static func maskNonIngredientSpans(_ text: String) -> String {
        var masked = text
        let phrases = glutenFreePhrases + allergenPhrases + crossContactPhrases
        for phrase in phrases {
            masked = replaceCI(masked, phrase: phrase)
        }
        return masked
    }

    private static let glutenFreePhrases = [
        "gluten-free", "gluten free", "free from gluten", "contains no gluten", "no gluten",
        "خال من الغلوتين", "خالي من الغلوتين", "خالٍ من الغلوتين", "بدون غلوتين", "بدون جلوتين",
        "لا يحتوي على الغلوتين", "لا يحتوي على الجلوتين"
    ]

    private static let allergenPhrases = [
        "contains:", "contains wheat", "contains barley", "contains rye", "contains gluten",
        "allergen information", "allergens:",
        "يحتوي على:", "يحتوي:", "يحتوي على القمح", "يحتوي على الشعير", "يحتوي على الغلوتين",
        "مسببات الحساسية:", "معلومات الحساسية:"
    ]

    private static let crossContactPhrases = [
        "may contain wheat", "may contain gluten", "may contain rye", "may contain barley",
        "may contain traces of wheat", "may contain traces of gluten",
        "manufactured in a facility that also processes wheat",
        "processed in a facility that also processes wheat",
        "made on equipment that also processes wheat",
        "manufactured on shared equipment", "made on shared equipment",
        "shared equipment", "cross-contact", "cross contact",
        "cross-contamination", "cross contamination",
        "قد يحتوي على القمح", "قد يحتوي على قمح", "قد يحتوي على الغلوتين", "قد يحتوي على غلوتين",
        "قد يحتوي على الشعير", "قد يحتوي على آثار من القمح", "قد يحتوي على آثار من الغلوتين",
        "قد يحتوي على آثار", "مصنع في منشأة", "تم تصنيعه في منشأة",
        "معدات مشتركة", "خط إنتاج مشترك", "تلوث تبادلي"
    ]

    private static func glutenFreeClaims(in text: String) -> [LabelStatement] {
        glutenFreePhrases.compactMap { phrase in
            guard containsPhrase(text, phrase) else { return nil }
            return LabelStatement(kind: .glutenFreeClaim, originalText: phrase, mentionsGlutenAllergen: false)
        }
    }

    private static func allergenDeclarations(in text: String) -> [LabelStatement] {
        var hits: [LabelStatement] = []
        let englishContains = matchesContainsLine(in: text, prefixes: ["contains:", "contains "])
        if englishContains.mentionsWheatBarleyRyeOrGluten {
            hits.append(LabelStatement(kind: .allergenDeclaration, originalText: englishContains.line, mentionsGlutenAllergen: true))
        }

        let arabicContains = matchesContainsLine(in: text, prefixes: ["يحتوي على:", "يحتوي:", "يحتوي على ", "مسببات الحساسية:", "معلومات الحساسية:"])
        if arabicContains.mentionsWheatBarleyRyeOrGluten {
            hits.append(LabelStatement(kind: .allergenDeclaration, originalText: arabicContains.line, mentionsGlutenAllergen: true))
        }
        return hits
    }

    private static func crossContactWarnings(in text: String) -> [LabelStatement] {
        crossContactPhrases.compactMap { phrase in
            guard containsPhrase(text, phrase) else { return nil }
            let mentions = glutenAllergenMentioned(in: phrase) || glutenAllergenMentioned(in: text)
            return LabelStatement(kind: .crossContactWarning, originalText: phrase, mentionsGlutenAllergen: mentions)
        }
    }

    private static func matchesContainsLine(in text: String, prefixes: [String]) -> (line: String, mentionsWheatBarleyRyeOrGluten: Bool) {
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: .newlines)
        for line in lines {
            let key = ScanTextNormalizer.matchingKey(line)
            for prefix in prefixes {
                let p = ScanTextNormalizer.matchingKey(prefix)
                if isAllergenContainsLine(key, prefix: p), glutenAllergenMentioned(in: line) {
                    return (line.trimmingCharacters(in: .whitespacesAndNewlines), true)
                }
            }
        }
        let whole = ScanTextNormalizer.matchingKey(text)
        if isCrossContactContext(whole) { return ("", false) }
        for prefix in prefixes {
            let p = ScanTextNormalizer.matchingKey(prefix)
            if let range = whole.range(of: p) {
                let snippet = String(whole[range.lowerBound...].prefix(80))
                if isAllergenContainsLine(snippet, prefix: p), glutenAllergenMentioned(in: snippet) {
                    return (String(text.prefix(120)), true)
                }
            }
        }
        return ("", false)
    }

    private static func isCrossContactContext(_ key: String) -> Bool {
        key.contains("may contain") || key.contains("قد يحتوي")
    }

    private static func isAllergenContainsLine(_ key: String, prefix: String) -> Bool {
        guard !isCrossContactContext(key) else { return false }
        return key.hasPrefix(prefix) || key.contains(prefix)
    }

    private static func glutenAllergenMentioned(in text: String) -> Bool {
        let tokens = Set(ScanTextNormalizer.tokens(text))
        let keys = ["wheat", "barley", "rye", "gluten", "قمح", "شعير", "جاودار", "غلوتين", "جلوتين", "حنطة"]
        return keys.contains { tokens.contains(ScanTextNormalizer.tokens($0).first ?? $0) }
    }

    private static func containsPhrase(_ text: String, _ phrase: String) -> Bool {
        let hay = ScanTextNormalizer.matchingKey(text)
        let needle = ScanTextNormalizer.matchingKey(phrase)
        guard !needle.isEmpty else { return false }
        return hay.contains(needle)
    }

    private static func replaceCI(_ text: String, phrase: String) -> String {
        let hay = ScanTextNormalizer.matchingKey(text)
        let needle = ScanTextNormalizer.matchingKey(phrase)
        guard !needle.isEmpty, hay.contains(needle) else { return text }
        var result = text
        let originalNeedleOptions: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        while let r = result.range(of: phrase, options: originalNeedleOptions) {
            result.replaceSubrange(r, with: String(repeating: " ", count: result.distance(from: r.lowerBound, to: r.upperBound)))
        }
        if ScanTextNormalizer.matchingKey(result).contains(needle) {
            var folded = ScanTextNormalizer.matchingKey(result)
            while let r = folded.range(of: needle) {
                folded.replaceSubrange(r, with: String(repeating: " ", count: needle.count))
            }
            return folded
        }
        return result
    }
}
