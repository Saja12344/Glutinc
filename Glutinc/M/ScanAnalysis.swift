import Foundation

enum ScanAnalysisStatus: String, Codable, CaseIterable {
    case glutenDetected
    case reviewRecommended
    case noneDetected
    case unverifiable
    case unreadableIngredients

    var accessibilityName: String {
            switch self {
            case .glutenDetected:
                return L10n.t("Gluten-containing ingredient detected", ar: "تم اكتشاف مكوّن يحتوي على الغلوتين")
            case .reviewRecommended:
                return L10n.t("Review recommended", ar: "يُنصح بالمراجعة")
            case .noneDetected:
                return L10n.t("No gluten-containing ingredients detected", ar: "لم يتم اكتشاف مكونات معروفة باحتوائها على الغلوتين")
            case .unverifiable:
                return L10n.t("We couldn't verify this product", ar: "تعذر التحقق من هذا المنتج")
            case .unreadableIngredients:
                return L10n.t("Couldn't read the ingredient list", ar: "تعذر قراءة قائمة المكونات")
            }
        }

        var supportingText: String {
            switch self {
            case .glutenDetected:
                return L10n.t(
                    "We identified one or more ingredients known to contain gluten.",
                    ar: "وجدنا مكوّنًا واحدًا أو أكثر معروفًا باحتوائه على الغلوتين."
                )
            case .reviewRecommended:
                return L10n.t(
                    "Some ingredients could not be confidently classified. Check the product label and manufacturer information before consumption.",
                    ar: "تعذر تصنيف بعض المكونات بشكل مؤكد. تحقق من ملصق المنتج ومعلومات الشركة المصنعة قبل الاستهلاك."
                )
            case .noneDetected:
                return L10n.t(
                    "We did not identify any known gluten-containing ingredients in the available ingredient information.",
                    ar: "لم نجد في معلومات المكونات المتاحة أي مكونات معروفة باحتوائها على الغلوتين."
                )
            case .unverifiable:
                return L10n.t(
                    "Check the ingredient label manually or try scanning again.",
                    ar: "تحقق من قائمة المكونات يدويًا أو حاول المسح مرة أخرى."
                )
            case .unreadableIngredients:
                return L10n.t(
                    "The ingredient text was not clear enough to analyze. Try a closer, sharper photo focused only on the ingredient list.",
                    ar: "لم تكن قائمة المكونات واضحة بما يكفي للتحليل. حاول التقاط صورة أقرب وأكثر وضوحًا مع التركيز على قائمة المكونات فقط."
                )
            }
        }

        var iconName: String {
            switch self {
            case .glutenDetected: return "exclamationmark.octagon.fill"
            case .reviewRecommended: return "questionmark.circle.fill"
            case .noneDetected: return "list.clipboard.fill"
            case .unverifiable: return "slash.circle.fill"
            case .unreadableIngredients: return "text.viewfinder"
            }
        }

        var tint: ColorToken {
            switch self {
            case .glutenDetected: return .red
            case .reviewRecommended: return .orange
            case .noneDetected: return .teal
            case .unverifiable, .unreadableIngredients: return .gray
            }
        }

    /// Legacy CloudKit boolean must never be treated as a safety claim.
    var legacyIsGlutenFreeFlag: Bool {
        self == .noneDetected
    }
}

enum ColorToken {
    case red, orange, teal, gray
}

struct IngredientHit: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let kind: Kind

    enum Kind: String {
        case gluten
        case ambiguous
        case manufacturerWarning
        case unknown
        case possibleOCR
        case allergenDeclaration
    }
}

struct ScanAnalysisResult {
    var status: ScanAnalysisStatus
    var extractedText: String
    var glutenHits: [IngredientHit]
    var ambiguousHits: [IngredientHit]
    var manufacturerWarnings: [IngredientHit]
    var recognizedNonGluten: [String]
    var ocrConfidence: Double?
    var originalOCRText: String
    var parsedIngredients: [ClassifiedIngredient]
    var unknownHits: [IngredientHit]
    var possibleOCRHits: [IngredientHit]
    var allergenDeclarations: [IngredientHit]
    var glutenFreeClaims: [String]
    var reviewReasons: [ScanReviewReason]
    var scanQuality: ScanQuality
    var ingredientSectionFound: Bool
    var tooSmallForOCR: Bool
    var skippedClassification: Bool

