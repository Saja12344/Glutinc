import Foundation
import CoreGraphics

enum OCRQuality: String, Sendable {
    case good
    case partial
    case poor
}

struct OCRQualityAssessment: Sendable {
    let quality: OCRQuality
    let skipClassification: Bool
    let reason: String
    let tooSmall: Bool
    let looksLikeGibberish: Bool
    let headerFound: Bool
}

enum OCRQualityEvaluator {
    static func assess(
        text: String,
        observations: [OCRTextObservation],
        source: ScanTextSource,
        policy: OCRConfidencePolicy = .standard
    ) -> OCRQualityAssessment {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let section = IngredientRegionDetector.detect(in: trimmed)
        let regionText = section.found ? section.text : trimmed
        let known = IngredientMatcher.knownConceptCount(in: regionText)
        let gibberish = looksLikeGibberish(trimmed, headerFound: section.found, knownConcepts: known)
        let arabicMismatch = arabicExpectedButLatinGarbage(trimmed)
        let tooSmall = observationsAreTooSmall(observations, headerFound: section.found)
        let structural = hasIngredientStructure(trimmed, headerFound: section.found, knownConcepts: known)

        let regionObservations = IngredientRegionDetector.observationsInIngredientRegion(observations)
        let regionQuality = regionObservationQuality(regionObservations, policy: policy)

        #if DEBUG
        print("[GlutincOCR] header=\(section.found) known=\(known) gibberish=\(gibberish) arabicMismatch=\(arabicMismatch) tooSmall=\(tooSmall) structural=\(structural) regionObs=\(regionObservations.count) regionQuality=\(regionQuality) source=\(source.rawValue)")
        #endif

        if trimmed.isEmpty {
            return OCRQualityAssessment(
                quality: .poor,
                skipClassification: true,
                reason: "empty",
                tooSmall: false,
                looksLikeGibberish: false,
                headerFound: false
            )
        }

        if gibberish || arabicMismatch {
            return OCRQualityAssessment(
                quality: .poor,
                skipClassification: true,
                reason: gibberish ? "gibberish" : "arabic-script-mismatch",
                tooSmall: tooSmall,
                looksLikeGibberish: true,
                headerFound: section.found
            )
        }

        if source == .userEdited {
            return OCRQualityAssessment(
                quality: structural ? .good : .partial,
                skipClassification: false,
                reason: "user-edited",
                tooSmall: false,
                looksLikeGibberish: false,
                headerFound: section.found
            )
        }

        if tooSmall && !section.found && known < 2 {
            return OCRQualityAssessment(
                quality: .poor,
                skipClassification: true,
                reason: "text-too-small",
                tooSmall: true,
                looksLikeGibberish: false,
                headerFound: section.found
            )
        }

        if !structural {
            let tokenCount = ScanTextNormalizer.tokens(trimmed).count
            let shouldReject =
                source == .ocr
                || (known == 0 && !section.found && tokenCount >= 4)
            if shouldReject {
                return OCRQualityAssessment(
                    quality: .poor,
                    skipClassification: true,
                    reason: "no-ingredient-structure",
                    tooSmall: tooSmall,
                    looksLikeGibberish: false,
                    headerFound: section.found
                )
            }
        }

        if source == .ocr, regionQuality == .poor, !section.found, !observations.isEmpty {
            return OCRQualityAssessment(
                quality: .poor,
                skipClassification: true,
                reason: "low-region-confidence",
                tooSmall: tooSmall,
                looksLikeGibberish: false,
                headerFound: false
            )
        }

        if !observations.isEmpty && (regionQuality == .partial || tooSmall || (section.found && known == 0 && source == .ocr)) {
            return OCRQualityAssessment(
                quality: .partial,
                skipClassification: false,
                reason: "partial-read",
                tooSmall: tooSmall,
                looksLikeGibberish: false,
                headerFound: section.found
            )
        }

        return OCRQualityAssessment(
            quality: .good,
            skipClassification: false,
            reason: "ok",
            tooSmall: false,
            looksLikeGibberish: false,
            headerFound: section.found
        )
    }

    /// Conservative garbage detector. Rare legitimate ingredients should still pass
    /// if a header, separators, or known food concepts are present.
    static func looksLikeGibberish(_ text: String, headerFound: Bool, knownConcepts: Int) -> Bool {
        if headerFound && knownConcepts >= 1 { return false }
        if knownConcepts >= 2 { return false }

        let tokens = ScanTextNormalizer.tokens(text)
        guard tokens.count >= 3 else {
            if !headerFound && knownConcepts == 0 && tokens.count >= 1 {
                return tokens.allSatisfy(isNonsenseToken)
            }
            return false
        }

        let nonsense = tokens.filter { isNonsenseToken($0) }.count
        let ratio = Double(nonsense) / Double(tokens.count)
        let separators = text.contains(",") || text.contains("،") || text.contains(";") || text.contains("؛")
        if knownConcepts == 0 && !headerFound && !separators && ratio >= 0.4 { return true }
        if knownConcepts == 0 && !headerFound && ratio >= 0.65 { return true }
        return false
    }

    private static func isNonsenseToken(_ token: String) -> Bool {
        if IngredientMatcher.modifiers.contains(token) { return false }
        if ScanTextNormalizer.containsArabic(token) {
            return token.count <= 1
        }
        let letters = token.filter(\.isLetter)
        let digits = token.filter(\.isNumber).count
        if letters.isEmpty { return true }
        if digits > 0 && letters.count > 0 && token.count <= 6 { return true }
        if token.contains(where: { "!@#$%^&*_=+~`|\\".contains($0) }) { return true }
        guard letters.count >= 2 else { return true }
        let vowels = letters.filter { "aeiouyàáâäèéêëìíîïòóôöùúûü".contains($0) }.count
        let vowelRatio = Double(vowels) / Double(letters.count)
        if vowels == 0 && letters.count >= 3 { return true }
        if letters.count >= 4 && vowelRatio <= 0.28 { return true }
        if hasLongConsonantRun(letters) { return true }
        return false
    }

    private static func hasLongConsonantRun(_ letters: String) -> Bool {
        var run = 0
        for ch in letters {
            if "aeiouyàáâäèéêëìíîïòóôöùúûü".contains(ch) {
                run = 0
            } else {
                run += 1
                if run >= 4 { return true }
            }
        }
        return false
    }

    private static func arabicExpectedButLatinGarbage(_ text: String) -> Bool {
        let arabic = text.filter { ScanTextNormalizer.containsArabic(String($0)) }.count
        let latin = text.filter { $0.isASCII && $0.isLetter }.count
        guard latin >= 12 else { return false }
        if arabic >= 8 { return false }
        let tokens = ScanTextNormalizer.tokens(text)
        let nonsense = tokens.filter { isNonsenseToken($0) }.count
        return arabic < 3 && nonsense >= max(3, tokens.count / 2)
    }

    private static func hasIngredientStructure(_ text: String, headerFound: Bool, knownConcepts: Int) -> Bool {
        if headerFound { return true }
        if knownConcepts >= 2 { return true }
        if knownConcepts >= 1 && ScanTextNormalizer.tokens(text).count <= 8 { return true }
        let separators = text.filter { $0 == "," || $0 == "،" }.count
        return separators >= 1 && knownConcepts >= 1
    }

    private static func observationsAreTooSmall(_ observations: [OCRTextObservation], headerFound: Bool) -> Bool {
        guard !observations.isEmpty else { return false }
        let region = IngredientRegionDetector.observationsInIngredientRegion(observations)
        let pool = region.isEmpty ? observations : region
        let heights = pool.map(\.boundingBox.height)
        let median = heights.sorted()[heights.count / 2]
        let coverage = pool.reduce(CGFloat.zero) { $0 + $1.boundingBox.width * $1.boundingBox.height }
        return (median < 0.012 || coverage < 0.012) && !headerFound
    }

    private static func regionObservationQuality(_ observations: [OCRTextObservation], policy: OCRConfidencePolicy) -> OCRQuality {
        guard !observations.isEmpty else { return .good }
        let mean = observations.map(\.confidence).reduce(0, +) / Float(observations.count)
        let low = observations.filter { $0.confidence < policy.reviewThreshold }.count
        if mean < policy.reviewThreshold || low * 2 >= observations.count { return .poor }
        if mean < policy.confidentThreshold || low > 0 { return .partial }
        return .good
    }
}