    /// Canonical gluten-risk keywords only. Never raw OCR.
    var flaggedNames: [String] {
        glutenHits.map(\.name)
    }

    var explanation: String {
        if status == .unreadableIngredients, tooSmallForOCR {
            return L10n.t("Move closer to the ingredient list.", ar: "قرّب الكاميرا من قائمة المكونات.")
        }
        if status == .reviewRecommended, !reviewReasons.isEmpty {
            return reviewReasons.map(\.localizedMessage).joined(separator: "\n")
        }
        return status.supportingText
    }

    static let empty = ScanAnalysisResult(
        status: .unverifiable,
        extractedText: "",
        glutenHits: [],
        ambiguousHits: [],
        manufacturerWarnings: [],
        recognizedNonGluten: [],
        ocrConfidence: nil,
        originalOCRText: "",
        parsedIngredients: [],
        unknownHits: [],
        possibleOCRHits: [],
        allergenDeclarations: [],
        glutenFreeClaims: [],
        reviewReasons: [],
        scanQuality: .poor,
        ingredientSectionFound: false,
        tooSmallForOCR: false,
        skippedClassification: false
    )

    static let scannerDisclaimerEN =
        "This result is not a guarantee that the product is gluten-free. Ingredients, formulations, and manufacturing processes may change, and cross-contact may not be detectable from the ingredient list. Always check the product label and manufacturer information before consumption."

    static let scannerDisclaimerAR =
        "هذه النتيجة لا تضمن أن المنتج خالٍ من الغلوتين. قد تتغير المكونات أو تركيبة المنتج أو طريقة التصنيع، وقد لا يمكن اكتشاف التلوث التبادلي من قائمة المكونات. تحقق دائمًا من ملصق المنتج ومعلومات الشركة المصنعة قبل الاستهلاك."

    static var scannerDisclaimer: String {
        L10n.t(scannerDisclaimerEN, ar: scannerDisclaimerAR)
    }
}

enum ScanAnalyzer {
    static func analyze(text: String, ocrConfidence: Double?) -> ScanAnalysisResult {
        analyze(text: text, source: .providedText, observations: [], ocrConfidence: ocrConfidence)
    }

    static func analyze(
        text: String,
        source: ScanTextSource,
        observations: [OCRTextObservation],
        ocrConfidence: Double? = nil
    ) -> ScanAnalysisResult {
        ScanResultEngine.analyze(
            text: text,
            source: source,
            observations: observations,
            ocrConfidence: ocrConfidence
        )
    }

    static func normalizeArabic(_ text: String) -> String {
        ScanTextNormalizer.normalizeArabic(text)
    }

    static func normalizeEnglish(_ text: String) -> String {
        ScanTextNormalizer.normalizeEnglish(text)
    }
}

enum IngredientLanguage {
    static func matches(_ text: String, arabic wantArabic: Bool) -> Bool {
        display(text, arabic: wantArabic) != nil
    }

    static func display(_ text: String, arabic wantArabic: Bool) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let stripped: String
        if wantArabic {
            stripped = String(trimmed.unicodeScalars.filter { !isLatinLetter($0) })
            guard containsArabic(stripped) else { return nil }
        } else {
            stripped = String(trimmed.unicodeScalars.filter { !isArabicScript($0) })
            guard !containsArabic(stripped) else { return nil }
            let hasReadable = stripped.unicodeScalars.contains {
                CharacterSet.letters.contains($0) || CharacterSet.decimalDigits.contains($0)
            }
            guard hasReadable else { return nil }
        }

        let cleaned = stripped
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleaned.count >= 2 else { return nil }
        return cleaned
    }

    private static func isArabicScript(_ scalar: Unicode.Scalar) -> Bool {
        (0x0600...0x06FF).contains(scalar.value)
            || (0x0750...0x077F).contains(scalar.value)
            || (0x08A0...0x08FF).contains(scalar.value)
            || (0xFB50...0xFDFF).contains(scalar.value)
            || (0xFE70...0xFEFF).contains(scalar.value)
    }

    private static func isLatinLetter(_ scalar: Unicode.Scalar) -> Bool {
        CharacterSet.letters.contains(scalar) && scalar.value <= 0x024F
    }

    private static func containsArabic(_ text: String) -> Bool {
        text.unicodeScalars.contains(where: isArabicScript)
    }
}
